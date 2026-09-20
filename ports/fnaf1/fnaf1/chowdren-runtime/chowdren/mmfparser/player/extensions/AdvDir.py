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
AdvDir.mfx
Advanced Direction Object - Olle Fredriksson (ollef@hotmail.com)

The advanced version of the Direction Object provides even more
functions that are very useful when creating custom movements, and
doing most movement related work.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

import math

def distance_from(x1, y1, x2, y2):
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
    
def direction_from(x1, y1, x2, y2):
    return (math.atan2(y2 - y1, x2 - x1) * 180.0) / math.pi

# Actions

class Action0(Action):
    """
    Set number of directions

    Parameters:
    0: Enter a direction value (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.directionCount = self.evaluate_expression(
            self.get_parameter(0))

class Action1(Action):
    """
    Get object distances and fixed values

    Parameters:
    0: Object (TIME, Time)
    1: Position (OBJECT, Object)
    """

    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        objectPlayer.distance = distance = []
        objectPlayer.fixed = fixed = []
        objectInfo = self.get_parameter(0).objectInfo
        objects = self.get_instances(objectInfo)
        position = self.get_parameter(1)
        for newInstance in objects:
            self.select_instances([newInstance], objectInfo)
            try:
                x, y, _ = self.get_positions(position)[0]
            except IndexError:
                continue
            distance.append(distance_from(x, y, newInstance.x, newInstance.y))
            fixed.append(id(newInstance))
            objectPlayer.lastX = x
            objectPlayer.lastY = y
        self.select_instances(objects, objectInfo)

class Action2(Action):
    """
    Add object to existing data

    Parameters:
    0: Object (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        objects = self.get_instances(self.get_parameter(0).objectInfo)
        for newInstance in objects:
            distance.append(distance_from(objectPlayer.lastX, 
                objectPlayer.lastY, newInstance.x, newInstance.y))
            fixed.append(id(newInstance))

class Action3(Action):
    """
    Reset object data

    Parameters:
    0:  ((unknown 27000))
    """

    def execute(self, instance):
        instance.objectPlayer.fixed = []
        instance.objectPlayer.distance = []

# Conditions

class Condition0(Condition):
    """
    Compare distance between two points

    Parameters:
    0: First position (SHORT, Short)
    1: Second position (POSITION, Position)
    """

    def check(self, instance):
        try:
            x1, y1, _ = self.get_positions(self.get_parameter(0))[0]
            x2, y2, _ = self.get_positions(self.get_parameter(1))[0]
        except IndexError:
            return
        v = self.evaluate_index(2)
        if distance_from(x1, y1, x2, y2) <= v:
            return True
        return False
        
class Condition1(Condition):
    """
    Compare direction between two points

    Parameters:
    0: First position (SHORT, Short)
    1: Second position (POSITION, Position)
    """

    def check(self, instance):
        try:
            x1, y1, _ = self.get_positions(self.get_parameter(0))[0]
            x2, y2, _ = self.get_positions(self.get_parameter(1))[0]
        except IndexError:
            return
        directionCount = instance.objectPlayer.directionCount
        dir = self.evaluate_index(2)
        offset = self.evaluate_index(3)
        dir = instance.objectPlayer.convert_direction(dir)
        dir2 = instance.objectPlayer.convert_direction(
            direction_from(x1, y1, x2, y2))
        if min(math.fabs(dir - dir2), 
        math.fabs(dir - dir2 - directionCount), 
        math.fabs(dir - dir2 + directionCount)) < offset:
            return True
        return False

# Expressions

class Expression0(Expression):
    """
    Get number of directions

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Distance and direction between two points->Float values (decimals)->Direction between two points ( x1, y1, x2, y2 )

    Parameters:
    0: (not found) (AlterableValue)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        x1 = self.next_argument()
        y1 = self.next_argument()
        x2 = self.next_argument()
        y2 = self.next_argument()
        return instance.objectPlayer.convert_direction(direction_from(
            x1, y1, x2, y2))

class Expression2(Expression):
    """
    Distance and direction between two points->Float values (decimals)->Distance between two points ( x1, y1, x2, y2 )

    Parameters:
    0: (not found) (AlterableValue)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        x1 = self.next_argument()
        y1 = self.next_argument()
        x2 = self.next_argument()
        y2 = self.next_argument()
        return distance_from(x1, y1, x2, y2)

class Expression3(Expression):
    """
    Distance and direction between two points->Long values (no decimals)->Direction between two points ( x1, y1, x2, y2 )

    Parameters:
    0: (not found) (AlterableValue)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        x1 = self.next_argument()
        y1 = self.next_argument()
        x2 = self.next_argument()
        y2 = self.next_argument()
        return int(instance.objectPlayer.convert_direction(direction_from(
            x1, y1, x2, y2)))

class Expression4(Expression):
    """
    Distance and direction between two points->Long values (no decimals)->Distance between two points ( x1, y1, x2, y2 )

    Parameters:
    0: (not found) (AlterableValue)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        x1 = self.next_argument()
        y1 = self.next_argument()
        x2 = self.next_argument()
        y2 = self.next_argument()
        return int(distance_from(x1, y1, x2, y2))

class Expression5(Expression):
    """
    Rotate ( dir, dirtrt, speed )

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        angle = self.next_argument()
        angletgt = self.next_argument()
        rotation = self.next_argument()
        directionCount = instance.objectPlayer.directionCount
        if rotation < 0:
            rotation *= -1
            angletgt += directionCount / 2
        while angletgt < 0:
            angletgt += directionCount
        while angletgt >= directionCount:
            angletgt -= directionCount
        if math.fabs(int(angle - angletgt)) <= rotation:
            angle = angletgt
        if math.fabs(int(angle - angletgt - directionCount)) <= rotation:
            angle = angletgt
        if math.fabs(int(angle - angletgt + directionCount)) <= rotation:
            angle = angletgt
        if angletgt != angle:
            if angle - angletgt >= 0 and angle - angletgt < directionCount / 2:
                angle -= rotation
            if angle - angletgt >= directionCount / 2:
                angle += rotation
            if angle - angletgt <= 0 and angle - angletgt > directionCount / -2:
                angle += rotation
            if angle - angletgt <= directionCount / -2:
                angle -= rotation
        while angle >= directionCount:
            angle -= directionCount
        while angle < 0:
            angle += directionCount
        return angle

class Expression6(Expression):
    """
    Difference between two directions->Absolute (positive only) ( dir1, dir2 )

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        directionCount = instance.objectPlayer.directionCount
        return min(math.fabs(a - b), math.fabs(a - b - directionCount),
            math.fabs(a - b + directionCount))

class Expression7(Expression):
    """
    Difference between two directions->Not absolute ( dir 1, dir2 )

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        directionCount = instance.objectPlayer.directionCount
        v1 = a - b
        v2 = a - b - directionCount
        v3 = a - b + directionCount
        if math.fabs(v1) <= math.fabs(v2) and math.fabs(v1) <= math.fabs(v3):
            return v1
        if math.fabs(v2) <= math.fabs(v1) and math.fabs(v2) <= math.fabs(v3):
            return v2
        if math.fabs(v3) <= math.fabs(v1) and math.fabs(v3) <= math.fabs(v2):
            return v3
        return 0

class Expression8(Expression):
    """
    Stored objects->Get fixed (0 = Closest object, 1 = Second closest, etc)

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = int(self.next_argument())
        fixed = instance.objectPlayer.fixed
        distance = instance.objectPlayer.distance
        if index < 0 or index >= len(fixed):
            index = len(fixed) - 1
        values = [(distance[i], item) for i, item in enumerate(fixed)]
        values.sort()
        return values[index][1]

class Expression9(Expression):
    """
    Stored objects->Get distance

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = int(self.next_argument())
        fixed = instance.objectPlayer.fixed
        distance = instance.objectPlayer.distance
        if index < 0 or index >= len(fixed):
            index = len(fixed) - 1
        values = [(distance[i], item) for i, item in enumerate(fixed)]
        values.sort()
        return values[index][0]

class Expression10(Expression):
    """
    Get movement->Get X movement from a speed and a direction ( dir, speed )

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        dir = self.next_argument()
        speed = self.next_argument()
        directionCount = instance.objectPlayer.directionCount
        dir = (dir * 360) / directionCount
        if dir in (270, 90):
            return 0
        return math.cos(((dir * math.pi * 2) / 360.0) * -1.0) * speed

class Expression11(Expression):
    """
    Get movement->Get Y movement from a speed and a direction ( dir, speed )

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        dir = self.next_argument()
        speed = self.next_argument()
        directionCount = instance.objectPlayer.directionCount
        dir = (dir * 360) / directionCount
        if dir in (180, 0):
            return 0
        return math.sin(((dir * math.pi * 2) / 360.0) * -1.0) * speed

class Expression12(Expression):
    """
    Convert direction to a different base ( dir, newbase )

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        a = self.next_argument()
        b = self.next_argument()
        return float(a * b) / instance.objectPlayer.directionCount

class DefaultObject(HiddenObject):
    directionCount = None
    lastX = lastY = 0
    distance = None
    fixed = None
    def created(self, data):
        data.skipBytes(8)
        self.directionCount = int(data.readString(32))
        self.distance = []
        self.fixed = []
    
    def convert_direction(self, angle):
        angle = ((angle * -1) / 360.0) * self.directionCount
        angle = angle % self.directionCount
        return angle

class AdvDir(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
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
    }

extension = AdvDir()

def get_extension():
    return extension
