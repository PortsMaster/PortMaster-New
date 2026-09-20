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

from cpython cimport (Py_INCREF, Py_DECREF, PyFloat_CheckExact, 
    PyLong_CheckExact, PyInt_CheckExact, PyString_CheckExact, Py_XDECREF)
cimport cython

cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void free(void *ptr)
    void *malloc(size_t size)
    void *realloc(void *ptr, size_t size)
    size_t strlen(char *s)
    char *strcpy(char *dest, char *src)

cdef int INT = 0
cdef int DOUBLE = 1
cdef int STRING = 2

cdef dict EXPRESSIONS
cdef void initialize_expressions():
    if EXPRESSIONS is None:
        global EXPRESSIONS
        from mmfparser.player.event.expressions.all import EXPRESSIONS

@cython.final
cdef class Value:
    cdef void set(self, value):
        self.value = value
        
    cdef object get(self):
        return self.value

@cython.final
cdef class Evaluater(PlayerChild):
    def initialize(self):
        initialize_expressions()

        cdef int i
        self.operators = <PyObject **>malloc(128 * sizeof(PyObject *))
        self.results = <PyObject **>malloc(128 * sizeof(PyObject *))
        cdef Value value
        for i in range(128):
            value = Value()
            Py_INCREF(value)
            self.results[i] = <PyObject *>value
        self.pilePosition = 0
        self.endOperator = self.new(EXPRESSIONS['End'])
        self.endOperator.initialize(None)
    
    cdef inline void reset(self, ExpressionList loader):
        self.stackPosition = 0
        self.items = loader.items
        self.pilePosition = 0
    
    @cython.wraparound(False)
    @cython.boundscheck(False)
    cdef object evaluate(self):
        cdef Expression next
        
        cdef int pileEnd = self.pilePosition
        self.operators[self.pilePosition] = <PyObject *>self.endOperator
        
        while True:
            self.pilePosition += 1
            self.isFirst = True
            self.get_next().execute(<Value>self.results[self.pilePosition])
            self.isFirst = False
            self.stackPosition += 1
            while True:
                next = self.get_next()
                if next.isOperator and not next.precedence == 0:
                    if next.precedence > (<Expression>self.operators[self.pilePosition-1]).precedence:
                        self.operators[self.pilePosition] = <PyObject *>next
                        self.pilePosition += 1
                        self.stackPosition += 1
                        self.isFirst = True
                        self.get_next().execute(
                            <Value>self.results[self.pilePosition])
                        self.isFirst = False
                        self.stackPosition += 1
                    else:
                        self.pilePosition -= 1
                        (<Expression>self.operators[self.pilePosition]).execute(
                            <Value>self.results[self.pilePosition])
                else:
                    self.pilePosition -= 1
                    if self.pilePosition == pileEnd:
                        break
                    (<Expression>self.operators[self.pilePosition]).execute(
                        <Value>self.results[self.pilePosition])
                    
            if not (self.pilePosition > pileEnd + 1):
                break

        return (<Value>self.results[pileEnd + 1]).get()
    
    cdef inline object evaluate_next(self):
        return (<Value>self.results[self.pilePosition + 1]).get()
    
    cdef inline void go_forward(self):
        self.stackPosition += 1
        
    cdef inline Expression get_next(self):
        return <Expression>self.items[self.stackPosition]
    
    cpdef on_detach(self):
        cdef int i
        for i in range(128):
            Py_DECREF(<object>self.results[i])
        free(self.operators)
        free(self.results)