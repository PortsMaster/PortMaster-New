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
kccombo.mfx
Combo object - ClickTeam (http://www.clickteam.com)

Used to create simple or drop-down lists.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Files->Load list file

    Parameters:
    0: Load list file (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action1(Action):
    """
    Files->Load drives list
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action2(Action):
    """
    Files->Load directory list

    Parameters:
    0: Load directory list (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action3(Action):
    """
    Files->Load Filelist

    Parameters:
    0: Load Filelist (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action4(Action):
    """
    Files->Save list file

    Parameters:
    0: Save list file (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action5(Action):
    """
    Reset
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action6(Action):
    """
    Add a line

    Parameters:
    0: Add a line (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action7(Action):
    """
    Insert a line

    Parameters:
    0: Line number to insert after (EXPRESSION, ExpressionParameter)
    1: Line to insert (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action8(Action):
    """
    Delete a line

    Parameters:
    0: Delete a line (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action9(Action):
    """
    Set current line

    Parameters:
    0: Set current line (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action10(Action):
    """
    Visibility->Make Object Reappear
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action11(Action):
    """
    Visibility->Make Object Invisible
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action12(Action):
    """
    Control->Get Focus
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action13(Action):
    """
    Control->Highlight
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action14(Action):
    """
    Control->Dehighlight
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action15(Action):
    """
    Size->Set Horizontal Size

    Parameters:
    0: Set Horizontal Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action16(Action):
    """
    Size->Set Vertical Size

    Parameters:
    0: Set Vertical Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action17(Action):
    """
    Control->Lose Focus
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action18(Action):
    """
    Set edit text

    Parameters:
    0: Set edit text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action19(Action):
    """
    Scrolling->Scroll To Top
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action20(Action):
    """
    Scrolling->Scroll To Line

    Parameters:
    0: Enter line number (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action21(Action):
    """
    Scrolling->Scroll To End
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action22(Action):
    """
    Color->Set text color

    Parameters:
    0: Set text color (COLOUR, Colour)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action23(Action):
    """
    Color->Set background color

    Parameters:
    0: Set background color (COLOUR, Colour)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action24(Action):
    """
    Fonts->List fonts
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action25(Action):
    """
    Fonts->List font sizes

    Parameters:
    0: Enter font name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action26(Action):
    """
    Set line data

    Parameters:
    0: Enter the index of the line (EXPRESSION, ExpressionParameter)
    1: Enter the data to store (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action27(Action):
    """
    Change a line

    Parameters:
    0: Enter the index of the line (EXPRESSION, ExpressionParameter)
    1: Enter the new text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Conditions

class Condition0(Condition):
    """
    Is visible ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition1(Condition):
    """
    Is enabled ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition2(Condition):
    """
    Double clicked ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition3(Condition):
    """
    Selection changed ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition4(Condition):
    """
    Has focus ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition5(Condition):
    """
    Is list dropped ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Expressions

class Expression0(Expression):
    """
    Get current line number
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression1(Expression):
    """
    Get current line
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression2(Expression):
    """
    Get current line (directory)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression3(Expression):
    """
    Get current line (drive)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression4(Expression):
    """
    Get line

    Parameters:
    0: Number of line (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression5(Expression):
    """
    Get line (directory)

    Parameters:
    0: Number of line (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression6(Expression):
    """
    Get line (drive)

    Parameters:
    0: Number of line (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression7(Expression):
    """
    Get number of lines
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression8(Expression):
    """
    Get X Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression9(Expression):
    """
    Get Y Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression10(Expression):
    """
    Get Edit text
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression11(Expression):
    """
    Get Text Color
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression12(Expression):
    """
    Get Background Color
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression13(Expression):
    """
    Find String

    Parameters:
    0: String to find (String)
    1: Flag (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression14(Expression):
    """
    Find String Exact

    Parameters:
    0: String to find (String)
    1: Flag (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression15(Expression):
    """
    Get index of last line inserted
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression16(Expression):
    """
    Get line data

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))



class DefaultObject(HiddenObject):
    def created(self, data):
        self.width = width = data.readShort()
        self.height = height = data.readShort()
        from mmfparser.data.font import LogFont
        self.font = font = LogFont(data, old = True)
        listFontColor = data.readColor()
        data.skipBytes(40)
        

class kccombo(UserExtension):
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
        19 : Action15,
        20 : Action16,
        21 : Action17,
        22 : Action18,
        23 : Action19,
        24 : Action20,
        25 : Action21,
        26 : Action22,
        27 : Action23,
        28 : Action24,
        29 : Action25,
        30 : Action26,
        31 : Action27,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
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
        10 : Expression8,
        11 : Expression9,
        12 : Expression10,
        13 : Expression11,
        14 : Expression12,
        15 : Expression13,
        16 : Expression14,
        17 : Expression15,
        18 : Expression16,
    }

extension = kccombo()

def get_extension():
    return extension
