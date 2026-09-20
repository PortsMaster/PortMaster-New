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
kcfocus.mfx
Window Focus Object - Marcello Bastea-Forte, Cellosoft (http://www.cellosoft.com/)
Copyright 1999 Cellosoft

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Flash Window on Task Bar
    """

    def execute(self, instance):
        self.player.window.activate()

# Conditions

class Condition0(Condition):
    """
    Window has Focus
    """

    def check(self, instance):
        return self.player.focus

# Expressions


class DefaultObject(HiddenObject):
    def created(self, data):
        # you should probably make your object ready here.
        # data is your property data
        pass

class kcfocus(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
    }
    
    conditions = {
        0 : Condition0,
    }
    
    expressions = {
    }

extension = kcfocus()

def get_extension():
    return extension
