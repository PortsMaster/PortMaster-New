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

class GetAngle(Expression):
    def get(self, instance):
        if instance is None:
            return 0
        return instance.objectPlayer.angle
        
class GetXScale(Expression):
    def get(self, instance):
        if instance is None:
            return 0
        return instance.objectPlayer.scaleX

class GetYScale(Expression):
    def get(self, instance):
        if instance is None:
            return 0
        return instance.objectPlayer.scaleY

class AnimationFrame(Expression):
    def get(self, instance):
        if instance is None:
            return 0
        return instance.objectPlayer.frameIndex

class AnimationNumber(Expression):
    def get(self, instance):
        if instance is None:
            return 0
        return instance.objectPlayer.currentAnimation.getIndex()

class GetColorAt(Expression):
    def get(self, instance):
        x = self.next_argument()
        y = self.next_argument()
        if instance is None:
            return 0
        active = instance.objectPlayer
        image = active.make_image(active.currentFrame)
        offset = (x + y * image.width) * 3
        data = image.get_data('RGB', -image.width * 3)[offset:offset+3]
        r = ord(data[0])
        g = ord(data[1])
        b = ord(data[2])
        return make_color_number(r, g, b)