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

from mmfparser.player.event.actions.common import Action
from mmfparser.player.collision import (Point, collides_python as collides,
    collide_python as collide)

class SetFrameBackgroundColor(Action):
    def execute(self):
        r, g, b = self.get_color(self.get_parameter(0))
        self.player.frame.set_background_color(r, g, b)

class SetFrameWidth(Action):
    def execute(self):
        value = self.evaluate_index(0)
        self.player.frame.set_size(width = value)

class SetFrameHeight(Action):
    def execute(self):
        value = self.evaluate_index(0)
        self.player.frame.set_size(height = value)

class SetVirtualWidth(Action):
    def execute(self):
        value = self.evaluate_index(0)
        self.player.frame.set_virtual_size(width = value)

class SetVirtualHeight(Action):
    def execute(self):
        value = self.evaluate_index(0)
        self.player.frame.set_virtual_size(height = value)

class DeleteAllCreatedBackdrops(Action):
    def execute(self):
        layer = self.evaluate_index(0) - 1
        for instance in self.player.frame.pastedInstances[:]:
            if instance.layerIndex != layer:
                continue
            instance.destroy()

class DeleteCreatedBackdrops(Action):
    def execute(self):
        layer = self.evaluate_index(0) - 1
        x = self.evaluate_index(1)
        y = self.evaluate_index(2)
        fineDetection = bool(self.evaluate_index(3))
        if fineDetection:
            collision = Point(x, y)
        for instance in self.player.frame.pastedInstances[:]:
            if instance.layerIndex != layer:
                continue
            if fineDetection:
                collided = collide(instance.objectPlayer.collision, collision)
            else:
                collided = collides(x, y, x + 1, y + 1, instance.x1, 
                    instance.y1, instance.x2, instance.y2)
            if collided:
                instance.destroy()