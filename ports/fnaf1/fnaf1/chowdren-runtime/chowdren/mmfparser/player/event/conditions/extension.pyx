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

from mmfparser.player.event.conditions.common cimport Condition
from mmfparser.player.instance cimport Instance
from mmfparser.player.collision cimport CollisionBase, collide
from mmfparser.bitdict import BitDict
from mmfparser.data.chunkloaders.objects import (NONE_OBSTACLE as _NO, 
    SOLID_OBSTACLE as _SO, PLATFORM_OBSTACLE as _PO, LADDER_OBSTACLE as _LO)
from mmfparser.data.chunkloaders.objectinfo import (QUICKBACKDROP as _QB, 
    BACKDROP as _BD)
from mmfparser.data.chunkloaders.parameters.loaders import EQUAL, DIFFERENT

cdef int EQUAL_INT = EQUAL
cdef int DIFFERENT_INT = DIFFERENT_INT

cdef extern from "Python.h":
    object PyLong_FromVoidPtr(void*)

cimport cython

cdef int QUICKBACKDROP, BACKDROP, NONE_OBSTACLE, SOLID_OBSTACLE, 
cdef int PLATFORM_OBSTACLE, LADDER_OBSTACLE
QUICKBACKDROP = _QB
BACKDROP = _BD
NONE_OBSTACLE = _NO
SOLID_OBSTACLE = _SO
PLATFORM_OBSTACLE = _PO
LADDER_OBSTACLE = _LO

import random

cdef int MAX_COLLISIONS = 10

class AllDestroyed(Condition):
    iterateObjects = False
    def created(self):
        if self.isTriggered:
            self.player.frame.add_handlers(self.loader.objectInfo,
                destroyed = self.object_destroyed
            )
    
    def object_destroyed(self, instance):
        if self.check():
            self.generate()
        
    def check(self):
        return len(self.get_all_instances()) == 0

@cython.final
cdef class OnCollision(Condition):
    cdef public:
        bint iterateObjects
        tuple waitingInstances
        list firstObjects
        list secondObjects

    cdef void created(self):
        firstObjects = self.firstObjects = self.resolve_objects(
            self.loader.objectInfo)
        secondObjects = self.secondObjects = self.resolve_objects(
            self.get_parameter(0).objectInfo)
        for first in firstObjects:
            if self.isTriggered:
                self.player.frame.add_handlers(first,
                    on_collision = self.first_collision
                )
            for second in secondObjects:
                if self.isTriggered:
                    self.player.frame.add_handlers(second,
                        on_collision = self.second_collision
                    )
                self.player.frame.register_collision(first, second)
    
    def first_collision(self, Instance firstInstance, Instance secondInstance):
        if secondInstance.handle not in self.secondObjects:
            return
        self.waitingInstances = (self.loader.objectInfo, firstInstance, 
            self.get_parameter(0).objectInfo, secondInstance)
        self.generate()
    
    def second_collision(self, Instance secondInstance, Instance firstInstance):
        if firstInstance.handle not in self.firstObjects:
            return
        self.waitingInstances = (self.loader.objectInfo, firstInstance, 
            self.get_parameter(0).objectInfo, secondInstance)
        self.generate()
    
    cdef bint check(self):
        cdef list instances, otherInstances
        cdef Instance otherInstance, instance
        if self.isTriggered:
            if not self.waitingInstances:
                return False
            handle, instance, otherHandle, otherInstance = self.waitingInstances
            self.select_instances([instance], handle)
            self.select_instances([otherInstance], otherHandle)
            self.waitingInstances = None
            return True
        else:
            instances = self.get_instances()
            otherInstances = self.get_instances(
                self.get_parameter(0).objectInfo)
            selectedInstances, otherSelectedInstances = check_overlap(instances, 
                otherInstances)
            self.select_instances(selectedInstances)
            self.select_instances(otherSelectedInstances, 
                self.get_parameter(0).objectInfo)
            return len(selectedInstances) > 0

cdef inline bint check_backdrop_overlap(Instance instance):
    if instance.destroying:
        return False
    cdef list instances
    cdef Instance otherInstance
    cdef CollisionBase collision = instance.objectPlayer.collision
    for instances in (instance.layer.ladders, instance.layer.obstacles):
        for otherInstance in instances:
            if collide(otherInstance.objectPlayer.collision, collision):
                return True
    return False

cdef inline tuple check_overlap(list instances, list otherInstances):
    cdef set selectedInstances = set()
    cdef set otherSelectedInstances = set()
    cdef Instance instance, otherInstance
    cdef CollisionBase collision
    for instance in instances:
        if instance.destroying:
            continue
        collision = instance.objectPlayer.collision
        for otherInstance in otherInstances:
            if (instance is otherInstance or otherInstance.destroying or
                instance.layerIndex != otherInstance.layerIndex):
                continue
            if collide(otherInstance.objectPlayer.collision, collision):
                otherSelectedInstances.add(otherInstance)
                selectedInstances.add(instance)
    return list(selectedInstances), list(otherSelectedInstances)

