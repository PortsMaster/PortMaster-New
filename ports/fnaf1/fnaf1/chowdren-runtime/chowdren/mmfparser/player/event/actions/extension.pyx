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

from pyglet.window import key

from mmfparser.player.event.actions.common cimport Action
from mmfparser.player.instance cimport Instance
from mmfparser.player.movements import shoot
from mmfparser.player.movements import make_direction
from mmfparser.player.objects.common cimport BaseObject
from mmfparser.player.frame cimport Frame

cdef class SubtractFromAlterable(Action):
    cdef void execute_instance(self, Instance instance):
        index = self.get_alterable_index(self.get_parameter(0))
        value = self.evaluate_index(1)
        currentValue = instance.alterables.get_value(index)
        instance.alterables.set_value(index, currentValue - value)

cdef class AddToAlterable(Action):
    cdef void execute_instance(self, Instance instance):
        index = self.get_parameter_value(self.parameters[0])
        value = self.evaluate_expression(self.parameters[1])
        currentValue = instance.alterables.get_value(index)
        instance.alterables.set_value(index, currentValue + value)

cdef class SetAlterableValue(Action):
    cdef void execute_instance(self, Instance instance):
        index = self.get_parameter_value(self.parameters[0])
        value = self.evaluate_expression(self.parameters[1])
        instance.alterables.set_value(index, value)

cdef class SetAlterableString(Action):
    cdef void execute_instance(self, Instance instance):
        index = self.get_alterable_index(self.get_parameter(0))
        value = self.evaluate_index(1)
        instance.alterables.set_string(index, str(value))

cdef class SpreadValue(Action):
    iterateObjects = False

    cdef void execute(self):
        index = self.get_alterable_index(self.get_parameter(0))
        start = self.evaluate_index(1)
        instances = self.get_instances()
        cdef int n
        cdef Instance item
        for n, item in enumerate(reversed(instances)):
            item.alterables.set_value(index, start + n)

cdef class EnableFlag(Action):
    cdef void execute_instance(self, Instance instance):
        index = self.evaluate_index(0) % 32
        try:
            instance.alterables.flags[index] = True
        except IndexError:
            pass

cdef class DisableFlag(Action):
    cdef void execute_instance(self, Instance instance):
        index = self.evaluate_index(0) % 32
        try:
            instance.alterables.flags[index] = False
        except IndexError:
            pass

cdef class ToggleFlag(Action):
    cdef void execute_instance(self, Instance instance):
        cdef bint value
        index = self.evaluate_index(0) % 32
        try:
            value = instance.alterables.flags[index]
            instance.alterables.flags[index] = not value
        except IndexError:
            pass

cdef class ForceAnimation(Action):
    cdef void execute_instance(self, Instance instance):
        index = <int>self.get_parameter_value(self.get_parameter(0))
        instance.objectPlayer.set_animation_index(index, True)
            
class RestoreAnimation(Action):
    def execute(self, instance):
        instance.objectPlayer.restore_animation()

cdef class ForceSpeed(Action):
    cdef void execute_instance(self, Instance instance):
        instance.objectPlayer.force_speed(True, self.evaluate_expression(
            self.get_parameter(0)))

cdef class RestoreSpeed(Action):
    cdef void execute_instance(self, Instance instance):
        instance.objectPlayer.force_speed(False)

class FlashDuring(Action):
    def created(self):
        self.seconds = self.get_time(self.get_parameter(0))
        
    def execute(self, instance):
        instance.flash(self.seconds)

cdef class SetPosition(Action):
    iterateObjects = False
    cdef void execute(self):
        cdef list positions = self.get_positions(self.get_parameter(0))
        cdef int size = len(positions)
        if not size:
            return
        cdef Instance instance
        cdef int index
        for index, instance in enumerate(self.get_instances()):
            destX, destY, _ = positions[index % size]
            instance.set_position(destX, destY, True)

