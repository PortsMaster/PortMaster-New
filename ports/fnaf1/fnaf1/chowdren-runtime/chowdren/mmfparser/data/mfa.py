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

from mmfparser.bytereader import ByteReader, checkDefault
from mmfparser.bitdict import BitDict
from mmfparser.data.mfaloaders.playercontrols import Controls
from mmfparser.data.mfaloaders.imagebank import AGMIBank
from mmfparser.data.chunkloaders.appmenu import AppMenu
from mmfparser.data.chunkloaders.fontbank import FontBank
from mmfparser.data.chunkloaders.soundbank import SoundBank
from mmfparser.data.chunkloaders.musicbank import MusicBank
from mmfparser.data.chunkloaders.objectinfo import (PLAYER, KEYBOARD, CREATE,
    TIMER, GAME, SPEAKER, SYSTEM, QUICKBACKDROP, BACKDROP, ACTIVE, TEXT,
    QUESTION, SCORE, LIVES, COUNTER, RTF, SUBAPPLICATION, objectTypes,
    EXTENSION_BASE)
from mmfparser.data.chunkloaders.objects import (LINE_SHAPE, SOLID_FILL,
    GRADIENT_FILL, MOTIF_FILL, SUBAPPLICATION_FLAGS, OBJECT_FLAGS,
    NEW_OBJECT_FLAGS)
from mmfparser.data.chunkloaders.events import EventGroup
from mmfparser.data.chunkloaders.movement import (MOVEMENT_CLASSES,
    MOVEMENT_TYPES)

from mmfparser.bitdict import BitDict
from mmfparser import byteflag
from mmfparser.loader import DataLoader

def make_id(value):
    return value[::-1]

FONT_BANK = make_id('FNTA')
IMAGE_BANK = make_id('IMGA')
MUSIC_BANK = make_id('MUSA')
SOUND_BANK = make_id('SMPA')

MFA_MAGIC = 'MMF2'

EXTENSION_MAGIC = 1493706006

BUILD_TYPES = [
    'Stand-alone Application',
    'Screen Saver',
    'Internet Application',
    'Java Application',
    'Stand-alone Java Application',
    'Stand-alone Java Internet Applet',
    'Stand-alone Java Web Start',
    'Stand-alone Java for Mobile Devices',
    'Stand-alone Java for Blackberry',
    'Stand-alone Mac Application (Java)',
    'SWF file for Adobe Flash player'
]

GRAPHIC_MODES = {
    4 : '16 million colors',
    7 : '65536 colors',
    6 : '32768 colors',
    3 : '256 colors'
}

INT_TYPE = 0
DOUBLE_TYPE = 1
STRING_TYPE = 2

class ValueItem(DataLoader):
    name = None
    value = None

    def read(self, reader):
        self.name = reader.read(reader.readInt())
        type = reader.readInt()
        if type == STRING_TYPE: # string
            self.value = reader.read(reader.readInt())
        elif type == INT_TYPE: # integer
            self.value = reader.readInt()
        elif type == DOUBLE_TYPE:
            self.value = reader.readDouble()

    def write(self, reader):
        name = self.name
        value = self.value
        reader.writeInt(len(name))
        reader.write(name)
        if isinstance(self.value, str):
            reader.writeInt(STRING_TYPE)
            reader.writeInt(len(value))
            reader.write(value)
        elif isinstance(self.value, int):
            reader.writeInt(INT_TYPE)
            reader.writeInt(value)
        elif isinstance(self.value, float):
            reader.writeInt(DOUBLE_TYPE)
            reader.writeInt(value)
        else:
            raise Exception('invalid value type')

