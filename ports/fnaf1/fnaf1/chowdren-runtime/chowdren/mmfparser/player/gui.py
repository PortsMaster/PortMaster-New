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
from mmfparser.player.collision import collides_python as collides
import math
import pyglet.font

from pyglet.gl import (glBegin, GL_QUADS, glEnd, glVertex2f, glColor4ub,
    glDisable, glPushMatrix, glPopMatrix, GL_TEXTURE_2D, glTranslatef,
    GL_TRIANGLES, glPushAttrib, GL_SCISSOR_BIT, glScissor, glPopAttrib,
    glEnable, GL_SCISSOR_TEST)

BORDER_COLOR = (0, 0, 0)

BORDER_COLOR_3D_1 = (0x69, 0x87, 0x90)
BORDER_COLOR_3D_2 = (255, 255, 255)
BORDER_COLOR_3D_3 = (0x69, 0x69, 0x69)

SCROLL_BAR_COLOR = (204, 206, 217)
SCROLL_BAR_BORDER = (106, 107, 110)
SCROLL_BAR_BUTTON = (228, 228, 228)
SCROLL_BAR_POINTER = (75, 78, 82, 255)
SCROLL_BAR_OVER = (181, 193, 204)
SCROLL_BAR_PRESSED = (167, 187, 233)

LIST_YPAD = 4
LIST_XPAD = 2

def draw_rectangle(x1, y1, x2, y2, color):
    if color is None:
        return
    glColor4ub(*(color + (255,)))
    glBegin(GL_QUADS)
    glVertex2f(x1, y1)
    glVertex2f(x2, y1)
    glVertex2f(x2, y2)
    glVertex2f(x1, y2)
    glEnd()

