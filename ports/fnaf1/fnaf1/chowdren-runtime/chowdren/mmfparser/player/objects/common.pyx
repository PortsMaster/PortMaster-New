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

import weakref
from mmfparser.player.sprite import ObjectSprite
from mmfparser.player.collision cimport BoundingBox, CollisionBase
from mmfparser.player.instance cimport Instance

from mmfparser.bytereader import ByteReader

generated_handles = {}
generated_images = {}

cdef object make_image = None
cdef inline void initialize():
    if make_image is not None:
        return
    global make_image
    from mmfparser.player.common import make_image

cdef class BaseObject(PlayerChild):
    property movement:
        def __get__(self):
            return (<Instance>self.parent).currentMovement

    cdef void initialize(self, loader, frame):
        self.loader = loader
        self.frame = frame
        self.created()
        if self.collision is None:
            self.collision = BoundingBox(self)
    
    cpdef update(self):
        return
    
    def get_storage(self):
        storage = self.player.extensionStorage
        key = (self.__class__, (<Instance>self.parent).objectInfo.name)
        if key not in storage:
            storage[key] = {}
        return storage[key]
    
    def fire_handler(self, *arg, **kw):
        return (<Instance>self.parent).fire_handler(*arg, **kw)

    def make_image(self, image, *arg, **kw):
        initialize()
        try:
            return generated_images[image]
        except KeyError:
            generated = make_image(image, *arg, 
                images = self.player.gameData.images, frame = self.frame, **kw)
            try:
                image.unload()
            except AttributeError:
                pass
            generated_images[image] = generated
            return generated

    def get_image(self, handle):
        return self.player.gameData.images.fromHandle(handle)

    def make_image_handle(self, handle):
        try:
            return generated_handles[handle]
        except KeyError:
            generated = self.make_image(self.get_image(handle))
            generated_handles[handle] = generated
            return generated
    
    def make_sprite(self, image):
        return ObjectSprite(image, self)
        
    def create_label(self, *arg, **kw):
        return create_label(self.parent, *arg, **kw)

    def created(self, data = None):
        pass
    
    cpdef bint draw(self):
        pass
    
    def is_background(self):
        return False
    
    cpdef set_position(self, double x, double y):
        pass

    def set_direction(self, direction, fromMovement = False):
        pass
    
    def get_action_point(self):
        x = (<Instance>self.parent).x + self.actionX
        y = (<Instance>self.parent).y + self.actionY
        return x, y
    
    def set_transparency(self, value):
        pass
    
    # mouse stuff
    
    def enable_mouse(self):
        self.player.mouse.enable_mouse((<Instance>self.parent).handle)
    
    def on_mouse_over(self):
        pass
        
    def on_mouse_motion(self, dx, dy):
        pass
    
    def on_mouse_left(self):
        pass
    
    def on_mouse_press(self, button, modifiers):
        pass
        
    def on_double_click(self, button, modifiers):
        pass
        
    def on_mouse_release(self, button, modifiers):
        pass
        
    def on_mouse_drag(self, dx, dy, button, modifiers):
        pass

    def destroy(self):
        return True

cdef class BackgroundPlayer(BaseObject):
    pass

cdef class ObjectPlayer(BaseObject):
    cdef void initialize(self, loader, frame):
        self.loader = loader
        self.frame = frame
        cdef Instance parent = self.parent
        if loader.flags['DoNotCreateAtStart'] and self.player.frame.startingUp:
            parent.destroyed = True
            return
        if not loader.newFlags['VisibleAtStart']:
            parent.set_visible(False)
            # print 'not visible'
        self.isGlobal = parent.objectInfo.flags['Global']
        if loader.extensionData:
            # assume we're an extension!
            self.created(ByteReader(loader.extensionData))
        else:
            self.created()
        if self.collision is None:
            self.collision = BoundingBox(self)
    
    def initialize_object(self, loader, frame):
        self.initialize(loader, frame)
    
    def stop(self):
        pass

from mmfparser.player.objects.text import create_label