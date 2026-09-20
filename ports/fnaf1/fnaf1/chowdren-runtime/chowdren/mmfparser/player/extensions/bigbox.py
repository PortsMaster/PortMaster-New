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
bigbox.mfx
The Big Box - Phanoo (http://tgfcenter.free.fr)

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Display->Windows->Change wallpaper

    Parameters:
    0: Choose a bitmap file (*.bmp) (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action1(Action):
    """
    Display->Windows->Launch the screensaver
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action2(Action):
    """
    Display->Windows->Enable screensaver
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action3(Action):
    """
    Display->Windows->Disable screensaver
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Display->Windows->Adjust the screensaver delay

    Parameters:
    0: Enter the delay, in minutes (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action5(Action):
    """
    Display->Windows->Reduce all opened windows
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action6(Action):
    """
    Mouse/Keyboard->Change keyboard repetition speed

    Parameters:
    0: Enter the speed, between 0 and 31 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Display->Windows->Change the background color of the desktop

    Parameters:
    0: Choose a colour (COLOUR, Colour)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    """
    Display->Change screen resolution

    Parameters:
    0: Width of the resolution (EXPRESSION, ExpressionParameter)
    1: Height of the resolution (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Display->Change color depth

    Parameters:
    0: [8]=256 coulours, [16]=66356, [24 ou 32]=16M (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action10(Action):
    """
    Display->Change screen refresh rate

    Parameters:
    0: Refresh rate, in Hz (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action11(Action):
    """
    System->Shut down the computer
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    """
    System->Reboot the computer
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    """
    System->Make a BEEP from the internal speaker

    Parameters:
    0: Enter the beep frequency (in Hz) (EXPRESSION, ExpressionParameter)
    1: Beep duration (in milliseconds, 1000ms = 1sec) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action14(Action):
    """
    Mouse/Keyboard->Set the mouse position

    Parameters:
    0: X position (EXPRESSION, ExpressionParameter)
    1: Y position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action15(Action):
    """
    Mouse/Keyboard->Change the mouse speed

    Parameters:
    0: Enter a value between 1 and 20 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action16(Action):
    """
    Mouse/Keyboard->Change keyboard repetition delay

    Parameters:
    0: Enter a value between 0 and 31 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action17(Action):
    """
    Mouse/Keyboard->Delay of the double-click

    Parameters:
    0: Max delay to do a double-click, en milliseconds (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action18(Action):
    """
    Display->Windows->Enable font smoothing
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action19(Action):
    """
    Display->Windows->Disable font smoothing
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action20(Action):
    """
    Mouse/Keyboard->Mouse's trails

    Parameters:
    0: [0]=No [1~16]=Number of cursors drawn in the trail (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action21(Action):
    """
    System->Kill a process

    Parameters:
    0: Process name (ex: explorer.exe) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action22(Action):
    """
    Misc->Open a file / Open a website

    Parameters:
    0: File to open / URL of the website (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action23(Action):
    """
    System->Close the current Windows session
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action24(Action):
    """
    System->Tell computer to hibernate
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action25(Action):
    """
    Mouse/Keyboard->   Simulate a left mouse click
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action26(Action):
    """
    Mouse/Keyboard->   Simulate a right mouse click
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action27(Action):
    """
    Mouse/Keyboard->Set Num Lock on
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action28(Action):
    """
    Mouse/Keyboard->Set Num Lock off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action29(Action):
    """
    Mouse/Keyboard->Set Caps Lock on
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action30(Action):
    """
    Mouse/Keyboard->Set Caps Lock off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action31(Action):
    """
    Misc->Make a screenshot
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action32(Action):
    """
    Mouse/Keyboard->   Simulate a middle mouse click
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Mouse/Keyboard->Is Num Lock on ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Mouse/Keyboard->Is Caps Lock on ?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Mouse/Keyboard->Keyboard repetition delay (*/31)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Display->Width of the current resolution
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression2(Expression):
    """
    Display->Height of the current resolution
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    System->Total amount of RAM (MB)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Display->Windows->Screensaver delay (in minutes)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Mouse/Keyboard->Mouse speed (*/21)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Display->Screen refresh rate
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Display->Screen depth
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    """
    System->BEEP music !->C frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    System->BEEP music !->C# frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression10(Expression):
    """
    System->BEEP music !->D frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    System->BEEP music !->D# frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    System->BEEP music !->E frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression13(Expression):
    """
    System->BEEP music !->F frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression14(Expression):
    """
    System->BEEP music !->F# frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression15(Expression):
    """
    System->BEEP music !->G frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression16(Expression):
    """
    System->BEEP music !->G# frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression17(Expression):
    """
    System->BEEP music !->A frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression18(Expression):
    """
    System->BEEP music !->A# frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression19(Expression):
    """
    System->BEEP music !->B frequency
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression20(Expression):
    """
    System->CPU speed (MHz)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression21(Expression):
    """
    System->Hard drive size (MB)

    Parameters:
    0: Letter of the disk (ex: C:\) (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression22(Expression):
    """
    System->Free space on the hard drive (MB)

    Parameters:
    0: Letter of the disk (ex: C:\) (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression23(Expression):
    """
    System->Amount of free RAM (MB)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression24(Expression):
    """
    Mouse/Keyboard->Keyboard repetition speed (*/31)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression25(Expression):
    """
    System->Installed OS  (see HELP.TXT)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression26(Expression):
    """
    System->Get Windows Directory
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression27(Expression):
    """
    System->Get System Directory
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression28(Expression):
    """
    System->Get Temp Directory
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


class DefaultObject(HiddenObject):
    def created(self):
        # you should probably make your object ready here.
        # data is your property data
        pass

class bigbox(UserExtension):
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
        28 : Action27,
        29 : Action28,
        30 : Action29,
        31 : Action30,
        32 : Action31,
        33 : Action32,
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
    }

extension = bigbox()

def get_extension():
    return extension
