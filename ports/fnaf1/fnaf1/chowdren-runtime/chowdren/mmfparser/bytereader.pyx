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

include "is_pypy.pxi"

cdef extern from "stdlib.h":
    void *memcpy(void * str1, void * str2, size_t n)

from libc.stdio cimport FILE

cdef extern from "Python.h":
    FILE * PyFile_AsFile(object)

from libc.stdio cimport fseek, ftell, fread, fwrite

from mmfparser.common cimport allocate_memory

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

cdef class ByteReader

cdef inline int check_available(ByteReader reader, size_t size) except -1:
    if reader.pos + size > reader.data_size:
        import traceback
        traceback.print_stack()
        raise struct.error('%s bytes required' % size)
    return 0

cdef inline void ensure_size(ByteReader reader, size_t size):
    cdef char * buf
    if size < reader.data_size:
        size = reader.data_size
    if len(reader.original) >= (reader.start + size) and not reader.shared:
        if size > reader.data_size:
            reader.data_size = size
        return
    newData = allocate_memory(size * 3, &buf)
    memcpy(buf, reader.buffer, reader.data_size)
    reader.original = newData
    reader.buffer = <unsigned char *>buf
    reader.data_size = size
    reader.start = 0
    reader.shared = False

cdef inline void ensure_write_size(ByteReader reader, size_t size):
    ensure_size(reader, reader.pos + size)

cimport cython

