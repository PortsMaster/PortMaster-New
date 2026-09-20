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
from mmfparser.data.chunkloaders.common import _ObjectTypeMixin
from mmfparser.data.chunkloaders.objectinfo import (ObjectName, ObjectHeader,
    ObjectEffects, PLAYER, KEYBOARD, CREATE, TIMER, GAME, SPEAKER, 
    SYSTEM, QUICKBACKDROP, BACKDROP, ACTIVE, TEXT, 
    QUESTION, SCORE, LIVES, COUNTER, RTF, SUBAPPLICATION, objectTypes,
    EXTENSION_BASE)
from mmfparser.data.chunkloaders.objects import _Background
from mmfparser.data.chunkloaders.last import Last
from mmfparser.data.chunk import ChunkList
from mmfparser.data.chunkloaders.objects import (OBJECT_FLAGS, 
    OBJECT_PREFERENCES, PARAGRAPH_FLAGS, SUBAPPLICATION_FLAGS,
    DOCK_POSITIONS, HIDDEN, HORIZONTAL_BAR, VERTICAL_BAR, NUMBERS, ANIMATION,
    SHAPE_FLAGS, LINE_SHAPE, SOLID_FILL, GRADIENT_FILL, MOTIF_FILL,
    Counter, AnimationHeader, COLLISION_MODES, OBSTACLE_TYPES,
    NEW_OBJECT_FLAGS)
from mmfparser import byteflag
from mmfparser.data.chunkloaders.movement import (MOVEMENT_CLASSES,
    MOVEMENT_TYPES)
from mmfparser.data.chunkloaders.frame import (FrameName,
    FramePassword, FramePalette)
from mmfparser.data.chunkloaders.common import _AceCommon
from mmfparser.data.chunkloaders.events import (HEADER, EVENT_COUNT,
    EVENTGROUP_DATA, END, GROUP_FLAGS, Qualifier, ACE_FLAGS,
    ACE_OTHERFLAGS, GROUP_FLAGS)
from mmfparser.data.chunkloaders import (actions, expressions, 
    conditions)
from mmfparser.bitdict import BitDict
from mmfparser.data.chunkloaders.transition import FadeIn, FadeOut
from mmfparser.data.chunkloaders.parameters.loaders import (parameterLoaders,
    getName)
from mmfparser.data.chunkloaders.parameters.loaders import ExpressionParameter
from mmfparser.data.chunkloaders.appheader import (AppHeader as RealAppHeader)
from mmfparser.key import Key

controlTypes = [
    'Joystick 1',
    'Joystick 2',
    'Keyboard'
]

class Controls(DataLoader):
    def initialize(self):
        self.items = []

    def read(self, reader):
        self.items = [self.new(PlayerControl, reader)
            for _ in xrange(4)]
        for control in self.items:
            control.loadKeys(reader)
                
    def write(self, reader):
        for control in self.items:
            control.write(reader)
        for control in self.items:
            control.writeKeys(reader)
        
class Keys(DataLoader):
    def initialize(self):
        self.up = Key()
        self.down = Key()
        self.left = Key()
        self.right = Key()
        self.button1 = Key()
        self.button2 = Key()
        
    def read(self, reader):
        self.up.setValue(reader.readShort())
        self.down.setValue(reader.readShort())
        self.left.setValue(reader.readShort())
        self.right.setValue(reader.readShort())
        self.button1.setValue(reader.readShort())
        self.button2.setValue(reader.readShort())

    def write(self, reader):
        reader.writeShort(self.up.getValue())
        reader.writeShort(self.down.getValue())
        reader.writeShort(self.left.getValue())
        reader.writeShort(self.right.getValue())
        reader.writeShort(self.button1.getValue())
        reader.writeShort(self.button2.getValue())

class PlayerControl(DataLoader):
    def initialize(self):
        self.keys = self.new(Keys)
    
    def read(self, reader):
        self.controlType = reader.readShort()

    def getControlType(self):
        return controlTypes[self.controlType-1]
        
    def setControlType(self, controlType):
        self.controlType = controlTypes.index(controlType) + 1
        
    def loadKeys(self, reader):
        self.keys = self.new(Keys, reader)
    
    def writeKeys(self, reader):
        self.keys.write(reader)

