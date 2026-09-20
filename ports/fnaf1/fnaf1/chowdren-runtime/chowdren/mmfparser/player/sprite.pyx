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

cdef extern from "include_math.h":
    cdef float fmodf(float x, float y)
    cdef float cosf(float x)
    cdef float sinf(float x)
    cdef float sqrtf(float x)
    cdef float PI, PI_OVER_180
    cdef float expf(float x)
    cdef float fabsf(float x)
    cdef float M_PI

from mmfparser.player.opengl cimport *
from pyglet.image import (ImageData as PygletImage, Texture, TextureRegion)
import math
from mmfparser.player.collision cimport Collision
from mmfparser.player.main cimport GamePlayer
from mmfparser.player.objects.common cimport BaseObject
from mmfparser.player.instance cimport Instance, InkEffect
from mmfparser.player.fbo import get_fbo
from mmfparser.player.common cimport int_max, int_min
from pyglet.gl import (glActiveTexture, GL_TEXTURE0, GL_TEXTURE1, glUseProgram,
    glMultiTexCoord2f, GL_CLAMP_TO_EDGE)

global get_alpha
get_alpha = None

class ImageData(PygletImage):
    alpha = None
    _texture = None
    def __init__(self, width, height, format, data, pitch, alpha = None):
        if format not in ('RGB', 'RGBA'):
            raise NotImplementedError('all images should be in RGB or RGBA')
        if alpha is None:
            global get_alpha
            if get_alpha is None:
                from mmfparser.player.common import get_alpha
            alpha = get_alpha(data, 'A' in format)
        self.alpha = alpha
        PygletImage.__init__(self, width, height, format, data, pitch)
    
    def get_region(self, x, y, width, height):
        from mmfparser.player.common import get_region
        region = TextureRegion(x, y, 0, width, height, self.get_texture())
        y = self.height - y - height
        region.alpha = get_region(self.alpha, x, y, width, height, self.width)
        return region
    
    def get_texture(self):
        if self._texture is not None:
            return self._texture
        texture = self._texture = PygletImage.get_texture(self)
        texture.alpha = self.alpha
        return texture

cdef struct Point2d:
    float x, y

cdef struct float2:
    float a, b

cdef class Quad:
    cdef Point2d v[4]
    def __init__(self, definition):
        try:
            definition[0][0]
        except TypeError:
            if len(definition) == 2:
                l = -definition[0]/2
                r =  definition[0]/2
                b = -definition[1]/2
                t =  definition[1]/2
                definition = [(l, t), (r, t), (r, b), (l, b)]
            elif len(definition) == 4:
                l, t, r, b = definition
                definition = [(l, t), (r, t), (r, b), (l, b)]
            elif len(definition) == 12:
                # Assume this is in the format of pyglet's tex_coords.
                d = definition
                definition = [
                        (d[9],d[10]), # l t
                        (d[6],d[7]), # r t
                        (d[3],d[4]), # r b
                        (d[0],d[1])] # l b
            else:
                raise ValueError("Don't know what to do with %r" % definition)
        assert len(definition) == 4
        cdef int i
        for i, v in enumerate(definition):
            self.__setitem__(i, v)

    def __getitem__(self, int i):
        if i < 0:
            i = 4 + i
        if i < 0 or i >= 4:
            raise IndexError(i)
        return self.v[i].x, self.v[i].y
    def __setitem__(self, int i, value):
        if i < 0:
            i = 4 + i
        if i < 0 or i >= 4:
            raise IndexError(i)
        self.v[i].x = value[0]
        self.v[i].y = value[1]

    def __len__(self):
        return 4

    cdef void _shift_x(self, float offset):
        for i from 0 <= i < 4:
            self.v[i].x = self.v[i].x + offset

    cdef void _shift_y(self, float offset):
        for i from 0 <= i < 4:
            self.v[i].y = self.v[i].y + offset

    property width:
        def __get__(self):
            cdef float2 b
            b = self._bounds_x()
            return b.b - b.a
        def __set__(self, float value):
            cdef float scale, center
            cdef float2 bounds
            cdef int i
            bounds = self._bounds_x()
            center = (bounds.a + bounds.b)/2
            if bounds.a == bounds.b:
                self.v[0].x = self.v[3].x = center-value/2
                self.v[1].x = self.v[2].x = center+value/2
            else:
                scale = value/(bounds.b - bounds.a)
                for i from 0 <= i < 4:
                    self.v[i].x = (self.v[i].x - center) * scale + center

    property height:
        def __get__(self):
            cdef float2 b
            b = self._bounds_y()
            return b.b - b.a
        def __set__(self, float value):
            cdef float scale, center
            cdef float2 bounds
            cdef int i
            bounds = self._bounds_y()
            center = (bounds.a + bounds.b)/2
            if bounds.a == bounds.b:
                self.v[0].y = self.v[1].y = center+value/2
                self.v[2].y = self.v[3].y = center-value/2
            else:
                scale = value/(bounds.b - bounds.a)
                for i from 0 <= i < 4:
                    self.v[i].y = (self.v[i].y - center) * scale + center

    property x:
        def __get__(self):
            cdef float2 b
            b = self._bounds_x()
            return (b.a + b.b)/2
        def __set__(self, float value):
            cdef float2 current
            current = self._bounds_x()
            self._shift_x(value - (current.a + current.b)/2)

    property y:
        def __get__(self):
            cdef float2 b
            b = self._bounds_y()
            return (b.a + b.b)/2
        def __set__(self, value):
            cdef float2 current
            current = self._bounds_y()
            self._shift_y(value - (current.a + current.b)/2)

    property xy:
        def __get__(self):
            return (self.x, self.y)
        def __set__(self, value):
            self.x, self.y = value

    cdef float2 _bounds_x(self):
        cdef float2 bounds
        cdef float x
        cdef int i
        bounds.a = bounds.b = self.v[0].x
        for i from 1 <= i < 4:
            x = self.v[i].x
            if bounds.a > x:
                bounds.a = x
            if bounds.b < x:
                bounds.b = x
        return bounds

    cdef float2 _bounds_y(self):
            cdef float2 bounds
            cdef float y
            cdef int i
            bounds.a = bounds.b = self.v[0].y
            for i from 1 <= i < 4:
                y = self.v[i].y
                if bounds.a > y:
                    bounds.a = y
                if bounds.b < y:
                    bounds.b = y
            return bounds

    property left:
        def __get__(self):
            return self._bounds_x().a
        def __set__(self, float v):
            self._shift_x(v - self._bounds_x().a)

    property right:
        def __get__(self):
            return self._bounds_x().b
        def __set__(self, float v):
            self._shift_x(v - self._bounds_x().b)

    property bottom:
        def __get__(self):
            return self._bounds_y().a
        def __set__(self, float v):
            self._shift_y(v - self._bounds_y().a)

    property top:
        def __get__(self):
            return self._bounds_y().b
        def __set__(self, float v):
            self._shift_y(v - self._bounds_y().b)

    def __repr__(self):
        return "Quad((%r, %r, %r, %r))" % (self[0], self[1], self[2], self[3])

