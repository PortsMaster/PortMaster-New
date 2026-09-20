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
from mmfparser import byteflag

class RandomSeed(DataLoader):
    value = None
    def read(self, reader):
        self.value = reader.readShort()

class VitalizePreview(DataLoader):
    def read(self, reader):
        """
        <Yves> it's just a zipped image file
        <Mathias> I see :)
        <Yves> format depends on the file type (png, jpeg, etc)
        """

class OtherExtensions(DataLoader):
    """
    Movement and transition extensions
    """
    def read(self, reader):
        """
        <Yves> filename + zipped DLL for each extension or something like that
        """

class AppIcon(DataLoader):
    width = 16
    height = 16
    points = None

    def read(self, reader):
        """
        zipped BITMAPINFO
        (followed by a monochrome mask)
        """
        self.saveReader = reader
        # just skip the BITMAPINFOHEADER-- we really don't care
        reader.skipBytes(reader.readInt() - 4)

        colorIndexes = []
        for _ in xrange(16 * 16):
            b = reader.readByte(True)
            g = reader.readByte(True)
            r = reader.readByte(True)
            reader.skipBytes(1)
            colorIndexes.append((r, g, b))

        self.points = []
        for y in xrange(16):
            xList = []
            for x in xrange(16):
                xList.append(colorIndexes[reader.readByte(True)])
            self.points = xList + self.points

        self.alpha = []
        for _ in xrange(16 * 16 / 8):
            newAlphas = byteflag.getFlags(reader.readByte(True), *xrange(8))
            for item in reversed(newAlphas):
                if item:
                    # is transparent
                    self.alpha.append(0)
                else:
                    # is opaque
                    self.alpha.append(255)

    def createDisplay(self):
        from mmfparser.player.common import join_image
        from mmfparser.player.sprite import ImageData
        newImage = ImageData(16, 16, 'RGBA', join_image(self.points,
            self.alpha), -16 * 4)
        return newImage

    def write(self, reader):
        reader.writeReader(self.saveReader)

class DemoVersion(DataLoader):
    """
    <Yves> if a CCN contains this chunk,
    then it has been saved with the demo version of MMF2
    """
    def read(self, reader):
        pass # apparently empty according to Yves

class BinaryItem(DataLoader):
    name = None
    data = None
    def read(self, reader):
        self.name = self.readString(reader, reader.readShort(True))
        self.data = reader.readReader(reader.readInt(True))

    def write(self, reader):
        reader.writeShort(len(self.name))
        reader.write(self.name)
        reader.writeInt(len(self.data))
        reader.writeReader(self.data)

class BinaryFiles(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        self.items = [self.new(BinaryItem, reader)
            for _ in xrange(reader.readInt(True))]

    def write(self, reader):
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)

__all__ = ['RandomSeed', 'VitalizePreview', 'OtherExtensions', 'AppIcon',
    'DemoVersion', 'BinaryFiles']