class AppHeader(RealAppHeader):
    def read(self, reader):
        self.flags.setFlags(reader.readShort(True))
        self.newFlags.setFlags(reader.readShort(True))
        self.mode = reader.readShort()
        self.otherFlags.setFlags(reader.readShort(True))

        self.windowWidth = reader.readShort(True)
        self.windowHeight = reader.readShort(True)
        self.initialScore = reader.readInt(True) ^ 0xffffffff
        self.initialLives = reader.readInt(True) ^ 0xffffffff
        self.controls = self.new(Controls, reader)
        self.borderColor = reader.readColor()
        self.numberOfFrames = reader.readInt(True)
        if not self.flags['OneFile']:
            # we're debugging, let new chunks know
            self.parent.settings['debug'] = True

class Movement(DataLoader):
    player = None
    type = None
    movingAtStart = None
    directionAtStart = None
    loader = None
    
    def read(self, reader):
        self.player = reader.readShort(True)
        if self.player not in (0, 1, 2, 3):
            print 'player?', self.player
        self.type = reader.readShort(True)
        self.movingAtStart = reader.readByte(True)
        if self.movingAtStart not in (0, 1):
            print 'moving at start?', self.movingAtStart
        reader.skipBytes(3) # mvFree0-2
        self.directionAtStart = reader.readInt()
        self.loader = self.new(MOVEMENT_CLASSES[self.type], reader)
    
    def getName(self):
        return MOVEMENT_TYPES[self.type]
    
    def setName(self, name):
        self.type = MOVEMENT_TYPES.index(name)

class Paragraph(DataLoader):
    def initialize(self):
        self.flags = PARAGRAPH_FLAGS.copy()

    def read(self, reader):
        size = reader.readShort(True)
        self.font = reader.readShort(True)
        self.color = reader.readColor()
        self.flags.setFlags(reader.readShort(True))
        self.value = reader.readString()

class Text(DataLoader):
    def initialize(self):
        self.items = []

    def read(self, reader):
        currentPosition = reader.tell()
        size = reader.readInt()
        self.width = reader.readShort()
        self.height = reader.readShort()
        
        itemOffsets = [reader.readShort()
            for _ in xrange(reader.readShort())]
        
        for offset in itemOffsets:
            reader.seek(currentPosition + offset)
            self.items.append(self.new(Paragraph, reader))

class SubApplication(DataLoader):
    name = ''
    def initialize(self):
        self.options = SUBAPPLICATION_FLAGS.copy()
    
    def read(self, reader):
        size = reader.readInt()
        self.width = reader.readShort()
        self.height = reader.readShort()
        self.version = reader.readShort()
        self.startFrame = reader.readShort()
        self.options.setFlags(reader.readInt(True))
        reader.skipBytes(1)
    
    def getDockedPosition(self):
        docked1 = self.options['Docked1']
        docked2 = self.options['Docked2']
        return DOCK_POSITIONS[(docked1, docked2)]

class Shape(DataLoader):
    color2 = None
    color1 = None
    gradientFlags = None
    def initialize(self):
        self.lineFlags = SHAPE_FLAGS.copy()

    def read(self, reader):
        self.borderSize = reader.readShort()
        self.borderColor = reader.readColor()
        self.shape = reader.readShort()
        self.fillType = reader.readShort()
        
        if self.shape == LINE_SHAPE:
            self.lineFlags.setFlags(reader.readShort(True))
        elif self.fillType == SOLID_FILL:
            self.color1 = reader.readColor()
        elif self.fillType == GRADIENT_FILL:
            self.color1 = reader.readColor()
            self.color2 = reader.readColor()
            self.gradientFlags = reader.readShort()
        elif self.fillType == MOTIF_FILL:
            self.image = reader.readShort()

