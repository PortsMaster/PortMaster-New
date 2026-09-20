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

from mmfparser.bitdict import BitDict
from mmfparser.data.chunkloaders.stringchunk import StringChunk
from mmfparser.data.chunkloaders.common import Rectangle
from mmfparser.data.chunkloaders.last import Last
from mmfparser.data.chunkloaders.events import Events
from mmfparser.data.chunkloaders.transition import FadeIn, FadeOut
from mmfparser.data import chunk
from mmfparser.loader import DataLoader

class LayerEffects(DataLoader):
    def read(self, reader):
        reader.seek(0, 2)

class FrameEffects(DataLoader):
    def read(self, reader):
        reader.seek(0, 2)

class FrameHandles(DataLoader):
    handles = None

    def initialize(self):
        self.handles = []

    def read(self, reader):
        self.handles = [reader.readShort() for _ in xrange(len(reader) / 2)]

    def write(self, reader):
        for handle in self.handles:
            reader.writeShort(handle)

class FramePalette(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        # XXX figure this out
        reader.skipBytes(4)

        self.items = []
        for _ in xrange(256):
            self.items.append(reader.readColor())

    def write(self, reader):
        reader.write('\x00' * 4)

        for item in self.items:
            reader.writeColor(item)

class MovementTimerBase(DataLoader):
    value = None
    def read(self, reader):
        self.value = reader.readInt()

    def write(self, reader):
        reader.writeInt(self.value)

class Frame(DataLoader):
    name = None

    password = None

    width = None
    height = None
    background = None
    flags = None

    top = None
    bottom = None
    left = None
    right = None

    movementTimer = None

    instances = None
    maxObjects = None

    layers = None

    events = None
    palette = None

    checksum = None

    delayedReader = None

    def read(self, reader):
        if not self.settings.get('loadFrames', False):
            self.delayedReader = reader
        else:
            self.read_now(reader)

    def load(self):
        if self.delayedReader is None:
            return
        self.read_now(self.delayedReader)

    def close(self):
        self.name = None
        self.instances = None
        self.layers = None
        self.events = None
        self.palette = None
        self.fadeIn = None
        self.fadeOut = None

    def read_now(self, reader):
        self.delayedReader = None
        newChunks = self.new(chunk.ChunkList, reader)
        name = newChunks.popChunk(FrameName, True)
        if name:
            self.name = name.value
        password = newChunks.popChunk(FramePassword, True)
        if password:
            self.password = password.value

        newHeader = newChunks.popChunk(FrameHeader)

        self.width = newHeader.width
        self.height = newHeader.height
        self.background = newHeader.background
        self.flags = newHeader.flags

        newVirtual = newChunks.popChunk(VirtualSize)
        self.top = newVirtual.top
        self.bottom = newVirtual.bottom
        self.left = newVirtual.left
        self.right = newVirtual.right

        self.instances = newChunks.popChunk(ObjectInstances, True)

        self.layers = newChunks.popChunk(Layers)

        self.events = newChunks.popChunk(Events)
        self.maxObjects = self.events.maxObjects

        self.palette = newChunks.popChunk(FramePalette, True)

        try:
            self.movementTimer = newChunks.popChunk(MovementTimerBase).value
        except IndexError:
            pass

        self.fadeIn = newChunks.popChunk(FadeIn, True)
        self.fadeOut = newChunks.popChunk(FadeOut, True)

    def write(self, reader):
        newChunks = self.new(chunk.ChunkList)

        newHeader = FrameHeader()
        newHeader.width = self.width
        newHeader.height = self.height
        newHeader.background = self.background
        newHeader.flags = self.flags
        newChunks.append(newHeader)

        newVirtual = VirtualSize()
        newVirtual.top = self.top
        newVirtual.bottom = self.bottom
        newVirtual.left = self.left
        newVirtual.right = self.right
        newChunks.append(newVirtual)

        if self.name is not None:
            newChunks.append(chunk.makeValueChunk(FrameName, self.name))
        if self.password is not None:
            newChunks.append(chunk.makeValueChunk(FramePassword, self.name))

        if self.instances is not None:
            newChunks.append(self.instances)
        newChunks.append(self.layers)
        newChunks.append(self.events)
        if self.palette is not None:
            newChunks.append(self.palette)
        if self.movementTimer is not None:
            newChunks.append(chunk.makeValueChunk(MovementTimerBase,
                self.movementTimer))
        if self.fadeIn is not None:
            newChunks.append(self.fadeIn)
        if self.fadeOut is not None:
            newChunks.append(self.fadeOut)
        newChunks.append(Last())
        newChunks.write(reader)

class Layer(DataLoader):
    name = None
    flags = None
    xCoefficient = None
    yCoefficient = None
    numberOfBackgrounds = None
    backgroundIndex = None

    def initialize(self):
        self.flags = BitDict(
            'XCoefficient',
            'YCoefficient',
            'DoNotSaveBackground',
            None, #Wrap (Obsolete)
            'Visible', # visible
            'WrapHorizontally',
            'WrapVertically',
            None, None, None, None,
            None, None, None, None, None,
            'Redraw',
            'ToHide',
            'ToShow'
        )

    def read(self, reader):
        value = reader.readInt(True)
        self.flags.setFlags(value)
        self.xCoefficient = reader.readFloat()
        self.yCoefficient = reader.readFloat()
        self.numberOfBackgrounds = reader.readInt()
        self.backgroundIndex = reader.readInt()
        self.name = self.readString(reader)

    def write(self, reader):
        reader.writeInt(self.flags.getFlags(), True)
        reader.writeFloat(self.xCoefficient)
        reader.writeFloat(self.yCoefficient)
        reader.writeInt(self.numberOfBackgrounds)
        reader.writeInt(self.backgroundIndex)
        reader.writeString(self.name)

    def getBackgrounds(self, objectInstances):
        return objectInstances.items[
            self.backgroundIndex:self.backgroundIndex+self.numberOfBackgrounds]

    def getInstances(self, objectInstances):
        return self.parent.getObjectInstances(self,
            objectInstances)

class Layers(DataLoader):
    def initialize(self):
        self.items = []

    def getObjectInstances(self, layer, objectInstances):
        layerIndex = self.items.index(layer)
        try:
            return [instance for instance in objectInstances.items
                if instance.layer == layerIndex]
        except AttributeError:
            return []

    def read(self, reader):
        self.items = [self.new(Layer, reader)
            for _ in xrange(reader.readInt(True))]

    def write(self, reader):
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)

