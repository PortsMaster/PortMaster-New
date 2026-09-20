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

from mmfparser.data.chunkloaders.common import Empty
from mmfparser.loader cimport DataLoader
from mmfparser.bytereader cimport ByteReader

class End(Empty):
    pass

cdef class String(DataLoader):
    cdef public:
        bytes value

    cpdef read(self, ByteReader reader):
        self.value = self.readString(reader)

    def write(self, reader):
        reader.writeString(self.value)

cdef class Long(DataLoader):
    cdef public:
        int value

    cpdef read(self, ByteReader reader):
        self.value = reader.readInt()

    def write(self, reader):
        reader.writeInt(self.value)

cdef class Double(DataLoader):
    cdef public:
        double value
        float floatValue

    cpdef read(self, ByteReader reader):
        self.value = reader.readDouble()
        self.floatValue = reader.readFloat()

    def write(self, reader):
        reader.writeDouble(self.value)
        reader.writeFloat(self.floatValue)

cdef class GlobalCommon(DataLoader):
    cdef public:
        short value

    cpdef read(self, ByteReader reader):
        # Oi et OIlist qui servent a rien
        # I does not translate. Sorry. Failure. :(
        reader.skipBytes(4)
        self.value = reader.readShort()

    def write(self, reader):
        reader.write('\x00' * 4)
        reader.writeShort(self.value)

class GlobalString(GlobalCommon):
    pass

class GlobalValue(GlobalCommon):
    pass

cdef class ExtensionCommon(DataLoader):
    cdef public:
        short value

    cpdef read(self, ByteReader reader):
        self.value = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.value)

class ExtensionString(ExtensionCommon):
    pass

class ExtensionValue(ExtensionCommon):
    pass

__all__ = ['String', 'Long', 'Double', 'GlobalValue', 'GlobalString',
    'ExtensionString', 'ExtensionValue', 'End']