class Counters(DataLoader):
    shape = None
    font = None
    frames = None
    def read(self, reader):
        size = reader.readInt(True)
        self.width = reader.readShort(True)
        self.height = reader.readShort(True)
        self.player = reader.readShort(True)
        self.displayType = reader.readShort(True)
        self.flags = reader.readShort()
        self.inverse = byteflag.getFlag(self.flags, 8)
        if self.displayType == HIDDEN:
            pass
        elif self.displayType in (NUMBERS, ANIMATION):
            self.frames = [reader.readShort()
                for _ in xrange(reader.readShort(True))]
        elif self.displayType in (VERTICAL_BAR, HORIZONTAL_BAR):
            self.shape = self.new(Shape, reader)
        
    def getFont(self, fonts):
        try:
            return fonts.fromHandle(self.font)
        except (ValueError, AttributeError):
            return INVALID_FONT
    
    def getImage(self, name, images):
        return images.fromHandle(self.frames[COUNTER_FRAMES.index(name)])
    
    def getDisplayType(self):
        return DISPLAY_NAMES[self.displayType]

class Movements(object):
    def __init__(self, items):
        self.items = items

class ObjectCommon(DataLoader):
    movements = None
    strings = None
    values = None
    fadeIn = fadeOut = None
    animations = None
    counters = None
    extensionData = None
    def initialize(self):   
        self.qualifiers = []
        # OCFLAGS2
        self.newFlags = NEW_OBJECT_FLAGS.copy()
        # OEFLAG
        self.flags = OBJECT_FLAGS.copy()
        # OEPREF
        self.preferences = OBJECT_PREFERENCES.copy()
    
    def read(self, reader):
        currentPosition = reader.tell()
        
        size = reader.readShort(True)
        checksum = reader.readShort(True)
        
        movementsOffset = reader.readShort()
        animationsOffset = reader.readShort()
        
        self.version = reader.readShort()
        
        counterOffset = reader.readShort()
        systemObjectOffset = reader.readShort() # ocCtAnim
        
        ocVariable = reader.readInt(True)

        self.flags.setFlags(reader.readShort(True))
        
        end = reader.tell() + 8 * 2
        
        for _ in xrange(8):
            qualifier = reader.readShort()
            if qualifier == -1:
                break
            self.qualifiers.append(qualifier)
        
        reader.seek(end)
        
        extensionOffset = reader.readShort()
        valuesOffset = reader.readShort()
        self.newFlags.setFlags(reader.readShort(True))
        self.preferences.setFlags(reader.readShort(True))
        self.identifier = reader.read(4)
        self.backColour = reader.readColor()
        fadeInOffset = reader.readInt()
        fadeOutOffset = reader.readInt()
        
        if movementsOffset != 0:
            reader.seek(currentPosition + movementsOffset)
            self.movements = Movements([self.new(Movement, reader)])
        else:
            self.movements = Movements([])
        
        if valuesOffset != 0:
            print 'values'
            # reader.seek(currentPosition + valuesOffset)
            # self.values = self.new(AlterableValues, reader)
        
        if animationsOffset != 0:
            reader.seek(currentPosition + animationsOffset)
            self.animations = self.new(AnimationHeader, reader)
            
        if counterOffset != 0:
            reader.seek(currentPosition + counterOffset)
            self.counter = self.new(Counter, reader)

        if extensionOffset != 0:
            reader.seek(currentPosition + extensionOffset)
            dataSize = reader.readShort() - 8
            reader.skipBytes(2) # maxSize
            self.extensionOldFlags = reader.readShort()
            self.extensionVersion = reader.readShort()
            self.extensionId = 0
            self.extensionPrivate = 0
            if dataSize != 0:
                self.extensionData = reader.read(dataSize)
        
        if fadeInOffset != 0:
            print 'fadein'
            # reader.seek(currentPosition + fadeInOffset)
            # self.fadeIn = self.new(FadeIn, reader)
            
        if fadeOutOffset != 0:
            print 'fadeout'
            # reader.seek(currentPosition + fadeOutOffset)
            # self.fadeOut = self.new(FadeOut, reader)
        
        if systemObjectOffset != 0:
            reader.seek(currentPosition + systemObjectOffset)

            objectType = self.parent.objectType
            if objectType in (TEXT, QUESTION): # also question
                self.text = self.new(Text, reader)
            elif objectType in (SCORE, LIVES, COUNTER):
                self.counters = self.new(Counters, reader)
            # elif objectType == RTF:
                # self.rtf = self.new(RTFObject, reader)
            elif objectType == SUBAPPLICATION:
                self.subApplication = self.new(SubApplication, reader)
            else:
                print 'native noo', objectType

