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

itemTypes = {
    'INSERT' : 0,
    'CHANGE' : 128,
    'APPEND' : 256,
    'DELETE' : 512,
    'REMOVE' : 4096,
    'BYCOMMAND' : 0,
    'BYPOSITION' : 1024,
    'SEPARATOR' : 2048,
    'ENABLED' : 0,
    'GRAYED' : 1,
    'DISABLED' : 2,
    'UNCHECKED' : 0,
    'CHECKED' : 8,
    'USECHECKBITMAPS' : 512,
    'STRING' : 0,
    'BITMAP' : 4,
    'OWNERDRAW' : 256,
    'POPUP' : 16,
    'MENUBARBREAK' : 32,
    'MENUBREAK' : 64,
    'UNHILITE' : 0,
    'HILITE' : 128,
    'SYSMENU' : 8192,
    'HELP' : 16384,
    'MOUSESELECT' : -32768,
    'END' : 128
}

class AppMenuItem(DataLoader):
    name = None
    flags = None
    id = None
    mnemonic = None

    def read(self, reader):
        mnemonic = None
        flags = reader.readShort()
        if not byteflag.getFlag(flags, 4): # if bit 4 is not set, read id
            self.id = reader.readShort()
        name = reader.readUnicodeString()
        for index in range(len(name)):
            if name[index] == '&':
                mnemonic = name[index+1].upper()
        name.replace('&', '')
                
        self.name = name
        self.mnemonic = mnemonic
        self.flags = flags
        
    def write(self, reader):
        reader.writeShort(self.flags)
        if not byteflag.getFlag(self.flags, 4):
            reader.writeShort(self.id)
        name = self.name
        if self.mnemonic is not None:
            name = name.replace(self.mnemonic, '&' + self.mnemonic)
        reader.writeUnicodeString(name)
        
class AppMenu(DataLoader):
    items = None
    accelKey = None
    accelId = None
    accelShift = None
    
    def initialize(self):
        self.items = []
        self.accelId = []
        self.accelKey = []
        self.accelShift = []
    
    def read(self, reader):
        currentPosition = reader.tell()
        headerSize = reader.readInt(True)
        menuOffset = reader.readInt()
        menuSize = reader.readInt()
        if menuSize == 0:
            return
        accelOffset = reader.readInt()
        accelSize = reader.readInt()
        reader.seek(currentPosition + menuOffset)
        reader.skipBytes(4)
        self.loadItems(reader)
        reader.seek(currentPosition + accelOffset)
        for i in range(accelSize / 8):
            self.accelShift.append(Key(reader.readByte()))
            reader.skipBytes(1)
            self.accelKey.append(Key(reader.readShort()))
            self.accelId.append(reader.readShort())
            reader.skipBytes(2)
            
                
    def loadItems(self, reader):
        items = self.items
        while True:
            newItem = AppMenuItem(reader)
            items.append(newItem)
            if byteflag.getFlag(newItem.flags, 4):# if bit 4 is set
                self.loadItems(reader) # load inner items?
            if byteflag.getFlag(newItem.flags, 7):
                break

    def write(self, reader):
        menuData = ByteReader()
        for item in self.items:
            item.write(menuData)

        nAccels = len(self.accelKey)
        reader.writeInt(20) # pad
        reader.writeInt(20)
        reader.writeInt(0) # pad
        reader.writeInt(24+len(menuData))
        reader.writeInt(nAccels*8)
        reader.writeInt(0) #pad
        reader.writeReader(menuData)
        for i in range(nAccels):
            reader.writeByte(self.accelShift[i].getValue())
            reader.writeByte(0) # pad
            reader.writeShort(self.accelKey[i].getValue())
            reader.writeShort(self.accelId[i])
            reader.writeShort(0) # pad

__all__ = ['AppMenu']