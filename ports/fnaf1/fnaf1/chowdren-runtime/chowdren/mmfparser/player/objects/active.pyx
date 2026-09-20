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

from mmfparser.player.instance cimport Instance
from mmfparser.player.objects.common cimport ObjectPlayer
from mmfparser.player.collision cimport BoundingBox
from mmfparser.player.sprite import Sprite
from mmfparser.player.transitions import get_transition
from mmfparser.player.movements.common cimport MovementPlayer
from mmfparser.player.common cimport (transform_rect, cos, sin, radians,
    get_point)
import pyglet

from mmfparser.data.chunkloaders.objects import (ANIMATION_NAMES, STOPPED,
    WALKING, RUNNING, APPEARING, DISAPPEARING, BOUNCING, SHOOTING, JUMPING,
    FALLING, CLIMBING, CROUCH_DOWN, STAND_UP)

cdef class Active(ObjectPlayer):
    cdef public:
        object sprite
        object fade
        object animations
        int currentState
        int currentIndex
        object currentFrame
        object currentAnimation
        object currentDirection
        int frameCount
        int backTo
        dict createdSprites
        bint fineCollisions
        bint automaticRotation
        int oldAnimation
        bint animationForced
        int oldDirection
        bint directionForced
        bint frameForced
        bint stopped
        int loopsLeft
        object direction
        int speed
        int frameIndex
        tuple old
        bint colliding
        bint isCustom
        bint destroying
        double angle
        int forcedSpeed
        bint speedForced
        int forcedFrame
        float scaleX
        float scaleY
        unsigned int counter
    
    def created(self):
        self.frameIndex = -1
        self.updateEnabled = True
        cdef object newFlags = (<Instance>self.parent).loader.newFlags
        self.fineCollisions = not newFlags['CollisionBox']
        self.automaticRotation = newFlags['AutomaticRotation']
        self.colliding = False
        self.scaleX = self.scaleY = 1.0
        self.currentState = WALKING
        self.forcedSpeed = self.forcedFrame = -1
        self.animations = self.loader.animations
        self.createdSprites = {}
        if self.has_animation_index(APPEARING):
            self.set_animation_index(APPEARING, True)
            self.oldAnimation = APPEARING
        else:
            self.set_animation_index(STOPPED, True)
            self.oldAnimation = STOPPED
        self.animationForced = self.stopped = self.frameForced = False
        self.update_speed()
        
        fade = self.loader.fadeIn
        if fade:
            self.fade = self.new(get_transition(fade))
            self.fade.initialize(fade, self.fadein_finished, self.sprite)
        
        cdef dict storage
        if self.isGlobal:
            storage = self.get_storage()
            if storage:
                (<Instance>self.parent).alterables = storage['alterables'].copy()
        
        self.counter = 0
    
    def fadein_finished(self):
        self.fade = None
        
    def fadeout_finished(self):
        if self.parent is None:
            return
        (<Instance>self.parent).destroy(True)
    
    def restore_animation(self):
        if self.animationForced:
            self.animationForced = False
            self.set_animation_index(self.oldAnimation)
    
    def set_animation_item(self, item, force = False):
        if self.fade is not None:
            return
        cdef int index = item.getIndex()
        if not force:
            self.oldAnimation = index
        if self.animationForced and not force:
            return
        self.animationForced = force
        if self.destroying:
            return
        if item == self.currentAnimation:
            return
        self.currentIndex = index
        self.currentAnimation = item
        self.isCustom = index > STAND_UP
        
        self.loopsLeft = -1
        if self.direction is None:
            self.set_direction(0)
        else:
            direction = self.direction
            self.direction = None # uh, ugly hack, but it works
            self.set_direction(direction, force)
        if not self.stopped and not self.frameForced:
            self.set_frame(0)
    
    def set_animation(self, name, force = False):
        self.set_animation_item(self.animations.fromName(name), force)
    
    def set_animation_index(self, index, force = False):
        self.set_animation_item(self.animations.items[index], force)
    
    def set_angle(self, value):
        self.angle = value
        if self.sprite is not None:
            self.sprite.set_angle(value)
            self.update_attributes()
    
    def set_scale(self, scaleX, scaleY):
        if scaleX is not None:
            self.scaleX = scaleX
        if scaleY is not None:
            self.scaleY = scaleY
        self.sprite.set_scale(self.scaleX, self.scaleY)
        self.update_attributes()
    
    cdef void update_colliding_frame(self):
        if self.colliding:
            self.set_frame(self.frameIndex, False)
    
    def set_direction(self, direction, force = True):
        cdef int realDirection = direction
        if self.directionForced and not force:
            return
        if not force and direction == self.direction:
            self.update_colliding_frame()
            return
        if self.automaticRotation:
            direction = 0
            self.set_angle(realDirection * 11.25)
        if self.destroying:
            return
        self.direction = realDirection
        self.currentDirection = currentDirection = (
            self.currentAnimation.directions[direction])
        self.frameCount = len(currentDirection.frames)
        self.backTo = currentDirection.backTo
        if currentDirection.repeat == 0:
            self.loopsLeft = -1
        elif self.loopsLeft in (0, -1):
            self.loopsLeft = currentDirection.repeat
        self.wrap()
        if self.frameIndex != -1:
            self.set_frame(self.frameIndex, force)
        self.update_speed()
    
    def force_direction(self, direction):
        direction = direction % 32
        if not self.directionForced:
            self.oldDirection = self.direction
        self.directionForced = False # unlock
        self.set_direction(direction)
        self.directionForced = True
    
    def restore_direction(self):
        self.directionForced = False
        self.set_direction(self.oldDirection)
    
    def update_current_frame(self):
        try:
            currentFrame = self.player.changedFrames[(self.currentDirection,
                self.frameIndex)]
            self.currentFrame = currentFrame
            try:
                currentSprite = self.createdSprites[currentFrame]
            except KeyError:
                currentSprite = self.make_sprite(
                    self.make_image(currentFrame))
                self.createdSprites[currentFrame] = currentSprite
            self.on_update(currentSprite, currentFrame)
        except KeyError:
            return
        
    cpdef set_frame(self, int frame, bint force = False):
        if self.detached:
            return
        oldFrame = self.frameIndex
        direction = self.currentDirection
        frameCount = len(direction.frames) - 1
        self.frameIndex = max(0, min(frame, frameCount))
        try:
            currentFrame = self.player.changedFrames[(self.currentDirection, 
                self.frameIndex)]
        except KeyError:
            currentFrame = self.get_image(self.get_frame())
        if self.colliding or self.currentFrame is not currentFrame:
            self.currentFrame = currentFrame
            try:
                currentSprite = self.createdSprites[currentFrame]
            except KeyError:
                currentSprite = self.make_sprite(
                    self.make_image(currentFrame))
                self.createdSprites[currentFrame] = currentSprite
            self.on_update(currentSprite, currentFrame)
            if not force and (<Instance>self.parent).movementEnabled:
                if (<Instance>self.parent).currentMovement.handle_collisions():
                    self.old = (currentSprite, currentFrame)
                    self.colliding = True
                elif self.old is not None:
                    self.on_update(*self.old)
                    self.colliding = True
            else:
                (<Instance>self.parent).collisionSet = False
    
    def on_update(self, sprite, frame):
        self.sprite = sprite
        sprite.xy = self.x, self.y
        sprite.set_scale(self.scaleX, self.scaleY)
        sprite.set_angle(self.angle)
        sprite.alpha = (<Instance>self.parent).transparency / 128.0
        self.update_attributes(frame)
        if self.fineCollisions:
            self.collision = sprite.collision
        else:
            self.collision = BoundingBox(self)
        
    cdef void update_attributes(self, frame = None):
        frame = frame or self.currentFrame
        cdef int xHotspot, yHotspot, actionX, actionY, x1, y1, x2, y2, temp
        xHotspot = frame.xHotspot
        yHotspot = frame.yHotspot
        actionX = frame.actionX
        actionY = frame.actionY
        cdef int width = self.sprite.width
        cdef int height = self.sprite.height
        
        cdef double scaleX, scaleY
        cdef double co, si

        if self.scaleX != 1 or self.scaleY != 1 or self.angle != 0:
            scaleX, scaleY = self.scaleX, self.scaleY
            co = cos(radians(self.angle))
            si = sin(radians(self.angle))
            transform_rect(width, height, co, si, scaleX, scaleY,
                &x1, &y1, &x2, &y2)
            width = x2 - x1
            height = y2 - y1
            
            temp = <int>(xHotspot * scaleX * co + yHotspot * scaleY * si)
            yHotspot = <int>(yHotspot * scaleY * co - xHotspot * scaleX * si)
            xHotspot = temp
            
            temp = <int>(actionX * scaleX * co + actionY * scaleY * si)
            actionY = <int>(actionY * scaleY * co - actionX * scaleX * si)
            actionX = temp

            xHotspot = -(x1 - xHotspot)
            yHotspot = -(y1 - yHotspot)
            actionX = -(x1 - actionX)
            actionY = -(y1 - actionY)
            
        actionX -= xHotspot
        actionY -= yHotspot
        self.width = width
        self.height = height
        self.hotspotX = xHotspot
        self.hotspotY = yHotspot
        self.actionX = actionX
        self.actionY = actionY
        (<Instance>self.parent).object_changed()
            
    cdef bint increment_frame(self):
        self.frameIndex += 1
        cdef bint ended = self.wrap()
        if ended:
            self.frameIndex -= 1
            self.animation_ended()
        else:
            self.set_frame(self.frameIndex)
        return ended
    
    cdef bint wrap(self):
        if self.at_last():
            if self.loopsLeft > 0:
                self.loopsLeft -= 1
            if not self.at_end():
                self.frameIndex = self.backTo
        return self.at_end()
    
    cdef bint at_last(self):
        return (self.frameIndex > self.frameCount - 1)
    
    cdef bint at_end(self):
        if self.loopsLeft == -1:
            return False
        else:
            return self.at_last() and not self.loopsLeft
    
    def stop_animation(self):
        self.stopped = True
    
    def start_animation(self):
        self.stopped = False
    
    def force_frame(self, bint on, int frame = 0):
        if on:
            self.set_frame(frame)
            self.frameForced = True
        else:
            self.frameForced = False
    
    def set_walk(self):
        self.currentState = WALKING
        self.update_walking()
    
    def set_bounce(self):
        if self.currentState != BOUNCING:
            self.currentState = BOUNCING
            self.set_animation_index(BOUNCING)
    
    def set_shoot(self):
        if self.currentState != SHOOTING:
            self.currentState = SHOOTING
            self.set_animation_index(SHOOTING)
    
    def set_jump(self):
        if self.currentState != JUMPING:
            self.currentState = JUMPING
            self.set_animation_index(JUMPING)
    
    def set_fall(self):
        if self.currentState != FALLING:
            self.currentState = FALLING
            self.set_animation_index(FALLING)
    
    def set_climb(self):
        if self.currentState != CLIMBING:
            self.currentState = CLIMBING
            self.set_animation_index(CLIMBING)
    
    def set_crouch(self):
        if self.currentState != CROUCH_DOWN:
            self.currentState = CROUCH_DOWN
            self.set_animation_index(CROUCH_DOWN)
        
    def set_uncrouch(self):
        if self.currentState != STAND_UP:
            self.currentState = STAND_UP
            self.set_animation_index(STAND_UP)
    
    cpdef update_animation_speed(self):
        self.update_walking()
        self.update_speed()
    
    cdef void update_walking(self):
        cdef MovementPlayer movement = (<Instance>self.parent).currentMovement
        cdef int movementSpeed
        if self.speedForced:
            movementSpeed = self.forcedSpeed
        else:
            movementSpeed = <int>movement.speed
        if self.currentState == WALKING and self.currentIndex != APPEARING:
            if movementSpeed == 0:
                self.set_animation_index(STOPPED)
            elif movementSpeed >= 75:
                self.set_animation_index(RUNNING)
            else:
                self.set_animation_index(WALKING)
    
    def force_speed(self, bint on, int speed = 0):
        self.speedForced = on
        self.forcedSpeed = speed
        self.update_animation_speed()
    
    cdef void update_speed(self):
        cdef MovementPlayer movement = (<Instance>self.parent).currentMovement
        cdef int deltaSpeed, delta, speed
        cdef int movementSpeed
        if self.speedForced:
            speed = self.forcedSpeed
        else:
            movementSpeed = <int>movement.speed
            direction = self.currentDirection
            delta = direction.maxSpeed - direction.minSpeed
            if delta == 0:
                speed = direction.minSpeed
            else:
                deltaSpeed = movement.maxSpeed - movement.minSpeed
                if deltaSpeed == 0:
                    delta /= 2
                    delta += direction.minSpeed
                    speed = delta
                else:
                    delta *= movementSpeed
                    delta /= deltaSpeed
                    delta += direction.minSpeed
                    if delta > direction.maxSpeed:
                        delta = direction.maxSpeed
                    speed = delta
        self.speed = speed

    cpdef update(self):
        if self.detached or self.stopped or self.frameForced:
            return
        self.counter += <int>(self.speed * self.player.multiplier)
        while self.counter > 100:
            self.counter -= 100
            if not self.at_end():
                self.increment_frame()
    
    def stop(self):
        pass
    
    cdef void animation_ended(self):
        self.animationForced = False
        self.fire_handler('animation_finished', self.currentAnimation)
        if self.currentIndex == DISAPPEARING and self.fade is None:
            fade = self.loader.fadeOut
            if fade:
                self.fade = self.new(get_transition(fade))
                self.fade.initialize(fade, self.fadeout_finished, self.sprite)
            else:
                (<Instance>self.parent).destroy(True)
        elif not self.destroying:
            if self.oldAnimation != -1:
                self.set_animation_index(self.oldAnimation)
    
    def has_animation(self, name):
        for animation in self.animations.items:
            if animation.getName() == name:
                return True
        return False
        
    def has_animation_index(self, index):
        return index in self.animations.loadedAnimations
    
    def get_frame(self):
        return self.currentDirection.frames[self.frameIndex]

    cpdef set_position(self, double x, double y):
        if self.fade:
            self.fade.set_position(x, y)
        self.sprite.xy = x, y
    
    def set_transparency(self, value):
        self.sprite.alpha = value / 128.0
    
    cpdef bint draw(self):
        if self.fade:
            self.fade.draw()
        else:
            self.sprite.render()
    
    cpdef on_detach(self):
        cdef dict storage
        if self.isGlobal:
            storage = self.get_storage()
            storage['alterables'] = (<Instance>self.parent).alterables
    
    def destroy(self):
        if self.fade and self.destroying:
            return False
        fade = self.loader.fadeOut
        if self.fade and self.fade.loader.fadeIn:
            pass
        elif fade:
            self.fade = self.new(get_transition(fade))
            self.fade.initialize(fade, self.fadeout_finished, self.sprite)
            self.destroying = True
            return False
        elif self.has_animation_index(DISAPPEARING):
            self.set_animation_index(DISAPPEARING, True)
            self.loopsLeft = 0
            self.destroying = True
            return False
        return True
    
    def paste(self, collisionType):
        sprite = self.make_sprite(self.make_image(self.currentFrame))
        sprite.xy = self.x, self.y
        sprite.set_scale(self.scaleX, self.scaleY)
        sprite.set_angle(self.angle)
        sprite.alpha = (<Instance>self.parent).transparency / 128.0
        self.player.frame.paste_sprite(sprite, collisionType, 
            (<Instance>self.parent).layerIndex)
        
__all__ = ['Active']