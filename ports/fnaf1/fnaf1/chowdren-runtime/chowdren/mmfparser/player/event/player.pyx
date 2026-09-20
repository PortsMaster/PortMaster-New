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

cimport cython

import time
import random
from collections import defaultdict

from mmfparser.player.event.conditions.common cimport Condition
from mmfparser.player.event.actions.common cimport Action
from mmfparser.player.instance cimport Instance
from mmfparser.player.event.evaluater cimport Evaluater
from mmfparser.player.event.expressions.common cimport Expression
from mmfparser.player.event.common cimport ExpressionList, ACEBase

from mmfparser.player.event.conditions.common import FalseCondition
from mmfparser.player.event.actions.common import EmptyAction
from mmfparser.player.event.actions.create import CreateObject
from mmfparser.player.event.actions.extension import ShootToward, Shoot
from mmfparser.player.event.conditions.system import NotAlways, OrLogical
from mmfparser.data.chunkloaders.objectinfo import EXTENSION_BASE

DEF PROFILE = 0
DEF DEBUG = 1

cdef enum:
    OR_NONE,
    OR_LOGICAL,
    OR_FILTERED

cdef inline bint is_qualifier(handle):
    return handle & 32768 == 32768

cdef inline int get_qualifier(handle):
    return handle & 2047

cdef inline bint is_expression(item):
    return isinstance(item, ExpressionList)

cdef inline list get_search_handles(Group self, handle):
    if is_qualifier(handle):
        return self.eventPlayer.resolve_objects(handle) + [handle]
    else:
        return [handle]

cdef dict CONDITIONS, ACTIONS, EXPRESSIONS
cdef object StartOfFrame, EndOfApplication

cdef void initialize_events():
    if CONDITIONS is not None:
        return
    global CONDITIONS, StartOfFrame, EndOfApplication, ACTIONS, EXPRESSIONS
    from mmfparser.player.event.conditions.all import CONDITIONS
    from mmfparser.player.event.conditions.application import (StartOfFrame, 
        EndOfApplication)
    from mmfparser.player.event.actions.all import ACTIONS
    from mmfparser.player.event.expressions.all import EXPRESSIONS