class Backdrop(_Background):
    def read(self, reader):
        size = reader.readInt()
        self.obstacleType = reader.readShort()
        self.collisionMode = reader.readShort()
        self.image = reader.readShort()
        
    def write(self, reader):
        reader.writeInt(0) # size
        reader.writeShort(self.obstacleType)
        reader.writeShort(self.collisionMode)
        reader.writeShort(self.image)
        
    def getCollisionMode(self):
        return COLLISION_MODES[self.collisionMode]
    
    def getObstacleType(self):
        return OBSTACLE_TYPES[self.obstacleType]
    
    def getImage(self, imageBank):
        return imageBank.fromHandle(self.image)

class ObjectProperties(DataLoader, _ObjectTypeMixin):
    loader = None
    objectType = None
    isCommon = None
    _loadReader = None

    def read(self, reader):
        self._loadReader = reader
    
    def load(self, objectType):
        self.objectType = objectType
        reader = self._loadReader
        del self._loadReader
        reader.seek(0)
        
        self.isCommon = False
        if objectType == QUICKBACKDROP:
            reader.openEditor()
            self.loader = self.new(QuickBackdrop, reader)
        elif objectType == BACKDROP:
            self.loader = self.new(Backdrop, reader)
        else:
            self.isCommon = True
            self.loader = self.new(ObjectCommon, reader)
    
    def write(self, reader):
        self.loader.write(reader)

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

    def read(self, reader):
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

class FrameItems(DataLoader):
    def initialize(self):
        self.itemDict = {}
    
    @property
    def items(self):
        return self.itemDict.values()
    
    def read(self, reader):
        itemDict = self.itemDict
        for _ in xrange(reader.readInt(True)):
            item = self.new(ObjectInfo, reader)
            itemDict[item.handle] = item
            # raw_input()
    
    def fromHandle(self, handle):
        return self.itemDict[handle]

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
    
    def load(self):
        pass
    
    def read(self, reader):
        newChunks = self.new(ChunkList, reader)
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
        
        self.instances = newChunks.popChunk(ObjectInstances, True)
        
        self.events = newChunks.popChunk(Events)
        self.maxObjects = self.events.maxObjects
        
        self.palette = newChunks.popChunk(FramePalette, True)
        self.fadeIn = newChunks.popChunk(FadeIn, True)
        self.fadeOut = newChunks.popChunk(FadeOut, True)

class ObjectInstance(DataLoader):
    layer = 0
    def read(self, reader):
        self.handle = reader.readShort(True)
        self.objectInfo = reader.readShort(True)
        self.x = reader.readShort()
        self.y = reader.readShort()
        self.parentType = reader.readShort()
        self.parentHandle = reader.readShort()
    
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
    
    def fromHandle(self, handle):
        handle, = [item for item in self.items if item.handle == handle]
        return handle

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
        self.width = reader.readShort(True)
        self.height = reader.readShort(True)
        self.background = reader.readColor()
        self.flags.setFlags(reader.readShort(True))

from mmfparser.data.chunkloaders.expressions.names import (
    systemLoaders as expression_system,
    extensionLoaders as expression_extension,
    systemDict as expression_system_dict, 
    extensionDict as expression_extension_dict
)

class Parameter(DataLoader):
    def read(self, reader):
        currentPosition = reader.tell()
        size = reader.readShort()
        self.code = reader.readShort()
        self.loader = self.new(parameter_loaders[self.code], reader)
        reader.seek(currentPosition+size)
    
    def write(self, reader):
        newReader = ByteReader()
        newReader.writeShort(self.code)
        self.loader.write(newReader)
        reader.writeShort(len(newReader) + 2, True)
        reader.writeReader(newReader)
    
    def getName(self):
        return getName(self.code)

