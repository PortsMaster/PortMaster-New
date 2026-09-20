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
BinaryArray.mfx
Binary array - AquadaSoft/Jamie McLaughlin (http://www.aquadasoft.com)
Copyright 2007 AquadaSoft

Represents a binary array to store different data types and read
binary files

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

from mmfparser.player.common import open_file, convert_path
from binaryarray import WorkspaceArray, Workspace
from mmfparser.bytereader import ByteReader
import gzip

class Action0(Action):
    """
    File->Load file->Uncompressed

    Parameters:
    0: File path (FILENAME, Filename)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            data = open_file(filename, 'rb').read()
        except IOError:
            return
        instance.objectPlayer.workspace.data = ByteReader(data)

class Action1(Action):
    """
    File->Save file->Uncompressed

    Parameters:
    0: File path (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            open_file(filename, 'wb').write(
                str(instance.objectPlayer.workspace.data))
        except IOError:
            return

class Action2(Action):
    """
    File->Load workspace file->Uncompressed

    Parameters:
    0: File path (FILENAME, Filename)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            array = WorkspaceArray(ByteReader(open_file(filename, 'rb')))
        except IOError:
            return
        instance.objectPlayer.array = array
        instance.objectPlayer.workspace = array.items[-1]

class Action3(Action):
    """
    File->Save workspace file->Uncompressed

    Parameters:
    0: File path (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            open_file(filename, 'wb').write(
                str(instance.objectPlayer.array.generate()))
        except IOError:
            return

class Action4(Action):
    """
    Workspace->Switch

    Parameters:
    0: Workspace name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        array = instance.objectPlayer.array
        try:
            workspace = array.getWorkspace(name)
            instance.objectPlayer.workspace = workspace
        except ValueError:
            return

class WriteAction(Action):
    def execute(self, instance):
        reader = instance.objectPlayer.workspace.data
        position = self.evaluate_index(0)
        reader.seek(position)
        self.write(reader)

class Action5(WriteAction):
    """
    Write->Byte

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Value (EXPRESSION, ExpressionParameter)
    """

    def write(self, reader):
        value = self.evaluate_index(1)
        if value < 0:
            reader.writeByte(value, False)
        else:
            reader.writeByte(value, True)

class Action6(WriteAction):
    """
    Write->Integer

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Value (EXPRESSION, ExpressionParameter)
    """

    def write(self, reader):
        value = self.evaluate_index(1)
        if value < 0:
            reader.writeInt(value, False)
        else:
            reader.writeInt(value, True)

class Action7(WriteAction):
    """
    Write->String

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Value (EXPSTRING, ExpressionParameter)
    """

    def write(self, reader):
        value = self.evaluate_index(1)
        reader.write(value)

class Action8(WriteAction):
    """
    Write->Terminated string

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Value (EXPSTRING, ExpressionParameter)
    """

    def write(self, reader):
        value = self.evaluate_index(1)
        reader.writeString(value)

class Action9(WriteAction):
    """
    Write->Float

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Value (EXPRESSION, ExpressionParameter)
    """

    def write(self, reader):
        value = self.evaluate_index(1)
        reader.writeFloat(value)

class Action10(Action):
    """
    Workspace->Resize

    Parameters:
    0: Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        reader = instance.objectPlayer.workspace.data
        size = self.evaluate_index(0)
        reader.truncate(size)

class Action11(Action):
    """
    Settings->Set virtual width/height

    Parameters:
    0: X size (EXPRESSION, ExpressionParameter)
    1: Y size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        width = self.evaluate_index(0)
        height = self.evaluate_index(1)
        instance.objectPlayer.virtualWidth = width
        instance.objectPlayer.virtualHeight = height

class Action12(Action):
    """
    Workspace->Create

    Parameters:
    0: Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        instance.objectPlayer.array.createWorkspace(name,
            instance.objectPlayer.defaultSize)

class Action13(Action):
    """
    Workspace->Delete

    Parameters:
    0: Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        try:
            array = instance.objectPlayer.array.getWorkspace(name)
        except ValueError:
            return
        instance.objectPlayer.array.items.remove(array)
            
class Action14(Action):
    """
    Settings->Set default size

    Parameters:
    0: New size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.defaultSize = self.evaluate_expression(
            self.get_parameter(0))

class Action15(Action):
    """
    Workspace->Delete all
    """

    def execute(self, instance):
        instance.objectPlayer.setup()

class Action16(Action):
    """
    Workspace->Copy

    Parameters:
    0: Destination name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        reader = instance.objectPlayer.workspace.data
        newReader = ByteReader(str(reader))
        workspace = instance.objectPlayer.array.createWorkspace(
            self.evaluate_index(0))
        workspace.data = newReader

class Action17(Action):
    """
    File->Load file->Compressed

    Parameters:
    0: File path (FILENAME, Filename)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            data = gzip.GzipFile(convert_path(filename), 'rb').read()
        except IOError:
            return
        instance.objectPlayer.workspace.data = ByteReader(data)

class Action18(Action):
    """
    File->Save file->Compressed

    Parameters:
    0: File path (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            gzip.GzipFile(convert_path(filename), 'wb').write(
                str(instance.objectPlayer.workspace.data))
        except IOError:
            return

class Action19(Action):
    """
    File->Load workspace file->Compressed

    Parameters:
    0: File path (FILENAME, Filename)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            array = WorkspaceArray(ByteReader(
                gzip.GzipFile(convert_path(filename), 'rb').read()))
        except IOError:
            return
        instance.objectPlayer.array = array
        instance.objectPlayer.workspace = array.items[-1]

class Action20(Action):
    """
    File->Save workspace file->Compressed

    Parameters:
    0: File path (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            gzip.GzipFile(convert_path(filename), 'wb').write(
                str(instance.objectPlayer.array.generate()))
        except IOError:
            return

class Action21(WriteAction):
    """
    Write->Range

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Size (EXPRESSION, ExpressionParameter)
    2: New value (EXPRESSION, ExpressionParameter)
    """

    def write(self, reader):
        size = self.evaluate_index(1)
        value = self.evaluate_index(2)
        for _ in xrange(size):
            if value < 0:
                reader.writeByte(value)
            else:
                reader.writeByte(value, True)

class Action22(WriteAction):
    """
    Write->Short

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Value (EXPRESSION, ExpressionParameter)
    """

    def write(self, reader):
        value = self.evaluate_index(1)
        if value < 0:
            reader.writeShort(value)
        else:
            reader.writeShort(value, True)

class Action23(Action):
    """
    Write->Entity

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Source position (EXPRESSION, ExpressionParameter)
    2: Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('cannot read from memory')

class Action24(Action):
    """
    Settings->Use big-endian
    """

    def execute(self, instance):
        raise NotImplementedError('only little-endian supported')

class Action25(Action):
    """
    Settings->Use little-endian
    """

    def execute(self, instance):
        return

# Conditions

class Condition0(Condition):
    """
    Workspace exists

    Parameters:
    0: Workspace name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        name = self.evaluate_index(0)
        try:
            instance.objectPlayer.array.getWorkspace(name)
            return True
        except ValueError:
            return False

# Expressions

class ReadExpression(Expression):
    def get(self, instance):
        position = self.next_argument()
        reader = instance.objectPlayer.workspace.data
        reader.seek(position)
        return self.read(reader)

class Expression0(ReadExpression):
    """
    Read->Byte->Unsigned

    Parameters:
    0: Position (Int)
    Return type: Int
    """

    def read(self, reader):
        return reader.readByte(True)

class ReadSignedByte(ReadExpression):
    """
    Read->Byte->Signed

    Parameters:
    0: Position (Int)
    Return type: Int
    """

    def read(self, reader):
        return reader.readByte()

class Expression2(ReadExpression):
    """
    Read->Integer->Unsigned

    Parameters:
    0: Position (Int)
    Return type: Int
    """

    def read(self, reader):
        return reader.readInt(True)

class Expression3(ReadExpression):
    """
    Read->String->With size

    Parameters:
    0: Position (Int)
    1: Size (Int)
    Return type: String
    """

    def read(self, reader):
        size = self.next_argument()
        return reader.read(size)

class Expression4(ReadExpression):
    """
    Read->String->Null terminated

    Parameters:
    0: Position (Int)
    Return type: String
    """

    def read(self, reader):
        return reader.readString()

class Expression5(Expression):
    """
    Combine->X/Y coordinates

    Parameters:
    0: X (Int)
    1: Y (Int)
    Return type: Int
    """

    def get(self, instance):
        x = self.next_argument()
        y = self.next_argument()
        objectPlayer = instance.objectPlayer
        return y * objectPlayer.virtualWidth + x

class Expression6(Expression):
    """
    Combine->X/Y/Z coordinates

    Parameters:
    0: X (Int)
    1: Y (Int)
    2: Z (Int)
    Return type: Int
    """

    def get(self, instance):
        x = self.next_argument()
        y = self.next_argument()
        z = self.next_argument()
        objectPlayer = instance.objectPlayer
        width = objectPlayer.virtualWidth
        height = objectPlayer.virtualHeight
        return z * width * height + y * width + x

class Expression7(ReadExpression):
    """
    Read->Float

    Parameters:
    0: Position (Int)
    Return type: Float
    """

    def read(self, reader):
        return reader.readFloat()

class Expression8(ReadExpression):
    """
    Read->Short->Unsigned

    Parameters:
    0: Position (Int)
    Return type: Int
    """

    def read(self, reader):
        return reader.readShort(True)

class Expression9(ReadExpression):
    """
    Read->Short->Signed

    Parameters:
    0: Position (Int)
    Return type: Int
    """

    def read(self, reader):
        return reader.readShort()

class Expression10(Expression):
    """
    Get array size
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.workspace.data)

class Expression11(Expression):
    """
    Get number of workspaces
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.array.items)

class Expression12(ReadExpression):
    """
    Read->Integer->Signed

    Parameters:
    0: Position (Int)
    Return type: Int
    """

    def read(self, reader):
        return reader.readInt()

class DefaultObject(HiddenObject):
    array = None
    workspace = None
    def created(self, data):
        self.virtualWidth = data.readInt(True)
        self.virtualHeight = data.readInt(True)
        self.defaultSize = data.readInt(True)
        self.array = array = WorkspaceArray()
        self.workspace = array.createWorkspace('', self.defaultSize)
    
    def setup(self):
        self.array = array = WorkspaceArray()
        self.workspace = array.createWorkspace('', self.defaultSize)

class BinaryArray(UserExtension):
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
    }
    
    conditions = {
        0 : Condition0,
    }
    
    expressions = {
        0 : Expression0,
        1 : ReadSignedByte,
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
    }

extension = BinaryArray()

def get_extension():
    return extension
