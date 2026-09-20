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

import random

from mmfparser.player.event.conditions.common cimport Condition
from mmfparser.player.event.conditions.common import TrueCondition, FalseCondition

class Always(TrueCondition):
    pass

class NotAlways(TrueCondition):
    pass

class OrLogical(TrueCondition):
    pass

class OrFiltered(TrueCondition):
    pass

class Never(FalseCondition):
    pass

# just here so I know they're implemented

class GroupEnd(TrueCondition):
    pass

class NewGroup(TrueCondition):
    pass

cdef class CompareGlobalValue(Condition):
    cdef bint check(self):
        value = self.player.globals.get_value(self.get_global_index(
            self.get_parameter(0)))
        evaluated = self.evaluate_index(1)
        return self.compare(value, evaluated)

cdef class CompareGlobalString(Condition):
    cdef bint check(self):
        value = self.player.globals.get_string(self.get_global_index(
            self.get_parameter(0)))
        evaluated = self.evaluate_index(1)
        return self.compare(value, evaluated)

class Once(Condition):
    done = False
    def check(self):
        if not self.done:
            self.done = True
            return True
        return False

cdef class Compare(Condition):
    cdef bint check(self):
        value1 = self.evaluate_index(0)
        value2 = self.evaluate_index(1)
        return self.compare(value1, value2)

class GroupCondition(Condition):
    def created(self):
        self.container = self.group.container

class OnGroupActivation(GroupCondition):
    enabled = False
    def created(self):
        GroupCondition.created(self)
        self.container.add_enable_callback(self.container_enabled)
    
    def container_enabled(self):
        # print 'container.enabled()'
        self.enabled = True
    
    def check(self):
        if self.enabled:
            self.enabled = False
            return True
        return False

class GroupActivated(Condition):
    container = None
    def created(self):
        groupPointer = self.get_parameter(0)
        eventPlayer = self.eventPlayer
        if groupPointer.pointer != 0:
            container = eventPlayer.containerPointers[groupPointer.pointer]
        else:
            container = eventPlayer.containerIds[groupPointer.id]
        self.container = container
    
    def check(self):
        return self.container.is_enabled() != self.negated

cdef class OnLoop(Condition):
    cdef bint check(self):
        return True
        
cdef class PickRandom(Condition):
    def created(self):
        self._iterateObjects = False
    
    cdef bint check(self):
        cdef list instances = self.get_instances()
        if not instances:
            return False
        self.select_instances([random.choice(instances)])
        return True

cdef class Chance(Condition):
    cdef bint check(self):
        value1 = self.evaluate_index(0)
        value2 = self.evaluate_index(1)
        return random.randrange(value2) <= value1

cdef class Repeat(Condition):
    cdef public:
        int times
    
    cdef bint check(self):
        if self.times >= self.evaluate_index(0):
            return False
        self.times += 1
        return True

cdef class RestrictFor(Condition):
    cdef double seconds
    cdef double lastTrigger

    cdef void created(self):
        self.seconds = self.get_parameter(0).timer / 1000.0

    cdef bint check(self):
        cdef double sinceLast = self.player.get_time() - self.lastTrigger
        if self.lastTrigger == 0 or sinceLast > self.seconds:
            self.lastTrigger = self.player.get_time()
            return True
        return False