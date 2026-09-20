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

from mmfparser.player.event.expressions.common cimport Expression, Expression
from mmfparser.player.event.evaluater cimport Value
cimport cython

cdef class SetExpression(Expression):
    cdef object value

    cdef void created(self):
        self.value = self.loader.loader.value

    cdef void execute(self, Value value):
        value.set(self.value)

@cython.final
cdef class Long(SetExpression):
    pass

@cython.final
cdef class Double(SetExpression):
    pass

@cython.final
cdef class String(SetExpression):
    pass

# convert

@cython.final
cdef class ToString(Expression):
    cdef object evaluate(self):
        value = self.next_argument()
        value_int = int(value)
        if value == value_int:
            value = value_int
        return str(value)

@cython.final
cdef class ToNumber(Expression):
    cdef object evaluate(self):
        try:
            return float(self.next_argument())
        except ValueError:
            return 0

@cython.final
cdef class ToInt(Expression):
    cdef object evaluate(self):
        try:
            return int(self.next_argument())
        except ValueError:
            return 0

@cython.final
cdef class FloatToString(Expression):
    cdef object evaluate(self):
        value = self.next_argument()
        digits = self.next_argument() # not used?
        decimals = self.next_argument()
        return ('%%.%sf' % decimals) % value