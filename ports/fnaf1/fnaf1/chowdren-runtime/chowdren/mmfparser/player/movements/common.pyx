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

import math

from mmfparser.player.collision cimport (collide, Rectangle, collides, 
    CollisionBase)
from mmfparser.player.movements import make_direction
from mmfparser.data.chunkloaders.objectinfo import ACTIVE
from mmfparser.player.instance cimport Instance
from mmfparser.player.event.player cimport EventPlayer

from pyglet.window import key

cpdef int get_direction(bint up, bint down, bint left, bint right):
    if up and down:
        up = False
        down = False

    if left and right:
        left = False
        right = False

    if right and not (up or down or left):
        return 0

    elif (up and right) and not (left or down):
        return 4
    
    elif up and not (down or left or right):
        return 8
    
    elif (up and left) and not (right or down):
        return 12
    
    elif left and not (right or down or up):
        return 16
    
    elif (left and down) and not (up or right):
        return 20
    
    elif down and not (up or left or right):
        return 24
    
    elif (down and right) and not (left or up):
        return 28

# taken from the Java runtime
ACCELERATORS = [0.0078125, 0.01171875, 0.015625, 0.0234375, 0.03125, 0.0390625,
    0.046875, 0.0625, 0.078125, 0.09375, 0.1875, 0.21875, 0.25, 0.28125,
    0.3125, 0.34375, 0.375, 0.40625, 0.4375, 0.46875, 0.5625, 0.625, 0.6875, 
    0.75, 0.8125, 0.875, 0.9375, 1.0, 1.0625, 1.125, 1.25, 1.3125, 1.375,
    1.4375, 1.5, 1.5625, 1.625, 1.6875, 1.75, 1.875, 2.0, 2.125, 2.1875,
    2.3125, 2.4375, 2.5, 2.625, 2.6875, 2.8125, 2.875, 3.0, 3.0625, 3.1875,
    3.3125, 3.375, 3.5, 3.625, 3.6875, 3.8125, 3.875, 4.0, 4.375, 4.75,
    5.125, 5.625, 6.0, 6.375, 6.75, 7.125, 7.625, 8.0, 8.75, 9.5, 10.5, 11.25,
    12.0, 12.75, 13.5, 14.5, 15.25, 16.0, 25.5625, 19.1953125, 20.375,
    22.390625, 24.0, 25.59765625, 27.1953125, 28.7734375, 30.390625, 32.0,
    38.421875, 45.59375, 52.015625, 58.4375, 64.859375, 71.28125, 77.703125,
    84.0, 100.0, 100.0]

cdef inline void set_position(Instance instance, double x, double y):
    instance.oldX1, instance.oldY1, instance.oldX2, instance.oldY2 = (
        instance.x1, instance.y1, instance.x2, instance.y2)
    instance.set_position(x, y)
    instance.update_playfield()