cdef class Sprite:
    cdef public:
        object texture
        int texture_id
        float red, green, blue, alpha
        float rot
        float x, y
        float scale_x, scale_y
        int width, height

    cdef Quad _shape, _tex_shape
    
    def __init__(self, image):
        self._init_sprite(image)
    
    cdef void _init_sprite(self, image):
        texture = self.texture = image.get_texture()
        self.width = image.width
        self.height = image.height
        self.red = self.green = self.blue = self.alpha = 1.0
        self.x = self.y = 0
        self.scale = 1
        self.rot = 0
        self.texture_id = texture.id
        self.tex_shape = texture.tex_coords
        anchor_x = texture.anchor_x
        anchor_y = texture.anchor_y
        self.shape = [-anchor_x, -anchor_y+self.height, -anchor_x+self.width,
            -anchor_y]

    def set_angle(self, value):
        self.rot = value
    
    def set_scale(self, xScale, yScale):
        xScale = max(0.0, xScale)
        yScale = max(0.0, yScale)
        self.scale_x = xScale
        self.scale_y = yScale
    
    def flip_horizontal(self):
        t_left, t_top, t_right, t_bottom = self.tex_shape
        self.tex_shape = t_top, t_left, t_bottom, t_right
        
    property shape:
        def __get__(self):
            return self._shape
            
        def __set__(self, value):
            if isinstance(value, Quad):
                self._shape = value
            else:
                self._shape = Quad(value)
                
    property xy:
        def __get__(self):
            return self.x, self.y
            
        def __set__(self, value):
            self.x, self.y = value

    property scale:
        def __get__(self):
            return self.scale_x, self.scale_y
        def __set__(self, value):
            try:
                self.scale_x, self.scale_y = value
            except TypeError:
                self.scale_x = self.scale_y = value

    property tex_shape:
        def __get__(self):
            return self._tex_shape
        def __set__(self, value):
            if isinstance(value, Quad):
                self._tex_shape = value
            else:
                self._tex_shape = Quad(value)
    
    cdef int _render(self, bint final = True,
                     object background_texture = None):
        if background_texture is not None:
            glActiveTexture(GL_TEXTURE0)
        glEnable(GL_TEXTURE_2D)
        glBindTexture(GL_TEXTURE_2D, self.texture_id)
        if background_texture is not None:
            glActiveTexture(GL_TEXTURE1)
            glEnable(GL_TEXTURE_2D)
            glBindTexture(GL_TEXTURE_2D, background_texture.id)
        
        cdef float color[4]
        if final:
            color[0] = self.red
            color[1] = self.green
            color[2] = self.blue
            color[3] = self.alpha
            glColor4fv(color)

        cdef float x, y, sx, sy, r
        x = self.x
        y = self.y
        if final:
            sx = self.scale_x
            sy = self.scale_y
        else:
            sx = sy = 1.0
        r = self.rot

        cdef int i
        cdef float vx, vy, co, si

        cdef Point2d * vert, * tex
        vert = self._shape.v
        tex = self._tex_shape.v
        cdef Point2d back[4]
        if background_texture is not None:
            coords = background_texture.tex_coords
            for i, coord in enumerate(((coords[9], coords[10]),
                                      (coords[6], coords[7]),
                                      (coords[3], coords[4]),
                                      (coords[0], coords[1]))):
                back[i].x = coord[0]
                back[i].y = coord[1]
        glBegin(GL_QUADS)
        if r == 0:
            if background_texture is None:
                glTexCoord2f(tex[0].x,tex[0].y)
                glVertex2f(vert[0].x*sx+x,vert[0].y*sy+y)
                glTexCoord2f(tex[1].x,tex[1].y)
                glVertex2f(vert[1].x*sx+x,vert[1].y*sy+y)
                glTexCoord2f(tex[2].x,tex[2].y)
                glVertex2f(vert[2].x*sx+x,vert[2].y*sy+y)
                glTexCoord2f(tex[3].x,tex[3].y)
                glVertex2f(vert[3].x*sx+x,vert[3].y*sy+y)
            else:
                glTexCoord2f(tex[0].x, tex[0].y)
                glMultiTexCoord2f(GL_TEXTURE1, back[0].x, back[0].y)
                glVertex2f(vert[0].x*sx+x,vert[0].y*sy+y)
                glTexCoord2f(tex[1].x, tex[1].y)
                glMultiTexCoord2f(GL_TEXTURE1, back[1].x, back[1].y)
                glVertex2f(vert[1].x*sx+x,vert[1].y*sy+y)
                glTexCoord2f(tex[2].x,tex[2].y)
                glMultiTexCoord2f(GL_TEXTURE1, back[2].x, back[2].y)
                glVertex2f(vert[2].x*sx+x,vert[2].y*sy+y)
                glTexCoord2f(tex[3].x,tex[3].y)
                glMultiTexCoord2f(GL_TEXTURE1, back[3].x, back[3].y)
                glVertex2f(vert[3].x*sx+x,vert[3].y*sy+y)
        else:
            r = r * PI_OVER_180
            co = cosf(r)
            si = sinf(r)
            if background_texture is None:
                for i from 0 <= i < 4:
                    glTexCoord2f(tex[i].x,tex[i].y)
                    vx = vert[i].x*sx
                    vy = vert[i].y*sy
                    glVertex2f((vx*co - vy*si)+x, (vx*si + vy*co)+y)
            else:
                for i from 0 <= i < 4:
                    glTexCoord2f(tex[i].x,tex[i].y)
                    glMultiTexCoord2f(GL_TEXTURE1, back[i].x, back[i].y)
                    vx = vert[i].x*sx
                    vy = vert[i].y*sy
                    glVertex2f((vx*co - vy*si)+x, (vx*si + vy*co)+y)
        glEnd()
        
        if background_texture is not None:
            glDisable(GL_TEXTURE_2D)
            glActiveTexture(GL_TEXTURE0)
    
    cpdef int render(self):
        self._render()
        
    cdef float2 _bounds_x(self):
        cdef float2 bounds
        cdef float r, co, si, x, sx, sy
        cdef int i
        sx = self.scale_x
        sy = self.scale_y
        r = self.rot
        r = r * PI_OVER_180
        co = cosf(r)
        si = sinf(r)

        for i from 0 <= i < 4:
            x = (self._shape.v[i].x*sx*co - self._shape.v[i].y*sy*si)
            if i == 0:
                bounds.a = x
                bounds.b = x
            else:
                if bounds.a > x:
                    bounds.a = x
                if bounds.b < x:
                    bounds.b = x
        return bounds

    cdef float2 _bounds_y(self):
        cdef float2 bounds
        cdef float r, co, si, y, sx, sy
        cdef int i
        sx = self.scale_x
        sy = self.scale_y
        r = self.rot
        r = r * PI_OVER_180
        co = cosf(r)
        si = sinf(r)

        for i from 0 <= i < 4:
            y = (self._shape.v[i].x*sx*si + self._shape.v[i].y*sy*co)
            if i == 0:
                bounds.a = y
                bounds.b = y
            else:
                if bounds.a > y:
                    bounds.a = y
                if bounds.b < y:
                    bounds.b = y
        return bounds

    property left:
        def __get__(self):
            return self._bounds_x().a + self.x
        def __set__(self, x):
            self.x = x - self._bounds_x().a

    property right:
        def __get__(self):
            return self._bounds_x().b + self.x
        def __set__(self, x):
            self.x = x - self._bounds_x().b

    property bottom:
        def __get__(self):
            return self._bounds_y().a + self.y
        def __set__(self, y):
            self.y = y - self._bounds_y().a

    property top:
        def __get__(self):
            return self._bounds_y().b + self.y
        def __set__(self, y):
            self.y = y - self._bounds_y().b
        
