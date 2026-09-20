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

# basically, offsets are pointers to zlibdata-compressed data

class _OffsetCommon(DataLoader):
    items = None
    
    def initialize(self):
        self.items = []
    
    def read(self, reader):
        self.items = [reader.readInt(True)
            for _ in xrange(len(reader) / 4)]
    
    def write(self, reader):
        try:
            for item in self.settings['bank'].offsets:
                reader.writeInt(item)
        except (KeyError, TypeError):
            for item in self.items:
                reader.writeInt(item, True)

class ImageOffsets(_OffsetCommon):
    pass

class FontOffsets(_OffsetCommon):
    pass

class SoundOffsets(_OffsetCommon):
    pass

class MusicOffsets(_OffsetCommon):
    pass

__all__ = ['ImageOffsets', 'FontOffsets', 'SoundOffsets', 'MusicOffsets']