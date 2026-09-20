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
KcCursor.mfx
Cursor object - ClickTeam (http://www.clickteam.com)

Lets you modify the mouse cursor (standard or bitmap shape).

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, ObjectPlayer
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set Cursor Shape->Standard arrow and small hourglass
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8000, 'wait_arrow')

class Action1(Action):
    """
    Set Cursor Shape->Standard arrow
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8001, None)

class Action2(Action):
    """
    Set Cursor Shape->Crosshair
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8002, 'crosshair')

class Action3(Action):
    """
    Set Cursor Shape->Text I-beam
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8003, 'text')

class Action4(Action):
    """
    Set Cursor Shape->Slashed circle
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8004, 'no')

class Action5(Action):
    """
    Set Cursor Shape->Four-pointed arrow (Windows NT only)
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8005, 'size')

class Action6(Action):
    """
    Set Cursor Shape->Double-pointed arrow pointing northeast and southwest
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8006, 'size_up_right')

class Action7(Action):
    """
    Set Cursor Shape->Double-pointed arrow pointing north and south
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8007, 'size_up_down')

class Action8(Action):
    """
    Set Cursor Shape->Double-pointed arrow pointing northwest and southeast
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8008, 'size_up_left')

class Action9(Action):
    """
    Set Cursor Shape->Double-pointed arrow pointing west and east
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(0x8009, 'size_left_right')

class Action10(Action):
    """
    Set Cursor Shape->Vertical arrow
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(32778, 'size_up')

class Action11(Action):
    """
    Set Cursor Shape->Hourglass
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(32779, 'wait')

class Action12(Action):
    """
    Set Cursor Shape->Help
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(32780, 'help')

class Action13(Action):
    """
    Set Cursor Shape->Image number

    Parameters:
    0: Enter an image index (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        image = self.evaluate_index(0)
        try:
            cursor = instance.objectPlayer.get_cursor_handle(image)
            instance.objectPlayer.set_custom_cursor(cursor)
        except ValueError:
            print 'Could not find image', image

class Action14(Action):
    """
    Set Cursor Shape->Image name

    Parameters:
    0: Enter an image name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        try:
            cursor = instance.objectPlayer.get_cursor_name(
                self.evaluate_index(0))
        except ValueError:
            return
        instance.objectPlayer.set_custom_cursor(cursor)

class Action15(Action):
    """
    Set Cursor Shape->Hand
    """

    def execute(self, instance):
        instance.objectPlayer.set_system_cursor(16487, 'hand')

class Action16(Action):
    """
    Set Cursor Shape->Magnifying Glass
    """

    def execute(self, instance):
        pass

class Action17(Action):
    """
    Set Cursor Shape->Color Picker
    """

    def execute(self, instance):
        pass

class Action18(Action):
    """
    Set Cursor Shape->Fill
    """

    def execute(self, instance):
        pass

class Action19(Action):
    """
    Set Cursor Shape->Horizontal Split
    """

    def execute(self, instance):
        pass

class Action20(Action):
    """
    Set Cursor Shape->Vertical Split
    """

    def execute(self, instance):
        pass

class Action21(Action):
    """
    Set Cursor Shape->Drag (Copy)
    """

    def execute(self, instance):
        pass

class Action22(Action):
    """
    Set Cursor Shape->Drag (Move)
    """

    def execute(self, instance):
        pass

class Action23(Action):
    """
    Set Cursor Shape->Drag (Shortcut)
    """

    def execute(self, instance):
        pass

from mmfparser.data.chunkloaders.objectinfo import ACTIVE

class Action24(Action):
    """
    Set Cursor Shape->Set shape from Active object

    Parameters:
    0: Please enter the name of the object (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        image = None
        for otherInstance in self.player.frame.instances:
            if (otherInstance.objectType == ACTIVE and 
            otherInstance.objectInfo.name == name):
                image = otherInstance.objectPlayer.currentFrame
                break
        if image is None:
            return
        instance.objectPlayer.set_image(image)

# Expressions

class Expression0(Expression):
    """
    Number of images
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.customCursors)

class Expression1(Expression):
    """
    Current image number
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.currentHandle

class Expression2(Expression):
    """
    Current image name
    Return type: Int
    """

    def get(self, instance):
        cursor = instance.objectPlayer.cursor
        if cursor is None:
            return ''
        return cursor.name

from pyglet.window import ImageMouseCursor

class CustomCursor(object):
    def __init__(self, name, hotspotX, hotspotY, handle, image):
        self.cursor = ImageMouseCursor(image, hotspotX, -hotspotY)
        self.handle = handle
        self.name = name

class DefaultObject(ObjectPlayer):
    customCursors = None
    cursors = None
    cursor = None
    currentHandle = None
    def created(self, data):
        self.currentHandle = 0x8001
        data.skipBytes(2)
        count = data.readShort(True)
        data.skipBytes(2)
        data.skipBytes(2)
        self.customCursors = []
        self.cursors = {}
        for i in xrange(count):
            image = self.make_image_handle(data.readShort())
            hotspotX = data.readShort()
            hotspotY = data.readShort()
            name = data.readString(40).lower()
            self.customCursors.append(CustomCursor(name, hotspotX, hotspotY,
                i, image))
    
    def get_cursor_handle(self, handle):
        item, = [item for item in self.customCursors
            if item.handle == handle]
        return item
        
    def get_cursor_name(self, name):
        name = name.lower()
        item, = [item for item in self.customCursors
            if item.name.lower() == name.lower()]
        return item
    
    def set_system_cursor(self, handle, name):
        self.cursor = None
        try:
            cursor = self.cursors[name]
        except KeyError:
            cursor = self.player.window.get_system_mouse_cursor(name)
            self.cursors[name] = cursor
        self.currentHandle = handle
        self.player.window.set_mouse_cursor(cursor)
    
    def set_image(self, image):
        newImage = self.make_image(image)
        cursor = CustomCursor('', 0, 0, image.handle, newImage)
        self.set_custom_cursor(cursor)
    
    def set_custom_cursor(self, cursor):
        self.player.window.set_mouse_cursor(cursor.cursor)
        self.currentHandle = cursor.handle
        self.cursor = cursor

class KcCursor(UserExtension):
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
        14 : Action14,
        15 : Action15,
        16 : Action16,
        17 : Action17,
        18 : Action18,
        19 : Action19,
        20 : Action20,
        21 : Action21,
        22 : Action22,
        23 : Action23,
        24 : Action24,
    }
    
    conditions = {
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
    }

extension = KcCursor()

def get_extension():
    return extension
