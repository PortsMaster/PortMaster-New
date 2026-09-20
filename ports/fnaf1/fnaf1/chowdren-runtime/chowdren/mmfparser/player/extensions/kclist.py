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
kclist.mfx
List object - ClickTeam (http://www.clickteam.com)

Lets you create customizable lists of strings in your applications.

Ported to Python by Mathias Kaerlev
"""

import os
from glob import glob

from mmfparser.player.extensions.common import UserExtension, ObjectPlayer
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import convert_path
from mmfparser.player.common import make_color_number

from mmfparser.player.gui import List

# Actions

class LoadListFile(Action):
    """
    Files->Load list file

    Parameters:
    0: Load list file (FILENAME, Filename)
    """

    def execute(self, instance):
        filename = convert_path(self.get_filename(self.get_parameter(0)))
        instance.objectPlayer.reset()
        try:
            lines = open(filename, 'rb').read().splitlines()
        except IOError:
            return
        instance.objectPlayer.listObject.extend(lines)

class LoadDrivesList(Action):
    """
    Files->Load drives list
    """

    def execute(self, instance):
        pass

class LoadDirectoryList(Action):
    """
    Files->Load directory list

    Parameters:
    0: Load directory list (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        lines = []
        for item in glob(path):
            if os.path.isdir(item):
                lines.append('[%s]' % os.path.basename(item))
        instance.objectPlayer.listObject.extend(lines)

class LoadFileList(Action):
    """
    Files->Load Filelist

    Parameters:
    0: Load Filelist (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        lines = []
        for item in glob(path):
            if os.path.isfile(item):
                lines.append(os.path.split(item)[1])
        instance.objectPlayer.listObject.extend(lines)

class SaveListFile(Action):
    """
    Files->Save list file

    Parameters:
    0: Save list file (FILENAME, Filename)
    """

    def execute(self, instance):
        path = convert_path(
            self.get_filename(self.get_parameter(0)))
        try:
            open(path, 'wb').write(str(instance.objectPlayer))
        except IOError:
            return

class Reset(Action):
    """
    Reset
    """

    def execute(self, instance):
        instance.objectPlayer.reset()

class AddLine(Action):
    """
    Add a line

    Parameters:
    0: Add a line (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.listObject.append(
            self.evaluate_index(0))

class InsertLine(Action):
    """
    Insert a line

    Parameters:
    0: Line number to insert after (EXPRESSION, ExpressionParameter)
    1: Line to insert (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        index += instance.objectPlayer.indexOffset
        instance.objectPlayer.listObject.insert(index, 
            self.evaluate_index(1))

class DeleteLine(Action):
    """
    Delete a line

    Parameters:
    0: Delete a line (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        index += instance.objectPlayer.indexOffset
        if index < 0:
            return
        instance.objectPlayer.listObject.pop(index)

class SetCurrentLine(Action):
    """
    Set current line

    Parameters:
    0: Set current line (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        index += instance.objectPlayer.indexOffset
        index = max(0, index)
        instance.objectPlayer.listObject.scroll_to_line(
            index)

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

class GetFocus(Action):
    """
    Control->Get Focus
    """

    def execute(self, instance):
        pass

class Highlight(Action):
    """
    Control->Highlight
    """

    def execute(self, instance):
        instance.objectPlayer.set_enable(True)

class Dehighlight(Action):
    """
    Control->Dehighlight
    """

    def execute(self, instance):
        instance.objectPlayer.set_enable(False)

class SetXSize(Action):
    """
    Size->Set Horizontal Size

    Parameters:
    0: Set Horizontal Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_size(self.evaluate_expression(
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

class LoseFocus(Action):
    """
    Control->Lose Focus
    """

    def execute(self, instance):
        pass

class ScrollToTop(Action):
    """
    Scrolling->Scroll To Top
    """

    def execute(self, instance):
        instance.objectPlayer.listObject.scroll_to_line(0)

class ScrollToLine(Action):
    """
    Scrolling->Scroll To Line

    Parameters:
    0: Enter line number (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.listObject.scroll_to_line(
            self.evaluate_index(0))

class ScrollToEnd(Action):
    """
    Scrolling->Scroll To End
    """

    def execute(self, instance):
        listObject = instance.objectPlayer.listObject
        listObject.scroll_to_line(len(listObject) - 1)

class SetTextColor(Action):
    """
    Color->Set text color

    Parameters:
    0: Set text color (COLOUR, Colour)
    """

    def execute(self, instance):
        value = self.get_color(self.get_parameter(0))
        instance.objectPlayer.listObject.set_font_color(value)

class SetBackgroundColor(Action):
    """
    Color->Set background color

    Parameters:
    0: Set background color (COLOUR, Colour)
    """

    def execute(self, instance):
        value = self.get_color(self.get_parameter(0))
        instance.objectPlayer.listObject.set_back_color(value)

class ListFonts(Action):
    """
    Fonts->List fonts
    """

    def execute(self, instance):
        pass

class ListFontSizes(Action):
    """
    Fonts->List font sizes

    Parameters:
    0: Enter font name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class SetLineData(Action):
    """
    Set line data

    Parameters:
    0: Enter the index of the line (EXPRESSION, ExpressionParameter)
    1: Enter the data to store (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        value = self.evaluate_index(1)
        instance.objectPlayer.listObject.set_data(index, value)

class ChangeLine(Action):
    """
    Change a line

    Parameters:
    0: Enter the index of the line (EXPRESSION, ExpressionParameter)
    1: Enter the new text (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        value = self.evaluate_index(1)
        instance.objectPlayer.listObject.replace(index, value)

# Conditions

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
        return instance.objectPlayer.listObject.enabled

class DoubleClicked(Condition):
    """
    Double clicked ?
    """
    instances = None
    def created(self):
        self.instances = []
        self.add_handlers(
            double_clicked = self.on_click)

    def on_click(self, instance):
        self.instances.append(instance)
        if self.isTriggered:
            self.generate()
            self.instances = []
        
    def check(self, instance):
        if instance in self.instances:
            self.instances.remove(instance)
            return True
        return False

class SelectionChanged(Condition):
    """
    Selection changed ?
    """
    instances = None
    loopCount = None
    def created(self):
        self.instances = []
        self.add_handlers(
            selection_changed = self.selection_changed)

    def selection_changed(self, instance):
        self.instances.append(instance)
        if self.isTriggered:
            self.generate()
            self.instances = []
        
    def check(self, instance):
        if instance in self.instances:
            self.instances.remove(instance)
            return True
        return False

class HasFocus(Condition):
    """
    Have focus ?
    """

    def check(self, instance):
        return True

# Expressions

class GetPosition(Expression):
    """
    Get current line number
    Return type: Int
    """

    def get(self, instance):
        index = instance.objectPlayer.listObject.selected or 0
        index -= instance.objectPlayer.indexOffset
        return index

class GetCurrentLine(Expression):
    """
    Get current line
    Return type: Int
    """

    def get(self, instance):
        index = instance.objectPlayer.listObject.selected or 0
        try:
            return instance.objectPlayer.get_line(index, False)
        except ValueError:
            return 0

class GetCurrentDirectoryLine(Expression):
    """
    Get current line (directory)
    Return type: Int
    """

    def get(self, instance):
        index = instance.objectPlayer.listObject.selected or 0
        try:
            return instance.objectPlayer.get_line(index, False)[1:-1]
        except ValueError:
            return 0

class GetCurrentDriveLine(Expression):
    """
    Get current line (drive)
    Return type: Int
    """

    def get(self, instance):
        return ''

class GetLine(Expression):
    """
    Get line

    Parameters:
    0: Line number (Int)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_line(self.next_argument())

class GetDirectoryLine(Expression):
    """
    Get line (directory)

    Parameters:
    0: Line number (Int)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_line(self.next_argument())[1:-1]

class GetDriveLine(Expression):
    """
    Get line (drive)

    Parameters:
    0: Line number (Int)
    Return type: Int
    """

    def get(self, instance):
        return ''

class GetLineCount(Expression):
    """
    Get number of lines
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.listObject)

class GetXSize(Expression):
    """
    Get X Size
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.width

class GetYSize(Expression):
    """
    Get Y Size
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.height

class GetTextColor(Expression):
    """
    Get Text Color
    Return type: Int
    """

    def get(self, instance):
        return make_color_number(*instance.objectPlayer.listObject.fontColor)

class GetBackgroundColor(Expression):
    """
    Get Background Color
    Return type: Int
    """

    def get(self, instance):
        return make_color_number(*instance.objectPlayer.listObject.backColor)

def find_string(find, listObject, start, exact = False):
    length = len(listObject)
    start += 1

    for i in xrange(length):
        index = (i + start) % length
        value = listObject.get_line(index)
        if exact and value == find or not exact and value.startswith(find):
            return index
    return -1

class FindString(Expression):
    """
    Find String

    Parameters:
    0: String to find (String)
    1: Flag (Int)
    Return type: Int
    """

    def get(self, instance):
        find = self.next_argument()
        start = self.next_argument()
        indexOffset = instance.objectPlayer.indexOffset
        if start != -1:
            start += indexOffset
        index = find_string(find, instance.objectPlayer.listObject, start)
        if index == -1:
            return -1
        return index - indexOffset

class FindExactString(Expression):
    """
    Find String Exact

    Parameters:
    0: String to find (String)
    1: Flag (Int)
    Return type: Int
    """

    def get(self, instance):
        find = self.next_argument()
        start = self.next_argument()
        indexOffset = instance.objectPlayer.indexOffset
        if start != -1:
            start += indexOffset
        index = find_string(find, instance.objectPlayer.listObject, start, True)
        if index == -1:
            return -1
        return index - indexOffset

class GetLastInsertedIndex(Expression):
    """
    Get index of last line inserted
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.listObject.lastIndex

class GetLineData(Expression):
    """
    Get line data

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.listObject.get_data(self.next_argument())

from mmfparser.bitdict import BitDict
from mmfparser.data.font import LogFont

class DefaultObject(ObjectPlayer):
    def created(self, data):
        self.flags = flags = BitDict(
            'FreeFlag',
            'VerticalScrollbar',
            'Sort',
            'Border',
            'HideOnStart',
            'SystemColor',
            '3DLook',
            'ScrollToNewline'
        )
        self.width = data.readShort()
        self.height = data.readShort()
        # XXX support unicode
        self.font = font = LogFont(data, old = True)
        self.fontColor = data.readColor()
        data.readString(40)
        data.skipBytes(16 * 4)
        self.backColor = data.readColor()
        flags.setFlags(data.readInt())
        lineCount = data.readShort(True)
        self.indexOffset = -1 if data.readInt() == 1 else 0
        data.skipBytes(4 * 3)
        lines = []
        for _ in xrange(lineCount):
            lines.append(data.readString())
        
        if flags['HideOnStart']:
            self.parent.visible = False
        
        self.listObject = self.new(List)
        self.listObject.initialize(0, 0, self.width, self.height,
            border = flags['Border'], border3d = flags['3DLook'],
            scrollBar = flags['VerticalScrollbar'], backColor = self.backColor,
            font = font, fontColor = self.fontColor)
        
        self.enable_mouse()
        
        self.listObject.extend(lines)
    
    def reset(self):
        self.listObject.reset()
    
    def get_line(self, index, with_index = True):
        if with_index:
            index += self.indexOffset
        if index < 0:
            return ''
        return self.listObject.get_line(index)
    
    def set_size(self, width = None, height = None):
        self.listObject.set_size(width, height)
        self.width = width or self.width
        self.height = height or self.height
    
    def set_enable(self, value):
        self.listObject.set_enable(value)
    
    def set_position(self, x, y):
        self.listObject.set_position(x, y)
        
    def on_mouse_over(self):
        self.listObject.on_mouse_over()
        
    def on_mouse_motion(self, dx, dy):
        self.listObject.on_mouse_motion(dx, dy)
    
    def on_mouse_left(self):
        self.listObject.on_mouse_left()
    
    def on_mouse_press(self, button, modifiers):
        self.listObject.on_mouse_press(button, modifiers)
        
    def on_mouse_release(self, button, modifiers):
        self.listObject.on_mouse_release(button, modifiers)
        
    def on_mouse_drag(self, dx, dy, button, modifiers):
        self.listObject.on_mouse_drag(dx, dy, button, modifiers)
    
    def on_double_click(self, button, modifiers):
        listObject = self.listObject
        if not listObject.enabled:
            return
        if not listObject.overList:
            return
        self.fire_handler('double_clicked')
    
    def selection_changed(self, listObject, index):
        self.fire_handler('selection_changed')
        
    def __str__(self):
        return '\n'.join([line.text for line in self.listObject.lines])
    
    def draw(self):
        self.listObject.draw()

class kclist(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : LoadListFile,
        1 : LoadDrivesList,
        2 : LoadDirectoryList,
        3 : LoadFileList,
        4 : SaveListFile,
        5 : Reset,
        6 : AddLine,
        7 : InsertLine,
        8 : DeleteLine,
        9 : SetCurrentLine,
        10 : ShowObject,
        11 : HideObject,
        12 : GetFocus,
        13 : Highlight,
        14 : Dehighlight,
        19 : SetXSize,
        20 : SetYSize,
        21 : LoseFocus,
        22 : ScrollToTop,
        23 : ScrollToLine,
        24 : ScrollToEnd,
        25 : SetTextColor,
        26 : SetBackgroundColor,
        27 : ListFonts,
        28 : ListFontSizes,
        29 : SetLineData,
        30 : ChangeLine,
    }
    
    conditions = {
        0 : IsVisible,
        1 : IsEnabled,
        2 : DoubleClicked,
        3 : SelectionChanged,
        4 : HasFocus,
    }
    
    expressions = {
        0 : GetPosition,
        1 : GetCurrentLine,
        2 : GetCurrentDirectoryLine,
        3 : GetCurrentDriveLine,
        4 : GetLine,
        5 : GetDirectoryLine,
        6 : GetDriveLine,
        7 : GetLineCount,
        10 : GetXSize,
        11 : GetYSize,
        12 : GetTextColor,
        13 : GetBackgroundColor,
        14 : FindString,
        15 : FindExactString,
        16 : GetLastInsertedIndex,
        17 : GetLineData,
    }

extension = kclist()

def get_extension():
    return extension