@cython.final
cdef class OnBackgroundCollision(Condition):
    cdef public:
        bint iterateObjects
        bint bounceObjects
        Instance waitingInstance

    cdef void created(self):
        for handle in self.resolve_objects(self.loader.objectInfo):
            if self.isTriggered:
                self.player.frame.add_handlers(handle,
                    on_collision = self.on_collision
                )
            self.player.frame.register_background_collision(handle)
    
    def on_collision(self, Instance instance, Instance otherInstance):
        if (otherInstance.objectType not in (QUICKBACKDROP, BACKDROP) or
            otherInstance.objectPlayer.obstacleType in (NONE_OBSTACLE,
            LADDER_OBSTACLE)):
            return
        self.waitingInstance = instance
        self.generate()
    
    cdef bint check(self):
        cdef list selectedInstances
        cdef Instance instance
        if self.isTriggered:
            if not self.waitingInstance:
                return False
            instance = self.waitingInstance
            if instance not in self.get_instances():
                return False
            self.select_instances([instance])
            self.waitingInstance = None
            return True
        else:
            selectedInstances = []
            for instance in self.get_instances():
                if check_backdrop_overlap(instance):
                    selectedInstances.append(instance)
            self.select_instances(selectedInstances)
            return len(selectedInstances) > 0

@cython.final
cdef class IsOverlapping(Condition):
    cdef public:
        object otherInfo
    
    cdef void created(self):
        self._iterateObjects = False
        for handle in self.resolve_objects(self.objectInfo):
            self.player.frame.add_no_sleep_instance(handle)
        objectInfo = self.otherInfo = self.get_parameter(0).objectInfo
        for handle in self.resolve_objects(objectInfo):
            self.player.frame.add_no_sleep_instance(handle)

    cdef bint check(self):
        objectInfo = self.otherInfo
        cdef list instances, otherInstances
        if self.negated:
            instances = self.get_all_instances()
            otherInstances = self.get_all_instances(objectInfo)
        else:
            instances = self.get_instances()
            otherInstances = self.get_instances(objectInfo)
        selectedInstances, otherSelectedInstances = check_overlap(instances, 
            otherInstances)
        if not self.negated:
            self.select_instances(selectedInstances)
            self.select_instances(otherSelectedInstances, objectInfo)
        return (len(selectedInstances) > 0) != self.negated

cdef class IsOverlappingBackground(Condition):
    cdef bint check_instance(self, Instance instance):
        return check_backdrop_overlap(instance)

cdef class AnimationPlaying(Condition):
    cpdef bint check_instance(self, Instance instance):
        value = self.get_parameter_value(self.get_parameter(0))
        return instance.objectPlayer.currentAnimation.getIndex() == value

cdef class AnimationFinished(Condition):
    iterateObjects = False
    instances = None
    instance = None
    cdef void created(self):
        self.instances = []
        self.player.frame.add_handlers(self.loader.objectInfo,
            animation_finished = self.animation_finished
        )
    
    def animation_finished(self, instance, animation):
        if animation.getIndex() == self.get_parameter(0).value:
            if self.isTriggered:
                self.instance = instance
                self.generate()
            else:
                self.instances.append(instance)
    
    cpdef bint check(self):
        if self.isTriggered:
            if not self.instance:
                return False
            if self.instance not in self.get_instances():
                return False
            self.select_instances([self.instance])
            self.instance = None
            return True
        else:
            selectedInstances = []
            currentInstances = self.get_instances()
            for instance in self.instances:
                if instance in currentInstances:
                    selectedInstances.append(instance)
            self.instances = []
            self.select_instances(selectedInstances)
            return len(selectedInstances) > 0

@cython.final
cdef class AnimationFrame(Condition):
    cdef bint check_instance(self, Instance instance):
        value = self.evaluate_index(0)
        return self.compare(instance.objectPlayer.frameIndex, value)

class NumberOfObjects(Condition):
    iterateObjects = False
    def check(self):
        value = self.evaluate_index(0)
        return self.compare(len(self.get_all_instances()), value)

class ObjectsInZone(Condition):
    iterateObjects = False
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
        count = len([instance for instance in self.get_all_instances()
            if instance.in_zone(self.x1, self.y1, self.x2, self.y2)])
        return self.compare(count, value)

