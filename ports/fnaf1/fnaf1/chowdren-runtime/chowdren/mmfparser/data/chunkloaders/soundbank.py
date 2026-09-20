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

import zlib

from mmfparser.loader import DataLoader
from mmfparser.bitdict import BitDict
from mmfparser.bytereader import ByteReader

class BaseSound(DataLoader):
    def getType(self):
        header = self.data[:4]
        if self.data[:4] == 'RIFF':
            return 'WAV'
        elif self.data[:4] == 'AIFF':
            return 'AIFF'
        elif self.data[:4] == 'OggS':
            return 'OGG'
        else:
            # assume MOD
            return 'MOD'

SOUND_FLAGS = BitDict(
    'Wave',
    'MIDI',
    None, None,
    'LoadOnCall',
    'PlayFromDisk',
    'Loaded'
)

class SoundItem(BaseSound):
    handle = None
    checksum = None
    references = None
    flags = None
    name = None
    data = None

    def initialize(self):
        self.flags = SOUND_FLAGS.copy()

    def read(self, reader):
        start = reader.tell()
        self.handle = reader.readInt(True)
        self.checksum = reader.readInt()
        self.references = reader.readInt()
        decompressedLenght = reader.readInt()
        self.flags.setFlags(reader.readInt(True))
        reserved = reader.readInt()
        nameLenght = reader.readInt()
        if (self.settings.get('compressed', True) and
                not self.flags['PlayFromDisk']):
            size = reader.readInt()
            data = ByteReader(zlib.decompress(reader.read(size)))
        else:
            data = reader.readReader(decompressedLenght)
        self.name = self.readString(data, nameLenght)
        self.data = data.read()

    def write(self, reader):
        reader.writeInt(self.handle, True)
        reader.writeInt(self.checksum)
        reader.writeInt(self.references)
        reader.writeInt(len(self.data) + len(self.name) + 1)
        reader.writeInt(self.flags.getFlags())
        reader.writeInt(0)
        reader.writeInt(len(self.name) + 1)
        reader.write(self.name + '\x00')
        reader.write(self.data)

class JavaSound(BaseSound):
    handle = None
    name = None
    data = None
    def read(self, reader):
        self.handle = reader.readShort()
        size = reader.readInt()
        self.data = reader.read(size)

class FlashSound(BaseSound):
    handle = None
    name = None
    data = None
    def read(self, reader):
        self.handle = reader.readShort()
        self.name = reader.readString(reader.readShort())

class OldSound(BaseSound):
    def initialize(self):
        self.flags = SOUND_FLAGS.copy()

    def read(self, reader):
        self.handle = reader.readInt(True)
        from mmfparser.data.onepointfive import decompress
        new_data = decompress(reader)
        self.checksum = new_data.readShort(True)
        self.references = new_data.readInt(True)
        size = new_data.readInt(True)
        self.flags.setFlags(new_data.readInt(True))
        reserved = new_data.readInt() # reserved
        self.name = new_data.read(new_data.readInt(True)).replace('\x00', '')
        self.format = new_data.readShort(True)
        self.channel_count = new_data.readShort(True)
        self.sample_rate = new_data.readInt(True)
        self.byte_rate = new_data.readInt(True)
        self.block_align = new_data.readShort(True)
        self.bits_per_sample = new_data.readShort(True)
        new_data.readShort() # dunno
        self.chunk_size = new_data.readInt(True)
        self.data = new_data.read(self.chunk_size)

    def get_wav(self):
        reader = ByteReader()
        reader.write('RIFF')
        reader.writeInt(len(self.data) - 44)
        reader.write('WAVEfmt ')
        reader.writeInt(16, True)
        reader.writeShort(self.format, True)
        reader.writeShort(self.channel_count, True)
        reader.writeInt(self.sample_rate, True)
        reader.writeInt(self.byte_rate, True)
        reader.writeShort(self.block_align, True)
        reader.writeShort(self.bits_per_sample, True)
        reader.write('data')
        reader.writeInt(self.chunk_size, True)
        reader.write(self.data)
        return reader

    def write(self, reader):
        data = self.get_wav()
        reader.writeInt(self.handle, True)
        reader.writeInt(self.checksum)
        reader.writeInt(self.references)
        reader.writeInt(len(data) + len(self.name) + 1)
        reader.writeInt(self.flags.getFlags())
        reader.writeInt(0)
        reader.writeInt(len(self.name) + 1)
        reader.write(self.name + '\x00')
        reader.writeReader(data)

class SoundBank(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        # reader.openEditor()
        debug = self.settings.get('debug', False)
        java = self.settings.get('java', False)
        flash = self.settings.get('flash', False)
        old = self.settings.get('old', False)

        if debug:
            path = self.readString(reader)
            reader = ByteReader(open(path, 'rb'))
            reader.skipBytes(4)

        if java:
            numberOfItems = reader.readShort()
            itemsToRead = reader.readShort()
            if flash:
                itemClass = FlashSound
            elif old:
                itemClass = OldSound
            else:
                itemClass = JavaSound
        else:
            itemsToRead = reader.readInt()
            if old:
                itemClass = OldSound
            else:
                itemClass = SoundItem

        compressed = not debug

        self.items = [self.new(itemClass, reader, compressed = compressed)
            for _ in xrange(itemsToRead)]

        self.names = dict([(item.name, item) for  item in self.items])

    def fromHandle(self, handle):
        return [item for item in self.items if item.handle == handle][0]

    def write(self, reader):
        reader.writeInt(len(self.items))
        for item in self.items:
            item.write(reader)

__all__ = ['SoundBank']