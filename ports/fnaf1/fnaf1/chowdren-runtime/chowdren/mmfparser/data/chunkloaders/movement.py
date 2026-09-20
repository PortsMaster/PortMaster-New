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

MOVEMENT_TYPES = [
    'Static',
    'Mouse',
    'Race',
    'EightDirections',
    'Ball',
    'Path',
    'Intelligent',
    'Pinball',
    'List',
    'Platform',
    'GoMovement', # wtf!?
    'Disappear', # wtf!?!?!?
    'Appear',
    'Bullet',
    'Extension'
]

class Static(DataLoader):
    def read(self, reader):
        pass

    def write(self, reader):
        pass

class Mouse(DataLoader):
    x1 = None
    x2 = None
    y1 = None
    y2 = None
    unusedFlags = None
    def read(self, reader):
        self.x1 = reader.readShort()
        self.x2 = reader.readShort()
        self.y1 = reader.readShort()
        self.y2 = reader.readShort()
        unusedFlags = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.x1)
        reader.writeShort(self.x2)
        reader.writeShort(self.y1)
        reader.writeShort(self.y2)
        reader.writeShort(0)

class Race(DataLoader):
    speed = None
    acceleration = None
    deceleration = None
    rotationSpeed = None
    bounceFactor = None
    reverseEnabled = None

    def read(self, reader):
        self.speed = reader.readShort()
        self.acceleration = reader.readShort()
        self.deceleration = reader.readShort()
        self.rotationSpeed = reader.readShort()
        self.bounceFactor = reader.readShort()
        self.angles = reader.readShort()
        self.reverseEnabled = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.speed)
        reader.writeShort(self.acceleration)
        reader.writeShort(self.deceleration)
        reader.writeShort(self.rotationSpeed)
        reader.writeShort(self.bounceFactor)
        reader.writeShort(self.angles)
        reader.writeShort(self.reverseEnabled)

class EightDirections(DataLoader):
    speed = None
    acceleration = None
    deceleration = None
    bounceFactor = None # as stated in Cncf.h
    directions = None

    def read(self, reader):
        self.speed = reader.readShort()
        self.acceleration = reader.readShort()
        self.deceleration = reader.readShort()
        self.bounceFactor = reader.readShort()
        self.directions = reader.readInt()

    def write(self, reader):
        reader.writeShort(self.speed)
        reader.writeShort(self.acceleration)
        reader.writeShort(self.deceleration)
        reader.writeShort(self.bounceFactor)
        reader.writeInt(self.directions)

class Ball(DataLoader):
    speed = None
    randomizer = None
    angles = None
    security = None
    deceleration = None

    def read(self, reader):
        self.speed = reader.readShort()
        self.randomizer = reader.readShort()
        self.angles = reader.readShort()
        self.security = reader.readShort()
        self.deceleration = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.speed)
        reader.writeShort(self.randomizer)
        reader.writeShort(self.angles)
        reader.writeShort(self.security)
        reader.writeShort(self.deceleration)

class Path(DataLoader):
    minimumSpeed = None
    maximumSpeed = None
    loop = None
    repositionAtEnd = None
    reverseAtEnd = None

    def initialize(self):
        self.steps = []

    def read(self, reader):
        count = reader.readShort()
        self.minimumSpeed = reader.readShort()
        self.maximumSpeed = reader.readShort()
        self.loop = reader.readByte()
        self.repositionAtEnd = reader.readByte()
        self.reverseAtEnd = reader.readByte()
        reader.skipBytes(1) # "free"
        for _ in xrange(count):
            currentPosition = reader.tell()

            reader.skipBytes(1)
            size = reader.readByte(True)
            self.steps.append(self.new(Step, reader))

            reader.seek(currentPosition + size)

    def write(self, reader):
        reader.writeShort(len(self.steps))
        reader.writeShort(self.minimumSpeed)
        reader.writeShort(self.maximumSpeed)
        reader.writeByte(self.loop)
        reader.writeByte(self.repositionAtEnd)
        reader.writeByte(self.reverseAtEnd)
        reader.writeByte(0)
        for step in self.steps:
            reader.writeByte(0)
            stepData = step.generate()
            reader.writeByte(len(stepData) + 2)
            reader.writeReader(stepData)