cdef class ObjectSprite(Sprite):
    cdef public:
        Collision collision
        GamePlayer player
        Instance instance
        bint cached_set
        float cached_top, cached_left

    def __init__(self, image, BaseObject objectPlayer):
        self._init_sprite(image)
        self.collision = Collision(image, self, objectPlayer)
        self.player = objectPlayer.player
        self.instance = objectPlayer.parent
        self.cached_set = False
    
    def set_angle(self, value):
        if value == self.rot:
            return
        self.rot = value
        self.collision.set_angle(value)
        self.cached_set = False
        
    def set_scale(self, xScale, yScale):
        if xScale == self.scale_x and yScale == self.scale_y:
            return
        xScale = max(0.0, xScale)
        yScale = max(0.0, yScale)
        self.scale_x = xScale
        self.scale_y = yScale
        self.collision.set_scale(xScale, yScale)
        self.cached_set = False

    def get_rect(self):
        return (self.left, self.player.realHeight - self.top, self.right,
            self.player.realHeight - self.bottom)
    
    cpdef int render(self):
        cdef InkEffect inkEffect = self.instance.inkEffect
        colorCoefficient = self.instance.colorCoefficient
        if colorCoefficient is not None:
            r, g, b = colorCoefficient
            self.red = r
            self.green = g
            self.blue = b
        else:
            self.red = self.green = self.blue = 1.0
        if inkEffect is None or inkEffect.shaders is None:
            self._render()
            return 0
        cdef list shaders = inkEffect.shaders
        width = <int>self.width
        height = <int>self.height
        cdef tuple size = (width, height)
        width = int(width * self.scale_x)
        height = int(height * self.scale_y)
        cdef tuple pos
        cdef tuple shape
        cdef int original_id, new_texture
        if not self.cached_set:
            self.cached_top = self._bounds_y().b
            self.cached_left = self._bounds_x().a
            self.cached_set = True
        top = (<int>(self.cached_top + self.y)) + self.player.offsetY
        left = (<int>(self.cached_left + self.x)) - self.player.offsetX
        glColor4f(1.0, 1.0, 1.0, 1.0)
        if len(shaders) > 1:
            pos = self.xy
            shape = tuple(self.shape)
            original_id = self.texture_id
            self.x = 0
            self.y = 0
            glPushMatrix()
            glLoadIdentity()
            fbo = get_fbo()
            fbo.start(width, height)
            self.player.fbo.texture.blit(-left, -top + height)
            background_texture = fbo.texture
            fbo.clear_texture()
            glClearColor(0.0, 0.0, 0.0, 0.0)
            glClear(GL_COLOR_BUFFER_BIT)
            new_texture = fbo.texture.id
            self.shape.bottom = self.shape.left = 0
            for new_shader in shaders:
                new_shader.bind(size)
                self._render(False, background_texture)
                self.texture_id = new_texture
            fbo.end()
            glUseProgram(0)
            glPopMatrix()
            self.shape = shape
            self.xy = pos
            self._render()
            self.texture_id = original_id
            self.shape = shape
        else:
            glPushMatrix()
            glLoadIdentity()
            fbo = get_fbo()
            fbo.start(width, height)
            glDisable(GL_BLEND)
            self.player.fbo.texture.blit(-left, -top + height)
            glEnable(GL_BLEND)
            background_texture = fbo.end()
            glPopMatrix()
            shaders[0].bind((self.width, self.height))
            self._render(True, background_texture)
            glUseProgram(0)
    
    def delete(self):
        self.collision.delete()
        self.collision = None
        self.player = None
        self.instance = None

cdef class CreatedFrame:
    cdef public:
        object image
        int xHotspot
        int yHotspot
        int actionX
        int actionY

    def __init__(self, image, xHotspot, yHotspot, actionX, actionY):
        self.image = image
        self.xHotspot = xHotspot
        self.yHotspot = yHotspot
        self.actionX = actionX
        self.actionY = actionY
        image.anchor_x = xHotspot
        image.anchor_y = image.height - yHotspot
    
    def createDisplay(self, *arg, **kw):
        return self.image