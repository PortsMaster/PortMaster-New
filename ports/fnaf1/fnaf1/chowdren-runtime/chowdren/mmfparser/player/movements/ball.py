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

from mmfparser.player.common import direction_from
from mmfparser.player.movements.common import MovementPlayer, get_direction
from mmfparser.player.collision import collide_python as collide
import math
import random

REBOND_LIST = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 30, 31, 0, 1, 4, 3, 2,
    1, 0, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 24, 25, 26, 27, 27,
    28, 28, 28, 28, 29, 29, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12,
    16, 17, 18, 19, 19, 20, 20, 20, 20, 21, 21, 22, 23, 24, 25, 28, 27, 26, 25,
    0, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 20, 21,
    22, 22, 23, 24, 24, 24, 24, 25, 26, 27, 28, 29, 30, 8, 7, 6, 5, 4, 8, 9, 10,
    11, 11, 12, 12, 12, 12, 13, 13, 14, 15, 16, 17, 20, 19, 18, 17, 16, 15, 14,
    13, 12, 11, 10, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
    17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 16, 15, 14, 13,
    12, 11, 10, 9, 8, 12, 13, 14, 15, 15, 16, 16, 16, 16, 17, 17, 18, 19, 20,
    21, 24, 23, 22, 21, 20, 19, 18, 17, 16, 17, 18, 19, 20, 21, 22, 23, 24, 23,
    22, 21, 20, 19, 18, 17, 16, 17, 18, 19, 20, 21, 22, 23, 24, 23, 22, 21, 20,
    19, 18, 17, 3, 3, 4, 4, 4, 4, 5, 5, 6, 7, 8, 9, 12, 11, 10, 9, 8, 7, 6, 5,
    4, 3, 2, 1, 0, 31, 30, 29, 28, 0, 1, 2, 0, 0, 1, 1, 2, 3, 4, 5, 8, 7, 6, 5,
    4, 3, 2, 1, 0, 31, 30, 29, 28, 27, 26, 25, 24, 28, 29, 30, 31, 31, 0, 0, 0,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 0, 31, 30, 29, 28, 27, 26, 25, 24,
    25, 26, 27, 28, 29, 30, 31, 0, 31, 30, 29, 28, 27, 25, 25, 24, 25, 26, 27,
    28, 29, 30, 31, 0, 4, 5, 6, 7, 7, 8, 8, 8, 8, 9, 9, 10, 11, 12, 13, 16, 15,
    14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7,
    6, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 16, 15,
    14, 13, 12, 11, 10, 9, 8, 9, 10, 11, 12, 13, 14, 15, 16, 15, 14, 13, 12, 11,
    10, 9, 8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    31]

PLUS_ANGLES_TRY = [-4, 4, -4, 4, -4, 4]
PLUS_ANGLES = [-4, 4, -2, 2, -1, 1]

DIRECTION_MASKS = [0xFFFFFFFC, 0xFFFFFFFE, 0xFFFFFFFF]

class Ball(MovementPlayer):
    pixel_per_move = None
    deceleration = 0
    
    directionMask = 0
    angles = None
    lastBounce = None
    
    oldSpeed = None

    def created(self):
        self.maxSpeed = self.minSpeed = self.oldSpeed = self.movement.loader.speed
        if self.movement.movingAtStart:
            self.set_speed(self.maxSpeed)
        self.set_deceleration(self.movement.loader.deceleration)
        self.set_walk()
        self.angles = self.movement.loader.angles
        self.directionMask = DIRECTION_MASKS[self.angles]

    def set_deceleration(self, value):
        self.decelerationValue = value
        if value != 0:
            self.deceleration = self.get_accelerator(
                self.decelerationValue)
    
    def speed_changed(self):
        self.pixel_per_move = self.get_pixels(self.speed)
    
    def get_move(self):
        return self.pixel_per_move * self.player.multiplier
    
    def stop(self, collision = False):
        self.collision = True
        if self.speed > 0:
            self.oldSpeed = self.speed
        self.set_speed(0)
    
    def on_start(self):
        self.set_speed(self.oldSpeed)
    
    def bounce(self):
        self.collision = True
        loopCount = self.player.eventPlayer.loopCount
        if self.lastBounce == loopCount:
            return
        self.lastBounce = loopCount
        items = self.get_reverse_direction(
            self.player.frame.get_stop_instances(self.parent))
        self.set_direction(items)

    def get_reverse_direction(self, instances):
        parent = self.parent
        x = oldX = parent.x
        y = oldY = parent.y
        x -= 8
        y -= 8
        rebond = 0
        if not self.test_collision(x, y, instances):
            rebond |= 0x01
        x += 16
        if not self.test_collision(x, y, instances):
            rebond |= 0x02
        y += 16
        if not self.test_collision(x, y, instances):
            rebond |= 0x04
        x -= 16
        if not self.test_collision(x, y, instances):
            rebond |= 0x08
        parent.set_position(oldX, oldY)
        value = REBOND_LIST[rebond * 32 + self.direction]
        value &= self.directionMask
        if not self.test_direction(value, instances):
            angles = PLUS_ANGLES_TRY[self.angles * 2 + 1]
            angles2 = angles
            free = False
            while 1:
                value -= angles
                value &= 31
                if self.test_direction(value, instances):
                    free = True
                    break
                value += 2 * angles
                value &= 31
                if self.test_direction(value, instances):
                    free = True
                    break
                value -= angles
                value &= 31
                angles += angles2
                if not (angles <=16):
                    break
            if not free:
                value = random.randrange(32) % self.directionMask
        self.parent.set_position(oldX, oldY)
        return value
            
    def test_collision(self, x, y, instances):
        parent = self.parent
        parent.set_position(x, y)
        objectPlayer = parent.objectPlayer
        if parent.handle in self.player.frame.borderCollisionHandles:
            if parent.is_leaving():
                return False
        for instance in instances:
            if instance is self.parent:
                continue
            if collide(instance.objectPlayer.collision, objectPlayer.collision):
                return False
        return True
    
    def test_direction(self, direction, instances):
        parent = self.parent
        oldX = parent.x
        oldY = parent.y
        x_speed = math.cos(math.radians(direction * 11.25)) * 8
        y_speed = math.sin(math.radians(direction * -11.25)) * 8
        value = self.test_collision(parent.x + x_speed, parent.y + y_speed,
            instances)
        parent.set_position(oldX, oldY)
        return value

    def move(self):
        parent = self.parent
        move = self.get_move()
        x_speed = self.x_speed
        y_speed = self.y_speed
        collidedX, collidedY = self.move_object(x_speed * move, y_speed * move)
        if collidedX or collidedY:
            self.set_speed(0)
        else:
            self.set_speed(self.speed - (self.deceleration * self.player.multiplier)
                )
        self.set_walk()

__all__ = ['Ball']