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

import string

from mmfparser.player.objects.common import ObjectPlayer
from mmfparser.data.chunkloaders.objects import (HIDDEN, NUMBERS, 
    VERTICAL_BAR, HORIZONTAL_BAR, ANIMATION, TEXT_COUNTER, VERTICAL_GRADIENT,
    HORIZONTAL_GRADIENT)

from mmfparser.player.collision import BoundingBox

from mmfparser.player.sprite import Sprite
from mmfparser.player.objects.shape import Shape

from mmfparser.data.chunkloaders.objectinfo import LIVES

# XXX implement new counter features

class Counter(ObjectPlayer):
    value = None
    maximum = None
    minimum = None

    displayType = None
    
    # Number
    imageList = None
    
    # for Bar
    shape = None
    countInverse = False
    
    # for drawing
    sprite = None
    
    # for Text
    label = None
    
    changed = False
    firstSet = True
    
    def created(self):
        counter = self.loader.counter
        counters = self.loader.counters
        if counters:
            height = self.height = counters.height
            width = self.width = counters.width
            displayType = self.displayType = counters.displayType

            if displayType in (VERTICAL_BAR, HORIZONTAL_BAR):
                self.countInverse = countInverse = counters.inverse
                self.shape = shape = self.new(Shape)
                shape.initialize(counters.shape, inverseGradient = countInverse)

            elif displayType == TEXT_COUNTER:
                font = counters.getFont(self.player.gameData.fonts)
                self.label = self.create_label(font.value, '', 
                    counters.shape.color1, width, height, multiline = False)
                self.label.anchor_y = 'bottom'
                self.label.anchor_x = 'right'
                self.label.set_style('align', 'right')
                self.label.content_valign = 'center'
        else:
            self.displayType = HIDDEN

        if counter:
            value = counter.initial
            maximum = counter.maximum
            minimum = counter.minimum
            if self.isGlobal:
                storage = self.get_storage()
                if storage:
                    value = storage['value']
                    maximum = storage['maximum']
                    minimum = storage['minimum']
            self.maximum = maximum
            self.minimum = minimum
            self.set(value)
            self.update()

        self.set_drawer()
    
    def set(self, value):
        if self.loader.counter:
            value = min(max(value, self.minimum), self.maximum)
        
        self.value = value
        self.update()
    
    def set_color(self, color1 = None, color2 = None):
        if self.displayType not in (VERTICAL_BAR, HORIZONTAL_BAR):
            return
        oldShape = self.shape
        self.shape = shape = self.new(Shape)
        shape.initialize(oldShape.loader,
            oldShape.inverse_gradient, color1 or oldShape.color1, 
            color2 or oldShape.color2)
        self.update()
    
    def update(self):
        value = self.value
        self.changed = False
        displayType = self.displayType
        if displayType == HIDDEN:
            return
        width = self.width
        height = self.height
        if displayType == HORIZONTAL_BAR:
            try:
                pixelCount = width - int(width * (self.value - self.minimum) / 
                    (self.maximum - self.minimum))
            except ZeroDivisionError:
                pixelCount = 0
            if self.countInverse: # count from right
                self.shape.set_offset(0, 0, pixelCount, 0)
            else: # count from left
                self.shape.set_offset(0, 0, 0, pixelCount)

        elif displayType == VERTICAL_BAR:
            pixelCount = height - int(height * (self.value - self.minimum) / 
                (self.maximum - self.minimum))
            if self.countInverse: # count up
                self.shape.set_offset(pixelCount, 0, 0, 0)
            else: # count down
                self.shape.set_offset(0, pixelCount, 0, 0)
        elif displayType == NUMBERS:
            imageList = [self.make_image(self.loader.counters.getImage(
                character, self.player.gameData.images)) 
                for character in self.as_text()]
            self.height = max([image.height for image in imageList])
            self.width = sum([image.width for image in imageList])
            self.hotspotX = self.width
            self.hotspotY = self.height

            self.sprites = sprites = []
            for image in imageList:
                newSprite = self.make_sprite(image)
                newSprite.shape.left = 0
                newSprite.shape.top = 0
                sprites.append(newSprite)
            self.parent.object_changed()
            self.collision = BoundingBox(self)

        elif displayType == ANIMATION:
            frames = self.loader.counters.frames
            if self.loader.counter:
                imageIndex = ((self.value - self.minimum) * (len(frames) - 1) / 
                    (self.maximum - self.minimum))
            else:
                imageIndex = 0
            currentImage = self.make_image_handle(
                frames[imageIndex])
            if self.parent.objectType == LIVES:
                self.sprites = sprites = []
                x = self.x or 0
                y = self.y or 0
                for blitX in xrange(0, int(currentImage.width * value), 
                                    currentImage.width):
                    newSprite = self.make_sprite(currentImage)
                    newSprite.shape.left = 0
                    newSprite.shape.top = 0
                    newSprite.x = x + blitX
                    newSprite.y = y
                    sprites.append(newSprite)
            else:
                # assume it's not
                self.sprites = [self.make_sprite(currentImage)]
        elif displayType == TEXT_COUNTER:
            self.label.text = self.as_text()

        # if we have coordinates to set yet
        if self.x and self.y:
            self.set_position(self.x, self.y)
        
        self.set_transparency(self.parent.transparency)
        
        if width != self.width or height != self.height:
            self.collision.resize(width, height)
    
    def as_text(self):
        counters = self.loader.counters
        if isinstance(self.value, float):
            if not counters.formatFloat:
                value = self.value
                if value.is_integer():
                    value = int(value)
                return str(value)
            value = self.value
            if counters.useDecimals:
                value = ('%%.%sf' % (counters.decimals)) % value
            else:
                value = ('%%.%sg' % (counters.floatDigits)) % value
            if counters.addNulls and not value.count('e'):
                count = (counters.floatDigits + value.count('-') 
                    + value.count('+') + value.count('.'))
                value = value.zfill(count)
            return value
        else:
            value = str(self.value)
            digits = counters.integerDigits
            if digits != 0:
                value = value.zfill(digits)
                if len(value) > digits:
                    value = value[len(value) - digits:]
            return value
    
    def set_position(self, x, y):
        if self.displayType in (VERTICAL_BAR, HORIZONTAL_BAR):
            self.x, self.y = x, y
        elif self.displayType == ANIMATION:
            sprites = self.sprites
            currentX = x
            for sprite in sprites:
                sprite.x = currentX
                sprite.y = y
                currentX += sprite.width
        elif self.displayType == TEXT_COUNTER:
            self.label.x = x
            self.label.y = y
        elif self.displayType == NUMBERS:
            x = currentX = self.x
            y = self.y
            height = self.height
            for sprite in reversed(self.sprites): # from end to start
                currentX -= sprite.width
                sprite.x = currentX
                sprite.y = y + height
    
    def set_transparency(self, value):
        value = value / 128.0
        if self.displayType in (VERTICAL_BAR, HORIZONTAL_BAR):
            pass
            #self.sprite.opacity = value
        elif self.displayType in (ANIMATION, NUMBERS):
            for sprite in self.sprites:
                sprite.alpha = value
        elif self.displayType == TEXT_COUNTER:
            self.label.opacity = int(value * 255)
    
    def set_drawer(self):
        displayType = self.displayType
        if displayType in (VERTICAL_BAR, HORIZONTAL_BAR):
            self.on_draw = self.draw_bar
        elif self.displayType in (ANIMATION, NUMBERS):
            self.on_draw = self.draw_images
        elif self.displayType == TEXT_COUNTER:
            self.on_draw = self.draw_text
        else:
            self.on_draw = self.draw_nothing
                
    def draw_nothing(self):
        pass
        
    def draw_bar(self):
        self.shape.draw()
    
    def draw_images(self):
        for item in self.sprites:
            item.render()
    
    def draw_text(self):
        self.label.draw()
    
    def on_draw(self):
        pass
    
    def draw(self):
        if self.changed:
            self.update()
        self.on_draw()
    
    def on_detach(self):
        if self.isGlobal:
            storage = self.get_storage()
            storage['value'] = self.value
            storage['maximum'] = self.maximum
            storage['minimum'] = self.minimum
        
__all__ = ['Counter']