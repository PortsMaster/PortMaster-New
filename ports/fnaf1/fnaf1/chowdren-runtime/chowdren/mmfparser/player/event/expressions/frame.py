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

from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import make_color_number
from mmfparser.data.chunkloaders.objectinfo import QUICKBACKDROP, BACKDROP
from mmfparser.data.chunkloaders.objects import SOLID_OBSTACLE

class CurrentFrame(Expression):
    def get(self):
        return self.player.frameIndex + 1

class CurrentFrameOld(Expression):
    def get(self):
        return self.player.frameIndex

class FrameWidth(Expression):
    def get(self):
        return self.player.frame.width

class FrameHeight(Expression):
    def get(self):
        return self.player.frame.height
        
class GetVirtualWidth(Expression):
    def get(self):
        return self.player.frame.virtualWidth
        
class GetVirtualHeight(Expression):
    def get(self):
        return self.player.frame.virtualHeight

class FrameBackgroundColor(Expression):
    def get(self):
        r, g, b = self.player.frame.clearValue[:3]
        return make_color_number(r * 255, g * 255, b * 255)

class TotalObjectCount(Expression):
    def get(self):
        return self.player.frame.objectCount

class GetCollisionMask(Expression):
    def get(self):
        x = self.next_argument()
        y = self.next_argument()
        collision = Point(x, y)
        for layer in self.player.frame.layers:
            if layer.ladder_at(x, y):
                return 2
            for instance in layer.obstacles:
                if collide(collision, instance.objectPlayer.collision):
                    return 1
        return 0

class DisplayMode(Expression):
    def get(self):
        return 8

class PixelShaderVersion(Expression):
    def get(self):
        return 0

from mmfparser.player.collision import Point, collide_python as collide