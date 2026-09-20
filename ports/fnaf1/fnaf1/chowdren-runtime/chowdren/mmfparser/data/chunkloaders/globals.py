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

import struct

from mmfparser.bytereader import ByteReader

from mmfparser.loader import DataLoader

LONG = 0
INT = 0
STRING = 1
FLOAT = 2
DOUBLE = 2

class GlobalValues(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        items = self.items
        numberOfItems = reader.readShort(True)
        tempList = []
        for i in xrange(numberOfItems):
            tempList.append(reader.readReader(4))
        for glob in tempList:
            globalType = reader.readByte(True)
            if globalType == FLOAT:
                newGlobal = glob.readFloat()
            elif globalType == INT:
                newGlobal = glob.readInt()
            else:
                raise Exception('unknown global type')
            items.append(newGlobal)

    def write(self, reader):
        types = []
        reader.writeShort(len(self.items))
        for item in self.items:
            if isinstance(item, float):
                reader.writeFloat(item)
                types.append(FLOAT)
            elif isinstance(item, int):
                reader.writeInt(item)
                types.append(INT)
            else:
                raise Exception('unknown global type')
        for globalType in types:
            reader.writeByte(globalType)

class GlobalStrings(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        self.items = [self.readString(reader)
            for _ in xrange(reader.readInt(True))]

    def write(self, reader):
        reader.writeInt(len(self.items))
        for item in self.items:
            reader.writeString(item)

__all__ = ['GlobalValues', 'GlobalStrings']