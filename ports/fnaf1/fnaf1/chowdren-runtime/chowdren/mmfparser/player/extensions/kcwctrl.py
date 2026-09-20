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
kcwctrl.mfx
Window Control object - ClickTeam (http://www.clickteam.com)

Allows you to control the window used to display your application.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Position->Set X Coordinate...

    Parameters:
    0: Set X Coordinate... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        window = self.player.window
        x, y = window.get_location()
        window.set_location(value, y)

class Action1(Action):
    """
    Position->Set Y Coordinate...

    Parameters:
    0: Set Y Coordinate... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        window = self.player.window
        x, y = window.get_location()
        window.set_location(x, value)

class Action2(Action):
    """
    Position->Set Position

    Parameters:
    0: Set Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        

class Action3(Action):
    """
    Resize->X Size...

    Parameters:
    0: X Size... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        window = self.player.window
        width, height = window.get_size()
        window.set_size(value, height)

class Action4(Action):
    """
    Resize->Y Size...

    Parameters:
    0: Y Size... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        window = self.player.window
        width, height = window.get_size()
        window.set_size(width, value)

class Action5(Action):
    """
    Position->Bring Window to Top
    """

    def execute(self, instance):
        self.player.window.activate()

class Action6(Action):
    """
    Position->Bring Window to Back
    """

    def execute(self, instance):
        pass

class Action7(Action):
    """
    Position->Window Always on Top
    """

    def execute(self, instance):
        pass

class Action8(Action):
    """
    Position->Window Not Always on Top
    """

    def execute(self, instance):
        pass

class Action9(Action):
    """
    Visibility->Make Window Reappear
    """

    def execute(self, instance):
        self.player.window.set_visible(True)

class Action10(Action):
    """
    Visibility->Make Window Invisible
    """

    def execute(self, instance):
        self.player.window.set_visible(False)

class Action11(Action):
    """
    Resize->Minimize Window
    """

    def execute(self, instance):
        pass

class Action12(Action):
    """
    Resize->Maximize Window
    """

    def execute(self, instance):
        self.player.window.set_fullscreen(True)

class Action13(Action):
    """
    Resize->Restore Window
    """

    def execute(self, instance):
        pass

class Action14(Action):
    """
    Position->Immediate Move...

    Parameters:
    0: X position (EXPRESSION, ExpressionParameter)
    1: Y position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        x = self.evaluate_index(0)
        y = self.evaluate_index(1)
        self.player.window.set_location(x, y)

class Action15(Action):
    """
    Set Title

    Parameters:
    0: Set Title (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        self.player.window.set_caption(value)

class Action16(Action):
    """
    Focus->Save Focus
    """

    def execute(self, instance):
        pass

class Action17(Action):
    """
    Focus->Restore Focus
    """

    def execute(self, instance):
        pass

class Action18(Action):
    """
    Focus->Set Focus
    """

    def execute(self, instance):
        self.player.window.activate()

class Action19(Action):
    """
    Visibility->Flash Window in Taskbar
    """

    def execute(self, instance):
        self.player.window.activate()

from pyglet.gl import glClearColor

class Action20(Action):
    """
    Visibility->Set Background Color

    Parameters:
    0: Set Background Color (COLOUR, Colour)
    """

    def execute(self, instance):
        self.player.borderColor = self.get_color(self.get_parameter(0))

class Action21(Action):
    """
    Position->Attach to desktop
    """

    def execute(self, instance):
        pass

class Action22(Action):
    """
    Position->Detach from desktop
    """

    def execute(self, instance):
        pass

class Action23(Action):
    """
    Frame Window->Set X Position

    Parameters:
    0: X position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action24(Action):
    """
    Frame Window->Set Y Position

    Parameters:
    0: Y position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action25(Action):
    """
    Frame Window->Set Width

    Parameters:
    0: Width (EXPRESSION, ExpressionParameter)
    1: 1 = adjust frame size, 0 = do not change frame size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        return # should implement?
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action26(Action):
    """
    Frame Window->Set Height

    Parameters:
    0: Height (EXPRESSION, ExpressionParameter)
    1: 1 = adjust frame size, 0 = do not change frame size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        return # should implement?
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Window is minimized ?
    """

    def check(self, instance):
        return False

class Condition1(Condition):
    """
    Window is maximized ?
    """

    def check(self, instance):
        return self.player.window.visible

class Condition2(Condition):
    """
    Window is visible ?
    """

    def check(self, instance):
        return self.player.window.visible

class Condition3(Condition):
    """
    Application is active ?
    """

    def check(self, instance):
        return True

class Condition4(Condition):
    """
    Window has focus ?
    """

    def check(self, instance):
        return True

class Condition5(Condition):
    """
    Window is attached to desktop ?
    """

    def check(self, instance):
        return True

# Expressions

class Expression0(Expression):
    """
    Application Window->Horizontal position of the window
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.get_location()[0]

class Expression1(Expression):
    """
    Application Window->Vertical position of the window
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.get_location()[1]

class Expression2(Expression):
    """
    Application Window->Horizontal size of the window
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.get_size()[0]

class Expression3(Expression):
    """
    Application Window->Vertical size of the window
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.get_size()[1]

class Expression4(Expression):
    """
    Screen->Horizontal size of the screen
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.screen.width

class Expression5(Expression):
    """
    Screen->Vertical size of the screen
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.screen.height

class Expression6(Expression):
    """
    Screen->Screen Depth
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression7(Expression):
    """
    Application Window->Horizontal size of the client area
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.get_size()[0]

class Expression8(Expression):
    """
    Application Window->Vertical size of the client area
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.get_size()[1]

class Expression9(Expression):
    """
    Application Window->Window Title
    Return type: Int
    """

    def get(self, instance):
        return self.player.window.caption

class Expression10(Expression):
    """
    Application Window->Background color
    Return type: Int
    """

    def get(self, instance):
        r, g, b = self.player.frame.clearValue[:3]
        return make_color_number(r * 255, g * 255, b * 255)

class Expression11(Expression):
    """
    Frame Window->Get X Position
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression12(Expression):
    """
    Frame Window->Get Y Position
    Return type: Int
    """

    def get(self, instance):
        return 0

class Expression13(Expression):
    """
    Frame Window->Get Width
    Return type: Int
    """

    def get(self, instance):
        return self.player.realWidth

class Expression14(Expression):
    """
    Frame Window->Get Height
    Return type: Int
    """

    def get(self, instance):
        return self.player.realHeight


class DefaultObject(HiddenObject):
    def created(self, data):
        pass

class kcwctrl(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        17 : Action14,
        18 : Action15,
        19 : Action16,
        20 : Action17,
        21 : Action18,
        22 : Action19,
        23 : Action20,
        24 : Action21,
        25 : Action22,
        26 : Action23,
        27 : Action24,
        28 : Action25,
        29 : Action26,
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
    }

extension = kcwctrl()

def get_extension():
    return extension
