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
IIF.mfx
Immediate If Object - Cragmyre and Matt Galanto (http://www.clickteam.com)
Performs conditionals within expressions.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

def compare(a, op, b):
    if not op:
        return a == b
    ch1 = op[0]
    try:
        ch2 = op[1]
    except IndexError:
        ch2 = None
    if ch1 == '=':
        return a == b
    if ch1 == '!':
        return a != b
    if ch1 == '>':
        if ch2 == '=':
            return a >= b
        return a > b
    if ch1 == '<':
        if ch2 == '=':
            return a <= b
        if ch2 == '>':
            return a != b
        return a < b
    return a == b

class CompareExpression(Expression):
    def get(self, instance):
        a = self.next_argument()
        op = self.next_argument()
        b = self.next_argument()
        ret = compare(a, op, b)
        instance.objectPlayer.lastComparison = ret
        a_result = self.next_argument()
        b_result = self.next_argument()
        if ret:
            return a_result
        else:
            return b_result

class Expression0(CompareExpression):
    """
    Return Types...->Integers->Compare Integers(n,operator,n,true,false)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    3:  (Int)
    4:  (Int)
    Return type: Int
    """

class Expression1(CompareExpression):
    """
    Return Types...->Integers->Compare Strings(a,operator,a,true,false)

    Parameters:
    0:  (String)
    1:  (String)
    2:  (String)
    3:  (Int)
    4:  (Int)
    Return type: Int
    """

class Expression2(CompareExpression):
    """
    Return Types...->Integers->Compare Floats(n.n,operator,n.n,true,false)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    3:  (Int)
    4:  (Int)
    Return type: Int
    """

class Expression3(CompareExpression):
    """
    Return Types...->Strings->Compare Integers$(n,operator,n,true,false)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    3:  (String)
    4:  (String)
    Return type: String
    """

class Expression4(CompareExpression):
    """
    Return Types...->Strings->Compare Strings$(a,operator,a,true,false)

    Parameters:
    0:  (String)
    1:  (String)
    2:  (String)
    3:  (String)
    4:  (String)
    Return type: String
    """

class Expression5(CompareExpression):
    """
    Return Types...->Strings->Compare Floats$(n.n,operator,n.n,true,false)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    3:  (String)
    4:  (String)
    Return type: String
    """

class Expression6(CompareExpression):
    """
    Return Types...->Floats->Compare IntegersF(n,operator,n,true,false)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    3:  (Int)
    4:  (Int)
    Return type: Float
    """

class Expression7(CompareExpression):
    """
    Return Types...->Floats->Compare StringsF(a,operator,a,true,false)

    Parameters:
    0:  (String)
    1:  (String)
    2:  (String)
    3:  (Int)
    4:  (Int)
    Return type: Float
    """

class Expression8(CompareExpression):
    """
    Return Types...->Floats->Compare FloatsF(n.n,operator,n.n,true,false)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    3:  (Int)
    4:  (Int)
    Return type: Float
    """

class CompareBoolExpression(Expression):
    def get(self, instance):
        ret = self.next_argument()
        a_result = self.next_argument()
        b_result = self.next_argument()
        instance.objectPlayer.lastComparison = ret
        if ret:
            return a_result
        else:
            return b_result

class Expression9(CompareBoolExpression):
    """
    Return Types...->Integers->Compare Bool(b,true,false)

    Parameters:
    0:  (Int)
    1:  (Int)
    2:  (Int)
    Return type: Int
    """

class Expression10(CompareBoolExpression):
    """
    Return Types...->Strings->Compare Bool$(b,true,false)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (String)
    Return type: String
    """

class Expression11(CompareBoolExpression):
    """
    Return Types...->Floats->Compare BoolF(b,true,false)

    Parameters:
    0:  (Int)
    1:  (Int)
    2:  (Int)
    Return type: Float
    """

class ReturnBoolExpression(Expression):
    def get(self, instance):
        a = self.next_argument()
        op = self.next_argument()
        b = self.next_argument()
        ret = compare(a, op, b)
        instance.objectPlayer.lastComparison = ret
        return int(ret)

class Expression12(ReturnBoolExpression):
    """
    Return Types...->Bool->Compare IntegersB(n,operator,n)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    Return type: Int
    """

class Expression13(ReturnBoolExpression):
    """
    Return Types...->Bool->Compare StringsB(a,operator,a)

    Parameters:
    0:  (String)
    1:  (String)
    2:  (String)
    Return type: Int
    """

class Expression14(ReturnBoolExpression):
    """
    Return Types...->Bool->Compare FloatsB(n.n,operator,n.n)

    Parameters:
    0:  (Int)
    1:  (String)
    2:  (Int)
    Return type: Int
    """

class Expression15(Expression):
    """
    Result of Last Comparison
    Return type: Int
    """

    def get(self, instance):
        return int(instance.objectPlayer.lastComparison)

class DefaultObject(HiddenObject):
    def created(self, data):
        pass

class IIF(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
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
    }

extension = IIF()

def get_extension():
    return extension
