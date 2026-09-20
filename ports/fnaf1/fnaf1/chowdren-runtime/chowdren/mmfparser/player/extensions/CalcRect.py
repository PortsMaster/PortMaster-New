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
CalcRect.mfx
Calculate Text Rect object - Chris Branch (http://www.starfishgames.co.uk)

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set font

    Parameters:
    0: Name of the font (EXPSTRING, ExpressionParameter)
    1: Size of the font (pt) (EXPRESSION, ExpressionParameter)
    2: Style - add together: 1 = bold, 2 = italic, 4 = underline (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_font(
            self.evaluate_index(0),
            self.evaluate_index(1),
            self.evaluate_index(2)
        )

class Action1(Action):
    """
    Set text

    Parameters:
    0: Text to calculate size of (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_text(
            self.evaluate_index(0)
        )

class Action2(Action):
    """
    Set maximum width (multiline text)

    Parameters:
    0: Maximum width in pixels (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_max_width(
            self.evaluate_index(0)
        )

class Action3(Action):
    """
    Calculate area
    """

    def execute(self, instance):
        instance.objectPlayer.calculate()


# Conditions


# Expressions

class Expression0(Expression):
    """
    Get text width
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_width()

class Expression1(Expression):
    """
    Get text height
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_height()


class DefaultObject(HiddenObject):
    name = size = bold = italic = underline = None
    max_width = None
    text = ''
    calculatedWidth = calculatedHeight = 0
    
    def created(self, data):
        return
    
    def set_font(self, name, size, flags):
        self.name = name
        self.size = size
        self.bold = (flags & 1) == 1
        self.italic = (flags & 2) == 2
        self.underline = (flags & 4) == 4
    
    def calculate(self):
        if self.name is None:
            return
        from pyglet.text import Label
        label = Label(self.text, self.name, self.size, self.bold, 
            self.italic, width = self.width)
        self.calculatedWidth = label.content_width
        self.calculatedHeight = label.content_height
        label.delete()
        
    def set_text(self, value):
        self.text = value
    
    def set_max_width(self, value):
        if value <= 0:
            value = 10000
        self.max_width = value
    
    def get_width(self):
        return self.calculatedWidth

    def get_height(self):
        return self.calculatedHeight

class CalcRect(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
    }
    
    conditions = {
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
    }

extension = CalcRect()

def get_extension():
    return extension