PARENT_TYPES = [
    'None',
    'Frame',
    'FrameItem',
    'Qualifier'
]

NONE_PARENT, FRAME_PARENT, FRAMEITEM_PARENT, QUALIFIER_PARENT = xrange(4)

class ObjectInstance(DataLoader):
    handle = None
    objectInfo = None
    x = None
    y = None
    parentType = None
    parentHandle = None
    layer = None

    def read(self, reader):
        self.handle = reader.readShort(True)
        self.objectInfo = reader.readShort(True)
        self.x = reader.readInt()
        self.y = reader.readInt()
        self.parentType = reader.readShort()
        self.parentHandle = reader.readShort() # object info
        self.layer = reader.readShort()
        reader.skipBytes(2)

    def write(self, reader):
        reader.writeShort(self.handle, True)
        reader.writeShort(self.objectInfo, True)
        reader.writeInt(self.x)
        reader.writeInt(self.y)
        reader.writeShort(self.parentType)
        reader.writeShort(self.parentHandle)
        reader.writeShort(self.layer)
        reader.writeShort(0)

    def getObjectInfo(self, frameItems):
        return frameItems.fromHandle(self.objectInfo)

    def getParent(self):
        return frameItems.fromHandle(self.parentHandle)

    def getParentType(self):
        return PARENT_TYPES[self.parentType]

class ObjectInstances(DataLoader):
    def initialize(self):
        self.items = []

    def read(self, reader):
        self.items = [self.new(ObjectInstance, reader)
            for _ in xrange(reader.readInt(True))]
        reader.skipBytes(4) # XXX figure out

    def write(self, reader):
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)
        reader.writeInt(self.parent.settings['parent'
            ].header.checksum, True)

    def fromHandle(self, handle):
        handle, = [item for item in self.items if item.handle == handle]
        return handle

class VirtualSize(Rectangle):
    pass

class FrameHeader(DataLoader):
    width = None
    height = None
    flags = None
    background = None

    def initialize(self):
        # 0x8000 == TimedMovements
        self.flags = BitDict(
            'DisplayName',
            'GrabDesktop',
            'KeepDisplay',
            'FadeIn',
            'FadeOut',
            'TotalCollisionMask',
            'Password',
            'ResizeAtStart',
            'DoNotCenter',
            'ForceLoadOnCall',
            'NoSurface',
            'Reserved_1',
            'Reserved_2',
            'RecordDemo',
            None,
            'TimedMovements'
        )

    def read(self, reader):
        self.width = reader.readInt()
        self.height = reader.readInt()
        self.background = reader.readColor()
        self.flags.setFlags(reader.readInt(True))

    def write(self, reader):
        reader.writeInt(self.width)
        reader.writeInt(self.height)
        reader.writeColor(self.background)
        reader.writeInt(self.flags.getFlags(), True)

class FrameName(StringChunk):
    pass

class FramePassword(StringChunk):
    pass

__all__ = ['FrameHandles', 'FrameName', 'Frame', 'FrameHeader',
    'VirtualSize', 'ObjectInstances', 'Layers', 'FramePalette',
    'MovementTimerBase', 'FramePassword', 'LayerEffects', 'FrameEffects']