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

from pyglet.window import mouse

from mmfparser.player.event.conditions.common import (Condition, 
    GeneratedInstances)

from mmfparser.data.chunkloaders.parameters.loaders import (LEFT_CLICK, 
    MIDDLE_CLICK, RIGHT_CLICK)

class KeyPressed(Condition):
    key = None
    pressed = None
    def created(self):
        self.key = self.player.keyboard.convert(
            self.get_parameter(0).key.getValue())
        self.player.window.push_handlers(
            on_key_press = self.on_key_press,
        )
    
    def on_detach(self):
        self.player.window.remove_handlers(
            on_key_press = self.on_key_press,
        )
    
    def on_key_press(self, symbol, modifiers):
        if symbol == self.key:
            self.pressed = self.eventPlayer.loopCount + 1

    def check(self):
        if self.pressed is None:
            return self.negated
        if self.pressed >= self.eventPlayer.loopCount:
            self.pressed = None
            return not self.negated
        return self.negated

class AnyKeyPressed(Condition):
    pressed = False
    def created(self):
        self.player.window.push_handlers(
            on_key_press = self.on_key_press,
        )
    
    def on_detach(self):
        self.player.window.remove_handlers(
            on_key_press = self.on_key_press,
        )
    
    def on_key_press(self, symbol, modifiers):
        if not self.group.container.is_enabled():
            return
        self.pressed = self.eventPlayer.loopCount + 1
        if self.isTriggered:
            self.generate()

    def check(self):
        if self.pressed is None:
            return False
        if self.pressed >= self.eventPlayer.loopCount:
            self.pressed = None
            return True
        return False

class KeyDown(Condition):
    key = None
    def created(self):
        self.key = self.player.keyboard.convert(
            self.get_parameter(0).key.getValue())

    def check(self):
        return self.player.keyboard[self.key] != self.negated

class MouseOnObject(Condition):
    objectInfo = None

    def created(self):
        self.objectInfo = objectInfo = self.get_parameter(0).objectInfo
        for handle in self.resolve_objects(objectInfo):
            self.player.mouse.enable_mouse(handle)
            self.player.frame.add_no_sleep_instance(handle)
    
    def check(self):
        instances = []
        for instance in self.get_instances(self.objectInfo):
            if instance.mouse_over():
                instances.append(instance)
        if not self.negated:
            self.select_instances(instances, self.objectInfo)
        return (len(instances) > 0) != self.negated

class ObjectClicked(Condition):
    instances = None
    click = None
    def created(self):
        parameter = self.get_parameter(0)
        self.click = parameter.click
        self.objectInfo = self.get_parameter(1).objectInfo
        self.player.mouse.enable_mouse(self.objectInfo)
        for handle in self.resolve_objects(self.objectInfo):
            self.player.mouse.enable_mouse(handle)
            if parameter.double:
                self.player.frame.add_handlers(handle,
                    on_double_click = self.on_mouse_press)
            else:
                self.player.frame.add_handlers(handle,
                    on_mouse_press = self.on_mouse_press)
            self.player.frame.add_no_sleep_instance(handle)
        self.instances = GeneratedInstances(self)
    
    def on_mouse_press(self, instance, button, modifiers):
        click = self.click
        if click == LEFT_CLICK and button != mouse.LEFT:
            return
        elif click == MIDDLE_CLICK and button != mouse.MIDDLE:
            return
        elif click == RIGHT_CLICK and button != mouse.RIGHT:
            return
        self.instances.add_instance(instance)
        if self.isTriggered:
            self.generate()
    
    def check(self):
        return self.instances.check(self.objectInfo)

class MouseInZone(Condition):
    zone = None
    def created(self):
        zone = self.get_parameter(0)
        self.zone = (zone.x1, zone.y1, zone.x2, zone.y2)
    
    def check(self):
        return self.player.mouse.in_zone(*self.zone) != self.negated

