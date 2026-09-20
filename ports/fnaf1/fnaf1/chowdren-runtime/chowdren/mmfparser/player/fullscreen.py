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

from pyglet.gl import (glTexParameteri, GL_TEXTURE_MAG_FILTER, GL_NEAREST,
    GL_TEXTURE_MIN_FILTER, glViewport, glClear, GL_COLOR_BUFFER_BIT, glColor4f,
    glMatrixMode, GL_PROJECTION, glLoadIdentity, glOrtho, GL_MODELVIEW,
    glBindTexture, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_TEXTURE_WRAP_T, 
    GL_CLAMP_TO_EDGE)
    
import pyglet

class FixedResolutionViewport(object):
    width = height = None
    def __init__(self, player, keep_ratio):
        self.fbo = player.fbo
        self.window = player.window
        self.keep_ratio = keep_ratio
    
    def set_size(self, width, height):
        if self.width == width and self.height == height:
            return
        self.width = width
        self.height = height

    def render(self, texture):
        x, y, scale_width, scale_height = self.get_scale()
        glLoadIdentity()
        if True: # oldschool?
            glBindTexture(texture.target, texture.id)
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
            # glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE)
            # glTexParameteri(texture.target, 
                # GL_TEXTURE_MAG_FILTER, GL_NEAREST)
            # glTexParameteri(texture.target, 
                # GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        texture.blit(x, y, width=scale_width, height=scale_height)
    
    def get_scale(self):
        if self.keep_ratio:
            aspect_width = self.window.width / float(self.width)
            aspect_height = self.window.height / float(self.height)
            if aspect_width > aspect_height:
                scale_width = aspect_height * self.width
                scale_height = aspect_height * self.height
            else:
                scale_width = aspect_width * self.width
                scale_height = aspect_width * self.height
            x = (self.window.width - scale_width) / 2
            y = (self.window.height - scale_height) / 2
        else:
            scale_width = self.window.width
            scale_height = self.window.height
            x = y = 0
        return x, y, scale_width, scale_height
    
    def convert_coordinates(self, x, y):
        offsetX, offsetY, scale_width, scale_height = self.get_scale()
        x -= offsetX
        y -= offsetY
        x *= (float(self.width) / scale_width)
        y *= (float(self.height) / scale_height)
        return x, y