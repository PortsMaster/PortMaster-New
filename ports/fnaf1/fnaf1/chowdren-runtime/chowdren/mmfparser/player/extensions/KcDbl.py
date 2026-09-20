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
KcDbl.mfx
Double-Precision Calculator object - ClickTeam (http://www.clickteam.com)

Allows you to perform simple calculations on double-precision floating
point numbers (16 significant digits). For Pro version only.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set Format->&Standard

    Parameters:
    0:  ((unknown 25001))
    """

    def execute(self, instance):
        instance.objectPlayer.reset()

class Action1(Action):
    """
    Set Format->N digits

    Parameters:
    0: Enter the number of digits (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        val = self.evaluate_index(0)
        if val <= 0:
            val = 1
        if val > 256:
            val = 256
        instance.objectPlayer.decimals = -1
        instance.objectPlayer.digits = val

class Action2(Action):
    """
    Set Format->N digits after decimal point

    Parameters:
    0: Enter the number of digits after the decimal point (OBJECT, Object)
    1: N digits after decimal point (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        val = self.evaluate_index(0)
        if val <= 0:
            val = 1
        if val > 256:
            val = 256
        instance.objectPlayer.decimals = val

# Expressions

class Expression0(Expression):
    """
    &Add

    Parameters:
    0: First number string (Global)
    1: Second number string (String)
    Return type: String
    """

    def get(self, instance):
        val1 = float(self.next_argument())
        val2 = float(self.next_argument())
        return instance.objectPlayer.to_string(val1 + val2)

class Expression1(Expression):
    """
    &Subtract

    Parameters:
    0: First number string (Global)
    1: Second number string (String)
    Return type: String
    """

    def get(self, instance):
        val1 = float(self.next_argument())
        val2 = float(self.next_argument())
        return instance.objectPlayer.to_string(val1 - val2)

class Expression2(Expression):
    """
    &Multiply

    Parameters:
    0: First number string (Global)
    1: Second number string (String)
    Return type: String
    """

    def get(self, instance):
        val1 = float(self.next_argument())
        val2 = float(self.next_argument())
        return instance.objectPlayer.to_string(val1 * val2)

class Expression3(Expression):
    """
    &Divide

    Parameters:
    0: First number string (Global)
    1: Second number string (String)
    Return type: String
    """

    def get(self, instance):
        val1 = float(self.next_argument())
        val2 = float(self.next_argument())
        return instance.objectPlayer.to_string(val1 / val2)

class Expression4(Expression):
    """
    Format ...->N digits

    Parameters:
    0: Number string (Global)
    1: Number of digits (String)
    Return type: String
    """

    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        return a

class Expression5(Expression):
    """
    Format ...->N digits after decimal point

    Parameters:
    0: Number string (Global)
    1: Number of decimals (String)
    Return type: String
    """

    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        return a

class DefaultObject(HiddenObject):
    def created(self, data):
        self.reset()
    
    def reset(self):
        self.digits = 32
        self.decimals = -1
    
    def to_string(self, val):
        if self.decimals == -1:
            return str(val)
        else:
            return ('%%.%sf' % self.decimals) % value

class KcDbl(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
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

extension = KcDbl()

def get_extension():
    return extension
