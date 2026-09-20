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
Select.mfx
Select Object Extension v0.09 Beta 2 - Gareth Ben Martin of Dynamic Arcade (http://www.dynamicarcade.co.uk)
Copyright 2006-2007 Dynamic Arcade

Selects objects through conditions such as "highest alterable value A"

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions


# Conditions

class Condition0(Condition):
    """
    Select by Number of Objects->Select first X objects

    Parameters:
    0: Choose object (OBJECT, Object)
    1: Enter how many to select (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition1(Condition):
    """
    Select by Alt Value->Single object with highest Alt Value

    Parameters:
    0: Choose object (OBJECT, Object)
    1: Enter the Alt. Value (0-25) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition2(Condition):
    """
    Select by Alt Value->Single object with lowest Alt Value

    Parameters:
    0: Choose object (OBJECT, Object)
    1: Enter the Alt. Value (0-25) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition3(Condition):
    """
    Select by Number of Objects->Select last X objects

    Parameters:
    0: Choose object (OBJECT, Object)
    1: Enter how many to select (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition4(Condition):
    """
    Re-select all objects

    Parameters:
    0: Choose object (OBJECT, Object)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition5(Condition):
    """
    Select by Display Order->Select frontmost object

    Parameters:
    0: Choose object (OBJECT, Object)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition6(Condition):
    """
    Select by Display Order->Select rearmost object

    Parameters:
    0: Choose object (OBJECT, Object)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition7(Condition):
    """
    Compare to n# of selected objects

    Parameters:
    0: Choose object (OBJECT, Object)
    1: Compare to number of selected objects (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Expressions

class Expression0(Expression):
    """
    Count Selected Objects (Name)

    Parameters:
    0: Name of Object (String)
    Return type: Int
    """
    objectHandle = None
    initialized = False
    
    def get(self, instance):
        name = self.next_argument()
        if not self.initialized:
            for item in self.player.gameData.frameItems.items:
                if item.name == name:
                    self.objectHandle = item.handle
                    break
            self.initialized = True
        if self.objectHandle is None:
            return 0
        return len(self.get_instances(self.objectHandle))

class Expression1(Expression):
    """
    Count Selected Objects (Fixed Value)

    Parameters:
    0: Fixed Value of Object (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


class DefaultObject(HiddenObject):
    def created(self):
        # you should probably make your object ready here.
        # data is your property data
        pass

class Select(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        9 : Condition7,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
    }

extension = Select()

def get_extension():
    return extension