cdef class MovementPlayer(PlayerChild):
    property stopped:
        def __get__(self):
            return self.speed == 0

    def initialize(self, movement):
        cdef Instance parent = self.parent
        self.speed = -1
        if getattr(self, 'useKeys', False):
            self._useKeys = True
            self.player_handler = self.player.players.items[movement.player-1]
            self.is_down = self.player_handler.is_down # for convience
            self.is_down_index = self.player_handler.is_down_index # for convience
        if getattr(movement, 'player', 0) != 0:
            parent.outsideKill = False
        self.movement = movement
        self.collisions = set()
        self.collidingInstances = set()
        self.set_speed(0)
        self.fire_handler = parent.fire_handler
        if parent.objectType == ACTIVE:
            self.hasAnimations = True
            active = parent.objectPlayer
            self.set_bounce = active.set_bounce
            self.set_climb = active.set_climb
            self.set_crouch = active.set_crouch
            self.set_jump = active.set_jump
            self.set_fall = active.set_fall
            self.set_shoot = active.set_shoot
            self.set_uncrouch = active.set_uncrouch
            self.set_walk = active.set_walk
        
    cpdef ready(self):
        cdef Instance parent = self.parent
        if not parent.updateEnabled:
            parent.updateEnabled = True
        self.created()
        self.set_direction()

    def get_accelerator(self, value):
        if value <= 100:
            return ACCELERATORS[value]
        return value
    
    cpdef double get_pixels(self, double value):
        return value * 0.125
    
    cpdef set_direction(self, direction = None):
        if direction is None:
            if hasattr(self.movement, 'directionAtStart'):
                direction = make_direction(self.movement.directionAtStart)
            else:
                return
        self.breakMovement = True
        self.direction = direction
        self.x_speed = math.cos(math.radians(direction * 11.25))
        self.y_speed = math.sin(math.radians(direction * -11.25))
        (<Instance>self.parent).set_direction(direction, False)
        self.direction_changed()
    
    def direction_changed(self):
        pass
    
    def stop(self, collision = False):
        self.collided = collision
        if not collision:
            self.on_stop()
    
    def on_stop(self):
        pass
    
    def bounce(self):
        self.stop(True)
    
    def start(self):
        self.on_start()
    
    def on_start(self):
        pass
    
    def set_speed(self, double speed):
        cdef Instance parent = self.parent
        speed = max(speed, 0)
        if speed == self.speed:
            return
        self.speed = speed
        if speed == 0:
            parent.stop()
        if self.hasAnimations:
            parent.set_speed(speed)
        self.speed_changed()
    
    def get_speed(self):
        return self.speed

    def speed_changed(self):
        pass
    
    cpdef update(self):
        if self._useKeys:        
            is_down = self.is_down_index
            up = is_down(0)
            down = is_down(1)
            left = is_down(2)
            right = is_down(3)
            button1 = is_down(4)
            button2 = is_down(5)
            self.move(up, down, left, right, button1, button2)
        else:
            self.move()
            
    cpdef tuple move_object(self, double addX, double addY):
        cdef Instance parent = self.parent
        if addX == 0 and addY == 0:
            return False, False
        if not self.player.frame.collision_enabled(parent.handle):
            set_position(parent, parent.x + addX, parent.y + addY)
            return False, False
        self.breakMovement = False
        
        cdef bint value
        cdef bint collidedX, collidedY
        collidedX = collidedY = False

        cdef double x = parent.x
        cdef double oldX = x
        cdef double y = parent.y
        cdef double oldY = y
        
        cdef int startX, endX, startY, endY, x1, x2, y1, y2, xStep, yStep
        cdef Instance instance

        startX = <int>x
        endX = <int>(x + addX)
        startY = <int>y
        endY = <int>(y + addY)
        
        cdef set instances = set()
        
        if addX > 0:
            x1 = parent.x1
            x2 = parent.x2 + (endX - startX)
            xStep = 1
        else:
            x1 = parent.x1 - (startX - endX)
            x2 = parent.x2
            xStep = -1
        
        if addY > 0:
            y1 = parent.y1
            y2 = parent.y2 + (endY - startY)
            yStep = 1
        else:
            y1 = parent.y1 - (startY - endY)
            y2 = parent.y2
            yStep = -1

        for instance in self.player.frame.get_collision_instances(parent):
            if collides(instance.x1, instance.y1, instance.x2, instance.y2, 
                        x1, y1, x2, y2):
                instances.add(instance)


        cdef int newX
        if addX:
            newX = startX
            while 1:
                if newX == endX:
                    set_position(parent, x + addX, parent.y)
                    break
                oldX = newX
                newX += xStep
                set_position(parent, newX, parent.y)
                value = self.handle_collisions(instances)
                if self.breakMovement:
                    return not value, not value
                if not value:
                    set_position(parent, oldX, parent.y)
                    collidedX = True
                    break
        
        cdef int newY
        if addY:
            newY = startY
            while 1:
                if newY == endY:
                    set_position(parent, parent.x, y + addY)
                    break
                oldY = newY
                newY += yStep
                set_position(parent, parent.x, newY)
                value = self.handle_collisions(instances)
                if self.breakMovement:
                    return not value, not value
                if not value:
                    set_position(parent, parent.x, oldY)
                    collidedY = True
                    break

        return collidedX, collidedY

    cpdef bint handle_collisions(self, set instances = None):
        cdef Instance parent = self.parent
        cdef int objectInfo = parent.handle
        if not self.player.frame.collision_enabled(objectInfo):
            return True
        elif parent.destroying:
            return True
        cdef set oldCollisions = self.collisions
        cdef set collisions = set()
        self.collisions = collisions
        # cdef dict overlapping = {}
        # self.overlapping = overlapping
        cdef set oldInstances = self.collidingInstances
        cdef set collidingInstances = set()
        self.collidingInstances = collidingInstances
        cdef BaseObject objectPlayer = parent.objectPlayer
        cdef bint collides = False
        if instances is None:
            instances = self.player.frame.get_collision_instances(parent)
        cdef Instance instance
        for instance in instances:
            if instance.destroying or instance is parent:
                continue
            if collide(instance.objectPlayer.collision, objectPlayer.collision):
                # overlapping[instance] = True
                if not self.instance_collides(instance):
                    continue
                collisions.add(instance)
                self.collided = False
                if instance in oldInstances:
                    self.collided = True
                elif (instance not in oldCollisions and
                not (instance.currentMovement
                and parent in instance.currentMovement.collisions)):
                    parent.fire_handler('on_collision', instance)
                if self.collided:
                    collidingInstances.add(instance)
                    if parent.destroying:
                        return True
            else:
                # overlapping[instance] = False
                if instance.currentMovement is not None:
                    instance.currentMovement.collisions.discard(parent)
        if collidingInstances:
            return False
        return True
    
    cpdef bint update_collisions(self, set instances):
        cdef Instance parent = self.parent
        cdef int objectInfo = parent.handle
        if not self.player.frame.collision_enabled(objectInfo):
            return True
        cdef dict overlapping = self.overlapping
        cdef CollisionBase collision = parent.objectPlayer.collision
        cdef Instance instance
        for instance in instances:
            if instance.destroying or instance is parent or instance in overlapping:
                continue
            if collide(instance.objectPlayer.collision, collision):
                overlapping[instance] = True
                if instance.currentMovement:
                    instance.currentMovement.overlapping[parent] = True
            else:
                overlapping[instance] = False
                if instance.currentMovement:
                    instance.currentMovement.overlapping[parent] = False

    cpdef bint instance_collides(self, Instance instance):
        return True
    
    def test_below(self, int y):
        cdef Instance parent = self.parent
        cdef int objectInfo = parent.handle
        if not self.player.frame.collision_enabled(objectInfo):
            return False
        cdef double oldY = parent.y
        parent.set_position(parent.x, oldY + y)
        cdef set instances = self.player.frame.get_stop_instances(parent)
        cdef CollisionBase collision = parent.objectPlayer.collision
        cdef CollisionBase otherCollision
        cdef Instance instance
        cdef bint collided = False
        for instance in instances:
            if instance.destroying or instance is parent:
                continue
            otherCollision = instance.objectPlayer.collision
            if collide(otherCollision, collision) and self.instance_collides(
            instance):
                collided = True
        if oldY + y == parent.y:
            parent.set_position(parent.x, oldY)
        return collided
    
    def created(self):
        pass
    
    def move(self, up, down, left, right, button1, button2):
        raise NotImplementedError('move() not implemented')
    
    def set_walk(self):
        pass
    
    def set_bounce(self):
        pass
    
    def set_shoot(self):
        pass
    
    def set_jump(self):
        pass
    
    def set_fall(self):
        pass
    
    def set_climb(self):
        pass
    
    def set_crouch(self):
        pass
        
    def set_uncrouch(self):
        pass
