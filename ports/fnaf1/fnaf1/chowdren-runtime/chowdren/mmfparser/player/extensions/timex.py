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
timex.mfx
Time X - z33z

This object lets you create any number of timers you want and control
them independantly. It also lets you pause the application, compare to
the current time using an expression, and get the current date/time as
numbers or month/day names.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Pause->Pause application for...

    Parameters:
    0: (In milliseconds) (TIME, Time)
    1: Hide cursor? (1 = true, 0 = false) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action1(Action):
    """
    Global timers->Start timer

    Parameters:
    0: (Zero-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        instance.objectPlayer.start_timer(index)

class Action2(Action):
    """
    Global timers->Stop timer

    Parameters:
    0: (Zero-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action3(Action):
    """
    Global timers->Set timer

    Parameters:
    0: (Zero-based) (TIME, Time)
    1: (In milliseconds) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Global timers->Reset timer

    Parameters:
    0: (Zero-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.reset_timer(self.evaluate_expression(
            self.get_parameter(0)))

class Action5(Action):
    """
    Pause->Pause application

    Parameters:
    0: Hide cursor? (1 = true, 0 = false) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action6(Action):
    """
    Pause->Set unpausing character

    Parameters:
    0: Set unpausing character (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Reset gametime

    Parameters:
    0:  ((unknown 25040))
    """

    def execute(self, instance):
        instance.objectPlayer.gameTime = self.player.time

class Action8(Action):
    """
    Global timers->Start all timers

    Parameters:
    0:  ((unknown 25045))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Global timers->Stop all timers

    Parameters:
    0:  ((unknown 25050))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action10(Action):
    """
    Global timers->Set all timers

    Parameters:
    0: (In milliseconds) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action11(Action):
    """
    Global timers->Reset all timers

    Parameters:
    0:  ((unknown 25060))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    """
    Pause->Store pausing character

    Parameters:
    0: Store pausing character (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    """
    Global timers->Toggle timer

    Parameters:
    0: (Zero-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action14(Action):
    """
    Global timers->Toggle all timers

    Parameters:
    0:  ((unknown 25075))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action15(Action):
    """
    Set gametime

    Parameters:
    0: (In milliseconds) (OBJECT, Object)
    1: Set gametime (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0) / 1000.0
        instance.objectPlayer.gameTime = self.player.time - value

# Conditions

class Condition0(Condition):
    """
    Compare time->Every...

    Parameters:
    0: (In milliseconds) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """
    last = None

    def created(self):
        self.last = self.player.frame.get_time()
    
    def check(self, instance):
        value = (self.evaluate_index(0) / 1000.0)
        if self.player.frame.get_time() - self.last >= value:
            self.last = self.last + value
            return True
        return False

class Condition1(Condition):
    """
    Compare time->Time equal to...

    Parameters:
    0: (In milliseconds) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition2(Condition):
    """
    Compare time->Time greater than...

    Parameters:
    0: (In milliseconds) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        value = (self.evaluate_index(0) / 1000.0)
        return self.player.frame.get_time() > value

class Condition3(Condition):
    """
    Compare time->Time less than...

    Parameters:
    0: (In milliseconds) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition4(Condition):
    """
    Global timers->Timer is counting?

    Parameters:
    0: (Zero-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition5(Condition):
    """
    Global timers->Timer greater than...

    Parameters:
    0: (Zero-based) (TIME, Time)
    1: (In milliseconds) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        index = self.evaluate_index(0)
        value = self.evaluate_index(1) / 1000.0
        # if value == 0.5:
            # import code
            # code.interact(local = locals())
        return instance.objectPlayer.get_time(index) > value

class Condition6(Condition):
    """
    Global timers->Timer lower than...

    Parameters:
    0: (Zero-based) (TIME, Time)
    1: (In milliseconds) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition7(Condition):
    """
    Global timers->Timer equal to...

    Parameters:
    0: (Zero-based) (TIME, Time)
    1: (In milliseconds) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition8(Condition):
    """
    Global timers->Timer different from...

    Parameters:
    0: (Zero-based) (TIME, Time)
    1: (In milliseconds) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition9(Condition):
    """
    Compare time->Time different from...

    Parameters:
    0: (In milliseconds) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition10(Condition):
    """
    Is paused?

    Parameters:
    0:  ((unknown 26055))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition11(Condition):
    """
    MMF loop->Every Nth loop

    Parameters:
    0: Every Nth loop (OBJECT, Object)
    1: Every Nth loop (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Compare time->Time since Windows started

    Parameters:
    0: (not found) ((unknown 27005))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Compare time->Time since the game started

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: Int
    """

    def get(self, instance):
        return int(instance.objectPlayer.get_game_time() * 1000)

class Expression2(Expression):
    """
    Get global timer

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        return int(instance.objectPlayer.get_time(index) * 1000)

class Expression3(Expression):
    """
    Pause->Get unpausing key as string

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Pause->Get unpausing key as value

    Parameters:
    0: (not found) ((unknown 27025))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Pause->Get pausing key as string

    Parameters:
    0: (not found) ((unknown 27030))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Pause->Get pausing key as value

    Parameters:
    0: (not found) ((unknown 27035))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Get total number of timers

    Parameters:
    0: (not found) ((unknown 27040))
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.timers)

class Expression8(Expression):
    """
    Date->Get year

    Parameters:
    0: (not found) ((unknown 27045))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    Date->Get month

    Parameters:
    0: (not found) ((unknown 27050))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression10(Expression):
    """
    Date->Get month (name)

    Parameters:
    0: (not found) ((unknown 27055))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    Date->Get day of the year

    Parameters:
    0: (not found) ((unknown 27060))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    Date->Get day of the month

    Parameters:
    0: (not found) ((unknown 27065))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression13(Expression):
    """
    Date->Get day of the week

    Parameters:
    0: (not found) ((unknown 27070))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression14(Expression):
    """
    Date->Get day of the week (name)

    Parameters:
    0: (not found) ((unknown 27075))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression15(Expression):
    """
    Date->Get hour

    Parameters:
    0: (not found) ((unknown 27080))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression16(Expression):
    """
    Date->Get minutes

    Parameters:
    0: (not found) ((unknown 27085))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression17(Expression):
    """
    Date->Get seconds

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class DefaultObject(HiddenObject):
    timers = None

    def created(self, data):
        self.gameTime = 0
        self.timers = {}
    
    def start_timer(self, index):
        if index in self.timers:
            return
        self.timers[index] = self.player.time
    
    def reset_timer(self, index):
        self.timers[index] = self.player.time
    
    def get_time(self, index):
        try:
            return self.player.time - self.timers[index]
        except KeyError:
            return 0
    
    def get_game_time(self):
        return self.player.time - self.gameTime

class timex(UserExtension):
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

extension = timex()

def get_extension():
    return extension
