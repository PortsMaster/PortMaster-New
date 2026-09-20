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

from mmfparser.player.event.actions.common cimport Action
from mmfparser.player.instance cimport Instance
from pyglet import image
from mmfparser.player.common import load_image
from mmfparser.player.sprite import CreatedFrame

cdef class SetAngle(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_angle(value)

cdef class SetScale(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_scale(value, value)

cdef class SetXScale(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_scale(value, None)

cdef class SetYScale(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_scale(None, value)

cdef class StartAnimation(Action):
    cdef void execute_instance(self, Instance instance):
        instance.objectPlayer.start_animation()

cdef class StopAnimation(Action):
    cdef void execute_instance(self, Instance instance):
        instance.objectPlayer.stop_animation()

cdef class ForceFrame(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.force_frame(True, value)

cdef class RestoreFrame(Action):
    cdef void execute_instance(self, Instance instance):
        instance.objectPlayer.force_frame(False)

cdef class ReplaceColor(Action):
    iterateObjects = False
    cdef void execute(self):
        color1 = self.get_color(self.get_parameter(0))
        color2 = self.get_color(self.get_parameter(1))
        self.player.change_active_color(self.loader.objectInfo, color1, 
            color2)
    
cdef inline int make_special_value(int value, int max): 
    if value == 100000:
        return max / 2
    if value == 110000:
        return max - 1
    return value

cdef class LoadActiveFrame(Action):
    iterateObjects = False
    cdef void execute(self):
        filename = self.get_filename(self.get_parameter(0))
        animationIndex = self.get_parameter_value(self.get_parameter(1))
        directionIndex = self.get_direction(self.get_parameter(2)) % 32
        frameIndex = self.evaluate_index(3)
        xHotspot = self.evaluate_index(4)
        yHotspot = self.evaluate_index(5)
        actionX = self.evaluate_index(6)
        actionY = self.evaluate_index(7)
        if len(filename) == 0 or frameIndex < 0:
            return
        try:
            newImage = load_image(filename)
            if newImage.width > 0 and newImage.height > 0:
                xHotspot = make_special_value(xHotspot, newImage.width)
                yHotspot = make_special_value(yHotspot, newImage.height)
                actionX = make_special_value(actionX, newImage.width)
                actionY = make_special_value(actionY, newImage.height)
            frame = CreatedFrame(newImage, xHotspot, yHotspot, actionX, 
                actionY)
            self.player.change_active_frame(self.loader.objectInfo, 
                animationIndex, directionIndex, frameIndex, frame)
        except IOError:
            pass

cdef class PasteActive(Action):
    cdef void execute_instance(self, Instance instance):
        collisionType = self.get_parameter(0).value
        instance.objectPlayer.paste(collisionType)

cdef class AddBackdrop(Action):
    cdef void execute_instance(self, Instance instance):
        collisionType = self.get_parameter(0).value
        instance.objectPlayer.paste(collisionType)