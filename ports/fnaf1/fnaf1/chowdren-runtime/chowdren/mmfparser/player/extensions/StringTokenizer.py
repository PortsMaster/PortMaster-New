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
StringTokenizer.mfx
String tokenizer - AquadaSoft/Jamie McLaughlin (http://www.aquadasoft.com)

Can split a string up based on single character delimiters. Requested
by Nifflas.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Split string

    Parameters:
    0: String (EXPSTRING, ExpressionParameter)
    1: Delimiters (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_string(
            self.evaluate_index(0),
            self.evaluate_index(1))

class Action1(Action):
    """
    Split string (2D)

    Parameters:
    0: String (EXPSTRING, ExpressionParameter)
    1: X delimiters (EXPSTRING, ExpressionParameter)
    2: Y delimiters (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_string_2d(
            self.evaluate_index(0),
            self.evaluate_index(1),
            self.evaluate_index(2))

# Expressions

class Expression0(Expression):
    """
    Number of elements
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.get_elements())

class Expression1(Expression):
    """
    Get element

    Parameters:
    0: Index (0 based) (Int)
    Return type: String
    """

    def get(self, instance):
        try:
            return instance.objectPlayer.get_elements()[self.next_argument()]
        except IndexError:
            return ''

class Expression2(Expression):
    """
    Get element (2D)

    Parameters:
    0: X index (0 based) (Int)
    1: Y index (0 based) (Int)
    Return type: String
    """

    def get(self, instance):
        try:
            return instance.objectPlayer.get_2d_elements()[
                self.next_argument()][self.next_argument()]
        except IndexError:
            return ''

class Expression3(Expression):
    """
    Number of X elements (2D)
    Return type: Int
    """

    def get(self, instance):
        count = 0
        for xlist in instance.objectPlayer.get_2d_elements():
            count += len(xlist)
        return count

class Expression4(Expression):
    """
    Number of Y elements (2D)

    Parameters:
    0: X index (0 based) (Int)
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.get_2d_elements())

def split(s, seps, keep_delimiters = False):
    res = [s]
    for sep in seps:
        s, res = res, []
        for seq in s:
            res += seq.split(sep)
            if keep_delimiters:
                res += sep
    return res

class DefaultObject(HiddenObject):
    elements = None
    elements_2d = None
    def created(self):
        pass
    
    def get_2d_elements(self):
        return self.elements_2d or []
    
    def get_elements(self):
        return self.elements or []
    
    def set_string(self, value, delimiters):
        self.elements = split(value, delimiters)
        self.elements_2d = None
    
    def set_string_2d(self, value, xdelimiters, ydelimiters):
        list_2d = []
        for item in split(value, ydelimiters):
            list_2d.append(split(item, xdelimiters))
        self.elements_2d = list_2d
        self.elements = None

class StringTokenizer(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
    }
    
    conditions = {
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
    }

extension = StringTokenizer()

def get_extension():
    return extension
