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
kccda.mfx
CD Audio object - ClickTeam (http://www.clickteam.com)

Lets you play compact disc audio tracks.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Play a track and continue

    Parameters:
    0: Play a track and continue (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action1(Action):
    """
    Stop
    """

    def execute(self, instance):
        pass

class Action2(Action):
    """
    Pause
    """

    def execute(self, instance):
        pass

class Action3(Action):
    """
    Resume
    """

    def execute(self, instance):
        pass

class Action4(Action):
    """
    Previous track
    """

    def execute(self, instance):
        pass

class Action5(Action):
    """
    Next track
    """

    def execute(self, instance):
        pass

class Action6(Action):
    """
    Play at position

    Parameters:
    0: Play at position (TIME, Time)
    """

    def execute(self, instance):
        pass

class Action7(Action):
    """
    Open door
    """

    def execute(self, instance):
        pass

class Action8(Action):
    """
    Close door
    """

    def execute(self, instance):
        pass

class Action9(Action):
    """
    Play a track

    Parameters:
    0: Play a track (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass


# Conditions

class Condition0(Condition):
    """
    Compare to track's elapsed time

    Parameters:
    0: Compare to track's elapsed time (CMPTIME, CompareTime)
    """

    def check(self, instance):
        pass

class Condition1(Condition):
    """
    Compare to time position

    Parameters:
    0: Compare to time position (CMPTIME, CompareTime)
    """

    def check(self, instance):
        pass


# Expressions

class Expression0(Expression):
    """
    Number of current track
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression1(Expression):
    """
    Number of tracks
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression2(Expression):
    """
    Position in current track (1/1000s)
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression3(Expression):
    """
    Length of current track (1/1000s)
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression4(Expression):
    """
    Position in disk (1/1000s)
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression5(Expression):
    """
    Length of disk (1/1000s)
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression6(Expression):
    """
    Last error number
    Return type: Int
    """

    def get(self, instance):
        pass


class DefaultObject(HiddenObject):
    def created(self, data):
        # you should probably make your object ready here.
        # data is your property data
        pass

class kccda(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        6 : Expression6,
    }

extension = kccda()

def get_extension():
    return extension