cdef class SetX(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_expression(self.parameters[0])
        instance.set_position(value, instance.y, True)
            
cdef class SetY(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        instance.set_position(instance.x, value, True)

cdef class SwapPosition(Action):
    cdef void execute_instance(self, Instance instance):
        if self.group.swaps is None:
            self.group.swaps = []
        self.group.swaps.append(instance)

cdef class SelectMovement(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.get_parameter_value(self.get_parameter(0))
        instance.set_movement(value)
        
cdef class NextMovement(Action):
    cdef void execute_instance(self, Instance instance):
        instance.set_movement(instance.movementIndex + 1)

cdef class PreviousMovement(Action):
    cdef void execute_instance(self, Instance instance):
        instance.set_movement(instance.movementIndex + 1)

cdef class SetSpeed(Action):
    cdef void execute_instance(self, Instance instance):
        speed = self.evaluate_index(0)
        instance.currentMovement.set_speed(speed)

cdef class SetMaximumSpeed(Action):
    cdef void execute_instance(self, Instance instance):
        speed = self.evaluate_index(0)
        movement = instance.currentMovement
        movement.maxSpeed = speed
        movement.set_speed(movement.speed)

cdef class SetRotatingSpeed(Action):
    cdef void execute_instance(self, Instance instance):
        speed = self.evaluate_index(0)
        movement = instance.currentMovement
        movement.rotationSpeed = speed

cdef class SetAcceleration(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        movement = instance.currentMovement
        movement.set_acceleration(value)

cdef class SetDeceleration(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        movement = instance.currentMovement
        movement.set_deceleration(value)

cdef class SetGravity(Action):
    cdef void execute_instance(self, Instance instance):
        value = self.evaluate_index(0)
        movement = instance.currentMovement
        try:
            movement.set_gravity(value)
        except AttributeError:
            pass

cdef class Reverse(Action):
    cdef void execute_instance(self, Instance instance):
        movement = instance.currentMovement
        try:
            movement.reverse()
        except AttributeError:
            pass

cdef class SetDirections(Action):
    cdef void execute_instance(self, Instance instance):
        directions = self.get_parameter(0).value
        movement = instance.currentMovement
        movement.directions = directions

cdef class BranchNode(Action):
    cdef void execute_instance(self, Instance instance):
        name = self.evaluate_index(0)
        movement = instance.currentMovement
        movement.branch_node(name)

cdef class GoToNode(Action):
    cdef void execute_instance(self, Instance instance):
        name = self.evaluate_index(0)
        movement = instance.currentMovement
        movement.goto_node(name)

cdef class SetDirection(Action):
    cdef void execute_instance(self, Instance instance):
        cdef int direction = self.get_direction(self.get_parameter(0))
        direction = direction & 31 # % 32
        if instance.direction == direction:
            return
        instance.set_direction(direction, False)

cdef class ForceDirection(Action):
    cdef void execute_instance(self, Instance instance):
        direction = self.get_direction(self.get_parameter(0))
        direction = direction & 31 # % 32
        instance.objectPlayer.force_direction(direction)

cdef class RestoreDirection(Action):
    cdef void execute_instance(self, Instance instance):
        instance.objectPlayer.restore_direction()

class LookAt(Action):
    iterateObjects = False
    def execute(self):
        try:
            destX, destY, instance = self.get_positions(
                self.get_parameter(0))[0]
        except IndexError:
            return
        for instance in self.get_instances():
            instance.set_direction(
                self.direction_from(instance.x, instance.y, 
                    int(destX), int(destY)))

cdef class CollidingCommon(Action):
    cdef public:
        bint stopCorner
        bint colliding
        bint bounceObjects

    cdef void created(self):
        cdef int objectInfo = self.loader.objectInfo
        cdef list handles = self.resolve_objects(objectInfo)
        collisionConditions = self.get_group_conditions(OnCollision)
        backgroundConditions = self.get_group_conditions(OnBackgroundCollision,
            objectInfo)
        cdef int otherHandle, handle
        cdef list firstObjects, secondObjects, objects
        if self.get_group_conditions(LeavingPlayfield, objectInfo):
            self.stopCorner = True
        elif self.get_group_conditions(IsOverlapping, objectInfo):
            self.colliding = True
        elif collisionConditions:
            for condition in collisionConditions:
                firstObjects = self.resolve_objects(condition.loader.objectInfo)
                secondObjects = self.resolve_objects(
                    condition.get_parameter(0).objectInfo)
                for handle in handles:
                    for (firstList, secondList) in (
                    (firstObjects, secondObjects), (secondObjects, firstObjects)):
                        if handle in firstList:
                            for otherHandle in secondList:
                                self.player.frame.register_stop_collision(
                                    handle, otherHandle)
            self.colliding = True
            self.bounceObjects = True
        elif backgroundConditions:
            for condition in backgroundConditions:
                objects = self.resolve_objects(condition.loader.objectInfo)
                for handle in handles:
                    if handle in objects:
                        self.player.frame.register_background_stop_collision(
                            handle)
            self.colliding = True
            self.bounceObjects = True
        elif self.get_group_conditions(IsOverlappingBackground):
            self.colliding = True
            
    cdef void execute_instance(self, Instance instance):
        self.action(instance)
        try:
            if not self.stopCorner or instance.currentMovement.isShoot:
                return
        except AttributeError:
            pass
        cdef BaseObject objectPlayer
        x, y = instance.x, instance.y
        cdef Frame frame = instance.frame
        objectPlayer = instance.objectPlayer
        if instance.y1 < 0:
            y = objectPlayer.hotspotY
        if instance.y2 > frame.virtualHeight:
            y = frame.virtualHeight - objectPlayer.height + objectPlayer.hotspotY
        if instance.x1 < 0:
            x = objectPlayer.hotspotX
        if instance.x2 > frame.virtualWidth:
            x = frame.width - objectPlayer.width + objectPlayer.hotspotX
        instance.set_position(x, y)
    
    cdef void action(self, Instance instance):
        pass

cdef class Stop(CollidingCommon):
    cdef void action(self, Instance instance):
        instance.stop(self.colliding)

cdef class Bounce(CollidingCommon):
    cdef void action(self, Instance instance):
        instance.bounce()

class Start(Action):
    def execute(self, instance):
        instance.currentMovement.start()

class Wrap(Action):
    def execute(self, instance):
        instance.wrap = True

from mmfparser.data.chunkloaders.objects import SHOOTING
from mmfparser.data.chunkloaders.objectinfo import ACTIVE

cdef class Shoot(Action):
    iterateObjects = False
    cdef:
        bint action
        int initialDirection
        int direction
        object launchedObject

    cdef void created(self):
        self.launchedObject = self.player.frame.loader.instances.fromHandle(
            self.get_parameter(0).objectInstance)
        shootParameter = self.get_parameter(0)
        flags = shootParameter.position.flags
        self.action = flags['Action']
        self.initialDirection = flags['InitialDirection']
        self.direction = shootParameter.position.direction

    cdef void execute(self):
        shootParameter = self.get_parameter(0)
        self.launchedObject.objectInfo = shootParameter.objectInfo
        if self.action and not self.initialDirection:
            direction = make_direction(self.direction)
        else:
            direction = None
        cdef Instance newItem
        cdef list newInstances = []
        for instance in self.get_instances():
            if instance.objectType == ACTIVE:
                if instance.objectPlayer.currentIndex == SHOOTING:
                    continue
                if instance.objectPlayer.has_animation_index(SHOOTING):
                    instance.objectPlayer.set_animation_index(SHOOTING, True)
            x, y = instance.objectPlayer.get_action_point()
            newItem = self.player.frame.create_instance(self.launchedObject,
                instance.layerIndex)
            if newItem is None or newItem.detached:
                continue
            newItem.set_position(x, y)
            movement = newItem.new(shoot.Shoot)
            movement.initialize(shootParameter)
            newItem.movementPlayers.insert(0, movement)
            newItem.currentMovement = movement
            movement.ready()
            newItem.movementEnabled = False # so collisions aren't checked
            if direction == None:
                movement.set_direction(instance.get_direction())
            else:
                movement.set_direction(direction)
            newItem.movementEnabled = True
            movement.update()
            newInstances.append(newItem)
        if newInstances:
            self.select_instances(newInstances, newItem.handle)

class ShootToward(Action):
    iterateObjects = False
    def created(self):
        self.launchedObject = self.player.frame.loader.instances.fromHandle(
            self.get_parameter(0).objectInstance)

    def execute(self):
        shootParameter = self.get_parameter(0)
        try:
            destX, destY, instance = self.get_positions(
                self.get_parameter(1))[0]
        except IndexError:
            return
        self.launchedObject.objectInfo = shootParameter.objectInfo
        cdef Instance newItem
        cdef list newInstances = []
        for instance in self.get_instances():
            if instance.objectType == ACTIVE:
                if instance.objectPlayer.currentIndex == SHOOTING:
                    continue
                if instance.objectPlayer.has_animation_index(SHOOTING):
                    instance.objectPlayer.set_animation_index(SHOOTING, True)
            x, y = instance.objectPlayer.get_action_point()
            newItem = self.player.frame.create_instance(self.launchedObject,
                instance.layerIndex)
            if newItem is None or newItem.detached:
                continue
            newItem.set_position(x, y)
            movement = newItem.new(shoot.Shoot)
            movement.initialize(shootParameter)
            newItem.movementPlayers.insert(0, movement)
            newItem.currentMovement = movement
            movement.ready()
            newItem.movementEnabled = False # so collisions aren't checked
            movement.set_direction(self.direction_from(instance.x, instance.y, 
                destX, destY))
            newItem.movementEnabled = True
            movement.update()
            newInstances.append(newItem)
        self.select_instances(newInstances, newItem.handle)

cdef class BringToBack(Action):
    cdef void execute_instance(self, Instance instance):
        layer = instance.layer
        layer.set_level(instance, 0)

cdef class BringToFront(Action):
    cdef void execute_instance(self, Instance instance):
        layer = instance.layer
        layer.set_level(instance, layer.get_size())

cdef class MoveBehind(Action):
    cdef void execute_instance(self, Instance instance):
        layer = instance.layer
        cdef Instance otherInstance
        cdef int position1, position2
        for otherInstance in self.get_instances(self.get_parameter(0).objectInfo):
            position1 = layer.get_level(instance)
            position2 = layer.get_level(otherInstance)
            if position2 < position1:
                layer.set_level(instance, position2)

cdef class MoveInFront(Action):
    cdef void execute_instance(self, Instance instance):
        layer = instance.layer
        cdef Instance otherInstance
        cdef int position1, position2
        for otherInstance in self.get_instances(self.get_parameter(0).objectInfo):
            position1 = layer.get_level(instance)
            position2 = layer.get_level(otherInstance)
            if position1 < position2:
                layer.set_level(instance, position2 + 1)

cdef class MoveToLayer(Action):
    cdef void execute_instance(self, Instance instance):
        index = int(self.evaluate_index(0)) - 1
        instance.set_layer(index)

cdef class SetInkEffect(Action):
    cdef void execute_instance(self, Instance instance):
        shorts = self.get_parameter(0)
        instance.set_effect(shorts.value1, shorts.value2)

cdef class SetEffect(Action):
    cdef void execute_instance(self, Instance instance):
        instance.set_effect_name(
            self.get_parameter(0).value)

cdef class Hide(Action):
    cdef void execute_instance(self, Instance instance):
        instance.set_visible(False)

cdef class Show(Action):
    cdef void execute_instance(self, Instance instance):
        instance.set_visible(True)

cdef class Destroy(Action):
    cdef void execute_instance(self, Instance instance):
        # print 'destroying instance:', instance.objectInfo.name
        instance.destroy()

cdef class SetSemiTransparency(Action):
    cdef void execute_instance(self, Instance instance):
        instance.set_transparency(128 - int(self.evaluate_expression(
            self.get_parameter(0))))

cdef class SetAlphaCoefficient(Action):
    cdef void execute_instance(self, Instance instance):
        instance.set_transparency((255 - int(self.evaluate_expression(
            self.get_parameter(0)))) / 255.0 * 128.0)

cdef class SetRGBCoefficient(Action):
    cdef void execute_instance(self, Instance instance):
        color = self.get_color(self.get_parameter(0))
        r, g, b = color
        r = r / 255.0
        g = g / 255.0
        b = b / 255.0
        instance.colorCoefficient = (r, g, b)

cdef class SetEffectParameter(Action):
    cdef void execute_instance(self, Instance instance):
        if instance.inkEffect is None or instance.inkEffect.parameters is None:
            return
        name = self.evaluate_index(0)
        value = self.evaluate_index(1)
        try:
            instance.inkEffect.parameters[name].value = value
        except KeyError:
            return

cdef class AddToDebugger(Action):
    cdef void execute_instance(self, Instance instance):
        pass

from mmfparser.player.event.conditions.extension import (LeavingPlayfield,
    OnCollision, OnBackgroundCollision, IsOverlappingBackground, IsOverlapping)