class ValueList(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        count = reader.readInt()
        self.items = [self.new(ValueItem, reader)
            for _ in xrange(count)]

    def write(self, reader):
        reader.writeInt(len(self.items))
        for item in self.items:
            item.write(reader)

# chunks

class StringChunk(DataLoader):
    def read(self, reader):
        self.value = reader.read(reader.readInt(True))

class FlagChunk(DataLoader):
    def read(self, reader):
        self.flags = reader.readInt(True)

class IntChunk(DataLoader):
    def read(self, reader):
        self.value = reader.readInt()

# frame item chunks

class CounterFormat(DataLoader):
    def read(self, reader):
        self.value = reader.readShort(True)

# application chunks

class BuildFlags(FlagChunk):
    pass

class Filters(DataLoader):
    def read(self, reader):
        self.filters = filters = []
        while reader.tell() != len(reader):
            count = reader.readInt(True)
            items = [reader.read(reader.readInt()) for _ in xrange(count)]
            filters.append(items)

class Serial(DataLoader):
    def read(self, reader):
        self.serial = reader.read(12)

class VitalizeOptions(DataLoader):
    def read(self, reader):
        self.flags = reader.readInt()
        self.allowedUrls = reader.read(reader.readInt())

class ExecutionLevel(FlagChunk):
    pass

class JarURL(StringChunk):
    pass

class Opacity(IntChunk):
    pass

class MochiAds(DataLoader):
    def read(self, reader):
        self.flags = reader.readInt(True)
        self.gameId = reader.read(reader.readInt(True))

class ScreenOptions(DataLoader):
    def read(self, reader):
        self.tolerance = reader.readShort(True)
        self.angle = reader.readShort(True)

class PreloaderOptions(DataLoader):
    def read(self, reader):
        self.preloaderType = reader.readInt(True) # image = 0, app = 0
        self.preloaderFile = reader.read(reader.readInt(True))
        self.x = reader.readInt()
        self.y = reader.readInt()
        self.radius = reader.readInt()
        self.thickness = reader.readInt()
        self.circleColor = reader.readColor()
        self.backgroundColor = reader.readColor()

class MP3Options(DataLoader):
    def read(self, reader):
        self.frequency = reader.readInt(True)
        self.bitrate = reader.readInt(True)

class FlashFonts(StringChunk):
    pass

# frame chunks

from mmfparser.data.chunkloaders.common import Rectangle

class FrameVirtualRect(Rectangle):
    pass

class RandomSeed(IntChunk):
    pass

class FrameOptions1(DataLoader):
    def read(self, reader):
        self.opacity = reader.readInt(True)
        self.releaseTimeout = reader.readInt(True)

class MovementTimerBase(IntChunk):
    pass

class FrameOptions2(IntChunk):
    pass

CHUNK_LOADERS = {
    23 : CounterFormat,
    33 : FrameVirtualRect,
    35 : RandomSeed,
    38 : FrameOptions1,
    39 : MovementTimerBase,
    42 : FrameOptions2,
    48 : BuildFlags,
    52 : Filters,
    56 : Serial,
    60 : VitalizeOptions,
    64 : ExecutionLevel,
    68 : JarURL,
    72 : Opacity,
    100 : MochiAds,
    108 : ScreenOptions,
    116 : MP3Options,
    118 : PreloaderOptions,
    122 : FlashFonts
}

class ChunkList(DataLoader):
    items = None
    saved = None

    def read(self, reader):
        start = reader.tell()
        self.items = items = []
        while 1:
            id = reader.readByte(True)
            if id == 0:
                break
            data = reader.readReader(reader.readInt(True))
            if id not in CHUNK_LOADERS:
                print 'Chunk with id', id, 'could not be loaded in', self.parent
                continue
            items.append(self.new(CHUNK_LOADERS[id], data))
        size = reader.tell() - start
        reader.seek(start)
        self.saved = reader.read(size)

    def write(self, reader):
        if self.saved is not None:
            reader.write(self.saved)
        else:
            reader.writeByte(0)

LAYER_FLAGS = BitDict(
    'Visible',
    'Locked',
    'Obsolete',
    'HideAtStart',
    'NoBackground',
    'WrapHorizontally',
    'WrapVertically',
    'PreviousEffect'
)

class Layer(DataLoader):
    name = None
    xCoefficient = None
    yCoefficient = None
    flags = None

    def initialize(self):
        self.flags = LAYER_FLAGS.copy()

    def read(self, reader):
        self.name = reader.read(reader.readInt())
        self.flags.setFlags(reader.readInt())
        self.xCoefficient = reader.readFloat()
        self.yCoefficient = reader.readFloat()

    def write(self, reader):
        reader.writeInt(len(self.name)); reader.write(self.name)
        reader.writeInt(self.flags.getFlags())
        reader.writeFloat(self.xCoefficient)
        reader.writeFloat(self.yCoefficient)

class Transition(DataLoader):
    module = None
    name = None
    id = None
    transitionId = None
    duration = None # in ms
    flags = None
    color = None
    parameterData = None

    def initialize(self):
        self.flags = BitDict('Color')

    def read(self, reader):
        self.module = reader.read(reader.readInt())
        self.name = reader.read(reader.readInt())
        self.id = reader.read(4)
        self.transitionId = reader.read(4)
        self.duration = reader.readInt()
        self.flags.setFlags(reader.readInt())
        self.color = reader.readColor()
        self.parameterData = reader.read(reader.readInt())

    def write(self, reader):
        reader.writeInt(len(self.module)); reader.write(self.module)
        reader.writeInt(len(self.name)); reader.write(self.name)
        reader.write(self.id)
        reader.write(self.transitionId)
        reader.writeInt(self.duration)
        reader.writeInt(self.flags.getFlags())
        reader.writeColor(self.color)
        reader.writeInt(len(self.parameterData)); reader.write(
            self.parameterData)

MAX_QUALIFIERS = 8

class Movement(DataLoader):
    def read(self, reader):
        self.name = reader.read(reader.readInt(True))
        # extension stuff
        self.extension = reader.read(reader.readInt(True))
        self.identifier = reader.readInt(True)
        dataSize = reader.readInt(True)
        if self.extension:
            newReader = reader.readReader(dataSize)
            self.loader = self.new(MOVEMENT_CLASSES[14], newReader,
                dataSize = dataSize)
        else:
            self.player = reader.readShort()
            self.type = reader.readShort()
            self.movingAtStart = reader.readByte()
            reader.skipBytes(3) # free
            self.directionAtStart = reader.readInt()
            newReader = reader.readReader(dataSize - 12)
            self.loader = self.new(MOVEMENT_CLASSES[self.type], newReader,
                dataSize = dataSize - 12)

    def write(self, reader):
        reader.writeIntString(self.name)
        reader.writeIntString(self.extension)
        reader.writeInt(self.identifier)
        newReader = ByteReader()
        if not self.extension:
            newReader.writeShort(self.player)
            newReader.writeShort(self.type)
            newReader.writeByte(self.movingAtStart)
            newReader.write('\x00' * 3)
            newReader.writeInt(self.directionAtStart)
        self.loader.write(newReader)
        reader.writeIntString(str(newReader))

class Movements(DataLoader):
    def initialize(self):
        self.items = []

    def read(self, reader):
        count = reader.readInt(True)
        self.items = [self.new(Movement, reader) for _ in xrange(count)]

    def write(self, reader):
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)

class Behaviour(DataLoader):
    def read(self, reader):
        self.name = reader.read(reader.readInt(True))
        self.data = reader.readReader(reader.readInt(True))

    def write(self, reader):
        reader.writeIntString(self.name)
        reader.writeIntString(str(self.data))

class Behaviours(DataLoader):
    def initialize(self):
        self.items = []

    def read(self, reader):
        count = reader.readInt(True)
        self.items = [self.new(Behaviour, reader) for _ in xrange(count)]

    def write(self, reader):
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)

