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

cdef class Expression

from mmfparser.player.event.evaluater cimport Value
from mmfparser.player.instance cimport Instance
from mmfparser.player.event.player cimport Group
from mmfparser.player.event.common cimport ACEBase

cdef class Expression(ACEBase):
    cdef object _get
    cdef public:
        bint isOperator
        int precedence
    
    cdef void initialize(self, loader)
    cdef void execute(self, Value value)
    cdef void created(self)
    cpdef next_argument(self)
    cdef object evaluate(self)
    cdef object evaluate_instance(self, Instance instance)

cdef class DummyExpression(Expression):
    pass