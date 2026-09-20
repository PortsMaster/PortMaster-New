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
import hashlib
from mmfparser.data.chunkloaders.imagebank import ImageItem

class AGMIBank(DataLoader):
    palette = None
    graphicMode = 4
    def initialize(self):
        self.items = []
        self.itemDict = {}

    def read(self, reader):
        print 'TEX READ'
        self.graphicMode = reader.readInt()
        self.paletteVersion = reader.readShort(True)
        self.paletteEntries = reader.readShort(True)
        self.palette = [reader.readColor()
            for _ in xrange(256)]
        count = reader.readInt()
        print "Number of image-items:"
        print count
        for _ in xrange(count):
            item = self.new(ImageItem, reader, debug=True)
            self.items.append(item)
            self.itemDict[item.handle] = item

    def write(self, reader):
        print 'TEX WRITE'
        reader.writeInt(self.graphicMode)
        reader.writeShort(self.paletteVersion, True)
        reader.writeShort(self.paletteEntries, True)
        for item in self.palette:
            reader.writeColor(item)
        reader.writeInt(len(self.items))
        print "Number of items count offset:"
        print len(self.items)
        for item in self.items:
           # print "Writing tex to MFA"
            item.write(reader)
           # print len(reader)


