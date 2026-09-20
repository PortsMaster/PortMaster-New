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

from mmfparser.player.common import PlayerChild
from mmfparser.player.temp import NamedTemporaryFile

class FileManager(PlayerChild):
    openBinaries = None
    def initialize(self):
        self.openBinaries = {}
    
    def get_binary_file(self, name, open = True):
        files = self.player.gameData.files
        name = name.lower()
        if files is None:
            return
        if name in self.openBinaries:
            return self.openBinaries[name]
        for item in files.items:
            if item.name.lower() == name:
                if not open:
                    return None
                newFile = NamedTemporaryFile()
                newFile.write(str(item.data))
                newFile.flush()
                newFile.seek(0)
                self.openBinaries[name] = newFile
                return newFile
        return None
    
    def release_binary_file(self, name):
        item = self.get_binary_file(name, False)
        if item is None:
            return
        item.close()
        del self.openBinaries[name.lower()]