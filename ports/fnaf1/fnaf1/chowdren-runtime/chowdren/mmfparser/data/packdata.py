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
from mmfparser.bytereader import ByteReader, checkDefault
from mmfparser.data.gamedata import (GAME_HEADER, UNICODE_GAME_HEADER)

import zlib

import struct

PACK_HEADER = '\x77\x77\x77\x77\x49\x87\x47\x12'

class PackFile(DataLoader):
    data = None
    filename = None
    bingo = None
    compressed = False

    def read(self, reader):
        self.filename = self.readString(reader, reader.readShort())
        if self.settings['hasBingo']:
            self.bingo = reader.readInt()
        data = reader.read(reader.readInt())
        try:
            data = zlib.decompress(data)
            self.compressed = True
        except zlib.error:
            pass
        self.data = data

    def write(self, reader):
        reader.writeShort(len(self.filename))
        reader.write(self.filename)
        if self.bingo is not None:
            reader.writeInt(self.bingo) # what to write here?
        data = self.data
        if self.compressed:
            data = zlib.compress(data)
        reader.writeInt(len(data), True)
        reader.write(data)

def checkSize(reader, size):
    return len(reader) - reader.tell() >= size

class PackData(DataLoader):
    formatVersion = None
    runtimeCompressed = None
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        start = reader.tell()
        header = reader.read(8) # read file header
        if header != PACK_HEADER:
            raise NotImplementedError('pack data header invalid')
        headerSize = reader.readInt()
        # total header size, including PACK_HEADER
        checkDefault(reader, headerSize, 32)
        dataSize = reader.readInt() # total pack data size + 32

        reader.seek(start + dataSize - 32)
        if reader.read(4) == UNICODE_GAME_HEADER:
            self.settings['unicode'] = True
        reader.seek(start + 16)

        self.formatVersion = reader.readInt() # actually hash?
        checkDefault(reader, reader.readInt(), 0)
        checkDefault(reader, reader.readInt(), 0)
        count = reader.readInt()
        offset = reader.tell()
        for _ in xrange(count):
            if not checkSize(reader, 2):
                break
            value = reader.readShort(True)
            if not checkSize(reader, value):
                break
            reader.skipBytes(value)
            if not checkSize(reader, 4):
                break
            value = reader.readInt(True)
            if not checkSize(reader, value):
                break
            reader.skipBytes(value)

        header = reader.read(4)
        hasBingo = header not in (GAME_HEADER, UNICODE_GAME_HEADER)
        reader.seek(offset)

        self.items = [self.new(PackFile, reader, hasBingo = hasBingo)
            for _ in xrange(count)]

    def write(self, reader):
        newReader = ByteReader()
        for item in self.items:
            item.write(newReader)

        reader.write(PACK_HEADER)
        reader.writeInt(32)
        reader.writeInt(len(newReader) + 64)
        reader.writeInt(self.formatVersion)
        reader.writeInt(0)
        reader.writeInt(0)
        reader.writeInt(len(self.items))
        reader.writeReader(newReader)