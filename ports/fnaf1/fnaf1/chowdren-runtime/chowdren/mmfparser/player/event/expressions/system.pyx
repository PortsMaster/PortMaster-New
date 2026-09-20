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

from mmfparser.player.event.expressions.common cimport Expression
from mmfparser.player.event.conditions.system import OnLoop
from mmfparser.player.common cimport (make_color_number, get_color_number,
    sin, cos, fabs, radians)
from mmfparser.player.event.player cimport Loop

import random
import os
import math
import sys

cdef class Random(Expression):
    cdef object evaluate(self):
        try:
            return random.randrange(0, self.next_argument())
        except ValueError:
            return 0

cdef class Abs(Expression):
    cdef object evaluate(self):
        return fabs(self.next_argument())

cdef class NewLine(Expression):
    cdef object evaluate(self):
        return '\r\n'

cdef class UpperString(Expression):
    cdef object evaluate(self):
        return self.next_argument().upper()

cdef class LowerString(Expression):
    cdef object evaluate(self):
        return self.next_argument().lower()

cdef class LeftString(Expression):
    cdef object evaluate(self):
        cdef str value = self.next_argument()
        cdef int index = self.next_argument()
        return value[:index]

cimport cython

cdef class RightString(Expression):
    @cython.wraparound(True)
    cdef object evaluate(self):
        cdef str value = self.next_argument()
        cdef int index = self.next_argument()
        return value[-index:]

cdef class MidString(Expression):
    cdef object evaluate(self):
        cdef str value = self.next_argument()
        cdef int index = self.next_argument()
        cdef int count = self.next_argument()
        return value[index:index+count]

cdef class Asin(Expression):
    cdef object evaluate(self):
        return math.degrees(math.asin(self.next_argument()))

cdef class Acos(Expression):
    cdef object evaluate(self):
        return math.degrees(math.acos(self.next_argument()))

cdef class Atan(Expression):
    cdef object evaluate(self):
        return math.degrees(math.atan(self.next_argument()))

cdef class Atan2(Expression):
    cdef object evaluate(self):
        y = self.next_argument()
        x = self.next_argument()
        return math.degrees(math.atan2(y, x))

cdef class Sin(Expression):
    cdef object evaluate(self):
        return sin(radians(self.next_argument()))

cdef class Cos(Expression):
    cdef object evaluate(self):
        return cos(radians(self.next_argument()))
        
cdef class Exp(Expression):
    cdef object evaluate(self):
        return math.exp(self.next_argument())

cdef class Tan(Expression):
    cdef object evaluate(self):
        return math.tan(radians(self.next_argument()))

cdef class Floor(Expression):
    cdef object evaluate(self):
        return math.floor(self.next_argument())

cdef class Log(Expression):
    cdef object evaluate(self):
        return math.log10(self.next_argument())

cdef class Ln(Expression):
    cdef object evaluate(self):
        return math.log(self.next_argument())
        
cdef class Min(Expression):
    cdef object evaluate(self):
        value1 = self.next_argument()
        value2 = self.next_argument()
        if value1 > value2:
            return value2
        else:
            return value1

cdef class Max(Expression):
    cdef object evaluate(self):
        value1 = self.next_argument()
        value2 = self.next_argument()
        return max(value1, value2)

cdef class SquareRoot(Expression):
    cdef object evaluate(self):
        return math.sqrt(self.next_argument())
        
cdef class Ceil(Expression):
    cdef object evaluate(self):
        return int(math.ceil(self.next_argument()))

cdef class Round(Expression):
    cdef object evaluate(self):
        return int(round(self.next_argument()))

cdef class Bin(Expression):
    cdef object evaluate(self):
        return bin(self.next_argument())
        
cdef class Hex(Expression):
    cdef object evaluate(self):
        value = hex(self.next_argument())
        if value.endswith('L'):
            value = value[:-1]
        return '0x' + value[2:].upper()

cdef class Not(Expression):
    cdef object evaluate(self):
        return ~<int>(self.next_argument())

cdef class ApplicationDrive(Expression):
    cdef object evaluate(self):
        return os.path.splitdrive(os.getcwd())[0]
        
cdef class ApplicationDirectory(Expression):
    cdef object evaluate(self):
        return os.path.splitdrive(os.getcwd())[1] + os.path.sep

cdef class ApplicationPath(Expression):
    cdef object evaluate(self):
        return os.getcwd() + os.path.sep
        
cdef class TemporaryPath(Expression):
    cdef object evaluate(self):
        return os.getcwd() + os.path.sep

cdef class ApplicationFilename(Expression):
    cdef object evaluate(self):
        return os.path.split(sys.argv[0])[1]

cdef class GlobalValue(Expression):
    cdef object evaluate(self):
        return self.player.globals.get_value(self.loader.loader.value)

cdef class GlobalString(Expression):
    cdef object evaluate(self):
        return self.player.globals.get_string(self.loader.loader.value)

cdef class GlobalValueExpression(Expression):
    cdef object evaluate(self):
        return self.player.globals.get_value(self.next_argument() - 1)
        
cdef class GlobalStringExpression(Expression):
    cdef object evaluate(self):
        return self.player.globals.get_string(self.next_argument() - 1)

cdef class XLeftFrame(Expression):
    cdef object evaluate(self):
        return self.player.x1

cdef class XRightFrame(Expression):
    cdef object evaluate(self):
        return self.player.x2

cdef class YTopFrame(Expression):
    cdef object evaluate(self):
        return self.player.y1

cdef class YBottomFrame(Expression):
    cdef object evaluate(self):
        return self.player.y2

cdef class LoopIndex(Expression):
    cdef str name
        
    cdef object evaluate(self):
        cdef str name = self.next_argument()
        try:
            return (<Loop>self.eventPlayer.loops[name.lower()]).index
        except KeyError:
            return 0

cdef class StringLength(Expression):
    cdef object evaluate(self):
        return len(self.next_argument())

cdef class Find(Expression):
    cdef object evaluate(self):
        value = self.next_argument()
        search = self.next_argument()
        start = self.next_argument()
        return value.find(search, start)

cdef class ReverseFind(Expression):
    cdef object evaluate(self):
        value = self.next_argument()
        search = self.next_argument()
        last = self.next_argument()
        return value.rfind(search, 0, last)

cdef class GetRGB(Expression):
    cdef object evaluate(self):
        cdef int r = self.next_argument()
        cdef int g = self.next_argument()
        cdef int b = self.next_argument()
        return make_color_number(r, g, b)

cdef class GetRed(Expression):
    cdef object evaluate(self):
        cdef int value = self.next_argument()
        return get_color_number(value)[0]

cdef class GetGreen(Expression):
    cdef object evaluate(self):
        cdef int value = self.next_argument()
        return get_color_number(value)[1]

cdef class GetBlue(Expression):
    cdef object evaluate(self):
        cdef int value = self.next_argument()
        return get_color_number(value)[2]