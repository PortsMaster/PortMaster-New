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

cdef class MovementPlayer

from mmfparser.player.objects.common cimport BaseObject
from mmfparser.player.instance cimport Instance
from mmfparser.player.common cimport PlayerChild

cdef class MovementPlayer(PlayerChild):
    cdef public:
        object player_handler
        double sinceLast
        int direction
        double x_speed
        double y_speed
        double speed
        int maxSpeed
        int minSpeed
        bint _useKeys
        double multiplier
        set collisions
        dict overlapping
        set collidingInstances
        bint collided
        bint isShoot
        bint isStatic
        bint hasAnimations
        bint breakMovement
    
    cpdef update(self)
    cpdef ready(self)
    cpdef double get_pixels(self, double value)
    cpdef set_direction(self, direction = ?)
    cpdef tuple move_object(self, double addX, double addY)
    cpdef bint handle_collisions(self, set instances = ?)
    cpdef bint update_collisions(self, set instances)
    cpdef bint instance_collides(self, Instance instance)