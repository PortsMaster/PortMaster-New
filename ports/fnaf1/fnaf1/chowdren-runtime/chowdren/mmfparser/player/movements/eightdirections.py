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

class EightDirections(MovementPlayer):
    pixel_per_move = None
    useKeys = True
    lastDirection = None
    bouncing = False
    directions = None
    
    def created(self):
        loader = self.movement.loader
        self.maxSpeed = loader.speed
        self.set_deceleration(loader.deceleration)
        self.set_acceleration(loader.acceleration)
        self.directions = loader.directions
        
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
        self.bouncing = True
        self.stop(True)
    
    def on_stop(self):
        self.set_speed(0)
        
    def move(self, up, down, left, right, button1, button2):
        if up and down:
            up = down = False
        if left and right:
            left = right = False
        direction = get_direction(up, down, left, right)
        moving = self.directions & (1 << direction) != 0
        if not any((up, down, left, right)) or self.bouncing or not moving:
            self.set_speed(
                self.speed - (self.deceleration * self.player.multiplier))
            direction = self.lastDirection
        else:
            self.set_speed(min(self.maxSpeed,
                self.speed + (self.acceleration * self.player.multiplier)))
            self.lastDirection = direction
        if direction == None:
            return
        self.set_direction(direction)
        if not self.stopped:
            x_speed = self.x_speed
            y_speed = self.y_speed
            if self.bouncing:
                x_speed = -x_speed
                y_speed = -y_speed
            move = self.get_move()
            collidedX, collidedY = self.move_object(x_speed * move, 
                y_speed * move)
            if (collidedX or collidedY) and not self.bouncing:
                self.set_speed(0)
        if self.stopped and self.bouncing:
            self.bouncing = False

__all__ = ['EightDirections']