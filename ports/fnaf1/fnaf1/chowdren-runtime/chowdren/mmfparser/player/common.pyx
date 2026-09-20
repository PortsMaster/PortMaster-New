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

import weakref
from pyglet import image
import array
import math
import os
from pyglet.gl import GL_TEXTURE_2D, GL_RGBA
from cpython cimport PyObject, Py_INCREF, Py_DECREF

generated_images = {}

cdef object replace_color(image, int r1, int g1, int b1, int r2, int g2,
                                 int b2):
    cdef unsigned char * c_data
    cdef unsigned int * c_array
    cdef bint hasAlpha = image.format == 'RGBA'
    data = image.get_data('RGBA' if hasAlpha else 'RGB', image.width * 4)
    c_data = <unsigned char *>data
    cdef int i
    cdef unsigned int color
    cdef bint changed = False
    for i in range(0, len(data), len(image.format)):
        if c_data[i] == r1 and c_data[i + 1] == g1 and c_data[i + 2] == b1:
            changed = True
            c_data[i] = r2
            c_data[i+1] = g2
            c_data[i+2] = b2
    if not changed:
        return None
    from mmfparser.player.sprite import ImageData
    return ImageData(image.width, image.height, 'RGBA' if hasAlpha else 'RGB',
        data, image.width * 4, image.alpha)

loaded_images = {}

from mmfparser.common cimport allocate_memory
from mmfparser.image cimport Image
from mmfparser.image import ImageException

def get_alpha(bytes points, bint hasAlpha):
    cdef unsigned pitch = 4 if hasAlpha else 3
    cdef unsigned char * points_c = points
    cdef char * alpha_c
    alpha = allocate_memory(len(points) / pitch, &alpha_c)
    cdef unsigned char * alpha_array = <unsigned char *>alpha_c
    cdef int i
    for i in range(len(points) / pitch):
        if hasAlpha:
            alpha_array[i] = points_c[i*4+3]
        else:
            alpha_array[i] = 255
    return alpha

def get_region(bytes points, int src_x, int src_y, int width, int height,
               int pitch):
    cdef unsigned char * points_c = points
    cdef char * alpha_c
    alpha = allocate_memory(width * height, &alpha_c)
    cdef unsigned char * alpha_array = <unsigned char *>alpha_c
    cdef int x, y
    for y in range(src_y, src_y + height):
        for x in range(src_x, src_x + width):
            alpha_array[(y - src_y) * width + (x - src_x)] = points_c[
                y * pitch + x]
    return alpha

def load_image(name, transparent = (0, 0, 0)):
    name = convert_path(name)
    try:
        return loaded_images[name]
    except KeyError:
        try:
            image = Image(filename = name)
        except ImageException:
            return None
        image = convert_image(image, transparent)
        loaded_images[name] = image
        return image

cdef convert_image(Image image, tuple transparent):
    cdef int size = image.width * image.height
    cdef unsigned char * data_c
    cdef int i, r, g, b
    if image.channels in (1, 3):
        data_c = image.c_data
        if transparent is None:
            r = data_c[0]
            g = data_c[1]
            b = data_c[2]
        else:
            r, g, b = transparent
        for i in range(size):
            if (data_c[i * 4] == r and data_c[i * 4 + 1] == g and 
            data_c[i * 4 + 2] == b):
                data_c[i * 4 + 3] = 0
            else:
                data_c[i * 4 + 3] = 255
    from mmfparser.player.sprite import ImageData
    return ImageData(image.width, image.height, 'RGBA', image.get_data(), 
        -image.width * 4)

def join_image(list image, list alpha = None):
    data = []
    if alpha is None:
        for point in image:
            data += point
    else:
        for i in xrange(len(alpha)):
            data += image[i]
            data.append(alpha[i])
    return array.array('B', data).tostring()

def make_image(bankItem, *arg, **kw):
    """
    Builds an PIL image from the ImageBank item, and converts it
    to a pyglet.image.ImageData object
    """
    if bankItem in generated_images:
        return generated_images[bankItem]

    imageData = bankItem.createDisplay(*arg, **kw)
    
    generated_images[bankItem] = imageData
    return imageData

def convert_path(str path):
    path = path.replace('\\', os.path.sep)
    path = path.replace(os.path.sep*2, os.path.sep)
    return path

def open_file(str path, *arg, **kw):
    path = convert_path(path)
    return open(path, *arg, **kw)

def direction_from(x1, y1, x2, y2, f = False):
    value = math.degrees(math.atan2(y2 - y1, x2 - x1)) / -11.25
    if not f:
        value = int(value)
    return value

cpdef list get_directions(int value):
    cdef int i
    cdef list directions = []
    for i in range(32):
        if value & (1 << i) != 0:
            directions.append(i)
    return directions

cpdef list make_ellipse_vertices(width, height, step = 5):
    x = width / 2
    y = -height / 2
    r1 = width / 2
    r2 = height / 2
    currentAngle = 0
    vertices = []
    while currentAngle <= 360:
        angleRadians = currentAngle * math.pi / 180
        vertices.append((x + r1 * math.cos(angleRadians), 
            y - r2 * math.sin(angleRadians)))
        currentAngle += step
    return vertices
    
def python_get_point(x, y, angle, x_scale, y_scale):
    cdef int new_x, new_y
    get_point(x, y, angle, x_scale, y_scale, 
        &new_x, &new_y)
    return new_x, new_y

cdef class PlayerChild:
    def __init__(self, object player, PlayerChild parent = None):
        self.init(player, parent)
    
    cdef void init(self, object player, PlayerChild parent):
        self.player = player
        self.parent = parent
        self._childs = []
    
    cpdef PlayerChild new(self, type childClass):
        cdef PlayerChild newChild = childClass.__new__(childClass)
        newChild.init(self.player, self)
        self._childs.append(newChild)
        return newChild
    
    cdef void _detach(self):
        if self.detached:
            return
        self.detached = True
        self.on_detach()
        cdef PlayerChild child
        for child in self._childs:
            child._detach()
        if self.parent is not None and not self.parent.detached:
            self.parent._childs.remove(self)
        self._childs = None
    
    cpdef detach(self):
        self._detach()
    
    cpdef on_detach(self):
        pass

# because I'm the laziest guy on earth, I think this is useful

def find_local_classes(klass, local):
    results = {}
    for k, v in local.iteritems():
        try:
            if issubclass(v, klass):
                results[k] = v
        except TypeError:
            pass
    return results
