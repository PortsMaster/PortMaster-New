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

class Workspace(DataLoader):
    name = ''
    data = None
    
    def initialize(self):
        size = self.settings.get('defaultSize', 0)
        self.data = ByteReader()
        self.data.write('\x00' * size)
    
    def read(self, reader):
        self.name = reader.readString()
        self.data = reader.readReader(reader.readInt(True))
    
    def write(self, reader):
        reader.writeString(self.name)
        reader.writeInt(len(self.data))
        reader.writeReader(self.data)

class WorkspaceArray(DataLoader):
    items = None
    
    def initialize(self):
        self.items = []
    
    def read(self, reader):
        while reader.tell() < len(reader):
            workspace = self.new(Workspace, reader)
            self.items.append(workspace)
        
    def write(self, reader):
        for item in self.items:
            item.write(reader)
    
    def getWorkspace(self, name):
        item, = [item for item in self.items if item.name == name]
        return item
    
    def createWorkspace(self, name, defaultSize):
        try:
            return self.getWorkspace(name)
        except ValueError:
            workspace = self.new(Workspace, defaultSize = defaultSize)
            workspace.name = name
            return workspace