@cython.final
cdef class NoObjectsInZone(Condition):
    iterateObjects = False
    cdef public:
        int x1
        int y1
        int x2
        int y2
    
    cdef void created(self):
        zone = self.get_parameter(0)
        self.x1 = zone.x1
        self.y1 = zone.y1
        self.x2 = zone.x2
        self.y2 = zone.y2
        
    cdef bint check(self):
        count = len([instance for instance in self.get_all_instances()
            if instance.in_zone(self.x1, self.y1, self.x2, self.y2)])
        return count == 0

cdef class MovementStopped(Condition):
    cdef bint check_instance(self, Instance instance):
        return instance.currentMovement.stopped

@cython.final
cdef class CompareDeceleration(Condition):
    cdef bint check_instance(self, Instance instance):
        try:
            value1 = instance.currentMovement.decelerationValue
        except AttributeError:
            value1 = 0
        value2 = self.evaluate_index(0)
        return self.compare(value1, value2)

@cython.final
cdef class CompareAcceleration(Condition):
    cdef bint check_instance(self, Instance instance):
        try:
            value1 = instance.currentMovement.accelerationValue
        except AttributeError:
            value1 = 0
        value2 = self.evaluate_index(0)
        return self.compare(value1, value2)

@cython.final
cdef class CompareY(Condition):
    cdef bint check_instance(self, Instance instance):
        value = self.evaluate_index(0)
        return self.compare(<int>instance.y, value)

@cython.final
cdef class CompareX(Condition):
    cdef bint check_instance(self, Instance instance):
        value = self.evaluate_index(0)
        return self.compare(<int>instance.x, value)

@cython.final
cdef class CompareAlterableValue(Condition):
    cdef bint check_instance(self, Instance instance):
        index = self.get_parameter_value(self.get_parameter(0))
        value = self.evaluate_index(1)
        return self.compare(instance.alterables.get_value(index), value)

@cython.final
cdef class CompareAlterableString(Condition):
    cdef bint check_instance(self, Instance instance):
        index = self.get_alterable_index(self.get_parameter(0))
        value = self.evaluate_index(1)
        return self.compare(instance.alterables.get_string(index), value)

@cython.final
cdef class FlagOn(Condition):
    cdef bint check_instance(self, Instance instance):
        index = self.evaluate_index(0) % 32
        try:
            return instance.alterables.flags[index]
        except IndexError:
            return False

@cython.final
cdef class FlagOff(Condition):
    iterateObjects = False
    cdef bint check(self):
        cdef list instances = self.get_instances()
        cdef Instance instance
        cdef list newInstances = []
        index = self.evaluate_index(0) % 32
        for instance in instances:
            try:
                if not instance.alterables.flags[index]:
                    newInstances.append(instance)
            except IndexError:
                continue
        self.select_instances(newInstances)
        return len(newInstances) > 0

cdef class OutsidePlayfield(Condition):
    cdef void created(self):
        for handle in self.resolve_objects(self.objectInfo):
            self.player.frame.add_border_collision_instance(handle)
        
    cpdef bint check_instance(self, Instance instance):
        return instance.outside_playfield()

cdef class InsidePlayfield(Condition):
    cdef void created(self):
        for handle in self.resolve_objects(self.objectInfo):
            self.player.frame.add_border_collision_instance(handle)

    cpdef bint check_instance(self, Instance instance):
        return (not instance.outside_playfield())

PLAYFIELD_FLAGS = BitDict('Left', 'Right', 'Up', 'Down')

class LeavingPlayfield(Condition):
    instances = None
    
    up = False
    down = False
    left = False
    right = False
    
    iterateObjects = False

    def created(self):
        self.instances = []
        ways = PLAYFIELD_FLAGS.copy()
        ways.setFlags(self.get_parameter(0).value)
        self.up = ways['Up']
        self.down = ways['Down']
        self.left = ways['Left']
        self.right = ways['Right']
        self.player.frame.add_handlers(self.loader.objectInfo,
            leaving_playfield = self.leaving_playfield
        )
        self.wrap = len(self.get_group_actions(Wrap, self.loader.objectInfo)
            ) > 0
        for handle in self.resolve_objects(self.objectInfo):
            self.player.frame.add_border_collision_instance(handle)

    def corners_match(self, corners):
        if corners & 1 and self.up:
            return True
        if corners & 2 and self.down:
            return True
        if corners & 4 and self.left:
            return True
        if corners & 8 and self.right:
            return True
        return False
    
    def leaving_playfield(self, instance):
        corners = instance.get_leaving_corners()
        if self.wrap:
            self.set_corners(instance)
        if not self.corners_match(corners):
            return
        self.instances.append(instance)
        self.generate()
    
    def set_corners(self, instance):
        instance.wrapUp = self.up or instance.wrapUp
        instance.wrapDown = self.down or instance.wrapDown
        instance.wrapLeft = self.left or instance.wrapLeft
        instance.wrapRight = self.right or instance.wrapRight

    def check(self):
        if not self.instances:
            return False
        self.select_instances(self.instances)
        self.instances = []
        return True
    
    def on_detach(self):
        del self.instances

