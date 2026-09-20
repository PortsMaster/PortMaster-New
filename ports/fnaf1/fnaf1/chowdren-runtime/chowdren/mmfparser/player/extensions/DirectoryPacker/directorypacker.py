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
from mmfparser.exceptions import InvalidData
from mmfparser.bytereader import ByteReader

import os

MAGIC = 'NF'

class File(DataLoader):
    path = None
    data = None

    def read(self, reader):
        header = reader.read(2)
        if header != MAGIC:
            raise InvalidData('invalid file header (%r)' % header)
        self.path = reader.readString()
        self.data = reader.read(reader.readInt(True))
    
    def write(self, reader):
        reader.write(MAGIC)
        reader.writeString(self.path)
        reader.writeInt(len(self.data), True)
        reader.write(self.data)

class DirectoryPacker(DataLoader):
    items = None
    root = None

    def initialize(self):
        self.items = []

    def read(self, reader):
        if reader.read(2) != MAGIC:
            raise InvalidData('invalid file header')
        self.root = reader.readString()
        reader.skipBytes(4) # badly coded, Jamie!
        size = len(reader)
        self.items = items = []
        while reader.tell() < size:
            item = self.new(File, reader)
            items.append(item)
    
    def write(self, reader):
        reader.write(MAGIC)
        reader.writeString(self.root)
        reader.writeInt(len(self.items))
        for item in self.items:
            item.write(reader)
    
    def unpack(self, path):
        root = os.path.join(path, self.root)
        if not os.path.exists(root):
            os.makedirs(root)
        for file in self.items:
            directory = os.path.join(root, os.path.dirname(file.path))
            filename = os.path.basename(file.path)
            path = os.path.join(root, file.path)
            if not os.path.exists(directory):
                os.makedirs(directory)
            open(path, 'wb').write(file.data)
    
    def pack(self, path, include = None, exclude = None):
        self.items = items = []
        self.root = os.path.split(path)[1]
        for root, dirs, files in os.walk(path):
            currentDir = os.path.relpath(root, path)
            for file in files:
                if include is not None:
                    if os.path.splitext(file)[1][1:] not in include:
                        continue
                elif exclude is not None:
                    if os.path.splitext(file)[1][1:] in exclude:
                        continue
                newFile = self.new(File)
                items.append(newFile)
                newFile.path = os.path.normpath(os.path.join(currentDir, file))
                newFile.data = open(os.path.join(root, file), 'rb').read()

if __name__ == '__main__':
    reader = ByteReader(open('Template.bin', 'rb'))
    files = DirectoryPacker(reader)
    files.unpack('./Wee')
    files.pack('./Wee/' + files.root, exclude = 'bin')