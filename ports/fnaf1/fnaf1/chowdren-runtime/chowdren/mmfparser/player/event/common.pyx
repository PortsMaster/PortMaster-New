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

#cython: boundscheck=False

cimport cython

cdef class Expression

from mmfparser.data.chunkloaders.objectinfo import (QUICKBACKDROP, BACKDROP,
    ACTIVE, TEXT, COUNTER, SCORE, LIVES, EXTENSION_BASE)

from mmfparser.player.event.actions.common cimport Action

from collections import defaultdict
import math

cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void free(void *ptr)
    void *malloc(size_t size)
    void *realloc(void *ptr, size_t size)
    size_t strlen(char *s)
    char *strcpy(char *dest, char *src)

cdef inline bint is_expression(item):
    return isinstance(item, BaseExpression)

cdef object direction_from, get_color_number, make_direction, get_directions
cdef inline void initialize():
    global direction_from, get_color_number, make_direction, get_directions
    from mmfparser.player.common import direction_from, get_color_number
    from mmfparser.player.movements import make_direction, get_directions

cdef inline void initialize_ace(ACEBase self, loader):
    if direction_from is None:
        initialize()
    iterateObjects = getattr(self, 'iterateObjects', None)
    if iterateObjects is None:
        if loader and loader.hasObjectInfo():
            self._iterateObjects = True
        else:
            self._iterateObjects = False
    else:
        self._iterateObjects = iterateObjects
    if self.group is None:
        self.group = self.parent
    self.eventPlayer = <EventPlayer>self.group.parent
    self.evaluater = self.eventPlayer.evaluater
    self.frame = self.player.frame
    self.loader = loader
    if loader and loader.objectInfo is not None:
        self.objectInfo = loader.objectInfo
        self.resolvedObjects = self.resolve_objects(self.objectInfo)

cdef class ACEBase(PlayerChild):
    cdef void _initialize(self, loader):
        initialize_ace(self, loader)
    
    cdef void created(self):
        cdef object created = getattr(self, 'created', None)
        if created is None:
            return
        created()
    
    def get_conditions(self, conditionClass):
        try:
            return self.eventPlayer.conditions[conditionClass]
        except KeyError:
            return []

    def get_actions(self, actionClass):
        try:
            return self.eventPlayer.actions[actionClass]
        except KeyError:
            return []
    
    def get_group_conditions(self, klass, objectInfo = None):
        return self.group.get_conditions(klass, objectInfo)
        
    def get_group_actions(self, klass, objectInfo = None):
        return self.group.get_actions(klass, objectInfo)

    cpdef evaluate_index(self, int index):
        cdef object loader = self.parameters[index]
        if isinstance(loader, ConstantExpressionList):
            return (<ConstantExpressionList>loader).value
        self.evaluater.reset(loader)
        result = self.evaluater.evaluate()
        return result

    cpdef evaluate_expression(self, loader):
        if isinstance(loader, ConstantExpressionList):
            return (<ConstantExpressionList>loader).value
        self.evaluater.reset(loader)
        result = self.evaluater.evaluate()
        return result
    
    cpdef direction_from(self, x1, y1, x2, y2, f = False):
        return direction_from(x1, y1, x2, y2, f)
    
    cpdef get_time(self, parameter):
        if is_expression(parameter):
            return self.evaluate_expression(parameter) / 1000.0
        else:
            return parameter.timer / 1000.0
    
    cpdef str get_filename(self, parameter):
        return self.get_parameter_value(parameter)
    
    cpdef tuple get_color(self, parameter):
        if is_expression(parameter):
            return get_color_number(self.evaluate_expression(parameter))
        else:
            return (<ValueParameter>parameter).value
    
    cpdef get_alterable_index(self, parameter):
        return self.get_parameter_value(parameter)
    
    cpdef get_global_index(self, parameter):
        if is_expression(parameter):
            return self.evaluate_expression(parameter) - 1
        else:
            return (<ValueParameter>parameter).value
            
    def get_fixed_index(self, parameter):
        if is_expression(parameter):
            return self.evaluate_expression(parameter) - 1
        else:
            return (<ValueParameter>parameter).value
            
    cpdef get_parameter_value(self, parameter):
        if is_expression(parameter):
            return self.evaluate_expression(parameter)
        else:
            return (<ValueParameter>parameter).value
    
    cpdef int get_direction(self, parameter):
        if is_expression(parameter):
            return self.evaluate_expression(parameter)
        else:
            return make_direction(parameter.value)
    
    cpdef list get_directions(self, parameter):
        if is_expression(parameter):
            return [self.evaluate_expression(parameter)]
        else:
            return get_directions(parameter.value)
    
    cpdef list get_positions(self, position):
        positions = []
        x, y = position.x, position.y
        cdef bint actionPoint = position.flags['Action']
        cdef Instance instance
        if position.objectInfoParent != 0xFFFF:
            for instance in self.get_instances(position.objectInfoParent):
                if actionPoint:
                    newX, newY = instance.objectPlayer.get_action_point()
                else:
                    newX, newY = instance.x, instance.y
                positions.append((x + newX, y + newY, instance))
        else:
            positions.append((x, y, None))
        return positions

    cpdef Instance get_instance(self, objectInfo = None):
        """
        For expressions
        """
        cdef list value = self.get_instances(objectInfo)
        cdef int index = self.group.eventPlayer.objectIndex
        cdef int size = len(value)
        if size:
            if index == -1:
                return value[size - 1]
            else:
                return value[index % size]
        return None

    cpdef list get_instances(self, objectInfo = None):
        """
        For actions and conditions
        """
        cdef list resolvedObjects
        if objectInfo is None:
            objectInfo = self.objectInfo
            resolvedObjects = self.resolvedObjects
        else:
            resolvedObjects = self.resolve_objects(objectInfo)
        cdef list instances = []
        for handle in resolvedObjects:
            instances.extend(self.group.get_instances(handle))
        return instances

    cpdef list resolve_objects(self, objectInfo):
        return self.eventPlayer.resolve_objects(objectInfo)

    cpdef list get_all_instances(self, objectInfo = None):
        if objectInfo is None:
            objectInfo = self.objectInfo
        cdef list instances = []
        cdef int handle
        for handle in self.resolve_objects(objectInfo):
            instances.extend(self.frame.get_instances(handle))
        return instances

    cpdef select_instances(self, list instanceList, objectInfo = None):
        cdef list resolvedObjects
        if objectInfo is None:
            objectInfo = self.objectInfo
            resolvedObjects = self.resolvedObjects
        else:
            resolvedObjects = self.resolve_objects(objectInfo)
        cdef Instance instance
        for handle in resolvedObjects:
            self.group.select_instances(handle, 
                [instance for instance in instanceList
                if instance.handle == handle])

    cpdef get_frame_instances(self):
        cdef Instance instance
        cdef list instances = []
        for instance in self.frame.instances:
            if instance.objectType not in (QUICKBACKDROP, BACKDROP):
                instances.append(instance)
        return instances

    cpdef select_frame_instances(self, list instanceList, list allInstances = None):
        allInstances = allInstances or self.frame.instances[:]
        cdef Instance instance
        cdef set handles = set([instance.handle for instance in allInstances])
        cdef int handle
        cdef dict instances = <dict>defaultdict(list)
        cdef currentList
        for instance in instanceList:
            instances[instance.handle].append(instance)
        for handle in handles:
            self.group.select_instances(handle, instances[handle])

    def add_handlers(self, **kw):
        objectInfo = kw.pop('objectInfo', self.objectInfo)
        self.frame.add_handlers(objectInfo, **kw)

