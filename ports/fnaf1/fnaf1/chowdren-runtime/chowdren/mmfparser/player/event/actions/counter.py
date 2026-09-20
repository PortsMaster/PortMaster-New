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

class SetCounterValue(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set(value)

class AddCounterValue(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set(instance.objectPlayer.value + value)

class SubtractCounterValue(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set(instance.objectPlayer.value - value)

class SetMinimumValue(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.minimum = value
        instance.objectPlayer.set(instance.objectPlayer.value)

class SetMaximumValue(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.maximum = value
        instance.objectPlayer.set(instance.objectPlayer.value)

class SetCounterColor1(Action):
    def execute(self, instance):
        value = self.get_color(self.get_parameter(0))
        instance.objectPlayer.set_color(color1 = value)

class SetCounterColor2(Action):
    def execute(self, instance):
        value = self.get_color(self.get_parameter(0))
        instance.objectPlayer.set_color(color2 = value)