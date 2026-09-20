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

from mmfparser.keyconvert import getKeyText

class Key(object):
    value = None
    
    def __init__(self, value = None):
        self.value = value
        
    def getName(self):
        return getKeyText(self.value)
    
    def getValue(self):
        return self.value
    
    def setValue(self, input):
        self.value = input
    
    def __repr__(self):
        return self.getName()