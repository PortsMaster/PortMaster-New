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

from mmfparser.player.event.actions.common cimport Action
from mmfparser.player.event.conditions.common cimport Condition
from mmfparser.player.event.actions.common import EmptyAction
from mmfparser.player.event.player cimport Container, EventPlayer, Loop
from mmfparser.player.event.common cimport (ExpressionList,
    ConstantExpressionList)
from mmfparser.player.event.conditions.system import OnLoop

class Skip(EmptyAction):
    pass

class CenterDisplayY(Action):
    def execute(self):
        self.player.set_center(y = self.evaluate_expression(
            self.get_parameter(0)))

class CenterDisplayX(Action):
    def execute(self):
        self.player.set_center(x = self.evaluate_expression(
            self.get_parameter(0)))

class CenterDisplay(Action):
    def execute(self):
        try:
            x, y, instance = self.get_positions(self.get_parameter(0))[0]
        except IndexError:
            return
        self.player.set_center(x = x, y = y)

cdef class _GroupAction(Action):
    cdef public:
        Container container

    cdef void created(self):
        groupPointer = self.get_parameter(0)
        cdef EventPlayer eventPlayer = self.eventPlayer
        cdef Container container
        if groupPointer.pointer != 0:
            container = eventPlayer.containerPointers[groupPointer.pointer]
        else:
            container = eventPlayer.containerIds[groupPointer.id]
        self.container = container
    
cdef class ActivateGroup(_GroupAction):
    cdef void execute(self):
        # print 'activating group', self.container.name
        self.container.enable()

cdef class DeactivateGroup(_GroupAction):
    cdef void execute(self):
        # print 'deactivating group', self.container.name
        self.container.disable()

cdef class AddGlobalValue(Action):
    cdef void execute(self):
        cdef int index = self.get_global_index(self.get_parameter(0))
        cdef object value = self.evaluate_index(1)
        cdef object original = self.player.globals.get_value(index)
        self.player.globals.set_value(index, original + value)

cdef class SubtractGlobalValue(Action):
    cdef void execute(self):
        cdef int index = self.get_global_index(self.get_parameter(0))
        cdef object value = self.evaluate_index(1)
        cdef object original = self.player.globals.get_value(index)
        self.player.globals.set_value(index, original - value)

cdef class SetGlobalValue(Action):
    cdef void execute(self):
        cdef int index = self.get_global_index(self.get_parameter(0))
        cdef object value = self.evaluate_index(1)
        self.player.globals.set_value(index, value)

cdef class SetGlobalString(Action):
    cdef void execute(self):
        cdef int index = self.get_global_index(self.get_parameter(0))
        cdef object value = self.evaluate_index(1)
        self.player.globals.set_string(index, value)

cdef class StartLoop(Action):
    cdef public:
        bint initialized
        list conditions
        Loop loop
        bint debug
        bint constant

    cdef void execute(self):
        if not self.initialized or not self.constant:
            parameter = self.get_parameter(0)
            if not self.initialized:
                self.constant = isinstance(parameter, ConstantExpressionList)
                self.initialized = True
            name = self.evaluate_expression(parameter)
            if name == 'debug_anaconda':
                self.debug = True
            else:
                self.conditions = [item for item in self.get_conditions(OnLoop)
                    if item.evaluate_expression(item.get_parameter(0)) == name]
                self.loop = self.eventPlayer.get_loop(name)
        
        if self.debug:
            self.player.open_debug()
            return

        cdef int loops = self.evaluate_index(1)
        
        cdef Loop loop = self.loop
        
        cdef int i
        
        cdef Condition condition
        
        cdef bint oldStopped = loop.stopped
        cdef int oldIndex = loop.index
        loop.stopped = False
        
        i = 0
        
        while 1:
            if loops >= 0 and i >= loops:
                break
            loop.index = i
            for condition in self.conditions:
                condition.generate()
            if loop.stopped:
                break
            i = loop.index + 1
        
        loop.index = oldIndex
        loop.stopped = oldStopped

cdef class StopLoop(Action):
    cdef public:
        bint initialized
        Loop loop
        list actions

    cdef void execute(self):
        if not self.initialized:
            name = self.evaluate_index(0)
            self.loop = self.eventPlayer.get_loop(name)
            self.initialized = True
        self.loop.stopped = True

cdef class SetLoopIndex(Action):
    cdef void execute(self):
        name = self.evaluate_index(0)
        index = self.evaluate_index(1)
        (<Loop>self.eventPlayer.loops[name.lower()]).index = index

cdef class FullscreenMode(Action):
    cdef void execute(self):
        self.player.set_fullscreen(True)

cdef class WindowedMode(Action):
    cdef void execute(self):
        self.player.set_fullscreen(False)

cdef class OpenDebugger(Action):
    cdef void execute(self):
        pass

cdef class PauseDebugger(Action):
    cdef void execute(self):
        pass

cdef class SetRandomSeed(Action):
    cdef void execute(self):
        value = self.evaluate_index(0)
        random.seed(value)