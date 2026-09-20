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
from mmfparser.player.sprite import Sprite
import pyglet.clock
from mmfparser.player.sprite import ImageData
from pyglet import gl
from pyglet.image import Texture

import time

class TransitionPlayer(PlayerChild):
    startTime = None
    endTime = None
    loader = None
    source = None
    destination = None
    frame = None
    done = False

    def initialize(self, loader, callback, sprite = None):
        self.loader = loader
        if sprite is None:
            self.frame = True
            self.currentTexture = self.player.fbo.texture
            self.player.fbo.texture = None
        else:
            self.frame = False
        self.callback = callback
        if sprite is not None:
            self.set_image(sprite)
            self.created()
    
    def set_time(self):
        loader = self.loader
        if self.frame:
            startTime = time.time()
        else:
            startTime = self.player.time
        self.startTime = startTime
        self.endTime = self.startTime + loader.duration / 1000.0
    
    def set_frame_image(self):
        player = self.player
        loader = self.loader
        frame = self.parent
        fbo = player.fbo
        old = self.currentTexture or fbo.texture
        # we don't actually need this, but we need to keep it around so it
        # isn't GC'ed
        save_texture = fbo.texture
        fbo.texture = None
        if not loader.fadeIn or loader.flags['Color']:
            r, g, b = loader.color
            src1 = pyglet.image.SolidColorImagePattern(
                (r, g, b, 255)).create_image(player.realWidth, 
                player.realHeight).get_texture()
        else:
            src1 = old
        player.draw(False)
        src2 = fbo.texture
        if loader.fadeIn:
            source = src1
            destination = src2
        else:
            source = src2
            destination = src1
        fbo.texture = old
        fbo.size = None
        self.source = Sprite(source)
        self.destination = Sprite(destination)
    
    def set_image(self, src1):
        loader = self.loader
        if False:#loader.flags['Color']:
            # this does not work yet
            r, g, b = loader.color
            src2 = ImageData(destination.width, destination.height)
            alphaMask = destination.texture.get_image_data().get_data('A', 
                destination.width)
            src2.set_data('R', destination.width, [r if item else 0
                for item in alphaMask])
            src2.set_data('G', destination.width, [g if item else 0
                for item in alphaMask])
            src2.set_data('B', destination.width, [b if item else 0
                for item in alphaMask])
            src2.set_data('A', destination.width, alphaMask)
            src2 = Sprite(src2)
        else:
            src2 = None
        if loader.fadeIn:
            source = src2
            destination = src1
        else:
            source = src1
            destination = src2
        self.source = source
        self.destination = destination
    
    def set_position(self, x, y):
        if self.source:
            self.source.xy = x, y
        if self.destination:
            self.destination.xy = x, y
    
    def created(self):
        pass
    
    def draw(self):
        if self.source is None and self.destination is None:
            # assume this transition is drawing for the frame
            self.set_frame_image()
            self.created()
        if self.startTime is None:
            self.set_time()
        if self.frame:
            currentTime = time.time()
        else:
            currentTime = self.player.time
        value = (currentTime - self.startTime) / (self.endTime - self.startTime)
        if self.frame:
            gl.glPushMatrix()
            gl.glLoadIdentity()
        self.draw_transition(value)
        if self.frame:
            gl.glPopMatrix()
        if value >= 1.0:
            pyglet.clock.schedule_once(self.finish, 0)
    
    def draw_transition(self, percentage_done):
        raise NotImplementedError('draw_transition() not implemented')
    
    def finish(self, dt):
        self.callback()