class VerticalScrollBar(PlayerChild):
    width = 19
    buttonHeight = 18
    scrollHeight = None
    scrollSize = 1
    max = 1
    position = 0
    over = False
    pressed = False
    over_down = over_up = False
    single = None
    startY = None
    startPosition = None
    enabled = True
    
    def initialize(self, x, y, width, height):
        self.x = x
        self.y = y
        self.set_size(width, height)
        self.player.mouse.push_handlers(
            on_mouse_release = self.on_mouse_release)

    def on_mouse_scroll(self, x, y, scroll_x, scroll_y):
        if not self.enabled:
            return
        buttonSize = self.scrollHeight * self.scrollSize
        self.set_y(self.position + 1 / 5.0 * -scroll_y)
    
    def draw(self):
        glDisable(GL_TEXTURE_2D)
        glPushMatrix()
        glTranslatef(self.x, self.y - self.height, 0)
        draw_rectangle(0, 0, self.width, self.height, SCROLL_BAR_BORDER)
        draw_rectangle(1, 1, self.width-1, self.height-1, SCROLL_BAR_COLOR)
        self.draw_button(0, self.height - self.buttonHeight, False, 
            self.over_up)
        self.draw_button(0, 0, True, self.over_down)
        buttonSize = self.scrollHeight * self.scrollSize
        y = (self.height - self.buttonHeight - 
            (self.position * (self.scrollHeight - buttonSize)) - buttonSize)
        if self.pressed and self.over:
            color = SCROLL_BAR_PRESSED
        elif self.over:
            color = SCROLL_BAR_OVER
        else:
            color = SCROLL_BAR_BORDER
        draw_rectangle(0, y, self.width, y + buttonSize, color)
        draw_rectangle(2, y + 2, self.width - 2, y + buttonSize - 2, 
            SCROLL_BAR_BUTTON)
        glPopMatrix()
    
    def set_scale(self, max, scrollSize, single):
        self.max = max
        self.scrollSize = scrollSize
        self.single = single
    
    def draw_button(self, x, y, point_down, over):
        if over and self.pressed:
            border = SCROLL_BAR_PRESSED
        elif over:
            border = SCROLL_BAR_OVER
        else:
            border = SCROLL_BAR_BORDER
        draw_rectangle(x, y, x + self.width, y + self.buttonHeight, 
            border)
        draw_rectangle(x + 1, y + 1, x + self.width - 1, 
            y + self.buttonHeight - 1, SCROLL_BAR_BUTTON)
        glBegin(GL_TRIANGLES)
        glColor4ub(*SCROLL_BAR_POINTER)
        singleX = self.width / 3.0
        upperX = self.width / 2.0
        singleY = self.buttonHeight / 3.0
        if point_down:
            y -= 1
            glVertex2f(singleX + x, singleY * 2 + y)
            glVertex2f(upperX + x, singleY + y)
            glVertex2f(singleX * 2 + x, singleY * 2 + y)

        else:
            glVertex2f(singleX + x, singleY + y)
            glVertex2f(upperX + x, singleY * 2 + y)
            glVertex2f(singleX * 2 + x, singleY + y)
        glEnd()
    
    def on_mouse_motion(self, dx, dy):
        if not self.enabled:
            return
        self.update_over()
    
    def update_over(self):
        self.over = over = self.is_over()
        self.over_up = self.over_button(0, self.height - self.buttonHeight)
        self.over_down = self.over_button(0, 0)
        
    def is_over(self):
        buttonSize = self.scrollHeight * self.scrollSize
        y = (self.height - self.buttonHeight - 
            (self.position * (self.scrollHeight - buttonSize)) - buttonSize)
        x1 = self.x
        y1 = y + self.y - self.height
        x2 = self.width + self.x
        y2 = y + buttonSize + self.y - self.height
        mouse = self.player.mouse
        glX, glY = mouse.glX, mouse.glY
        return collides(glX, glY, glX, glY, x1, y1, x2, y2)
    
    def over_button(self, x, y):
        mouse = self.player.mouse
        glX, glY = mouse.glX, mouse.glY
        x1 = x + self.x
        y1 = y + self.y - self.height
        x2 = x + self.width + self.x
        y2 = y + self.buttonHeight + self.y - self.height
        return collides(glX, glY, glX, glY, x1, y1, x2, y2)
    
    def on_mouse_press(self, button, modifiers):
        if not self.enabled:
            return
        self.pressed = True
        if self.over:
            self.startY = self.player.mouse.glY
            self.startPosition = self.position
        
    def set_y(self, value):
        if self.scrollSize == 1:
            return
        self.position = max(0, min(1, value))
        self.parent.on_scroll(self.position * self.max)
        
    def on_mouse_release(self, x, y, button, modifiers):
        if not self.enabled:
            return
        self.pressed = False
        if self.over_down:
            value = self.single
        elif self.over_up:
            value = -self.single
        if self.over_down or self.over_up:
            self.set_y(self.position + value)
        self.update_over()
    
    def on_mouse_drag(self, dx, dy, button, modifiers):
        if not self.enabled:
            return
        if self.over:
            buttonSize = self.scrollHeight * self.scrollSize
            value = self.startY - self.player.mouse.glY
            try:
                delta = float(value) / ((self.scrollHeight - buttonSize))
            except ZeroDivisionError:
                return
            self.set_y(delta + self.startPosition)
    
    def set_position(self, x, y):
        self.x, self.y = x, y
    
    def set_enable(self, value):
        self.enabled = value
        if not self.enabled:
            self.over = self.over_up = self.over_down = False
            self.pressed = False
    
    def set_size(self, width = None, height = None):
        if width is not None:
            self.width = width
        if height is not None:
            self.height = height
            self.scrollHeight = height - self.buttonHeight * 2
    
    def on_detach(self):
        self.player.mouse.remove_handlers(
            on_mouse_release = self.on_mouse_release)

class Line(PlayerChild):
    text = None
    label = None
    data = 0
    updated = False
    def initialize(self, text):
        self.text = text
    
    def set_text(self):
        self.text = text
        self.updated = False
    
    def get_label(self):
        if self.label is None:
            text = self.text
            label = self.parent.parent.create_label(self.parent.font, text, 
                self.parent.fontColor, self.parent.listWidth, 0)
            if text == '':
                label.text = ' '
                content_height = label.content_height
                label.text = ''
                label.content_height = content_height
            label.content_valign = 'center'
            label.height = label.content_height + LIST_YPAD
            label.x = self.parent.borderPad + LIST_XPAD
            self.label = label
            return label
        elif not self.updated:
            self.label.text = self.text
            return self.label
    
    def on_detach(self):
        self.text = self.label = None
    
    @property
    def content_height(self):
        if self.label is None:
            return 0
        return self.label.content_height
            