cdef class Group(PlayerChild):
    cdef void initialize(self, list conditionGroups, list actionList, 
                         Container container, int index, int orType):
        self.enabled = True
        self.eventPlayer = self.parent
        self.index = index # merely for debugging :)
        self.orType = orType
        self.settings = {}
        #self.frame = self.player.frame
        self.container = container
        self.conditions = conditions = []
        self.actions = actions = []
        self.actionClasses = actionClasses = {}
        self.conditionClasses = conditionClasses = {}
        cdef list currentConditions
        
        cdef Condition newCondition
        for conditionList in conditionGroups:
            currentConditions = []
            for index, condition in enumerate(conditionList):
                triggered = index == 0 and not condition.flags['Always']
                conditionClass = self.find_condition(condition)
                newCondition = self.new(conditionClass)
                newCondition.initialize(condition, triggered)
                currentConditions.append(newCondition)
                if conditionClass in conditionClasses:
                    conditionClasses[conditionClass].append(newCondition)
                else:
                    conditionClasses[conditionClass] = [newCondition]

            conditions.append(currentConditions)

        cdef Action newAction
        for action in actionList:
            actionClass = self.find_action(action)
            newAction = self.new(actionClass)
            newAction.initialize(action)
            actions.append(newAction)
            if actionClass in actionClasses:
                actionClasses[actionClass].append(newAction)
            else:
                actionClasses[actionClass] = [newAction]
        self.triggered = conditions[0][0].isTriggered
        self.notAlways = len(self.get_conditions(NotAlways)) > 0
    
    # XXX it would probably be a good idea to move these
    
    cdef type find_condition(self, item):
        if item.getType() == EXTENSION_BASE:
            extensionNum = item.getExtensionNum()
            if extensionNum >= 0:
                return self.player.get_extension(item).conditions[
                    extensionNum]
        return CONDITIONS[item.getName()]
    
    cdef type find_action(self, item):
        if item.getType() == EXTENSION_BASE:
            extensionNum = item.getExtensionNum()
            if extensionNum >= 0:
                return self.player.get_extension(item).actions[
                    extensionNum]
        return ACTIONS[item.getName()]
        
    cdef type find_expression(self, item):
        if item.getType() == EXTENSION_BASE:
            extensionNum = item.getExtensionNum()
            if extensionNum >= 0:
                IF DEBUG:
                    try:
                        return self.player.get_extension(item).expressions[
                            extensionNum]
                    except:
                        import traceback
                        traceback.print_exc()
                        print self.player.get_extension(item)
                        return None
                ELSE:
                    return self.player.get_extension(item).expressions[
                        extensionNum]
        return EXPRESSIONS[item.getName()]
    
    cpdef list get_conditions(self, klass, objectInfo = None):
        cdef list searchHandles
        try:
            if objectInfo is None:
                return self.conditionClasses[klass]
            else:
                searchHandles = get_search_handles(self, objectInfo)
                return [condition for condition in self.conditionClasses[klass]
                    if condition.loader.objectInfo in searchHandles]
        except KeyError:
            return []

    cpdef list get_actions(self, klass, objectInfo = None):
        cdef list searchHandles
        try:
            if objectInfo is None:
                return self.actionClasses[klass]
            else:
                searchHandles = get_search_handles(self, objectInfo)
                return [action for action in self.actionClasses[klass]
                    if action.loader.objectInfo in searchHandles]
        except KeyError:
            return []
    
    cdef list get_instances(self, infoHandle):
        if infoHandle in self.eventPlayer.selectedInstances:
            return self.eventPlayer.selectedInstances[infoHandle]
        else:
            return self.player.frame.get_instances(infoHandle)
    
    cdef void select_instances(self, handle, list instanceList):
        self.eventPlayer.selectedInstances[handle] = instanceList
    
    cdef void execute(self):
        if not self.container.is_enabled():
            return
        cdef dict oldSelected = self.eventPlayer.selectedInstances
        cdef dict allSelected
        if self.orType == OR_NONE:
            self.eventPlayer.selectedInstances = {}
        else:
            allSelected = {}
        cdef Condition condition
        cdef list conditionGroup
        cdef bint value = False
        cdef bint group_value
        cdef list instanceList
        for conditionGroup in self.conditions:
            if self.orType != OR_NONE:
                self.eventPlayer.selectedInstances = {}
                group_value = False
            for condition in conditionGroup:
                if not condition.handle():
                    break
            else:
                group_value = True
                value = True
            if (self.orType == OR_LOGICAL and group_value) or self.orType == OR_FILTERED:
                for k, v in self.eventPlayer.selectedInstances.iteritems():
                    if k in allSelected:
                        instanceList = allSelected[k]
                        for instance in v:
                            if instance not in instanceList:
                                instanceList.append(instance)
                    else:
                        allSelected[k] = v
        if not value:
            if self.notAlways:
                self.enabled = True
        elif not self.enabled:
            if self.triggered: 
                if self.loopCount + 1 >= self.eventPlayer.loopCount:
                    self.loopCount = self.eventPlayer.loopCount
                    value = False
            elif self.loopCount + 1 < self.eventPlayer.loopCount:
                self.enabled = True
            else:
                self.loopCount = self.eventPlayer.loopCount
                value = False
        if not value:
            self.eventPlayer.selectedInstances = oldSelected
            return
        if self.orType != OR_NONE:
            self.eventPlayer.selectedInstances = allSelected
        
        cdef Action action
        for action in self.actions:
            
            action.handle()
        # swap position stuff
        cdef Instance instance1, instance2
        cdef double a_x, a_y, b_x, b_y
        if self.swaps is not None:
            if len(self.swaps) > 1:
                random.shuffle(self.swaps)
                instance1 = self.swaps[0]
                a_x, a_y = instance1.x, instance1.y
                instance2 = self.swaps[1]
                b_x, b_y = instance2.x, instance2.y
                instance1.set_position(b_x, b_y)
                instance2.set_position(a_x, a_y)
            self.swaps = None
            
        # self.selectedInstances = oldSelected
        if self.notAlways:
            self.enabled = False
            self.loopCount = self.eventPlayer.loopCount
        return

cdef class Container(PlayerChild):
    def initialize(self, groupParameter):
        self.name = groupParameter.name
        self.callbacks = []
        self.enabled = not groupParameter.flags['Inactive']
        self.parentContainer = self.parent
    
    cpdef add_enable_callback(self, func):
        self.callbacks.append(func)
        
    cpdef remove_enable_callback(self, func):
        try:
            self.callbacks.remove(func)
        except ValueError:
            pass
    
    cpdef bint is_enabled(self):
        return self.enabled and self.parentContainer.is_enabled()
    
    cpdef enable(self):
        if self.enabled:
            return
        self.enabled = True
        for callback in self.callbacks:
            callback()
    
    cpdef disable(self):
        self.enabled = False

cdef class BaseContainer(Container):
    def initialize(self):
        pass
    
    cpdef bint is_enabled(self):
        return True

cdef class Loop:
    pass

