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
from mmfparser.key import Key
from mmfparser.bytereader import ByteReader, checkDefault

controlTypes = [
    'Joystick 1',
    'Joystick 2',
    'Joystick 3',
    'Joystick 4',
    'Keyboard'
]

class Controls(DataLoader):
    controls = None
    def initialize(self):
        self.controls = []

    def read(self, reader):
        self.controls = [self.new(PlayerControl, reader)
            for _ in xrange(reader.readInt())]

    def write(self, reader):
        reader.writeInt(len(self.controls))
        for control in self.controls:
            control.write(reader)

class PlayerControl(DataLoader):
    controlType = None
    unknown = None
    up = None
    down = None
    left = None
    right = None
    button1 = None
    button2 = None
    button3 = None
    button4 = None

    def initialize(self):
        self.up = Key()
        self.down = Key()
        self.left = Key()
        self.right = Key()
        self.button1 = Key()
        self.button2 = Key()
        self.button3 = Key()
        self.button4 = Key()

    def read(self, reader):
        self.controlType = reader.readInt()
        count = reader.readInt(True) # 16
        checkDefault(reader, count, 16)
        self.up = Key(reader.readInt())
        self.down = Key(reader.readInt())
        self.left = Key(reader.readInt())
        self.right = Key(reader.readInt())
        self.button1 = Key(reader.readInt())
        self.button2 = Key(reader.readInt())
        self.button3 = Key(reader.readInt())
        self.button4 = Key(reader.readInt())
        for _ in xrange(8):
            checkDefault(reader, reader.readInt(), 0)

    def getControlType(self):
        return controlTypes[self.controlType-1]

    def write(self, reader):
        reader.writeInt(self.controlType)
        reader.writeInt(16, True)
        for item in (self.up, self.down, self.left, self.right,
                     self.button1, self.button2, self.button3, self.button4):
            reader.writeInt(item.getValue())

        for _ in xrange(8):
            reader.writeInt(0)