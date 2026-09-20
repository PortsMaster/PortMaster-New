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
Blowfish.mfx
Blowfish Encryption Object - Matt Galanto (http://www.bumderland.com)

A powerful encryption object that uses the famous Blowfish encryption
algorithm to encrypt strings internally, and files.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

from mmfblowfish import MMFBlowfish

# Actions

class Action0(Action):
    """
    Encryption Keys->Add an Encryption Key

    Parameters:
    0: Enter the Encryption Key (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        key = self.evaluate_index(0)
        instance.objectPlayer.add_key(key)
        print 'key added:', key

class Action1(Action):
    """
    Encryption Keys->Remove an Encryption Key

    Parameters:
    0: Enter the Encryption Key (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action2(Action):
    """
    Character Filter->Add Characters to Filter

    Parameters:
    0: Enter the Characters (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action3(Action):
    """
    Character Filter->Add a Character to Filter by Code

    Parameters:
    0: Enter the Character Code (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action4(Action):
    """
    Character Filter->Remove Characters from Filter

    Parameters:
    0: Enter the Characters (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action5(Action):
    """
    Character Filter->Remove a Character from Filter by Code

    Parameters:
    0: Enter the Character Code (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action6(Action):
    """
    Errors->Clear Expression Error Code

    Parameters:
    0:  ((unknown 25070))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    """
    Files->Encrypt a File

    Parameters:
    0: Enter the Encryption Key (TIME, Time)
    1: Enter the File (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        key = self.evaluate_index(0)
        filename = self.evaluate_index(1)
        
        try:
            data = open(filename, 'rb').read()
            data = instance.objectPlayer.encrypt(data, key)
            open(filename, 'wb').write(data)
        except (KeyError, IOError):
            return
        

class Action8(Action):
    """
    Files->Decrypt a File

    Parameters:
    0: Enter the Encryption Key (TIME, Time)
    1: Enter the File (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        key = self.evaluate_index(0)
        filename = self.evaluate_index(1)
        
        try:
            data = open(filename, 'rb').read()
            data = instance.objectPlayer.decrypt(data, key)
            open(filename, 'wb').write(data)
        except (KeyError, IOError):
            return

class Action9(Action):
    """
    Settings->Do not Pad End of Files with Zeros

    Parameters:
    0:  ((unknown 25100))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action10(Action):
    """
    Settings->Pad End of Files with Zeros

    Parameters:
    0:  ((unknown 25110))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action11(Action):
    """
    Settings->Enable Filtering of Characters with Codes 0 to 31

    Parameters:
    0:  ((unknown 25120))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    """
    Settings->Disable Filtering of Characters with Codes 0 to 31

    Parameters:
    0:  ((unknown 25130))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    """
    Files->Set File Work Time Interval

    Parameters:
    0: Enter the File Work Time Interval in Milliseconds (0 to Disable) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action14(Action):
    """
    Files->Set File Work Percentage Interval

    Parameters:
    0: Enter the File Work Percentage Interval (0 to Disable) (OBJECT, Object)
    1: Set File Work Percentage Interval (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    Errors->Has an Error Occured?

    Parameters:
    0:  ((unknown 26010))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Encryption Keys->Does a Specific Key Exist?

    Parameters:
    0: Enter the Encryption Key (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition2(Condition):
    """
    Character Filter->Is a Specific Character Being Filtered?

    Parameters:
    0: Enter the Character (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition3(Condition):
    """
    Character Filter->Is a Specific Character (by Code) Being Filtered?

    Parameters:
    0: Enter the Character Code (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition4(Condition):
    """
    Settings->Is Set to Pad End of Files with Zeros?

    Parameters:
    0:  ((unknown 26050))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition5(Condition):
    """
    Settings->Is Filtering of Characters with Codes 0 to 31 Enabled?

    Parameters:
    0:  ((unknown 26060))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition6(Condition):
    """
    Files->Has File Finished Being Encrypted/Decrypted?

    Parameters:
    0:  ((unknown 26070))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition7(Condition):
    """
    Files->Is File Being Encrypted/Decrypted?
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Encrypting->Encrypt an Integer

    Parameters:
    0: (not found) (AlterableValue)
    1: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Floats->Convert a Float to an Integer

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression2(Expression):
    """
    Encrypting->Encrypt a String

    Parameters:
    0: (not found) (Global)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Decrypting->Decrypt an Integer

    Parameters:
    0: (not found) (AlterableValue)
    1: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Floats->Convert an Integer Back to a Float

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Decrypting->Decrypt a String

    Parameters:
    0: (not found) (Global)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Filtering->Filter a String

    Parameters:
    0: (not found) (Int)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Filtering->Defilter a String

    Parameters:
    0: (not found) (Int)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    """
    Errors->Get Current Error Code

    Parameters:
    0: (not found) ((unknown 27090))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    Errors->Get Current Expression Error Code

    Parameters:
    0: (not found) ((unknown 27100))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression10(Expression):
    """
    Encryption Keys->Create a Random Key

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    Files->Get File Work Time Interval

    Parameters:
    0: (not found) ((unknown 27120))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    Files->Get File Work Progress

    Parameters:
    0: (not found) ((unknown 27130))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression13(Expression):
    """
    Files->Get File Work Percentage Interval

    Parameters:
    0: (not found) ((unknown 27140))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression14(Expression):
    """
    Files->Get File Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

from mmfparser.bitdict import BitDict

FLAGS = BitDict(
    'FilterCharacters',
    'NoPadding'
)

global_keys = {}

class DefaultObject(HiddenObject):
    def created(self, data):
        self.flags = flags = FLAGS.copy()
        flags.setFlags(data.readInt())
        data.skipBytes(4)
        self.filter = filter = []
        while 1:
            byte = data.read(1)
            if byte == '\x00':
                data.skipBytes(1)
                break
            filter.append(byte)
        while 1:
            byte = data.read(1)
            byte2 = data.read(1)
            if byte == '\xFF' and byte2 == '\xFF':
                break
            filter.append(byte)
    
    def add_key(self, key):
        global_keys[key] = MMFBlowfish(key)
    
    def encrypt(self, data, key):
        cipher = global_keys[key]
        return cipher.encrypt(data)

    def decrypt(self, data, key):
        cipher = global_keys[key]
        return cipher.decrypt(data)

class Blowfish(UserExtension):
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

extension = Blowfish()

def get_extension():
    return extension
