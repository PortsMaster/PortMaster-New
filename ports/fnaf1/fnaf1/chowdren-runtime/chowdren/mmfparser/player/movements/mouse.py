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

from mmfparser.player.movements.common import MovementPlayer
from mmfparser.player.common import direction_from

class Mouse(MovementPlayer):
    useKeys = True
    x1 = y1 = x2 = y2 = None
    movedX = 0
    movedY = 0
    minSpeed = 0
    maxSpeed = 100
    
    def created(self):
        parent = self.parent
        loader = self.movement.loader
        self.x1 = parent.x + loader.x1
        self.y1 = parent.y + loader.y1
        self.x2 = parent.x + loader.x2
        self.y2 = parent.y + loader.y2
        self.player.window.set_mouse_visible(False)
        self.player.window.set_exclusive_mouse(True)
        self.player.mouse.push_handlers(
            on_mouse_motion = self.on_mouse_motion,
            on_mouse_drag = self.on_mouse_motion)
        self.player_handler.use_mouse = True
    
    def on_mouse_motion(self, x, y, dx, dy, *arg, **kw):
        self.movedX += dx
        self.movedY += dy
        
    def on_detach(self):
        self.player.window.set_exclusive_mouse(False)
        self.player.mouse.remove_handlers(self.on_mouse_motion)
        self.player.window.set_mouse_visible(True)
        self.player_handler.use_mouse = False
        
    def move(self, *arg, **kw):
        speed = min(250, (math.fabs(self.movedX) + math.fabs(self.movedY)) * 4)
        self.set_speed(speed)
        if self.movedX == 0 and self.movedY == 0:
            return
        parent = self.parent
        direction = direction_from(0, 0, self.movedX, self.movedY)
        self.set_direction(direction)
        self.move_object(self.movedX, self.movedY)
        x = max(self.x1, min(self.x2, parent.x))
        y = max(self.y1, min(self.y2, parent.y))
        if x != parent.x or y != parent.y:
            parent.set_position(x, y)
        self.movedX = self.movedY = 0

__all__ = ['Mouse']