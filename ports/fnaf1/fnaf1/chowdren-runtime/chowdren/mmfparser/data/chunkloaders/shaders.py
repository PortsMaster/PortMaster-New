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

class Parameter(object):
    name = None
    type = None
    value = None
    
    def copy(self):
        parameter = Parameter()
        parameter.name = self.name
        parameter.type = self.type
        parameter.value = self.value
        return parameter

INT, FLOAT, INT_FLOAT4, IMAGE = xrange(4)

class Shader(DataLoader):
    name = None
    data = None
    parameters = None

    def read(self, reader):
        currentPosition = reader.tell()
        nameOffset = reader.readInt()
        dataOffset = reader.readInt()
        parameterOffset = reader.readInt()
        backgroundTexture = reader.readInt()
        reader.seek(currentPosition + nameOffset)
        self.name = reader.readString()
        reader.seek(currentPosition + dataOffset)
        self.data = reader.readString()
        if parameterOffset != 0:
            parameterOffset += currentPosition
            reader.seek(parameterOffset)
            parameterCount = reader.readInt()
            self.parameters = parameters = [Parameter() 
                for _ in xrange(parameterCount)]
            typeOffset = reader.readInt()
            namesOffset = reader.readInt()
            reader.seek(parameterOffset + typeOffset)
            for parameter in parameters:
                parameter.type = reader.readByte()
            reader.seek(parameterOffset + namesOffset)
            for parameter in parameters:
                parameter.name = reader.readString()
    
    def get_parameters(self):
        if not self.parameters:
            return {}
        return dict([(parameter.name, parameter.copy()) 
            for parameter in self.parameters])

class Shaders(DataLoader):
    def initialize(self):
        self.items = []
        self.names = {}

    def read(self, reader):
        currentPosition = reader.tell()
        count = reader.readInt()
        offsets = []
        for _ in xrange(count):
            offsets.append(reader.readInt())
        
        for offset in offsets:
            reader.seek(currentPosition + offset)
            shader = self.new(Shader, reader)
            self.items.append(shader)
            self.names[shader.name] = shader
        
    def write(self, reader):
        pass

__all__ = ['Shaders']