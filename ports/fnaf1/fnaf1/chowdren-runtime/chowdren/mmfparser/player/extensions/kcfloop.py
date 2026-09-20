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
kcfloop.mfx
Fast Loop Object - Marcello Bastea-Forte, Cellosoft (http://www.cellosoft.com/)

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Start Loop

    Parameters:
    0: Slot number (0-29) (EXPRESSION, ExpressionParameter)
    1: Number of loops (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action1(Action):
    """
    Single Loop

    Parameters:
    0: Slot number (0-29) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action2(Action):
    """
    Stop Loop

    Parameters:
    0: Slot number (0-29) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action3(Action):
    """
    Advanced->Adjust Loop Position

    Parameters:
    0: Slot number (0-29) (EXPRESSION, ExpressionParameter)
    1: New loop position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Advanced->Redraw Frame
    """

    def execute(self, instance):
        print 'redrawing frame?'

class Action5(Action):
    """
    Advanced->Set Loop Pause

    Parameters:
    0: Number of milliseconds (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Loop Trigger

    Parameters:
    0: Slot number (0-29) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Compare Loop Position...

    Parameters:
    0: Slot number (0-29) (EXPRESSION, ExpressionParameter)
    1: Compare to loop position... (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition2(Condition):
    """
    Loop is Infinite

    Parameters:
    0: Slot number (0-29) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Get Loop Step

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Get Number of Loop Steps

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


class DefaultObject(HiddenObject):
    def created(self, data):
        # you should probably make your object ready here.
        # data is your property data
        pass

class kcfloop(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
    }

extension = kcfloop()

def get_extension():
    return extension
