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

cdef class Values:
    cdef public:
        int stringCount
        int valueCount
        dict values
        dict strings
    
    cdef initialize(self)
    cpdef str get_string(self, index)
    cpdef bint set_string(self, index, value)
    cpdef object get_value(self, index)
    cpdef bint set_value(self, index, value)
    cpdef Values copy(self)

cdef class Alterables(Values):
    cdef public:
        list flags

cdef class Globals(Values):
    pass