@cython.final
cdef class ByteReader:
    def __cinit__(self, input = None, start = None, size = None):
        self.pos = 0
        if isinstance(input, file):
            IF not IS_PYPY:
                self.fp = PyFile_AsFile(input)
            self.python_fp = input
            self.shared = False
            self.start = 0
            return
        else:
            self.python_fp = None
            if input is not None:
                data = input
            else:
                data = ''
        cdef bint isChild = start is not None and size is not None
        self.shared = isChild
        self.original = data
        cdef unsigned char * c_data
        c_data = data
        cdef int int_start
        if isChild:
            int_start = start
            self.start = int_start
            c_data += int_start
        if isChild:
            self.data_size = size
        else:
            self.data_size = len(data)

        self.buffer = c_data

    cpdef int tell(self):
        IF IS_PYPY:
            if self.python_fp:
                return self.python_fp.tell()
        ELSE:
            if self.fp != NULL:
                return ftell(self.fp)

        return self.pos

    cpdef data(self):
        cdef int pos
        IF IS_PYPY:
            if self.python_fp:
                pos = self.tell()
                self.seek(0)
                data = self.read()
                self.seek(pos)
                return data
        ELSE:
            if self.fp != NULL:
                pos = self.tell()
                self.seek(0)
                data = self.read()
                self.seek(pos)
                return data

        return self.buffer[0:self.data_size]

    cpdef bint seek(self, int pos, int mode = 0):
        IF IS_PYPY:
            if self.python_fp:
                self.python_fp.seek(pos, mode)
                return True
        ELSE:
            if self.fp != NULL:
                fseek(self.fp, pos, mode)
                return True

        if mode == 2:
            pos += self.data_size
        elif mode == 1:
            pos += self.pos
        if pos > self.data_size:
            pos = self.data_size
        if pos < 0:
            pos = 0
        self.pos = pos
        return True

    cpdef adjust(self, int to):
        cdef int value = to - (self.tell() % to)

        IF IS_PYPY:
            if self.python_fp:
                self.seek(self.tell() + value)
                return
        ELSE:
            if self.fp != NULL:
                self.seek(self.tell() + value)
                return

        self.pos += value

    cdef bint _read(self, void * value, int size) except False:
        cdef char * data_c
        cdef size_t read_bytes
        IF IS_PYPY:
            if self.python_fp:
                data = self.python_fp.read(size)
                if len(data) < size:
                    raise struct.error('%s bytes required' % size)
                data_c = data
                memcpy(value, data_c, len(data))
                return True
        ELSE:
            if self.fp != NULL:
                read_bytes = fread(value, 1, size, self.fp)
                if read_bytes < size:
                    raise struct.error('%s bytes required' % size)
                return True

        check_available(self, size)
        memcpy(value, (self.buffer + self.pos), size)
        self.pos += size
        return True

    cpdef read(self, int size = -1):
        cdef char * buf
        cdef size_t read_bytes

        IF IS_PYPY:
            if self.python_fp:
                if size == -1:
                    size = self.size() - self.tell()
                return self.python_fp.read(size)
        ELSE:
            if self.fp != NULL:
                if size == -1:
                    size = self.size() - self.tell()
                newData = allocate_memory(size, &buf)
                read_bytes = fread(buf, 1, size, self.fp)
                return newData

        if size == -1 or size + self.pos > self.data_size:
            size = self.data_size - self.pos
        if size < 0:
            size = 0
        data = self.buffer[self.pos:self.pos+size]
        self.pos += size
        if self.pos > self.data_size:
            self.pos = self.data_size
        return data

    cpdef size_t size(self):
        cdef int pos
        cdef int size

        IF IS_PYPY:
            if self.python_fp:
                pos = self.tell()
                self.seek(0, 2)
                size = self.tell()
                self.seek(pos)
                return size
        ELSE:
            if self.fp != NULL:
                pos = self.tell()
                self.seek(0, 2)
                size = self.tell()
                self.seek(pos)
                return size
        
        return self.data_size

    def __len__(self):
        return self.size()

    def __str__(self):
        return self.data()

    def __repr__(self):
        return repr(str(self))

    cpdef short readByte(self, bint asUnsigned = False) except? -10:
        cdef char value
        self._read(&value, 1)
        if asUnsigned:
            return <unsigned char>value
        return value

    cpdef int readShort(self, bint asUnsigned = False) except? -10:
        cdef short value
        cdef unsigned char byte1, byte2
        self._read(&byte1, 1)
        self._read(&byte2, 1)
        value = (byte2 << 8) | byte1
        if asUnsigned:
            return <unsigned short>value
        return value

    cpdef float readFloat(self) except? -10:
        cdef float value
        self._read(&value, 4)
        return value

    cpdef double readDouble(self) except? -10:
        cdef double value
        self._read(&value, 8)
        return value

    cpdef readInt(self, bint asUnsigned = False):
        cdef int value
        cdef unsigned char byte1, byte2, byte3, byte4
        self._read(&byte1, 1)
        self._read(&byte2, 1)
        self._read(&byte3, 1)
        self._read(&byte4, 1)
        value = ((byte4 << 24) | (byte3 << 16) | (byte2 << 8) | byte1)
        if asUnsigned:
            return <unsigned int>value
        return value

    cpdef bytes readString(self, size=None):
        if size is not None:
            return self.readReader(size).readString()
        data = ''
        while 1:
            c = self.read(1)
            if c in ('\x00', ''):
                break
            data += c
        return data

    cpdef unicode readUnicodeString(self, size=None):
        if size is not None:
            return self.readReader(size*2).readUnicodeString()

        cdef int currentPosition = self.tell()
        cdef int endPosition
        data = ''
        while 1:
            endPosition = self.tell()
            c = self.read(2)
            if len(c) != 2:
                break
            if c == '\x00\x00':
                break
            data += c

        return data.decode('utf-16-le')

    cpdef tuple readColor(self):
        cdef int currentPosition = self.tell()
        cdef short r = self.readByte(True)
        cdef short g = self.readByte(True)
        cdef short b = self.readByte(True)
        self.skipBytes(1)
        return (r, g, b)

    cpdef ByteReader readReader(self, size_t size):
        cdef ByteReader reader

        IF IS_PYPY:
            if self.python_fp:
                data = self.read(size)
                reader = ByteReader(data, 0, len(data))
                return reader
        ELSE:
            if self.fp != NULL:
                data = self.read(size)
                reader = ByteReader(data, 0, len(data))
                return reader

        check_available(self, size)
        self.shared = True
        reader = ByteReader(self.original, self.pos + self.start, size)
        self.pos += size
        return reader

    def readIntString(self):
        cdef size_t length = self.readInt(True)
        return self.read(length)

    cpdef bint write(self, bytes data):
        cdef size_t size = len(data)
        cdef char * c_data
        if size == 0:
            return False

        IF IS_PYPY:
            if self.python_fp:
                self.python_fp.write(data)
                return True
        ELSE:
            if self.fp != NULL:
                fwrite(<char *>data, 1, size, self.fp)
                return True

        ensure_write_size(self, size)
        c_data = data
        memcpy((self.buffer + self.pos), c_data, size)
        self.pos += size
        return True

    cpdef bint write_size(self, char * data, size_t size):
        if size == 0:
            return False

        IF IS_PYPY:
            if self.python_fp:
                self.python_fp.write(buffer(data, 0, size))
                return True
        ELSE:
            if self.fp != NULL:
                fwrite(data, 1, size, self.fp)
                return True

        ensure_write_size(self, size)
        memcpy(<void *>(self.buffer + self.pos), <void *>data, size)
        self.pos += size
        return True

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

    def writeString(self, value, size_t size = -1):
        cdef unsigned int currentPosition
        if size == -1:
            self.write(value + "\x00")
        else:
            for i in range(size):
                self.writeByte(0)
            currentPosition = self.tell()
            self.rewind(size)
            self.write(value[:size-1])
            self.seek(currentPosition)

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

    def writeIntString(self, value):
        self.writeInt(len(value), True)
        self.write(value)

    cpdef bint skipBytes(self, size_t n):
        self.seek(n, 1)

    cpdef bint rewind(self, size_t n):
        self.seek(-n, 1)

    def truncate(self, value):
        self.buffer.truncate(value)

    def checkDefault(self, value, *defaults):
        return checkDefault(self, value, *defaults)

    def openEditor(self):
        cdef object name
        if self.python_fp:
            name = self.python_fp.name
        else:
            fp = tempfile.NamedTemporaryFile('wb', delete = False)
            fp.write(self.data())
            fp.close()
            name = fp.name

        try:
            raw_input('Press enter to open hex editor...')
            openEditor(name, self.tell())
        except IOError:
            pass
        raw_input('(enter)')

def openEditor(filename, position):
    return subprocess.Popen(['010editor', '%s@%s' % (filename, position)])

def checkDefault(ByteReader reader, value, *defaults):
    if value in defaults:
        return False
    cdef int lastPosition = reader.lastPosition
    cdef size_t size = reader.tell() - lastPosition
    reprDefaults = defaults
    if len(defaults) == 1:
        reprDefaults, = defaults
    cdef str message = ('unimplemented value at %s, size %s (should be '
        '%s but was %s)' % (lastPosition, size, reprDefaults, value))
    traceback.print_stack(file=sys.stdout)
    # print message
    if sys.stdin.isatty():
        reader.openEditor()
    raise SystemExit