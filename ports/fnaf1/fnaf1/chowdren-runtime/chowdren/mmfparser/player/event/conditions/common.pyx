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

from mmfparser.player.event.common cimport ACBase
from mmfparser.data.chunkloaders.parameters.loaders import (EQUAL, DIFFERENT,
    LOWER_OR_EQUAL, LOWER, GREATER_OR_EQUAL, GREATER)

DEF PROFILE = 1

cdef int EQUAL_INT = EQUAL
cdef int DIFFERENT_INT = DIFFERENT
cdef int LOWER_OR_EQUAL_INT = LOWER_OR_EQUAL
cdef int LOWER_INT = LOWER
cdef int GREATER_OR_EQUAL_INT = GREATER_OR_EQUAL
cdef int GREATER_INT = GREATER

cimport cython

cdef class Condition(ACBase):
    @cython.wraparound(True)
    cdef void initialize(self, loader, bint isTriggered):
        self.isTriggered = isTriggered
        self.negated = loader.otherFlags['Not']
        try:
            self.compareValue = loader.items[-1].loader.comparison
        except (IndexError, AttributeError):
            pass
        self._initialize(loader)
        self._check = getattr(self, 'check', None)
    
    cpdef bint compare(self, value1, value2):
        cdef int compareValue = self.compareValue
        if compareValue == EQUAL_INT:
            return value1 == value2
        elif compareValue == DIFFERENT_INT:
            return value1 != value2
        elif compareValue == LOWER_OR_EQUAL_INT:
            return value1 <= value2
        elif compareValue == LOWER_INT:
            return value1 < value2
        elif compareValue == GREATER_OR_EQUAL_INT:
            return value1 >= value2
        elif compareValue == GREATER_INT:
            return value1 > value2
        return False
    
    cpdef generate(self):
        if self.player.paused or self.player.fading:
            return
        self.group.execute()
    
    cpdef get_conditions(self, conditionClass):
        try:
            return self.eventPlayer.conditions[conditionClass]
        except KeyError:
            return []
        
    cdef bint check(self):
        return <bint>(self._check())
    
    cdef bint check_instance(self, Instance instance):
        return <bint>(self._check(instance))
        
    cpdef bint handle(self):
        cdef Instance instance
        cdef list selected_instances, all_instances
        if self._iterateObjects:
            all_instances = self.get_instances()
            selected_instances = []
            for instance in all_instances:
                self.select_instances([instance])
                # print self
                if self.check_instance(instance) != self.negated:
                    selected_instances.append(instance)
            self.select_instances(selected_instances)
            return len(selected_instances) > 0
        else:
            return self.check()

cdef class TrueCondition(Condition):
    cdef bint check(self):
        return True

    cdef bint check_instance(self, Instance instance):
        return True

cdef class FalseCondition(Condition):
    cdef bint check(self):
        return False
    
    cdef bint check_instance(self, Instance instance):
        return False

cdef class GeneratedInstances:
    cdef list instances
    cdef Condition condition
    cdef int loopCount
    
    def __init__(self, Condition condition):
        self.instances = []
        self.condition = condition
        self.loopCount = -1
    
    cpdef add_instance(self, Instance instance):
        if self.is_valid():
            self.instances.append(instance)
        else:
            self.instances = [instance]
            self.loopCount = self.condition.eventPlayer.loopCount

    cdef bint is_valid(self):
        if self.loopCount == -1:
            return False
        elif self.condition.isTriggered:
            return self.condition.eventPlayer.loopCount == self.loopCount
        else:
            return self.condition.eventPlayer.loopCount <= self.loopCount + 1
    
    cpdef list get_instances(self, objectInfo = None):
        if not self.is_valid():
            return None
        cdef list currentInstances = self.condition.get_instances(objectInfo)
        return list(set(currentInstances) & set(self.instances))
    
    cpdef bint check(self, objectInfo = None):
        cpdef list instances = self.get_instances(objectInfo)
        if instances is None:
            return False
        self.condition.select_instances(instances, objectInfo)
        return True