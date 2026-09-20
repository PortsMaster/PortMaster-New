# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

from mmfparser.data.chunkloaders.objects import PLATFORM_OBSTACLE
from mmfparser.player.common cimport cos, sin, radians, transform_rect
from pyglet.image import ImageData

cdef extern from "pmask.c":
    ctypedef struct PMASK:
        pass
    void install_pmask()
    PMASK * create_pmask(int w, int h)
    void destroy_pmask(PMASK * mask)
    void pmask_load_pixels(PMASK *mask, void * pixels, int pitch, 
        int bytes_per_pixel, int trans_color)
    void set_pmask_pixel(PMASK * mask, int x, int y, int value)
    int get_pmask_pixel(PMASK * mask, int x, int y)
    int check_pmask_collision(PMASK * mask1, PMASK * mask2, int x1, int y1, 
        int x2, int y2)
    void fill_pmask(PMASK * mask, int value)
    void pmask_operation_or(PMASK *destination, PMASK * source, int x, int y)
    
def intersect_python(int a_x1, int a_y1, int a_x2, int a_y2, 
                            int b_x1, int b_y1, int b_x2, int b_y2):
    return (int_max(a_x1, b_x1), int_max(a_y1, b_y1), int_min(a_x2, b_x2),
        int_min(a_y2, b_y2))

def collides_python(int a_x1, int a_y1, int a_x2, int a_y2, 
             int b_x1, int b_y1, int b_x2, int b_y2):
    return collides(a_x1, a_y1, a_x2, a_y2, b_x1, b_y1, b_x2, b_y2)

def collide_line(x1, y1, x2, y2, line_x1, line_y1, line_x2, line_y2):
    if line_x2 - line_x1 > line_y2 - line_y1:
        delta = float(line_y2 - line_y1) / (line_x2 - line_x1)
        if line_x2 > line_x1:
            if x2 < line_x1 or x1 >= line_x2:
                return False
        else:
            if x2 < line_x2 or x1 >= line_x1:
                return False
        y = delta * (x1 - line_x1) + line_y1
        if y >= y1 and y < y2:
            return True
        y = delta * (x2 - line_x1) + line_y1
        if y >= y1 and y < y2:
            return True
        return False
    else:
        delta = float(line_x2 - line_x1) / (line_y2 - line_y1)
        if line_y2 > line_y1:
            if y2 < line_y1 or y2 >= line_y2:
                return False
        else:
            if y2 < line_y2 or y1 >= line_y1:
                return False
        x = delta * (y1 - line_y1) + x1
        if x >= x1 and x < x2:
            return True
        x = delta * (y1 - line_y1) + x1
        if x >= x1 and x < x2:
            return True
        return False
            
import weakref
generated_masks = weakref.WeakKeyDictionary()

cdef class MaskContainer:
    cdef PMASK * mask
    
    def __dealloc__(self):
        destroy_pmask(self.mask)

cdef class CollisionBase:
    cdef void get_rect(self, int * r_x1, int * r_y1, int * r_x2, int * r_y2):
        pass # default does nothing
        
    cdef bint get_bit(self, int x, int y):
        return get_pmask_pixel(self.mask, x, y)