class Expression(_AceCommon):
    def initialize(self):
        self.systemDict = expression_system_dict
        self.extensionDict = expression_extension_dict

    def read(self, reader):
        currentPosition = reader.tell()
        self.objectType = reader.readByte()
        self.num = self.realnum = reader.readByte()
        if self.objectType > 2 and self.num >= 48:
            self.num += 32
        if self.objectType == 0 and self.num == 0:
            return
        size = reader.readShort(True)
        if (self.objectType in expression_system and 
        self.num in expression_system[self.objectType]):
            self.loader = self.new(
                expression_system[self.objectType][self.num], reader)
        elif self.objectType >= 2 or self.objectType == -7:
            self.objectInfo = reader.readShort(True)
            self.objectInfoList = reader.readShort()
            if self.num in expression_extension:
                self.loader = self.new(expression_extension[self.num], reader)
        reader.seek(currentPosition + size)

    def write(self, reader):
        reader.writeShort(self.objectType)
        reader.writeShort(self.num)
        if self.objectType == 0 and self.num == 0:
            return
        dataReader = ByteReader()
        if (self.objectType in expression_system 
        and self.num in expression_system[self.objectType]):
            self.loader.write(dataReader)
        elif self.objectType >= 2 or self.objectType == -7:
            dataReader.writeShort(self.objectInfo, True)
            dataReader.writeShort(self.objectInfoList)
            if self.num in expression_extension:
                self.loader.write(dataReader)
        reader.writeShort(len(dataReader) + 6, True)
        reader.writeReader(dataReader)
    
    def getExtensionNum(self):
        return (self.num) - 80

class OldExpressionParameter(ExpressionParameter):
    def read(self, reader):
        self.comparison = reader.readShort()
        items = self.items
        while 1:
            expression = self.new(Expression, reader)
            items.append(expression)
            if expression.objectType == 0 and expression.num == 0:
                break

parameter_loaders = []
for item in parameterLoaders:
    if item == ExpressionParameter:
        parameter_loaders.append(OldExpressionParameter)
    else:
        parameter_loaders.append(item)

class Action(_AceCommon):    
    def initialize(self):
        self.systemDict = actions.systemDict
        self.extensionDict = actions.extensionDict
        self.flags = ACE_FLAGS.copy()
        self.otherFlags = ACE_OTHERFLAGS.copy()

    def read(self, reader):
        currentPosition = reader.tell()
        size = reader.readShort(True)
        self.objectType = reader.readByte()
        self.num = self.realnum = reader.readByte()
        if self.objectType >= 2 and self.num >= 48:
            self.num += 32
        if self.getName() == 'SetFontName':
            print 'uhohh', self.num, self.realnum, self.objectType
            raw_input()
        self.objectInfo = reader.readShort(True)
        self.objectInfoList = reader.readShort()
        self.flags.setFlags(reader.readByte(True))
        self.otherFlags.setFlags(reader.readByte(True))
        numberOfParameters = reader.readByte()
        self.defType = reader.readByte()
        self.items = [self.new(Parameter, reader) 
            for i in xrange(numberOfParameters)]
        reader.seek(currentPosition+size)
    
    def write(self, reader):
        newReader = ByteReader()
        newReader.writeShort(self.objectType)
        newReader.writeShort(self.num)
        newReader.writeShort(self.objectInfo, True)
        newReader.writeShort(self.objectInfoList)
        newReader.writeByte(self.flags.getFlags(), True)
        newReader.writeByte(self.otherFlags.getFlags(), True)
        newReader.writeByte(len(self.items))
        newReader.writeByte(self.defType)
        
        for item in self.items:
            item.write(newReader)
        
        reader.writeShort(len(newReader) + 2, True)
        reader.writeReader(newReader)
    
    def getExtensionNum(self):
        return (self.num) - 80