cdef class BaseParameter(PlayerChild):
    cdef void initialize(self, loader):
        pass

cdef class ValueParameter(BaseParameter):
    cdef void initialize(self, value):
        self.value = value
        self.isExpression = False

cdef class BaseExpression(BaseParameter):
    pass

cdef class ExpressionList(BaseExpression):
    cdef void initialize(self, loader):
        self.isExpression = True
        self.size = len(loader.items)
        self.items = <PyObject **>malloc(self.size * sizeof(PyObject *))
        cdef int i
        cdef Expression expression
        for i in range(self.size):
            expressionClass = (<ACBase>self.parent).group.find_expression(
                loader.items[i])
            expression = self.new(expressionClass)
            expression.initialize(loader.items[i])
            Py_INCREF(expression)
            self.items[i] = <PyObject *>expression
    
    def get_items(self):
        cdef list items = []
        cdef int i
        for i in range(self.size):
            items.append(<object>self.items[i])
        return items
    
    cpdef on_detach(self):
        cdef int i
        for i in range(self.size):
            Py_DECREF(<object>self.items[i])
        free(self.items)

cdef class ConstantExpressionList(BaseExpression):
    cdef void initialize(self, value):
        self.value = value
        self.isExpression = True

cdef class ACBase(ACEBase):
    cdef void _initialize(self, loader):
        initialize_ace(self, loader)
        cdef list parameters = []
        self.parameters = parameters
        for parameter in loader.items:
            newLoader = parameter.loader
            if newLoader.isExpression:
                # optimization
                if (len(newLoader.items) == 2 and newLoader.items[0].getName()
                in ('String', 'Double', 'Long')):
                    item = self.new(ConstantExpressionList)
                    value = newLoader.items[0].loader.value
                    (<ConstantExpressionList>item).initialize(value)
                else:
                    item = self.new(ExpressionList)
                    (<ExpressionList>item).initialize(newLoader)
            else:
                try:
                    value = newLoader.value
                    item = self.new(ValueParameter)
                    (<ValueParameter>item).initialize(value)
                except AttributeError:
                    item = newLoader
            parameters.append(item)

    cpdef get_parameter(self, int index):
        return self.parameters[index]