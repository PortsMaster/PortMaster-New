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
kcedit.mfx
Edit object - ClickTeam (http://www.clickteam.com)

Simple editable text box.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.objects.common import ObjectPlayer
from mmfparser.player.extensions.common import UserExtension
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import convert_path, make_color_number

from mmfparser.player.dialog import *

# Actions

class LoadFile(Action):
    """
    Files->Load text file

    Parameters:
    0: Please select a text file (FILENAME, Filename)
    """

    def execute(self, instance):
        path = convert_path(self.get_filename(self.get_parameter(0)))
        try:
            data = open(path, 'rb').read()
        except IOError:
            return
        instance.objectPlayer.set_text(data)

class LoadSelector(Action):
    """
    Files->Load text file via a file selector
    """

    def execute(self, instance):
        path = open_file_selector()
        try:
            data = open(path, 'rb').read()
        except IOError:
            return
        instance.objectPlayer.set_text(data)

class SaveFile(Action):
    """
    Files->Save text file

    Parameters:
    0: Please select a text file (FILENAME, Filename)
    """

    def execute(self, instance):
        path = convert_path(self.get_filename(self.get_parameter(0)))
        try:
            open(path, 'wb').write(instance.objectPlayer.get_text())
        except IOError:
            return

class SaveSelector(Action):
    """
    Files->Save text file via a file selector
    """

    def execute(self, instance):
        path = save_file_selector()
        try:
            open(path, 'wb').write(instance.objectPlayer.get_text())
        except IOError:
            return

class SetText(Action):
    """
    Editing->Set text

    Parameters:
    0: Set text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        data = self.evaluate_index(0)
        instance.objectPlayer.set_text(data)

class ReplaceSelection(Action):
    """
    Editing->Block->Replace selection

    Parameters:
    0: Replace selection (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        data = self.evaluate_index(0)
        widget = instance.objectPlayer.widget
        if widget.caret.mark is None:
            return
        widget.on_text(data)

class CutBlock(Action):
    """
    Editing->Block->Cut
    """

    def execute(self, instance):
        pass

class CopyBlock(Action):
    """
    Editing->Block->Copy
    """

    def execute(self, instance):
        pass

class PasteBlock(Action):
    """
    Editing->Block->Paste
    """

    def execute(self, instance):
        pass

class ClearBlock(Action):
    """
    Editing->Block->Clear
    """

    def execute(self, instance):
        instance.objectPlayer.set_text('')

class Undo(Action):
    """
    Editing->Undo->Undo
    """

    def execute(self, instance):
        pass

class ClearUndoBuffer(Action):
    """
    Editing->Undo->Clear undo buffer
    """

    def execute(self, instance):
        pass

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

class SetFontSelector(Action):
    """
    Control->Aspect->Set font via a selector
    """

    def execute(self, instance):
        pass

class SetBackgroundSelector(Action):
    """
    Control->Aspect->Set background color via a selector
    """

    def execute(self, instance):
        pass

class SetFocus(Action):
    """
    Control->Focus->On
    """

    def execute(self, instance):
        instance.objectPlayer.widget.set_focus(True)

class Enable(Action):
    """
    Control->Enabled->On
    """

    def execute(self, instance):
        instance.objectPlayer.enable()

class Disable(Action):
    """
    Control->Enabled->Off
    """

    def execute(self, instance):
        instance.objectPlayer.disable()

class EnableReadOnly(Action):
    """
    Control->Read only->On
    """

    def execute(self, instance):
        instance.objectPlayer.widget.read_only = True

class DisableReadOnly(Action):
    """
    Control->Read only->Off
    """

    def execute(self, instance):
        instance.objectPlayer.widget.read_only = False

class ForceModified(Action):
    """
    Control->Force text modified flag->On
    """

    def execute(self, instance):
        instance.objectPlayer.widget.modified = True

class DisableModified(Action):
    """
    Control->Force text modified flag->Off
    """

    def execute(self, instance):
        instance.objectPlayer.widget.modified = False

class LimitSize(Action):
    """
    Control->Limit text size

    Parameters:
    0: Limit text size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        size = self.evaluate_index(0)
        instance.objectPlayer.widget.size_limit = size

class SetXSize(Action):
    """
    Size->Set Horizontal Size

    Parameters:
    0: Set Horizontal Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.resize(
            width = self.evaluate_index(0))

class SetYSize(Action):
    """
    Size->Set Vertical Size

    Parameters:
    0: Set Vertical Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.resize(
            height = self.evaluate_index(0))

class DisableFocus(Action):
    """
    Control->Focus->Off
    """

    def execute(self, instance):
        instance.objectPlayer.widget.set_focus(False)

class ScrollToTop(Action):
    """
    Editing->Scrolling->Scroll To Top
    """

    def execute(self, instance):
        instance.objectPlayer.widget.caret.position = 0

class ScrollToLine(Action):
    """
    Editing->Scrolling->Scroll To Line

    Parameters:
    0: Enter line number (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        line = self.evaluate_index(0)
        length = len(instance.objectPlayer.get_text())
        instance.objectPlayer.widget.caret.position = length
        instance.objectPlayer.widget.caret.line = line

class ScrollToEnd(Action):
    """
    Editing->Scrolling->Scroll To End
    """

    def execute(self, instance):
        length = len(instance.objectPlayer.get_text())
        instance.objectPlayer.widget.caret.position = length

class SetTextColor(Action):
    """
    Control->Aspect->Set text color

    Parameters:
    0: Set text color (COLOUR, Colour)
    """

    def execute(self, instance):
        r, g, b = self.get_parameter(0).value
        instance.objectPlayer.widget.set_foreground_color(r, g, b)

class SetBackgroundColor(Action):
    """
    Control->Aspect->Set background color

    Parameters:
    0: Set background color (COLOUR, Colour)
    """

    def execute(self, instance):
        r, g, b = self.get_parameter(0).value
        instance.objectPlayer.widget.set_background_color(r, g, b)

# Conditions

class IsVisible(Condition):
    """
    Is entry zone visible?
    """

    def check(self, instance):
        return instance.visible

class IsEnabled(Condition):
    """
    Is entry zone enabled?
    """

    def check(self, instance):
        return instance.objectPlayer.enabled

class UndoAvailable(Condition):
    """
    Is undo information available?
    """

    def check(self, instance):
        return False

class TextModified(Condition):
    """
    Has entry zone just been modified?
    """

    def check(self, instance):
        return instance.objectPlayer.widget.modified

class HasFocus(Condition):
    """
    Does entry zone have input focus?
    """

    def check(self, instance):
        return instance.objectPlayer.widget.has_focus

class IsNumber(Condition):
    """
    Is text a number?
    """

    def check(self, instance):
        try:
            float(instance.objectPlayer.get_text())
            return True
        except ValueError:
            return False

class IsSelected(Condition):
    """
    Is text selected?
    """

    def check(self, instance):
        return instance.objectPlayer.widget.caret.mark is not None

# Expressions

class GetText(Expression):
    """
    Get text
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_text()

class GetSelectedText(Expression):
    """
    Get selected text
    Return type: Int
    """

    def get(self, instance):
        caret = instance.objectPlayer.widget.caret
        if caret.mark is None:
            return ''
        start = min(caret.mark, caret.position)
        end = max(caret.mark, caret.position)
        return instance.objectPlayer.get_text()[start:end]

class GetWidth(Expression):
    """
    Size->Get X Size
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.width

class GetHeight(Expression):
    """
    Size->Get Y Size
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.height

class GetNumber(Expression):
    """
    Get numeric value
    Return type: Int
    """

    def get(self, instance):
        try:
            return float(instance.objectPlayer.get_text())
        except ValueError:
            return 0

class GetFirstLine(Expression):
    """
    Get first visible line
    Return type: Int
    """

    def get(self, instance):
        return 0

class GetLineCount(Expression):
    """
    Get line count
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.get_text().split('\n'))

class GetTextColor(Expression):
    """
    Color->Get Text Color
    Return type: Int
    """

    def get(self, instance):
        color = instance.objectPlayer.widget.document.get_style('color')[:-1]
        return make_color_number(*color)

class GetBackgroundColor(Expression):
    """
    Color->Get Background Color
    Return type: Int
    """

    def get(self, instance):
        if not instance.objectPlayer.widget.rectangle:
            return 0
        color = instance.objectPlayer.widget.rectangle.colors[:3]
        return make_color_number(*color)

from mmfparser.data.font import LogFont
from mmfparser.bitdict import BitDict
from mmfparser.player.gui import Edit

class EditBox(ObjectPlayer):
    flags = None
    logFont = None
    foregroundColor = None
    backgroundColor = None
    disabled = False

    def created(self, data):
        self.flags = flags = BitDict(
            'HorizontalScrollbar',
            'HorizontalAutoscroll',
            'VerticalScrollbar',
            'VerticalAutoscroll',
            'ReadOnly',
            'Multiline',
            'Password',
            'Border',
            'HideOnStart',
            'Uppercase',
            'Lowercase',
            'Tabstop',
            'SystemColor',
            '3DLook',
            'Transparent',
            None,
            'AlignCenter',
            'AlignRight'
        )
        self.width = data.readShort(True)
        self.height = data.readShort(True)
        # XXX support unicode when the unicode build is out!
        self.logFont = LogFont(data, old = True)
        data.skipBytes(4 * 16) # custom colors?
        self.foregroundColor = data.readColor()
        self.backgroundColor = data.readColor()
        data.skipBytes(40) # text-style?
        flags.setFlags(data.readInt())

        if flags['HideOnStart']:
            self.parent.visible = False

        self.enable_mouse()
        self.widget = self.new(Edit)
        self.widget.initialize(int(self.x), int(self.y) - self.height, 
            self.width, self.height, self.foregroundColor, self.backgroundColor,
            self.logFont, flags['Password'], flags['AlignCenter'], 
            flags['AlignRight'], flags['Uppercase'], flags['Lowercase'],
            flags['ReadOnly'], flags['Multiline'], flags['Transparent'],
            flags['Border'])
        self.player.window.push_handlers(
            on_text_motion = self.widget.on_text_motion,
            on_text = self.widget.on_text,
            on_text_motion_select = self.widget.on_text_motion_select
        )
    
    def on_mouse_over(self):
        if self.disabled:
            return
        self.widget.on_mouse_over()
    
    def on_mouse_left(self):
        if self.disabled:
            return
        self.widget.on_mouse_left()
    
    def on_mouse_press(self, button, modifiers):
        mouse = self.player.mouse
        self.widget.on_mouse_press(mouse.glX, mouse.glY, button, modifiers)
    
    def on_mouse_drag(self, dx, dy, button, modifiers):
        mouse = self.player.mouse
        self.widget.on_mouse_drag(mouse.glX, mouse.glY, dx, dy, button, 
            modifiers)
    
    def set_position(self, x, y):
        self.widget.set_position(int(x), int(y) - self.height)
    
    def set_text(self, value):
        self.widget.set_text(value)
    
    def resize(self, width = None, height = None):
        self.width = width = width or self.width
        self.height = height = height or self.height
        self.widget.resize(width, height)
    
    def get_text(self):
        return self.widget.get_text()
    
    def disable(self):
        self.widget.disable()
    
    def enable(self):
        self.widget.enable()
    
    def draw(self):
        self.widget.draw()


class kcedit(UserExtension):
    objectPlayer = EditBox
    
    actions = {
        0 : LoadFile,
        1 : LoadSelector,
        2 : SaveFile,
        3 : SaveSelector,
        4 : SetText,
        5 : ReplaceSelection,
        6 : CutBlock,
        7 : CopyBlock,
        8 : PasteBlock,
        9 : ClearBlock,
        10 : Undo,
        11 : ClearUndoBuffer,
        12 : ShowObject,
        13 : HideObject,
        14 : SetFontSelector,
        15 : SetBackgroundSelector,
        16 : SetFocus,
        17 : Enable,
        18 : Disable,
        19 : EnableReadOnly,
        20 : DisableReadOnly,
        21 : ForceModified,
        22 : DisableModified,
        23 : LimitSize,
        28 : SetXSize,
        29 : SetYSize,
        30 : DisableFocus,
        31 : ScrollToTop,
        32 : ScrollToLine,
        33 : ScrollToEnd,
        34 : SetTextColor,
        35 : SetBackgroundColor,
    }
    
    conditions = {
        0 : IsVisible,
        1 : IsEnabled,
        2 : UndoAvailable,
        3 : TextModified,
        4 : HasFocus,
        5 : IsNumber,
        6 : IsSelected,
    }
    
    expressions = {
        0 : GetText,
        1 : GetSelectedText,
        4 : GetWidth,
        5 : GetHeight,
        6 : GetNumber,
        7 : GetFirstLine,
        8 : GetLineCount,
        9 : GetTextColor,
        10 : GetBackgroundColor,
    }

extension = kcedit()

def get_extension():
    return extension
