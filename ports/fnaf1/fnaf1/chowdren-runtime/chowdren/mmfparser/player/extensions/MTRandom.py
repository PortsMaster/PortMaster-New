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
MTRandom.mfx
Mersenne Twister Random object - Chris Branch (http://www.starfishgames.co.uk)

The Mersenne Twister random number generator is a highly optimised
random generator; it can generate a number within any range, including
decimal numbers.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Seed->Set seed to system time

    Parameters:
    0: Set seed to %0 ((unknown 25010))
    """

    def execute(self, instance):
        instance.objectPlayer.random.seed()

class Action1(Action):
    """
    Seed->Set seed using one number

    Parameters:
    0: Enter a seed from -2147483648 to 2147483647 (OBJECT, Object)
    1: Set seed to ( %0, %1) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.random.seed(
            self.evaluate_index(0))

class SeedAction(Action):
    def execute(self, instance):
        seeds = [self.evaluate_expression(parameter)
            for parameter in self.parameters]
        instance.objectPlayer.seed_array(seeds)

class Action2(SeedAction):
    """
    Seed->Set seed using 2 numbers

    Parameters:
    0: Enter 1st seed (TIME, Time)
    1: Enter 2nd seed (EXPRESSION, ExpressionParameter)
    """

class Action3(SeedAction):
    """
    Seed->Set seed using 3 numbers

    Parameters:
    0: Enter 1st seed (SHORT, Short)
    1: Enter 2nd seed (EXPRESSION, ExpressionParameter)
    """

class Action4(SeedAction):
    """
    Seed->Set seed using 4 numbers

    Parameters:
    0: Enter 1st seed (SHORT, Short)
    1: Enter 2nd seed (EXPRESSION, ExpressionParameter)
    """

class Action5(SeedAction):
    """
    Seed->Set seed using 6 numbers

    Parameters:
    0: Enter 1st seed (SAMPLE, Sample)
    1: Enter 2nd seed (EXPRESSION, ExpressionParameter)
    """

class Action6(SeedAction):
    """
    Seed->Set seed using 8 numbers

    Parameters:
    0: Enter 1st seed ((unknown 8))
    1: Enter 2nd seed (EXPRESSION, ExpressionParameter)
    """

class Action7(SeedAction):
    """
    Seed->Set seed using 10 numbers

    Parameters:
    0: Enter 1st seed (SHORT, Short)
    1: Enter 2nd seed (EXPRESSION, ExpressionParameter)
    """

class Action8(Action):
    """
    Expire one number

    Parameters:
    0: Expire %0 numbers ((unknown 25090))
    """

    def execute(self, instance):
        instance.objectPlayer.random.random()

class Action9(Action):
    """
    Expire X numbers

    Parameters:
    0: Amount of numbers to expire (OBJECT, Object)
    1: Expire X numbers (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        for _ in xrange(self.evaluate_index(0)):
            instance.objectPlayer.random.random()

# Expressions

class Expression0(Expression):
    """
    Random float, 0-1

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: Float
    """

    def get(self, instance):
        return instance.objectPlayer.random.uniform(0.0, 1.0)

class Expression1(Expression):
    """
    Random float, 0-1 (excludes 1)

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: Float
    """

    def get(self, instance):
        return instance.objectPlayer.random.random()

class Expression2(Expression):
    """
    Random float, define range

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        return instance.objectPlayer.random.uniform(self.next_argument(),
            self.next_argument())

class Expression3(Expression):
    """
    Random float, define range (excludes upperbound)

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        rand = instance.objectPlayer.random.random()
        return a + (a - b) * rand

class Expression4(Expression):
    """
    Random integer

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.random.randint(self.next_argument(),
            self.next_argument())

class Expression5(Expression):
    """
    Random integer (excludes upperbound)

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.random.randint(self.next_argument(),
            self.next_argument())

import random

# Python's random implementation is already Mersenne Twisted, so ;-)

class DefaultObject(HiddenObject):
    def created(self, data):
        self.random = random.Random()
        seedValues = data.readByte() == 1
        seed = [data.readInt() for _ in xrange(10)]
        if seedValues:
            self.seed_array(seed)
    
    def seed_array(self, values):
        val = 0
        for val in reversed(values):
            val = (val << 32) | val
        self.random.seed(val)

class MTRandom(UserExtension):
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
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
    }

extension = MTRandom()

def get_extension():
    return extension
