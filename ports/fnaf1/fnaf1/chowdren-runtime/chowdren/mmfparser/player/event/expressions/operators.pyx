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

from __future__ import division
from mmfparser.player.event.expressions.common cimport (Expression, 
    DummyExpression, Expression)
from mmfparser.player.event.evaluater cimport Evaluater, Value
import math
cimport cython

cdef class OperatorExpression(Expression):
    cdef void created(self):
        self.isOperator = True
        self.operator_created()
    
    cdef operator_created(self):
        pass

@cython.final
cdef class End(OperatorExpression):
    cdef void initialize(self, loader):
        self.eventPlayer = self.player.eventPlayer
        self.evaluater = self.eventPlayer.evaluater

    cdef operator_created(self):
        self.precedence = 0

    cdef void execute(self, Value value):
        pass

@cython.final
cdef class Plus(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 1

    cdef void execute(self, Value value):
        src_value = value.get()
        new_value = self.evaluater.evaluate_next()
        value.set(value.get() + self.evaluater.evaluate_next())

@cython.final
cdef class Minus(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 2

    cdef void execute(self, Value value):
        if self.evaluater.isFirst:
            self.evaluater.go_forward()
            self.evaluater.get_next().execute(value)
            value.set(-value.get())
        else:
            value.set(value.get() - self.evaluater.evaluate_next())

@cython.final
cdef class Multiply(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 3

    cdef void execute(self, Value value):
        value.set(value.get() * self.evaluater.evaluate_next())

@cython.final
cdef class Divide(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 3

    cdef void execute(self, Value value):
        cdef object value1 = value.get()
        cdef object value2 = self.evaluater.evaluate_next()
        cdef object new_value
        if 0 in (value1, value2):
            new_value = 0
        else:
            if isinstance(value1, float) or isinstance(value2, float):
                new_value = value1 / value2
            else:
                new_value = math.trunc(value1 / value2)
        value.set(new_value)

@cython.final
cdef class Modulus(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 4
    cdef void execute(self, Value value):
        cdef object value1 = value.get()
        cdef object value2 = self.evaluater.evaluate_next()
        if 0 in (value1, value2):
            new_value = 0
        else:
            if isinstance(value1, float) or isinstance(value2, float):
                new_value = value1 % value2
            else:
                new_value = value1 - (value2 * math.trunc(value1 / value2))
        value.set(new_value)

@cython.final
cdef class Power(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 5
    cdef void execute(self, Value value):
        value.set(value.get() ** self.evaluater.evaluate_next())

@cython.final
cdef class AND(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 6
    cdef void execute(self, Value value):
        value.set(value.get() & self.evaluater.evaluate_next())

@cython.final
cdef class OR(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 7
    cdef void execute(self, Value value):
        value.set(value.get() | self.evaluater.evaluate_next())

@cython.final
cdef class XOR(OperatorExpression):
    cdef operator_created(self):
        self.precedence = 8

    cdef void execute(self, Value value):
        value.set(value.get() ^ self.evaluater.evaluate_next())

# not really operators...

@cython.final
cdef class Parenthesis(Expression):
    cdef evaluate(self):
        return self.next_argument()

@cython.final
cdef class Virgule(DummyExpression):
    pass

@cython.final
cdef class EndParenthesis(DummyExpression):
    pass