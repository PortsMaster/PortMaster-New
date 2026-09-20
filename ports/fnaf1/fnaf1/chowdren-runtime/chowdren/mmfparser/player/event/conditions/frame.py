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

from mmfparser.player.collision import Point, collide_python as collide
from mmfparser.data.chunkloaders.objectinfo import QUICKBACKDROP, BACKDROP
from mmfparser.data.chunkloaders.objects import SOLID_OBSTACLE
from mmfparser.player.event.conditions.common import Condition

class IsObstacle(Condition):
    def check(self):
        x = self.evaluate_index(0)
        y = self.evaluate_index(1)
        collision = Point(x, y)
        for layer in self.player.frame.layers:
            for instance in layer.obstacles:
                if collide(collision, instance.objectPlayer.collision):
                    return not self.negated
        return self.negated

class IsLadder(Condition):
    def check(self):
        x = self.evaluate_index(0)
        y = self.evaluate_index(1)
        for layer in self.player.frame.layers:
            if layer.ladder_at(x, y):
                return not self.negated
        return self.negated