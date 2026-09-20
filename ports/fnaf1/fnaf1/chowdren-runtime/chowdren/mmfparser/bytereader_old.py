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

from cStringIO import StringIO
import struct
import subprocess
import os
import traceback
import sys
import tempfile

BYTE = struct.Struct('b')
UBYTE = struct.Struct('B')
SHORT = struct.Struct('h')
USHORT = struct.Struct('H')
FLOAT = struct.Struct('f')
DOUBLE = struct.Struct('d')
INT = struct.Struct('i')
UINT = struct.Struct('I')

class ByteReader(object):
    buffer = None
    lastPosition = None

    def __init__(self, input = None, fp = None):
        if isinstance(input, file):
            buffer = input
            self.write = buffer.write
        else:
            if input is not None:
                buffer = StringIO(input)
            else:
                buffer = StringIO()
                self.write = buffer.write
            self.data = buffer.getvalue

        self.buffer = buffer
        self.tell = buffer.tell

        self.lastPosition = self.tell()
    
    def data(self):
        currentPosition = self.tell()
        self.seek(0)
        data = self.read()
        self.seek(currentPosition)
        return data
    
    def seek(self, *arg, **kw):
        self.buffer.seek(*arg, **kw)
        self.lastPosition = self.tell()
    
    def read(self, *arg, **kw):
        self.lastPosition = self.tell()
        return self.buffer.read(*arg, **kw)
    
    def size(self):
        currentPosition = self.tell()
        self.seek(0, 2)
        size = self.tell()
        self.seek(currentPosition)
        return size
    
    def __len__(self):
        return self.size()
    
    def __str__(self):
        return self.data()
    
    def __repr__(self):
        return repr(str(self))

    def readByte(self, asUnsigned = False):
        format = UBYTE if asUnsigned else BYTE
        value, = self.readStruct(format)
        return value
        
    def readShort(self, asUnsigned = False):
        format = USHORT if asUnsigned else SHORT
        value, = self.readStruct(format)
        return value

    def readFloat(self):
        value, = self.readStruct(FLOAT)
        return value

    def readDouble(self):
        value, = self.readStruct(DOUBLE)
        return value
        
    def readInt(self, asUnsigned = False):
        format = UINT if asUnsigned else INT
        value, = self.readStruct(format)
        return value
        
    def readString(self, size = None):
        if size is not None:
            return self.readReader(size).readString()
        currentPosition = self.tell()
        store = ''
        while 1:
            readChar = self.read(1)
            if readChar in ('\x00', ''):
                break
            store = ''.join([store, readChar])
        self.lastPosition = currentPosition
        return store
        
    def readUnicodeString(self):
        currentPosition = self.tell()
        startPos = self.tell()
        while 1:
            short = self.readShort()
            if short == 0:
                break
        size = self.tell() - 2 - startPos
        self.seek(startPos)
        data = self.read(size)
        self.skipBytes(2)
        self.lastPosition = currentPosition
        return data.decode('utf-16-le')
        
    def readColor(self):
        currentPosition = self.tell()
        r = self.readByte(True)
        g = self.readByte(True)
        b = self.readByte(True)
        self.skipBytes(1)
        self.lastPosition = currentPosition
        return (r, g, b)
    
    def readReader(self, size):
        reader = ByteReader()
        reader.write(self.read(size))
        reader.seek(0)
        return reader

    def readFormat(self, format):
        size = struct.calcsize(format)
        return struct.unpack(format, self.read(size))
    
    def readStruct(self, structType):
        return structType.unpack(self.read(structType.size))
        
    def writeByte(self, value, asUnsigned = False):
        format = UBYTE if asUnsigned else BYTE
        self.writeStruct(format, value)
        
    def writeShort(self, value, asUnsigned = False):
        format = USHORT if asUnsigned else SHORT
        self.writeStruct(format, value)

    def writeFloat(self, value):
        self.writeStruct(FLOAT, value)

    def writeDouble(self, value):
        self.writeStruct(DOUBLE, value)
        
    def writeInt(self, value, asUnsigned = False):
        format = UINT if asUnsigned else INT
        self.writeStruct(format, value)
        
    def writeString(self, value):
        self.write(value + "\x00")
        
    def writeUnicodeString(self, value):
        self.write(value.encode('utf-16-le') + "\x00\x00")
        
    def writeColor(self, colorTuple):
        r, g, b = colorTuple
        self.writeByte(r, True)
        self.writeByte(g, True)
        self.writeByte(b, True)
        self.writeByte(0)
        
    def writeFormat(self, format, *values):
        self.write(struct.pack(format, *values))
    
    def writeStruct(self, structType, *values):
        self.write(structType.pack(*values))
        
    def writeReader(self, reader):
        self.write(reader.data())
        
    def skipBytes(self, n):
        self.seek(n, 1)
        
    def rewind(self, n):
        self.seek(-n, 1)
    
    def truncate(self, value):
        self.buffer.truncate(value)
    
    def checkDefault(self, *arg, **kw):
        return checkDefault(self, *arg, **kw)
    
    def openEditor(self):
        if not hasattr(self.buffer, 'name'):
            fp = tempfile.NamedTemporaryFile('wb', delete = False)
            fp.write(self.data())
            fp.close()
            name = fp.name
            is_temp = True
        else:
            name = self.buffer.name
            is_temp = False
        try:
            raw_input('Press enter to open hex editor...')
            openEditor(name, self.tell())
        except IOError:
            pass
        raw_input('(enter)')

def openEditor(filename, position):
    return subprocess.Popen(['010editor', '%s@%s' % (filename, position)])
        
def checkDefault(reader, value, *defaults):
    size = reader.tell() - reader.lastPosition
    reprDefaults = defaults
    if len(defaults) == 1:
        reprDefaults, = defaults
    message = ('unimplemented value at %s, size %s (should be '
        '%s but was %s)' % (reader.lastPosition, size, reprDefaults, value))
    if value in defaults:
        return
    traceback.print_stack(file=sys.stdout)
    # print message
    if sys.stdin.isatty():
        reader.openEditor()
    raise SystemExit