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
KcButton.mfx
Button object - ClickTeam (http://www.clickteam.com)

Used to create push buttons, check boxes, radio buttons and bitmap
buttons.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, ObjectPlayer
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class ChangeText(Action):
    """
    Change text

    Parameters:
    0: Change text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_text(0, self.evaluate_expression(
            self.get_parameter(0)))

class ShowObject(Action):
    """
    Visibility->Make Object Reappear
    """

    def execute(self, instance):
        instance.visible = True

class HideObject(Action):
    """
    Visibility->Make Object Invisible
    """

    def execute(self, instance):
        instance.visible = False

class EnableObject(Action):
    """
    Enable
    """

    def execute(self, instance):
        instance.objectPlayer.enable()

class DisableObject(Action):
    """
    Disable
    """

    def execute(self, instance):
        instance.objectPlayer.disable()

class SetXSize(Action):
    """
    Size->Set Horizontal Size

    Parameters:
    0: Set Horizontal Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_size(width = self.evaluate_expression(
            self.get_parameter(0)))

class SetYSize(Action):
    """
    Size->Set Vertical Size

    Parameters:
    0: Set Vertical Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_size(height = self.evaluate_expression(
            self.get_parameter(0)))

class SetRadioText(Action):
    """
    Set Radio button->Change text

    Parameters:
    0: Change text (EXPRESSION, ExpressionParameter)
    1: Change text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        value = self.evaluate_index(0)
        instance.objectPlayer.set_text(index, value) 

class EnableRadio(Action):
    """
    Set Radio button->Enable a radio button

    Parameters:
    0: Enable a radio button (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        instance.objectPlayer.enable(index = index)

class DisableRadio(Action):
    """
    Set Radio button->Disable a radio button

    Parameters:
    0: Disable a radio button (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        instance.objectPlayer.disable(index = index)

class SelectRadio(Action):
    """
    Set Radio button->Select a radio button

    Parameters:
    0: Select a radio button (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        instance.objectPlayer.currentRadio = index

class CheckButton(Action):
    """
    Check
    """

    def execute(self, instance):
        instance.objectPlayer.values[0] = True

class UncheckButton(Action):
    """
    Uncheck
    """

    def execute(self, instance):
        instance.objectPlayer.values[0] = False

class AttachMenuOption(Action):
    """
    Attach menu option

    Parameters:
    0: Attach menu option (MENU, Int)
    """

    def execute(self, instance):
        pass

class ChangeTooltip(Action):
    """
    Change tooltip

    Parameters:
    0: Change tooltip (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.tooltip = self.evaluate_expression(
            self.get_parameter(0))

# Conditions

class BoxChecked(Condition):
    """
    Box checked ?
    """

    def check(self, instance):
        return instance.objectPlayer.values[0]

class ButtonClicked(Condition):
    """
    Button clicked ?
    """
    iterateObjects = False
    instance = None
    
    def created(self):
        self.add_handlers(clicked = self.on_click)
    
    def on_click(self, instance):
        self.instance = instance
        if self.isTriggered:
            self.generate()

    def check(self):
        if self.instance not in self.get_instances():
            return False
        self.select_instances([self.instance])
        self.instance = None
        return True

class IsVisible(Condition):
    """
    Is visible ?
    """

    def check(self, instance):
        return instance.visible

class IsEnabled(Condition):
    """
    Is enabled ?
    """

    def check(self, instance):
        return instance.objectPlayer.enabled[0]

class RadioEnabled(Condition):
    """
    Is radio button enabled ?

    Parameters:
    0: Enter the number of the button (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        index = self.evaluate_index(0)
        return instance.objectPlayer.enabled[index]

# Expressions

class XSize(Expression):
    """
    X Size of Button
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.width

class YSize(Expression):
    """
    Y Size of Button
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.height

class RadioValue(Expression):
    """
    Value of set Radio button
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.values[instance.objectPlayer.currentRadio]

class ButtonText(Expression):
    """
    Text of the button

    Parameters:
    0: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.strings[index]

class TooltipText(Expression):
    """
    Text of the tooltip
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.tooltip

# font!
from mmfparser.data.font import LogFont
from mmfparser.bitdict import BitDict
from pyglet.window.mouse import LEFT, RIGHT
from pyglet.gl import *
from pyglet import graphics
from pyglet.graphics import Batch

PUSHTEXT_BUTTON = 0
CHECKBOX_BUTTON = 1
RADIO_BUTTON = 2
PUSHBITMAP_BUTTON = 3
PUSHTEXTBITMAP_BUTTON = 4

BUTTON_BORDER = 1

# colours (taken from the Flash runtime :))
NORMAL_FILL = ((0xDB, 0xE1, 0xE5), (0x9E, 0xAB, 0xB2))
NORMAL_RECT = ((0xB7, 0xBA, 0xBC), (0x5E, 0x61, 0x62))

OVER_FILL = ((0xE8, 0xED, 0xEF), (0xC7, 0xCF, 0xD2))
OVER_RECT = ((0x00, 0x9D, 0xFF), (0x00, 0x76, 0xC1))

PRESS_FILL = ((0xD8, 0xF0, 0xFF), (0x9B, 0xD8, 0xFF))
PRESS_RECT = ((0x00, 0x81, 0xFF), (0x00, 0x76, 0xC1))

DISABLED_FILL = ((0xB7, 0xBA, 0xBC), (0xB7, 0xBA, 0xBC))
DISABLED_RECT = ((0xDB, 0xE1, 0xE5), (0xDB, 0xE1, 0xE5))

BOX_OFFSET = 16

X_MARGIN = 2

def create_box_vertex(width, height, border, rect, fill):
    fill1, fill2 = fill
    rect1, rect2 = rect
    return graphics.vertex_list(20,
        ('v2i',
            # fill
            (0, 0, 
            width, 0,
            width, -height,
            0, -height,
            # outline
            # top
            0, 0,
            width, 0,
            width, -border,
            0, -border,
            # left
            0, 0,
            border, 0,
            border, -height,
            0, -height,
            # right
            width, 0,
            width - border, 0,
            width - border, -height,
            width, -height,
            # bottom
            0, -height,
            width, -height,
            width, border-height,
            0, border-height
            )
        ),
        ('c3B', 
            fill1 * 2 + fill2 * 2 + rect1 * 4 + rect2 * 12
        )
    )

def change_box_color(vertex, rect, fill):
    fill1, fill2 = fill
    rect1, rect2 = rect
    vertex.colors = fill1 * 2 + fill2 * 2 + rect1 * 4 + rect2 * 12

CHECKBOX_VERTEX = create_box_vertex(12, 12, 1, 
    ((0xB7, 0xBA, 0xBC), (0x5E, 0x61, 0x62)),
    ((0xDB, 0xE1, 0xE5), (0x9E, 0xAB, 0xB2)))

CHECKBOX_OVER_VERTEX = create_box_vertex(12, 12, 1, 
    ((0x00, 0x9D, 0xFF), (0x00, 0x76, 0xC1)),
    ((0xE8, 0xED, 0xEF), (0xC7, 0xCF, 0xD2)))

CHECKBOX_DISABLED_VERTEX = create_box_vertex(12, 12, 1, 
    ((0x00, 0x9D, 0xFF), (0x00, 0x76, 0xC1)),
    ((0xE8, 0xED, 0xEF), (0xC7, 0xCF, 0xD2)))

CHECK_VERTEX = graphics.vertex_list(4,
        ('v2i', (10, -3, 5, -10, 5, -10, 3, -5)),
        ('c3B', (0, 0, 0) * 4))

class DefaultObject(ObjectPlayer):
    items = None
    fill = None
    rect = None
    vertex = None
    label = None
    labels = None
    batch = None
    values = None
    overBox = None
    enabled = None
    currentRadio = 0
    def created(self, data):
        self.flags = flags = BitDict(
            'HideOnStart',
            'DisableOnStart',
            'TextOnLeft',
            'Transparent',
            'SystemColor'
        )
        strings = []
        width = data.readShort()
        height = data.readShort()
        self.buttonType = buttonType = data.readShort()
        self.buttonCount = buttonCount = data.readShort()
        flags.setFlags(data.readInt())
        self.font = LogFont(data)
        self.fontColor = data.readColor()
        self.backColor = data.readColor()
        if self.flags['SystemColor']:
            self.backColor = (255, 255, 255)
        buttonImages = [data.readShort() for _ in xrange(3)]
        if buttonType in (PUSHBITMAP_BUTTON, PUSHTEXTBITMAP_BUTTON):
            self.textures = textures = []
            for item in buttonImages:
                textures.append(self.make_image_handle(item)
                    if item != -1 else None)
        if buttonType == PUSHBITMAP_BUTTON:
            width = max([
                item.width for item in textures if item is not None] + [32])
            height = max([
                item.height for item in textures if item is not None] + [32])
        data.readShort() # fourth word in img array
        data.readInt() # ebtnSecu
        align = data.readShort()
        tooltip = ''
        if buttonType == RADIO_BUTTON:
            strings = [data.readString() for _ in xrange(buttonCount)]
        else:
            strings.append(data.readString())
            tooltip = data.readString()
        self.values = [False for _ in xrange(buttonCount)]
        self.width = width
        self.height = height
        self.strings = strings
        self.tooltip = tooltip
        self.enable_mouse()
        if flags['DisableOnStart']:
            value = False
        else:
            value = True
        self.enabled = [value for _ in xrange(self.buttonCount)]
        if flags['HideOnStart']:
            self.parent.visible = False
        self.setup()
    
    def enable(self, index = None):
        if index is None:
            if all(self.enabled):
                return
            self.enabled = [True for _ in xrange(self.buttonCount)]
        else:
            if self.enabled[index]:
                return
            self.enabled[index] = True
        self.update_lists(NORMAL_RECT, NORMAL_FILL)
        
    def disable(self, index = None):
        if index is None:
            if not all(self.enabled):
                return
            self.enabled = [False for _ in xrange(self.buttonCount)]
        else:
            if self.enabled[index]:
                return
            self.enabled[index] = False
        self.update_lists(DISABLED_RECT, DISABLED_FILL)
    
    def setup(self):
        buttonType = self.buttonType
        if buttonType == PUSHTEXT_BUTTON:
            self.label = self.create_label(self.font, self.strings[0],
                self.fontColor, self.width, self.height)
            self.label.content_valign = 'center'
            self.label.set_style('align', 'center')
        elif buttonType in (CHECKBOX_BUTTON, RADIO_BUTTON):
            buttonSize = self.height / self.buttonCount
            labels = self.labels = []
            batch = self.batch = Batch()
            if self.flags['TextOnLeft']:
                x = X_MARGIN
            else:
                x = BOX_OFFSET + X_MARGIN
            for i in xrange(self.buttonCount):
                y = -buttonSize * i
                label = self.create_label(self.font, self.strings[i],
                    self.fontColor, self.width - BOX_OFFSET, buttonSize,
                    batch = batch)
                label.x = x
                label.y = y
                label.content_valign = 'center'
                label.set_style('align', 'left')
                labels.append(label)
        self.update_lists(NORMAL_RECT, NORMAL_FILL)
    
    def update_lists(self, rect, fill):
        width = self.width
        height = self.height
        buttonType = self.buttonType
        
        if buttonType in (CHECKBOX_BUTTON, RADIO_BUTTON):
            if self.vertex is None and not self.flags['Transparent']:
                self.vertex = graphics.vertex_list(4,
                    ('v2i',
                        (0, 0, width, 0, width, -height, 0, -height)
                    ),
                    ('c3B',
                        (self.backColor * 4)
                    )
                )
            
        elif buttonType in (PUSHTEXT_BUTTON, PUSHTEXTBITMAP_BUTTON):
            if not self.enabled[0]:
                rect = DISABLED_RECT
                fill = DISABLED_FILL
            if rect == self.rect and fill == self.fill:
                return
            self.rect = rect
            self.fill = fill
            if self.vertex is None:
                self.vertex = create_box_vertex(self.width, self.height,
                    BUTTON_BORDER, rect, fill)
            else:
                change_box_color(self.vertex, rect, fill)
            
    def on_mouse_drag(self, dx, dy, button, modifiers):
        self.update_box()
        if not button & LEFT:
            return
        self.update_lists(PRESS_RECT, PRESS_FILL)
    
    def on_mouse_motion(self, dx, dy):
        self.update_box()
    
    def on_mouse_over(self):
        self.update_lists(OVER_RECT, OVER_FILL)
    
    def on_mouse_left(self):
        self.overBox = None
        self.player.window.set_mouse_cursor(
            self.player.window.get_system_mouse_cursor(None))
        self.update_lists(NORMAL_RECT, NORMAL_FILL)
    
    def on_mouse_press(self, button, modifiers):
        if button != LEFT:
            return
        self.update_lists(PRESS_RECT, PRESS_FILL)
    
    def on_mouse_release(self, button, modifiers):
        if button != LEFT:
            return
        buttonType = self.buttonType
        if buttonType == RADIO_BUTTON:
            if self.overBox is not None and self.overBox in xrange(len(self.values)):
                self.values = [False for _ in xrange(self.buttonCount)]
                self.values[self.overBox] = True
        elif buttonType == CHECKBOX_BUTTON:
            self.values[0] = not self.values[0]
        self.update_lists(OVER_RECT, OVER_FILL)
        if self.enabled[self.overBox]:
            self.fire_handler('clicked')
    
    def update_box(self):
        if self.buttonType == RADIO_BUTTON:
            buttonSize = self.height / self.buttonCount
            self.overBox = int((self.player.mouse.y - (self.parent.y or 0)
                ) / buttonSize)
        else:
            self.overBox = 0
    
    def draw(self):
        width = self.width
        height = self.height
        buttonType = self.buttonType
        
        glDisable(GL_TEXTURE_2D)
        glPushMatrix()
        glTranslatef(self.x, self.y, 0)
        if buttonType in (PUSHTEXT_BUTTON, PUSHTEXTBITMAP_BUTTON): 
            self.vertex.draw(GL_QUADS)
            if self.label:
                self.label.draw()
        elif buttonType in (CHECKBOX_BUTTON, RADIO_BUTTON):
            if self.vertex is not None:
                self.vertex.draw(GL_QUADS)
            self.batch.draw()
            glPushMatrix()
            buttonSize = self.height / self.buttonCount
            if self.flags['TextOnLeft']:
                x = self.width - 12
            else:
                x = 0
            glTranslatef(x, -buttonSize / 2 + 6, 0)
            for i in xrange(self.buttonCount):
                if self.overBox == i:
                    vertex = CHECKBOX_OVER_VERTEX
                else:
                    vertex = CHECKBOX_VERTEX
                vertex.draw(GL_QUADS)
                if self.values[i]:
                    CHECK_VERTEX.draw(GL_LINES)
                glTranslatef(0, -buttonSize, 0)
            glPopMatrix()
        glPopMatrix()
            
class KcButton(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : ChangeText,
        1 : ShowObject,
        2 : HideObject,
        3 : EnableObject,
        4 : DisableObject,
        6 : SetXSize,
        7 : SetYSize,
        8 : SetRadioText,
        9 : EnableRadio,
        10 : DisableRadio,
        11 : SelectRadio,
        14 : CheckButton,
        15 : UncheckButton,
        16 : AttachMenuOption,
        17 : ChangeTooltip,
    }
    
    conditions = {
        0 : BoxChecked,
        1 : ButtonClicked,
        3 : IsVisible,
        4 : IsEnabled,
        5 : RadioEnabled,
    }
    
    expressions = {
        0 : XSize,
        1 : YSize,
        4 : RadioValue,
        5 : ButtonText,
        6 : TooltipText,
    }

extension = KcButton()

def get_extension():
    return extension
