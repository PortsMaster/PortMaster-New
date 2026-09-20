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
CharImage.mfx
Character Image - Greyhill

Allows you to draw text using a different image for each character.
Supports alpha channels.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set Text...

    Parameters:
    0: Enter Text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action1(Action):
    """
    Set Unformatted Text...

    Parameters:
    0: Enter Unformatted Text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action2(Action):
    """
    Set Page Width...

    Parameters:
    0: Enter Width (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action3(Action):
    """
    Set Page Height...

    Parameters:
    0: Enter Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action4(Action):
    """
    Line breaks at RC/LF->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action5(Action):
    """
    Line breaks at RC/LF->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action6(Action):
    """
    Line breaks at RC/LF->Set

    Parameters:
    0: Set Line breaks at RC/LF (0 = Off, 1 = On) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action7(Action):
    """
    Word Wrap->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action8(Action):
    """
    Word Wrap->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action9(Action):
    """
    Word Wrap->Set

    Parameters:
    0: Set Word Wrap (0 = Off, 1 = On) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action10(Action):
    """
    Set Available Characters...

    Parameters:
    0: Enter Available Characters (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action11(Action):
    """
    Add Available Char...

    Parameters:
    0: Enter Available Char (ASCII Value) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action12(Action):
    """
    On Draw Changes->Set X Offset...

    Parameters:
    0: Enter X Offset (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action13(Action):
    """
    On Draw Changes->Set Y Offset...

    Parameters:
    0: Enter Y Offset (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action14(Action):
    """
    On Draw Changes->Set Alpha Channel Off of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action15(Action):
    """
    On Draw Changes->Ink Effects->Set Transparent Effect of Current Character...

    Parameters:
    0: Enter Transparency Coefficient (0 - 128) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action16(Action):
    """
    On Draw Changes->Ink Effects->Set Invert Effect of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action17(Action):
    """
    On Draw Changes->Ink Effects->Set XOr Effect of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action18(Action):
    """
    On Draw Changes->Ink Effects->Set And Effect of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action19(Action):
    """
    On Draw Changes->Ink Effects->Set Or Effect of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action20(Action):
    """
    On Draw Changes->Ink Effects->Set Mono Effect of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action21(Action):
    """
    On Draw Changes->Ink Effects->Set Add Effect of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action22(Action):
    """
    On Draw Changes->Ink Effects->Set Subtract Effect of Current Character...
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action23(Action):
    """
    Formats->Set Alias Index of Unformated Text...

    Parameters:
    0: Enter Alias Index (EXPRESSION, ExpressionParameter)
    1: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    2: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action24(Action):
    """
    Formats->Set Tracking of Unformated Text...

    Parameters:
    0: Enter Tracking (EXPRESSION, ExpressionParameter)
    1: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    2: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action25(Action):
    """
    Formats->Set Alpha Channel Off of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action26(Action):
    """
    Formats->Ink Effects->Set Transparent Effect of Unformated Text...

    Parameters:
    0: Enter Transparency Coefficient (0 - 128) (EXPRESSION, ExpressionParameter)
    1: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    2: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action27(Action):
    """
    Formats->Ink Effects->Set Invert Effect of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action28(Action):
    """
    Formats->Ink Effects->Set XOr Effect of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action29(Action):
    """
    Formats->Ink Effects->Set And Effect of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action30(Action):
    """
    Formats->Ink Effects->Set Or Effect of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action31(Action):
    """
    Formats->Ink Effects->Set Mono Effect of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action32(Action):
    """
    Formats->Ink Effects->Set Add Effect of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action33(Action):
    """
    Formats->Ink Effects->Set Subtract Effect of Unformated Text...

    Parameters:
    0: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    1: Enter Length (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action34(Action):
    """
    Formats->Set Horizontal Alignment of Unformated Text...

    Parameters:
    0: Enter Horizontal Alignment (left, centre, right, justify) (EXPSTRING, ExpressionParameter)
    1: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action35(Action):
    """
    Formats->Set Vertical Alignment of Unformated Text...

    Parameters:
    0: Enter Vertical Alignment (top, centre, bottom) (EXPSTRING, ExpressionParameter)
    1: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action36(Action):
    """
    Formats->Set Leading of Unformated Text...

    Parameters:
    0: Enter Leading (EXPRESSION, ExpressionParameter)
    1: Enter Position in Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action37(Action):
    """
    Aliases->Add Alias...

    Parameters:
    0: Enter Name of Alias (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action38(Action):
    """
    Aliases->Insert Alias...

    Parameters:
    0: Enter Name of Alias (EXPSTRING, ExpressionParameter)
    1: Insert At (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action39(Action):
    """
    Aliases->Delete Alias

    Parameters:
    0: Delete At (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action40(Action):
    """
    Aliases->Copy Alias...

    Parameters:
    0: Enter From Alias (EXPRESSION, ExpressionParameter)
    1: Enter To Alias (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action41(Action):
    """
    Aliases->By Character->Set Clipping X...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter A Character (EXPSTRING, ExpressionParameter)
    2: Enter X Clipping Coordinate (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action42(Action):
    """
    Aliases->By Character->Set Clipping Y...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter A Character (EXPSTRING, ExpressionParameter)
    2: Enter Y Clipping Coordinate (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action43(Action):
    """
    Aliases->By Character->Set Clipping Width...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter A Character (EXPSTRING, ExpressionParameter)
    2: Enter Clipping Width (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action44(Action):
    """
    Aliases->By Character->Set Clipping Height...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter A Character (EXPSTRING, ExpressionParameter)
    2: Enter Clipping Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action45(Action):
    """
    Aliases->By Character->Set Character Width...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter A Character (EXPSTRING, ExpressionParameter)
    2: Enter Character Width (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action46(Action):
    """
    Aliases->By Character->Set Character Height...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter A Character (EXPSTRING, ExpressionParameter)
    2: Enter Character Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action47(Action):
    """
    Aliases->By Character->Load Image from File...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter A Character (EXPSTRING, ExpressionParameter)
    2: Enter Image Filename (FILENAME, Filename)
    3: X Coordinate of hot spot (100000 for centre, 110000 for right) (EXPRESSION, ExpressionParameter)
    4: Y Coordinate of hot spot (100000 for centre, 110000 for bottom) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action48(Action):
    """
    Aliases->By Char->Set Clipping X...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Char (ASCII value) (EXPRESSION, ExpressionParameter)
    2: Enter X Clipping Coordinate (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action49(Action):
    """
    Aliases->By Char->Set Clipping Y...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Char (ASCII value) (EXPRESSION, ExpressionParameter)
    2: Enter Y Clipping Coordinate (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action50(Action):
    """
    Aliases->By Char->Set Clipping Width...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Char (ASCII value) (EXPRESSION, ExpressionParameter)
    2: Enter Clipping Width (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action51(Action):
    """
    Aliases->By Char->Set Clipping Height...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Char (ASCII value) (EXPRESSION, ExpressionParameter)
    2: Enter Clipping Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action52(Action):
    """
    Aliases->By Char->Set Character Width...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Char (ASCII value) (EXPRESSION, ExpressionParameter)
    2: Enter Character Width (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action53(Action):
    """
    Aliases->By Char->Set Character Height...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Char (ASCII value) (EXPRESSION, ExpressionParameter)
    2: Enter Character Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action54(Action):
    """
    Aliases->By Char->Load Image from File...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Char (ASCII value) (EXPRESSION, ExpressionParameter)
    2: Enter Image Filename (FILENAME, Filename)
    3: X Coordinate of hot spot (100000 for centre, 110000 for right) (EXPRESSION, ExpressionParameter)
    4: Y Coordinate of hot spot (100000 for centre, 110000 for bottom) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action55(Action):
    """
    Aliases->Load Basic Glyph Map from Image File...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Image Filename (FILENAME, Filename)
    2: Enter Width of each Character Image (EXPRESSION, ExpressionParameter)
    3: Enter Height of each Character Image (EXPRESSION, ExpressionParameter)
    4: X Coordinate of hot spots (100000 for centre, 110000 for right) (EXPRESSION, ExpressionParameter)
    5: Y Coordinate of hot spots (100000 for centre, 110000 for bottom) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action56(Action):
    """
    Aliases->Load Character Images from Folder...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Path of folder containing images (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action57(Action):
    """
    Set Object Width...

    Parameters:
    0: Enter Width (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action58(Action):
    """
    Set Object Height...

    Parameters:
    0: Enter Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action59(Action):
    """
    Aliases->Set Name...

    Parameters:
    0: Enter Alias (EXPRESSION, ExpressionParameter)
    1: Enter Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action60(Action):
    """
    Redraw
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action61(Action):
    """
    On Draw Changes->Set Alias Index of Current Character...

    Parameters:
    0: Enter Alias Index (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action62(Action):
    """
    On Draw Changes->Set Tracking of Current Character...

    Parameters:
    0: Enter Tracking (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action63(Action):
    """
    On Draw Changes->Set Horizontal Alignment of Current RC/LF Line...

    Parameters:
    0: Enter Horizontal Alignment (left, centre, right, justify) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action64(Action):
    """
    On Draw Changes->Set Vertical Alignment of Current RC/LF Line...

    Parameters:
    0: Enter Vertical Alignment (top, centre, bottom) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action65(Action):
    """
    On Draw Changes->Set Leading of Current Line...

    Parameters:
    0: Enter Leading (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action66(Action):
    """
    Load Text from File...

    Parameters:
    0: Enter Text File (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Conditions

class Condition0(Condition):
    """
    Line breaks at RC/LF
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition1(Condition):
    """
    Word Wraps
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition2(Condition):
    """
    Available Characters Contain

    Parameters:
    0: Enter one or more Characters (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition3(Condition):
    """
    Available Characters Contain Char...

    Parameters:
    0: Enter A Char (ASCII value) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition4(Condition):
    """
    On Draw->On Text
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition5(Condition):
    """
    On Draw->On Line
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition6(Condition):
    """
    On Draw->On Character
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition7(Condition):
    """
    Formats->Is Alpha Channel Off on Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition8(Condition):
    """
    Formats->Ink Effects->Is Transparent Effect on Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition9(Condition):
    """
    Formats->Ink Effects->Is Invert Effect on Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition10(Condition):
    """
    Formats->Ink Effects->Is XOr Effect of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition11(Condition):
    """
    Formats->Ink Effects->Is And Effect of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition12(Condition):
    """
    Formats->Ink Effects->Is Or Effect of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition13(Condition):
    """
    Formats->Ink Effects->Is Mono Effect of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition14(Condition):
    """
    Formats->Ink Effects->Is Add Effect of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition15(Condition):
    """
    Formats->Ink Effects->Is Subtract Effect of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition16(Condition):
    """
    Formats->Is Line of Character proceeded by a RC/LF on Unformatted Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Expressions

class Expression0(Expression):
    """
    Get Object Width
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression1(Expression):
    """
    Get Object Height
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression2(Expression):
    """
    Get Text
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression3(Expression):
    """
    Get Unformated Text
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression4(Expression):
    """
    Get Unformated Char At

    Parameters:
    0: Enter Char Position within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression5(Expression):
    """
    Get Unformated Length
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression6(Expression):
    """
    Get Page Width
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression7(Expression):
    """
    Get Page Height
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression8(Expression):
    """
    Get Available Characters
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression9(Expression):
    """
    Get Available Char Quantity
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression10(Expression):
    """
    Get Available Char At

    Parameters:
    0: Enter Available Char Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression11(Expression):
    """
    On Draw Changes->Get X Offset
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression12(Expression):
    """
    On Draw Changes->Get Y Offset
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression13(Expression):
    """
    On Draw Changes->Get Unformatted Current Character Index
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression14(Expression):
    """
    Drawing->Get X Coordinate of Character Image in Unformatted Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression15(Expression):
    """
    Drawing->Get Y Coordinate of Character Image in Unformatted Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression16(Expression):
    """
    Drawing->Get Hotspot Inclusive X Coordinate of Character Image in Unformatted Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression17(Expression):
    """
    Drawing->Get Hotspot Inclusive Y Coordinate of Character Image in Unformatted Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression18(Expression):
    """
    Formats->Get Alias Index of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression19(Expression):
    """
    Formats->Get Tracking of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression20(Expression):
    """
    Formats->Ink Effects->Get Transparent Coefficient of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression21(Expression):
    """
    Formats->Get Horizontal Alignment of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression22(Expression):
    """
    Formats->Get Vertical Alignment of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression23(Expression):
    """
    Formats->Get Leading of Unformated Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression24(Expression):
    """
    Aliases->Get Name of Alias

    Parameters:
    0: Enter Index of Alias (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression25(Expression):
    """
    Aliases->Get Index of Alias

    Parameters:
    0: Enter Name of Alias (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression26(Expression):
    """
    Aliases->Get Quantity of Aliases
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression27(Expression):
    """
    Formats->Get Line of Character from Unformatted Text At

    Parameters:
    0: Enter Index of Character within Unformatted Text (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression28(Expression):
    """
    Aliases->By Character->Get Clipping X

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Character (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression29(Expression):
    """
    Aliases->By Character->Get Clipping Y

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Character (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression30(Expression):
    """
    Aliases->By Character->Get Clipping Width

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Character (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression31(Expression):
    """
    Aliases->By Character->Get Clipping Height

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Character (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression32(Expression):
    """
    Aliases->By Character->Get Character Width

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Character (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression33(Expression):
    """
    Aliases->By Character->Get Character Height

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Character (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression34(Expression):
    """
    Aliases->By Char->Get Clipping X

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Char (ASCII value) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression35(Expression):
    """
    Aliases->By Char->Get Clipping Y

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Char (ASCII value) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression36(Expression):
    """
    Aliases->By Char->Get Clipping Width

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Char (ASCII value) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression37(Expression):
    """
    Aliases->By Char->Get Clipping Height

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Char (ASCII value) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression38(Expression):
    """
    Aliases->By Char->Get Character Width

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Char (ASCII value) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression39(Expression):
    """
    Aliases->By Char->Get Character Height

    Parameters:
    0: Enter Alias Index (Int)
    1: Enter A Char (ASCII value) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Alias(object):
    def __init__(self, name, characters):
        self.name = name
        self.characters = characters

class Character(object):
    def __init__(self, image, external, clip, size):
        self.image = image
        self.external = external
        self.rect = clip
        self.width, self.height = size

class DefaultObject(HiddenObject):
    def created(self, data):
        self.width = data.readInt(True)
        self.height = data.readInt(True)
        data.skipBytes(60) # logfont?
        data.skipBytes(4) # lastLogFontiPointSize
        data.skipBytes(4) # lastLogFontColor
        data.skipBytes(4) # get page size from object
        self.pageSize = (data.readInt(), data.readInt())
        self.text = data.readString(3072)
        self.lineBreaks = data.readInt() != 0
        self.wordWrap = data.readInt() != 0
        self.characters = [data.read(1)
            for _ in xrange(128)]
        self.characterCount = characterCount = data.readShort()
        data.skipBytes(2)
        aliasCount = data.readInt()
        data.skipBytes(4)
        self.aliases = []
        for _ in xrange(aliasCount):
            images = []
            external = []
            end = data.tell() + 128 * 2
            for _ in xrange(characterCount):
                images.append(data.readShort())
            data.seek(end)
            end = data.tell() + 128
            for _ in xrange(characterCount):
                external.append(data.readByte() != 0)
            data.seek(end)
            data.skipBytes(4)
            data.skipBytes(4 * 128)
            end = data.tell() + 128 * (4 + 4 + 4 + 4)
            clip = []
            for _ in xrange(characterCount):
                left = data.readInt()
                top = data.readInt()
                right = data.readInt()
                bottom = data.readInt()
                clip.append((left, top, right, bottom))
            data.seek(end)
            data.skipBytes(128 * 4)
            end = data.tell() + 128 * (4 + 4)
            sizes = []
            for _ in xrange(characterCount):
                sizes.append((data.readInt(), data.readInt()))
            data.seek(end)
            name = data.readString(128)
            characters = []
            for i in xrange(characterCount):
                characters.append(Character(
                    images[i], external[i], clip[i], sizes[i]))
            self.aliases.append(Alias(name, characters))



class CharImage(UserExtension):
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
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        14 : Action14,
        15 : Action15,
        16 : Action16,
        17 : Action17,
        18 : Action18,
        19 : Action19,
        20 : Action20,
        21 : Action21,
        22 : Action22,
        23 : Action23,
        24 : Action24,
        25 : Action25,
        26 : Action26,
        27 : Action27,
        28 : Action28,
        29 : Action29,
        30 : Action30,
        31 : Action31,
        32 : Action32,
        33 : Action33,
        34 : Action34,
        35 : Action35,
        36 : Action36,
        37 : Action37,
        38 : Action38,
        39 : Action39,
        40 : Action40,
        41 : Action41,
        42 : Action42,
        43 : Action43,
        44 : Action44,
        45 : Action45,
        46 : Action46,
        47 : Action47,
        48 : Action48,
        49 : Action49,
        50 : Action50,
        51 : Action51,
        52 : Action52,
        53 : Action53,
        54 : Action54,
        55 : Action55,
        56 : Action56,
        57 : Action57,
        58 : Action58,
        59 : Action59,
        60 : Action60,
        61 : Action61,
        62 : Action62,
        63 : Action63,
        64 : Action64,
        65 : Action65,
        66 : Action66,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        7 : Condition7,
        8 : Condition8,
        9 : Condition9,
        10 : Condition10,
        11 : Condition11,
        12 : Condition12,
        13 : Condition13,
        14 : Condition14,
        15 : Condition15,
        16 : Condition16,
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
        10 : Expression10,
        11 : Expression11,
        12 : Expression12,
        13 : Expression13,
        14 : Expression14,
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
        20 : Expression20,
        21 : Expression21,
        22 : Expression22,
        23 : Expression23,
        24 : Expression24,
        25 : Expression25,
        26 : Expression26,
        27 : Expression27,
        28 : Expression28,
        29 : Expression29,
        30 : Expression30,
        31 : Expression31,
        32 : Expression32,
        33 : Expression33,
        34 : Expression34,
        35 : Expression35,
        36 : Expression36,
        37 : Expression37,
        38 : Expression38,
        39 : Expression39,
    }

extension = CharImage()

def get_extension():
    return extension
