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
kcfile.mfx
File object - ClickTeam (http://www.clickteam.com)

Allows you to perform basic file and disk operations such as renaming,
copying and deleting files, creating sub-directories, and launching
external applications.

Ported to Python by Mathias Kaerlev
"""

import os
import shutil
import time
import sys

from mmfparser.player.extensions.common import (UserExtension, 
    HiddenObject, get_application_directory)
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import convert_path

from mmfparser.player.dialog import *

# Actions

class FileAction(Action):
    def execute(self, instance):
        if instance.objectPlayer.error is not None:
            return
        try:
            ret = self.action(instance)
        except OSError, e:
            instance.objectPlayer.error = e

class ChangeWorkingDirectory(FileAction):
    """
    Directory Actions->Change the current directory

    Parameters:
    0: Name of directory to set (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        path = convert_path(self.evaluate_index(0))
        os.chdir(path)

class SetOriginalDirectory(FileAction):
    """
    Directory Actions->Set directory to original
    """

    def action(self, instance):
        os.chdir(instance.objectPlayer.originalDirectory)

class CreateDirectory(FileAction):
    """
    Directory Actions->Create a directory

    Parameters:
    0: Name of directory to create (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        os.mkdir(path)

class DeleteDirectory(FileAction):
    """
    Directory Actions->Delete a directory

    Parameters:
    0: Name of directory to delete (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        os.rmdir(path)

class CreateFile(FileAction):
    """
    File Actions->Create a file

    Parameters:
    0: Name of file to create (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        open(path, 'wb').close()

class DeleteFile(FileAction):
    """
    File Actions->Delete a file

    Parameters:
    0: Name of file to delete (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        os.remove(path)

class RenameFile(FileAction):
    """
    File Actions->Rename a file

    Parameters:
    0: Name of file to rename (EXPSTRING, ExpressionParameter)
    1: New name for the file (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        src = convert_path(
            self.evaluate_index(0))
        dest = convert_path(
            self.evaluate_index(0))
        os.rename(src, dest)

class AppendFile(FileAction):
    """
    File Actions->Append a file to a file

    Parameters:
    0: Source file to append (EXPSTRING, ExpressionParameter)
    1: Destination file (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        src = convert_path(
            self.evaluate_index(0))
        dest = convert_path(
            self.evaluate_index(0))
        open(dest, 'ab').write(open(src, 'rb').read())

class CopyFile(FileAction):
    """
    File Actions->Copy a file

    Parameters:
    0: Source file name (EXPSTRING, ExpressionParameter)
    1: Destination file name (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        src = convert_path(
            self.evaluate_index(0))
        dest = convert_path(
            self.evaluate_index(1))
        shutil.copyfile(src, dest)

class MoveFile(FileAction):
    """
    File Actions->Move a file

    Parameters:
    0: Source file name (EXPSTRING, ExpressionParameter)
    1: Destination file name (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        src = convert_path(
            self.evaluate_index(0))
        dest = convert_path(
            self.evaluate_index(0))
        os.rename(src, dest)

class AppendText(FileAction):
    """
    File Actions->Append text to a file

    Parameters:
    0: String to append (EXPSTRING, ExpressionParameter)
    1: Destination file (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance):
        value = self.evaluate_index(0)
        filename = convert_path(
            self.evaluate_index(0))
        open(filename, 'ab').write(value)

class ClearError(Action):
    """
    Clear the last error
    """

    def execute(self, instance):
        instance.objectPlayer.error = None

class RunApplication(Action):
    """
    File Actions->Run application

    Parameters:
    0: Name of application to run (EXPSTRING, ExpressionParameter)
    1: Enter "(hide,wait)" then command line (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class SetSelectorTitle(Action):
    """
    File Selector->Set title

    Parameters:
    0: Set title (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.title = self.evaluate_expression(
            self.get_parameter(0))

class SetSelectorStyle(Action):
    """
    File Selector->Set style

    Parameters:
    0: Set file selector style : choose a style in file object... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class SetSelectorFilter(Action):
    """
    File Selector->Set extension filter

    Parameters:
    0: Enter filter : ''description1|*.xxx;*.yyy|description2|*.zzz'' (EXPSTRING, ExpressionParameter)
    1: Enter number of default filter... (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        splitted = self.evaluate_index(0).split('|')
        for i in xrange(0, len(splitted), 2):
            description = splitted[i]
            patterns = splitted[i+1].split(';')
            instance.objectPlayer.filters.append((description, patterns))
        

class SetDefaultSelectorExtension(Action):
    """
    File Selector->Set default extension

    Parameters:
    0: Set default extension (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class OpenLoadSelector(Action):
    """
    File Selector->Open load selector

    Parameters:
    0: Enter default pathname... (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        defaultPath = convert_path(
            self.evaluate_index(0))
        objectPlayer = instance.objectPlayer
        objectPlayer.path = open_file_selector(title = objectPlayer.title,
            filters = objectPlayer.filters,
            root = defaultPath)

class OpenSaveSelector(Action):
    """
    File Selector->Open save selector

    Parameters:
    0: Enter default pathname... (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        defaultPath = convert_path(
            self.evaluate_index(0))
        objectPlayer = instance.objectPlayer
        objectPlayer.path = open_save_selector(title = objectPlayer.title,
            filters = objectPlayer.filters,
            root = defaultPath)

class SetSingleSelection(Action):
    """
    File Selector->Set Selection Mode->Single
    """

    def execute(self, instance):
        pass

class SetMultipleSelection(Action):
    """
    File Selector->Set Selection Mode->Multiple
    """

    def execute(self, instance):
        pass

class OpenDirectorySelector(Action):
    """
    File Selector->Open directory selector

    Parameters:
    0: Enter default pathname... (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass


# Conditions

class LastActionSuccess(Condition):
    """
    Last action OK
    """

    def check(self, instance):
        return instance.objectPlayer.error == None

class NameExists(Condition):
    """
    Name exists

    Parameters:
    0: Name to test (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        return os.path.exists(path)

class FileReadable(Condition):
    """
    File is readable

    Parameters:
    0: Name of file to test (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        try:
            f = open(path, 'rb')
            f.close()
            return True
        except OSError:
            return False

class FileWriteable(Condition):
    """
    File is writeable

    Parameters:
    0: Name of file to test (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        try:
            f = open(path, 'r+')
            f.close()
            return True
        except (IOError, OSError):
            return False

class IsFile(Condition):
    """
    Name is a file

    Parameters:
    0: Name of file to test (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        return os.path.isfile(path)

class IsDirectory(Condition):
    """
    Name is a directory

    Parameters:
    0: Name of directory to test (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        path = convert_path(
            self.evaluate_index(0))
        return os.path.isdir(path)

# Expressions

class FileSize(Expression):
    """
    File Attributes->Size of a file

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        path = convert_path(self.next_argument())
        try:
            return os.path.getsize(path)
        except OSError:
            return 0

class CreationDate(Expression):
    """
    File Attributes->Creation date

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        path = convert_path(self.next_argument())
        try:
            value = time.gmtime(os.path.getctime(path))
        except OSError:
            return ''
        return time.strftime('%d/%m/%y', value)

class ModificationDate(Expression):
    """
    File Attributes->Modification date

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        path = convert_path(self.next_argument())
        try:
            value = time.gmtime(os.path.getmtime(path))
        except OSError:
            return ''
        return time.strftime('%d/%m/%y', value)

class LastAccessDate(Expression):
    """
    File Attributes->Last access date

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        path = convert_path(self.next_argument())
        try:
            value = time.gmtime(os.path.getatime(path))
        except OSError:
            return ''
        return time.strftime('%d/%m/%y', value)

class DriveName(Expression):
    """
    Names->Drive name

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        value = convert_path(self.next_argument())
        return os.path.splitdrive(value)[0]

class DirectoryName(Expression):
    """
    Names->Directory name

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        value = convert_path(self.next_argument())
        return os.path.splitdrive(os.path.dirname(value))[1]

class FileTitle(Expression):
    """
    Names->File title

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        value = convert_path(self.next_argument())
        return os.path.splitext(os.path.basename(value))[0]

class ExtensionName(Expression):
    """
    Names->Extension name

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        value = convert_path(self.next_argument())
        return os.path.splitext(os.path.basename(value))[1]

class TotalPath(Expression):
    """
    Names->Total pathway of a file

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        value = convert_path(self.next_argument())
        return os.path.normpath(value)

class CurrentDirectory(Expression):
    """
    Directories->Current directory
    Return type: Int
    """

    def get(self, instance):
        return os.getcwd()

class MostSignificantNumber(Expression):
    """
    File Version->Most significant number

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        return 0

class LessSignificantNumber(Expression):
    """
    File Version->Less significant number

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        return 0

class LastErrorCode(Expression):
    """
    Last error code
    Return type: Int
    """

    def get(self, instance):
        error = instance.objectPlayer.error
        if error is None:
            return 0
        return error.errno

from mmfparser.player.temp import NamedTemporaryFile

class TemporaryFilename(Expression):
    """
    Names->Temporary filename

    Parameters:
    0:  (String)
    Return type: Int
    """

    def get(self, instance):
        prefix = self.next_argument()
        fp = NamedTemporaryFile(prefix = prefix)
        return fp.name

class WindowsDirectory(Expression):
    """
    Directories->Windows directory
    Return type: Int
    """

    def get(self, instance):
        return ''

class GetResultPathname(Expression):
    """
    File selector->Get result pathname
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.path

class AllowCreateFile(Expression):
    """
    File selector->Allow create file prompt
    Return type: Int
    """

    def get(self, instance):
        return 0

class AllowNonexistantFile(Expression):
    """
    File selector->Allow non existant file
    Return type: Int
    """

    def get(self, instance):
        return 0

class AllowDirectoryChange(Expression):
    """
    File selector->Allow directory change
    Return type: Int
    """

    def get(self, instance):
        return 0

class NoOverwritePrompt(Expression):
    """
    File selector->No overwrite prompt
    Return type: Int
    """

    def get(self, instance):
        return 0

class AllowNonexistantPath(Expression):
    """
    File selector->Allow non existant path
    Return type: Int
    """

    def get(self, instance):
        return 0

class GetDefaultFilter(Expression):
    """
    File selector->Get default filter
    Return type: Int
    """

    def get(self, instance):
        return ''

class GetPathnameCount(Expression):
    """
    File selector->Multi-selection->Get number of pathnames
    Return type: Int
    """

    def get(self, instance):
        pass

class GetPathname(Expression):
    """
    File selector->Multi-selection->Get pathname at...

    Parameters:
    0: File number (Int)
    Return type: Int
    """

    def get(self, instance):
        pass

class GetCDDirectoryFromLabel(Expression):
    """
    Directories->Get CDROM Directory From Label

    Parameters:
    0: Disc label (String)
    Return type: Int
    """

    def get(self, instance):
        return ''

class SystemDirectory(Expression):
    """
    Directories->System directory
    Return type: Int
    """

    def get(self, instance):
        return ''

class DocumentsDirectory(Expression):
    """
    Directories->My Documents directory
    Return type: Int
    """

    def get(self, instance):
        return os.path.expanduser('~')

class ApplicationDataDirectory(Expression):
    """
    Directories->Application Data directory
    Return type: Int
    """

    def get(self, instance):
        return get_application_directory()

class UserDirectory(Expression):
    """
    Directories->User directory
    Return type: Int
    """

    def get(self, instance):
        return os.path.expanduser('~')

class AllUsersDirectory(Expression):
    """
    Directories->All Users directory
    Return type: Int
    """

    def get(self, instance):
        return ''

class AllUsersDocumentsDirectory(Expression):
    """
    Directories->All Users Documents Directory
    Return type: Int
    """

    def get(self, instance):
        return ''

class AllUsersApplicationDataDirectory(Expression):
    """
    Directories->All Users Application Data Directory
    Return type: Int
    """

    def get(self, instance):
        if sys.platform == 'win32':
            return os.environ['APPDATA']
        return os.path.expanduser('~')

class DefaultObject(HiddenObject):
    defaultExtension = None
    filters = None
    path = None
    originalDirectory = None
    error = None
    def created(self, data):
        self.originalDirectory = os.getcwd()
        self.filters = []

class kcfile(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : ChangeWorkingDirectory,
        1 : SetOriginalDirectory,
        2 : CreateDirectory,
        3 : DeleteDirectory,
        4 : CreateFile,
        5 : DeleteFile,
        6 : RenameFile,
        7 : AppendFile,
        8 : CopyFile,
        9 : MoveFile,
        10 : AppendText,
        11 : ClearError,
        12 : RunApplication,
        13 : SetSelectorTitle,
        14 : SetSelectorStyle,
        16 : SetSelectorFilter,
        17 : SetDefaultSelectorExtension,
        18 : OpenLoadSelector,
        19 : OpenSaveSelector,
        20 : SetSingleSelection,
        21 : SetMultipleSelection,
        22 : OpenDirectorySelector,
    }
    
    conditions = {
        0 : LastActionSuccess,
        1 : NameExists,
        2 : FileReadable,
        3 : FileWriteable,
        4 : IsFile,
        5 : IsDirectory,
    }
    
    expressions = {
        0 : FileSize,
        1 : CreationDate,
        2 : ModificationDate,
        3 : LastAccessDate,
        4 : DriveName,
        5 : DirectoryName,
        6 : FileTitle,
        7 : ExtensionName,
        8 : TotalPath,
        9 : CurrentDirectory,
        10 : MostSignificantNumber,
        11 : LessSignificantNumber,
        12 : LastErrorCode,
        13 : TemporaryFilename,
        14 : WindowsDirectory,
        15 : GetResultPathname,
        16 : AllowCreateFile,
        17 : AllowNonexistantFile,
        18 : AllowDirectoryChange,
        20 : NoOverwritePrompt,
        21 : AllowNonexistantPath,
        22 : GetDefaultFilter,
        23 : GetPathnameCount,
        24 : GetPathname,
        25 : GetCDDirectoryFromLabel,
        26 : SystemDirectory,
        27 : DocumentsDirectory,
        28 : ApplicationDataDirectory,
        29 : UserDirectory,
        30 : AllUsersDirectory,
        31 : AllUsersDocumentsDirectory,
        32 : AllUsersApplicationDataDirectory,
    }

extension = kcfile()

def get_extension():
    return extension
