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

from mmfparser.loader import DataLoader
from mmfparser.bytereader import ByteReader
from mmfparser.bitdict import BitDict
from mmfparser.data import zlibdata

class MusicFile(DataLoader):
    handle = None
    name = None
    checksum = None
    references = None
    flags = None
    data = None
    
    def initialize(self):
        self.flags = BitDict(
            'Wave',
            'MIDI',
            None, None,
            'LoadOnCall',
            'PlayFromDisk',
            'Loaded'
        )
    
    def read(self, reader):
        debug = self.settings.get('debug', False)
        compressed = not debug and self.settings.get('compressed', True)
        self.handle = reader.readInt()
        if compressed:
            reader = zlibdata.decompress(reader)
        self.checksum = reader.readInt()
        self.references = reader.readInt(True)
        size = reader.readInt(True)
        self.flags.setFlags(reader.readInt(True))
        reserved = reader.readInt()
        nameLength = reader.readInt()
        self.name = reader.read(nameLength).replace('\x00', '')
        self.data = reader.read(size - nameLength)

class JavaMusic(DataLoader):
    handle = None
    data = None
    
    def read(self, reader):
        self.handle = reader.readShort()
        self.data = reader.read(reader.readInt())

class MusicBank(DataLoader):
    items = None
    
    def initialize(self):
        self.items = []

    def read(self, reader):
        java = self.settings.get('java', False)
        debug = self.settings.get('debug', False)
        
        if debug:
            path = reader.readString()
            reader = ByteReader(open(path, 'rb'))
            reader.skipBytes(4)
        
        if java:
            totalReferences = reader.readShort()
            numberOfItems = reader.readShort()
            itemClass = JavaMusic
        else:
            numberOfItems = reader.readInt()
            itemClass = MusicFile

        self.items = [self.new(itemClass, reader)
            for _ in xrange(numberOfItems)]
            
    def write(self, newReader):
        newReader.writeShort(len(self.items))
        newReader.writeShort(len(self.items))
        for item in self.items:
            newReader.writeReader(item.generate())

    def fromHandle(self, handle):
        return [item for item in self.items if item.handle == handle][0]

__all__ = ['MusicBank']