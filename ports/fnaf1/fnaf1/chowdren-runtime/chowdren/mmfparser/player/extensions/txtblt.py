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
txtblt.mfx
Text Blitter - Christopher Lightfoot (http://light.cellosoft.com/)

Allows you to use bitmap fonts in any application or game, online or
offline. This version has new features that give you more control.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Change Alterable Text...

    Parameters:
    0: Change the text (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action1(Action):
    """
    Object->Set Position...

    Parameters:
    0: Set the X Position (TIME, Time)
    1: Set the Y Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action2(Action):
    """
    Object->Set X Position...

    Parameters:
    0: Set the X Position (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action3(Action):
    """
    Object->Set Y Position...

    Parameters:
    0: Set the Y Position (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Characters->Set Character Width...

    Parameters:
    0: Set Character Width (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action5(Action):
    """
    Characters->Set Character Height...

    Parameters:
    0: Set Character Height (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action6(Action):
    """
    Characters->Set Character Offset...

    Parameters:
    0: Set Character Offset (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Characters->Set Character Map...

    Parameters:
    0: Set Character Map (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    """
    Image->Load Image...

    Parameters:
    0: Load an image (OBJECT, Object)
    1:  (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Image->Save Image...

    Parameters:
    0: Save an image (OBJECT, Object)
    1:  (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action10(Action):
    """
    Image->Set Image Width...

    Parameters:
    0: Set Width of the image (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action11(Action):
    """
    Image->Set Image Height...

    Parameters:
    0: Set Width of the image (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    """
    Image->Set Image X Offset...

    Parameters:
    0: Set Image Drawing offset (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    """
    Image->Set Image Y Offset...

    Parameters:
    0: Set Image Drawing offset (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action14(Action):
    """
    Set Transparency->Set On

    Parameters:
    0:  ((unknown 25020))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action15(Action):
    """
    Set Transparency->Set Off

    Parameters:
    0:  ((unknown 25021))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action16(Action):
    """
    Set Transparency->Toggle

    Parameters:
    0:  ((unknown 25022))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action17(Action):
    """
    Set Text Functions->Set On

    Parameters:
    0:  ((unknown 25026))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action18(Action):
    """
    Set Text Functions->Set Off

    Parameters:
    0:  ((unknown 25027))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action19(Action):
    """
    Set Text Functions->Toggle

    Parameters:
    0:  ((unknown 25028))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action20(Action):
    """
    Word Wrapping->Set On

    Parameters:
    0:  ((unknown 25032))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action21(Action):
    """
    Word Wrapping->Set Off

    Parameters:
    0:  ((unknown 25033))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action22(Action):
    """
    Word Wrapping->Toggle

    Parameters:
    0:  ((unknown 25034))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action23(Action):
    """
    Text->Load Text from file...

    Parameters:
    0: Filename of file to load (OBJECT, Object)
    1:  (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action24(Action):
    """
    Text->Save Text to file...

    Parameters:
    0: Filename of file to save to (OBJECT, Object)
    1:  (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action25(Action):
    """
    Alignment->Set Horizontal Alignment...

    Parameters:
    0: Set Horizontal Alignment (0=Left,1=Center,2=Right) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action26(Action):
    """
    Alignment->Set Vertical Alignment...

    Parameters:
    0: Set Vertical Alignment (0=Top,1=Center,2=Bottom) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action27(Action):
    """
    Margins->Set Top Margin...

    Parameters:
    0: Set Top Margin (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action28(Action):
    """
    Margins->Set Left Margin...

    Parameters:
    0: Set Left Margin (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action29(Action):
    """
    Margins->Set Right Margin...

    Parameters:
    0: Set Right Margin (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action30(Action):
    """
    Margins->Set Bottom Margin...

    Parameters:
    0: Set Bottom Margin (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action31(Action):
    """
    Scrolling->Set Horizontal Scrolling...

    Parameters:
    0: Set Horizontal Scroll (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action32(Action):
    """
    Scrolling->Set Vertical Scrolling...

    Parameters:
    0: Set Vertical Scroll (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action33(Action):
    """
    Characters->Set Horizontal Spacing...

    Parameters:
    0: Set Horizontal Character Spacing (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action34(Action):
    """
    Characters->Set Vertical Spacing...

    Parameters:
    0: Set Vertical Character Spacing (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action35(Action):
    """
    Multiline->Set On

    Parameters:
    0:  ((unknown 25047))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action36(Action):
    """
    Multiline->Set Off

    Parameters:
    0:  ((unknown 25048))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action37(Action):
    """
    Multiline->Toggle

    Parameters:
    0:  ((unknown 25049))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action38(Action):
    """
    Append Text...

    Parameters:
    0: Append String (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action39(Action):
    """
    Animation->Change Speed...

    Parameters:
    0: Set Anim Speed (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action40(Action):
    """
    Animation->Set Animation Type...

    Parameters:
    0: Set Anim Type (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action41(Action):
    """
    Animation->Set Animation Param...

    Parameters:
    0: Which Param (TIME, Time)
    1: Param Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action42(Action):
    """
    Text->Set Tab Width...

    Parameters:
    0: Number of characters (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action43(Action):
    """
    Text->Load Text Using Selector...

    Parameters:
    0: Dialog Box Title (INT, Int)
    1: File Filter - Text (*.txt)|*.txt|All Files(*.*)|*.* (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action44(Action):
    """
    Text->Save Text Using Selector...

    Parameters:
    0: Dialog Box Title (INT, Int)
    1: File Filter - Text (*.txt)|*.txt|All Files(*.*)|*.* (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action45(Action):
    """
    Color->Set Transparant Color...

    Parameters:
    0: Set Transparent Color (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action46(Action):
    """
    Color->Replace Color...

    Parameters:
    0: Old Color (TIME, Time)
    1: New Color (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action47(Action):
    """
    Object->Set Object Width...

    Parameters:
    0: Set Width (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action48(Action):
    """
    Object->Set Object Height...

    Parameters:
    0: Set Height (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action49(Action):
    """
    Callback->Character->Destination X...

    Parameters:
    0: Char: New X Destination (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action50(Action):
    """
    Callback->Character->Destination Y...

    Parameters:
    0: Char: New Y Destination (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action51(Action):
    """
    Callback->Character->Source X...

    Parameters:
    0: Char: Source X (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action52(Action):
    """
    Callback->Character->Source Y...

    Parameters:
    0: Char: Source Y (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action53(Action):
    """
    Callback->Character->Character Width...

    Parameters:
    0: Char: Character Width (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action54(Action):
    """
    Callback->Character->Character Height...

    Parameters:
    0: Char: Character Height (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action55(Action):
    """
    Callback->Character->Transparency...

    Parameters:
    0: Char: Character Transparency (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action56(Action):
    """
    Callback->Character->Character...

    Parameters:
    0: Char: Character (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action57(Action):
    """
    Callback->Character->Image X Offset...

    Parameters:
    0: Char: Image X Offset (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action58(Action):
    """
    Callback->Character->Image Y Offset...

    Parameters:
    0: Char: Image Y Offset (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action59(Action):
    """
    Callback->Begin Line->X...

    Parameters:
    0: Line: Destination X (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action60(Action):
    """
    Callback->Begin Line->Y...

    Parameters:
    0: Line: Destination Y (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action61(Action):
    """
    Callback->Begin Line->Transparency...

    Parameters:
    0: Line: Transparency (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action62(Action):
    """
    Callback->Begin Line->Image X Offset...

    Parameters:
    0: Line: Image X Offset (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action63(Action):
    """
    Callback->Begin Line->Image Y Offset...

    Parameters:
    0: Line: Image Y Offset (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action64(Action):
    """
    Balloon->Off

    Parameters:
    0:  ((unknown 25076))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action65(Action):
    """
    Balloon->Balloon...

    Parameters:
    0: Set Balloon : X (SHORT, Short)
    1: Set Balloon : Y (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action66(Action):
    """
    Balloon->Source...

    Parameters:
    0: Set Balloon source x (TIME, Time)
    1: Set Balloon source y (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action67(Action):
    """
    Balloon->Size...

    Parameters:
    0: Set Balloon Minimum X (SHORT, Short)
    1: Set Balloon Minimum Y (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action68(Action):
    """
    Send Message...

    Parameters:
    0: Message (SHORT, Short)
    1: Parameter1 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Is Transparent

    Parameters:
    0:  ((unknown 26001))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Text Functions

    Parameters:
    0:  ((unknown 26002))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition2(Condition):
    """
    Word Wrapped

    Parameters:
    0:  ((unknown 26003))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition3(Condition):
    """
    Multiline

    Parameters:
    0:  ((unknown 26004))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition4(Condition):
    """
    Callback->On Begin

    Parameters:
    0:  ((unknown 26005))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition5(Condition):
    """
    Callback->On End

    Parameters:
    0:  ((unknown 26006))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition6(Condition):
    """
    Callback->On Line Begin

    Parameters:
    0:  ((unknown 26007))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition7(Condition):
    """
    Callback->On Line End

    Parameters:
    0:  ((unknown 26008))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition8(Condition):
    """
    Callback->On Character
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Get String

    Parameters:
    0: (not found) ((unknown 27001))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Character->Get Character Width

    Parameters:
    0: (not found) ((unknown 27002))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression2(Expression):
    """
    Character->Get Character Height

    Parameters:
    0: (not found) ((unknown 27003))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Character->Get Character Offset

    Parameters:
    0: (not found) ((unknown 27004))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Character->Get Character Map

    Parameters:
    0: (not found) ((unknown 27005))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Image->Get Image Width

    Parameters:
    0: (not found) ((unknown 27006))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Image->Get Image Height

    Parameters:
    0: (not found) ((unknown 27007))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Image->Get Image Filename

    Parameters:
    0: (not found) ((unknown 27008))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    """
    Alignment->Get Horizontal Alignment

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    Alignment->Get Vertical Alignment

    Parameters:
    0: (not found) ((unknown 27011))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression10(Expression):
    """
    Margins->Get Top Margin

    Parameters:
    0: (not found) ((unknown 27012))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    Margins->Get Left Margin

    Parameters:
    0: (not found) ((unknown 27013))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    Margins->Get Right Margin

    Parameters:
    0: (not found) ((unknown 27014))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression13(Expression):
    """
    Margins->Get Bottom Margin

    Parameters:
    0: (not found) ((unknown 27015))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression14(Expression):
    """
    Scrolling->Get Horizontal Scroll

    Parameters:
    0: (not found) ((unknown 27016))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression15(Expression):
    """
    Scrolling->Get Vertical Scroll

    Parameters:
    0: (not found) ((unknown 27017))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression16(Expression):
    """
    Character->Get Horizontal Character Spacing

    Parameters:
    0: (not found) ((unknown 27018))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression17(Expression):
    """
    Character->Get Vertical Character Spacing

    Parameters:
    0: (not found) ((unknown 27019))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression18(Expression):
    """
    Object->Horizontal Position

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression19(Expression):
    """
    Object->Vertical Position

    Parameters:
    0: (not found) ((unknown 27021))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression20(Expression):
    """
    Object->Get Width

    Parameters:
    0: (not found) ((unknown 27022))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression21(Expression):
    """
    Object->Get Height

    Parameters:
    0: (not found) ((unknown 27023))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression22(Expression):
    """
    Advanced->Convert to ASCII Value...

    Parameters:
    0: (not found) (Int)
    1: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression23(Expression):
    """
    Advanced->Convert to ASCII Character...

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression24(Expression):
    """
    Advanced->Get Uppercase of buffer

    Parameters:
    0: (not found) ((unknown 27026))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression25(Expression):
    """
    Advanced->Get Lowercase of buffer

    Parameters:
    0: (not found) ((unknown 27027))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression26(Expression):
    """
    Advanced->Get Reverse of buffer

    Parameters:
    0: (not found) ((unknown 27028))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression27(Expression):
    """
    Advanced->Extract left of buffer...

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression28(Expression):
    """
    Advanced->Extract right of buffer...

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression29(Expression):
    """
    Advanced->Extract middle of buffer...

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression30(Expression):
    """
    Advanced->Length of buffer

    Parameters:
    0: (not found) ((unknown 27032))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression31(Expression):
    """
    Advanced->Number of lines

    Parameters:
    0: (not found) ((unknown 27033))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression32(Expression):
    """
    Advanced->Get Line...

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression33(Expression):
    """
    Image->Get Image X Offset

    Parameters:
    0: (not found) ((unknown 27035))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression34(Expression):
    """
    Image->Get Image Y Offset

    Parameters:
    0: (not found) ((unknown 27037))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression35(Expression):
    """
    Animation->Get Animation Speed

    Parameters:
    0: (not found) ((unknown 27036))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression36(Expression):
    """
    Animation->Get Animation Type

    Parameters:
    0: (not found) ((unknown 27038))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression37(Expression):
    """
    Animation->Get Animation Param...

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression38(Expression):
    """
    Text->Get Tab Width

    Parameters:
    0: (not found) ((unknown 27040))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression39(Expression):
    """
    Text->Get Text Filename

    Parameters:
    0: (not found) ((unknown 27041))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression40(Expression):
    """
    Color->Get Transparant Color

    Parameters:
    0: (not found) ((unknown 27042))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression41(Expression):
    """
    Character->Get Char From Character Map...

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression42(Expression):
    """
    Callback->Current Character on line

    Parameters:
    0: (not found) ((unknown 27044))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression43(Expression):
    """
    Callback->Current Line Number

    Parameters:
    0: (not found) ((unknown 27045))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression44(Expression):
    """
    Callback->Number of characters on line

    Parameters:
    0: (not found) ((unknown 27046))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression45(Expression):
    """
    Callback->Number of lines

    Parameters:
    0: (not found) ((unknown 27047))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression46(Expression):
    """
    Callback->Character->Destination X

    Parameters:
    0: (not found) ((unknown 27048))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression47(Expression):
    """
    Callback->Character->Destination Y

    Parameters:
    0: (not found) ((unknown 27049))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression48(Expression):
    """
    Callback->Character->Source X

    Parameters:
    0: (not found) ((unknown 27050))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression49(Expression):
    """
    Callback->Character->Source Y

    Parameters:
    0: (not found) ((unknown 27051))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression50(Expression):
    """
    Callback->Character->Character Width

    Parameters:
    0: (not found) ((unknown 27052))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression51(Expression):
    """
    Callback->Character->Character Height

    Parameters:
    0: (not found) ((unknown 27053))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression52(Expression):
    """
    Callback->Character->Transparency

    Parameters:
    0: (not found) ((unknown 27054))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression53(Expression):
    """
    Callback->Character->Character

    Parameters:
    0: (not found) ((unknown 27055))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression54(Expression):
    """
    Callback->Character->Image X Offset

    Parameters:
    0: (not found) ((unknown 27056))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression55(Expression):
    """
    Callback->Character->Image Y Offset

    Parameters:
    0: (not found) ((unknown 27057))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression56(Expression):
    """
    Callback->Begin Line->X

    Parameters:
    0: (not found) ((unknown 27058))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression57(Expression):
    """
    Callback->Begin Line->Y

    Parameters:
    0: (not found) ((unknown 27059))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression58(Expression):
    """
    Callback->Begin Line->Transparency of line

    Parameters:
    0: (not found) ((unknown 27060))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression59(Expression):
    """
    Callback->Begin Line->Image X Offset

    Parameters:
    0: (not found) ((unknown 27061))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression60(Expression):
    """
    Callback->Begin Line->Image Y Offset

    Parameters:
    0: (not found) ((unknown 27062))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression61(Expression):
    """
    Balloon->Get X Position

    Parameters:
    0: (not found) ((unknown 27063))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression62(Expression):
    """
    Balloon->Get Y Position

    Parameters:
    0: (not found) ((unknown 27064))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression63(Expression):
    """
    Balloon->Get Handle

    Parameters:
    0: (not found) ((unknown 27065))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression64(Expression):
    """
    Balloon->Get Flags

    Parameters:
    0: (not found) ((unknown 27066))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression65(Expression):
    """
    Balloon->Min X

    Parameters:
    0: (not found) ((unknown 27067))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression66(Expression):
    """
    Balloon->Min Y

    Parameters:
    0: (not found) ((unknown 27068))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression67(Expression):
    """
    Balloon->Max X

    Parameters:
    0: (not found) ((unknown 27069))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression68(Expression):
    """
    Balloon->Max Y
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

class txtblt(UserExtension):
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
        13 : Action8,
        14 : Action9,
        15 : Action10,
        16 : Action11,
        17 : Action12,
        18 : Action13,
        19 : Action14,
        20 : Action15,
        21 : Action16,
        25 : Action17,
        26 : Action18,
        27 : Action19,
        31 : Action20,
        32 : Action21,
        33 : Action22,
        34 : Action23,
        35 : Action24,
        36 : Action25,
        37 : Action26,
        38 : Action27,
        39 : Action28,
        40 : Action29,
        41 : Action30,
        42 : Action31,
        43 : Action32,
        44 : Action33,
        45 : Action34,
        46 : Action35,
        47 : Action36,
        48 : Action37,
        49 : Action38,
        50 : Action39,
        51 : Action40,
        52 : Action41,
        53 : Action42,
        54 : Action43,
        55 : Action44,
        56 : Action45,
        57 : Action46,
        58 : Action47,
        59 : Action48,
        60 : Action49,
        61 : Action50,
        62 : Action51,
        63 : Action52,
        64 : Action53,
        65 : Action54,
        66 : Action55,
        67 : Action56,
        68 : Action57,
        69 : Action58,
        70 : Action59,
        71 : Action60,
        72 : Action61,
        73 : Action62,
        74 : Action63,
        75 : Action64,
        76 : Action65,
        77 : Action66,
        78 : Action67,
        79 : Action68,
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
        9 : Expression8,
        10 : Expression9,
        11 : Expression10,
        12 : Expression11,
        13 : Expression12,
        14 : Expression13,
        15 : Expression14,
        16 : Expression15,
        17 : Expression16,
        18 : Expression17,
        19 : Expression18,
        20 : Expression19,
        21 : Expression20,
        22 : Expression21,
        23 : Expression22,
        24 : Expression23,
        25 : Expression24,
        26 : Expression25,
        27 : Expression26,
        28 : Expression27,
        29 : Expression28,
        30 : Expression29,
        31 : Expression30,
        32 : Expression31,
        33 : Expression32,
        34 : Expression33,
        35 : Expression34,
        36 : Expression35,
        37 : Expression36,
        38 : Expression37,
        39 : Expression38,
        40 : Expression39,
        41 : Expression40,
        42 : Expression41,
        43 : Expression42,
        44 : Expression43,
        45 : Expression44,
        46 : Expression45,
        47 : Expression46,
        48 : Expression47,
        49 : Expression48,
        50 : Expression49,
        51 : Expression50,
        52 : Expression51,
        53 : Expression52,
        54 : Expression53,
        55 : Expression54,
        56 : Expression55,
        57 : Expression56,
        58 : Expression57,
        59 : Expression58,
        60 : Expression59,
        61 : Expression60,
        62 : Expression61,
        63 : Expression62,
        64 : Expression63,
        65 : Expression64,
        66 : Expression65,
        67 : Expression66,
        68 : Expression67,
        69 : Expression68,
    }

extension = txtblt()

def get_extension():
    return extension
