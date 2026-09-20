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

from mmfparser.bytereader import ByteReader
from mmfparser import byteflag
from mmfparser.key import Key
from mmfparser.loader import DataLoader
from mmfparser.bitdict import BitDict
from mmfparser.data.checksum import make_checksum

graphicModes = {
    4 : '16 million colors',
    7 : '65536 colors',
    6 : '32768 colors',
    3 : '256 colors'
}

controlTypes = [
    'Joystick 1',
    'Joystick 2',
    'Joystick 3',
    'Joystick 4',
    'Keyboard'
]

class Controls(DataLoader):
    items = None
    
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
        self.up.setValue(reader.readShort())
        self.down.setValue(reader.readShort())
        self.left.setValue(reader.readShort())
        self.right.setValue(reader.readShort())
        self.button1.setValue(reader.readShort())
        self.button2.setValue(reader.readShort())
        self.button3.setValue(reader.readShort())
        self.button4.setValue(reader.readShort())

    def write(self, reader):
        reader.writeShort(self.up.getValue())
        reader.writeShort(self.down.getValue())
        reader.writeShort(self.left.getValue())
        reader.writeShort(self.right.getValue())
        reader.writeShort(self.button1.getValue())
        reader.writeShort(self.button2.getValue())
        reader.writeShort(self.button3.getValue())
        reader.writeShort(self.button4.getValue())

class PlayerControl(DataLoader):
    controlType = None
    keys = None

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
        
    def write(self, reader):
        reader.writeShort(self.controlType)

HEADER_FLAGS = BitDict(
    'BorderMax',
    'NoHeading',
    'Panic',
    'SpeedIndependent',
    'Stretch',
    'MusicOn', # obsolete?
    'SoundOn', # obsolete?
    'MenuHidden',
    'MenuBar',
    'Maximize', # maximized at bootup?
    'MultiSamples',
    'FullscreenAtStart',
    'FullscreenSwitch',
    'Protected', # wonder...
    'Copyright',
    'OneFile' # ?
)

HEADER_NEW_FLAGS = BitDict(
    'SamplesOverFrames',
    'RelocFiles',
    'RunFrame',
    'SamplesWhenNotFocused',
    'NoMinimizeBox',
    'NoMaximizeBox',
    'NoThickFrame',
    'DoNotCenterFrame',
    'ScreensaverAutostop',
    'DisableClose',
    'HiddenAtStart',
    'XPVisualThemes',
    'VSync',
    'RunWhenMinimized',
    'MDI',
    'RunWhileResizing',
)

HEADER_OTHER_FLAGS = BitDict(
    'DebuggerShortcuts',
    'DirectX',
    'VRAM',
    'Obsolete',
    'AutoImageFilter',
    'AutoSoundFilter',
    'AllInOne', # no idea
    'ShowDebugger',
    'Reserved1',
    'Reserved2'
)

class AppHeader(DataLoader):
    borderColor = None
    numberOfFrames = None
    frameRate = None
    windowsMenuIndex = None # Index of Window menu for MDI applications
    flags = None
    newFlags = None
    mode = None
    otherFlags = None
    windowWidth = None
    windowHeight = None
    initialScore = None
    initialLives = None
    controls = None
    
    checksum = None

    def initialize(self):
        self.flags = HEADER_FLAGS.copy()
        self.newFlags = HEADER_NEW_FLAGS.copy()
        self.otherFlags = HEADER_OTHER_FLAGS.copy()

        # self.controls = self.new(Controls)
    
    def read(self, reader):
        size = reader.readInt()
        # (gaFlags)
        self.flags.setFlags(reader.readShort(True))

        # (gaNewFlags)
        self.newFlags.setFlags(reader.readShort(True))

        self.mode = reader.readShort()
        # (gaOtherFlags)
        self.otherFlags.setFlags(reader.readShort(True))

        self.windowWidth = reader.readShort(True)
        self.windowHeight = reader.readShort(True)
        self.initialScore = reader.readInt(True) ^ 0xffffffff
        self.initialLives = reader.readInt(True) ^ 0xffffffff
        self.controls = self.new(Controls, reader)
        self.borderColor = reader.readColor()
        self.numberOfFrames = reader.readInt(True)
        self.frameRate = reader.readInt(True)
        self.windowsMenuIndex = reader.readByte()
        reader.skipBytes(3) # definitely skipped, defined as gaFree
        if not self.flags['OneFile']:
            # we're debugging, let new chunks know
            self.parent.settings['debug'] = True
            
    def getGraphicMode(self):
        return graphicModes[self.mode]
        
    def setGraphicMode(self, graphicMode):
        for key, value in graphicModes.iteritems():
            if value == graphicMode:
                self.mode = value
                return True
        return False
        
    def write(self, reader):
        reader.writeInt(112) # total size, must be 0x70, 112
        reader.writeShort(self.flags.getFlags(), True)
        reader.writeShort(self.newFlags.getFlags(), True)
        reader.writeShort(self.mode)
        reader.writeShort(self.otherFlags.getFlags(), True)
        reader.writeShort(self.windowWidth)
        reader.writeShort(self.windowHeight)
        reader.writeInt(self.initialScore ^ 0xffffffff)
        reader.writeInt(self.initialLives ^ 0xffffffff)
        self.controls.write(reader)
        reader.writeColor(self.borderColor)
        reader.writeInt(self.numberOfFrames)
        reader.writeInt(self.frameRate)
        reader.writeByte(self.windowsMenuIndex)
        reader.writeFormat('xxx') # 3 pad bytes
        reader.seek(0)
        self.checksum = make_checksum(reader.read())

class ExtendedHeader(DataLoader):
    flags = None
    buildType = None
    buildFlags = None
    screenRatioTolerance = None
    screenAngle = None
    
    def initialize(self):
        self.flags = BitDict(
            'KeepScreenRatio',
            'FrameTransition', # (HWA only) frame has a transition
            'ResampleStretch', # (HWA only) resample while resizing
            'GlobalRefresh' # (Mobile) force global refresh
        )

    def read(self, reader):
        self.flags.setFlags(reader.readInt())
        self.buildType = reader.readInt(True)
        self.buildFlags = reader.readInt(True)
        self.screenRatioTolerance = reader.readShort()
        self.screenAngle = reader.readShort()
        reader.readInt() # unused
        if self.buildType >= 0x10000000:
            self.parent.settings['compat'] = True
    
    def write(self, reader):
        reader.writeInt(self.flags.getFlags())
        reader.writeInt(self.buildType, True)
        reader.writeInt(self.buildFlags, True)
        reader.writeShort(self.screenRatioTolerance)
        reader.writeShort(self.screenAngle)
        reader.writeInt(0) # unused

__all__ = ['AppHeader', 'ExtendedHeader']