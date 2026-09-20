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

from mmfparser.data.checksum import Checksum

class Protection(DataLoader):
    checksum = None
    def read(self, reader):
        self.checksum = reader.readInt(True)
        
    def compareData(self, data):
        realChecksum = Checksum(data).getChecksum()
        return realChecksum == self.checksum
        
    def setData(self, data):
        self.checksum = Checksum(data).getChecksum()
        
    def write(self, reader):
        reader.writeInt(self.checksum, True)

__all__ = ['Protection']