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

from mmfparser.player.event.actions.system import StartLoop

class CreateObject(Action):
    selectInstance = True
    clearInstances = False
    createdObject = None
    createParameter = None
    def created(self):
        objectInfo = self.getObjectInfo()
        if objectInfo is None:
            return
        objectInfoParent = self.createParameter.position.objectInfoParent
        for action in self.group.actions:
            klass = action.__class__
            if klass == CreateObject:
                if action.getObjectInfo() == objectInfo:
                    if action == self:
                        self.clearInstances = objectInfo != objectInfoParent
                    break
            elif klass == StartLoop:
                self.clearInstances = True
                break
            if action.loader and action.loader.objectInfo == objectInfo:
                self.selectInstance = False
                break

    def execute(self):
        createdObject = self.createdObject
        if createdObject is None:
            print '(error: object not found in frame instances)'
            return
        handle = self.createParameter.objectInfo
        createdObject.objectInfo = handle
        layer = self.createParameter.position.layer
        if self.clearInstances:
            self.select_instances([], handle)
        for x, y, instance in self.get_positions(self.createParameter.position):
            if instance is not None:
                currentLayer = instance.layerIndex
            else:
                currentLayer = layer
            newItem = self.player.frame.create_instance(createdObject, 
                currentLayer)
            if newItem is None or newItem.detached:
                continue
            newItem.set_position(x, y)
            if self.selectInstance:
                self.select_instances(self.get_instances(handle
                    ) + [newItem], handle)
    
    def getObjectInfo(self):
        if self.createdObject is None:
            self.createParameter = self.get_parameter(0)
            try:
                self.createdObject = self.player.frame.loader.instances.fromHandle(
                    self.createParameter.objectInstance)
            except ValueError:
                return None
        return self.createParameter.objectInfo