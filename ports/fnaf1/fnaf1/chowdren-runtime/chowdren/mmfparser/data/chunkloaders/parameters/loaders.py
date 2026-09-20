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
from mmfparser.data.chunkloaders.parameters.names import getName
from mmfparser.data.chunkloaders.expressions.loader import Expression
from mmfparser.key import Key
from mmfparser.bitdict import BitDict
from mmfparser.data.chunkloaders.common import (_ObjectInfoMixin,
    _ObjectTypeMixin)
from mmfparser.data.font import LogFont
from mmfparser.bytereader import ByteReader

EQUAL = 0
DIFFERENT = 1
LOWER_OR_EQUAL = 2
LOWER = 3
GREATER_OR_EQUAL = 4
GREATER = 5

OPERATOR_LIST = [
    '=',
    '<>',
    '<=',
    '<',
    '>=',
    '>'
]

def getAttributes(loader):
    attributeDict = {}
    for k in dir(loader):
        if k.startswith('__') or k in dir(DataLoader):
            continue
        v = getattr(loader, k)
        if hasattr(v, '__call__'):
            continue
        if isinstance(v, DataLoader):
            v = getAttributes(v)
        attributeDict[k] = v
    return attributeDict

class ParameterCommon(DataLoader):
    isExpression = False

class Object(ParameterCommon, _ObjectInfoMixin, _ObjectTypeMixin):
    objectInfoList = None
    objectInfo = None
    objectType = None

    def read(self, reader):
        self.objectInfoList = reader.readShort()
        self.objectInfo = reader.readShort(True)
        self.objectType = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.objectInfoList)
        reader.writeShort(self.objectInfo, True)
        reader.writeShort(self.objectType)

class Time(ParameterCommon):
    timer = None
    loops = None

    def read(self, reader):
        self.timer = reader.readInt()
        self.loops = reader.readInt()

    def write(self, reader):
        reader.writeInt(self.timer)
        reader.writeInt(self.loops)

class Short(ParameterCommon):
    value = None

    def read(self, reader):
        self.value = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.value)

class Remark(ParameterCommon):
    def read(self, reader):
        self.font = self.new(LogFont, reader, old = True)
        self.fontColor = reader.readColor()
        self.backColor = reader.readColor()
        if reader.readShort() != 0:
            print 'remark NOOO'
        self.id = reader.readInt(True)

    def write(self, reader):
        self.font.write(reader)
        reader.writeColor(self.fontColor)
        reader.writeColor(self.backColor)
        reader.writeShort(0)
        reader.writeInt(self.id)

class Int(ParameterCommon):
    value = None

    def read(self, reader):
        self.value = reader.readInt()

    def write(self, reader):
        reader.writeInt(self.value)

SAMPLE_FLAGS = BitDict(
    'Uninterruptible',
    'Bad',
    'IPhoneAudioPlayer',
    'IPhoneOpenAL'
)


class Sample(ParameterCommon):
    handle = None
    flags = None

    def initialize(self):
        self.flags = SAMPLE_FLAGS.copy()

    def read(self, reader):
        self.handle = reader.readShort()
        self.flags.setFlags(reader.readShort(True))
        self.name = self.readString(reader)

    def write(self, reader):
        reader.writeShort(self.handle)
        reader.writeShort(self.flags.getFlags(), True)
        reader.writeString(self.name)

class Create(ParameterCommon):
    objectInstance = None
    objectInfo = None

    def read(self, reader):
        self.position = self.new(Position, reader)
        self.objectInstance = reader.readShort(True)
        self.objectInfo = reader.readShort(True)
        reader.skipBytes(4) # free

    def write(self, reader):
        self.position.write(reader)
        reader.writeShort(self.objectInstance, True)
        reader.writeShort(self.objectInfo, True)
        reader.write('\x00' * 4)

class Every(ParameterCommon):
    delay = None

    def read(self, reader):
        self.delay = reader.readInt() # in ms
        self.compteur = reader.readInt()

    def write(self, reader):
        reader.writeInt(self.delay)
        reader.writeInt(self.compteur)

class KeyParameter(ParameterCommon):
    key = None

    def read(self, reader):
        self.key = Key(reader.readShort())

    def write(self, reader):
        reader.writeShort(self.key.getValue())