class ObjectLoader(DataLoader):
    fadeIn = fadeOut = None
    def initialize(self):
        self.objectFlags = OBJECT_FLAGS.copy()
        self.newObjectFlags = NEW_OBJECT_FLAGS.copy()

    def read(self, reader):
        self.objectFlags.setFlags(reader.readInt(True))
        self.newObjectFlags.setFlags(reader.readInt(True))
        self.backgroundColor = reader.readColor()
        self.qualifiers = qualifiers = []
        end = reader.tell() + 2 * (MAX_QUALIFIERS + 1)
        for _ in xrange(MAX_QUALIFIERS + 1):
            value = reader.readShort()
            if value == -1:
                break
            qualifiers.append(value)
        reader.seek(end)
        self.values = ValueList(reader)
        self.strings = ValueList(reader)
        self.movements = Movements(reader)
        self.behaviours = Behaviours(reader)

        if reader.readByte() != 0:
            self.fadeIn = self.new(Transition, reader)
        if reader.readByte() != 0:
            self.fadeOut = self.new(Transition, reader)

    def write(self, reader):
        reader.writeInt(self.objectFlags.getFlags(), True)
        reader.writeInt(self.newObjectFlags.getFlags(), True)
        reader.writeColor(self.backgroundColor)

        for i in xrange(MAX_QUALIFIERS + 1):
            try:
                value = self.qualifiers[i]
                reader.writeShort(value)
            except IndexError:
                reader.writeShort(-1)

        self.values.write(reader)
        self.strings.write(reader)
        self.movements.write(reader)
        self.behaviours.write(reader)

        for item in (self.fadeIn, self.fadeOut):
            if item is None:
                reader.writeByte(0)
            else:
                reader.writeByte(1)
                item.write(reader)

class AnimationDirection(DataLoader):
    def read(self, reader):
        self.index = reader.readInt(True)
        self.minSpeed = reader.readInt(True)
        self.maxSpeed = reader.readInt(True)
        self.repeat = reader.readInt(True)
        self.backTo = reader.readInt(True)
        self.frames = [reader.readInt(True)
            for _ in xrange(reader.readInt(True))]

    def write(self, reader):
        reader.writeInt(self.index, True)
        reader.writeInt(self.minSpeed, True)
        reader.writeInt(self.maxSpeed, True)
        reader.writeInt(self.repeat, True)
        reader.writeInt(self.backTo, True)
        reader.writeInt(len(self.frames), True)
        for item in self.frames:
            reader.writeInt(item)

class Animation(DataLoader):
    name = None
    def read(self, reader):
        self.name = reader.read(reader.readInt(True))
        directionCount = reader.readInt(True)
        self.directions = [self.new(AnimationDirection, reader)
            for _ in xrange(directionCount)]

    def write(self, reader):
        reader.writeIntString(self.name or '')
        reader.writeInt(len(self.directions))
        for item in self.directions:
            item.write(reader)

class AnimationObject(ObjectLoader):
    items = None
    def read(self, reader):
        ObjectLoader.read(self, reader)
        if reader.readByte() != 0:
            animationCount = reader.readInt(True)
            self.items = [self.new(Animation, reader)
                for _ in xrange(animationCount)]

    def write(self, reader):
        ObjectLoader.write(self, reader)
        if self.items is None:
            reader.writeByte(0)
        else:
            reader.writeByte(1)
            reader.writeInt(len(self.items))
            for item in self.items:
                item.write(reader)

class BackgroundLoader(DataLoader):
    def read(self, reader):
        self.obstacleType = reader.readInt(True)
        self.collisionType = reader.readInt(True)

    def write(self, reader):
        reader.writeInt(self.obstacleType, True)
        reader.writeInt(self.collisionType, True)

class ExtensionObject(AnimationObject):
    def read(self, reader):
        AnimationObject.read(self, reader)
        self.extensionType = reader.readInt()
        if self.extensionType == -1:
            self.extensionName = reader.read(reader.readInt(True))
            self.filename = reader.read(reader.readInt(True))
            self.magic = reader.readInt(True)
            self.subType = reader.read(reader.readInt(True))
        newReader = reader.readReader(reader.readInt(True))
        dataSize = newReader.readInt() - 20
        newReader.skipBytes(4) # maxSize
        self.extensionVersion = newReader.readInt()
        self.extensionId = newReader.readInt()
        self.extensionPrivate = newReader.readInt()
        self.extensionData = newReader.read(dataSize)

    def write(self, reader):
        AnimationObject.write(self, reader)
        reader.writeInt(self.extensionType)
        if self.extensionType == -1:
            reader.writeIntString(self.extensionName)
            reader.writeIntString(self.filename)
            reader.writeInt(self.magic, True)
            reader.writeIntString(self.subType)
        reader.writeInt(len(self.extensionData) + 20)
        reader.writeInt(len(self.extensionData) + 20)
        reader.writeInt(0)
        reader.writeInt(self.extensionVersion)
        reader.writeInt(self.extensionId)
        reader.writeInt(self.extensionPrivate)
        reader.write(self.extensionData)

class Active(AnimationObject):
    def read(self, reader):
        AnimationObject.read(self, reader)

    def write(self, reader):
        AnimationObject.write(self, reader)

class Backdrop(BackgroundLoader):
    def read(self, reader):
        BackgroundLoader.read(self, reader)
        self.handle = reader.readInt()

    def write(self, reader):
        BackgroundLoader.write(self, reader)
        reader.writeInt(self.handle)

SHAPE_FLAGS = BitDict(
    'Woo'
)

class QuickBackdrop(BackgroundLoader):
    def initialize(self):
        self.flags = SHAPE_FLAGS.copy()

    def read(self, reader):
        BackgroundLoader.read(self, reader)
        self.width = reader.readInt(True)
        self.height = reader.readInt(True)
        self.shape = reader.readInt(True)
        self.borderSize = reader.readInt(True)
        self.borderColor = reader.readColor()

        self.fillType = reader.readInt(True)
        self.color1 = reader.readColor()
        self.color2 = reader.readColor()
        self.flags.setFlags(reader.readInt(True))
        self.image = reader.readInt()

    def write(self, reader):
        BackgroundLoader.write(self, reader)
        reader.writeInt(self.width, True)
        reader.writeInt(self.height, True)
        reader.writeInt(self.shape, True)
        reader.writeInt(self.borderSize, True)
        reader.writeColor(self.borderColor)
        reader.writeInt(self.fillType, True)
        reader.writeColor(self.color1)
        reader.writeColor(self.color2)
        reader.writeInt(self.flags.getFlags(), True)
        reader.writeInt(self.image)

