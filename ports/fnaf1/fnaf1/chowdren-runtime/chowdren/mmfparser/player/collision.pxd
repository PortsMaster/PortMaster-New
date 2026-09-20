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

cdef class CollisionBase
cdef class ObjectCollision
cdef class Rectangle
cdef class BoundingBox
cdef class Point
cdef class Collision

cdef extern from "pmask.h":
    ctypedef struct PMASK:
        pass

cdef inline bint collides(int a_x1, int a_y1, int a_x2, int a_y2, 
                          int b_x1, int b_y1, int b_x2, int b_y2):
    if a_x2 <= b_x1 or a_y2 <= b_y1 or a_x1 >= b_x2 or a_y1 >= b_y2:
        return False
    return True

cdef inline int int_max(int a, int b): return a if a >= b else b
cdef inline int int_min(int a, int b): return a if a <= b else b

cdef inline void intersect(int a_x1, int a_y1, int a_x2, int a_y2, 
                            int b_x1, int b_y1, int b_x2, int b_y2,
                            int * r_x1, int * r_y1, int * r_x2, int * r_y2):
    r_x1[0] = int_max(a_x1, b_x1)
    r_y1[0] = int_max(a_y1, b_y1)
    r_x2[0] = int_min(a_x2, b_x2)
    r_y2[0] = int_min(a_y2, b_y2)

cdef bint collide(CollisionBase lhs, CollisionBase rhs)

from mmfparser.player.instance cimport Instance
from mmfparser.player.objects.common cimport BaseObject

cdef class CollisionBase:
    cdef PMASK * mask
    cdef int width, height
    cdef bint isPlatform
    cdef bint isBounding
    cdef bint transform

    cdef void get_rect(self, int * r_x1, int * r_y1, int * r_x2, int * r_y2)
    cdef bint get_bit(self, int x, int y)

cdef class ObjectCollision(CollisionBase):
    cdef BaseObject objectPlayer
    cdef Instance parent
    
    # transform stuff
    cdef double xScale, yScale
    cdef int angle
    cdef int x1, y1, x2, y2
    cdef double cosinus, sinus

    cdef void created(self)
    cdef void update_transform(self)
    cpdef set_angle(self, int value)
    cpdef set_scale(self, double xScale, double yScale)

cdef class Collision(ObjectCollision):
    cdef object image

cdef class BoundingBox(ObjectCollision):
    pass

cdef class Point(CollisionBase):
    cdef int x1, y1, x2, y2

cdef class Rectangle(CollisionBase):
    cdef int x1, y1, x2, y2