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

cdef class Container
cdef class Group
cdef class EventPlayer

from mmfparser.player.event.evaluater cimport Evaluater
from mmfparser.player.frame cimport Frame
from mmfparser.player.common cimport PlayerChild

cdef class Container(PlayerChild):
    cdef public:
        str name
        bint enabled
        Container parentContainer
    cdef list callbacks
    
    cpdef add_enable_callback(self, func)
    cpdef remove_enable_callback(self, func)
    cpdef bint is_enabled(self)
    cpdef enable(self)
    cpdef disable(self)

cdef class Group(PlayerChild):
    cdef public:
        Container container
        int index
        list conditions
        list actions
        list swaps
    cdef int orType
    cdef int loopCount
    cdef dict conditionClasses
    cdef dict actionClasses
    cdef Frame frame
    cdef bint notAlways
    cdef bint triggered
    cdef bint enabled
    cdef dict settings
    cdef EventPlayer eventPlayer
    
    cdef void initialize(self, list conditionGroups, list actionList, 
        Container container, int index, int orType)
    cdef type find_condition(self, item)
    cdef type find_action(self, item)
    cdef type find_expression(self, item)
    cpdef list get_conditions(self, klass, objectInfo = ?)
    cpdef list get_actions(self, klass, objectInfo = ?)
    cdef list get_instances(self, infoHandle)
    cdef void select_instances(self, handle, list instanceList)
    cdef void execute(self)

cdef class Loop:
    cdef int index
    cdef bint stopped

cdef class EventPlayer(PlayerChild):
    cdef public:
        Evaluater evaluater
        list containers
        dict containerPointers
        dict containerIds
        dict qualifiers
        dict conditions
        dict actions
        bint looping
        int loopCount
        dict loops
        cdef list groups
        dict selectedInstances
        int objectIndex
    cdef list always_groups
    cdef bint started
    
    cpdef initialize(self, events)
    cpdef loop(self, sinceLast)
    cpdef list resolve_objects(self, objectInfo)
    cpdef quit(self)