class ExpressionParameter(ParameterCommon):
    isExpression = True
    comparison = None
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        self.comparison = reader.readShort()
        items = self.items
        while 1:
            expression = self.new(Expression, reader)
            items.append(expression)
            if expression.objectType == 0 and expression.num == 0:
                break

    def write(self, reader):
        reader.writeShort(self.comparison)
        for item in self.items:
            item.write(reader)

    def getOperator(self):
        return OPERATOR_LIST[self.comparison]

POSITION_FLAGS = BitDict(
    # Located flag
    # True: transform position according to the direction of parent
    # False: use position without transformation
    'Direction',
    # Origin flag
    'Action',
    # 2 orientation flags (both are set appropriately)
    # True: use direction of parent
    'InitialDirection',
    # True: use default movement direction
    'DefaultDirection'
)

class Position(ParameterCommon):
    objectInfoParent = None
    flags = None
    x = None
    y = None
    slope = None
    angle = None
    direction = None
    typeParent = None
    objectInfoList = None
    layer = None

    def initialize(self):
        self.flags = POSITION_FLAGS.copy()

    def read(self, reader):
        self.objectInfoParent = reader.readShort(True)
        self.flags.setFlags(reader.readShort(True))
        self.x = reader.readShort()
        self.y = reader.readShort()
        self.slope = reader.readShort()
        self.angle = reader.readShort()
        self.direction = reader.readInt()
        self.typeParent = reader.readShort()
        self.objectInfoList = reader.readShort()
        self.layer = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.objectInfoParent, True)
        reader.writeShort(self.flags.getFlags(), True)
        reader.writeShort(self.x)
        reader.writeShort(self.y)
        reader.writeShort(self.slope)
        reader.writeShort(self.angle)
        reader.writeInt(self.direction)
        reader.writeShort(self.typeParent)
        reader.writeShort(self.objectInfoList)
        reader.writeShort(self.layer)

class Shoot(ParameterCommon):
    position = None
    objectInstance = None
    objectInfo = None
    shootSpeed = None

    def read(self, reader):
        self.position = self.new(Position, reader)
        self.objectInstance = reader.readShort(True)
        self.objectInfo = reader.readShort(True)
        reader.skipBytes(4) # free
        self.shootSpeed = reader.readShort()

    def write(self, reader):
        self.position.write(reader)
        reader.writeShort(self.objectInstance, True)
        reader.writeShort(self.objectInfo, True)
        reader.write('\x00' * 4)
        reader.writeShort(self.shootSpeed)

class Zone(ParameterCommon):
    x1 = None
    y1 = None
    x2 = None
    y2 = None

    def read(self, reader):
        self.x1 = reader.readShort()
        self.y1 = reader.readShort()
        self.x2 = reader.readShort()
        self.y2 = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.x1)
        reader.writeShort(self.y1)
        reader.writeShort(self.x2)
        reader.writeShort(self.y2)

class Colour(ParameterCommon):
    value = None

    def read(self, reader):
        self.value = reader.readColor()

    def write(self, reader):
        reader.writeColor(self.value)

PROGRAM_FLAGS = BitDict(
    'Wait',
    'Hide'
)

class Program(ParameterCommon):
    flags = None
    filename = None
    command = None

    def initialize(self):
        self.flags = PROGRAM_FLAGS.copy()

    def read(self, reader):
        self.flags.setFlags(reader.readShort(True))
        currentPosition = reader.tell()
        self.filename = self.readString(reader)
        reader.seek(currentPosition + 260)
        self.command = self.readString(reader)

    def write(self, reader):
        reader.writeShort(self.flags.getFlags(), True)
        filename = self.filename[:259]
        reader.write(filename + (260 - len(filename)) * '\x00')
        reader.writeString(self.command)

GROUP_FLAGS = BitDict(
    'Inactive',
    'Closed',
    'ParentInactive',
    'GroupInactive',
    'Global' # unicode?
)

