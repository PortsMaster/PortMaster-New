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

from cpython cimport PyObject

cdef class Value
cdef class Evaluater

from mmfparser.player.event.expressions.common cimport Expression
from mmfparser.player.event.common cimport ExpressionList
from mmfparser.player.common cimport PlayerChild

cdef class Value:
    cdef object value
    
    cdef void set(self, value)
    cdef object get(self)

cdef class Evaluater(PlayerChild):
    cdef public:
        bint finished
        int pilePosition
        Value currentValue
        bint isFirst
        Expression endOperator
    cdef:
        PyObject ** operators
        PyObject ** results
        PyObject ** items
        int stackPosition

    cdef void reset(self, ExpressionList loader)
    cdef object evaluate(self)
    cdef object evaluate_next(self)
    cdef void go_forward(self)
    cdef Expression get_next(self)