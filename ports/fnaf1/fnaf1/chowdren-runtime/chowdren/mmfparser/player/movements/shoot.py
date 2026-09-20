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

class Shoot(MovementPlayer):
    beenIn = False
    firstMove = True

    def created(self):
        self.isShoot = True
        self.maxSpeed = self.movement.shootSpeed
        self.set_speed(self.movement.shootSpeed)
    
    def speed_changed(self):
        self.pixel_per_move = self.get_pixels(self.speed)
    
    def get_move(self):
        return self.pixel_per_move * self.player.multiplier
        
    def move(self):
        move = self.get_move()
        if self.firstMove:
            self.parent.set_position(self.parent.x + self.x_speed * move,
                self.parent.y + self.y_speed * move)
            self.firstMove = False
        else:
            self.move_object(self.x_speed * move, self.y_speed * move)
            if self.detached:
                return
        if self.parent.outside_playfield() and self.beenIn:
            self.parent.destroy()
        elif self.parent.in_playfield():
            self.beenIn = True
    
    def stop(self, collided):
        return
    
    def bounce(self):
        return

__all__ = ['Shoot']