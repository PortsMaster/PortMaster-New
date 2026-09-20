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
kcrandom.mfx
Randomizer Object - Marcello Bastea-Forte, Cellosoft (http://www.cellosoft.com/)

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    New Random Seed
    """

    def execute(self, instance):
        instance.objectPlayer.set_seed()

class Action1(Action):
    """
    Set Random Seed

    Parameters:
    0: Total Percent (normal: 100) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_seed(
            self.evaluate_index(0))

class Action2(Action):
    """
    Activate Random Event Group

    Parameters:
    0: Total Percent (normal: 100) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        maxPercent = self.evaluate_index(0)
        if maxPercent <= 0:
            maxPercent = 100
        objectPlayer.globalPercentMax = maxPercent
        objectPlayer.globalRandom = objectPlayer.random.randrange(maxPercent)
        objectPlayer.globalPosition = 0
        for condition in self.get_conditions(Condition1):
            condition.generate()

class Action3(Action):
    """
    Activate Custom Random Event Group

    Parameters:
    0: Random Event Group Name (EXPSTRING, ExpressionParameter)
    1: Total Percent (normal: 100) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        groupName = self.evaluate_index(0)
        maxPercent = self.evaluate_index(1)
        if maxPercent <= 0:
            maxPercent = 100
        lastPercentMax = objectPlayer.currentPercentMax
        lastRandom = objectPlayer.currentRandom
        lastPosition = objectPlayer.currentPosition
        lastGroupName = objectPlayer.currentGroupName
        
        objectPlayer.groupName = groupName
        objectPlayer.currentPercentMax = maxPercent
        objectPlayer.currentRandom = objectPlayer.random.randrange(maxPercent)
        objectPlayer.currentPosition = 0
        for condition in self.get_conditions(Condition2):
            condition.generate()
        objectPlayer.currentPercentMax = lastPercentMax
        objectPlayer.currentRandom = lastRandom
        objectPlayer.currentPosition = lastPosition
        objectPlayer.groupName = lastGroupName

# Conditions

class Condition0(Condition):
    """
    Random Event

    Parameters:
    0: Percent (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        return instance.objectPlayer.random.randrange(100
            ) < self.evaluate_index(0)

class Condition1(Condition):
    """
    Random Event Group

    Parameters:
    0: Percent (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        objectPlayer = instance.objectPlayer
        p = self.evaluate_index(0)
        objectPlayer.globalPosition += p
        return (objectPlayer.globalRandom >= objectPlayer.globalPosition - p and
            objectPlayer.globalRandom < objectPlayer.globalPosition)

class Condition2(Condition):
    """
    Custom Random Event Group

    Parameters:
    0: Random Event Group Name (EXPSTRING, ExpressionParameter)
    1: Percent (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        name = self.evaluate_index(0)
        if name != instance.objectPlayer.groupName:
            return
        objectPlayer = instance.objectPlayer
        p = self.evaluate_index(1)
        objectPlayer.globalPosition += p
        return (objectPlayer.globalRandom >= objectPlayer.globalPosition - p and
            objectPlayer.globalRandom < objectPlayer.globalPosition)

# Expressions

class Expression0(Expression):
    """
    Random Number

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.random.randrange(self.next_argument())

class Expression1(Expression):
    """
    Random Number (range)

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.random.randrange(self.next_argument(), 
            self.next_argument())

class Expression2(Expression):
    """
    Get Last Seed
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.lastSeed

class Expression3(Expression):
    """
    Random Letter
    Return type: Int
    """

    def get(self, instance):
        return chr(instance.objectPlayer.random.randrange(97, 122))

class Expression4(Expression):
    """
    Random Alphanumeric Character
    Return type: Int
    """

    def get(self, instance):
        val = instance.objectPlayer.random.randrange(36)
        if val < 10:
            val += 48
        else:
            val += 87
        return chr(val)

class Expression5(Expression):
    """
    Random Character
    Return type: Int
    """

    def get(self, instance):
        return chr(instance.objectPlayer.random.randrange(256))

class Expression6(Expression):
    """
    Character/String functions->Ascii to Char

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        return chr(self.next_argument())

class Expression7(Expression):
    """
    Character/String functions->Char to Ascii

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        return ord(self.next_argument())

class Expression8(Expression):
    """
    Character/String functions->To Uppercase

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        return self.next_argument().upper()

class Expression9(Expression):
    """
    Character/String functions->To Lowercase

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        return self.next_argument().lower()

import random
import time

class DefaultObject(HiddenObject):
    globalPosition = 0
    globalRandom = 0
    globalPercentMax = 0
    currentPercentMax = 0
    currentRandom = 0
    currentPosition = 0
    groupName = ''
    
    lastSeed = None
    def created(self, data):
        self.random = random.Random()
    
    def set_seed(self, seed = None):
        if seed is None:
            seed = int(time.time() * 1000)
        self.lastSeed = seed
        self.random.seed(seed)

class kcrandom(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
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

extension = kcrandom()

def get_extension():
    return extension
