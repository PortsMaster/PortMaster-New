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
Keyboard.mfx
Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition, TrueCondition
from mmfparser.player.event.expressions.common import Expression
from pyglet.window import key

# Conditions

class Condition0(Condition):
    """
    Upon key down

    Parameters:
    0: Key number (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        key = self.evaluate_index(0)
        return key in instance.objectPlayer.key_press

class Condition1(Condition):
    """
    Upon key up

    Parameters:
    0: Key number (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        key = self.evaluate_index(0)
        return key in instance.objectPlayer.key_release

class Condition2(Condition):
    """
    Repeat while key is pressed

    Parameters:
    0: Key number (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        key = self.evaluate_index(0)
        return self.player.keyboard[key]

class Condition3(TrueCondition):
    """
    Upon any key down
    """

    def created(self):
        if self.isTriggered:
            self.add_handlers(
                on_key_press = self.on_key_press
            )

    def on_key_press(self, instance):
        self.generate()

class Condition4(TrueCondition):
    """
    Upon any key up
    """

    def created(self):
        if self.isTriggered:
            self.add_handlers(
                on_key_release = self.on_key_release
            )

    def on_key_release(self, instance):
        self.generate()

class Condition5(Condition):
    """
    Repeat while any key is pressed
    """

    def check(self):
        return any(self.player.keyboard.values())

# Expressions

class Expression0(Expression):
    """
    Last key pressed
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.last_key_press

class Expression1(Expression):
    """
    Last key released
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.last_key_release

class Expression2(Expression):
    """
    Key string

    Parameters:
    0: Key value (Int)
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.get_key_string(self.next_argument())

class Expression3(Expression):
    """
    Key value

    Parameters:
    0: Key string (String)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_key_value(self.next_argument())


class KeyboardObject(HiddenObject):
    last_key_press = 0
    last_key_release = 0

    def created(self):
        self.player.window.push_handlers(
            on_key_press = self.on_key_press,
            on_key_release = self.on_key_release)
        self.updateEnabled = True
        self.new_key_press = self.key_press = set()
        self.new_key_release = self.key_release = set()
    
    def update(self):
        self.key_press = self.new_key_press
        self.key_release = self.new_key_release
        self.new_key_press = set()
        self.new_key_release = set()

    def on_detach(self):
        self.player.window.remove_handlers(
            on_key_press = self.on_key_press,
            on_key_release = self.on_key_release)

    def on_key_press(self, symbol, modifiers):
        self.last_key_press = symbol
        self.new_key_press.add(symbol)
        self.fire_handler('on_key_press')

    def on_key_release(self, symbol, modifiers):
        self.last_key_release = symbol
        self.new_key_release.add(symbol)
        self.fire_handler('on_key_release')

    def get_key_string(self, value):
        value = key.symbol_string(value)
        if value.startswith('_'):
            value = value[1:]
        if value == 'LCTRLREAL':
            return 'LCTRL'
        return value

    def get_key_value(self, value):
        try:
            int(value)
            value = '_' + value
        except ValueError:
            pass
        if value.startswith('userkey('):
            value = value.replace('userkey(', '').replace(')', '')
            return key.user_key(int(value, 16))
        return getattr(key, value)

class Keyboard(UserExtension):
    objectPlayer = KeyboardObject
    
    actions = {
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
    }

extension = Keyboard()

def get_extension():
    return extension
