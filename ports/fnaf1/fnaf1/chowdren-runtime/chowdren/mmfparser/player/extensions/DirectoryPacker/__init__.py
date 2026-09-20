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
DirectoryPacker.mfx
Directory packer - AquadaSoft/Jamie McLaughlin (http://www.aquadasoft.com)
Copyright 2007 AquadaSoft

Packs a directory into a single file

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import open_file as open

import os
import shutil

# Actions

class PackDirectory(Action):
    """
    Pack directory

    Parameters:
    0: Directory (EXPSTRING, ExpressionParameter)
    1: Destination filename (EXPSTRING, ExpressionParameter)
    """
    
    def created(self):
        self.conditions = self.get_conditions(PackingFinished)
    
    def execute(self, instance):
        src = self.evaluate_index(0)
        dest = self.evaluate_index(1)
        instance.objectPlayer.pack(src, dest)
        for condition in self.conditions:
            condition.generate()

class UnpackFile(Action):
    """
    Unpack file

    Parameters:
    0: Packed file (FILENAME, Filename)
    1: Destination directory (EXPSTRING, ExpressionParameter)
    2: Stop if folder exists? (0 = no, 1 = yes) (EXPRESSION, ExpressionParameter)
    """
    def created(self):
        self.conditions = self.get_conditions(UnpackingFinished)

    def execute(self, instance):
        src = self.evaluate_index(0)
        dest = self.evaluate_index(1)
        force = self.evaluate_index(2)
        instance.objectPlayer.unpack(src, dest, force)
        for condition in self.conditions:
            condition.generate()

class DeleteDirectory(Action):
    """
    Delete directory

    Parameters:
    0: Directory to delete (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        shutil.rmtree(self.evaluate_index(0), True)

class EnableExtensionFilter(Action):
    """
    Enable extension filter

    Parameters:
    0: 0 = block list, 1 = only allow list (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        value = self.evaluate_index(0)
        if value:
            objectPlayer.include = True
            objectPlayer.exclude = False
        else:
            objectPlayer.include = False
            objectPlayer.exclude = True

class DisableExtensionFilter(Action):
    """
    Disable extension filter
    """

    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        objectPlayer.include = False
        objectPlayer.exclude = False

class AddExtensionFilter(Action):
    """
    Add extension to filter list

    Parameters:
    0: Extension to add (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        extension = self.evaluate_index(0)
        instance.objectPlayer.filters.append(extension)

class RemoveExtensionFilter(Action):
    """
    Remove extension from filter list

    Parameters:
    0: Extension to remove (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        extension = self.evaluate_index(0)
        instance.objectPlayer.filters.remove(extension)

class PackDirectoryBlocking(PackDirectory):#Action):
    """
    Pack directory (this thread)

    Parameters:
    0: Directory (EXPSTRING, ExpressionParameter)
    1: Destination filename (EXPSTRING, ExpressionParameter)
    """

    # def execute(self, instance):
        # pass

class UnpackFileBlocking(UnpackFile):#Action):
    """
    Unpack file (this thread)

    Parameters:
    0: Packed file (FILENAME, Filename)
    1: Destination directory (EXPSTRING, ExpressionParameter)
    2: Stop if folder exists? (0 = no, 1 = yes) (EXPRESSION, ExpressionParameter)
    """

    # def execute(self, instance):
        # pass


# Conditions

class ErrorOccured(Condition):
    """
    An error occured
    """

    def check(self, instance):
        return self.isTriggered

class PackingFinished(Condition):
    """
    Packing finished
    """

    def check(self, instance):
        return self.isTriggered

class UnpackingFinished(Condition):
    """
    Unpacking finished
    """

    def check(self, instance):
        return self.isTriggered

class PackingFailed(Condition):
    """
    Packing failed
    """

    def check(self, instance):
        return self.isTriggered

class UnpackingFailed(Condition):
    """
    Unpacking failed
    """

    def check(self, instance):
        return self.isTriggered

class FileAllowed(Condition):
    """
    File is allowed

    Parameters:
    0: Filename (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        extension = self.evaluate_expression(
            self.get_parameter(0)).split('.')[-1]
        return instance.objectPlayer.filters.count(extension)

# Expressions

class ProgressString(Expression):
    """
    Get current process
    Return type: String
    """

    def get(self, instance):
        return ''

class ProgressPercent(Expression):
    """
    Get current progress %
    Return type: Int
    """

    def get(self, instance):
        return 0

class GetLastError(Expression):
    """
    Get last error
    Return type: String
    """

    def get(self, instance):
        return ''

class GetLastWindowsError(Expression):
    """
    Get last windows error
    Return type: String
    """

    def get(self, instance):
        return ''

from directorypacker import DirectoryPacker
from mmfparser.bytereader import ByteReader

class DefaultObject(HiddenObject):
    include = False
    exclude = False
    filters = None
    def created(self):
        self.filters = []
    
    def pack(self, src, dest):
        files = DirectoryPacker()
        if self.include:
            files.pack(src, include = self.filters)
        elif self.exclude:
            files.pack(src, exclude = self.filters)
        open(dest, 'wb').write(str(files.generate()))
        
    def unpack(self, src, dest, force):
        if not force and os.path.isdir(dest):
            return
        reader = ByteReader(open(src, 'rb'))
        files = DirectoryPacker(reader)
        files.unpack(dest)

class DirectoryPackerExtension(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : PackDirectory,
        1 : UnpackFile,
        2 : DeleteDirectory,
        3 : EnableExtensionFilter,
        4 : DisableExtensionFilter,
        5 : AddExtensionFilter,
        6 : RemoveExtensionFilter,
        7 : PackDirectoryBlocking,
        8 : UnpackFileBlocking,
    }
    
    conditions = {
        0 : ErrorOccured,
        1 : PackingFinished,
        2 : UnpackingFinished,
        3 : PackingFailed,
        4 : UnpackingFailed,
        5 : FileAllowed,
    }
    
    expressions = {
        0 : ProgressString,
        1 : ProgressPercent,
        2 : GetLastError,
        3 : GetLastWindowsError,
    }

extension = DirectoryPackerExtension()

def get_extension():
    return extension
