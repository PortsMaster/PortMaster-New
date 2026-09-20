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

import sys

from mmfparser.bytereader import ByteReader

from mmfparser.data.chunkloaders import (
    parameters, expressions, conditions, actions)

if sys.platform in ('cygwin', 'win32'):
    from mmfparser.extension import LoadedExtension

from mmfparser.loader import DataLoader

class Extension(DataLoader):
    name = None
    extension = None
    handle = None
    subType = None
    magicNumber = None
    versionLS = None
    versionMS = None
    loaded = None

    def read(self, reader):
        currentPosition = reader.tell()
        size = reader.readShort()
        if size < 0:
            size = -size
        self.handle = reader.readShort()
        self.magicNumber = reader.readInt()
        self.versionLS = reader.readInt()
        self.versionMS = reader.readInt()
        self.name, self.extension = self.readString(reader).split('.')
        self.subType = reader.readString()
        reader.seek(currentPosition + size)

    def write(self, reader):
        newReader = ByteReader()
        newReader.writeShort(self.handle)
        newReader.writeInt(self.magicNumber)
        newReader.writeInt(self.versionLS)
        newReader.writeInt(self.versionMS)
        newReader.writeString('.'.join([self.name, self.extension]))
        newReader.writeString(self.subType)

        reader.writeShort(len(newReader) + 2, True)
        reader.writeReader(newReader)

    def load(self, library = None):
        if self.loaded:
            return self.loaded
        self.loaded = LoadedExtension(library)
        return self.loaded

class ExtensionList(DataLoader):
    items = None
    preloadExtensions = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        # reader.openEditor()
        numberOfExtensions = reader.readShort(True)
        self.preloadExtensions = reader.readShort(True)
        self.items = [self.new(Extension, reader)
            for _ in xrange(numberOfExtensions)]

    def write(self, reader):
        reader.writeShort(len(self.items))
        reader.writeShort(self.preloadExtensions)
        for item in self.items:
            item.write(reader)

    def fromHandle(self, handle):
        handle, = [item for item in self.items if item.handle == handle]
        return handle

class MovementExtension(DataLoader):
    build = None
    name = None

    def read(self, reader):
        currentPosition = reader.tell()
        size = reader.readShort()
        headerSize = reader.readShort()
        assert headerSize - 8 == 0
        name = reader.readString()
        reader.seek(currentPosition + size)

class MovementExtensions(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        self.items = [self.new(MovementExtension, reader)
            for _ in xrange(reader.readShort(True))]

__all__ = ['ExtensionList', 'MovementExtensions']