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

from mmfparser.player.common import PlayerChild
from mmfparser.player.eventdispatcher import EventDispatcher
from mmfparser.player.collision import (Point, collides_python as collides,
    collide_python as collide)
from pyglet.window import mouse
import time

mouse_collision = Point(0, 0)

class Mouse(PlayerChild, EventDispatcher):
    x = 0
    y = 0
    glX = 0
    glY = 0
    wheel = 0
    enabledInstances = None
    over = None
    left = False
    middle = False
    right = False
    lastClick = None
    # mouse cursors
    hand = None

    def initialize(self):
        get_cursor = self.player.window.get_system_mouse_cursor
        self.hand = get_cursor('hand')
        self.enabledInstances = set()
        self.over = []
        self.register_event_type('on_mouse_drag')
        self.register_event_type('on_mouse_enter')
        self.register_event_type('on_mouse_leave')
        self.register_event_type('on_mouse_motion')
        self.register_event_type('on_mouse_press')
        self.register_event_type('on_mouse_release')
        self.register_event_type('on_mouse_scroll')
        self.register_event_type('on_double_click')
        self.player.window.push_handlers(
            on_mouse_drag = self.drag,
            on_mouse_enter = self.enter,
            on_mouse_leave = self.leave,
            on_mouse_motion = self.motion,
            on_mouse_press = self.press,
            on_mouse_release = self.release,
            on_mouse_scroll = self.scroll)
    
    def clear_enabled(self):
        self.enabledInstances = set()
        self.over = []
    
    def enable_mouse(self, objectInfo):
        self.enabledInstances.add(objectInfo)
    
    def get_over(self):
        for instance in self.over[:]:
            if instance.destroyed:
                self.over.remove(instance)
        return self.over
    
    def update_over(self, instance = None):
        collision = mouse_collision
        collision.set_position(self.x, self.y)
        oldOver = self.over
        if instance is not None:
            instanceCollision = instance.objectPlayer.collision
            if collide(instanceCollision, collision):
                if instance not in oldOver:
                    instance.objectPlayer.on_mouse_over()
                    oldOver.append(instance)
            elif instance in oldOver:
                oldOver.remove(instance)
                instance.objectPlayer.on_mouse_left()
            return
        self.over = over = []
        for objectInfo in self.enabledInstances:
            try:
                for instance in self.player.frame.instanceHandles[objectInfo]:
                    objectPlayer = instance.objectPlayer
                    instanceCollision = objectPlayer.collision
                    if collide(instanceCollision, collision):
                        if instance not in oldOver:
                            objectPlayer.on_mouse_over()
                        over.append(instance)
                    elif instance in oldOver:
                        objectPlayer.on_mouse_left()
            except KeyError:
                pass
    
    def in_zone(self, x1, y1, x2, y2):
        return collides(self.x, self.y, self.x + 1, self.y + 1,
            x1, y1, x2, y2)
    
    def drag(self, x, y, dx, dy, *arg):
        dy = -dy
        self.update_position(x, y)
        self.update_over()
        self.dispatch_event('on_mouse_drag', self.x, self.y, dx, dy, *arg)
        for instance in self.get_over():
            instance.objectPlayer.on_mouse_drag(dx, dy, *arg)
    
    def enter(self, x, y):
        self.update_position(x, y)
        self.dispatch_event('on_mouse_enter', self.x, self.y)
    
    def leave(self, x, y):
        self.update_position(x, y)
        self.dispatch_event('on_mouse_leave', self.x, self.y)

    def motion(self, x, y, dx, dy, *arg):
        self.update_position(x, y)
        dy = -dy
        self.update_over()
        self.dispatch_event('on_mouse_motion', self.x, self.y, dx, dy)
        for instance in self.get_over():
            instance.objectPlayer.on_mouse_motion(dx, dy, *arg)
        
    def press(self, x, y, button, modifiers):
        if button == 0:
            button = mouse.LEFT
        double = False
        if button == mouse.LEFT:
            self.left = True
            if self.lastClick is not None and time.time() - self.lastClick < 0.2:
                double = True
            self.lastClick = time.time()
        elif button == mouse.MIDDLE:
            self.middle = True
        elif button == mouse.RIGHT:
            self.right = True
        self.update_position(x, y)
        self.dispatch_event('on_mouse_press', self.x, self.y, button, modifiers)
        if double:
            self.dispatch_event('on_double_click', self.x, self.y, button, 
                modifiers)
        for instance in self.get_over():
            instance.objectPlayer.on_mouse_press(button, modifiers)
            if double:
                instance.objectPlayer.on_double_click(button, modifiers)
            instance.fire_handler('on_mouse_press', button, modifiers)
            if double:
                instance.fire_handler('on_double_click', button, modifiers)
        
    def release(self, x, y, button, modifiers):
        if button == 0:
            button = mouse.LEFT
        if button == mouse.LEFT:
            self.left = False
        elif button == mouse.MIDDLE:
            self.middle = False
        elif button == mouse.RIGHT:
            self.right = False
        self.update_position(x, y)
        self.dispatch_event('on_mouse_release', self.x, self.y, button, 
            modifiers)
        for instance in self.get_over():
            instance.objectPlayer.on_mouse_release(button, modifiers)
            instance.fire_handler('on_mouse_release', button, modifiers)
        
    def scroll(self, x, y, scroll_x, scroll_y):
        self.update_position(x, y)
        self.wheel = scroll_y * 40 * 3
        self.dispatch_event('on_mouse_scroll', self.x, self.y, scroll_x,
            scroll_y)
    
    def update_position(self, x, y):
        self.x, self.y = self.player.get_real_coordinates(x, y)
        self.glX = self.x
        self.glY = self.player.realHeight - self.y
        self.player.update_away()
    
    def on_screen_scroll(self, addX, addY):
        self.x += addX
        self.y += addY
        self.glX += addX
        self.glY -= addY
        self.update_over()
    
    def set_default_cursor(self):
        self.player.window.set_mouse_cursor(None)

    def set_hand_cursor(self):
        self.player.window.set_mouse_cursor(self.hand)