class List(PlayerChild):
    x = 20
    y = 50
    width = None
    height = None
    listWidth = listHeight = None
    sort = border = systemColor = autoScroll = border3d = False
    backColor = None
    listObject = None
    scrollBar = None
    borderPad = None
    fontColor = None
    font = None
    itemHeight = None
    
    over = None
    selected = None
    lines = None
    yOffset = 0
    overList = False
    pressed = False
    enabled = True
    lastIndex = 0
    updateDraw = False
    
    def initialize(self, x, y, width, height, scrollBar = False, sort = False, 
                   border = False, systemColor = False, autoScroll = False, 
                   border3d = False, backColor = (255, 255, 255), 
                   fontColor = (0, 0, 0), font = None):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.sort = sort
        self.border = border
        self.systemColor = systemColor
        self.autoScroll = autoScroll
        self.border3d = border3d
        self.fontColor = fontColor
        self.backColor = backColor
        self.font = font
        self.lineData = []
        
        pad = 0
        if self.border:
            if self.border3d:
                pad = 3
            else:
                pad = 1
        
        self.borderPad = pad
        
        self.set_size(width, height)
        
        if scrollBar:
            self.scrollBar = self.new(VerticalScrollBar)
            self.scrollBar.initialize(
                x + width - VerticalScrollBar.width - pad, y - pad,
                VerticalScrollBar.width, height - pad * 2)

        self.lines = []
        
        self.player.mouse.push_handlers(
            on_mouse_scroll = self.on_mouse_scroll)
        
        pyglet.font.load()
    
    def __len__(self):
        return len(self.lines)
    
    def insert(self, index, text):
        line = self.new(Line)
        line.initialize(text)
        self.lines.insert(index, line)
        self.update_lines()
        self.lastIndex = index
    
    def get_data(self, index):
        try:
            return self.lines[index].data
        except IndexError:
            return 0
    
    def set_data(self, index, value):
        try:
            self.lines[index].data = value
        except IndexError:
            pass
    
    def remove(self, text):
        for item in self.lines[:]:
            if item.text == text:
                item.detach()
                self.lines.remove(item)
                return
        self.update_lines()
    
    def append(self, text):
        self.insert(len(self), text)
    
    def extend(self, lines):
        for line in lines:
            self.append(line)
        self.update_lines()
    
    def pop(self, index):
        try:
            item = self.lines.pop(index)
            item.detach()
            self.update_lines()
        except IndexError:
            return
    
    def replace(self, index, value):
        try:
            self.lines[index].set_text(value)
            self.update_lines()
        except IndexError:
            return
    
    def reset(self):
        for line in self.lines:
            line.detach()
        self.lines = []
        self.update_lines()
    
    def get_line(self, index):
        try:
            return self.lines[index].text.encode('windows-1252')
        except IndexError:
            return ''
    
    def get_lines(self):
        lines = []
        for line in self.lines:
            lines.append(line.text.encode('windows-1252'))
        return lines
    
    def scroll_to_line(self, value):
        self.selected = value
        if self.lines:
            content_height = self.lines[0].content_height
        else:   
            content_height = 0
        yOffset = (content_height + LIST_YPAD) * value
        if self.scrollBar is None:
            self.yOffset = yOffset
        else:
            max = self.scrollBar.max
            position = float(yOffset) / max
            self.scrollBar.set_y(position)
            return
    
    def update_lines(self):
        self.updateDraw = True
    
    def update_scrollbar(self):
        if self.scrollBar is not None:
            if self.lines:
                content_height = self.lines[0].content_height
            else:   
                content_height = 0
            total = (content_height + LIST_YPAD) * len(self.lines)
            try:
                scale = min(1, self.listHeight / float(total))
            except ZeroDivisionError:
                scale = 1
            try:
                single = 1.0 / len(self.lines) / scale
            except ZeroDivisionError:
                single = 0
            self.scrollBar.set_scale(total - self.listHeight, scale, single)
    
    def on_scroll(self, value):
        self.yOffset = value
        
    def on_mouse_over(self):
        if not self.enabled:
            return
        self.overList = True
    
    def on_mouse_scroll(self, x, y, scroll_x, scroll_y):
        if not self.enabled:
            return
        if self.overList and self.scrollBar is not None:
            self.scrollBar.on_mouse_scroll(x, y, scroll_x, scroll_y)
        self.update_over()
        self.update_pressed()
        
    def on_mouse_motion(self, dx, dy):
        if not self.enabled:
            return
        if self.scrollBar is not None:
            self.scrollBar.on_mouse_motion(dx, dy)
            if self.scrollBar.over:
                return
        self.update_over()
    
    def update_over(self):
        mouse = self.player.mouse
        glX, glY = mouse.glX, mouse.glY
        over = None
        for index, item in enumerate(self.lines):
            if item.label is None:
                continue
            line = item.label
            x1 = self.borderPad + self.x
            y1 = line.y - line.height + self.y - self.height + self.yOffset
            x2 = self.borderPad + line.width + self.x
            y2 = line.y + self.y - self.height + self.yOffset
            if collides(glX, glY, glX, glY, x1, y1, x2, y2):
                over = index
                break
        self.over = over
    
    def update_pressed(self):
        if self.over is None or not self.pressed:
            return
        if self.selected != self.over:
            self.parent.selection_changed(self, self.over)
            self.selected = self.over
        self.selected = self.over
    
    def on_mouse_left(self):
        if not self.enabled:
            return
        self.overList = False
        self.over = None
    
    def on_mouse_press(self, button, modifiers):
        if not self.enabled:
            return
        if self.scrollBar is not None:
            self.scrollBar.on_mouse_press(button, modifiers)
        self.pressed = True
        self.update_pressed()
        
    def on_mouse_release(self, button, modifiers):
        if not self.enabled:
            return
        self.pressed = False
        self.update_over()
        
    def on_mouse_drag(self, dx, dy, button, modifiers):
        if not self.enabled:
            return
        if self.scrollBar is not None:
            self.scrollBar.on_mouse_drag(dx, dy, button, modifiers)
            if self.scrollBar.over and self.scrollBar.pressed:
                self.over = selected = None
                return
        self.update_over()
        self.update_pressed()
        
    def draw(self):
        if self.updateDraw:
            self.updateDraw = False
            
            current = self.height - self.borderPad
            for item in self.lines:
                line = item.get_label()
                line.y = current
                current -= line.height
            self.update_scrollbar()
        
        glDisable(GL_TEXTURE_2D)
        glPushMatrix()
        glTranslatef(self.x, self.y - self.height, 0)
        
        # border
        
        if self.border:
            if self.border3d:
                draw_rectangle(0, 0, self.width, self.height, BORDER_COLOR_3D_1)
                draw_rectangle(1, 1, self.width - 1, self.height - 1,
                    BORDER_COLOR_3D_2)
                draw_rectangle(2, 2, self.width - 2, self.height - 2,
                    BORDER_COLOR_3D_3)
            else:
                draw_rectangle(0, 0, self.width, self.height, BORDER_COLOR)
        
        # background
        pad = self.borderPad
        glColor4ub(*(self.backColor + (255,)))
        glBegin(GL_QUADS)
        glVertex2f(pad, pad)
        glVertex2f(self.width - pad, pad)
        glVertex2f(self.width - pad, self.height - pad)
        glVertex2f(pad, self.height - pad)
        glEnd()
        
        glPushAttrib(GL_SCISSOR_BIT)
        x, y, width, height = self.player.get_scissor_box(
            self.x + self.borderPad, self.y - self.height + self.borderPad, 
            self.listWidth, self.height - self.borderPad * 2)
        glScissor(x, y, width, height)
        glEnable(GL_SCISSOR_TEST)
        glTranslatef(0, self.yOffset, 0)
        for index, item in enumerate(self.lines):
            line = item.get_label()
            color = None
            if self.selected == index:
                color = (139, 190, 228)
            elif self.over == index:
                color = (191, 219, 240)
            if color is not None:
                draw_rectangle(pad, line.y - line.height, 
                    self.listWidth + self.borderPad, 
                    line.y, color)
            line.draw()
        glPopAttrib()

        glPopMatrix()
        
        if self.scrollBar is not None:
            self.scrollBar.draw()
    
    def set_position(self, x, y):
        self.x, self.y = x, y
        if self.scrollBar is not None:
            pad = self.borderPad
            self.scrollBar.set_position(
                x + self.width - VerticalScrollBar.width - pad,
                y - pad)
    
    def set_size(self, width = None, height = None):
        pad = self.borderPad
        if width is not None:
            self.listWidth = width - pad * 2
            if self.scrollBar is not None:
                self.listWidth -= VerticalScrollBar.width
            self.width = width
        if height is not None:
            self.listHeight = height - pad * 2
            self.height = height
            if self.scrollBar is not None:
                self.scrollBar.set_size(height = height - pad * 2)
                self.update_scrollbar()
            if self.lines is not None:
                self.update_lines()

        if self.scrollBar is not None:
            self.set_position(self.x, self.y)
    
    def set_enable(self, value):
        self.enabled = value
        if self.scrollBar is not None:
            self.scrollBar.set_enable(value)
        if not self.enabled:
            self.over = None
            self.pressed = False
            self.overList = False
    
    def set_font_color(self, value):
        self.fontColor = value
        for line in self.lines:
            if line.label is not None:
                line.label.set_rgb(value)
    
    def set_back_color(self, value):
        self.backColor = value

    def on_detach(self):
        self.player.mouse.remove_handlers(
            on_mouse_scroll = self.on_mouse_scroll
        )

