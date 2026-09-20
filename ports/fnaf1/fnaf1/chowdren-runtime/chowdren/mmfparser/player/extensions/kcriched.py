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
kcriched.mfx
Rich Edit Object - Clickteam (http://www.clickteam.com)

Enhanced editable formated text box. Can display, load, save RTF
files.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Files->Load ASCII text

    Parameters:
    0: Please enter pathname (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action1(Action):
    """
    Files->Load RTF text

    Parameters:
    0: Please enter pathname (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action2(Action):
    """
    Files->Save ASCII text

    Parameters:
    0: Please enter pathname (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action3(Action):
    """
    Files->Save RTF text

    Parameters:
    0: Please enter pathname (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Files->Load ASCII text from selector
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action5(Action):
    """
    Files->Load RTF text from selector
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action6(Action):
    """
    Files->Save ASCII text from selector
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Files->Save RTF text from selector
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    """
    Block->Replace selection

    Parameters:
    0: Replace selection (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Block->Cut
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action10(Action):
    """
    Block->Copy
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action11(Action):
    """
    Block->Paste
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    """
    Block->Clear
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    """
    Size->Set width

    Parameters:
    0: Set width (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action14(Action):
    """
    Size->Set height

    Parameters:
    0: Set height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action15(Action):
    """
    Visibility->Show object
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action16(Action):
    """
    Visibility->Hide object
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action17(Action):
    """
    Control->Read only->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action18(Action):
    """
    Control->Read only->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action19(Action):
    """
    Control->Window->Enabled
    """

    def execute(self, instance):
        instance.objectPlayer.set_enabled(True)

class Action20(Action):
    """
    Control->Window->Disabled
    """

    def execute(self, instance):
        instance.objectPlayer.set_enabled(False)

class Action21(Action):
    """
    Control->Goto->Character number...

    Parameters:
    0: Character number... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action22(Action):
    """
    Control->Goto->Line number...

    Parameters:
    0: Line number... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action23(Action):
    """
    Control->Find->Find text

    Parameters:
    0: Enter the string to find* (EXPSTRING, ExpressionParameter)
    1: 0 : no case, 1 : case sensitive, 2 : whole word, 3 : both (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action24(Action):
    """
    Control->Find->Find next
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action25(Action):
    """
    Control->Find->Find and select text

    Parameters:
    0: Enter the string to find* (EXPSTRING, ExpressionParameter)
    1: 0 : no case, 1 : case sensitive, 2 : whole word, 3 : both (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action26(Action):
    """
    Control->Find->Find and select next
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action27(Action):
    """
    Control->Window->Set focus
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action28(Action):
    """
    Block->Select text

    Parameters:
    0: Enter the first character to select (EXPRESSION, ExpressionParameter)
    1: Enter the last character to select (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action29(Action):
    """
    Control->Background->Set color from string

    Parameters:
    0: Please enter the color, use a string with "Red, Green, Blue" (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action30(Action):
    """
    Control->Undo->Undo
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action31(Action):
    """
    Control->Undo->Clear UNDO buffer
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action32(Action):
    """
    Control->Format->Bold->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action33(Action):
    """
    Control->Format->Bold->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action34(Action):
    """
    Control->Format->Italic->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action35(Action):
    """
    Control->Format->Italic->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action36(Action):
    """
    Control->Format->Underline->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action37(Action):
    """
    Control->Format->Underline->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action38(Action):
    """
    Control->Format->Strike->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action39(Action):
    """
    Control->Format->Strike->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action40(Action):
    """
    Control->Format->Font->Set font from selector
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action41(Action):
    """
    Control->Format->Font->Set font color from string

    Parameters:
    0: Please enter the color, use a string with "Red, Green, Blue" (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action42(Action):
    """
    Control->Format->Font->Set font color from selector
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action43(Action):
    """
    Control->Set Text

    Parameters:
    0: Set Text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.add_line(self.evaluate_expression(
            self.get_parameter(0)))

class Action44(Action):
    """
    Paragraph->Align->Left
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action45(Action):
    """
    Paragraph->Align->Center
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action46(Action):
    """
    Paragraph->Align->Right
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action47(Action):
    """
    Paragraph->Bullets->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action48(Action):
    """
    Paragraph->Bullets->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action49(Action):
    """
    Block->Select all
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action50(Action):
    """
    Paragraph->Indent

    Parameters:
    0: Please enter the indentation of the first line (EXPRESSION, ExpressionParameter)
    1: Please enter the indentation of the second line (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action51(Action):
    """
    Control->Scrolling->Scroll up
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action52(Action):
    """
    Control->Scrolling->Scroll down
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action53(Action):
    """
    Control->Scrolling->Scroll left
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action54(Action):
    """
    Control->Scrolling->Scroll right
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action55(Action):
    """
    Control->Format->Font->Set font name

    Parameters:
    0: Set font name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action56(Action):
    """
    Control->Format->Font->Set font size

    Parameters:
    0: Set font size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action57(Action):
    """
    Control->Format->Font->Set font color from integer

    Parameters:
    0: Please enter the color in the form : BLUE*65536 + GREEN*256 + RED  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action58(Action):
    """
    Control->Background->Set color from integer

    Parameters:
    0: Please enter the color in the form : BLUE*65536 + GREEN*256 + RED  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action59(Action):
    """
    Block->Unselect block
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action60(Action):
    """
    Control->Scrolling->Scroll To Top
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action61(Action):
    """
    Control->Scrolling->Scroll To Line

    Parameters:
    0: Enter line number (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action62(Action):
    """
    Control->Scrolling->Scroll To End
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action63(Action):
    """
    Files->Print text
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action64(Action):
    """
    Control->Format->Link (2.0)->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action65(Action):
    """
    Control->Format->Link (2.0)->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action66(Action):
    """
    Control->Undo->&Redo (2.0)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action67(Action):
    """
    Control->Set RTF Text

    Parameters:
    0: Set RTF Text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action68(Action):
    """
    Control->Format->Protection->On
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action69(Action):
    """
    Control->Format->Protection->Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action70(Action):
    """
    Control->&Modified->&Yes
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action71(Action):
    """
    Control->&Modified->&No
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action72(Action):
    """
    Control->Auto &Focus->O&n
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action73(Action):
    """
    Control->Auto &Focus->O&ff
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Is object visible?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Is object enabled?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition2(Condition):
    """
    Is object read-only?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition3(Condition):
    """
    Has the object the input focus?
    """

    def check(self, instance):
        return False

class Condition4(Condition):
    """
    Has the text been modified?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition5(Condition):
    """
    Undo->Is UNDO available?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition6(Condition):
    """
    Is text available in the clipboard?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition7(Condition):
    """
    Character->Is bold?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition8(Condition):
    """
    Character->Is italic?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition9(Condition):
    """
    Character->Is underlined?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition10(Condition):
    """
    Character->Is striked out?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition11(Condition):
    """
    Paragraph->Is aligned on the left?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition12(Condition):
    """
    Paragraph->Is centered?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition13(Condition):
    """
    Paragraph->Is aligned on the right?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition14(Condition):
    """
    Paragraph->Bullet selected?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition15(Condition):
    """
    Mouse->Clicked with left button?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition16(Condition):
    """
    Mouse->Clicked with right button?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition17(Condition):
    """
    Mouse->Double-clicked?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition18(Condition):
    """
    Mouse->Link clicked? (2.0)

    Parameters:
    0: Link text (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition19(Condition):
    """
    Mouse->Any link clicked? (2.0)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition20(Condition):
    """
    Undo->Is REDO available? (2.0)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition21(Condition):
    """
    Character->Is link? (2.0)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition22(Condition):
    """
    Character->Is protected?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition23(Condition):
    """
    Scrolling->Is line visible?

    Parameters:
    0: Enter line number (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition24(Condition):
    """
    Scrolling->Is line entirely visible

    Parameters:
    0: Enter line number (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Caret->Get caret position
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Caret->Get caret line
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression2(Expression):
    """
    Position->Get X Position
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Position->Get Y Position
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Size->Get width
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Size->Get height
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Text->Get text

    Parameters:
    0: First character number (Int)
    1: Second character number (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Text->Get selection
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    """
    Font->Get font name
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    Font->Get font size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression10(Expression):
    """
    Font->Get font color
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    Scrolling->Get first visible line
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    Scrolling->Get line count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression13(Expression):
    """
    Link (2.0)->Get link text
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression14(Expression):
    """
    Text->Get RTF text

    Parameters:
    0: First character number (Int)
    1: Second character number (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression15(Expression):
    """
    Text->Get RTF selection
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression16(Expression):
    """
    Text->Get total number of characters
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression17(Expression):
    """
    Link (2.0)->Get link position
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


class DefaultObject(HiddenObject):
    enabled = True
    def created(self, data):
        # you should probably make your object ready here.
        # data is your property data
        pass
    
    def set_enabled(self, value):
        self.enabled = value
    
    def add_line(self, value):
        print 'add_line:', value

class kcriched(UserExtension):
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
        16 : Action13,
        17 : Action14,
        18 : Action15,
        19 : Action16,
        20 : Action17,
        21 : Action18,
        22 : Action19,
        23 : Action20,
        24 : Action21,
        25 : Action22,
        26 : Action23,
        27 : Action24,
        28 : Action25,
        29 : Action26,
        30 : Action27,
        31 : Action28,
        32 : Action29,
        33 : Action30,
        34 : Action31,
        35 : Action32,
        36 : Action33,
        37 : Action34,
        38 : Action35,
        39 : Action36,
        40 : Action37,
        41 : Action38,
        42 : Action39,
        43 : Action40,
        44 : Action41,
        45 : Action42,
        46 : Action43,
        47 : Action44,
        48 : Action45,
        49 : Action46,
        50 : Action47,
        51 : Action48,
        52 : Action49,
        53 : Action50,
        54 : Action51,
        55 : Action52,
        56 : Action53,
        57 : Action54,
        58 : Action55,
        59 : Action56,
        60 : Action57,
        61 : Action58,
        62 : Action59,
        63 : Action60,
        64 : Action61,
        65 : Action62,
        66 : Action63,
        67 : Action64,
        68 : Action65,
        69 : Action66,
        70 : Action67,
        71 : Action68,
        72 : Action69,
        73 : Action70,
        74 : Action71,
        75 : Action72,
        76 : Action73,
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
        17 : Condition17,
        18 : Condition18,
        19 : Condition19,
        20 : Condition20,
        21 : Condition21,
        22 : Condition22,
        23 : Condition23,
        24 : Condition24,
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
    }

extension = kcriched()

def get_extension():
    return extension
