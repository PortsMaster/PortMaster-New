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
KcIni.mfx
Ini object - ClickTeam (http://www.clickteam.com)

Allows you to store and retrieve any value or text to/from .INI files.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import convert_path

from mmfparser.player.ini import FastINI

from ConfigParser import (RawConfigParser, NoSectionError, 
    DuplicateSectionError)

# Actions

class SetGroup(Action):
    """
    Set current group

    Parameters:
    0: Set current group (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.group = self.evaluate_expression(
            self.get_parameter(0))

class SetItem(Action):
    """
    Set current item

    Parameters:
    0: Set current item (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.item = self.evaluate_expression(
            self.get_parameter(0))

class SetValue(Action):
    """
    Set value

    Parameters:
    0: Set value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_value(self.evaluate_expression(
            self.get_parameter(0)))

class SavePosition(Action):
    """
    Save position of object

    Parameters:
    0: Save position of object (OBJECT, Object)
    """

    def execute(self, instance):
        pass

class LoadPosition(Action):
    """
    Load position of object

    Parameters:
    0: Load position of object (OBJECT, Object)
    """

    def execute(self, instance):
        pass

class SetString(Action):
    """
    Set string

    Parameters:
    0: Set string (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_value(self.evaluate_expression(
            self.get_parameter(0)))

class SetFile(Action):
    """
    Set current file

    Parameters:
    0: Set current file (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.load(self.evaluate_expression(
            self.get_parameter(0)))

class SetItemValue(Action):
    """
    Set value (item)

    Parameters:
    0: Enter Item Name (EXPSTRING, ExpressionParameter)
    1: Enter Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        item = self.evaluate_index(0)
        instance.objectPlayer.set_value(self.evaluate_expression(
            self.get_parameter(1)), item = item)


class SetSpecifiedValue(Action):
    """
    Set value (group - item)

    Parameters:
    0: Enter Group Name (EXPSTRING, ExpressionParameter)
    1: Enter Item Name (EXPSTRING, ExpressionParameter)
    2: Enter Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        item = self.evaluate_index(1)
        group = self.evaluate_index(0)
        instance.objectPlayer.set_value(self.evaluate_expression(
            self.get_parameter(2)), item = item, group = group)

class SetItemString(Action):
    """
    Set string (item)

    Parameters:
    0: Enter Item Name (EXPSTRING, ExpressionParameter)
    1: Enter String (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        item = self.evaluate_index(0)
        instance.objectPlayer.set_value(self.evaluate_expression(
            self.get_parameter(1)), item = item)

class SetSpecifiedString(Action):
    """
    Set string (group - item)

    Parameters:
    0: Enter Group Name (EXPSTRING, ExpressionParameter)
    1: Enter Item Name (EXPSTRING, ExpressionParameter)
    2: Enter String (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        item = self.evaluate_index(1)
        group = self.evaluate_index(0)
        instance.objectPlayer.set_value(self.evaluate_expression(
            self.get_parameter(2)), item = item, group = group)

class DeleteItem(Action):
    """
    Delete item

    Parameters:
    0: Enter Item Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        item = self.evaluate_index(0)
        instance.objectPlayer.remove_item(item = item)

class DeleteSpecifiedItem(Action):
    """
    Delete item (group)

    Parameters:
    0: Enter Group Name (EXPSTRING, ExpressionParameter)
    1: Enter Item Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        group = self.evaluate_index(0)
        item = self.evaluate_index(0)
        instance.objectPlayer.remove_item(item = item, group = group)

class DeleteGroup(Action):
    """
    Delete group

    Parameters:
    0: Enter Group Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        group = self.evaluate_index(0)
        instance.objectPlayer.remove_group(group = group)

# Expressions

class GetValue(Expression):
    """
    Get value
    Return type: Int
    """

    def get(self, instance):
        try:
            return int(instance.objectPlayer.get_value())
        except ValueError:
            return 0

class GetString(Expression):
    """
    Get string
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.get_value()

class GetItemValue(Expression):
    """
    Get value (item)

    Parameters:
    0: Item name (String)
    Return type: Int
    """

    def get(self, instance):
        item = self.next_argument()
        try:
            return int(instance.objectPlayer.get_value(item = item))
        except ValueError:
            return 0

class GetSpecifiedValue(Expression):
    """
    Get value (group - item)

    Parameters:
    0: Group name (String)
    1: Item name (String)
    Return type: Int
    """

    def get(self, instance):
        group = self.next_argument()
        item = self.next_argument()
        try:
            return int(instance.objectPlayer.get_value(group = group, 
                item = item))
        except ValueError:
            return 0

class GetItemString(Expression):
    """
    Get string (item)

    Parameters:
    0: Item name (String)
    Return type: String
    """

    def get(self, instance):
        item = self.next_argument()
        return instance.objectPlayer.get_value(item = item)

class GetSpecifiedString(Expression):
    """
    Get string (group - item)

    Parameters:
    0: Group name (String)
    1: Item name (String)
    Return type: String
    """

    def get(self, instance):
        group = self.next_argument()
        item = self.next_argument()
        return instance.objectPlayer.get_value(group = group, item = item)

class DefaultObject(HiddenObject):
    filename = None
    group = None
    item = None
    config = None
    def created(self, data):
        filename = data.readString()
        self.load(filename)
    
    def load(self, filename):
        path = convert_path(filename)
        self.config = FastINI(path)
    
    def set_value(self, value, group = None, item = None):
        group = group or self.group
        item = item or self.item
        if group is None or item is None:
            return
        self.config.set_key(group, item, str(value))
        
    def get_value(self, group = None, item = None):
        group = group or self.group
        item = item or self.item
        if group is None or item is None:
            return ''
        return self.config.get_key(group, item)
    
    def remove_item(self, group = None, item = None):
        group = group or self.group
        item = item or self.item
        if group is None or item is None:
            return
        self.config.delete_key(group, item)

    def remove_group(self, group = None):
        group = group or self.group
        if group is None:
            return
        self.config.delete_section(group)

class KcIni(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : SetGroup,
        1 : SetItem,
        2 : SetValue,
        3 : SavePosition,
        4 : LoadPosition,
        5 : SetString,
        6 : SetFile,
        7 : SetItemValue,
        8 : SetSpecifiedValue,
        9 : SetItemString,
        10 : SetSpecifiedString,
        11 : DeleteItem,
        12 : DeleteSpecifiedItem,
        13 : DeleteGroup,
    }
    
    conditions = {
    }
    
    expressions = {
        0 : GetValue,
        1 : GetString,
        2 : GetItemValue,
        3 : GetSpecifiedValue,
        4 : GetItemString,
        5 : GetSpecifiedString,
    }

extension = KcIni()

def get_extension():
    return extension