cdef class ObjectCollision(CollisionBase):
    cdef void created(self):
        self.xScale = self.yScale = 1.0
        self.parent = self.objectPlayer.parent
        cdef PMASK * newMask
        try:
            if self.objectPlayer.obstacleType == PLATFORM_OBSTACLE:
                newMask = create_pmask(self.width, 6)
                pmask_operation_or(newMask, self.mask, 0, 0)
                self.mask = newMask
                self.isPlatform = True
        except AttributeError:
            pass
    
    def __dealloc__(self):
        if self.isPlatform:
            destroy_pmask(self.mask)

    cpdef set_angle(self, int value):
        self.angle = value
        self.update_transform()
    
    cpdef set_scale(self, double xScale, double yScale):
        self.xScale = xScale
        self.yScale = yScale
        self.update_transform()
    
    cdef void update_transform(self):
        if self.xScale == 1.0 and self.yScale == 1.0 and self.angle == 0:
            self.transform = False
            return
        else:
            self.transform = True
        cdef double co, si
        co = cos(radians(self.angle))
        si = sin(radians(self.angle))
        cdef int x1, y1, x2, y2
        transform_rect(self.width, self.height, co, si, self.xScale, 
            self.yScale, &x1, &y1, &x2, &y2)
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.cosinus = cos(radians(-self.angle))
        self.sinus = sin(radians(-self.angle))
    
    cdef bint get_bit(self, int x, int y):
        if not self.transform:
            return get_pmask_pixel(self.mask, x, y)
        cdef int sourceX, sourceY
        cdef double x2 = x + self.x1
        cdef double y2 = y + self.y1
        sourceX = <int>((x2 * self.cosinus + y2 * self.sinus) / self.xScale)
        sourceY = <int>((y2 * self.cosinus - x2 * self.sinus) / self.yScale)
        if (sourceX >= 0 and sourceX < self.width 
        and sourceY >= 0 and sourceY < self.height):
            return get_pmask_pixel(self.mask, sourceX, sourceY)
        return False
    
    def get_image(self):
        width, height = self.objectPlayer.width, self.objectPlayer.height
        cdef bytes data = bytes('\x00' * (width * height))
        cdef char * work_data = data
        cdef int x, y
        for y in range(self.objectPlayer.height):
            for x in range(self.objectPlayer.width):
                if get_pmask_pixel(self.mask, x, y):
                    work_data[y * width + x] = 255
                else:
                    work_data[y * width + x] = 10
        image = ImageData(self.objectPlayer.width, self.objectPlayer.height, 
            'A', data, -self.objectPlayer.width)
        return image
    
    def get_transformed_image(self):
        cdef int width = self.x2 - self.x1
        cdef int height = self.y2 - self.y1
        cdef bytes data = bytes('\x00' * (width * height))
        cdef char * work_data = data
        cdef int x, y
        for y in range(height):
            for x in range(width):
                if self.get_bit(x, y):
                    work_data[y * width + x] = 255
                else:
                    work_data[y * width + x] = 10
        image = ImageData(self.objectPlayer.width, self.objectPlayer.height, 
            'A', data, -self.objectPlayer.width)
        return image
        
    def draw(self):
        image = self.get_image()
        texture = image.get_texture()
        texture.width = image.width
        texture.height = image.height
        texture.anchor_x = (self.objectPlayer.hotspotX)
        texture.anchor_y = (image.height - (self.objectPlayer.hotspotY))
        texture.blit(self.objectPlayer.x, self.objectPlayer.y, 
            width = image.width, height = image.height)
    
    def draw_transformed(self):
        image = self.get_transformed_image()
        texture = image.get_texture()
        texture.width = image.width
        texture.height = image.height
        texture.anchor_x = (self.objectPlayer.hotspotX)
        texture.anchor_y = (image.height - (self.objectPlayer.hotspotY))
        texture.blit(self.objectPlayer.x, self.objectPlayer.y, 
            width = image.width, height = image.height)
            
    cdef void get_rect(self, int * r_x1, int * r_y1, int * r_x2, int * r_y2):
        if not (<Instance>self.parent).boxSet:
            (<Instance>self.parent).update_bounding_box()
        r_x1[0] = (<Instance>self.parent).x1
        r_y1[0] = (<Instance>self.parent).y1
        r_x2[0] = (<Instance>self.parent).x2
        r_y2[0] = (<Instance>self.parent).y2

cdef class Collision(ObjectCollision):
    def __init__(self, image, sprite, BaseObject objectPlayer):
        self.image = image
        self.objectPlayer = objectPlayer
        self.width = sprite.width
        self.height = sprite.height
        cdef MaskContainer maskContainer
        cdef PMASK * bitmask
        cdef char * mask
        
        cdef int x, y, value
        if image in generated_masks:
            bitmask = (<MaskContainer>generated_masks[image]).mask
        else:
            bitmask = create_pmask(self.width, self.height)
            alphaMask = image.alpha
            mask = alphaMask

            for x in range(self.width):
                for y in range(self.height):
                    if mask[x + y * self.width]:
                        value = 1
                    else:
                        value = 0
                    set_pmask_pixel(bitmask, x, y, value)

            maskContainer = MaskContainer()
            maskContainer.mask = bitmask
            generated_masks[image] = maskContainer

        self.mask = bitmask
        self.created()

cdef dict transformed_masks = {}

cdef inline PMASK * transform_mask(PMASK * oldMask, CollisionBase base):
    cdef double xScale, yScale
    cdef int angle
    xScale = base.xScale
    yScale = base.yScale
    angle = base.angle
    cdef tuple key = (<int>oldMask, angle, xScale, yScale)
    if key in transformed_masks:
        return (<MaskContainer>transformed_masks[key]).mask
    cdef double co, si
    co = cos(radians(angle))
    si = sin(radians(angle))
    cdef int x1, y1, x2, y2, width, height, oldWidth, oldHeight
    oldWidth = base.width
    oldHeight = base.height
    transform_rect(oldWidth, oldHeight, co, si, xScale, yScale, 
        &x1, &y1, &x2, &y2)
    width = x2 - x1
    height = y2 - y1
    cdef PMASK * newMask = create_pmask(width, height)
    fill_pmask(newMask, 0)
    cdef int x, y, sourceX, sourceY
    co = cos(radians(-angle))
    si = sin(radians(-angle))

    for y in range(y1, y2):
        for x in range(x1, x2):
            sourceX = <int>(x / xScale * co + y / yScale * si)
            sourceY = <int>(y / yScale * co - x / xScale * si)
            if (sourceX >= 0 and sourceX < oldWidth 
            and sourceY >= 0 and sourceY < oldHeight):
                set_pmask_pixel(newMask, x - x1, y - y1, 
                    get_pmask_pixel(oldMask, sourceX, sourceY))
            
    cdef MaskContainer container = MaskContainer()
    container.mask = newMask
    transformed_masks[key] = container
    return newMask

