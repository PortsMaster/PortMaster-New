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
Ini++.mfx
Ini++ Object - Jack Webster (http://www.clickteam.com)

An improved version of the Ini object. Allows advanced manipulation of
Ini files. Chart features missing.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import open_file, convert_path

from ConfigParser import (RawConfigParser, NoSectionError, 
    DuplicateSectionError)

import os

import re
regex_cache = {}

def get_regex_pattern(value):
    try:
        return regex_cache[value]
    except KeyError:
        pass
    res = '^' + re.escape(value).replace('\\*', '.*').replace('\\.', '.')
    pattern = re.compile(res)
    regex_cache[value] = pattern
    return pattern
    
# Actions

class Action0(Action):
    """
    Set Current Group

    Parameters:
    0: Group name (EXPSTRING, ExpressionParameter)
    1: Ensure new group? ( 0 = No, 1 = Yes. If unsure, choose 0 ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        group = self.evaluate_index(0)
        new_group = self.evaluate_index(1)
        instance.objectPlayer.group = group

class Action1(Action):
    """
    Current Group->Set Value

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    1: Type (0 = Integer [Whole numbers] , 1 = Floating Point [Decimal Points]) (EXPRESSION, ExpressionParameter)
    2: Value to set to (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        item = self.evaluate_index(0)
        value = self.evaluate_index(2)
        instance.objectPlayer.set_value(value, item = item)

class Action2(Action):
    """
    Current Group->Set String

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    1: String to set to (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        item = self.evaluate_index(0)
        value = self.evaluate_index(1)
        instance.objectPlayer.set_value(value, item = item)

class Action3(Action):
    """
    Current Group->Set String (MD5 Hashed)

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    1: String to set to (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Current Group->Save Object

    Parameters:
    0: Object to save (OBJECT, Object)
    1: Save position? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    2: Save alt values? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action5(Action):
    """
    Current Group->Load Object

    Parameters:
    0: Object to load (OBJECT, Object)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action6(Action):
    """
    Current Group->Save Position

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    1: Position (POSITION, Position)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Current Group->Save global values
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    """
    Current Group->Load global values
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Current Group->Delete group
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action10(Action):
    """
    Current Group->Delete item

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        instance.objectPlayer.remove_item(item = name)

class Action11(Action):
    """
    Current Group->Rename group

    Parameters:
    0: New name (EXPSTRING, ExpressionParameter)
    1: Overwrite Mode ( 0 = Overwrite , 1 = Merge , 2 = Never overwrite ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    """
    Current Group->Rename item

    Parameters:
    0: Old name (EXPSTRING, ExpressionParameter)
    1: New name (EXPSTRING, ExpressionParameter)
    2: Allow overwriting? ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    """
    Current Group->Move Item to another Group

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    1: New group name (EXPSTRING, ExpressionParameter)
    2: Allow overwrites? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action14(Action):
    """
    Setting Items->Set Value

    Parameters:
    0: Group name (EXPSTRING, ExpressionParameter)
    1: Item name (EXPSTRING, ExpressionParameter)
    2: Type (0 = Integer [Whole numbers] , 1 = Floating Point [Decimal Points]) (EXPRESSION, ExpressionParameter)
    3: Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        group = self.evaluate_index(0)
        item = self.evaluate_index(1)
        type = self.evaluate_index(2)
        value = self.evaluate_index(3)
        if type == 0:
            value = int(value)
        elif type == 1:
            value = float(value)
        value = str(value)
        instance.objectPlayer.set_value(value, group = group, item = item)

class Action15(Action):
    """
    Setting Items->Set String

    Parameters:
    0: Group (EXPSTRING, ExpressionParameter)
    1: Item (EXPSTRING, ExpressionParameter)
    2: String to set to (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        group = self.evaluate_index(0)
        item = self.evaluate_index(1)
        value = self.evaluate_index(2)
        instance.objectPlayer.set_value(value, group = group, item = item)

class Action16(Action):
    """
    Setting Items->Set String (MD5 Hashed)

    Parameters:
    0: Group (EXPSTRING, ExpressionParameter)
    1: Item (EXPSTRING, ExpressionParameter)
    2: Value (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action17(Action):
    """
    Setting Items->Save Object

    Parameters:
    0: Object (OBJECT, Object)
    1: Group (EXPSTRING, ExpressionParameter)
    2: Save position? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    3: Save alt values? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action18(Action):
    """
    Setting Items->Load Object

    Parameters:
    0: Object (OBJECT, Object)
    1: Group (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action19(Action):
    """
    Setting Items->Save Position

    Parameters:
    0: Group name (EXPSTRING, ExpressionParameter)
    1: Item name (EXPSTRING, ExpressionParameter)
    2: Position (POSITION, Position)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action20(Action):
    """
    Setting Items->Save Global Values

    Parameters:
    0: Group (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action21(Action):
    """
    Setting Items->Load Global Values

    Parameters:
    0: Group (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action22(Action):
    """
    Moving and Copying->Rename Group 

    Parameters:
    0: Old Group Name (EXPSTRING, ExpressionParameter)
    1: New Group Name (EXPSTRING, ExpressionParameter)
    2: Overwrite Mode ( 0 = Overwrite , 1 = Merge , 2 = Never overwrite ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action23(Action):
    """
    Moving and Copying->Rename item

    Parameters:
    0: Group Name (EXPSTRING, ExpressionParameter)
    1: Old item name (EXPSTRING, ExpressionParameter)
    2: New item name (EXPSTRING, ExpressionParameter)
    3: Allow overwrite? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action24(Action):
    """
    Moving and Copying->Move Item

    Parameters:
    0: Old Group Name (EXPSTRING, ExpressionParameter)
    1: Old item name (EXPSTRING, ExpressionParameter)
    2: New group name (EXPSTRING, ExpressionParameter)
    3: New item name (EXPSTRING, ExpressionParameter)
    4: Allow overwrite? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action25(Action):
    """
    Moving and Copying->Move Item between groups

    Parameters:
    0: Old Group Name (EXPSTRING, ExpressionParameter)
    1: Item name (EXPSTRING, ExpressionParameter)
    2: New group name (EXPSTRING, ExpressionParameter)
    3: Allow overwrite? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action26(Action):
    """
    Moving and Copying->Copy Group

    Parameters:
    0: Source group name (EXPSTRING, ExpressionParameter)
    1: Destination group name (EXPSTRING, ExpressionParameter)
    2: Overwrite Mode ( 0 = Replace old group , 1 = Merge with old group ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action27(Action):
    """
    Moving and Copying->Copy Item

    Parameters:
    0: Source group (EXPSTRING, ExpressionParameter)
    1: Source item (EXPSTRING, ExpressionParameter)
    2: Destination group (EXPSTRING, ExpressionParameter)
    3: Destination item (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action28(Action):
    """
    Deleting->Delete group

    Parameters:
    0: Group to delete (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        group = self.evaluate_index(0)
        instance.objectPlayer.remove_group(group)

class Action29(Action):
    """
    Deleting->Delete item

    Parameters:
    0: Group (EXPSTRING, ExpressionParameter)
    1: Item (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        group = self.evaluate_index(0)
        item = self.evaluate_index(1)
        instance.objectPlayer.remove_item(group, item)

class Action30(Action):
    """
    Deleting->Delete item in all groups

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action31(Action):
    """
    Deleting->Delete by pattern

    Parameters:
    0: Pattern for groups (EXPSTRING, ExpressionParameter)
    1: Pattern for items (EXPSTRING, ExpressionParameter)
    2: Pattern for values (EXPSTRING, ExpressionParameter)
    3: Case Sensitive ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        group_pattern = get_regex_pattern(self.evaluate_index(0))
        item_pattern = get_regex_pattern(self.evaluate_index(1))
        value_pattern = get_regex_pattern(self.evaluate_index(2))
        case_sens = self.evaluate_index(3)
        if case_sens != 0:
            raise NotImplementedError
        for option, options in instance.objectPlayer.get_dict().iteritems():
            if not group_pattern.match(option):
                continue
            for value_name, value in options.iteritems():
                if not item_pattern.match(value_name):
                    continue
                if not value_pattern.match(value):
                    continue
                del options[value_name]

class Action32(Action):
    """
    Deleting->Clear all
    """

    def execute(self, instance):
        instance.objectPlayer.clear()

class Action33(Action):
    """
    Searching->Perform Search

    Parameters:
    0: Group condition (Use '.', '*' or start with a '!' for 'not') (EXPSTRING, ExpressionParameter)
    1: Item condition (Use '.', '*' or start with a '!' for 'not') (EXPSTRING, ExpressionParameter)
    2: Value condition (Use '.', '*' or start with a '!' for 'not') (EXPSTRING, ExpressionParameter)
    3: Value condition (Use '.', '*' or start with a '!' for 'not') ((unknown 1005))
    """

    def execute(self, instance):
        # XXX does not support exotic features
        group_condition = get_regex_pattern(
            self.evaluate_index(0))
        item_condition = get_regex_pattern(
            self.evaluate_index(1))
        value_condition = get_regex_pattern(
            self.evaluate_index(2))
        # options = self.get_parameter(3).data
        # print 'option len:', len(options)
        # mode = options.readByte(True)
        # flags = options.readByte(True)
        results = []
        for section, options in instance.objectPlayer.get_dict().iteritems():
            if not group_condition.match(section):
                continue
            for option, value in options.iteritems():
                if not item_condition.match(option):
                    continue
                if not value_condition.match(value):
                    continue
                results.append((section, option))
        instance.objectPlayer.results = results

class Action34(Action):
    """
    Searching->Find 'Repeats' of Item

    Parameters:
    0: Group (EXPSTRING, ExpressionParameter)
    1: Item (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action35(Action):
    """
    Searching->Clear Results
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action36(Action):
    """
    Searching->Search and put result in Ini file

    Parameters:
    0: #Title#Destination Path#Filter#Ini Files|*.ini|All files|*.*| (FILENAME, Filename)
    1: Group condition (EXPSTRING, ExpressionParameter)
    2: Item condition (EXPSTRING, ExpressionParameter)
    3: Value condition (EXPSTRING, ExpressionParameter)
    4: Case sensitive? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action37(Action):
    """
    Searching->Search and put result in Ini++ object

    Parameters:
    0: THERE IS NO WAY TO GET THIS DATA YET (TODO) ((unknown 1001))
    1: Group condition (EXPSTRING, ExpressionParameter)
    2: Item condition (EXPSTRING, ExpressionParameter)
    3: Value condition (EXPSTRING, ExpressionParameter)
    4: Case sensitive? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action38(Action):
    """
    Merging->Merge (with file)

    Parameters:
    0: #Title#File to merge from#Filter#Ini Files|*.ini|All files|*.*| (FILENAME, Filename)
    1: Allow overwrites ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.get_filename(self.get_parameter(0))
        overwrite = bool(self.evaluate_index(1))
        instance.objectPlayer.load(filename, True, overwrite)

class Action39(Action):
    """
    Merging->Merge Group (with file)

    Parameters:
    0: #Title#File to merge from#Filter#Ini Files|*.ini|All files|*.*| (FILENAME, Filename)
    1: Source Group name (EXPSTRING, ExpressionParameter)
    2: Destination Group name (EXPSTRING, ExpressionParameter)
    3: Allow overwrites ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class OtherINIAction(Action):
    def execute(self, instance):
        name = self.get_parameter(0).data.readString()
        for other_instance in self.player.frame.instances:
            if other_instance.objectInfo.name != name:
                continue
            if other_instance.objectPlayer.__class__ is not DefaultObject:
                continue
            break
        else:
            return
        self.action(instance, instance)

class Action40(OtherINIAction):
    """
    Merging->Merge (with other Ini++ object)

    Parameters:
    0: Address of INI++ Object (Use "Get Memory Address" expression in other object) ((unknown 1000))
    1: Allow overwrites ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def action(self, instance, other_instance):
        overwrite = self.evaluate_index(1)
        instance.objectPlayer.merge_dict(other_instance.objectPlayer.get_dict(),
            overwrite)

class Action41(OtherINIAction):
    """
    Merging->Merge Group (with other Ini++ object)

    Parameters:
    0: CANNOT SEE YET ((unknown 1000))
    1: Source Group name (EXPSTRING, ExpressionParameter)
    2: Destination Group name (EXPSTRING, ExpressionParameter)
    3: Allow overwrites ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def action(self, instance, other_instance):
        source = self.evaluate_index(1)
        dest = self.evaluate_index(2)
        overwrite = self.evaluate_index(3)
        instance.objectPlayer.merge_group(other_instance.objectPlayer.get_dict(),
            source, dest, overwrite)

class Action42(Action):
    """
    Loading and Saving->Change current file

    Parameters:
    0: #Title#File name (if blank it will be kept in memory)#Filter#Ini Files|*.ini|All files|*.*| (FILENAME, Filename)
    1: Clear current data? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        mode = self.evaluate_index(1)
        instance.objectPlayer.load(value, mode)

class Action43(Action):
    """
    Loading and Saving->Load file

    Parameters:
    0: #Title#File to load#Filter#Ini Files|*.ini|All files|*.*| (FILENAME, Filename)
    1: Read only? ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.get_filename(self.get_parameter(0))
        readonly = self.evaluate_index(1)
        try:
            instance.objectPlayer.load(filename)
        except:
            print 'Could not load', filename

class Action44(Action):
    """
    Loading and Saving->Save file
    """

    def execute(self, instance):
        instance.objectPlayer.save()

class Action45(Action):
    """
    Loading and Saving->Save as

    Parameters:
    0: Path (FILENAME, Filename)
    """

    def execute(self, instance):
        path = self.evaluate_index(0)
        instance.objectPlayer.save(path)

class Action46(Action):
    """
    Loading and Saving->Backup to

    Parameters:
    0: #Title#File to backup to#Filter#Ini Files|*.ini|All files|*.*| (FILENAME, Filename)
    1: Compressed? ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    2: Encrypted? (Type key or use blank string for none) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action47(Action):
    """
    Loading and Saving->Close
    """

    def execute(self, instance):
        instance.objectPlayer.close()

class Action48(Action):
    """
    Loading and Saving->Load From String

    Parameters:
    0: Text (in Ini format) to load (EXPSTRING, ExpressionParameter)
    1: Mode ( 0 = Replace , 1 = Merge ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        mode = self.evaluate_index(1)
        instance.objectPlayer.load_string(value, mode)

class Action49(Action):
    """
    Loading and Saving->Set auto load/save

    Parameters:
    0: Auto Save (0 = Off , 1 = On) (EXPRESSION, ExpressionParameter)
    1: Auto Load ( 0 = Off , 1 = On ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action50(Action):
    """
    Loading and Saving->Set compression

    Parameters:
    0: 0 = Off , 1 = On (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action51(Action):
    """
    Loading and Saving->Set encryption

    Parameters:
    0: Type the key, or an empty string to not use encryption (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_key(self.evaluate_expression(
            self.get_parameter(0)))

class Action52(Action):
    """
    Loading and Saving->Set read only

    Parameters:
    0: 0 = No , 1 = Yes (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action53(Action):
    """
    Advanced Settings->Set case sensitivity

    Parameters:
    0: 0 = Not case sensitive , 1 = Case sensitive (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action54(Action):
    """
    Advanced Settings->Escape character settings

    Parameters:
    0: Use in groups ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    1: Use in item names ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    2: Use in item values ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action55(Action):
    """
    Advanced Settings->Enable/Disable 'always quote strings'

    Parameters:
    0: 0 = No , 1 = Yes (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action56(Action):
    """
    Advanced Settings->Set repeat modes

    Parameters:
    0: For groups ( 0 = First , 1 = Last , 2 = Rename , 3 = Merge ) (EXPRESSION, ExpressionParameter)
    1: For items ( 0 = First , 1 = Last , 2 = Rename  ) (EXPRESSION, ExpressionParameter)
    2: Save repeated items as original? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action57(Action):
    """
    Advanced Settings->Set new line string

    Parameters:
    0: Type the new line string or type an empty string to use the Standard mode (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action58(Action):
    """
    Advanced Settings->Set default directory

    Parameters:
    0: Default directory (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action59(Action):
    """
    Extra Functions->Compress file

    Parameters:
    0: #Title#Source#Filter#All files|*.*| (FILENAME, Filename)
    1: #Title#Destination#Filter#All files|*.*| (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action60(Action):
    """
    Extra Functions->Decompress file

    Parameters:
    0: #Title#Source#Filter#All files|*.*| (FILENAME, Filename)
    1: #Title#Destination#Filter#All files|*.*| (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action61(Action):
    """
    Dialog Box->Open Dialog

    Parameters:
    0: Title for dialog box (EXPSTRING, ExpressionParameter)
    1: Pause MMF? (0 = Run in own thread, 1 = Pause MMF) ((unknown 1002))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action62(Action):
    """
    Setting Items->Add Repeated Item

    Parameters:
    0: Group Name (EXPSTRING, ExpressionParameter)
    1: Item Name (EXPSTRING, ExpressionParameter)
    2: String to set to (Use Str$(...) if you wish to set to a value) (EXPSTRING, ExpressionParameter)
    3: Mode ( 0 = New item ; 1 = New group ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action63(Action):
    """
    Dialog Box->Close dialog
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action64(Action):
    """
    Dialog Box->Refresh Dialog

    Parameters:
    0: Mode (0 for full refresh, 1 for 'quick' item name refresh) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action65(Action):
    """
    Loading and Saving->Import/Export CSV

    Parameters:
    0: Import = 0, Export = 1 (EXPRESSION, ExpressionParameter)
    1: #Title#Path to save to#Filter#CSV Files|*.csv|All files|*.*| (FILENAME, Filename)
    2: Group to save. Leave blank to save/load all. (EXPSTRING, ExpressionParameter)
    3: Seperator symbol (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action66(Action):
    """
    Loading and Saving->Import/Export CSV Array

    Parameters:
    0: 0 = Import, 1 = Export (EXPRESSION, ExpressionParameter)
    1: #Title#Path to load from#Filter#CSV Files|*.csv|All files|*.*| (FILENAME, Filename)
    2: Seperator symbol (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action67(Action):
    """
    Chart Object->Display data in chart object

    Parameters:
    0: Mode (0 for full refresh, 1 for 'quick' item name refresh) ((unknown 1003))
    1: Group filter (Either name or search string) (EXPSTRING, ExpressionParameter)
    2: Item filter (Either name or search string) (EXPSTRING, ExpressionParameter)
    3: Value filter (Either name or search string) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action68(Action):
    """
    Searching->Find 'Subgroups'

    Parameters:
    0: Group to find subgroups of (EXPSTRING, ExpressionParameter)
    1: Number of levels (0 for unlimited. n for at most n levels, -n means exactly n levels) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action69(Action):
    """
    Advanced Settings->Group settings (Subgroups, Empty groups)

    Parameters:
    0: Enable subgroup loading and saving? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    1: Allow empty groups? (0 = No, 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action70(Action):
    """
    Loading and Saving->Change global data slot

    Parameters:
    0: Change global data slot to %0 (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

SORT_BY_VALUE = 0
SORT_BY_NAME = 9
SORT_FIRST_PART = 10
SHUFFLE = 1
REMOVE_FIRST = 2
REMOVE_LAST = 4
CYCLE_UP = 3
CYCLE_DOWN = 5
REVERSE = 6
SWAP = 7
RENUMBER = 8

ALPHANUM_SORT = 0
CASE_INSENSITIVE_SORT = 1
CASE_SENSITIVE_SORT = 2

class Action71(Action):
    """
    Moving and Copying->Shift, Sort, Shuffle (etc.) group

    Parameters:
    0: Group to apply to ((unknown 1004))
    1: Group to apply to (EXPSTRING, ExpressionParameter)
    """
    
    def created(self):
        reader = self.get_parameter(0).get_reader()
        self.option = reader.readByte(True)
        self.parameter = reader.readByte(True)

    def execute(self, instance):
        group = self.evaluate_index(1)
        if self.option == SORT_BY_NAME:
            orig = instance.objectPlayer.get_dict()
            value = ini_dict(sorted(orig.items(), key=lambda t: t[0]))
            instance.objectPlayer.set_dict(value)
        else:
            print 'INI++: reorder option', self.option, 'not supported'

# Conditions

class Condition0(Condition):
    """
    Current group->Group exists
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Current group->Group has Item

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        name = self.evaluate_index(0)
        return instance.objectPlayer.has_item(item = name)

class Condition2(Condition):
    """
    Current group->Item has hashed value

    Parameters:
    0: Item name (EXPSTRING, ExpressionParameter)
    1: Default string (if item does not exist) (EXPSTRING, ExpressionParameter)
    2: String to compare to (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition3(Condition):
    """
    Group exists

    Parameters:
    0: Group name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        return instance.objectPlayer.has_group(
            self.evaluate_index(0))

class Condition4(Condition):
    """
    Group has item

    Parameters:
    0: Group name (EXPSTRING, ExpressionParameter)
    1: Item name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        group = self.evaluate_index(0)
        item = self.evaluate_index(1)
        return instance.objectPlayer.has_item(group, item)

class Condition5(Condition):
    """
    Item has hashed value

    Parameters:
    0: Group name (EXPSTRING, ExpressionParameter)
    1: Item name (EXPSTRING, ExpressionParameter)
    2: Default value (if item does not exist) (EXPSTRING, ExpressionParameter)
    3: String to compare to (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition6(Condition):
    """
    Extra Functions->Is Wildcat Match?

    Parameters:
    0: Pattern (. or * allowed) (EXPSTRING, ExpressionParameter)
    1: String (EXPSTRING, ExpressionParameter)
    2: Case Sensitive? ( 0 = No , 1 = Yes ) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition7(Condition):
    """
    Dialog box->On open
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition8(Condition):
    """
    Dialog box->On close
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition9(Condition):
    """
    Dialog box->On modified
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition10(Condition):
    """
    On Data Modified
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition11(Condition):
    """
    On Save
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition12(Condition):
    """
    On New Item
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition13(Condition):
    """
    Search Results->On Results Found
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition14(Condition):
    """
    Search Results->On No Results Found
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition15(Condition):
    """
    On Merge
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Current group->Get Item Value ( item , default value)

    Parameters:
    0:  (String)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        item = self.next_argument()
        default = self.next_argument()
        value = instance.objectPlayer.get_value(default,
            item = item)
        try:
            return int(value)
        except ValueError:
            pass
        try:
            return float(value)
        except ValueError:
            return 0

class Expression1(Expression):
    """
    Current group->Get Item String ( item . default string)

    Parameters:
    0:  (String)
    1:  (String)
    Return type: String
    """

    def get(self, instance):
        item = self.next_argument()
        default = self.next_argument()
        return instance.objectPlayer.get_value(default, item = item)

class Expression2(Expression):
    """
    Current group->Get position X ( item )

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Current group->Get position Y ( item )

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Current group->Get N-th Item name ( n )

    Parameters:
    0:  (Int)
    Return type: String
    """

    def get(self, instance):
        index = self.next_argument()
        try:
            return instance.objectPlayer.get_options()[index][0]
        except IndexError:
            return ''

class Expression5(Expression):
    """
    Current group->Get N-th Item value ( n )

    Parameters:
    0:  (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        try:
            return int(instance.objectPlayer.get_options()[index][1])
        except IndexError:
            return 0

class Expression6(Expression):
    """
    Current group->Get N-th Item string ( n )

    Parameters:
    0:  (Int)
    Return type: String
    """

    def get(self, instance):
        index = self.next_argument()
        try:
            return instance.objectPlayer.get_options()[index][1]
        except IndexError:
            return ''

class Expression7(Expression):
    """
    Current group->Get Item Count
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.get_options())

class Expression8(Expression):
    """
    Get Item Value (group , item , default value)

    Parameters:
    0:  (String)
    1:  (String)
    2:  (Int)
    Return type: Int
    """

    def get(self, instance):
        group = self.next_argument()
        item = self.next_argument()
        default = self.next_argument()
        value = instance.objectPlayer.get_value(default, group = group,
            item = item)
        try:
            return int(value)
        except ValueError:
            pass
        try:
            return float(value)
        except ValueError:
            return 0

class Expression9(Expression):
    """
    Get Item String (group , item , default string)

    Parameters:
    0:  (String)
    1:  (String)
    2:  (String)
    Return type: String
    """

    def get(self, instance):
        group = self.next_argument()
        item = self.next_argument()
        default = self.next_argument()
        return instance.objectPlayer.get_value(default, group = group,
            item = item)

class Expression10(Expression):
    """
    Get X Position (group , item)

    Parameters:
    0:  (String)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    Get Y Position (group , item)

    Parameters:
    0:  (String)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    List Groups and Items->Get N-th Group name ( n )

    Parameters:
    0:  (Int)
    Return type: String
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.get_sections()[index]

class Expression13(Expression):
    """
    List Groups and Items->Get N-th Item name ( group , n )

    Parameters:
    0:  (String)
    1:  (Int)
    Return type: String
    """

    def get(self, instance):
        group = self.next_argument()
        index = self.next_argument()
        try:
            return instance.objectPlayer.get_options(group)[index][0]
        except IndexError:
            return ''

class Expression14(Expression):
    """
    List Groups and Items->Get N-th Item string ( group , n )

    Parameters:
    0:  (String)
    1:  (Int)
    Return type: String
    """

    def get(self, instance):
        group = self.next_argument()
        index = self.next_argument()
        try:
            return instance.objectPlayer.get_options(group)[index][1]
        except IndexError:
            return ''

class Expression15(Expression):
    """
    List Groups and Items->Get N-th Item value ( group , n )

    Parameters:
    0:  (String)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression16(Expression):
    """
    Counting and Calculations->Get Group Count
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.get_sections())

class Expression17(Expression):
    """
    Counting and Calculations->Get Item Count (Group)

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.get_options(self.next_argument()))

class Expression18(Expression):
    """
    Counting and Calculations->Get Total Item Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression19(Expression):
    """
    Search Results->Number of search results
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.results)

class Expression20(Expression):
    """
    Search Results->Get N-th Search Result Group ( n )

    Parameters:
    0:  (Int)
    Return type: String
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.results[index][0]

class Expression21(Expression):
    """
    Search Results->Get N-th Search Result Item Name ( n )

    Parameters:
    0:  (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression22(Expression):
    """
    Search Results->Get N-th Search Result Item Value ( n )

    Parameters:
    0:  (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression23(Expression):
    """
    Search Results->Get N-th Search Result Item String ( n )

    Parameters:
    0:  (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression24(Expression):
    """
    Search Results->Get N-th Search Result Path ( n , separator )

    Parameters:
    0:  (Int)
    1:  (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression25(Expression):
    """
    Get INI as String
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.get_data()
        
class Expression26(Expression):
    """
    Extra Functions->Hash String ( string )

    Parameters:
    0:  (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression27(Expression):
    """
    Extra Functions->Escape String ( string )

    Parameters:
    0:  (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression28(Expression):
    """
    Extra Functions->Unescape String ( string )

    Parameters:
    0:  (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression29(Expression):
    """
    Counting and Calculations->Perform Calculations (Click for info)

    Parameters:
    0:  (String)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression30(Expression):
    """
    Counting and Calculations->Find Max or Min Group (Click for info)

    Parameters:
    0:  (String)
    1:  (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression31(Expression):
    """
    List Groups and Items->Get N-th Sorted Item name ( group , n )

    Parameters:
    0:  (String)
    1:  (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression32(Expression):
    """
    List Groups and Items->Get N-th Sorted Item Value ( group , n )

    Parameters:
    0:  (String)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression33(Expression):
    """
    Get INI as CSV String

    Parameters:
    0:  (String)
    1:  (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression34(Expression):
    """
    List Groups and Items->Get N-th Item used in any group ( n )

    Parameters:
    0:  (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression35(Expression):
    """
    Counting and Calculations->Get number of unique item names
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression36(Expression):
    def get(self, instance):
        group = self.next_argument()
        item = self.next_argument()
        index = self.next_argument()
        default = self.next_argument()
        value = instance.objectPlayer.get_value(group, item, '')
        try:
            return value.split(',')[index]
        except IndexError:
            return default

class CurrentGroupName(Expression):
    """
    Counting and Calculations->Get number of unique item names
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.group or ''

from cStringIO import StringIO

GLOBAL_DATA = {}

def convert(data, key):
    v11 = range(256)
    v6 = [0] * 256
    v7 = 0
    if key:
        for i in xrange(256):
            if v7 == len(key):
                v7 = 0
            v6[i] = ord(key[v7])
            v7 += 1
    v7 = 0
    for i in xrange(256):
        v7 = (v6[i] + v11[i] + v7) % 256
        v10 = v11[i]
        v11[i] = v11[v7]
        v11[v7] = v10
    v7 = 0
    out = ''
    i = 0
    for j in xrange(len(data)):
        i = (i + 1) % 256
        v7 = (v7 + v11[i]) % 256
        v10 = v11[i]
        v11[i] = v11[v7]
        v11[v7] = v10
        v12 = (v11[v7] + v11[i]) % 256
        v5 = v11[v12]
        out += chr(ord(data[j]) ^ v5)
    return out

from ordereddict import OrderedDict

class ini_dict(OrderedDict):
    def __init__(self, *arg, **kw):
        self.key_transform = {}
        OrderedDict.__init__(self, *arg, **kw)
    
    def __setitem__(self, key, value):
        try:
            if type(value) == str and value[0] == value[-1] == '"':
                value = value[1:-1]
        except IndexError:
            pass
        if key == '<empty>':
            key = ''
        transform = key.lower()
        if transform not in self.key_transform:
            OrderedDict.__setitem__(self, key, value)
            self.key_transform[transform] = key
        else:
            key = self.key_transform[transform]
            OrderedDict.__setitem__(self, key, value)
    
    def __getitem__(self, key):
        return OrderedDict.__getitem__(self, self.key_transform[key.lower()])
    
    def __delitem__(self, key):
        key = key.lower()
        OrderedDict.__delitem__(self, self.key_transform[key])
        del self.key_transform[key]
    
    def __contains__(self, key):
        return key.lower() in self.key_transform
    
    def clear(self):
        OrderedDict.clear(self)
        self.key_transform = {}

class FileReader(object):
    def __init__(self, file):
        self.file = file
    
    def readline(self, *arg, **kw):
        line = self.file.readline(*arg, **kw).lstrip(' \t')
        if line.startswith('='):
            line = '<empty>' + line
        return line

class ConfigParser(RawConfigParser):
    def readfp(self, fp, filename = None):
        return RawConfigParser.readfp(self, FileReader(fp), filename)

def open_dir_file(filename, mode):
    filename = convert_path(filename)
    try:
        os.makedirs(os.path.dirname(filename))
    except OSError:
        pass
    return open(filename, mode)

class DefaultObject(HiddenObject):
    filename = None
    group = None
    item = None
    config = None
    key = None
    def created(self, data):
        self.results = []
        data.skipBytes(2)
        filename = data.readString()
        data.seek(3269)
        self.autoSave = data.readByte() == 1
        data.seek(3429)
        self.isGlobal = data.readInt() == 1
        data.skipBytes(1)
        self.globalKey = data.readString()
        if self.isGlobal:
            try:
                self.config = GLOBAL_DATA[self.globalKey]
                return
            except KeyError:
                pass
        if filename:
            self.load(filename)
        else:
            self.clear()
    
    def close(self):
        self.clear()
        self.filename = None
    
    def get_config(self):
        config = ConfigParser(dict_type = ini_dict)
        config.optionxform = str
        return config
    
    def clear(self):
        self.config = self.get_config()
        if self.isGlobal:
            GLOBAL_DATA[self.globalKey] = self.config
    
    def set_key(self, key):
        self.key = key or None
    
    def load(self, filename, merge = False, overwrite = True):
        if not merge:
            self.clear()
        if filename == '':
            return
        try:
            fp = open_dir_file(filename, 'rb')
            if self.key is not None:
                data = fp.read()
                fp.close()
                data = convert(data, self.key)
                fp = StringIO(data)
            if overwrite:
                self.config.readfp(fp)
            else:
                config = self.get_config()
                config.readfp(fp)
                for group in config.sections():
                    if not self.config.has_section(group):
                        self.config.add_section(group)
                    for name, value in config.items(group):
                        if not self.config.has_option(group, name):
                            self.config.set(group, name, value)
            fp.close()
        except IOError, e:
            print 'INI++ load failed:', e
            pass
            # print 'could not load:', e
        self.filename = filename
    
    def merge_dict(self, value, overwrite):
        sections = self.get_dict()
        for section, options in value.iteritems():
            if section not in sections:
                origin_section = {}
                sections[section] = origin_section
            else:
                origin_section = sections[section]
            for option, value in options.iteritems():
                if not overwrite and option in origin_section:
                    continue
                origin_section[option] = value

    def merge_group(self, value, source, dest, overwrite):
        sections = self.get_dict()
        if dest not in sections:
            origin_section = {}
            value[dest] = origin_section
        else:
            origin_section = sections[dest]
        for option, value in value.get(source, {}).iteritems():
            if not overwrite and option in origin_section:
                continue
            origin_section[option] = value
    
    def load_string(self, value, merge):
        if not merge:
            self.clear()
        if self.key is not None:
            value = convert(value, self.key)
        self.config.readfp(StringIO(value))
    
    def get_data(self):
        value = StringIO()
        self.config.write(value)
        return value.getvalue()
    
    def get_dict(self):
        return self.config._sections
    
    def set_dict(self, value):
        self.config._sections = value
    
    def save(self, filename = None):
        filename = filename or self.filename
        if filename is None:
            return
        self.filename = filename
        # print 'saving', filename, self.key
        try:
            fp = open_dir_file(filename, 'wb')
            if self.key is not None:
                value = self.get_data()
                fp.write(convert(value, self.key))
            else:
                self.config.write(fp)
            fp.close()
        except IOError, e:
            pass
            # print 'could not save:', e
    
    def set_value(self, value, group = None, item = None):
        group = group or self.group
        item = item or self.item
        if group is None or item is None:
            return
        # if item.lower().count('thorn'):
            # print 'set', value, group, item
        config = self.config
        if not config.has_section(group):
            config.add_section(group)
        config.set(group, item, value)
        if self.autoSave:
            self.save()
        
    def get_value(self, default, group = None, item = None):
        group = group or self.group
        item = item or self.item
        if group is None or item is None:
            return default
        # if item.lower().count('thorn'):
            # print 'get', default, group, item
        config = self.config
        if not config.has_section(group) or not config.has_option(group, item):
            return default
        return config.get(group, item)
    
    def remove_item(self, group = None, item = None):
        group = group or self.group
        item = item or self.item
        if group is None or item is None:
            return
        config = self.config
        try:
            config.remove_option(group, item)
        except NoSectionError:
            return
        if self.autoSave:
            self.save()
    
    def get_sections(self):
        return self.config.sections()
    
    def get_options(self, group = None):
        group = group or self.group
        if group is None:
            return []
        config = self.config
        try:
            return config.items(group)
        except NoSectionError:
            return ()
    
    def has_item(self, group = None, item = None):
        group = group or self.group
        item = item or self.item
        if group is None or item is None:
            return False
        config = self.config
        return config.has_option(group, item)
    
    def has_group(self, group = None):
        group = group or self.group
        if group is None:
            return False
        config = self.config
        return config.has_section(group)

    def remove_group(self, group = None):
        group = group or self.group
        if group is None:
            return
        config = self.config
        try:
            config.remove_section(group)
        except NoSectionError:
            return
        if self.autoSave:
            self.save()

class Ini(UserExtension):
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
        25 : Action25,
        26 : Action26,
        27 : Action27,
        28 : Action28,
        29 : Action29,
        30 : Action30,
        31 : Action31,
        32 : Action32,
        33 : Action33,
        34 : Action34,
        35 : Action35,
        36 : Action36,
        37 : Action37,
        38 : Action38,
        39 : Action39,
        40 : Action40,
        41 : Action41,
        42 : Action42,
        43 : Action43,
        44 : Action44,
        45 : Action45,
        46 : Action46,
        47 : Action47,
        48 : Action48,
        49 : Action49,
        50 : Action50,
        51 : Action51,
        52 : Action52,
        53 : Action53,
        54 : Action54,
        55 : Action55,
        56 : Action56,
        57 : Action57,
        58 : Action58,
        59 : Action59,
        60 : Action60,
        61 : Action61,
        62 : Action62,
        63 : Action63,
        64 : Action64,
        65 : Action65,
        66 : Action66,
        67 : Action67,
        68 : Action68,
        69 : Action69,
        70 : Action70,
        71 : Action71,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        7 : Condition7,
        8 : Condition8,
        9 : Condition9,
        10 : Condition10,
        11 : Condition11,
        12 : Condition12,
        13 : Condition13,
        14 : Condition14,
        15 : Condition15,
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
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
        20 : Expression20,
        21 : Expression21,
        22 : Expression22,
        23 : Expression23,
        24 : Expression24,
        25 : Expression25,
        26 : Expression26,
        28 : Expression27,
        29 : Expression28,
        30 : Expression29,
        31 : Expression30,
        32 : Expression31,
        33 : Expression32,
        34 : Expression33,
        35 : Expression34,
        36 : Expression35,
        37 : Expression36,
        38 : CurrentGroupName
    }

extension = Ini()

def get_extension():
    return extension
