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

from mmfparser.bytereader cimport ByteReader
from mmfparser.bitdict import BitDict
from mmfparser.data.chunkloaders.stringchunk import StringChunk
from mmfparser.loader cimport DataLoader
from mmfparser.data.chunkloaders.common import _ObjectTypeMixin
from mmfparser import byteflag

EXTENSION_BASE = 32

objectTypes = {
    -7 : 'Player',
    -6 : 'Keyboard',
    -5 : 'Create',
    -4 : 'Timer',
    -3 : 'Game',
    -2 : 'Speaker',
    -1 : 'System',
    0 : 'QuickBackdrop',
    1 : 'Backdrop',
    2 : 'Active',
    3 : 'Text',
    4 : 'Question',
    5 : 'Score',
    6 : 'Lives',
    7 : 'Counter',
    8 : 'RTF',
    9 : 'SubApplication'
}

(PLAYER, KEYBOARD, CREATE, TIMER, GAME, SPEAKER,
    SYSTEM, QUICKBACKDROP, BACKDROP, ACTIVE, TEXT,
    QUESTION, SCORE, LIVES, COUNTER, RTF, SUBAPPLICATION) = xrange(-7, 10)

def getObjectType(id):
    if id < EXTENSION_BASE:
        return objectTypes[id]
    else:
        return 'Extension'

class ObjectProperties(DataLoader, _ObjectTypeMixin):
    loader = None
    objectType = None
    isCommon = None
    _loadReader = None

    def read(self, ByteReader reader):
        self._loadReader = reader

    def load(self, objectType):
        self.objectType = objectType
        reader = self._loadReader
        del self._loadReader
        reader.seek(0)

        self.isCommon = False
        if objectType == QUICKBACKDROP:
            self.loader = self.new(QuickBackdrop, reader)
        elif objectType == BACKDROP:
            self.loader = self.new(Backdrop, reader)
        else:
            self.isCommon = True
            self.loader = self.new(ObjectCommon, reader)

    def write(self, ByteReader reader):
        self.loader.write(reader)

class ObjectName(StringChunk):
    pass

NONE_EFFECT = 0
SEMITRANSPARENT_EFFECT = 1
INVERTED_EFFECT = 2
XOR_EFFECT = 3
AND_EFFECT = 4
OR_EFFECT = 5
REPLACE_TRANSPARENT_EFFECT = 6
DWROP_EFFECT = 7
ANDNOT_EFFECT = 8
ADD_EFFECT = 9
MONOCHROME_EFFECT = 10
SUBTRACT_EFFECT = 11
NO_REPLACE_EFFECT = 12
SHADER_EFFECT = 13

HWA_EFFECT = 0x1000 # BOP_RGBAFILTER

INK_EFFECTS = {
    NONE_EFFECT : 'None',
    SEMITRANSPARENT_EFFECT : 'Semitransparent',
    INVERTED_EFFECT : 'Inverted',
    XOR_EFFECT : 'XOR',
    AND_EFFECT : 'AND',
    OR_EFFECT : 'OR',
    ADD_EFFECT : 'Add',
    MONOCHROME_EFFECT : 'Monochrome',
    SUBTRACT_EFFECT : 'Subtract',
    SHADER_EFFECT : 'Shader',
    HWA_EFFECT : 'HWA'
}

OBJECT_FLAGS = BitDict(
    'LoadOnCall',
    'Discardable',
    'Global',
    'Reserved_1'
)

class ObjectEffects(DataLoader):
    items = None
    def read(self, ByteReader reader):
        self.id = reader.readInt(True)
        self.items = [reader.readReader(4)
            for _ in xrange(reader.readInt(True))]

class ObjectHeader(DataLoader, _ObjectTypeMixin):
    handle = None
    objectType = None
    flags = None
    inkEffect = None
    inkEffectParameter = None

    def initialize(self):
        self.flags = OBJECT_FLAGS.copy()

    def read(self, ByteReader reader):
        self.handle = reader.readShort()
        self.objectType = reader.readShort()
        self.flags.setFlags(reader.readShort(True))
        reserved = reader.readShort() # no longer used
        self.inkEffect = reader.readInt(True)
        self.inkEffectParameter = reader.readInt(True)

    def write(self, ByteReader reader):
        reader.writeShort(self.handle)
        reader.writeShort(self.objectType)
        reader.writeShort(self.flags.getFlags(), True)
        reader.writeShort(0)
        reader.writeInt(self.inkEffect, True)
        reader.writeInt(self.inkEffectParameter, True)

class ObjectInfo(DataLoader, _ObjectTypeMixin):
    name = None
    handle = None
    objectType = None
    flags = None
    properties = None

    antialias = None
    transparent = None
    inkEffect = None
    inkEffectValue = None

    shaderId = None
    items = None

    def read(self, ByteReader reader):
        infoChunks = self.new(ChunkList, reader)
        properties = None
        for chunk in infoChunks.items:
            loader = chunk.loader
            klass = loader.__class__
            if klass is ObjectName:
                self.name = loader.value
            elif klass is ObjectHeader:
                self.handle = loader.handle
                self.objectType = loader.objectType
                self.flags = loader.flags
                inkEffect = loader.inkEffect
                self.transparent = byteflag.getFlag(inkEffect, 28)
                self.antialias = byteflag.getFlag(inkEffect, 29)
                self.inkEffect = inkEffect & 0xFFFF
                self.inkEffectValue = loader.inkEffectParameter
            elif klass is ObjectProperties:
                properties = loader
            elif klass is ObjectEffects:
                self.shaderId = loader.id
                self.items = loader.items
            else:
                print chunk.getName(), chunk.id
        properties.load(self.objectType)
        self.properties = properties

    def write(self, ByteReader reader):
        newChunks = self.new(ChunkList)
        newHeader = self.new(ObjectHeader)
        newHeader.handle = self.handle
        newHeader.objectType = self.objectType
        newHeader.flags = self.flags
        flag = 0
        if self.transparent:
            flag = byteflag.setFlag(flag, 28, True)
        if self.antialias:
            flag = byteflag.setFlag(flag, 29, True)
        flag = flag | (self.inkEffect & 0xFFFF)
        newHeader.inkEffect = flag
        newHeader.inkEffectParameter = self.inkEffectValue
        newChunks.append(newHeader)
        if self.name is not None:
            newName = self.new(ObjectName)
            newName.value = self.name
            newChunks.append(newName)
        newChunks.append(self.properties)
        newChunks.append(Last())
        newChunks.write(reader)

from mmfparser.data.chunkloaders.objects import (QuickBackdrop, Backdrop,
    ObjectCommon)

from mmfparser.data.chunkloaders.last import Last
from mmfparser.data.chunk import ChunkList

__all__ = ['ObjectProperties', 'ObjectInfo', 'ObjectHeader', 'ObjectName',
    'ObjectEffects']