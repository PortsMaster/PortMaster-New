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
base64.mfx
Base64 object - Jean Villy Edberg (http://www.aquadasoft.com)
Copyright 2007 AquadaSoft

Simple object to encode and decode base64 strings

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    This is a submenu->Trigger condition
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action1(Action):
    """
    Dummy action
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Conditions

class Condition0(Condition):
    """
    Evaluated condition

    Parameters:
    0: First number (EXPRESSION, ExpressionParameter)
    1: Second number (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition1(Condition):
    """
    Triggered condition
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Expressions

import base64

class Expression0(Expression):
    """
    Encode

    Parameters:
    0: String to encode (String)
    Return type: String
    """

    def get(self, instance):
        value = self.next_argument()
        return base64.b64encode(value)

class Expression1(Expression):
    """
    Decode

    Parameters:
    0: String to decode (String)
    Return type: String
    """

    def get(self, instance):
        value = self.next_argument()
        return base64.b64decode(value)

class DefaultObject(HiddenObject):
    def created(self):
        # you should probably make your object ready here.
        # data is your property data
        pass

class base64ext(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
    }

extension = base64ext()

def get_extension():
    return extension