from pyglet.text.document import UnformattedDocument

def get_rectangle_vertices(x, y, width, height, border = False):
    pad = 1 if border else 0
    x1 = x + pad
    y1 = y + pad
    x2 = x + width - pad
    y2 = y + height - pad
    return [x1, y1, x2, y1, x2, y2, x1, y2]

X_PAD = 5
Y_PAD = 2

class EditDocument(UnformattedDocument):
    def _get_text(self):
        password_mode = self.styles.get('password', False)
        if not password_mode:
            return self._text

        text = u'*' * len(self._text)
        return text

    text = property(_get_text, UnformattedDocument._set_text)

    def get_value(self):
        return self._text

import pyglet

class Edit(PlayerChild):
    x = None
    y = None
    width = None
    height = None
    rectangle = None
    border = None
    has_focus = None
    disabled = False
    size_limit = -1
    old_text = ''
    modified = False
    focus_set = None
    def initialize(self, x, y, width, height, foreground_color, 
                   background_color, logFont, password, align_center,
                   align_right, uppercase, lowercase, read_only, multiline,
                   transparent, border):
        batch = pyglet.graphics.Batch()
        self.text_cursor = self.player.window.get_system_mouse_cursor('text')
        self.document = EditDocument()
        options = dict(
            face_name = logFont.faceName,
            font_size = logFont.getSize(),
            color = list(foreground_color) + [255],
            bold = logFont.isBold(),
            italic = logFont.italic,
            password = password
        )
        if logFont.underline:
            options['underline'] = list(foreground_color) + [255]
        if align_center:
            alignment = 'center'
        elif align_right:
            alignment = 'right'
        else:
            alignment = 'left'

        options['align'] = alignment
        self.document.set_style(0, 0, options)
            
        self.upper = uppercase
        self.lower = lowercase
        self.read_only = read_only
        font = self.document.get_font()
        self.height = height
        self.width = width
        self.x = x
        self.y = y
        self.batch = batch
        layoutGroup = pyglet.graphics.OrderedGroup(2)
        self.layout = layout = pyglet.text.layout.IncrementalTextLayout(
            self.document, width - (X_PAD * 2), height - (Y_PAD * 2), 
            multiline = multiline, batch = batch,
            group = layoutGroup)
        self.caret = pyglet.text.caret.Caret(self.layout, 
            color = foreground_color)
        if not (transparent and multiline):
            if border:
                borderGroup = pyglet.graphics.OrderedGroup(0)
                self.border = self.batch.add(4, GL_QUADS, borderGroup,
                    ('v2i', get_rectangle_vertices(x, y, width, height)),
                    ('c4B', [0, 0, 0, 255] * 4)
                )
            rectangleGroup = pyglet.graphics.OrderedGroup(1)
            self.rectangle = self.batch.add(4, GL_QUADS, rectangleGroup,
                ('v2i', get_rectangle_vertices(x, y, width, height, 
                    border)),
                ('c4B', (list(background_color) + [255]) * 4)
            )
        self.set_position(x, y)
        self.set_focus(False)
        self.player.mouse.push_handlers(
            on_mouse_press = self.window_mouse_press)
    
    def on_mouse_drag(self, *arg, **kw):
        if self.disabled:
            return
        self.caret.on_mouse_drag(*arg, **kw)
    
    def on_mouse_press(self, *arg, **kw):
        if self.disabled:
            return
        if self.player.eventPlayer.loopCount == self.focus_set:
            return
        self.set_focus(True)
        self.caret.on_mouse_press(*arg, **kw)
    
    def window_mouse_press(self, x, y, button, modifiers):
        if self.disabled:
            return
        mouse = self.player.mouse
        if self.player.eventPlayer.loopCount == self.focus_set:
            return
        if not self.parent.parent in mouse.over:
            self.set_focus(False)
    
    def disable(self):
        self.disabled = True
        self.set_focus(False)
        mouse = self.player.mouse
        if self.parent.parent in mouse.over:
            self.player.window.set_mouse_cursor(None)
    
    def enable(self):
        self.disabled = False
        mouse = self.player.mouse
        if self.parent.parent in mouse.over:
            self.player.window.set_mouse_cursor(self.text_cursor)
    
    def on_mouse_left(self):
        self.player.window.set_mouse_cursor(None)
    
    def on_mouse_over(self):
        self.player.window.set_mouse_cursor(self.text_cursor)
    
    def on_text_motion(self, *arg, **kw):
        if self.has_focus:
            self.caret.on_text_motion(*arg, **kw)
            self.update_modified_flag()
            
    def on_text(self, text):
        if self.has_focus and not self.read_only:
            if not self.layout.multiline and text == '\r':
                return
            if self.upper:
                text = text.upper()
            elif self.lower:
                text = text.lower()
            self.caret.on_text(text)
            # if (self.size_limit > 0 and len(self.document.text) > self.size_limit):
                # self.document.text = self.document.get_value()[:self.size_limit]
            self.update_modified_flag()
    
    def set_text(self, value):
        self.document.text = value.decode('windows-1252')
    
    def get_text(self):
        data = self.document.get_value()
        return data.encode('windows-1252')
            
    def on_text_motion_select(self, *arg, **kw):
        if self.has_focus:
            self.caret.on_text_motion_select(*arg, **kw)
            self.update_modified_flag()
    
    def set_position(self, x, y):
        self.layout.x = x + X_PAD
        self.layout.y = y + Y_PAD
        self.x = x
        self.y = y
        self._update_vertices()

    def set_focus(self, value):
        if self.player.eventPlayer is not None:
            self.focus_set = self.player.eventPlayer.loopCount
        if value == self.has_focus:
            return
        self.has_focus = value
        caret = self.caret
        if value:
            caret.visible = True
        else:
            caret.visible = False
            caret.mark = None
    
    def set_background_color(self, r, g, b):
        if self.rectangle:
            self.rectangle.colors = [r, g, b, 255] * 4
    
    def set_foreground_color(self, r, g, b):
        self.document.set_style(0, 0, dict(
            color = [r, g, b, 255]))
        self.caret.color = (r, g, b)
    
    def update_modified_flag(self):
        old_text = self.old_text
        new_text = self.document.get_value()
        if new_text != old_text:
            self.modified = True
            self.old_text = new_text
    
    def resize(self, width, height):
        layout = self.layout
        x, y = self.x, self.y
        y = y + self.height - height
        layout.y = y
        self.width = width
        self.height = height
        self._update_vertices()
        layout.width = width - (X_PAD * 2)
        layout.height = height - (Y_PAD * 2)
    
    def _update_vertices(self):
        x, y = self.x, self.y
        width = self.width
        height = self.height
        if self.rectangle:
            self.rectangle.vertices = get_rectangle_vertices(x, y, width,
                height, self.border is not None)
            if self.border:
                self.border.vertices = get_rectangle_vertices(x, y, width,
                    height)
    
    def draw(self):
        glDisable(GL_TEXTURE_2D)
        self.batch.draw()
    
    def on_detach(self):
        self.player.mouse.remove_handlers(
            on_mouse_press = self.window_mouse_press)