class Paragraph(DataLoader):
    def read(self, reader):
        self.value = reader.read(reader.readInt(True))
        self.flags = reader.readInt(True) # is answer?

    def write(self, reader):
        reader.writeIntString(self.value)
        reader.writeInt(self.flags, True)

class Text(ObjectLoader):
    def read(self, reader):
        ObjectLoader.read(self, reader)
        self.width = reader.readInt(True)
        self.height = reader.readInt(True)
        self.font = reader.readInt(True)
        self.color = reader.readColor()
        self.flags = reader.readInt(True)
        checkDefault(reader, reader.readInt(True), 0)
        self.items = [self.new(Paragraph, reader)
            for _ in xrange(reader.readInt(True))]

    def write(self, reader):
        ObjectLoader.write(self, reader)
        reader.writeInt(self.width, True)
        reader.writeInt(self.height, True)
        reader.writeInt(self.font, True)
        reader.writeColor(self.color)
        reader.writeInt(self.flags, True)
        reader.writeInt(0)
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)

class QuestionObject(ObjectLoader):
    def read(self, reader):
        ObjectLoader.read(self, reader)
        self.width = reader.readInt(True)
        self.height = reader.readInt(True)
        self.questionFont = reader.readInt(True)
        self.questionColor = reader.readColor()
        checkDefault(reader, reader.readInt(True), 37)
        self.questionFlags = reader.readInt(True) # add relief?
        checkDefault(reader, reader.readInt(True), 1) # question count?
        self.question = reader.read(reader.readInt(True))
        checkDefault(reader, reader.readInt(True), 0)
        self.answerFont = reader.readInt(True)
        self.answerColor = reader.readColor()
        checkDefault(reader, reader.readInt(True), 37)
        self.answerFlags = reader.readInt(True) # add relief?
        self.items = [self.new(Paragraph, reader)
            for _ in xrange(reader.readInt(True))]

    def write(self, reader):
        ObjectLoader.write(self, reader)
        reader.writeInt(self.width, True)
        reader.writeInt(self.height, True)
        reader.writeInt(self.questionFont, True)
        reader.writeColor(self.questionColor)
        reader.writeInt(37, True)
        reader.writeInt(self.questionFlags, True)
        reader.writeInt(1, True)
        reader.writeInt(len(self.question), True)
        reader.write(self.question)
        reader.writeInt(0, True)
        reader.writeInt(self.answerFont, True)
        reader.writeColor(self.answerColor)
        reader.writeInt(37, True)
        reader.writeInt(self.answerFlags)
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)

class Counter(ObjectLoader):
    def read(self, reader):
        ObjectLoader.read(self, reader)
        self.value = reader.readInt()
        self.minimum = reader.readInt()
        self.maximum = reader.readInt()
        self.displayType = reader.readInt(True)
        self.flags = reader.readInt(True)
        self.color1 = reader.readColor()
        self.color2 = reader.readColor()
        self.verticalGradient = reader.readInt(True)
        self.countType = reader.readInt(True)
        self.width = reader.readInt()
        self.height = reader.readInt()
        self.images = [reader.readInt(True)
            for _ in xrange(reader.readInt(True))]
        self.font = reader.readInt(True)

    def write(self, reader):
        ObjectLoader.write(self, reader)
        reader.writeInt(self.value)
        reader.writeInt(self.minimum)
        reader.writeInt(self.maximum)
        reader.writeInt(self.displayType, True)
        reader.writeInt(self.flags, True)
        reader.writeColor(self.color1)
        reader.writeColor(self.color2)
        reader.writeInt(self.verticalGradient, True)
        reader.writeInt(self.countType)
        reader.writeInt(self.width)
        reader.writeInt(self.height)
        reader.writeInt(len(self.images))
        for item in self.images:
            reader.writeInt(item, True)
        reader.writeInt(self.font, True)

class Score(ObjectLoader):
    def read(self, reader):
        ObjectLoader.read(self, reader)
        self.player = reader.readInt(True)
        self.images = [reader.readInt(True)
            for _ in xrange(reader.readInt(True))]
        self.displayType = reader.readInt(True)
        self.flags = reader.readInt(True)
        self.font = reader.readInt(True)
        self.width = reader.readInt()
        self.height = reader.readInt()

    def write(self, reader):
        ObjectLoader.write(self, reader)
        reader.writeInt(self.player, True)
        reader.writeInt(len(self.images))
        for item in self.images:
            reader.writeInt(item, True)
        reader.writeInt(self.displayType, True)
        reader.writeInt(self.flags, True)
        reader.writeInt(self.font, True)
        reader.writeInt(self.width)
        reader.writeInt(self.height)

class Lives(ObjectLoader):
    def read(self, reader):
        ObjectLoader.read(self, reader)
        self.player = reader.readInt(True)
        self.images = [reader.readInt(True)
            for _ in xrange(reader.readInt(True))]
        self.displayType = reader.readInt(True)
        self.flags = reader.readInt(True)
        self.font = reader.readInt(True)
        self.width = reader.readInt()
        self.height = reader.readInt()

    def write(self, reader):
        ObjectLoader.write(self, reader)
        reader.writeInt(self.player, True)
        reader.writeInt(len(self.images))
        for item in self.images:
            reader.writeInt(item, True)
        reader.writeInt(self.displayType, True)
        reader.writeInt(self.flags, True)
        reader.writeInt(self.font, True)
        reader.writeInt(self.width)
        reader.writeInt(self.height)

class RTFObject(ObjectLoader):
    def read(self, reader):
        ObjectLoader.read(self, reader)
        self.width = reader.readInt()
        self.height = reader.readInt()
        self.flags = reader.readInt(True)
        self.color = reader.readColor()
        self.value = reader.read(reader.readInt(True))

class SubApplication(ObjectLoader):
    def initialize(self):
        ObjectLoader.initialize(self)
        self.options = SUBAPPLICATION_FLAGS.copy()

    def read(self, reader):
        ObjectLoader.read(self, reader)
        self.filename = reader.read(reader.readInt(True))
        self.width = reader.readInt()
        self.height = reader.readInt()
        self.options.setFlags(reader.readInt(True))
        self.startFrame = reader.readInt()
        if self.startFrame != -1:
            if reader.readInt() != -1:
                print 'subapp NO'

    def write(self, reader):
        ObjectLoader.write(self, reader)
        reader.writeIntString(self.filename)
        reader.writeInt(self.width)
        reader.writeInt(self.height)
        reader.writeInt(self.options.getFlags(), True)
        reader.writeInt(self.startFrame)
        if self.startFrame != -1:
            reader.writeInt(-1)

