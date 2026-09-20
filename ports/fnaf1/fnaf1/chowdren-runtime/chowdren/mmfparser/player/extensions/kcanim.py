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
kcanim.mfx
Animation object - ClickTeam (http://www.clickteam.com)

Plays animation files (FLI, GIF, AVI).

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Animation->Start

    Parameters:
    0: MF2 (OBJECT, Object)
    """

    def execute(self, instance):
        return
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action1(Action):
    """
    Animation->Stop

    Parameters:
    0: Animation (TIME, Time)
    """

    def execute(self, instance):
        return
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action2(Action):
    """
    Animation->Pause

    Parameters:
    0:  (SHORT, Short)
    """

    def execute(self, instance):
        return

class Action3(Action):
    """
    Animation->Resume

    Parameters:
    0:  (SHORT, Short)
    """

    def execute(self, instance):
        return

class Action4(Action):
    """
    Animation->Change frame duration

    Parameters:
    0: Change frame duration (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class MakeInvisible(Action):
    def execute(self, instance):
        instance.visible = False

class Action5(Action):
    """
    Animation->Go to frame...

    Parameters:
    0: Go to frame... (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        return

class Action6(Action):
    """
    Animation->Next frame

    Parameters:
    0:  (CREATE, Create)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Animation->Previous frame

    Parameters:
    0:  (SHORT, Short)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    """
    Animation->New file

    Parameters:
    0: New file (OBJECT, Object)
    1:  (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Animation->New file from selector
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Compare to current frame

    Parameters:
    0: Compare to current frame (OBJECT, Object)
    1: MF2 (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        return False

class Condition1(Condition):
    """
    End of animation?

    Parameters:
    0: Animation (TIME, Time)
    """

    def check(self, instance):
        return True

class Condition2(Condition):
    """
    Is the animation running?

    Parameters:
    0:  (SHORT, Short)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition3(Condition):
    """
    Is the animation paused?

    Parameters:
    0:  (SHORT, Short)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Number of current frame

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Number of frames

    Parameters:
    0: (not found) (Global)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression2(Expression):
    """
    Width of animation

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Height of animation

    Parameters:
    0: (not found) (AlterableValue)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Frame duration
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


class DefaultObject(HiddenObject):
    def created(self, data):
        # you should probably make your object ready here.
        # data is your property data
        pass

class kcanim(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : MakeInvisible,
        7 : Action5,
        8 : Action6,
        9 : Action7,
        10 : Action8,
        11 : Action9,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
    }

extension = kcanim()

def get_extension():
    return extension