cdef class EventPlayer(PlayerChild):    
    cpdef initialize(self, events):
        initialize_events()
        self.objectIndex = -1
        self.qualifiers = qualifiers = {}
        self.evaluater = self.new(Evaluater)
        self.evaluater.initialize()
        frameItems = self.player.gameData.frameItems
        for item in events.qualifiers.values():
            qualifiers[item.qualifier] = item.resolve_objects(
                frameItems)
        self.always_groups = []
        self.groups = groups = []
        self.containers = containers = []
        self.containerPointers = containerPointers = {}
        self.containerIds = containerIds = {}
        self.conditions = conditions = <dict>defaultdict(list)
        self.actions = actions = <dict>defaultdict(list)
        self.loops = {}
        
        cdef Container currentContainer
        cdef Group newGroup

        currentContainer = self.new(BaseContainer)
        currentContainer.initialize()
        cdef str name
        cdef list names
        
        cdef int conditionIndex, index
        cdef int orType
        
        for index, item in enumerate(events.items):
            firstCondition = item.conditions[0]
            names = [condition.getName() for condition in item.conditions]
            name = names[0]
            if name == 'NewGroup':
                groupParameter = firstCondition.items[0].loader
                currentContainer = currentContainer.new(
                    Container)
                currentContainer.initialize(groupParameter)
                containerPointers[groupParameter.offset] = currentContainer
                containerIds[groupParameter.id] = currentContainer
                self.containers.append(currentContainer)
                continue
            elif name == 'GroupEnd':
                currentContainer = currentContainer.parentContainer
                continue
            if 'OrLogical' in names:
                orType = OR_LOGICAL
            elif 'OrFiltered' in names:
                orType = OR_FILTERED
            else:
                orType = OR_NONE
            
            if orType == OR_NONE:
                newGroup = self.new(Group)
                newGroup.initialize([item.conditions], item.actions, 
                    currentContainer, index, OR_NONE)
                groups.append(newGroup)
            else:
                alwaysGroups = []
                generatedGroups = []
                subgroup = []
                for conditionIndex, name in enumerate(names):
                    if name in ('OrLogical', 'OrFiltered'):
                        if subgroup:
                            if subgroup[0].flags['Always']:
                                alwaysGroups.append(subgroup)
                            else:
                                generatedGroups.append(subgroup)
                        subgroup = []
                        continue
                    subgroup.append(item.conditions[conditionIndex])
                if subgroup:
                    if subgroup[0].flags['Always']:
                        alwaysGroups.append(subgroup)
                    else:
                        generatedGroups.append(subgroup)
                
                for group in generatedGroups:
                    newGroup = self.new(Group)
                    newGroup.initialize([group], item.actions, 
                        currentContainer, index, OR_NONE)
                    groups.append(newGroup)
                if alwaysGroups:
                    newGroup = self.new(Group)
                    newGroup.initialize(alwaysGroups, item.actions, 
                        currentContainer, index, orType)
                    groups.append(newGroup)
                
        for newGroup in groups:
            for conditionGroup in newGroup.conditions:
                for condition in conditionGroup:
                    conditionClass = condition.__class__
                    conditions[conditionClass].append(condition)
            for action in newGroup.actions:
                actions[action.__class__].append(action)
            if not newGroup.triggered:
                self.always_groups.append(newGroup)
        
        # make sure all actions and conditions know all groups have been
        # initialized
        cdef int i
        cdef ExpressionList newList
        cdef ACEBase ace
        for newGroup in groups:
            for aceList in ((newGroup.actions,), newGroup.conditions):
                for aceGroup in aceList:
                    for ace in aceGroup:
                        if ace.parameters:
                            for parameter in ace.parameters:
                                if is_expression(parameter):
                                    newList = <ExpressionList>parameter
                                    for i in range(newList.size):
                                        (<Expression>newList.items[i]).created()
                        ace.created()
    
    def get_loop(self, name):
        cdef Loop loop
        name = name.lower()
        if name in self.loops:
            return self.loops[name]
        else:
            loop = Loop()
            self.loops[name] = loop
            return loop

    cpdef loop(self, sinceLast):
        self.looping = True
        self.loopCount += 1
        cdef Condition condition
        cdef bint fading
        if not self.started:
            self.started = True
            fading = self.player.fading
            self.player.fading = False
            for condition in self.conditions[StartOfFrame]:
                condition.generate()
            self.player.fading = fading
        if self.player.fading:
            self.looping = False
            return
        cdef Group group
        for group in self.always_groups:
            IF PROFILE:
                oldTime = time.clock()
            group.execute()
            IF PROFILE:
                timeTaken = time.clock() - oldTime
                if timeTaken > 0.006:
                    print 'took', timeTaken, group.actions
        self.looping = False
    
    def generate_event(self, klass, objectInfo = None):
        # used by main to generate events
        cdef Condition condition
        for condition in self.conditions[klass]:
            if objectInfo is not None and condition.loader.objectInfo != objectInfo:
                continue
            condition.generate()
    
    cpdef list resolve_objects(self, objectInfo):
        if is_qualifier(objectInfo):
            return self.qualifiers[get_qualifier(objectInfo)]
        return [objectInfo]
    
    cpdef quit(self):
        if EndOfApplication in self.conditions.keys():
            for condition in self.conditions[EndOfApplication]:
                condition.generate()