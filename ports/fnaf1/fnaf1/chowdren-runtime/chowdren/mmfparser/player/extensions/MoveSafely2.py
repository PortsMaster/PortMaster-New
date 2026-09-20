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

"""
MoveSafely2.mfx
Move Safely 2 Object - David Clark (Alien) (http://www.clickteam.com)

Allow multiple objects to move 'safely' from one point to another
taking 'in-between steps' rather than jumping, allowing you to test
for collisions.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Safety Procedure->Prepare

    Parameters:
    0: 00Commence Safety Procedure ((unknown 25010))
    """

    def execute(self, instance):
        instance.objectPlayer.prepare()

class Action1(Action):
    """
    Safety Procedure->Commence

    Parameters:
    0: 00Stop Safety Procedure and push out ((unknown 25020))
    """

    def execute(self, instance):
        instance.objectPlayer.start()

class Action2(Action):
    """
    Safety Procedure->Stop ( Push out of obstacle )

    Parameters:
    0: 01Add object (%s) to protection ((unknown 25030))
    """

    def execute(self, instance):
        instance.objectPlayer.stop()

class Action3(Action):
    """
    Add a new protected object/s

    Parameters:
    0: Select Object (TIME, Time)
    1: Pixel Distance of each 'step' (OBJECT, Object)
    """

    def execute(self, instance):
        value = self.evaluate_index(1)
        instances = self.get_instances(self.get_parameter(0).objectInfo)
        instance.objectPlayer.add(instances, value)

class Action4(Action):
    """
    Safety Procedure->Stop ( Keep in obstacle        )

    Parameters:
    0: 01Set Distance %s ((unknown 25050))
    """

    def execute(self, instance):
        instance.objectPlayer.stop_keep()

class Action5(Action):
    """
    Release all objects
    """

    def execute(self, instance):
        instance.objectPlayer.clear()

# Conditions

class Condition0(Condition):
    """
    On Safety procedure
    """
    
    def created(self):
        self.add_handlers(on_safety = self.on_safety)
    
    def on_safety(self, instance):
        self.generate()

    def check(self, instance):
        return self.isTriggered

# Expressions

class Expression0(Expression):
    """
    Get current object X

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.data.instance.x

class Expression1(Expression):
    """
    Get current object Y

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.data.instance.y

class Expression2(Expression):
    """
    Get current object Fixed Value

    Parameters:
    0: (not found) ((unknown 27030))
    Return type: Int
    """

    def get(self, instance):
        return id(instance.objectPlayer.data.instance)

class Expression3(Expression):
    """
    Get Number of loops

    Parameters:
    0: (not found) ((unknown 27040))
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.instances)

class Expression4(Expression):
    """
    Get loop index

    Parameters:
    0: (not found) ((unknown 27050))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.loopIndex

class InstanceData(object):
    newX = newY = None
    oldX = oldY = None
    def __init__(self, instance, dist):
        self.instance = instance
        self.distance = dist

import math

class DefaultObject(HiddenObject):
    instances = None
    data = None
    hasStopped = False
    inObstacle = False
    temp = temp2 = None
    last = False
    loopIndex = 0
    def created(self, data):
        self.instances = {}
    
    def clear(self):
        self.instances = set()
    
    def add(self, instances, value):
        for instance in instances:
            self.instances[instance] = InstanceData(instance, value)
    
    def prepare(self):
        for instance, data in self.instances.iteritems():
            data.oldX = instance.x
            data.oldY = instance.y
    
    def start(self):
        for instance, data in self.instances.iteritems():
            data.newX = instance.x
            data.newY = instance.y
            instance.set_position(data.oldX, data.oldY)
        self.loopIndex = 0
        for instance, data in self.instances.iteritems():
            self.temp = max(math.fabs(data.oldX - data.newX), 
                math.fabs(data.oldY - data.newY))
            if self.temp != 0:
                self.temp2 = 1
                first = True
                self.last = False
                doit = True
                while 1:
                    if not first:
                        self.temp2 += data.distance
                    if first:
                        first = False
                    if self.temp2 < self.temp:
                        doit = True
                    if self.temp2 >= self.temp:
                        doit = False
                    if not doit and not self.last:
                        self.last = True
                        doit = True
                        self.temp2 = self.temp
                    if not doit:
                        break
                    x_value = data.newX - data.oldX
                    y_value = data.newY - data.oldY
                    x = data.oldX + x_value * self.temp2 / self.temp
                    y = data.oldY + y_value * self.temp2 / self.temp
                    instance.set_position(x, y)
                    self.data = data
                    self.fire_handler('on_safety')
            self.loopIndex += 1
            self.hasStopped = False
    
    def stop(self):
        data = self.data
        if data is None:
            return
        instance = data.instance
        if self.hasStopped:
            self.inObstacle = True
            return
        self.hasStopped = True
        self.inObstacle = True
        loop = 0
        while self.inObstacle:
            loop += 1
            self.inObstacle = False
            x_value = data.newX - data.oldX
            y_value = data.newY - data.oldY
            x = data.oldX + x_value * (self.temp2 - loop) / self.temp
            y = data.oldY + y_value * (self.temp2 - loop) / self.temp
            instance.set_position(x, y)
            self.fire_handler('on_safety')
        self.temp2 = self.temp
        self.last = True
    
    def stop_keep(self):
        if self.hasStopped:
            self.inObstacle = True
            return
        self.temp2 = self.temp

class MoveSafely2(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        6 : Action5,
    }
    
    conditions = {
        0 : Condition0,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
    }

extension = MoveSafely2()

def get_extension():
    return extension
