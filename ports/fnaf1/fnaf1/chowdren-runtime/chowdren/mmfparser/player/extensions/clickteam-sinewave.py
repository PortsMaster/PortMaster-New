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

STOP_ON_END = 0
RESET_ON_END = 1
BOUNCE_ON_END = 2
REVERSE_ON_END = 3

class SinewaveData(object):
    def __init__(self, reader):
        reader.seek(0)
        reader.skipBytes(1)
        self.flags = reader.readInt(True)
        self.stopped = self.flags == 0
        self.speed = reader.readInt()
        self.finalX = reader.readInt()
        self.finalY = reader.readInt()
        self.amp = reader.readInt()
        self.angVel = reader.readInt()
        self.startAngle = reader.readInt()
        self.onEnd = reader.readInt()

def direction_from(x1, y1, x2, y2):
    return math.atan2(y2 - y1, x2 - x1)

class SinewaveMovement(MovementPlayer):
    stopped = False
    speed = 0
    dx = dy = 0
    cx = cy = 0
    x = None
    y = None
    lastX = lastY = None
    
    def created(self):
        reader = self.movement.loader.data
        parent = self.parent
        data = self.data = SinewaveData(reader)
        self.speed = data.speed
        self.angVel = math.radians(data.angVel) / 50.0
        self.currentAngle = math.radians(data.startAngle)
        self.x = self.startX = self.lastX = parent.x
        self.y = self.startY = self.lastY = parent.y

        if data.speed != 0:
            angle = self.angle = direction_from(self.x, self.y, data.finalX, 
                data.finalY)
            self.cx = math.cos(angle + math.pi * 0.5)
            self.cy = math.sin(angle + math.pi * 0.5)
            dx = math.cos(angle) * (data.speed / 50.0)
            dy = math.sin(angle) * (data.speed / 50.0)
            
            if math.fabs(dx) > 0.0001:
                steps = math.fabs((data.finalX - self.x) / dx)
            elif math.fabs(dy) > 0.0001:
                steps = math.fabs((data.finalY - self.y) / dy)
            else:
                steps = 0.0
        else:
            dx = 0
            dy = 0
            steps = 0

        self.dx = dx
        self.dy = dy
        self.steps = steps
        self.set_speed(data.speed)

    def move(self):
        parent = self.parent
        if parent.x != self.lastX:
            self.x -= self.lastX - parent.x
        if parent.y != self.lastY:
            self.y -= self.lastY - parent.y
        if self.speed != 0 and not self.stopped:
            if self.steps > 0.0:
                if self.currentAngle < 0:
                    self.currentAngle += 2 * math.pi
                elif self.currentAngle >= 2 * math.pi:
                    self.currentAngle -= 2 * math.pi
                
                angVel = self.angVel * self.player.multiplier
                dx = self.dx * self.player.multiplier
                dy = self.dy * self.player.multiplier
                
                if self.steps > 1.0:
                    self.x += dx
                    self.y += dy
                    self.currentAngle -= angVel
                    self.steps -= self.player.multiplier
                    if self.steps < 0.1:
                        self.steps = 0.1
                else:
                    self.x += self.steps * dx
                    self.y += self.steps * dy
                    self.currentAngle -= self.steps * angVel
                    self.steps -= self.player.multiplier
                    if self.steps < 0.1:
                        self.steps = 0.1
                    onEnd = self.data.onEnd
                    if onEnd == STOP_ON_END:
                        self.do_move()
                        self.stopped = True
                    elif onEnd == RESET_ON_END:
                        self.reset()
                    elif onEnd == BOUNCE_ON_END:
                        self.bounce()
                    elif onEnd == REVERSE_ON_END:
                        self.reverse()
                    return
                self.do_move()
                return
    
    def do_move(self):
        parent = self.parent
        amp = self.data.amp * math.sin(self.currentAngle)
        self.move_object((self.x + self.cx * amp) - parent.x,
            (self.y + self.cy * amp) - parent.y)
        self.lastX = parent.x
        self.lastY = parent.y
    
    def reset(self):
        parent = self.parent
        parent.set_position(self.startX, self.startY)
        self.lastX = parent.x
        self.lastY = parent.y
        self.x = self.startX
        self.y = self.startY
        data = self.data
        self.currentAngle = math.radians(data.startAngle)
        if data.speed != 0:
            angle = self.angle = direction_from(self.x, self.y, data.finalX, 
                data.finalY)
            self.cx = math.cos(angle + math.pi * 0.5)
            self.cy = math.sin(angle + math.pi * 0.5)
            dx = math.cos(angle) * (data.speed / 50.0)
            dy = math.sin(angle) * (data.speed / 50.0)
            
            if math.fabs(dx) > 0.0001:
                steps = math.fabs((data.finalX - self.x) / dx)
            elif math.fabs(dy) > 0.0001:
                steps = math.fabs((data.finalY - self.y) / dy)
            else:
                steps = 0.0
        else:
            dx = 0
            dy = 0
            steps = 0

        self.dx = dx
        self.dy = dy
        self.steps = steps
    
    def bounce(self):
        parent = self.parent
        self.do_move()
        tmpX = self.data.finalX
        tmpY = self.data.finalY
        self.data.finalX = self.startX
        self.data.finalY = self.startY
        self.startX = tmpX
        self.startY = tmpY
        self.angle += math.pi
        if self.speed != 0:
            self.dx *= -1
            self.dy *= -1
            if math.fabs(self.dx) > 0.0001:
                steps = math.fabs((self.data.finalX - self.x) / self.dx)
            elif math.fabs(self.dy) > 0.0001:
                steps = math.fabs((self.data.finalY - self.y) / self.dy)
            else:
                steps = 0
        else:
            self.dx = 0
            self.dy = 0
            steps = 0
        self.steps = steps
    
    def reverse(self):
        parent = self.parent
        self.do_move()
        tmpX = self.data.finalX
        tmpY = self.data.finalY
        self.data.finalX = self.startX
        self.data.finalY = self.startY
        self.startX = tmpX
        self.startY = tmpY
        self.angVel *= -1
        self.angle += math.pi
        if self.speed != 0:
            self.dx *= -1
            self.dy *= -1
            if math.fabs(self.dx) > 0.0001:
                steps = math.fabs((self.data.finalX - self.x) / self.dx)
            elif math.fabs(self.dy) > 0.0001:
                steps = math.fabs((self.data.finalY - self.y) / self.dy)
            else:
                steps = 0
        else:
            self.dx = 0
            self.dy = 0
            steps = 0

def get_movement():
    return SinewaveMovement