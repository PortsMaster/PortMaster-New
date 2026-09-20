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
from mmfparser.bytereader import ByteReader
from mmfparser.data.packdata import PackData, PACK_HEADER
from mmfparser.data.gamedata import GameData, GAME_HEADER
from mmfparser.data.chunk import ChunkList
from mmfparser.data.pe import findAppendedOffset

class ExecutableData(DataLoader):
    executable = None
    packData = None
    gameData = None
    def read(self, reader):
        entryPoint = findAppendedOffset(reader)
        reader.seek(0)
        self.executable = reader.read(entryPoint)
        
        firstShort = reader.readShort()
        reader.rewind(2)
        
        pameMagic = reader.read(4)
        reader.rewind(4)
        
        packMagic = reader.read(8)
        reader.rewind(8)
        
        if firstShort == 8748:
            self.settings['old'] = True
            packData = self.new(ChunkList, reader)
        elif packMagic == PACK_HEADER:
            packData = self.new(PackData, reader)
        elif pameMagic == GAME_HEADER:
            self.settings['old'] = True
            self.gameData = self.new(GameData, reader)
            return
        else:
            raise Exception('invalid packheader')
        self.packData = packData
        self.gameData = self.new(GameData, reader)
        
    def write(self, reader):
        reader.write(self.executable)
        self.packData.write(reader)
        self.gameData.write(reader)