FRAME_ITEM_LOADERS = {
    ACTIVE : Active,
    BACKDROP : Backdrop,
    QUICKBACKDROP : QuickBackdrop,
    TEXT : Text,
    QUESTION : QuestionObject,
    COUNTER : Counter,
    SCORE : Score,
    LIVES : Lives,
    RTF : RTFObject,
    SUBAPPLICATION : SubApplication
}

ITEM_FLAGS = BitDict(
    'LoadOnCall',
    None,
    'Global'
)

class FrameItem(DataLoader):
    def initialize(self):
        self.flags = ITEM_FLAGS.copy()

    def read(self, reader):
        self.objectType = reader.readInt()
        self.handle = reader.readInt()
        self.name = reader.read(reader.readInt())
        self.transparent = bool(reader.readInt())
        self.inkEffect = reader.readInt()
        self.inkEffectParameter = reader.readInt()
        self.antiAliasing = bool(reader.readInt())
        self.flags.setFlags(reader.readInt())
        iconType = reader.readInt()
        if iconType == 1:
            self.iconHandle = reader.readInt(True)
        else:
            raise NotImplementedError('invalid icon')
        self.chunks = self.new(ChunkList, reader)
        if self.objectType >= EXTENSION_BASE:
            objectClass = ExtensionObject
        else:
            objectClass = FRAME_ITEM_LOADERS[self.objectType]
        self.loader = self.new(objectClass, reader)

    def write(self, reader):
        reader.writeInt(self.objectType)
        reader.writeInt(self.handle)
        reader.writeInt(len(self.name)); reader.write(self.name)
        reader.writeInt(int(self.transparent))
        reader.writeInt(self.inkEffect)
        reader.writeInt(self.inkEffectParameter, True)
        reader.writeInt(int(self.antiAliasing))
        reader.writeInt(self.flags.getFlags())
        reader.writeInt(1)
        reader.writeInt(self.iconHandle)
        self.chunks.write(reader)
        self.loader.write(reader)

class ItemFolder(DataLoader):
    name = None
    def read(self, reader):
        value = reader.readInt(True)
        if value == 0x70000004: # folder
            self.name = reader.read(reader.readInt(True))
            self.items = [reader.readInt(True)
                for _ in xrange(reader.readInt(True))]
        else:
            self.name = None
            self.items = [reader.readInt(True)]

    def write(self, reader):
        if self.name is None:
            reader.writeInt(0x70000005)
        else:
            reader.writeInt(0x70000004, True)
            reader.writeIntString(self.name)
            reader.writeInt(len(self.items))
        for item in self.items:
            reader.writeInt(item, True)

class FrameInstance(DataLoader):
    def read(self, reader):
        self.x = reader.readInt()
        self.y = reader.readInt()
        self.layer = reader.readInt(True)
        self.handle = reader.readInt()
        self.flags = reader.readInt(True)
        self.parentType = reader.readInt(True)
        self.itemHandle = reader.readInt(True)
        self.parentHandle = reader.readInt(True)

    def write(self, reader):
        reader.writeInt(self.x)
        reader.writeInt(self.y)
        reader.writeInt(self.layer, True)
        reader.writeInt(self.handle)
        reader.writeInt(self.flags, True)
        reader.writeInt(self.parentType, True)
        reader.writeInt(self.itemHandle, True)
        reader.writeInt(self.parentHandle, True)

class Comment(DataLoader):
    def read(self, reader):
        self.handle = reader.readInt(True)
        self.value = reader.read(reader.readInt(True))

    def write(self, reader):
        reader.writeInt(self.handle, True)
        reader.writeIntString(self.value)

FRAME_ITEM_TYPE = 1
SHORTCUT_ITEM_TYPE = 2
SYSTEM_ITEM_TYPE = 3
ICON_BUFFER_CODE = 'OIC2'

class EventObject(DataLoader):
    def read(self, reader):
        self.handle = reader.readInt(True)
        self.objectType = reader.readShort(True)
        self.itemType = reader.readShort(True)
        self.name = reader.read(reader.readInt(True))
        self.typeName = reader.read(reader.readInt(True))
        self.flags = reader.readShort(True)
        if self.objectType == FRAME_ITEM_TYPE:
            self.itemHandle = reader.readInt(True)
            self.instanceHandle = reader.readInt(True)
        elif self.objectType == SHORTCUT_ITEM_TYPE:
            self.code = reader.read(4)
            if self.code == ICON_BUFFER_CODE:
                self.iconBuffer = reader.read(reader.readInt(True))
        if self.objectType == SYSTEM_ITEM_TYPE:
            self.systemQualifier = reader.readShort(True)

    def write(self, reader):
        reader.writeInt(self.handle, True)
        reader.writeShort(self.objectType, True)
        reader.writeShort(self.itemType, True)
        reader.writeIntString(self.name)
        reader.writeIntString(self.typeName)
        reader.writeShort(self.flags)
        if self.objectType == FRAME_ITEM_TYPE:
            reader.writeInt(self.itemHandle, True)
            reader.writeInt(self.instanceHandle, True)
        elif self.objectType == SHORTCUT_ITEM_TYPE:
            reader.write(self.code)
            if self.code == ICON_BUFFER_CODE:
                reader.writeIntString(self.iconBuffer)
        if self.objectType == SYSTEM_ITEM_TYPE:
            reader.writeShort(self.systemQualifier, True)

EVENT_DATA = 'Evts'
COMMENT_DATA = 'Rems'
OBJECT_DATA = 'EvOb'
EVENT_EDITOR_DATA = 'EvCs'
OBJECT_LIST_DATA = 'EvEd'
TIME_LIST_DATA = 'EvEd'
EDITOR_POSITION_DATA = 'EvTs'
EDITOR_LINE_DATA = 'EvLs'
EVENT_END = make_id('END!')

