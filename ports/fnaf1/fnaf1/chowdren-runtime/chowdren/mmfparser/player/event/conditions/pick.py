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

import random
from mmfparser.data.chunkloaders.objectinfo import ACTIVE
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.collision import collide_line

class PickAlterableValue(Condition):
    def check(self):
        instances = self.get_frame_instances()
        selectedInstances = []
        for instance in instances[:]:
            if instance.alterables is None:
                instances.remove(instance)
                continue
            self.select_instances([instance], instance.handle)
            index = self.get_alterable_index(self.get_parameter(0))
            value = self.evaluate_index(1)
            if self.compare(instance.alterables.get_value(index), value):
                selectedInstances.append(instance)
        self.select_frame_instances(selectedInstances, instances)
        return len(selectedInstances) > 0

class PickFlagOn(Condition):
    def check(self):
        instances = self.get_frame_instances()
        selectedInstances = []
        for instance in instances:
            if instance.alterables is None:
                continue
            self.select_instances([instance], instance.handle)
            index = self.evaluate_index(0)
            if instance.alterables.flags[index] == True:
                selectedInstances.append(instance)
        self.select_frame_instances(selectedInstances, instances)
        return len(selectedInstances) > 0

class PickFlagOff(Condition):
    def check(self):
        instances = self.get_frame_instances()
        selectedInstances = []
        for instance in instances:
            if instance.alterables is None:
                continue
            self.select_instances([instance], instance.handle)
            index = self.evaluate_index(0)
            if instance.alterables.flags[index] == False:
                selectedInstances.append(instance)
        self.select_frame_instances(selectedInstances, instances)
        return len(selectedInstances) > 0

class CompareObjectCount(Condition):
    def check(self):
        value = self.evaluate_index(0)
        return self.compare(self.player.frame.objectCount, value)

class NoAllObjectsInZone(Condition):
    x1 = None
    y1 = None
    x2 = None
    y2 = None
    def created(self):
        zone = self.get_parameter(0)
        self.x1 = zone.x1
        self.y1 = zone.y1
        self.x2 = zone.x2
        self.y2 = zone.y2

    def check(self):
        count = len([instance for instance in self.get_frame_instances()
            if instance.in_zone(self.x1, self.y1, self.x2, self.y2)])
        return count == 0

class AllObjectsInZone(Condition):
    x1 = None
    y1 = None
    x2 = None
    y2 = None
    def created(self):
        zone = self.get_parameter(0)
        self.x1 = zone.x1
        self.y1 = zone.y1
        self.x2 = zone.x2
        self.y2 = zone.y2

    def check(self):
        value = self.evaluate_index(1)
        count = len([instance for instance in self.get_frame_instances()
            if instance.in_zone(self.x1, self.y1, self.x2, self.y2)])
        return self.compare(count, value)

class PickRandomObject(Condition):
    def check(self):
        try:
            selected = [random.choice(self.get_frame_instances())]
        except IndexError:
            selected = []
        self.select_frame_instances(selected)
        return len(selected) > 0

class PickObjectsInZone(Condition):
    x1 = None
    y1 = None
    x2 = None
    y2 = None
    def created(self):
        zone = self.get_parameter(0)
        self.x1 = zone.x1
        self.y1 = zone.y1
        self.x2 = zone.x2
        self.y2 = zone.y2

    def check(self):
        instances = [instance for instance in self.get_frame_instances()
            if instance.in_zone(self.x1, self.y1, self.x2, self.y2)]
        self.select_frame_instances(instances)
        return len(instances) > 0

class PickObjectsInLine(Condition):
    def check(self):
        x1 = self.evaluate_index(0)
        y1 = self.evaluate_index(1)
        x2 = self.evaluate_index(2)
        y2 = self.evaluate_index(3)
        instances = [instance for instance in self.get_frame_instances()
            if collide_line(instance.x1, instance.y1, instance.x2, instance.y2,
            x1, y1, x2, y2)]
        self.select_frame_instances(instances)
        return len(instances) > 0

class PickRandomObjectInZone(Condition):
    x1 = None
    y1 = None
    x2 = None
    y2 = None
    def created(self):
        zone = self.get_parameter(0)
        self.x1 = zone.x1
        self.y1 = zone.y1
        self.x2 = zone.x2
        self.y2 = zone.y2

    def check(self):
        instances = [instance for instance in self.get_frame_instances()
            if instance.in_zone(self.x1, self.y1, self.x2, self.y2)]
        try:
            selected = [random.choice(instances)]
        except IndexError:
            selected = []
        self.select_frame_instances(selected)
        return len(instances) > 0

class PickRandomObjectInZoneOld(Condition):
    x1 = None
    y1 = None
    x2 = None
    y2 = None
    def created(self):
        zone = self.get_parameter(0)
        self.x1 = zone.x1
        self.y1 = zone.y1
        self.x2 = zone.x2
        self.y2 = zone.y2

    def check(self):
        instances = [instance for instance in self.get_frame_instances()
            if instance.objectType == ACTIVE and instance.in_zone(
            self.x1, self.y1, self.x2, self.y2)]
        try:
            selected = [random.choice(instances)]
        except IndexError:
            selected = []
        self.select_frame_instances(selected)
        return len(instances) > 0

class PickFromFixed(Condition):
    def check(self):
        fixed = self.evaluate_index(0)
        instances = [instance for instance in self.get_frame_instances()
            if id(instance) == fixed]
        self.select_frame_instances(instances, self.get_instances(
            instance.handle))
        return len(instances) > 0

