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

from mmfparser.player.movements.common cimport MovementPlayer
from mmfparser.player.movements import make_direction
from mmfparser.player.instance cimport Instance
from mmfparser.player.collision cimport collide, CollisionBase
from mmfparser.player.objects.common cimport BaseObject
import time

cdef class Static(MovementPlayer):
    cdef public:
        object movement
        bint firstUpdate

    def initialize(self, loader):
        self.movement = loader
        self.isStatic = True
        cdef int direction = loader.directionAtStart
        self.collisions = set()
        # self.overlapping = {}
        self.collidingInstances = set()
        cdef Instance parent = self.parent
        if direction != 0:
            direction = make_direction(direction)
            self.set_direction(direction)
        if not self.firstUpdate and not parent.updateEnabled:
            parent.updateEnabled = True
        
    cpdef update(self):
        cdef Instance parent = self.parent
        if self.firstUpdate:
            if not self.player.frame.collision_enabled(parent.handle):
                self.firstUpdate = False
                parent.updateEnabled = False
                return
        if parent.collisionSet and len(self.collisions) > 0:
            self.collisions = set()
        else:
            parent.collisionSet = True
            self.handle_collisions()
            
    cpdef bint handle_collisions(self, set instances_dummy = None):
        cdef Instance parent = self.parent
        if parent.destroying:
            return True
        cdef set oldCollisions = self.collisions
        cdef set collisions = set()
        self.collisions = collisions
        cdef BaseObject objectPlayer = parent.objectPlayer
        cdef Instance instance
        cdef set instances = self.player.frame.get_collision_instances(parent)
        for instance in instances:
            if instance is parent or instance.destroying:
                continue
            if (collide(
            instance.objectPlayer.collision, objectPlayer.collision)):
                collisions.add(instance)
                if (instance not in oldCollisions
                and not (instance.currentMovement
                and parent in instance.currentMovement.collisions)):
                    parent.fire_handler('on_collision', instance)
                    if self.breakMovement or parent.destroying:
                        return True

__all__ = ['Static']