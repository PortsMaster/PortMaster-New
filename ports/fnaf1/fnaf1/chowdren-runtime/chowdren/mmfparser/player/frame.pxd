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

cdef class Framecdef class Layerfrom mmfparser.player.event.player cimport EventPlayerfrom mmfparser.player.instance cimport Instancefrom mmfparser.player.common cimport PlayerChildcdef class Layer(PlayerChild):    cdef public:        int x, y        str name        object flags        double xCoefficient        double yCoefficient        list instances        list backInstances        list ladders        list obstacles        bint wrapX, wrapY        dict instanceHandles        set backgrounds        bint visible    cpdef add(self, Instance instance, bint asBackground = ?)    cpdef remove(self, Instance instance)    cpdef bint has_instance(self, Instance instance)    cpdef draw(self)    cpdef set_level(self, Instance instance, int newPosition)    cpdef int get_level(self, Instance instance)    cpdef int get_size(self)    cpdef tuple ladder_at(self, int x, int y)    cpdef set_instances(self, list instances)cdef class Frame(PlayerChild):    cdef public:                object loader        int width, height, virtualWidth, virtualHeight        tuple clearValue        list instances        dict instanceHandles        list pastedInstances        list layers        object fadeIn, fadeOut        dict collisionDict        dict stopDict        set backgrounds        set backgroundCollisions        set backgroundStops        dict objectHandlers        bint startingUp        int objectCount        int maxObjects        double startTime        list timeChangeHandlers        list topRenders        set noSleepHandles, borderCollisionHandles        cdef list get_instances(self, handle)    cpdef bint collision_enabled(self, objectInfo)    cpdef set get_collision_instances(self, Instance instance)    cpdef set get_stop_instances(self, Instance instance)    cdef void update(self)