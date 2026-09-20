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
EditBoxSel.mfx
Edit Box: Selection - Looki
Copyright 2008 Looki

Adds 'Set/get selection' features to the Edit Box

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set caret/selection

    Parameters:
    0: Edit Box (OBJECT, Object)
    1: Selection start (0 = Whole text) (EXPRESSION, ExpressionParameter)
    2: Selection end (-1 = Whole text if start is 0, else same as start) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        handle = self.get_parameter(0).objectInfo
        instances = self.get_instances(handle)
        for instance in instances:
            self.select_instances([instance], handle)
            start = self.evaluate_index(1)
            end = self.evaluate_index(2)
            caret = instance.objectPlayer.widget.caret
            caret.position = end
            if end == start:
                start = None
            caret.mark = start
        self.select_instances(instances, handle)

# Expressions

class Expression0(Expression):
    """
    Get caret/selection start

    Parameters:
    0: Fixed value of Edit Box (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression1(Expression):
    """
    Get selection end

    Parameters:
    0: Fixed value of Edit Box (Int)
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

class EditBoxSel(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
    }
    
    conditions = {
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
    }

extension = EditBoxSel()

def get_extension():
    return extension
