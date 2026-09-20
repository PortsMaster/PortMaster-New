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
Console.mfx
Console object - AquadaSoft/Jamie McLaughlin (http://www.authorswebpage.com)

Allows you to create a console window and interact with it, and run
console applications visibly or invisibly, retrieving their output

Ported to Python by Mathias Kaerlev
"""

import sys

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Console->Open
    """

    def execute(self, instance):
        pass

class Action1(Action):
    """
    Console->Close
    """

    def execute(self, instance):
        pass

class Action2(Action):
    """
    Settings->Set title

    Parameters:
    0: New title (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action3(Action):
    """
    Settings->Set window dimensions

    Parameters:
    0: New width (EXPRESSION, ExpressionParameter)
    1: New height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action4(Action):
    """
    Settings->Set buffer dimensions

    Parameters:
    0: New width (EXPRESSION, ExpressionParameter)
    1: New height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action5(Action):
    """
    Settings->Set cursor position

    Parameters:
    0: New X position (EXPRESSION, ExpressionParameter)
    1: New Y position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action6(Action):
    """
    Settings->Set output colours

    Parameters:
    0: Background colour (0-15) (EXPRESSION, ExpressionParameter)
    1: Foreground colour (0-15) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action7(Action):
    """
    Input->Read character
    """
    conditions = None
    
    def created(self):
        self.conditions = self.get_conditions(CharacterRead)

    def execute(self, instance):
        value = raw_input()
        instance.objectPlayer.input = value[0]
        for condition in self.conditions:
            condition.generate()

class Action8(Action):
    """
    Input->Read string
    """
    conditions = None
    
    def created(self):
        self.conditions = self.get_conditions(StringRead)

    def execute(self, instance):
        value = raw_input()
        instance.objectPlayer.input = value
        for condition in self.conditions:
            condition.generate()

class Action9(Action):
    """
    Input->Read number
    """
    conditions = None
    
    def created(self):
        self.conditions = self.get_conditions(NumberRead)

    def execute(self, instance):
        try:
            value = int(raw_input())
        except ValueError:
            value = 0
        instance.objectPlayer.input = value
        for condition in self.conditions:
            condition.generate()

class Action10(Action):
    """
    Output->Clear
    """

    def execute(self, instance):
        pass

class Action11(Action):
    """
    Output->Write string

    Parameters:
    0: String to write (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        sys.stdout.write(value)

class Action12(Action):
    """
    Output->Write number

    Parameters:
    0: Number to write (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        sys.stdout.write(str(value))

class Action13(Action):
    """
    Output->Write string with escape sequences

    Parameters:
    0: String to write (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        print self.evaluate_index(0)

class Action14(Action):
    """
    Output->Write ASCII character

    Parameters:
    0: ASCII index of character to write (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        sys.stdout.write(chr(value))

class Action15(Action):
    """
    Output->Write newline
    """

    def execute(self, instance):
        print ''

class Action16(Action):
    """
    Pipe->Run application in it's own console

    Parameters:
    0: Application to run (FILENAME, Filename)
    1: Arguments (EXPSTRING, ExpressionParameter)
    2: Environment variables (seperated by delimiter of your choice, delimiter is next parameter, end with delimiter) (EXPSTRING, ExpressionParameter)
    3: Environment variable delimiter (single character) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action17(Action):
    """
    Pipe->Run application without a console

    Parameters:
    0: Application to run (FILENAME, Filename)
    1: Arguments (EXPSTRING, ExpressionParameter)
    2: Environment variables (seperated by delimiter of your choice, delimiter is next parameter, end with delimiter) (EXPSTRING, ExpressionParameter)
    3: Environment variable delimiter (single character) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action18(Action):
    """
    Settings->Hide cursor
    """

    def execute(self, instance):
        pass

class Action19(Action):
    """
    Settings->Show cursor
    """

    def execute(self, instance):
        pass

class Action20(Action):
    """
    Input->Set character to read until

    Parameters:
    0: New character (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass


# Conditions

class Condition0(Condition):
    """
    Console->Console is open
    """

    def check(self, instance):
        return True

class CharacterRead(Condition):
    """
    Input->Character read
    """

    def check(self, instance):
        return self.isTriggered

class StringRead(Condition):
    """
    Input->String read
    """

    def check(self, instance):
        return self.isTriggered

class NumberRead(Condition):
    """
    Input->Number read
    """

    def check(self, instance):
        return self.isTriggered

class Condition4(Condition):
    """
    Events->Key down
    """

    def check(self, instance):
        return False

class Condition5(Condition):
    """
    Events->Key up
    """

    def check(self, instance):
        return False

class Condition6(Condition):
    """
    Events->Mouse moved
    """

    def check(self, instance):
        return False

class Condition7(Condition):
    """
    Events->Mouse wheeled
    """

    def check(self, instance):
        return False

class Condition8(Condition):
    """
    Events->Mouse left down
    """

    def check(self, instance):
        return False

class Condition9(Condition):
    """
    Events->Mouse middle down
    """

    def check(self, instance):
        return False

class Condition10(Condition):
    """
    Events->Mouse right down
    """

    def check(self, instance):
        return False

class Condition11(Condition):
    """
    Events->Window resized
    """

    def check(self, instance):
        return False

class Condition12(Condition):
    """
    Pipe->Application ended
    """

    def check(self, instance):
        return False

class Condition13(Condition):
    """
    Events->Mouse state changed
    """

    def check(self, instance):
        return False


# Expressions

class Expression0(Expression):
    """
    Input->Get character read
    Return type: Int
    """

    def get(self, instance):
        return ord(instance.objectPlayer.input)

class Expression1(Expression):
    """
    Input->Get string read
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.input

class Expression2(Expression):
    """
    Input->Get number read
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.input

class Expression3(Expression):
    """
    Settings->Get cursor X position
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression4(Expression):
    """
    Settings->Get cursor Y position
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression5(Expression):
    """
    Events->Get repeat count for key down
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression6(Expression):
    """
    Events->Get ASCII value for key up/down
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression7(Expression):
    """
    Events->Get mouse X position for mouse events
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression8(Expression):
    """
    Events->Get mouse Y position for mouse events
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression9(Expression):
    """
    Events->Get window width for window resize
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression10(Expression):
    """
    Events->Get window height for window resize
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression11(Expression):
    """
    Pipe->Get output
    Return type: String
    """

    def get(self, instance):
        return ''


class DefaultObject(HiddenObject):
    input = None
    def created(self):
        # you should probably make your object ready here.
        # data is your property data
        pass

class Console(UserExtension):
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
    }
    
    conditions = {
        0 : Condition0,
        1 : CharacterRead,
        2 : StringRead,
        3 : NumberRead,
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
    }

extension = Console()

def get_extension():
    return extension
