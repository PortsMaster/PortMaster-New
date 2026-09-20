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
kcplugin.mfx
Plug-in object - ClickTeam (http://www.clickteam.com)

Allows your application to communicate with the Web browser through
the Vitalize! plugin.

Ported to Python by Mathias Kaerlev
"""

import webbrowser

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    &Open URL->in plug-in window (.ccn only)

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action1(Action):
    """
    &Open URL->in current window

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action2(Action):
    """
    &Open URL->in parent window

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action3(Action):
    """
    &Open URL->in top-level window

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action4(Action):
    """
    &Open URL->in a new window

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        url = self.evaluate_index(0)
        print 'opening %r' % url
        webbrowser.open_new(url)

class Action5(Action):
    """
    Display &Status Message

    Parameters:
    0: Display &Status Message (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action6(Action):
    """
    &Open URL->in target window

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    1: Target (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action7(Action):
    """
    &Download->Download file

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action8(Action):
    """
    &Download->Abort file downloading

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action9(Action):
    """
    &Javascript->Reset Parameter List
    """

    def execute(self, instance):
        pass

class Action10(Action):
    """
    &Javascript->Add Integer Parameter

    Parameters:
    0: Add Integer Parameter (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action11(Action):
    """
    &Javascript->Add Float Parameter

    Parameters:
    0: Add Float Parameter (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action12(Action):
    """
    &Javascript->Add String Parameter

    Parameters:
    0: Add String Parameter (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass

class Action13(Action):
    """
    &Javascript->Call Function

    Parameters:
    0: Call Function (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        pass


# Conditions

class Condition0(Condition):
    """
    &Downloading->Is loading?

    Parameters:
    0: Is loading? (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        pass

class Condition1(Condition):
    """
    &Downloading->Is loaded?

    Parameters:
    0: Is loaded? (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        pass

class Condition2(Condition):
    """
    &Downloading->Has download failed?

    Parameters:
    0: Has download failed? (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        pass

class Condition3(Condition):
    """
    &Downloading->Is file in loading list?

    Parameters:
    0: Is file in loading list? (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        pass

class Condition4(Condition):
    """
    &JavaScript->On Error
    """

    def check(self, instance):
        pass


# Expressions

class Expression0(Expression):
    """
    Current URL
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression1(Expression):
    """
    Vitalize! Version->Main version number
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression2(Expression):
    """
    Vitalize! Version->Sub-version number
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression3(Expression):
    """
    Vitalize! Version->Build number
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression4(Expression):
    """
    Browser name
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression5(Expression):
    """
    &Download->Percentage

    Parameters:
    0: Filename (String)
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression6(Expression):
    """
    &Download->Read size

    Parameters:
    0: Filename (String)
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression7(Expression):
    """
    &Download->Total size

    Parameters:
    0: Filename (String)
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression8(Expression):
    """
    &Javascript->Get Integer Result
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression9(Expression):
    """
    &Javascript->Get Float Result
    Return type: Int
    """

    def get(self, instance):
        pass

class Expression10(Expression):
    """
    &Javascript->Get String Result
    Return type: Int
    """

    def get(self, instance):
        pass


class DefaultObject(HiddenObject):
    def created(self, data):
        # you should probably make your object ready here.
        # data is your property data
        pass

class kcplugin(UserExtension):
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
        10 : Action9,
        11 : Action10,
        12 : Action11,
        13 : Action12,
        14 : Action13,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        6 : Expression5,
        7 : Expression6,
        8 : Expression7,
        9 : Expression8,
        10 : Expression9,
        11 : Expression10,
    }

extension = kcplugin()

def get_extension():
    return extension