class Events(DataLoader):
    items = None
    comments = None
    objects = None
    objectTypes = None
    x = None
    lineY = None
    def read(self, reader):
        self.version = reader.readShort(True)
        self.frameType = reader.readShort(True)
        self.items = []
        while 1:
            name = reader.read(4)
            if name == EVENT_DATA:
                size = reader.readInt(True)
                endPosition = reader.tell() + size
                while 1:
                    self.items.append(self.new(EventGroup, reader))
                    if reader.tell() >= endPosition:
                        break
            elif name == COMMENT_DATA:
                try:
                    self.comments = [self.new(Comment, reader)
                        for _ in xrange(reader.readInt(True))]
                except OverflowError:
                    import code
                    code.interact(local = locals())
            elif name == OBJECT_DATA:
                self.objects = [self.new(EventObject, reader)
                    for _ in xrange(reader.readInt(True))]
            elif name == EVENT_EDITOR_DATA:
                reader.skipBytes(4)
                self.conditionWidth = reader.readShort(True)
                self.objectHeight = reader.readShort(True)
                reader.skipBytes(4 * 3)
            elif name == OBJECT_LIST_DATA:
                count = realCount = reader.readShort()
                if count == -1:
                    realCount = reader.readShort()
                self.objectTypes = [reader.readShort(True)
                    for _ in xrange(realCount)]
                self.objectHandles = [reader.readShort(True)
                    for _ in xrange(realCount)]
                self.objectFlags = [reader.readShort(True)
                    for _ in xrange(realCount)]
                if count == -1:
                    self.folders = [reader.read(reader.readInt(True))
                        for _ in xrange(reader.readShort(True))]
                else:
                    self.folders = []
            elif name == TIME_LIST_DATA:
                raise NotImplementedError("I don't like no timelist")
            elif name == EDITOR_POSITION_DATA:
                if reader.readShort(True) != 1:
                    raise NotImplementedError("Invalid chunkversion")
                self.x = reader.readInt(True)
                self.y = reader.readInt(True)
                self.caretType = reader.readInt(True)
                self.caretX = reader.readInt(True)
                self.caretY = reader.readInt(True)
            elif name == EDITOR_LINE_DATA:
                if reader.readShort(True) != 1:
                    raise NotImplementedError("Invalid chunkversion")
                self.lineY = reader.readInt(True)
                self.lineItemType = reader.readInt(True)
                self.eventLine = reader.readInt(True)
                self.eventLineY = reader.readInt(True)
            elif name == EVENT_END:
                break
            else:
                raise NotImplementedError('%s is an unknown event identifier' %
                    name)

    def write(self, reader):
        reader.writeShort(self.version, True)
        reader.writeShort(self.frameType)
        if self.items:
            reader.write(EVENT_DATA)
            newReader = ByteReader()
            for item in self.items:
                item.write(newReader)
            reader.writeIntString(str(newReader))
        if self.comments is not None:
            reader.write(COMMENT_DATA)
            reader.writeInt(len(self.comments), True)
            for comment in self.comments:
                comment.write(reader)
        if self.objects is not None:
            reader.write(OBJECT_DATA)
            reader.writeInt(len(self.objects), True)
            for item in self.objects:
                item.write(reader)
        reader.write(EVENT_EDITOR_DATA)
        reader.write('\x00' * (4 + 2 * 2 + 4 * 3))
        if self.objectTypes is not None:
            reader.write(OBJECT_LIST_DATA)
            reader.writeShort(-1)
            reader.writeShort(len(self.objectTypes))
            for item in (self.objectTypes, self.objectHandles, self.objectFlags):
                for subitem in item:
                    reader.writeShort(subitem, True)
            reader.writeShort(len(self.folders), True)
            for item in self.folders:
                reader.writeIntString(item)
        if self.x is not None:
            reader.write(EDITOR_POSITION_DATA)
            reader.writeShort(1)
            reader.writeInt(self.x)
            reader.writeInt(self.y)
            reader.writeInt(self.caretType, True)
            reader.writeInt(self.caretX, True)
            reader.writeInt(self.caretY, True)
        if self.lineY is not None:
            reader.write(EDITOR_LINE_DATA)
            reader.writeShort(1)
            reader.writeInt(self.lineY, True)
            reader.writeInt(self.lineItemType, True)
            reader.writeInt(self.eventLine, True)
            reader.writeInt(self.eventLineY, True)
        reader.write(EVENT_END)

class Frame(DataLoader):
    handle = None
    name = None
    size = None
    background = None
    maxObjects = None
    password = None
    palette = None
    fadeIn = None
    fadeOut = None
    def initialize(self):
        self.palette = []
        self.flags = BitDict(
            'GrabDesktop',
            'KeepDisplay',
            'BackgroundCollisions',
            'DisplayFrameTitle',
            'ResizeToScreen',
            'ForceLoadOnCall',
            'NoDisplaySurface',
            'ScreenSaverSetup',
            'TimerBasedMovements',
            'MochiAds',
            'NoGlobalEvents'
        )

    def read(self, reader):
        self.handle = reader.readInt()
        self.name = reader.read(reader.readInt())
        self.size = (reader.readInt(), reader.readInt())
        self.background = reader.readColor()
        self.flags.setFlags(reader.readInt(True))

        self.maxObjects = reader.readInt()
        self.password = reader.read(reader.readInt())
        checkDefault(reader, reader.readInt(), 0)

        self.lastViewedX = reader.readInt()
        self.lastViewedY = reader.readInt()

        self.palette = [reader.readColor()
            for _ in xrange(reader.readInt())]

        self.stampHandle = reader.readInt()

        self.activeLayer = reader.readInt()

        self.layers = [self.new(Layer, reader)
            for _ in xrange(reader.readInt())]

        if reader.readByte() != 0:
            self.fadeIn = self.new(Transition, reader)

        if reader.readByte() != 0:
            self.fadeOut = self.new(Transition, reader)

        self.items = items = [self.new(FrameItem, reader)
            for _ in xrange(reader.readInt())]

        self.folders = [self.new(ItemFolder, reader)
            for _ in xrange(reader.readInt(True))]

        self.instances = [self.new(FrameInstance, reader)
            for _ in xrange(reader.readInt())]
        self.events = self.new(Events, reader)
        self.chunks = self.new(ChunkList, reader)

    def write(self, reader):
        reader.writeInt(self.handle)
        reader.writeInt(len(self.name)); reader.write(self.name)
        reader.writeInt(self.size[0]); reader.writeInt(self.size[1])
        reader.writeColor(self.background)
        reader.writeInt(self.flags.getFlags(), True)
        reader.writeInt(self.maxObjects)
        reader.writeInt(len(self.password)); reader.write(self.password)
        reader.writeInt(0)
        reader.writeInt(self.lastViewedX)
        reader.writeInt(self.lastViewedY)
        reader.writeInt(len(self.palette))
        for item in self.palette:
            reader.writeColor(item)
        reader.writeInt(self.stampHandle)
        reader.writeInt(self.activeLayer)
        reader.writeInt(len(self.layers))
        for item in self.layers:
            item.write(reader)
        for item in (self.fadeIn, self.fadeOut):
            if item is not None:
                reader.writeByte(1)
                item.write(reader)
            else:
                reader.writeByte(0)
        for item in (self.items, self.folders, self.instances):
            reader.writeInt(len(item), True)
            for subitem in item:
                subitem.write(reader)

        self.events.write(reader)
        self.chunks.write(reader)