cdef inline PMASK * make_rectangle_mask(int width, int height):
    cdef PMASK * mask = create_pmask(width, height)
    cdef int x, y
    for x in range(width):
        for y in range(height):
            set_pmask_pixel(mask, x, y, 1)
    return mask

cdef class BoundingBox(ObjectCollision):
    def __init__(self, BaseObject objectPlayer):
        self.width = objectPlayer.width or 0
        self.height = objectPlayer.height or 0
        self.objectPlayer = objectPlayer
        self.mask = make_rectangle_mask(self.width, self.height)
        self.created()
        self.isBounding = True
    
    def __dealloc__(self):
        destroy_pmask(self.mask)
    
    def resize(self, width, height):
        destroy_pmask(self.mask)
        self.mask = make_rectangle_mask(self.width, self.height)

cdef class Rectangle(CollisionBase):
    def __init__(self, int x, int y, int width, int height):
        self.x1 = x
        self.y1 = y
        self.x2 = x + width
        self.y2 = y + height
        self.width = width
        self.height = height
        self.mask = make_rectangle_mask(self.width, self.height)
        self.isBounding = True
        
    def __dealloc__(self):
        destroy_pmask(self.mask)
    
    cdef void get_rect(self, int * r_x1, int * r_y1, int * r_x2, int * r_y2):
        r_x1[0] = self.x1
        r_y1[0] = self.y1
        r_x2[0] = self.x2 + 1
        r_y2[0] = self.y2 + 1

cdef PMASK * point_mask = make_rectangle_mask(1, 1)

cdef class Point(CollisionBase):
    def __init__(self, int x, int y):
        self.x1 = x
        self.y1 = y
        self.x2 = x + 1
        self.y2 = y + 1
        self.width = 1
        self.height = 1
        self.mask = point_mask
        self.isBounding = True
    
    def set_position(self, x, y):
        self.x1 = x
        self.y1 = y
        self.x2 = x + 1
        self.y2 = y + 1
        
    cdef void get_rect(self, int * r_x1, int * r_y1, int * r_x2, int * r_y2):
        r_x1[0] = self.x1
        r_y1[0] = self.y1
        r_x2[0] = self.x2 + 1
        r_y2[0] = self.y2 + 1

install_pmask()

cdef inline bint collide(CollisionBase lhs, CollisionBase rhs):
    cdef int a_x1, a_y1, a_x2, a_y2, b_x1, b_y1, b_x2, b_y2
    lhs.get_rect(&a_x1, &a_y1, &a_x2, &a_y2)
    rhs.get_rect(&b_x1, &b_y1, &b_x2, &b_y2)
    if not (lhs.transform or rhs.transform):
        return check_pmask_collision(lhs.mask, rhs.mask, a_x1, a_y1, b_x1, 
            b_y1)
    # we're transformed <3
    if not collides(a_x1, a_y1, a_x2, a_y2, b_x1, b_y1, b_x2, b_y2):
        return False
    if lhs.isBounding and rhs.isBounding:
        return True
    cdef int x1, y1, x2, y2
    # calculate the overlapping area
    intersect(a_x1, a_y1, a_x2, a_y2, b_x1, b_y1, b_x2, b_y2,
        &x1, &y1, &x2, &y2)
    # figure out the offsets of the overlapping area in each sprite
    cdef int offx1 = x1 - a_x1
    cdef int offy1 = y1 - a_y1
    cdef int offx2 = x1 - b_x1
    cdef int offy2 = y1 - b_y1
    
    cdef bint bounding1 = lhs.isBounding
    cdef bint bounding2 = rhs.isBounding
    
    cdef int c1, c2, x, y
    # for each overlapping pixel, check for a collision

    for x in range(x2 - x1):
        for y in range(y2 - y1):
            if bounding1:
                c1 = 1
            else:
                c1 = lhs.get_bit(offx1+x, y + offy1)
            if bounding2:
                c2 = 1
            else:
                c2 = rhs.get_bit(offx2+x, y + offy2)
            if c1 and c2:
                return 1
    return 0

def collide_python(lhs, rhs):
    return collide(lhs, rhs)