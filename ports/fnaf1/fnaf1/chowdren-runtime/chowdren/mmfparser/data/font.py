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

class LogFont(DataLoader):
    height = None
    width = None
    escapement = None
    orientation = None
    weight = None
    italic = None
    underline = None
    strikeOut = None
    charSet = None
    outPrecision = None
    clipPrecision = None
    quality = None
    pitchAndFamily = None
    faceName = None
    def read(self, reader):
        if self.settings.get('old', False):
            readMethod = reader.readShort
        else:
            readMethod = reader.readInt
        self.height = readMethod()
        self.width = readMethod()
        self.escapement = readMethod()
        self.orientation = readMethod()
        self.weight = readMethod()
        self.italic = reader.readByte()
        self.underline = reader.readByte()
        self.strikeOut = reader.readByte()
        self.charSet = reader.readByte()
        self.outPrecision = reader.readByte()
        self.clipPrecision = reader.readByte()
        self.quality = reader.readByte()
        self.pitchAndFamily = reader.readByte()
        self.faceName = self.readString(reader, 32)

    def isBold(self):
        return self.weight == 700

    def getSize(self):
        return -int(round(self.height / (96.0 / 72)))

    def write(self, reader):
        if self.settings.get('old', False):
            writeMethod = reader.writeShort
        else:
            writeMethod = reader.writeInt
        writeMethod(self.height)
        writeMethod(self.width)
        writeMethod(self.escapement)
        writeMethod(self.orientation)
        writeMethod(self.weight)
        reader.writeByte(self.italic)
        reader.writeByte(self.underline)
        reader.writeByte(self.strikeOut)
        reader.writeByte(self.charSet)
        reader.writeByte(self.outPrecision)
        reader.writeByte(self.clipPrecision)
        reader.writeByte(self.quality)
        reader.writeByte(self.pitchAndFamily)
        reader.writeString(self.faceName, 32)