class Group(ParameterCommon):
    flags = None
    id = None
    name = None
    offset = None

    def initialize(self):
        self.flags = GROUP_FLAGS.copy()

    def read(self, reader):
        self.offset = reader.tell() - 24
        self.flags.setFlags(reader.readShort(True))
        self.id = reader.readShort(True)
        self.name = self.readString(reader, 96)
        self.password = reader.readInt()

    def write(self, reader):
        reader.writeShort(self.flags.getFlags(), True)
        reader.writeShort(self.id, True)
        reader.writeString(self.name, 96)
        reader.writeInt(self.password)

class GroupPointer(ParameterCommon):
    savedPointer = None
    pointer = None
    id = None

    def read(self, reader):
        self.pointer = self.savedPointer = reader.readInt()
        self.id = reader.readShort()
        if self.pointer != 0:
            self.pointer += reader.tell()

    def write(self, reader):
        reader.writeInt(self.savedPointer)
        reader.writeShort(self.id)

class String(ParameterCommon):
    value = None

    def read(self, reader):
        self.value = self.readString(reader)

    def write(self, reader):
        reader.writeString(self.value)

class Filename(ParameterCommon):
    value = None

    def read(self, reader):
        self.value = self.readString(reader)

    def write(self, reader):
        value = self.value[:259]
        reader.write(value + '\x00' * (260 - len(value)))

class CompareTime(ParameterCommon):
    timer = None
    loops = None
    comparison = None

    def read(self, reader):
        self.timer = reader.readInt()
        self.loops = reader.readInt()
        self.comparison = reader.readShort()

    def write(self, reader):
        reader.writeInt(self.timer)
        reader.writeInt(self.loops)
        reader.writeShort(self.comparison)

class TwoShorts(ParameterCommon):
    value1 = None
    value2 = None

    def read(self, reader):
        self.value1 = reader.readShort()
        self.value2 = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.value1)
        reader.writeShort(self.value2)

class Extension(ParameterCommon):
    data = None
    type = None
    code = None
    def read(self, reader):
        size = reader.readShort()
        self.type = reader.readShort()
        self.code = reader.readShort()
        self.data = reader.readReader(size - 6)

    def get_reader(self):
        self.data.seek(0)
        return self.data

    def write(self, reader):
        reader.writeShort(len(self.data) + 6)
        reader.writeShort(self.type)
        reader.writeShort(self.code)
        reader.writeReader(self.data)

LEFT_CLICK = 0
MIDDLE_CLICK = 1
RIGHT_CLICK = 2

CLICK_NAMES = [
    'Left',
    'Middle',
    'Right'
]

class Click(ParameterCommon):
    double = None
    click = None

    def read(self, reader):
        self.click = reader.readByte()
        self.double = bool(reader.readByte())

    def write(self, reader):
        reader.writeByte(self.click)
        reader.writeByte(int(self.double))

    def getButton(self):
        return CLICK_NAMES[self.click]

class CharacterEncoding(ParameterCommon):
    def read(self, reader):
        raise NotImplementedError()
        # typedef struct {
        #     WORD    wCharEncoding;
        #     DWORD   dwUnusedParam;
        # } charEncodingParam;

    def write(self, reader):
        raise NotImplementedError()

class Bug(ParameterCommon):
    def read(self, reader):
        pass

    def write(self, reader):
        pass

parameterLoaders = [
    None,
    Object,
    Time,
    Short,
    Short,
    Int,
    Sample,
    Sample,
    None,
    Create,
    Short,
    Short,
    Short,
    Every,
    KeyParameter,
    ExpressionParameter,
    Position,
    Short,
    Shoot,
    Zone,
    None,
    Create,
    ExpressionParameter,
    ExpressionParameter,
    Colour,
    Int,
    Short,
    ExpressionParameter,
    ExpressionParameter,
    Int,
    None,
    Short,
    Click,
    Program,
    Int,
    Sample,
    Sample,
    Remark,
    Group,
    GroupPointer,
    Filename,
    String,
    CompareTime,
    Short,
    KeyParameter,
    ExpressionParameter,
    ExpressionParameter,
    TwoShorts,
    Int,
    Short,
    Short,
    TwoShorts,
    ExpressionParameter,
    ExpressionParameter,
    ExpressionParameter,
    Extension,
    Int,
    Short,
    Short,
    ExpressionParameter,
    Short,
    Short,
    ExpressionParameter,
    Filename,
    String,
    CharacterEncoding,
    CharacterEncoding
]