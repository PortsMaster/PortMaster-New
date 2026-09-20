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

from mmfparser.player.objects.common import ObjectPlayer
from pyglet.text import Label

class PlayerLabel(Label):
    strikeOut = False
    
    def _set_opacity(self, value):
        color = self.color[:3] + (value,)
        self.color = color
        if self.get_style('underline') != None:
            self.set_style('underline', (color))
    
    def _get_opacity(self):
        return self.color[-1]
    
    def set_rgb(self, value):
        color = value + (self.color[-1],)
        self.color = color
        if self.get_style('underline') != None:
            self.set_style('underline', (color))
    
    def _get_underline(self):
        return self.get_style('underline') != None
    
    def _set_underline(self, value):
        if value:
            color = self.color
        else:
            color = None
        self.set_style('underline', color)
    
    opacity = property(_get_opacity, _set_opacity)
    underline = property(_get_underline, _set_underline)

def create_label(instance, logFont, text, color, width = None, height = None, 
    multiline = True, alpha = 255, batch = None):
    # XXX support strikeout
    color = color + (alpha,)
    if not logFont:
        return PlayerLabel(text, color = color, height = height, width = width, 
            anchor_y = 'top', multiline = multiline, batch = batch)
    newLabel = PlayerLabel(text, font_name = logFont.faceName, 
        font_size = logFont.getSize(), bold = logFont.isBold(), 
        italic = logFont.italic, color = color, height = height, width = width, 
        anchor_y = 'top', multiline = multiline, batch = batch)
    newLabel.strikeOut = logFont.strikeOut
    if logFont.underline:
        newLabel.underline = True
    return newLabel

class Text(ObjectPlayer):
    value = None
    label = None
    currentParagraph = None
    changed = False
    displayedInstances = None

    def created(self):
        self.displayedInstances = []
        text = self.loader.text
        self.width = text.width
        self.height = 0
        self.set_paragraph(0)
        if self.isGlobal:
            storage = self.get_storage()
            if storage:
                self.value = storage['value']
                self.currentParagraph = storage['paragraph']
                self.changed = True
                return
    
    def set_position(self, x, y):
        self.label.x = x
        self.label.y = y
    
    def set_paragraph(self, value):
        text = self.loader.text
        value = max(0, min(value, len(text.items) - 1))
        if value == self.currentParagraph:
            return
        self.currentParagraph = value
        currentParagraph = text.items[value]
        try:
            font = currentParagraph.getFont(self.player.gameData.fonts)
            logFont = font.value
        except ValueError:
            logFont = None
        if currentParagraph.flags['HorizontalCenter']:
            horizontalAlignment = 'center'
        elif currentParagraph.flags['RightAligned']:
            horizontalAlignment = 'right'
        else:
            horizontalAlignment = 'left'
        if currentParagraph.flags['VerticalCenter']:
            verticalAlignment = 'center'
        elif currentParagraph.flags['BottomAligned']:
            verticalAlignment = 'bottom'
        else:
            verticalAlignment = 'top'
            
        oldLabel = self.label
        self.value = currentParagraph.value
        self.label = self.create_label(logFont, 
            currentParagraph.value.decode('windows-1252'), 
            currentParagraph.color, text.width, text.height)
        self.height = self.label.content_height
        if oldLabel:
            self.set_color(oldLabel.color[:-1])
            self.label.opacity = oldLabel.opacity
            self.set_position(oldLabel.x, oldLabel.y)
            oldLabel.delete()
            
        self.label.set_style('align', horizontalAlignment)
        self.label.content_valign = verticalAlignment
    
    def get_paragraph_text(self, index):
        index = max(0, min(len(self.loader.text.items) - 1, index))
        return self.loader.text.items[index].value
    
    def set_color(self, value):
        self.label.set_rgb(value)
    
    def set_transparency(self, value):
        self.label.opacity = int(value / 128.0 * 255.0)
    
    def set_text(self, value):
        self.currentParagraph = -1
        self.value = value
        self.changed = True
    
    def erase_text(self):
        self.parent.visible = False
        for text in self.displayedInstances:
            text.destroy()
        self.displayedInstances = []
    
    def draw(self):
        # so we're not rebuilding our string all the time >_>
        if self.changed:
            self.label.text = self.value.decode('windows-1252')
            self.height = self.label.content_height
            self.changed = False
        self.label.draw()
    
    def get_font(self):
        # name, size, bold, italic, underline, strikeOut, color
        label = self.label
        return (label.font_name, label.font_size, label.bold, label.italic,
            label.get_style('underline') != None, label.strikeOut, 
            label.color[:-1])
    
    def set_font(self, name = None, size = None, bold = None, italic = None,
                 underline = None, strikeOut = None, color = None):
        label = self.label
        if name is not None:
            self.label.font_name = name
        elif size is not None:
            self.label.font_size = size
        elif bold is not None:
            self.label.bold = bold
        elif italic is not None:
            self.label.italic = italic
        elif underline is not None:
            if underline:
                value = (label.color)
            else:
                value = None
            label.set_style('underline', value)
        elif color is not None:
            label.set_rgb(color)
        elif strikeOut is not None:
            label.strikeOut = strikeOut
    
    def on_detach(self):
        if self.isGlobal:
            storage = self.get_storage()
            storage['value'] = self.value
            storage['paragraph'] = self.currentParagraph
        if self.label is not None:
            self.label.delete()

__all__ = ['Text']