class EnteringPlayfield(Condition):
    instances = None
    
    up = False
    down = False
    left = False
    right = False
    
    iterateObjects = False

    def created(self):
        self.instances = []
        ways = PLAYFIELD_FLAGS.copy()
        ways.setFlags(self.get_parameter(0).value)
        self.up = ways['Up']
        self.down = ways['Down']
        self.left = ways['Left']
        self.right = ways['Right']
        self.player.frame.add_handlers(self.loader.objectInfo,
            entering_playfield = self.entering_playfield
        )
        for handle in self.resolve_objects(self.objectInfo):
            self.player.frame.add_border_collision_instance(handle)

    def corners_match(self, corners):
        if corners & 1 and self.up:
            return True
        if corners & 2 and self.down:
            return True
        if corners & 4 and self.left:
            return True
        if corners & 8 and self.right:
            return True
        return False
    
    def entering_playfield(self, instance):
        corners = instance.get_entering_corners()
        if not self.corners_match(corners):
            return
        self.instances.append(instance)
        self.generate()

    def check(self):
        if not self.instances:
            return False
        self.select_instances(self.instances)
        self.instances = []
        return True
    
    def on_detach(self):
        del self.instances

cdef class ObjectVisible(Condition):
    cdef bint check_instance(self, Instance instance):
        return instance.visible and instance.layer.visible

@cython.final
cdef class ObjectInvisible(Condition):
    cdef bint check_instance(self, Instance instance):
        return not (instance.visible and instance.layer.visible)

@cython.final
cdef class NearWindowBorder(Condition):
    cpdef bint check_instance(self, Instance instance):
        value = self.evaluate_index(0)
        result = instance.inside_window(value, value)
        return not result

cdef class PathFinished(Condition):
    iterateObjects = False
    instance = None
    cdef void created(self):
        self.player.frame.add_handlers(self.loader.objectInfo,
            path_finished = self.path_finished
        )
    
    def path_finished(self, instance):
        self.instance = instance
        self.generate()
    
    cpdef bint check(self):
        if self.instance and self.instance in self.get_instances():
            self.select_instances([self.instance])
            self.instance = None
            return True
        return False

class NodeReached(Condition):
    instance = None
    iterateObjects = False

    def created(self):
        self.player.frame.add_handlers(self.loader.objectInfo,
            node_reached = self.node_reached
        )
    
    def node_reached(self, instance):
        self.instance = instance
        self.generate()
    
    def check(self):
        if self.instance and self.instance in self.get_instances():
            self.select_instances([self.instance])
            self.instance = None
            return True
        return False

class NamedNodeReached(Condition):
    instance = None
    iterateObjects = False

    def created(self):
        self.player.frame.add_handlers(self.loader.objectInfo,
            named_node_reached = self.named_node_reached
        )
    
    def named_node_reached(self, instance, name):
        if name != self.evaluate_index(0):
            return
        self.instance = instance
        self.generate()
    
    def check(self):
        if self.instance and self.instance in self.get_instances():
            self.select_instances([self.instance])
            self.instance = None
            return True
        return False

@cython.final
cdef class CompareSpeed(Condition):
    cdef bint check_instance(self, Instance instance):
        value = self.evaluate_index(0)
        return self.compare(instance.currentMovement.speed, value)

@cython.final
cdef class Bouncing(Condition):
    cdef bint check_instance(self, Instance instance):
        try:
            return instance.currentMovement.bouncing
        except AttributeError:
            return False

@cython.final
cdef class FacingInDirection(Condition):
    cdef bint check_instance(self, Instance instance):
        return instance.direction in self.get_directions(self.get_parameter(0))

@cython.final
cdef class CompareFixedValue(Condition):
    iterateObjects = False
    cdef bint check(self):
        cdef void * fixed = <void*>(<long>self.evaluate_index(0))
        cdef Instance instance
        cdef list instances
        if self.compareValue == EQUAL_INT:
            if fixed == <void*>(-1):
                return False
            # for instance in self.get_instances():
            #     if fixed == <void*>instance:
            #         break
            # else:
            #     return False
            # self.select_instances([instance])
            self.select_instances([<object>fixed])
            return True
        elif self.compareValue == DIFFERENT_INT:
            if fixed == <void*>(-1):
                return True
            instances = []
            for instance in self.get_instances():
                if fixed == <void*>instance:
                    continue
                instances.append(instance)
            self.select_instances(instances)
            return len(instances) > 0

from mmfparser.player.event.actions.extension import Wrap, Bounce