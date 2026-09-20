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
AdvGameBoard.mfx
Advanced Game Board - Andos (http://andos.stiaxies.net)
Copyright 2004 Anders Riggelsen

AGBO makes the creation of board games much easier with its inbuilt
looping and searches for connected bricks.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension
from mmfparser.player.objects.common import ObjectPlayer
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from wrapper import (call_wrapper_a, call_wrapper_c, call_wrapper_e,
    DataContainer)

# Actions

def create_action_wrapper(num):
    class ActionWrapper(Action):
        id = num
        def execute(self, instance):
            parameters = []
            for arg in self.parameters:
                parameters.append(self.evaluate_expression(arg))
            call_wrapper_a(self.id, instance, *parameters)
    
    return ActionWrapper

def create_condition_wrapper(num):
    class ConditionWrapper(Condition):
        id = num
        def check(self, instance):
            parameters = []
            for arg in self.parameters:
                parameters.append(self.evaluate_expression(arg))
            return call_wrapper_c(self.id, instance, *parameters)
    
    return ConditionWrapper

class Action19(Action):
    """
    Import actives for board

    Parameters:
    0: Import actives for board (OBJECT, Object)
    1: Mark all found bricks as used (OBJECT, Object)
    """

    def execute(self, instance):
        instances = self.get_instances(self.get_parameter(0).objectInfo)
        for newInstance in reversed(instances):
            call_wrapper_a(19, instance, id(newInstance))

# Conditions

class Condition0(Condition):
    """
    On found connected bricks

    Parameters:
    0: %o: On found brick ((unknown 26010))
    """

    def check(self, instance):
        return True

class Condition1(Condition):
    """
    On found brick

    Parameters:
    0: %o: On found looped ((unknown 26020))
    """

    def check(self, instance):
        return True

class Condition2(Condition):
    """
    On looped brick (extra looping)

    Parameters:
    0: %o: No connected found ((unknown 26030))
    """

    def check(self, instance):
        return True

class Condition3(Condition):
    """
    No connected found

    Parameters:
    0: %o: Brick at %0, %1 can fall up ((unknown 26050))
    """

    def check(self, instance):
        return True

class Condition8(Condition):
    """
    On Brick moved

    Parameters:
    0: %o: On brick deleted ((unknown 26090))
    """

    def check(self, instance):
        return True

class Condition9(Condition):
    """
    On Brick deleted

    Parameters:
    0: %o: Position %0, %1 is empty ((unknown 26100))
    """

    def check(self, instance):
        return True

# Expressions

class WrapperExpression(Expression):
    id = None
    args = None
    
    def get(self, instance):
        parameters = []
        for _ in xrange(self.args):
            parameters.append(self.next_argument())
        return call_wrapper_e(self.id, instance, *parameters)

class Expression0(WrapperExpression):
    id = 0
    args = 2

class Expression1(WrapperExpression):
    id = 1
    args = 0

class Expression2(WrapperExpression):
    id = 2
    args = 0

class Expression3(WrapperExpression):
    id = 3
    args = 0

class Expression4(WrapperExpression):
    id = 4
    args = 1

class Expression5(WrapperExpression):
    id = 5
    args = 1

class Expression6(WrapperExpression):
    id = 6
    args = 0

class Expression7(WrapperExpression):
    id = 7
    args = 1

class Expression8(WrapperExpression):
    id = 8
    args = 1

class Expression9(WrapperExpression):
    id = 9
    args = 3

class Expression10(WrapperExpression):
    id = 10
    args = 0

class Expression11(WrapperExpression):
    id = 11
    args = 1

class Expression12(WrapperExpression):
    id = 12
    args = 0

class Expression13(WrapperExpression):
    id = 13
    args = 0

class Expression14(WrapperExpression):
    id = 14
    args = 0

class Expression15(WrapperExpression):
    id = 15
    args = 0

class Expression16(WrapperExpression):
    id = 16
    args = 2

class Expression17(WrapperExpression):
    id = 17
    args = 0

class Expression18(WrapperExpression):
    id = 18
    args = 1

class Expression19(WrapperExpression):
    id = 19
    args = 1

class Expression20(WrapperExpression):
    id = 20
    args = 1

class Expression21(WrapperExpression):
    id = 21
    args = 0

class Expression22(WrapperExpression):
    id = 22
    args = 0

class Expression23(WrapperExpression):
    id = 22
    args = 0

class Expression24(WrapperExpression):
    id = 24
    args = 0

class Expression25(WrapperExpression):
    id = 25
    args = 0

class Expression26(WrapperExpression):
    id = 26
    args = 1

class Expression27(WrapperExpression):
    id = 27
    args = 1

class Expression28(WrapperExpression):
    id = 28
    args = 1

class Expression29(WrapperExpression):
    id = 29
    args = 1

class Expression30(WrapperExpression):
    id = 30
    args = 0

class Expression31(WrapperExpression):
    id = 31
    args = 0

class Expression32(WrapperExpression):
    id = 32
    args = 0

class Expression33(WrapperExpression):
    id = 33
    args = 0

class Expression34(WrapperExpression):
    id = 34
    args = 2

class Expression35(WrapperExpression):
    id = 35
    args = 1

class Expression36(WrapperExpression):
    id = 36
    args = 1

class Expression37(WrapperExpression):
    id = 37
    args = 0

class Expression38(WrapperExpression):
    id = 38
    args = 0

class Expression39(WrapperExpression):
    id = 39
    args = 0

class Expression40(WrapperExpression):
    id = 40
    args = 0

class Expression41(WrapperExpression):
    id = 41
    args = 0

class Expression42(WrapperExpression):
    id = 42
    args = 0

class Expression43(WrapperExpression):
    id = 43
    args = 0

class Expression44(WrapperExpression):
    id = 44
    args = 0

class DefaultObject(ObjectPlayer):
    def created(self, data):
        data.skipBytes(8)
        self.data = DataContainer(self, data)
        self.updateEnabled = True
    
    def update(self):
        self.data.update()
    
    def on_detach(self):
        self.data.on_detach()
    
    def generate(self, id):
        condition = AdvGameBoard.conditions[id]
        self.player.eventPlayer.generate_event(condition, self.parent.handle)

class AdvGameBoard(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : create_action_wrapper(0),
        1 : create_action_wrapper(1),
        2 : create_action_wrapper(2),
        3 : create_action_wrapper(3),
        4 : create_action_wrapper(4),
        5 : create_action_wrapper(5),
        6 : create_action_wrapper(6),
        7 : create_action_wrapper(7),
        8 : create_action_wrapper(8),
        9 : create_action_wrapper(9),
        10 : create_action_wrapper(10),
        11 : create_action_wrapper(11),
        12 : create_action_wrapper(12),
        13 : create_action_wrapper(13),
        14 : create_action_wrapper(14),
        15 : create_action_wrapper(15),
        16 : create_action_wrapper(16),
        17 : create_action_wrapper(17),
        18 : create_action_wrapper(18),
        19 : Action19,
        20 : create_action_wrapper(20),
        21 : create_action_wrapper(21),
        22 : create_action_wrapper(22),
        23 : create_action_wrapper(23),
        24 : create_action_wrapper(24),
        25 : create_action_wrapper(25),
        26 : create_action_wrapper(26),
        27 : create_action_wrapper(27),
        28 : create_action_wrapper(28),
        29 : create_action_wrapper(29),
        30 : create_action_wrapper(30),
        31 : create_action_wrapper(31),
        32 : create_action_wrapper(32),
        33 : create_action_wrapper(33),
        34 : create_action_wrapper(34),
        35 : create_action_wrapper(35),
        36 : create_action_wrapper(36),
        37 : create_action_wrapper(37),
        38 : create_action_wrapper(38),
        39 : create_action_wrapper(39),
        40 : create_action_wrapper(40),
        41 : create_action_wrapper(41),
        42 : create_action_wrapper(42),
        43 : create_action_wrapper(43),
        44 : create_action_wrapper(44),
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : create_condition_wrapper(4),
        5 : create_condition_wrapper(5),
        6 : create_condition_wrapper(6),
        7 : create_condition_wrapper(7),
        8 : Condition8,
        9 : Condition9,
        10 : create_condition_wrapper(10),
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
        27 : Expression27,
        28 : Expression28,
        29 : Expression29,
        30 : Expression30,
        31 : Expression31,
        32 : Expression32,
        33 : Expression33,
        34 : Expression34,
        35 : Expression35,
        36 : Expression36,
        37 : Expression37,
        38 : Expression38,
        39 : Expression39,
        40 : Expression40,
        41 : Expression41,
        42 : Expression42,
        43 : Expression43,
        44 : Expression44,
    }

extension = AdvGameBoard()

def get_extension():
    return extension
