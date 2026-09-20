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
from mmfparser.loader import DataLoader

class SecNum(DataLoader):
    tickCount = None
    serialSlice = None
    def read(self, reader):
        eax = reader.readInt()
        ecx = reader.readInt()
        
        tickCount = eax ^ 0xBD75329
        
        serialSlice = ecx + eax
        serialSlice ^= 0xF75A3F
        serialSlice ^= eax
        serialSlice -= 10
        
        self.tickCount = tickCount
        self.serialSlice = serialSlice
    
    def write(self, reader):
        # heh, we don't want people to see our stuff, do we? :)
        reader.writeInt(0)
        reader.writeInt(0)

__all__ = ['SecNum']