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

cdef class PlayerChild

cdef object replace_color(image, int r1, int g1, int b1, int r2, int g2, int b2)

cpdef inline unsigned int make_color_number(unsigned char r, unsigned char g, 
                                  unsigned char b):
    return (r | g << 8 | b << 16)

cpdef inline tuple get_color_number(unsigned int value):
    return value & 0xFF, (value & 0xFF00) >> 8, (value & 0xFF0000) >> 16

# math stuff

cdef inline int int_max(int a, int b): return a if a >= b else b
cdef inline int int_min(int a, int b): return a if a <= b else b
    
cdef extern from "math.h":
    double sin(double)
    double cos(double)
    double abs(double)
    double fabs(double)

DEF PI = 3.141592653589793238462643

DEF PI_OVER_180 = 0.017453292519943295

cdef inline double radians(double degrees):
    return PI_OVER_180 * degrees

cdef inline void get_point(int x, int y, int angle, double x_scale, 
        double y_scale, int * new_x, int * new_y):
    cdef double co, si
    co = cos(angle * PI_OVER_180)
    si = sin(angle * PI_OVER_180)
    new_x[0] = <int>(x * x_scale * co + y * y_scale * si)
    new_y[0] = <int>(y * y_scale * co - x * x_scale * si)

cdef inline int int_max_4(int a, int b, int c, int d):
    cdef int value = int_max(a, b)
    value = int_max(value, c)
    value = int_max(value, d)
    return value

cdef inline int int_min_4(int a, int b, int c, int d):
    cdef int value = int_min(a, b)
    value = int_min(value, c)
    value = int_min(value, d)
    return value

cdef inline void transform_rect(int width, int height, double co, 
        double si, double scaleX, double scaleY, int * r_x1, int * r_y1, int * r_x2, 
        int * r_y2):
    top_right_x = <int>(width * scaleX * co)
    top_right_y = <int>(-width * scaleX * si)
    bottom_left_x = <int>(height * scaleY * si)
    bottom_left_y = <int>(height * scaleY * co)
    bottom_right_x = <int>(width * scaleX * co + height * scaleY * si)
    bottom_right_y = <int>(height * scaleY * co - width * scaleX * si)
    r_x1[0] = int_min_4(0, top_right_x, bottom_left_x, bottom_right_x)
    r_x2[0] = int_max_4(0, top_right_x, bottom_left_x, bottom_right_x)
    r_y1[0] = int_min_4(0, top_right_y, bottom_left_y, bottom_right_y)
    r_y2[0] = int_max_4(0, top_right_y, bottom_left_y, bottom_right_y)

from mmfparser.player.main cimport GamePlayer

cdef class PlayerChild:
    cdef:
        list _childs

    cdef public:
        PlayerChild parent
        GamePlayer player
        bint detached
    
    cdef void init(self, object player, PlayerChild parent)
    cpdef detach(self)
    cpdef on_detach(self)
    cdef void _detach(self)
    cpdef PlayerChild new(self, type typeClass)