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

from mmfparser.data.chunkloaders.expressions.names import *
from mmfparser.data.chunkloaders.common cimport _AceCommon
from mmfparser.bytereader cimport ByteReader
from mmfparser.loader cimport DataLoader

cdef class Expression(_AceCommon):
    cpdef initialize(self):
        self.systemDict = systemDict
        self.extensionDict = extensionDict

    cpdef read(self, ByteReader reader):
        cdef int currentPosition = reader.tell()
        self.objectType = reader.readShort()
        self.num = reader.readShort()
        if self.objectType == 0 and self.num == 0:
            return
        cdef int size = reader.readShort(True)
        if self.objectType in systemLoaders and self.num in systemLoaders[self.objectType]:
            self.loader = self.new(
                systemLoaders[self.objectType][self.num], reader)
        elif self.objectType >= 2 or self.objectType == -7:
            self.objectInfo = reader.readShort(True)
            self.objectInfoList = reader.readShort()
            if self.num in extensionLoaders:
                self.loader = self.new(extensionLoaders[self.num], reader)
        reader.seek(currentPosition + size)
    
    def write(self, reader):
        reader.writeShort(self.objectType)
        reader.writeShort(self.num)
        if self.objectType == 0 and self.num == 0:
            return
        dataReader = ByteReader()
        if self.objectType in systemLoaders and self.num in systemLoaders[self.objectType]:
            self.loader.write(dataReader)
        elif self.objectType >= 2 or self.objectType == -7:
            dataReader.writeShort(self.objectInfo, True)
            dataReader.writeShort(self.objectInfoList)
            if self.num in extensionLoaders:
                self.loader.write(dataReader)
        reader.writeShort(len(dataReader) + 6, True)
        reader.writeReader(dataReader)
    
    def getExtensionNum(self):
        return self.num - 80