class Condition(_AceCommon):
    def initialize(self):
        self.systemDict = conditions.systemDict
        self.extensionDict = conditions.extensionDict
        self.flags = ACE_FLAGS.copy()
        self.otherFlags = ACE_OTHERFLAGS.copy()

    def read(self, reader):
        currentPosition = reader.tell()
        size = reader.readShort(True)
        self.objectType = reader.readByte()
        self.num = self.realnum = reader.readByte()
        if self.objectType >= 2 and self.num < -48:
            self.num -= 32
        self.objectInfo = reader.readShort(True)
        self.objectInfoList = reader.readShort()
        self.flags.setFlags(reader.readByte(True))
        self.otherFlags.setFlags(reader.readByte(True))
        numberOfParameters = reader.readByte()
        self.defType = reader.readByte()
        self.identifier = reader.readShort() # Event identifier
        
        self.items = [self.new(Parameter, reader) 
            for i in xrange(numberOfParameters)]
        
        reader.seek(currentPosition + size)
        
    def write(self, reader):
        newReader = ByteReader()
        newReader.writeShort(self.objectType)
        newReader.writeShort(self.num)
        newReader.writeShort(self.objectInfo, True)
        newReader.writeShort(self.objectInfoList)
        newReader.writeByte(self.flags.getFlags(), True)
        newReader.writeByte(self.otherFlags.getFlags(), True)
        newReader.writeByte(len(self.items), True)
        newReader.writeByte(self.defType)
        newReader.writeShort(self.identifier)
        
        for item in self.items:
            item.write(newReader)
        
        reader.writeShort(len(newReader) + 2, True)
        reader.writeReader(newReader)
    
    def getExtensionNum(self):
        return -(self.num) - 80 - 1

class EventGroup(DataLoader):
    def initialize(self):
        self.flags = GROUP_FLAGS.copy()
    
    def read(self, reader):
        currentPosition = reader.tell()
        size = reader.readShort()*-1

        numberOfConditions = reader.readByte(True)
        numberOfActions = reader.readByte(True)
        self.flags.setFlags(reader.readShort(True)) # Flags
        self.is_restricted = reader.readShort() # If the group is inhibited
        self.restrictCpt = reader.readShort() # Counter
        self.identifier = reader.readShort() # Unique identifier
        self.undo = reader.readShort() # Identifier for UNDO
        
        self.conditions = [self.new(Condition, reader) 
            for i in xrange(numberOfConditions)]
            
        self.actions = [self.new(Action, reader) 
            for i in xrange(numberOfActions)]

        reader.seek(currentPosition + size)
        
    def write(self, reader):
        newReader = ByteReader()
        
        newReader.writeByte(len(self.conditions), True)
        newReader.writeByte(len(self.actions), True)
        newReader.writeShort(self.flags.getFlags(), True)
        newReader.writeShort(self.is_restricted)
        newReader.writeShort(self.restrictCpt)
        newReader.writeShort(self.identifier)
        newReader.writeShort(self.undo)
        
        for condition in self.conditions:
            condition.write(newReader)

        for action in self.actions:
            action.write(newReader)
        
        reader.writeShort((len(newReader) + 2)*-1)
        reader.writeReader(newReader)

class Events(DataLoader):
    def initialize(self):
        self.items = []
    
    def read(self, reader):
        while 1:
            identifier = reader.read(4)
            if identifier == HEADER:
                self.maxObjects = max(300, reader.readShort())
                self.maxObjectInfo = reader.readShort()
                self.numberOfPlayers = reader.readShort()
                self.numberOfConditions = [reader.readShort()
                    for _ in xrange(17)]
                self.qualifiers = qualifiers = {}
                for _ in xrange(reader.readShort()):
                    newQualifier = self.new(Qualifier, reader)
                    qualifiers[newQualifier.qualifier] = newQualifier
            elif identifier == EVENT_COUNT:
                size = reader.readInt() # ignored

            elif identifier == EVENTGROUP_DATA:
                size = reader.readInt()
                endPosition = reader.tell() + size
                while 1:
                    self.items.append(self.new(EventGroup, reader))
                    if reader.tell() >= endPosition:
                        break
                
            elif identifier == END:
                break
            else:
                print 'identifier %r not implemented (%s)' % (identifier, 
                    reader.tell())
                break
    
    def write(self, reader):
        eventReader = ByteReader()
        for eventGroup in self.items:
            eventGroup.write(eventReader)
        
        reader.write(HEADER)
        reader.writeShort(self.maxObjects)
        reader.writeShort(self.maxObjectInfos)
        reader.writeShort(self.numberOfPlayers)
        for item in self.numberOfConditions:
            reader.writeShort(item)
        reader.writeShort(len(self.qualifiers))
        for item in self.qualifiers:
            item.write(reader)
        
        reader.write(EVENT_COUNT)
        reader.writeInt(len(eventReader))
        
        if self.items:
            reader.write(EVENTGROUP_DATA)
            reader.writeInt(len(eventReader))
            reader.writeReader(eventReader)
        
        reader.write(END)