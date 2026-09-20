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

STRING_COUNT = 10
VALUE_COUNT = 26

cdef fill_dict(loader, dict fillDict):
    if loader:
        for index, item in enumerate(loader.items):
            fillDict[index] = item

cdef class Values:
    def __init__(self, values = None, strings = None):
        self.initialize()
        self.values = {}
        fill_dict(values, self.values)
        self.strings = {}
        fill_dict(strings, self.strings)
    
    cdef initialize(self):
        pass
            
    cpdef str get_string(self, index):
        try:
            return self.strings[index]
        except KeyError:
            return ''
    
    cpdef bint set_string(self, index, value):
        self.strings[index] = value
        return True
    
    cpdef object get_value(self, index):
        try:
            return self.values[index]
        except KeyError:
            return 0
    
    cpdef bint set_value(self, index, value):
        self.values[index] = value
        return True
    
    cpdef Values copy(self):
        cdef Values values = self.__class__()
        values.values = self.values.copy()
        values.strings = self.strings.copy()
        return values

cdef class Alterables(Values):
    cdef initialize(self):
        self.stringCount = 10
        self.valueCount = 26
        self.flags = [False for _ in xrange(32)]

cdef class Globals(Values):
    cdef initialize(self):
        self.stringCount = 26
        self.valueCount = 26
        
__all__ = ['Alterables', 'Globals']
        