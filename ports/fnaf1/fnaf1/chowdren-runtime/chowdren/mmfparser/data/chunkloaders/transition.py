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
from mmfparser.bitdict import BitDict

class Transition(DataLoader):
    module = None
    name = None
    duration = None # in ms
    flags = None
    color = None
    moduleFile = None
    parameterData = None
    def initialize(self):
        self.flags = BitDict('Color')
        
    def read(self, reader):
        currentPosition = reader.tell()
        self.module = reader.read(4)
        self.name = reader.read(4)
        self.duration = reader.readInt()
        self.flags.setFlags(reader.readInt(True))
        self.color = reader.readColor()
        nameOffset = reader.readInt()
        parameterOffset = reader.readInt()
        parameterSize = reader.readInt()
        reader.seek(currentPosition + nameOffset)
        self.moduleFile = reader.readString()
        reader.seek(currentPosition + parameterOffset)
        self.parameterData = reader.read(parameterSize)
    
    def isStandard(self):
        return self.name == 'STDT'

class FadeIn(Transition):
    fadeIn = True

class FadeOut(Transition):
    fadeIn = False

__all__ = ['FadeIn', 'FadeOut']