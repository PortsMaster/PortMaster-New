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

import struct

def wrap(value):
    return value & 0xFFFFFFFF

def wrap_signed_char(value):
    value = value & 0xFF
    if value > 127:
        value -= 256
    return value

def make_checksum(data):
    result = 0
    bufferOffset = 0
    numberOfBytes = len(data)
    numberOfReads = numberOfBytes >> 2
    for _ in xrange(numberOfReads):
        newInt, = struct.unpack_from('<I', data, bufferOffset)
        result = newInt + (wrap(result) >> 31) + 2 * result
        result = wrap(result)
        bufferOffset += 4
    for _ in xrange(numberOfBytes & 3):
        v7 = (wrap(result) >> 31) + struct.unpack_from('<B', data, bufferOffset)[0]
        bufferOffset += 1
        result = wrap(v7 + 2*result)
    return wrap(result)

GROUP_WORDS = list('mqojhm:qskjhdsmkjsmkdjhq\x63clkcdhdlkjhd')

def make_group_checksum(password, group_name):
    v4 = 57
    for c in group_name:
        v4 += ord(c) ^ 0x7F
    v5 = 0
    for c in password:
        v4 += wrap_signed_char(ord(GROUP_WORDS[v5]) + (ord(c) ^ 0xC3)) ^ 0xF3
        v5 += 1
        if v5 > len(GROUP_WORDS):
            v5 = 0
    return v4
    
def make_pame_checksum(data):
    checksum = make_checksum(data)
    lastByte = checksum & 0x000000FF # get last byte
    xorByte = lastByte ^ 13
    checksum = checksum & 0xFFFFFF00 | xorByte
    return int(checksum)

class Checksum(object):
    data = None
    def __init__(self, data = None):
        if data:
            self.data = data
            
    def getChecksum(self):
        return make_pame_checksum(self.data)

if __name__ == '__main__':
    print hex(make_group_checksum('klonoafan', 'yay'))