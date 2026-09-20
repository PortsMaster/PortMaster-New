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

from mmfparser.player.movements.common import MovementPlayer

ANGLE_MASK = [
    0xFFFFFFF8,
    0xFFFFFFFC,
    0xFFFFFFFE,
    0xFFFFFFFF
]

def get_limited_direction(direction, angles):
    return direction & ANGLE_MASK[angles]

class Race(MovementPlayer):
    useKeys = True
    rotationSpeed = None
    rotationCounter = 0
    bouncing = False
    reverseEnabled = False
    reversing = False
    lastControls = (False, False)
    currentAngle = None
    moving = False
    
    def created(self):
        loader = self.movement.loader
        self.maxSpeed = loader.speed
        self.set_deceleration(loader.deceleration)
        self.set_acceleration(loader.acceleration)
        self.rotationSpeed = loader.rotationSpeed
        self.reverseEnabled = loader.reverseEnabled
        self.angles = loader.angles
        self.currentAngle = self.direction

    def set_acceleration(self, value):
        self.accelerationValue = value
        self.acceleration = self.get_accelerator(value)
    
    def set_deceleration(self, value):
        self.decelerationValue = value
        self.deceleration = self.get_accelerator(value)
        
    def speed_changed(self):
        self.pixel_per_move = self.get_pixels(self.speed)
        
    def get_move(self):
        return self.pixel_per_move * self.player.multiplier
        
    def bounce(self):
        self.reversing = False
        self.bouncing = True
        self.stop(True)
    
    def on_stop(self):
        self.set_speed(0)
    
    def direction_changed(self):
        newDirection = get_limited_direction(self.direction, self.angles)
        if newDirection == self.direction:
            return
        self.set_direction(newDirection)
        if not self.moving:
            self.currentAngle = self.direction
        
    def move(self, up, down, left, right, button1, button2):
        self.moving = True
        if up and down:
            up = down = False
        if left and right:
            left = right = False
        accel = 0
        if self.reversing:
            if up:
                accel = 1
            if down:
                accel = 2
        else:
            if up:
                accel = 2
            if down:
                accel = 1
        if accel == 1 or self.bouncing:
            if not self.bouncing and self.reverseEnabled and self.speed == 0 and not any(self.lastControls):
                self.reversing ^= True
                self.set_speed(min(self.maxSpeed,
                    self.speed + (self.acceleration * self.player.multiplier)))
            else:
                self.set_speed(
                    self.speed - (self.deceleration * self.player.multiplier))
        elif accel == 2:
            self.set_speed(min(self.maxSpeed,
                self.speed + (self.acceleration * self.player.multiplier)))
        add = 0
        if right:
            add = -1
        elif left:
            add = 1
        direction = self.currentAngle or self.direction
        if add != 0:
            self.rotationCounter += self.rotationSpeed * self.player.multiplier
            while self.rotationCounter > 100:
                self.rotationCounter -= 100
                direction = (direction + add) % 32
            self.currentAngle = direction
            self.set_direction(direction)
        if not self.stopped:
            x_speed = self.x_speed
            y_speed = self.y_speed
            if self.bouncing or self.reversing:
                x_speed = -x_speed
                y_speed = -y_speed
            move = self.get_move()
            collidedX, collidedY = self.move_object(x_speed * move, 
                y_speed * move)
            if (collidedX or collidedY) and not self.bouncing:
                self.set_speed(0)
        if self.stopped and self.bouncing:
            self.bouncing = False
        self.lastControls = (up, down)
        self.moving = False

__all__ = ['Race']