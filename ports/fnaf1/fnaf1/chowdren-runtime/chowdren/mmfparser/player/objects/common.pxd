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

cdef class BaseObject
cdef class BackgroundPlayer
cdef class ObjectPlayer

from mmfparser.player.collision cimport CollisionBase
from mmfparser.player.frame cimport Frame
from mmfparser.player.common cimport PlayerChild

cdef class BaseObject(PlayerChild):
    cdef public:
        double x, y
        int width, height, actionX, actionY, hotspotX, hotspotY
        CollisionBase collision
        object frame
        object loader
        bint updateEnabled
    
    cdef void initialize(self, loader, frame)
    cpdef update(self)
    cpdef bint draw(self)
    cpdef set_position(self, double x, double y)

cdef class BackgroundPlayer(BaseObject):
    pass

cdef class ObjectPlayer(BaseObject):
    cdef public:
        bint isGlobal