class Step(DataLoader):
    speed = None
    direction = None
    # destination positions relative to the last step
    destinationX = None
    destinationY = None
    cosinus = None
    sinus = None
    length = None
    pause = None
    name = None

    def read(self, reader):
        self.speed = reader.readByte()
        self.direction = reader.readByte()
        self.destinationX = reader.readShort()
        self.destinationY = reader.readShort()
        self.cosinus = reader.readShort() / 16384.0
        self.sinus = reader.readShort() / 16384.0
        self.length = reader.readShort()
        self.pause = reader.readShort()
        name = reader.readString()
        if len(name) > 0:
            self.name = name

    def write(self, reader):
        reader.writeByte(self.speed)
        reader.writeByte(self.direction)
        reader.writeShort(self.destinationX)
        reader.writeShort(self.destinationY)
        reader.writeShort(self.cosinus * 16384.0)
        reader.writeShort(self.sinus * 16384.0)
        reader.writeShort(self.length)
        reader.writeShort(self.pause)
        reader.writeString(self.name or '')

CONTROLS = [
    'NoJump',
    'WhileWalking',
    'Button1',
    'Button2'
]

class Platform(DataLoader):
    speed = None
    acceleration = None
    deceleration = None
    control = None
    gravity = None
    jumpStrength = None
    def read(self, reader):
        self.speed = reader.readShort()
        self.acceleration = reader.readShort()
        self.deceleration = reader.readShort()
        self.control = reader.readShort()
        self.gravity = reader.readShort()
        self.jumpStrength = reader.readShort()

    def write(self, reader):
        reader.writeShort(self.speed)
        reader.writeShort(self.acceleration)
        reader.writeShort(self.deceleration)
        reader.writeShort(self.control)
        reader.writeShort(self.gravity)
        reader.writeShort(self.jumpStrength)

    def getControl(self):
        return CONTROLS[self.control]

    def setControl(self, name):
        self.control = CONTROLS.index(name)

class Extension(DataLoader):
    id = None
    data = None
    name = None

    def read(self, reader):
        self.data = reader.readReader(self.settings['dataSize'])

    def write(self, reader):
        reader.writeReader(self.data)

MOVEMENT_CLASSES = {
    0 : Static,
    1 : Mouse,
    2 : Race,
    3 : EightDirections,
    4 : Ball,
    5 : Path,
    9 : Platform,
    14 : Extension
}

class Movements(DataLoader):
    items = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        rootPosition = reader.tell()
        count = reader.readInt(True)
        currentPosition = reader.tell()
        for _ in xrange(count):
            self.items.append(self.new(Movement, reader,
                rootPosition = rootPosition))
            reader.seek(currentPosition + 16)
            currentPosition = reader.tell()

    def write(self, reader):
        reader.writeInt(len(self.items), True)
        for item in self.items:
            item.write(reader)

class Movement(DataLoader):
    player = None
    type = None
    movingAtStart = None
    directionAtStart = None
    loader = None

    def read(self, reader):
        # extension stuff (if extension, that is)
        rootPosition = self.settings['rootPosition']

        nameOffset = reader.readInt()
        movementId = reader.readInt()
        newOffset = reader.readInt()
        dataSize = reader.readInt()

        reader.seek(rootPosition + newOffset)
        self.player = reader.readShort()
        self.type = reader.readShort()
        self.movingAtStart = reader.readByte()

        reader.skipBytes(3) # free

        self.directionAtStart = reader.readInt()

        if self.getName() == 'Extension':
            reader.skipBytes(14)
            dataSize -= 14

        self.loader = self.new(MOVEMENT_CLASSES[self.type], reader,
            dataSize = dataSize - 12)

        if self.getName() == 'Extension':
            reader.seek(rootPosition + nameOffset)
            self.loader.name = self.readString(reader)[:-4]
            self.loader.id = movementId

    def write(self, reader):
        loaderData = self.loader.generate()
        if self.getName() == 'Extension':
            reader.writeInt(16)
            reader.writeInt(self.loader.id)
            reader.writeInt(16 + len(self.loader.name) + 1)
            reader.writeInt(len(loaderData) + 12 + 14)
            reader.writeString(self.loader.name)
        else:
            reader.writeInt(0)
            reader.writeInt(0)
            reader.writeInt(16)
            reader.writeInt(0)
        reader.writeShort(self.player)
        reader.writeShort(self.type)
        reader.writeByte(self.movingAtStart)
        reader.write('\x00' * 3)
        reader.writeInt(self.directionAtStart)
        if self.getName() == 'Extension':
            reader.write('\x00' * 14)
        reader.writeReader(loaderData)

        # print 'read %s' % self.getName()

    def getName(self):
        return MOVEMENT_TYPES[self.type]

    def setName(self, name):
        self.type = MOVEMENT_TYPES.index(name)