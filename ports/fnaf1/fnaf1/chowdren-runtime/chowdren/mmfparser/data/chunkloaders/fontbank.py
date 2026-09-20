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

from mmfparser.data import zlibdata
from mmfparser.data.font import LogFont
from mmfparser.bytereader import ByteReader
from mmfparser.loader import DataLoader

class FontItem(DataLoader):
    handle = None
    checksum = None
    references = None
    value = None
    def read(self, reader):
        java = self.settings.get('java', False)
        debug = self.settings.get('debug', False)
        compressed = not debug and self.settings.get('compressed', True)
        
        self.handle = reader.readInt(True)
        if not java and compressed:
            newReader = zlibdata.decompress(reader)
        else:
            newReader = reader
        currentPosition = newReader.tell()
        self.checksum = newReader.readInt()
        self.references = newReader.readInt()
        size = newReader.readInt()
        self.value = self.new(LogFont, newReader)
        
    def write(self, reader):
        java = self.settings.get('java', False)
        debug = self.settings.get('debug', False)
        compressed = not debug and self.settings.get('compressed', True)

        reader.writeInt(self.handle, True)

        compressedReader = ByteReader()
        compressedReader.writeInt(self.checksum)
        compressedReader.writeInt(self.references)
        compressedReader.writeInt(0) # size
        self.value.write(compressedReader)
        
        if not java and compressed:
            reader.writeReader(zlibdata.compress(compressedReader))
        else:
            reader.writeReader(compressedReader)
    
class OldFont(FontItem):
    handle = None
    checksum = None
    references = None
    value = None
    def read(self, reader):
        self.handle = reader.readInt(True)
        from mmfparser.data.onepointfive import decompress
        new_data = decompress(reader)
        self.checksum = new_data.readShort(True)
        self.references = new_data.readInt()
        new_data.skipBytes(4 * 2) # dunno
        self.value = self.new(LogFont, new_data)
        self.value.settings['old'] = False

class FontBank(DataLoader):
    items = None
    offsets = None
    def read(self, reader):
        debug = self.settings.get('debug', False)
        old = self.settings.get('old', False)
        if debug:
            path = self.readString(reader)
            reader = ByteReader(open(path, 'rb'))
            reader.skipBytes(4)

        numberOfItems = reader.readInt()
        
        if old:
            klass = OldFont
        else:
            klass = FontItem
        
        offset = 0
        if self.settings['build'] >= 284 and not debug:
            offset = -1

        self.items = []
        for _ in xrange(numberOfItems):
            item = self.new(klass, reader)
            item.handle += offset
            self.items.append(item)
                
    def write(self, reader):
        items = self.items or ()
        self.offsets = offsets = []
        reader.writeInt(len(items))
        for item in items:
            offsets.append(reader.tell() + 4)
            item.write(reader)
    
    def fromHandle(self, handle):
        item, = [item for item in self.items if item.handle == handle]
        return item

__all__ = ['FontBank']