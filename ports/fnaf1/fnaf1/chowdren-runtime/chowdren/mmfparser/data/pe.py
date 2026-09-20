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

"""
With help from http://article.gmane.org/gmane.comp.python.ctypes/432

Converted to mmfparser-esque style
"""

from mmfparser.bytereader import ByteReader
from mmfparser.loader import DataLoader
from mmfparser.exceptions import InvalidData

def findAppendedOffset(reader):
    """
    I personally hope I don't have to revisit this function
    """
    if reader.read(2) != 'MZ':
        raise InvalidData('invalid executable signature')
    reader.seek(60)

    hdr_ofs = reader.readInt(True)

    reader.seek(hdr_ofs)
    if reader.read(4) != 'PE\x00\x00':
        raise InvalidData('invalid PE signature')

    # COFF header
    reader.skipBytes(2)
    numberOfSections = reader.readShort(True)
    reader.skipBytes(16)

    # seek to first section table entry
    optional_header = 28 + 68
    data_dir = 16 * 8
    reader.skipBytes(optional_header + data_dir)

    pos = None

    for i in xrange(numberOfSections):
        start = reader.tell()
        name = reader.readString()
        if name == '.extra':
            reader.seek(start+16+4)
            pos = reader.readInt(True) # pointerToRawData
            break
        elif i >= numberOfSections - 1:
            reader.seek(start+16)
            size = reader.readInt(True) # sizeOfRawData
            addr = reader.readInt(True) # pointerToRawData
            pos = addr + size
            break
        reader.seek(start+40)
    reader.seek(pos)
    return reader.tell()