class MouseClicked(Condition):
    click = None
    value = None
    def created(self):
        parameter = self.get_parameter(0)
        self.click = parameter.click
        if parameter.double:
            self.player.mouse.push_handlers(
                on_double_click = self.on_mouse_press)
        else:
            self.player.mouse.push_handlers(
                on_mouse_press = self.on_mouse_press)
    
    def on_mouse_press(self, x, y, button, modifiers):
        click = self.click
        if click == LEFT_CLICK and button != mouse.LEFT:
            return
        elif click == MIDDLE_CLICK and button != mouse.MIDDLE:
            return
        elif click == RIGHT_CLICK and button != mouse.RIGHT:
            return
        if self.isTriggered:
            self.generate()
        else:
            self.value = self.player.eventPlayer.loopCount + 1
    
    def check(self):
        if self.isTriggered:
            return True
        return self.value == self.player.eventPlayer.loopCount
    
    def on_detach(self):
        if self.get_parameter(0).double:
            self.player.mouse.remove_handlers(
                on_double_click = self.on_mouse_press
            )
        else:
            self.player.mouse.remove_handlers(
                on_mouse_press = self.on_mouse_press
            )

class MouseWheelUp(Condition):
    def created(self):
        self.player.mouse.push_handlers(
            on_mouse_scroll = self.on_mouse_scroll
        )
    
    def on_mouse_scroll(self, x, y, scroll_x, scroll_y):
        if scroll_y > 0:
            self.generate()
    
    def check(self):
        return self.isTriggered
    
    def on_detach(self):
        self.player.mouse.remove_handlers(
            on_mouse_scroll = self.on_mouse_scroll
        )

class MouseWheelDown(Condition):
    def created(self):
        self.player.mouse.push_handlers(
            on_mouse_scroll = self.on_mouse_scroll
        )
    
    def on_mouse_scroll(self, x, y, scroll_x, scroll_y):
        if scroll_y < 0:
            self.generate()
    
    def check(self):
        return self.isTriggered
    
    def on_detach(self):
        self.player.mouse.remove_handlers(
            on_mouse_scroll = self.on_mouse_scroll
        )

class MouseVisible(Condition):
    def check(self):
        return self.player.window.get_mouse_visible() != self.negated

class MouseClickedInZone(Condition):
    click = None
    zone = None
    value = None
    def created(self):
        parameter = self.get_parameter(0)
        self.click = parameter.click
        if parameter.double:
            self.player.mouse.push_handlers(
                on_double_click = self.on_mouse_press)
        else:
            self.player.mouse.push_handlers(
                on_mouse_press = self.on_mouse_press)
        zone = self.get_parameter(1)
        self.zone = (zone.x1, zone.y1, zone.x2, zone.y2)
    
    def on_mouse_press(self, x, y, button, modifiers):
        click = self.click
        if click == LEFT_CLICK and button != mouse.LEFT:
            return
        elif click == MIDDLE_CLICK and button != mouse.MIDDLE:
            return
        elif click == RIGHT_CLICK and button != mouse.RIGHT:
            return
        if not self.player.mouse.in_zone(*self.zone):
            return
        if self.isTriggered:
            self.generate()
        else:
            self.value = self.player.eventPlayer.loopCount + 1
    
    def check(self):
        if self.isTriggered:
            return True
        return self.value == self.player.eventPlayer.loopCount
    
    def on_detach(self):
        if self.get_parameter(0).double:
            self.player.mouse.remove_handlers(
                on_double_click = self.on_mouse_press
            )
        else:
            self.player.mouse.remove_handlers(
                on_mouse_press = self.on_mouse_press
            )

class WhileMousePressed(Condition):
    button = None
    def created(self):
        self.button = self.get_parameter(0).key.getValue()
    
    def check(self):
        button = self.button
        if button == 1:
            value = self.player.mouse.left
        elif button == 4:
            value = self.player.mouse.middle
        elif button == 2:
            value = self.player.mouse.right
        return value != self.negated