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

cdef class Instance

from mmfparser.player.alterables cimport Alterables
from mmfparser.player.objects.common cimport BaseObject
from mmfparser.player.frame cimport Frame, Layer
from mmfparser.player.movements.common cimport MovementPlayer
from mmfparser.player.common cimport PlayerChild

cdef class InkEffect:
    cdef public:
        object effect
        object shaders
        object parameters

    cdef void begin(self)
    cdef void end(self)

cdef class Instance(PlayerChild):
    cdef public:
        Frame frame
        double x, y
        int x1, y1, x2, y2
        int oldX1, oldY1, oldX2, oldY2
        bint boxSet
        bint collisionSet
        int direction
        object loader
        object objectInstance
        int handle
        object objectInfo
        int objectType
        BaseObject objectPlayer
        list movementPlayers
        MovementPlayer currentMovement
        int movementIndex
        bint movementEnabled
        bint updateEnabled
        bint sleep
        bint destroyed
        bint destroying
        bint visible
        bint scroll
        bint flashing
        InkEffect inkEffect
        double transparency
        Layer layer
        int layerIndex
        Alterables alterables
        bint wrap
        bint wrapUp
        bint wrapDown
        bint wrapLeft
        bint wrapRight
        bint outsideKill
        bint positionChanged
        bint initialized
        tuple colorCoefficient

    cdef void update_bounding_box(self)
    cpdef set_position(self, double x, double y, bint fromAction = ?)
    cpdef update_collisions(self, list instances)
    cpdef set_direction(self, int direction, bint force = ?)
    cpdef inline int get_direction(self)
    cpdef inline int get_leaving_corners(self)
    cpdef inline int get_entering_corners(self)
    cpdef inline bint is_leaving(self)
    cpdef inline bint outside_playfield(self)
    cpdef inline tuple get_outside_corners(self)
    cpdef inline bint in_playfield(self, int x_border = ?, int y_border = ?)
    cpdef inline bint inside_window(self, int x_border = ?, int y_border = ?)
    cpdef inline bint in_zone(self, int xZone, int yZone, int xZone2, 
        int yZone2)
    cpdef inline bint inside_zone(self, int xZone, int yZone, int xZone2, 
        int yZone2)
    cpdef inline bint mouse_over(self)
    cdef void draw(self)
    cpdef object_changed(self)
    cdef void update(self)
    cdef void update_playfield(self)