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
animPicture.mfx
Animated Picture - Daniel Rehn & Jonas Rehn (http://www.phizix.tk)

An object which can cache pictures at runtime and animate them.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Cahce->Cache Tileset

    Parameters:
    0: File to Cahce (FILENAME, Filename)
    1: Identifier (EXPSTRING, ExpressionParameter)
    2: Tile Width (EXPRESSION, ExpressionParameter)
    3: Tile Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action1(Action):
    """
    Cahce->Remove Image from Cache

    Parameters:
    0: Identifier (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action2(Action):
    """
    Scale and Rotation->Set Rotoscale State

    Parameters:
    0: State (1=Enabled, 0=Disabled) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action3(Action):
    """
    Scale and Rotation->Set Angle

    Parameters:
    0: Angle (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Scale and Rotation->Set Scale

    Parameters:
    0: Scale (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action5(Action):
    """
    Scale and Rotation->Set X-Scale

    Parameters:
    0: Scale (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action6(Action):
    """
    Scale and Rotation->Set Y-Scale

    Parameters:
    0: Scale (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Hotspot->Set Hotspot

    Parameters:
    0: Hotspot X (EXPRESSION, ExpressionParameter)
    1: Hotspot Y (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    """
    Hotspot->Set Hotspot X

    Parameters:
    0: Hotspot X (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Hotspot->Set Hotspot Y

    Parameters:
    0: Hotspot Y (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action10(Action):
    """
    Cahce->Cache Image from Alphachannel and Color

    Parameters:
    0: File to Cahce (FILENAME, Filename)
    1: Identifier (EXPSTRING, ExpressionParameter)
    2: Color (COLOUR, Colour)
    3: Inverse Alpha (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action11(Action):
    """
    Cahce->Cache Image

    Parameters:
    0: File to Cahce (FILENAME, Filename)
    1: Identifier (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    """
    Cahce->Cache Tileset from Alphachannel and Color

    Parameters:
    0: File to Cahce (FILENAME, Filename)
    1: Identifier (EXPSTRING, ExpressionParameter)
    2: Tile Width (EXPRESSION, ExpressionParameter)
    3: Tile Height (EXPRESSION, ExpressionParameter)
    4: Color (COLOUR, Colour)
    5: Inverse Alpha (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    """
    Animation->Set Image

    Parameters:
    0: Identifier (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action14(Action):
    """
    Animation->Set Tile

    Parameters:
    0: Tile ID in Tileset (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action15(Action):
    """
    Animation->Animate

    Parameters:
    0: First Tile (EXPRESSION, ExpressionParameter)
    1: Last Tile (EXPRESSION, ExpressionParameter)
    2: Loop Back to (EXPRESSION, ExpressionParameter)
    3: Speed (EXPRESSION, ExpressionParameter)
    4: Loop (0=Infinity) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action16(Action):
    """
    Animation->Pause Animation
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action17(Action):
    """
    Animation->Resume Animation
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action18(Action):
    """
    Cahce->Set Color of Cache

    Parameters:
    0: Identifier (EXPSTRING, ExpressionParameter)
    1: Color (COLOUR, Colour)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action19(Action):
    """
    Hotspot->Center Hotspot on Object
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action20(Action):
    """
    Cahce->Clear Cache
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action21(Action):
    """
    Cahce->Cache Image from Overlay

    Parameters:
    0: Overlay Adress (EXPRESSION, ExpressionParameter)
    1: Identifier (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action22(Action):
    """
    Cahce->Cache Tileset from Overlay

    Parameters:
    0: Overlay Adress (EXPRESSION, ExpressionParameter)
    1: Identifier (EXPSTRING, ExpressionParameter)
    2: Tile Width (EXPRESSION, ExpressionParameter)
    3: Tile Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Identifier Exists in Cache?

    Parameters:
    0: Identifier (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Is Animation Playing?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Animation->Get Current Image
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Animation->Get Current Tile
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression2(Expression):
    """
    Hotspot->Get Hotspot X
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Hotspot->Get Hotspot Y
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Scale and Rotation->Get Rotoscale State
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Scale and Rotation->Get Angle
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Scale and Rotation->Get X-Scale
    Return type: Float
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Scale and Rotation->Get Y-Scale
    Return type: Float
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    """
    Size->Get Original Width
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    Size->Get Original Height
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


class DefaultObject(HiddenObject):
    def created(self):
        # you should probably make your object ready here.
        # data is your property data
        pass

class animPicture(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        3 : Action2,
        4 : Action3,
        5 : Action4,
        6 : Action5,
        7 : Action6,
        8 : Action7,
        9 : Action8,
        10 : Action9,
        11 : Action10,
        12 : Action11,
        13 : Action12,
        14 : Action13,
        15 : Action14,
        16 : Action15,
        17 : Action16,
        18 : Action17,
        19 : Action18,
        20 : Action19,
        21 : Action20,
        22 : Action21,
        23 : Action22,
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
        7 : Expression7,
        8 : Expression8,
        9 : Expression9,
    }

extension = animPicture()

def get_extension():
    return extension
