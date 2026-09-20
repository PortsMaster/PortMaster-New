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
Stochastic Utility.mfx
Stochastic Utility 1.1 - Nicklas Nygren (http://nifflas.ni2.se)
Does some random Nifflas-y stuff!

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class SetRandomSeed(Action):
    def execute(self, instance):
        instance.objectPlayer.random.seed(
            self.evaluate_index(0))

class SetRandomSeedTimer(Action):
    def execute(self, instance):
        instance.objectPlayer.random.seed()

# Conditions

def compare(val1, op, val2):
    if op == 0:
        return val1 == val2
    elif op == 1:
        return val1 != val2
    elif op == 2:
        return val1 > val2
    elif op == 3:
        return val1 < val2
    elif op == 4:
        return val1 >= val2
    elif op == 5:
        return val1 <= val2
    return False

class CompareNumbers(Condition):
    def execute(self, instance):
        val1 = self.evaluate_index(0)
        val2 = self.evaluate_index(1)
        op = self.evaluate_index(2)
        return compare(val1, op, val2)

# Expressions

import math

def order(a, b):
    if a > b:
        return b, a
    return a, b

class RandomNumberInt(Expression):
    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        a, b = order(a, b)
        return instance.objectPlayer.random.randint(int(a), int(b))

class RandomNumberFloat(Expression):
    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        a, b = order(a, b)
        return instance.objectPlayer.random.uniform(a, b)

def limit(val, minimum, maximum):
    if minimum < maximum:
        return max(minimum, min(maximum, val))
    return max(maximum, min(minimum, val))

class LimitFloat(Expression):
    def get(self, instance):
        val = self.next_argument()
        a = self.next_argument()
        b = self.next_argument()
        return limit(val, a, b)

class Substring(Expression):
    def get(self, instance):
        val = self.next_argument()
        start = self.next_argument()
        size = self.next_argument()
        return val[start:(start+size)]

def nearest(val, minimum, maximum):
    if minimum > val:
        a = minimum - val
    else:
        a = val - minimum
    if maximum > val:
        b = maximum - val
    else:
        b = val - maximum
    if a > b:
        return maximum
    else:
        return minimum

class NearestFloat(Expression):
    def get(self, instance):
        val = self.next_argument()
        minimum = self.next_argument()
        maximum = self.next_argument()
        return nearest(val, minimum, maximum)

def normalise(val, minimum, maximum, limitrange):
    val = float(val - minimum) / (maximum - minimum)
    if limitrange != 0:
        return limit(val, 0, 1)
    return val

class NormaliseFloat(Expression):
    def get(self, instance):
        val = self.next_argument()
        a = self.next_argument()
        b = self.next_argument()
        limitrange = self.next_argument()
        return normalise(val, a, b, limitrange)

def modify_range(val, minimum, maximum, new_minimum, new_maximum, limitrange):
    val = new_minimum + float(val - minimum) * (new_maximum - new_minimum
        ) / (maximum - minimum)
    if limitrange != 0:
        return limit(val, new_minimum, new_maximum)
    return val

class ModifyRangeFloat(Expression):
    def get(self, instance):
        val = self.next_argument()
        a = self.next_argument()
        b = self.next_argument()
        new_minimum = self.next_argument()
        new_maximum = self.next_argument()
        limitrange = self.next_argument()
        return modify_range(val, a, b, new_minimum, new_maximum, limitrange)

def wave(waveform, value, cycle_start, cycle_end, minimum, maximum):
    if waveform == 0:
        return modify_range(math.sin(modify_range(value, cycle_start, 
            cycle_end, 0, 2 * math.pi, 0)), -1, 1, minimum, maximum, 0)
    elif waveform == 1:
        return modify_range(math.cos(modify_range(value, cycle_start, 
            cycle_end, 0, 2 * math.pi, 0)), -1, 1, minimum, maximum, 0)
    elif waveform == 2:
        return uber_mod(modify_range(value, cycle_start, cycle_end, minimum,
            maximum, 0), minimum, maximum)
    elif waveform == 3:
        return uber_mod(modify_range(value, cycle_start, cycle_end, maximum,
            minimum, 0), minimum, maximum)
    elif waveform == 4:
        return mirror(modify_range(value, cycle_start, cycle_start + (
            cycle_end - cycle_start) / 2.0, minimum, maximum, 0), minimum,
            maximum)
    elif waveform == 5:
        if uber_mod(value, cycle_start, cycle_end) < cycle_start + (
        cycle_end - cycle_start) / 2.0:
            return minimum
        return maximum
    return 0

class WaveFloat(Expression):
    def get(self, instance):
        waveform = self.next_argument()
        value = self.next_argument()
        cycle_start = self.next_argument()
        cycle_end = self.next_argument()
        minimum = self.next_argument()
        maximum = self.next_argument()
        return wave(waveform, value, cycle_start, cycle_end, minimum, maximum)

def euclidean_mod(dividend, divisor):
    return math.fmod(math.fmod(dividend, divisor) + divisor, divisor)

class EuclideanModuloFloat(Expression):
    def get(self, instance):
        dividend = self.next_argument()
        divisor = self.next_argument()
        return euclidean_mod(dividend, divisor)

def uber_mod(dividend, lower, upper):
    return modify_range(euclidean_mod(normalise(dividend, lower, upper, 0), 1),
        0, 1, lower, upper, 0)

class UberModuloFloat(Expression):
    def get(self, instance):
        dividend = self.next_argument()
        lower = self.next_argument()
        upper = self.next_argument()
        return uber_mod(dividend, lower, upper)

def interpolate(value, from_val, to_val, limitrange):
    value = from_val + value * (to_val - from_val)
    if limitrange != 0:
        return limit(value, from_val, to_val)
    return value

class InterpolateFloat(Expression):
    def get(self, instance):
        value = self.next_argument()
        from_val = self.next_argument()
        to_val = self.next_argument()
        limitrange = self.next_argument()
        return interpolate(value, from_val, to_val, limitrange)

def mirror(value, from_val, to_val):
    if from_val < to_val:
        return from_val + math.fabs(euclidean_mod(value - to_val, 
            (to_val - from_val) * 2) - (to_val - from_val))
    else:
        return to_val + math.fabs(euclidean_mod(value - from_val, 
            (from_val - to_val) * 2) - (from_val - to_val))

class MirrorFloat(Expression):
    def get(self, instance):
        value = self.next_argument()
        from_val = self.next_argument()
        to_val = self.next_argument()
        return mirror(value, from_val, to_val)

def round(val):
    if val > 0:
        return int(math.floor(val + 0.5))
    return int(math.ceil(val - 0.5))

class LimitInt(Expression):
    def get(self, instance):
        return round(limit(self.next_argument(), self.next_argument(),
            self.next_argument()))

class NearestInt(Expression):
    def get(self, instance):
        return round(nearest(self.next_argument(), self.next_argument(),
            self.next_argument()))

class NormaliseInt(Expression):
    def get(self, instance):
        return round(normalise(self.next_argument(), self.next_argument(),
            self.next_argument(), self.next_argument()))

class ModifyRangeInt(Expression):
    def get(self, instance):
        return round(modify_range(self.next_argument(), self.next_argument(),
            self.next_argument(), self.next_argument(), self.next_argument(),
            self.next_argument()))

class WaveInt(Expression):
    def get(self, instance):
        return round(wave(self.next_argument(), self.next_argument(),
            self.next_argument(), self.next_argument(), self.next_argument(),
            self.next_argument()))

class EuclideanModuloInt(Expression):
    def get(self, instance):
        return round(euclidean_mod(self.next_argument(), self.next_argument()))

class UberModuloInt(Expression):
    def get(self, instance):
        return round(uber_mod(self.next_argument(), self.next_argument(),
            self.next_argument()))

class InterpolateInt(Expression):
    def get(self, instance):
        return round(interpolate(self.next_argument(), self.next_argument(),
            self.next_argument(), self.next_argument()))

class MirrorInt(Expression):
    def get(self, instance):
        return round(interpolate(self.next_argument(), self.next_argument(),
            self.next_argument()))

class CompareExpression(Expression):
    def get(self, instance):
        val1 = self.next_argument()
        val2 = self.next_argument()
        op = self.next_argument()
        ret_true = self.next_argument()
        ret_false = self.next_argument()
        if compare(val1, op, val2):
            return ret_true
        else:
            return ret_false

class CompareNumbersFloat(CompareExpression):
    pass

class CompareNumbersInt(CompareExpression):
    pass

class CompareNumbersString(CompareExpression):
    pass

def approach(value, amount, target):
    if value < target:
        return min(value + amount, target)
    else:
        return max(value - amount, target)

class ApproachFloat(Expression):
    def get(self, instance):
        return approach(self.next_argument(), self.next_argument(),
            self.next_argument())

class ApproachInt(Expression):
    def get(self, instance):
        return round(approach(self.next_argument(), self.next_argument(),
            self.next_argument()))

import random

class DefaultObject(HiddenObject):
    def created(self, data = None):
        self.random = random.Random()

class StochasticUtility(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : SetRandomSeed,
        1 : SetRandomSeedTimer
    }
    
    conditions = {
        0 : CompareNumbers
    }
    
    expressions = {
        0 : RandomNumberInt,
        1 : RandomNumberFloat,
        2 : LimitFloat,
        3 : Substring,
        4 : NearestFloat,
        5 : NormaliseFloat,
        6 : ModifyRangeFloat,
        7 : WaveFloat,
        8 : EuclideanModuloFloat,
        9 : UberModuloFloat,
        10 : InterpolateFloat,
        11 : MirrorFloat,
        12 : LimitInt,
        13 : NearestInt,
        14 : NormaliseInt,
        15 : ModifyRangeInt,
        16 : WaveInt,
        17 : EuclideanModuloInt,
        18 : UberModuloInt,
        19 : InterpolateInt,
        20 : MirrorInt,
        21 : CompareNumbersFloat,
        22 : CompareNumbersInt,
        23 : CompareNumbersString,
        24 : ApproachFloat,
        25 : ApproachInt
    }

extension = StochasticUtility()

def get_extension():
    return extension
