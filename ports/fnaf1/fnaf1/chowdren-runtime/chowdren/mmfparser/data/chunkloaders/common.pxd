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

from mmfparser.loader cimport DataLoader

cdef class _AceCommon(DataLoader):
    cdef public:
        dict systemDict
        dict extensionDict
        int objectType
        int num
        DataLoader loader
        int objectInfo
        int objectInfoList
    cdef str name
        
    cpdef object getObjects(self, frameItems)
    cpdef bint isQualifier(self)
    cpdef bint getQualifier(self)
    cpdef str getName(self)   
    cpdef int getType(self)
    cpdef str getTypeName(self)
    cpdef bint hasObjectInfo(self)
    cpdef getExtension(self, extensionChunk)