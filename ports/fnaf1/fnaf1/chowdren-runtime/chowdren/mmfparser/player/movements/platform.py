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

import math

from mmfparser.player.movements.common import MovementPlayer, get_direction

from mmfparser.data.chunkloaders.objects import (NONE_OBSTACLE,
    FINE_COLLISION, BOX_COLLISION, LADDER_OBSTACLE, PLATFORM_OBSTACLE,
    SOLID_OBSTACLE)

from mmfparser.data.chunkloaders.objectinfo import QUICKBACKDROP, BACKDROP

from mmfparser.player.collision import collide_python as collide

class Platform(MovementPlayer):
    pixel_per_move = None
    useKeys = True
    gravity = 0
    lastDirection = None
    crouching = False
    standing = False
    climbing = False
    checkingPlatform = False
    firstMove = True
    lastInstance = None
    
    def created(self):
        self.maxSpeed = self.movement.loader.speed
        self.set_speed(self.movement.loader.speed)
        self.set_deceleration(self.movement.loader.deceleration)
        self.set_acceleration(self.movement.loader.acceleration)
        self.jumpStrength = self.movement.loader.jumpStrength
        self.set_gravity(self.movement.loader.gravity)
        self.lastDirection = self.direction
        self.set_walk()
    
    def speed_changed(self):
        self.pixel_per_move = self.get_pixels(self.speed)
    
    def get_move(self):
        return self.pixel_per_move * self.player.multiplier
    
    def set_gravity(self, value):
        self.gravityAcceleration = self.get_pixels(value)
    
    def set_acceleration(self, value):
        self.accelerationValue = value
        self.acceleration = self.get_accelerator(value)
    
    def set_deceleration(self, value):
        self.decelerationValue = value
        self.deceleration = self.get_accelerator(value)
    
    def set_above(self, instance):
        parent = self.parent
        set_position = parent.set_position
        parent_collision = parent.objectPlayer.collision
        instance_collision = instance.objectPlayer.collision
        while 1:
            if not collide(parent_collision, instance_collision):
                break
            set_position(parent.x, int(parent.y) - 1)
    
    def instance_collides(self, instance):
        self.lastInstance = None
        if instance.objectType in (BACKDROP, QUICKBACKDROP):
            obstacleType = instance.objectPlayer.obstacleType
            if obstacleType in (PLATFORM_OBSTACLE, SOLID_OBSTACLE):
                parent = self.parent
                if obstacleType == PLATFORM_OBSTACLE:
                    value = False
                else:
                    value = True
                a_y2 = parent.y2
                b_y1 = instance.y1
                foot = (parent.objectPlayer.height * 3) / 8
                if (a_y2 in xrange(b_y1, b_y1 + 6 + foot) and self.gravity >= 0
                and not self.climbing):
                    self.lastInstance = instance
                    return True
                return value
        return True
    
    def stop(self, collision = False):
        if self.lastInstance not in (None, True):
            self.set_above(self.lastInstance)
            self.lastInstance = True
            self.breakMovement = True
            return
        MovementPlayer.stop(self, collision)
        
    def move(self, up, down, left, right, button1, button2):
        self.handle_collisions()
        parent = self.parent
        if self.firstMove:
            if self.test_below(10):
                while 1:
                    if self.test_below(1):
                        break
                    parent.set_position(parent.x, parent.y + 1)
                self.standing = True
            self.firstMove = False
        climbing = self.climbing
        if left and right:
            right = False
        if up and down:
            down = False
        if any((left, right)) or (climbing and (up or down)):
            self.set_speed(min(self.maxSpeed,
                self.speed + self.acceleration * self.player.multiplier))
            if climbing:
                direction = self.lastDirection = get_direction(up, down, left,
                    right)
            else:
                direction = self.lastDirection = get_direction(False, False, 
                    left, right)
        else:
            self.set_speed(
                self.speed - self.deceleration * self.player.multiplier)
            if self.direction != self.lastDirection:
                direction = self.lastDirection = self.direction
            else:
                direction = self.lastDirection
        self.set_direction(direction)
        objectPlayer = parent.objectPlayer
        y2 = parent.y2
        x = parent.x
        ladder_at = parent.layer.ladder_at
        ySpeed = self.y_speed
        if (climbing and not ladder_at(x, y2 - 1) and not 
        ladder_at(parent.x, y2 - 4)):
            if ySpeed < 0 and ladder_at(x, y2):
                ySpeed = 0
            else:
                self.climbing = climbing = False
                self.set_fall()
        elif (not climbing and self.gravity >= 0 and
             (up or down or not self.standing)):
                value = 0
                if up:
                    value = -4
                elif down:
                    value = 4
                if ladder_at(x, y2 + value):
                    self.climbing = climbing = True
                    self.gravity = 0
                    self.set_climb()
        move = self.get_move()
        platformUnder = False
        if climbing:
            addY = ySpeed * move
        else:
            self.gravity = min(250, 
                self.gravity + self.gravityAcceleration * 
                self.player.multiplier)
            self.firstMove = True
            if self.gravity >= 0 and self.standing and self.test_below(10):
                platformUnder = True
                addY = 0
            else:
                addY = self.get_pixels(self.gravity) * self.player.multiplier
            self.firstMove = False
        self.checkingPlatform = True
        collidedX, collidedY = self.move_object(self.x_speed * move, 
            addY)
        if self.lastInstance is True:
            self.lastInstance = None
            collidedX = False
            collidedY = True
        self.checkingPlatform = False
        if collidedX:
            self.set_speed(0)
        if platformUnder:
            self.firstMove = True
            for _ in xrange(10):
                if self.test_below(1):
                    break
                parent.set_position(parent.x, parent.y + 1)
            else:
                parent.set_position(parent.x, parent.y - 10)
                platformUnder = False
            self.firstMove = False
        if not platformUnder:
            self.standing = not self.climbing and self.gravity >= 0 and collidedY
        if self.standing:
            self.gravity = 0
            if down and not self.crouching:
                self.crouching = True
                self.set_crouch()
            elif not down and self.crouching:
                self.crouching = False
                self.set_uncrouch()
            elif not self.crouching:
                self.set_walk()
        elif not self.climbing and self.gravity > 0:
            self.set_fall()
        if not self.crouching and (self.standing or self.climbing) and self.is_down_index(4):
            self.climbing = False
            self.gravity = -self.jumpStrength
            self.set_jump()

__all__ = ['Platform']