PRODUCTS = {
    1 : 'TGF',
    2 : 'MMF2 Standard',
    3 : 'MMF2 Developer',
    4 : 'DeluxeGoldEdition'
}

MFA_CURRENT_VERSION = 5

DISPLAY_SETTINGS = BitDict(
    'MaximizedOnBoot',
    'ResizeDisplay',
    'FullscreenAtStart',
    'AllowFullscreen',
    'Heading',
    'HeadingWhenMaximized',
    'MenuBar',
    'MenuOnBoot',
    'NoMinimize',
    'NoMaximize',
    'NoThickFrame',
    'NoCenter',
    'DisableClose',
    'HiddenAtStart',
    'MDI'
)

GRAPHIC_SETTINGS = BitDict(
    'MultiSamples',
    'SpeedIndependent',
    'SoundsOverFrames',
    'PlaySamplesWhenUnfocused',
    'IgnoreInputOnScreensaver',
    'DirectX',
    'VRAM',
    'EnableVisualThemes',
    'VSync',
    'RunWhenMinimized',
    'RunWhenResizing',
    'EnableDebuggerShortcuts',
    'NoDebugger',
    'NoSubappSharing'
)

class MFA(DataLoader):
    mfaVersion = None
    product = None
    buildVersion = None

    languageId = None
    name = None
    description = None
    path = None

    fonts = None
    sounds = None
    musics = None
    images = None
    icons = None

    author = None
    copyright = None
    company = None
    version = None

    windowSize = None
    borderColor = None
    displaySettings = None
    graphicSettings = None

    helpFile = None
    vitalizePreview = None
    initialScore = None
    initialLifes = None
    frameRate = None
    buildType = None
    buildPath = None
    commandLine = None
    aboutBox = None
    binaryFiles = None
    controls = None
    menu = None
    windowMenuIndex = None
    menuImages = None
    globalValues = None
    globalStrings = None
    globalEvents = None
    iconImages = None
    customQualifiers = None
    extensions = None
    frames = None

    def initialize(self):
        self.binaryFiles = []
        self.extensions = []
        self.frames = []
        self.iconTypes = []
        self.displaySettings = DISPLAY_SETTINGS.copy()
        self.graphicSettings = GRAPHIC_SETTINGS.copy()

    def read(self, reader):
        if reader.read(4) != MFA_MAGIC:
            raise Exception('mfa header is invalid')
        self.mfaBuild = reader.readInt()
        self.product = reader.readInt()
        self.buildVersion = reader.readInt()
        self.settings['build'] = self.buildVersion
        if self.mfaBuild >= MFA_CURRENT_VERSION:
            self.languageId = reader.readInt()
        self.name = reader.read(reader.readInt())
        self.description = reader.read(reader.readInt())
        self.path = reader.read(reader.readInt())
        # stamp? stampSize
        self.stamp = reader.read(reader.readInt())

        if reader.read(4) != FONT_BANK:
            raise Exception('invalid font bank name')
        self.fonts = self.new(FontBank, reader, compressed = False)
        if reader.read(4) != SOUND_BANK:
            raise Exception('invalid sound bank name')
        self.sounds = self.new(SoundBank, reader, compressed = False)
        if reader.read(4) != MUSIC_BANK:
            raise Exception('invalid music bank name')
        self.music = self.new(MusicBank, reader, compressed = False)
        if reader.read(4) != IMAGE_BANK:
            raise Exception('invalid icon bank name')
        self.icons = self.new(AGMIBank, reader)
        if reader.read(4) != IMAGE_BANK:
            raise Exception('invalid image bank name')
        self.images = self.new(AGMIBank, reader)

        checkDefault(reader, reader.read(reader.readInt()), self.name)
        self.author = reader.read(reader.readInt())
        checkDefault(reader, reader.read(reader.readInt()), self.description)
        self.copyright = reader.read(reader.readInt())
        self.company = reader.read(reader.readInt())
        self.version = reader.read(reader.readInt())

        self.windowSize = (reader.readInt(), reader.readInt())
        self.borderColor = reader.readColor()

        self.displaySettings.setFlags(reader.readInt(True))
        self.graphicSettings.setFlags(reader.readInt(True))

        self.helpFile = reader.read(reader.readInt())
        self.vitalizePreview = reader.read(reader.readInt())
        self.initialScore = reader.readInt(True)
        self.initialLifes = reader.readInt(True)
        self.frameRate = reader.readInt()
        self.buildType = reader.readInt()
        self.buildPath = reader.read(reader.readInt())
        checkDefault(reader, reader.readInt(), 0)
        self.commandLine = reader.read(reader.readInt())
        self.aboutBox = reader.read(reader.readInt())
        checkDefault(reader, reader.readInt(), 0)

        self.binaryFiles = [reader.read(reader.readInt())
            for _ in xrange(reader.readInt())]

        self.controls = self.new(Controls, reader)

        menuSize = reader.readInt(True)
        currentPosition = reader.tell()
        self.menu = self.new(AppMenu, reader)
        reader.seek(currentPosition + menuSize)

        self.windowMenuIndex = reader.readInt()

        self.menuImages = menuImages = {}
        for i in xrange(reader.readInt()):
            id = reader.readInt()
            menuImages[id] = reader.readInt()

        self.globalValues = ValueList(reader)
        self.globalStrings = ValueList(reader)

        self.globalEvents = reader.read(reader.readInt())

        self.graphicMode = reader.readInt()

        self.iconImages = [reader.readInt()
            for _ in xrange(reader.readInt())]

        self.customQualifiers = qualifiers = []
        for _ in xrange(reader.readInt()):
            name = reader.read(reader.readInt())
            handle = reader.readInt()
            qualifiers.append((name, handle))

        for _ in xrange(reader.readInt()):
            handle = reader.readInt()
            filename = reader.read(reader.readInt())
            name = reader.read(reader.readInt())
            # KPX_MAGICNUMBER
            magic = reader.readInt()
            subType = reader.read(reader.readInt())
            self.extensions.append((handle, filename, name, magic, subType))

        frameOffsets = [reader.readInt()
            for _ in xrange(reader.readInt())]
        nextOffset = reader.readInt()

        for offset in frameOffsets:
            reader.seek(offset)
            self.frames.append(self.new(Frame, reader))

        reader.seek(nextOffset)

        self.chunks = self.new(ChunkList, reader)

    def getBuildType(self):
        return BUILD_TYPES[self.buildType]

    def setBuildType(self, name):
        self.buildType = BUILD_TYPES.index(name)

    def getGraphicMode(self):
        return GRAPHIC_MODES[self.graphicMode]

    def setGraphicMode(self, name):
        self.graphicMode = [(v, k) for k, v in GRAPHIC_MODES.iteritems()][name]

    def write(self, reader):
        reader.write(MFA_MAGIC)
        reader.writeInt(self.mfaBuild)
        reader.writeInt(self.product)
        reader.writeInt(self.buildVersion)
        if self.languageId is not None:
            reader.writeInt(self.languageId)
        reader.writeInt(len(self.name))
        reader.write(self.name)
        reader.writeInt(len(self.description))
        reader.write(self.description)
        reader.writeInt(len(self.path))
        reader.write(self.path)
        reader.writeInt(len(self.stamp), True)
        reader.write(self.stamp)
        reader.write(FONT_BANK)
        self.fonts.write(reader)
        reader.write(SOUND_BANK)
        self.sounds.write(reader)
        reader.write(MUSIC_BANK)
        self.music.write(reader)
        for item in (self.icons, self.images):
            reader.write(IMAGE_BANK)
            item.write(reader)
        reader.writeInt(len(self.name))
        reader.write(self.name)
        reader.writeInt(len(self.author))
        reader.write(self.author)
        reader.writeInt(len(self.description))
        reader.write(self.description)
        reader.writeInt(len(self.copyright))
        reader.write(self.copyright)
        reader.writeInt(len(self.company))
        reader.write(self.company)
        reader.writeInt(len(self.version))
        reader.write(self.version)
        reader.writeInt(self.windowSize[0])
        reader.writeInt(self.windowSize[1])
        reader.writeColor(self.borderColor)
        reader.writeInt(self.displaySettings.getFlags())
        reader.writeInt(self.graphicSettings.getFlags())
        reader.writeInt(len(self.helpFile)); reader.write(self.helpFile)
        reader.writeInt(len(self.vitalizePreview))
        reader.write(self.vitalizePreview)
        reader.writeInt(self.initialScore, True)
        reader.writeInt(self.initialLifes, True)
        reader.writeInt(self.frameRate)
        reader.writeInt(self.buildType)
        reader.writeInt(len(self.buildPath))
        reader.write(self.buildPath)
        reader.writeInt(0)
        reader.writeInt(len(self.commandLine))
        reader.write(self.commandLine)
        reader.writeInt(len(self.aboutBox))
        reader.write(self.aboutBox)
        reader.writeInt(0)
        reader.writeInt(len(self.binaryFiles))
        for item in self.binaryFiles:
            reader.writeInt(len(item))
            reader.write(item)
        self.controls.write(reader)
        if self.menu:
            menuData = self.menu.generate()
            reader.writeInt(len(menuData))
            reader.writeReader(menuData)
        else:
            reader.writeInt(0)
        reader.writeInt(self.windowMenuIndex)
        reader.writeInt(len(self.menuImages))
        for k, v in self.menuImages.iteritems():
            reader.writeInt(k)
            reader.writeInt(v)
        self.globalValues.write(reader)
        self.globalStrings.write(reader)
        reader.writeInt(len(self.globalEvents))
        reader.write(self.globalEvents)
        reader.writeInt(self.graphicMode)
        reader.writeInt(len(self.iconImages))
        for item in self.iconImages:
            reader.writeInt(item)
        reader.writeInt(len(self.customQualifiers))
        for item in self.customQualifiers:
            name, handle = item
            reader.writeInt(len(name)); reader.write(name)
            reader.writeInt(handle)
        reader.writeInt(len(self.extensions))
        for item in self.extensions:
            handle, filename, name, magic, subType = item
            reader.writeInt(handle)
            reader.writeIntString(filename)
            reader.writeIntString(name)
            reader.writeInt(magic)
            reader.writeIntString(subType)
        reader.writeInt(len(self.frames))
        startPosition = reader.tell() + 4 * len(self.frames) + 4
        newReader = ByteReader()
        for frame in self.frames:
            reader.writeInt(startPosition + newReader.tell(), True)
            frame.write(newReader)
        reader.writeInt(startPosition + newReader.tell(), True)
        reader.writeReader(newReader)
        self.chunks.write(reader)