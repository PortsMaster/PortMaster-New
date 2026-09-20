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
Platform.mfx
Platform Movement object - ClickTeam (http://www.clickteam.com)

A powerful alternative to MMF's built-in platform movement. Easy to
use and provides you with everything you need to create functional,
flexible, custom platform games.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class OverlapsObstacle(Action):
    """
    Collisions->Object does overlap with an obstacle

    Parameters:
    0: Selected object overlaps a jump through platform ((unknown 25010))
    """

    def execute(self, instance):
        instance.objectPlayer.obstacle_collision = True

class OverlapsPlatform(Action):
    """
    Collisions->Object does overlap with a jump through platform

    Parameters:
    0: Set object to %0 ((unknown 25020))
    """

    def execute(self, instance):
        instance.objectPlayer.platform_collision = True

class SetObject(Action):
    """
    Set object

    Parameters:
    0: Object (OBJECT, Object)
    1: User is holding right input key (OBJECT, Object)
    """

    def execute(self, instance):
        try:
            selected, = self.get_instances(self.get_parameter(0).objectInfo)
        except ValueError:
            return
        instance.objectPlayer.set_object(selected)

class SetRight(Action):
    """
    On user input->User is holding right input key

    Parameters:
    0: User is holding left input key ((unknown 25040))
    """

    def execute(self, instance):
        instance.objectPlayer.right = True

class SetLeft(Action):
    """
    On user input->User is holding left input key

    Parameters:
    0: Jump ((unknown 25050))
    """

    def execute(self, instance):
        instance.objectPlayer.left = True


class Jump(Action):
    """
    On user input->Jump

    Parameters:
    0: Set X velocity to %0 ((unknown 25060))
    """

    def execute(self, instance):
        instance.objectPlayer.yVelocity = 0 - instance.objectPlayer.jumpStrength

class SetXVelocity(Action):
    """
    Variables->Set X velocity

    Parameters:
    0: X velocity (OBJECT, Object)
    1: Set Y velocity to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.xVelocity = self.evaluate_expression(
            self.get_parameter(0))

class SetYVelocity(Action):
    """
    Variables->Set Y velocity

    Parameters:
    0: Y velocity (OBJECT, Object)
    1: Set maximum X velocity to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.yVelocity = self.evaluate_expression(
            self.get_parameter(0))

class SetMaximumXVelocity(Action):
    """
    Variables->Set maximum X velocity

    Parameters:
    0: Maximum X velocity (OBJECT, Object)
    1: Set maximum Y velocity to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.maxXVelocity = self.evaluate_expression(
            self.get_parameter(0))

class SetMaximumYVelocity(Action):
    """
    Variables->Set maximum Y velocity

    Parameters:
    0: Maximum Y velocity (OBJECT, Object)
    1: Set X acceleration to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.maxYVelocity = self.evaluate_expression(
            self.get_parameter(0))


class SetXAcceleration(Action):
    """
    Variables->Set X acceleration

    Parameters:
    0: X acceleration (OBJECT, Object)
    1: Set X deceleration to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.xAccel = self.evaluate_expression(
            self.get_parameter(0))


class SetXDeceleration(Action):
    """
    Variables->Set X deceleration

    Parameters:
    0: X deceleration (OBJECT, Object)
    1: Set gravity to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.xDecel = self.evaluate_expression(
            self.get_parameter(0))


class SetGravity(Action):
    """
    Variables->Set gravity

    Parameters:
    0: Gravity (OBJECT, Object)
    1: Set jump strength to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.gravity = self.evaluate_expression(
            self.get_parameter(0))


class SetJumpStrength(Action):
    """
    Variables->Set jump strength

    Parameters:
    0: Jump strength (OBJECT, Object)
    1: Set jump hold height to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.jumpStrength = self.evaluate_expression(
            self.get_parameter(0))


class SetJumpHoldHeight(Action):
    """
    Variables->Set jump hold height

    Parameters:
    0: Jump strength (OBJECT, Object)
    1: Set maximum step up to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.jumpHoldHeight = self.evaluate_expression(
            self.get_parameter(0))


class SetMaximumStepUp(Action):
    """
    Variables->Set maximum step up (in whole pixels)

    Parameters:
    0: Maximum step up (in pixels) (OBJECT, Object)
    1: User is holding jump in the air (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.stepUp = self.evaluate_expression(
            self.get_parameter(0))

class JumpInAir(Action):
    """
    On user input->User is holding jump in the air

    Parameters:
    0: Pause movement ((unknown 25170))
    """

    def execute(self, instance):
        instance.objectPlayer.yVelocity -= instance.objectPlayer.jumpHoldHeight

class PauseMovement(Action):
    """
    Pause movement

    Parameters:
    0: Unpause movement ((unknown 25180))
    """

    def execute(self, instance):
        instance.objectPlayer.paused = True


class StartMovement(Action):
    """
    Unpause movement

    Parameters:
    0: Set downhill slope correction to %0 ((unknown 25190))
    """

    def execute(self, instance):
        instance.objectPlayer.paused = False


class SetSlopeCorrection(Action):
    """
    Variables->Set downhill slope correction (in whole pixels)

    Parameters:
    0: Downhill slope correction (in pixels) (OBJECT, Object)
    1: Set additional X velocity to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.slopeCorrection = self.evaluate_expression(
            self.get_parameter(0))


class SetAdditionalXVelocity(Action):
    """
    Variables->Set additional X velocity

    Parameters:
    0: Additional X velocity (OBJECT, Object)
    1: Set additional Y velocity to %0 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.addXVelocity = self.evaluate_expression(
            self.get_parameter(0))


class SetAdditionalYVelocity(Action):
    """
    Variables->Set additional Y velocity

    Parameters:
    0: Additional Y velocity (OBJECT, Object)
    1: Set additional Y velocity (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.addYVelocity = self.evaluate_expression(
            self.get_parameter(0))

# Conditions

class ObstacleTest(Condition):
    """
    Collision testing (top of the event)->Test for obstacle overlap

    Parameters:
    0: %o: Test for jump through platform overlap ((unknown 26010))
    """
    iterateObjects = False
    instance = None
    i = 0
    
    def created(self):
        self.add_handlers(
            test_obstacle = self.on_handle)
    
    def on_handle(self, instance):
        self.instance = instance
        self.generate()

    def check(self):
        if self.instance not in self.get_instances():
            return False
        self.select_instances([self.instance])
        self.instance = None
        return True

class PlatformTest(Condition):
    """
    Collision testing (top of the event)->Test for jump through platform overlap

    Parameters:
    0: %o: Object is standing on ground ((unknown 26020))
    """

    iterateObjects = False
    instance = None
    
    def created(self):
        self.add_handlers(
            test_platform = self.on_handle)
    
    def on_handle(self, instance):
        self.instance = instance
        self.generate()

    def check(self):
        if self.instance not in self.get_instances():
            return False
        self.select_instances([self.instance])
        self.instance = None
        return True

class ObjectStanding(Condition):
    """
    Object states->Object is standing on ground

    Parameters:
    0: %o: Object is jumping ((unknown 26030))
    """

    def check(self, instance):
        return instance.objectPlayer.onGround

class ObjectJumping(Condition):
    """
    Object states->Object is jumping

    Parameters:
    0: %o: Object is falling ((unknown 26040))
    """

    def check(self, instance):
        return (not instance.objectPlayer.onGround and 
                instance.objectPlayer.yVelocity <= 0)

class ObjectFalling(Condition):
    """
    Object states->Object is falling

    Parameters:
    0: %o: Movement is paused ((unknown 26050))
    """

    def check(self, instance):
        return (not instance.objectPlayer.onGround and 
                instance.objectPlayer.yVelocity > 0)

class MovementPaused(Condition):
    """
    Movement is paused

    Parameters:
    0: %o: Object is moving ((unknown 26060))
    """

    def check(self, instance):
        return instance.objectPlayer.paused

class ObjectMoving(Condition):
    """
    Object states->Object is moving
    """

    def check(self, instance):
        return math.fabs(instance.objectPlayer.xVelocity) > 0

# Expressions

class XVelocity(Expression):
    """
    Get X velocity

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.xVelocity

class YVelocity(Expression):
    """
    Get Y velocity

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.yVelocity

class MaxXVelocity(Expression):
    """
    Get maximum X velocity

    Parameters:
    0: (not found) ((unknown 27030))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.maxXVelocity

class MaxYVelocity(Expression):
    """
    Get maximum Y velocity

    Parameters:
    0: (not found) ((unknown 27040))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.maxYVelocity

class XAcceleration(Expression):
    """
    Get X acceleration

    Parameters:
    0: (not found) ((unknown 27050))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.xAccel

class XDeceleration(Expression):
    """
    Get X deceleration

    Parameters:
    0: (not found) ((unknown 27060))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.xDecel

class Gravity(Expression):
    """
    Get gravity

    Parameters:
    0: (not found) ((unknown 27070))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.gravity

class JumpStrength(Expression):
    """
    Get jump strength

    Parameters:
    0: (not found) ((unknown 27080))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.jumpStrength

class JumpHoldHeight(Expression):
    """
    Get jump hold height

    Parameters:
    0: (not found) ((unknown 27090))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.jumpHoldHeight

class MaxStepUp(Expression):
    """
    Get maximum step up (in whole pixels)

    Parameters:
    0: (not found) ((unknown 27100))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.stepUp

class SlopeCorrection(Expression):
    """
    Get downhill slope correction (in whole pixels)

    Parameters:
    0: (not found) ((unknown 27110))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.slopeCorrection

class AdditionalXVelocity(Expression):
    """
    Get additional X velocity

    Parameters:
    0: (not found) ((unknown 27120))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.addXVelocity

class AdditionalYVelocity(Expression):
    """
    Get additional Y velocity
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.addYVelocity

import math

def fix_string(data):
    for i, c in enumerate(data):
        if ord(c) < 10:
            return int(data[:i])
    return int(data)

def read_value(reader):
    data = reader.readString(16)
    for i, c in enumerate(data):
        if ord(c) < 10:
            return int(data[:i])
    return int(data)

class DefaultObject(HiddenObject):
    maxXVelocity = None
    maxYVelocity = None
    xAccel = None
    xDecel = None
    gravity = None
    jumpStrength = None
    jumpHoldHeight = None
    stepUp = None
    slopeCorrection = None
    jumpThrough = None
    throughCollisionTop = None
    # set through action
    addXVelocity = 0
    addYVelocity = 0
    
    xMoveCount = 0
    yMoveCount = 0

    instance = None
    paused = False
    xVelocity = 0
    yVelocity = 0
    left = False
    right = False
    
    # event stuff
    obstacle_collision = False
    platform_collision = False
    onGround = False
    
    def created(self, data):
        data.skipBytes(8)
        self.maxXVelocity = read_value(data)
        self.maxYVelocity = read_value(data)
        self.xAccel = read_value(data)
        self.xDecel = read_value(data)
        self.gravity = read_value(data)
        self.jumpStrength = read_value(data)
        self.jumpHoldHeight = read_value(data)
        self.stepUp = read_value(data)
        self.slopeCorrection = read_value(data)
        self.throughCollisionTop = data.readByte() == 1
        self.jumpThrough = data.readByte() == 1
        self.updateEnabled = True
    
    def set_object(self, instance):
        self.instance = instance
    
    def update(self):
        instance = self.instance
        
        left = self.left
        right = self.right
        self.left = self.right = False
        
        if not self.paused and instance is not None and not instance.destroyed:
            if right and not left:
                self.xVelocity += self.xAccel
            if left and not right:
                self.xVelocity -= self.xAccel
            if self.xVelocity != 0 and ((not left and not right) or 
                                        (left and right)):
                self.xVelocity -= (self.xVelocity / math.fabs(self.xVelocity
                    ) * self.xDecel)
                if self.xVelocity <= self.xDecel and self.xVelocity >= 0 - self.xDecel:
                    self.xVelocity = 0

            self.xVelocity = min(max(self.xVelocity, 0 - self.maxXVelocity),
                self.maxXVelocity)
            self.yVelocity = min(max(self.yVelocity + self.gravity, 0 - self.maxYVelocity),
                self.maxYVelocity)
            xVelocity = self.xVelocity + self.addXVelocity
            yVelocity = self.yVelocity + self.addYVelocity
            self.xMoveCount += math.fabs(xVelocity)
            self.yMoveCount += math.fabs(yVelocity)
            
            while self.xMoveCount > 100:
                if not self.overlaps_obstacle():
                    instance.set_position(instance.x + xVelocity / math.fabs(
                        xVelocity), instance.y)
                if self.overlaps_obstacle():
                    for i in xrange(self.stepUp):
                        instance.set_position(instance.x, instance.y - 1)
                        if not self.overlaps_obstacle():
                            break
                    if self.overlaps_obstacle():
                        instance.set_position(
                            instance.x - xVelocity / math.fabs(xVelocity),
                            instance.y + self.stepUp)
                        self.xVelocity = self.xMoveCount = 0
                self.xMoveCount -= 100
            
            while self.yMoveCount > 100:
                if not self.overlaps_obstacle():
                    instance.set_position(instance.x, 
                        instance.y + yVelocity / math.fabs(yVelocity))
                    self.onGround = False
                if self.overlaps_obstacle():
                    instance.set_position(instance.x,
                        instance.y - yVelocity / math.fabs(yVelocity))
                    if yVelocity > 0:
                        self.onGround = True
                    self.yVelocity = self.yMoveCount = 0
                if self.overlaps_platform() and yVelocity > 0:
                    if self.throughCollisionTop:
                        instance.set_position(instance.x, instance.y - 1)
                        if not self.overlaps_platform():
                            instance.set_position(instance.x,
                                instance.y - yVelocity / math.fabs(yVelocity))
                            self.yVelocity = self.yMoveCount = 0
                            self.onGround = True
                        instance.set_position(instance.x, instance.y + 1)
                    else:
                        instance.set_position(instance.x,
                            instance.y - yVelocity / math.fabs(yVelocity))
                        self.yVelocity = self.yMoveCount = 0
                        self.onGround = True
                self.yMoveCount -= 100
            if self.slopeCorrection > 0 and yVelocity >= 0:
                tmp = False
                for i in xrange(self.slopeCorrection):
                    instance.set_position(instance.x,
                        instance.y + 1)
                    if self.overlaps_obstacle():
                        instance.set_position(instance.x,
                            instance.y - 1)
                        self.onGround = True
                        tmp = True
                        break
                if tmp == False:
                    instance.set_position(instance.x,
                        instance.y - self.slopeCorrection)

    def overlaps_obstacle(self):
        self.obstacle_collision = False
        self.fire_handler('test_obstacle')
        return self.obstacle_collision
        
    def overlaps_platform(self):
        if not self.jumpThrough:
            return False
        self.platform_collision = False
        self.fire_handler('test_platform')
        return self.platform_collision

class Platform(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : OverlapsObstacle,
        1 : OverlapsPlatform,
        2 : SetObject,
        3 : SetRight,
        4 : SetLeft,
        5 : Jump,
        6 : SetXVelocity,
        7 : SetYVelocity,
        8 : SetMaximumXVelocity,
        9 : SetMaximumYVelocity,
        10 : SetXAcceleration,
        11 : SetXDeceleration,
        12 : SetGravity,
        13 : SetJumpStrength,
        14 : SetJumpHoldHeight,
        15 : SetMaximumStepUp,
        16 : JumpInAir,
        17 : PauseMovement,
        18 : StartMovement,
        19 : SetSlopeCorrection,
        20 : SetAdditionalXVelocity,
        21 : SetAdditionalYVelocity,
    }
    
    conditions = {
        0 : ObstacleTest,
        1 : PlatformTest,
        2 : ObjectStanding,
        3 : ObjectJumping,
        4 : ObjectFalling,
        5 : MovementPaused,
        6 : ObjectMoving,
    }
    
    expressions = {
        0 : XVelocity,
        1 : YVelocity,
        2 : MaxXVelocity,
        3 : MaxYVelocity,
        4 : XAcceleration,
        5 : XDeceleration,
        6 : Gravity,
        7 : JumpStrength,
        8 : JumpHoldHeight,
        9 : MaxStepUp,
        10 : SlopeCorrection,
        11 : AdditionalXVelocity,
        12 : AdditionalYVelocity,
    }

extension = Platform()

def get_extension():
    return extension
