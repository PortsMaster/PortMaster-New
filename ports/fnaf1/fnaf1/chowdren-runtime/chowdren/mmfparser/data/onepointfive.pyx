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

from mmfparser.bytereader cimport ByteReader
from mmfparser.common cimport allocate_memory
from libc.stdlib cimport malloc, free

cdef extern from "tinflate.c":
    void tinf_init()
    int tinf_uncompress(void *dest, unsigned int *destLen,
        void *source, unsigned int sourceLen)

tinf_init()

cdef char * buffer = NULL

def decompress_single(ByteReader reader):
    cdef unsigned int buffer_size = 1024 * 1024 * 10
    global buffer
    if buffer == NULL:
        buffer = <char*>malloc(buffer_size) # allocate 10 mb
    cdef int start = reader.tell()
    data = reader.read()
    cdef int bytesread = tinf_uncompress(<void *>buffer, &buffer_size,
        <void *>(<char *>data), len(data))
    reader.seek(start + bytesread)
    return ByteReader(buffer[:buffer_size])

def decompress(ByteReader reader):
    cdef unsigned int decompressed_size = reader.readInt(True)
    cdef unsigned int saved_size = decompressed_size
    cdef char * buf
    cdef int start = reader.tell()
    data = reader.read()
    new_data = allocate_memory(decompressed_size, &buf)
    cdef int bytesread = tinf_uncompress(<void *>buf, &decompressed_size,
        <void *>(<char *>data), len(data))
    reader.seek(start + bytesread)
    if decompressed_size != saved_size:
        raise Exception('decompression failed (%s, %s)' % (saved_size,
            decompressed_size))
    return ByteReader(new_data)
