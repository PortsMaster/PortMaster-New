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

from pyglet.image import SolidColorImagePattern, create
from mmfparser.player.objects.common import BackgroundPlayer
from mmfparser.data.chunkloaders.objects import (LINE_SHAPE,
    RECTANGLE_SHAPE, ELLIPSE_SHAPE, NONE_FILL, SOLID_FILL, GRADIENT_FILL,
    MOTIF_FILL, HORIZONTAL_GRADIENT, VERTICAL_GRADIENT, NONE_OBSTACLE,
    LADDER_OBSTACLE, FINE_COLLISION, BOX_COLLISION)

from mmfparser.player.sprite import Sprite
from mmfparser.player.objects.shape import Shape

class QuickBackdrop(BackgroundPlayer):
    shape = None
    obstacleType = None
    def created(self):
        loader = self.loader
        self.width = loader.width
        self.height = loader.height
        self.shape = self.new(Shape)
        self.shape.initialize(self.loader.shape)
        self.obstacleType = obstacleType = loader.obstacleType
        if obstacleType not in (NONE_OBSTACLE, LADDER_OBSTACLE):
            self.player.frame.add_background(self.parent)
        self.draw = self.shape.draw
    
    def set_position(self, x,  y):
        pass
    
    def set_transparency(self, value):
        self.shape.set_transparency(value)

class Backdrop(BackgroundPlayer):
    sprite = None
    obstacleType = None
    def created(self):
        loader = self.loader
        createdImage = self.make_image_handle(loader.image)
        self.width = loader.width
        self.height = loader.height
        self.sprite = sprite = self.make_sprite(createdImage)
        sprite.shape.left = 0
        sprite.shape.top = 0
        self.obstacleType = obstacleType = loader.obstacleType
        
        if obstacleType not in (NONE_OBSTACLE, LADDER_OBSTACLE):
            if loader.collisionMode == FINE_COLLISION:
                self.collision = self.sprite.collision
            self.player.frame.add_background(self.parent)
    
    def set_position(self, x,  y):
        self.sprite.xy = x, y
    
    def set_transparency(self, value):
        self.sprite.alpha = value / 128.0
    
    def draw(self):
        self.sprite.render()

__all__ = ['QuickBackdrop', 'Backdrop']