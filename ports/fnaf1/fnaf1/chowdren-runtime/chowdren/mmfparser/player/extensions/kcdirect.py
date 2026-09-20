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
kcdirect.mfx
Direction Calculator - Philip Williams (philipwilliams@iname.com)

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

import math

# Actions

class Action0(Action):
    """
    Set the amount to rotate

    Parameters:
    0: Set the amount to rotate (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.angleToTurn = self.evaluate_expression(
            self.get_parameter(0))

class Action1(Action):
    """
    Rotate object toward a direction

    Parameters:
    0: Rotate object toward a direction (EXPRESSION, ExpressionParameter)
    1: Rotate object toward a direction (OBJECT, Object)
    """

    def execute(self, instance):
        dir = self.evaluate_index(0)
        for newInstance in self.get_instances(self.get_parameter(1).objectInfo):
            direction = newInstance.direction
            goalAngle = dir
            goalAngle = goalAngle % 32
            cc = goalAngle - direction
            if cc < 0:
                cc += 32
            cl = direction - goalAngle
            if cl < 0:
                cl += 32
            if cc < cl:
                angle = cc
            else:
                angle = cl
            objectPlayer = newInstance.objectPlayer
            if angle > objectPlayer.angleToTurn:
                angle = objectPlayer.angleToTurn
            if cl < cc:
                angle = -angle
            direction += angle
            if direction >= 32:
                direction -= 32
            if direction <= -1:
                direction += 32
            newInstance.set_direction(direction)

class Action2(Action):
    """
    Rotate object toward a position

    Parameters:
    0: Rotate object toward a position (OBJECT, Object)
    1: Rotate object toward a position (POSITION, Position)
    """

    def execute(self, instance):
        objectInfo = self.get_parameter(0).objectInfo
        allInstances = self.get_instances(objectInfo)
        for newInstance in allInstances:
            self.select_instances([newInstance], objectInfo)
            try:
                x, y, _ = self.get_positions(self.get_parameter(1))[0]
            except IndexError:
                continue
            direction = newInstance.direction
            l1 = x
            l2 = y
            l1 -= newInstance.x
            l2 = newInstance.y
            look_angle = math.atan2(-l2, l1)
            if look_angle < 0.0:
                look_angle = look_angle + 2.0 * math.pi
            goal_angle = int(look_angle * 32.0 / (2.0 * math.pi) + 0.5)
            cc = goal_angle - direction
            if cc < 0:
                cc += 32
            cl = direction - goal_angle
            if cl < 0:
                cl += 32
            if cc < cl:
                angle = cc
            else:
                angle = cl
            objectPlayer = instance.objectPlayer
            if angle > objectPlayer.angleToTurn:
                angle = objectPlayer.angleToTurn
            if cl < cc:
                angle = -angle
            direction += angle
            if direction >= 32:
                direction -= 32
            if direction <= -1:
                direction += 32
            newInstance.set_direction(direction)
        self.select_instances(allInstances, objectInfo)

class Action3(Action):
    """
    Add a directional speed to an object

    Parameters:
    0: Add a directional speed to an object (EXPRESSION, ExpressionParameter)
    1: Add a directional speed to an object (OBJECT, Object)
    """

    def execute(self, instance):
        speed = self.evaluate_index(0)
        for newInstance in self.get_instances(self.get_parameter(1).objectInfo):
            add_speed = speed
            object_speed = newInstance.currentMovement.speed
            direction1 = newInstance.direction
            angle1 = (direction1 * 2 * math.pi / 32)
            objectPlayer = instance.objectPlayer
            angle2 = (objectPlayer.dirToAdd * 2 * math.pi / 32)
            x1 = object_speed * math.cos(angle1)
            y1 = object_speed * math.sin(angle1)
            x2_delta = add_speed * math.cos(angle2)
            y2_delta = add_speed * math.sin(angle2)
            x2 = x1 + x2_delta
            y2 = y1 + y2_delta
            if math.fabs((objectPlayer.dirToAdd - direction1) % 32) != 16:
                look_angle = math.atan2(y2, x2)
                diff_ang = look_angle - angle1
                if diff_ang > math.pi:
                    diff_ang -= 2 * math.pi
                elif diff_ang < -math.pi:
                    diff_ang += 2 * math.pi
                if diff_ang < 0.0:
                    angle1 -= math.pi / 32
                else:
                    angle1 += math.pi / 32
                
                x1 = object_speed * math.cos(angle1)
                y1 = object_speed * math.sin(angle1)
                x2 = x1 + x2_delta
                y2 = y1 + y2_delta
            look_angle = math.atan2(y2, x2)
            if look_angle < 0.0:
                look_angle = look_angle + 2.0 * math.pi
            final_dir = int(look_angle * 32.0 / (2.0 * math.pi) + 0.5)
            if final_dir >= 32:
                final_dir -= 32
            newInstance.set_direction(final_dir)
            final_speed = int(math.sqrt(x2**2 + y2**2) + 0.5)
            if final_speed > 100:
                final_speed = 100
            newInstance.set_speed(final_speed)

class Action4(Action):
    """
    Set the direction to add

    Parameters:
    0: Set the direction to add (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.dirToAdd = self.evaluate_expression(
            self.get_parameter(0)) % 32

# Expressions

class Expression0(Expression):
    """
    Convert an XY to a direction

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        x = self.next_argument()
        y = self.next_argument()
        angle = math.atan2(-y, x)
        if angle < 0.0:
            angle = angle + 2 * math.pi
        return int(angle * 32.0 / (2.0 * math.pi) + 0.5)

class Expression1(Expression):
    """
    Convert an XY to a speed

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        x = self.next_argument()
        y = self.next_argument()
        speed = math.sqrt(x**2 + y**2)
        return int(speed + (-0.5 if speed < 0 else 0.5))

class Expression2(Expression):
    """
    Convert a direction to an X value

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        dir = self.next_argument() % 32
        speed = self.next_argument()
        val = speed * math.cos(dir * 2 * math.pi / 32)
        return int(val + (-0.5 if speed < 0 else 0.5))

class Expression3(Expression):
    """
    Convert a direction to a Y value

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        dir = self.next_argument() % 32
        speed = self.next_argument()
        val = speed * math.sin(dir * 2 * math.pi / 32)
        return int(val + (-0.5 if speed < 0 else 0.5))

class Expression4(Expression):
    """
    Turn one direction toward another

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        direction = self.next_argument()
        goalAngle = self.next_argument()
        goalAngle = goalAngle % 32
        cc = goalAngle - direction
        if cc < 0:
            cc += 32
        cl = direction - goalAngle
        if cl < 0:
            cl += 32
        if cc < cl:
            angle = cc
        else:
            angle = cl
        objectPlayer = newInstance.objectPlayer
        if angle > objectPlayer.angleToTurn:
            angle = objectPlayer.angleToTurn
        if cl < cc:
            angle = -angle
        direction += angle
        if direction >= 32:
            direction -= 32
        if direction <= -1:
            direction += 32
        return direction


class DefaultObject(HiddenObject):
    angleToTurn = 1
    dirToAdd = 16
    def created(self, data):
        pass

class kcdirect(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
    }
    
    conditions = {
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
    }

extension = kcdirect()

def get_extension():
    return extension
