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

"""
KcRuntime.mfx
Runtime object - James McLaughlin (http://www.clickteam.com)
Copyright (C) 2011 James McLaughlin

Detects which runtime the application is running on

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import (TrueCondition, 
    FalseCondition)
from mmfparser.player.event.expressions.common import Expression

# Expressions

class GetName(Expression):
    def get(self, instance):
        return 'Anaconda'

class DefaultObject(HiddenObject):
    def created(self, data):
        pass

class KcRuntime(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
    }
    
    conditions = {
        0 : TrueCondition,
        1 : FalseCondition,
        2 : FalseCondition,
        3 : FalseCondition,
        4 : FalseCondition,
        5 : FalseCondition,
        6 : FalseCondition,
        7 : FalseCondition,
        8 : FalseCondition,
        9 : FalseCondition
    }
    
    expressions = {
        0 : GetName
    }

extension = KcRuntime()

def get_extension():
    return extension
