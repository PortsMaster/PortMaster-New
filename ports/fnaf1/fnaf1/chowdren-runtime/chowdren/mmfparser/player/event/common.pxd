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

cdef class ACEBase
cdef class ACBase
cdef class BaseParameter
cdef class ValueParameter
cdef class BaseExpression
cdef class ExpressionList
cdef class ConstantExpressionList

from mmfparser.player.frame cimport Frame
from mmfparser.player.event.player cimport Group, EventPlayer
from mmfparser.player.instance cimport Instance
from mmfparser.player.common cimport PlayerChild
from mmfparser.player.event.evaluater cimport Evaluater
from mmfparser.player.event.expressions.common cimport Expression

from cpython cimport PyObject, Py_INCREF, Py_DECREF

cimport cython

cdef class ACEBase(PlayerChild):
    cdef public:
        object loader
        bint _iterateObjects
        Frame frame
        Group group
        EventPlayer eventPlayer
        object objectInfo
        list resolvedObjects
        Evaluater evaluater

    cdef void _initialize(self, loader)
    cdef void created(self)
    cpdef Instance get_instance(self, objectInfo = ?)
    cpdef list get_instances(self, objectInfo = ?)
    cpdef list resolve_objects(self, objectInfo)
    cpdef list get_all_instances(self, objectInfo = ?)
    cpdef select_instances(self, list instanceList, objectInfo = ?)
    cpdef get_frame_instances(self)
    cpdef select_frame_instances(self, list instanceList, list allInstances = ?)
    cpdef evaluate_expression(self, object loader)
    cpdef evaluate_index(self, int index)
    
    # parameter stuff
    cpdef direction_from(self, x1, y1, x2, y2, f = ?)
    cpdef get_time(self, parameter)
    cpdef str get_filename(self, parameter)
    cpdef tuple get_color(self, parameter)
    cpdef get_alterable_index(self, parameter)
    cpdef get_global_index(self, parameter)
    cpdef get_parameter_value(self, parameter)
    cpdef int get_direction(self, parameter)
    cpdef list get_directions(self, parameter)
    cpdef list get_positions(self, position)

cdef class BaseParameter(PlayerChild):
    cdef public bint isExpression
    cdef void initialize(self, loader)

cdef class ValueParameter(BaseParameter):
    cdef public object value

cdef class BaseExpression(BaseParameter):
    pass

cdef class ExpressionList(BaseExpression):
    cdef:
        int size
        PyObject ** items

cdef class ConstantExpressionList(BaseExpression):
    cdef public object value

cdef class ACBase(ACEBase):
    cdef public:
        list parameters
        
    cpdef get_parameter(self, int index)