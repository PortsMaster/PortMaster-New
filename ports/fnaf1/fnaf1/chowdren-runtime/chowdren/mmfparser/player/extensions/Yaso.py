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
Yaso.mfx
YASO object - Jack Webster (http://www.clickteam.com)
Copyright Jack Webster 2005

This object, 'Yet Another System Object', deals with file
associations, folders and paths, shut down events and various other
system related tasks. MMF2 Developer only.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import (UserExtension, HiddenObject,
    get_application_directory)
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Add file to list of recent documents

    Parameters:
    0: Select file (OBJECT, Object)
    1: Connect to Internet with title %0 (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action1(Action):
    """
    Connect to Internet

    Parameters:
    0: Title of dialog (TIME, Time)
    1: 0 = 'Cancel' button , 1 = 'Work offline' button (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action2(Action):
    """
    Shutdown Features->Allow Shutdown

    Parameters:
    0: Disallow shutdown ((unknown 25030))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action3(Action):
    """
    Shutdown Features->Disallow Shutdown

    Parameters:
    0: Allow shutdown = %0 (0 = No, 1 = Yes ) ((unknown 25040))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action4(Action):
    """
    Shutdown Features->Set by value

    Parameters:
    0: 0 = Disallow , 1 = Allow (OBJECT, Object)
    1: Associate %0 to %2 for type %1 with icon %3 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action5(Action):
    """
    Association Features->For single extension->Associate

    Parameters:
    0: Extension (e.g. '.txt') (SHORT, Short)
    1: Type (e.g. 'open' or 'edit') (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action6(Action):
    """
    Association Features->For single extension->Un-associate

    Parameters:
    0: Extension (e.g. '.txt') (TIME, Time)
    1: Type (e.g. 'open' or 'edit') (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action7(Action):
    """
    Association Features->For all file extensions->Associate

    Parameters:
    0: Type (e.g. 'open') (TIME, Time)
    1: Path of program to associate with (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action8(Action):
    """
    Association Features->For all file extensions->Un-associate

    Parameters:
    0: Type (e.g. 'open') (OBJECT, Object)
    1: Set error string in %o to %0 (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action9(Action):
    """
    System Folder Options->Set Error String

    Parameters:
    0: Error string (e.g. '#err') (OBJECT, Object)
    1: Give current users path when global path cannot be found? %0 (0 = No , 1 = Yes) (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action10(Action):
    """
    System Folder Options->Give current users path when global path cannot be found?

    Parameters:
    0: 0 = No , 1 = Yes (OBJECT, Object)
    1: Give My Documents when other personal folder cannot be found? %0 (0 = No , 1 = Yes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action11(Action):
    """
    System Folder Options->Give My Documents when other personal folder cannot be found?

    Parameters:
    0: 0 = No , 1 = Yes (OBJECT, Object)
    1: Give My Documents when other personal folder cannot be found? (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Conditions

class Condition0(Condition):
    """
    Is Windows NT/2K/XP?

    Parameters:
    0: Is connected to the internet? ((unknown 26010))
    """

    def check(self, instance):
        print 'hello'
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition1(Condition):
    """
    Is connected to the internet?

    Parameters:
    0: Does %0 fit %1? ((unknown 26020))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition2(Condition):
    """
    Is wild card match?

    Parameters:
    0: String to search (TIME, Time)
    1: String to compare to (e.g. '*hello*') (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition3(Condition):
    """
    Shutdown Events->On Shutdown Aborted

    Parameters:
    0: %0 has an association for %1 ((unknown 26040))
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition4(Condition):
    """
    Associate Conditions->Has Association 

    Parameters:
    0: Extension (e.g. '.txt') (TIME, Time)
    1: Type (e.g. 'open') (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition5(Condition):
    """
    Associate Conditions->Has Global Association 

    Parameters:
    0: Type (e.g. 'open') (OBJECT, Object)
    1: Has Global Association  (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Expressions

class Expression0(Expression):
    """
    Folder Features->All users folders->Application Data

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression1(Expression):
    """
    Folder Features->All users folders->Favorites

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression2(Expression):
    """
    Folder Features->All users folders->Desktop

    Parameters:
    0: (not found) ((unknown 27030))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression3(Expression):
    """
    Folder Features->All users folders->Templates

    Parameters:
    0: (not found) ((unknown 27040))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression4(Expression):
    """
    Folder Features->All users folders->Shared Documents

    Parameters:
    0: (not found) ((unknown 27050))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression5(Expression):
    """
    Folder Features->All users folders->Program Files

    Parameters:
    0: (not found) ((unknown 27060))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression6(Expression):
    """
    Folder Features->All users folders->System Folder

    Parameters:
    0: (not found) ((unknown 27070))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression7(Expression):
    """
    Folder Features->All users folders->Windows Folder

    Parameters:
    0: (not found) ((unknown 27080))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression8(Expression):
    """
    Folder Features->Current user folders->Application Data

    Parameters:
    0: (not found) ((unknown 27090))
    Return type: String
    """

    def get(self, instance):
        return get_application_directory()

class Expression9(Expression):
    """
    Folder Features->Current user folders->Recent Documents

    Parameters:
    0: (not found) ((unknown 27100))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression10(Expression):
    """
    Folder Features->Current user folders->Start Menu

    Parameters:
    0: (not found) ((unknown 27110))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression11(Expression):
    """
    Folder Features->Current user folders->Programs (in Start Menu)

    Parameters:
    0: (not found) ((unknown 27120))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression12(Expression):
    """
    Folder Features->Current user folders->Send To

    Parameters:
    0: (not found) ((unknown 27130))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression13(Expression):
    """
    Folder Features->Current user folders->Start up

    Parameters:
    0: (not found) ((unknown 27140))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression14(Expression):
    """
    Folder Features->Current user folders->Desktop

    Parameters:
    0: (not found) ((unknown 27150))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression15(Expression):
    """
    Folder Features->Current user folders->Personal data folders->My Documents

    Parameters:
    0: (not found) ((unknown 27160))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression16(Expression):
    """
    Folder Features->Current user folders->Personal data folders->My Pictures

    Parameters:
    0: (not found) ((unknown 27170))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression17(Expression):
    """
    Folder Features->Current user folders->Personal data folders->My Music

    Parameters:
    0: (not found) ((unknown 27180))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression18(Expression):
    """
    Folder Features->Current user folders->Personal data folders->My Videos

    Parameters:
    0: (not found) ((unknown 27190))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression19(Expression):
    """
    Folder Features->Current user folders->Personal data folders->My Favorites

    Parameters:
    0: (not found) ((unknown 27200))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression20(Expression):
    """
    Folder Features->Get Error String

    Parameters:
    0: (not found) ((unknown 27210))
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression21(Expression):
    """
    Folder Features->Get Relative Path ( From , To )

    Parameters:
    0: (not found) (Global)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression22(Expression):
    """
    Folder Features->Shorten Path ( Path , Length )

    Parameters:
    0: (not found) (Global)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression23(Expression):
    """
    Associate Features->Get Current Association ( Extension , Type )

    Parameters:
    0: (not found) (Global)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression24(Expression):
    """
    Associate Features->Get Current Global Association ( Type )

    Parameters:
    0: (not found) (Int)
    1: (not found) (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression25(Expression):
    """
    Get Current User
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


class DefaultObject(HiddenObject):
    def created(self, data):
        # you should probably make your object ready here.
        # data is your property data
        pass

class Yaso(UserExtension):
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
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
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
    }

extension = Yaso()

def get_extension():
    return extension
