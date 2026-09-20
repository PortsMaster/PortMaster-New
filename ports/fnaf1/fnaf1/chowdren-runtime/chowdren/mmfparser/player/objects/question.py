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
from pyglet.window.mouse import LEFT, RIGHT
from pyglet import gl

def draw_rectangle(x1, y1, x2, y2, r, g, b):
    gl.glColor4ub(r, g, b, 255)
    gl.glBegin(gl.GL_QUADS)
    gl.glVertex2f(x1, y1)
    gl.glVertex2f(x2, y1)
    gl.glVertex2f(x2, y2)
    gl.glVertex2f(x1, y2)
    gl.glEnd()

def draw_border(x1, y1, width, height, state = False):
    if state:
        r, g, b = (128, 128, 128)
    else:
        r, g, b = (192, 192, 192)
    x2 = x1 + width
    y2 = y1 - height
    draw_rectangle(x1, y1, x2, y2, 0, 0, 0)
    draw_rectangle(x1 + 1, y1 - 1, x2 - 1, y2 + 1, r, g, b)

X_MARGIN = 12
Y_MARGIN = 6

class Question(ObjectPlayer):
    questionFont = None
    answerFont = None
    correctAnswers = None
    
    questionLabel = None
    answers = None
    
    overBox = None
    
    def created(self):
        self.correctAnswers = set()
        items = self.loader.text.items
        for id, item in enumerate(items[1:]):
            if item.flags['Correct']:
                self.correctAnswers.add(id)
        questionParagraph = items[0]
        self.questionFont = questionParagraph.getFont(
            self.player.gameData.fonts).value
        self.answerFont = items[1].getFont(self.player.gameData.fonts).value
        self.enable_mouse()
        self.player.frame.topRenders.append(self.draw_question)
    
    def ask_question(self, x, y):
        self.parent.visible = True
        self.parent.set_position(x, y)
        x = self.x
        y = self.y
        
        items = self.loader.text.items
        
        self.answers = answers = []
        width = 0
        height = 0
        for item in items[1:]:
            label = self.create_label(self.answerFont, item.value,
                item.color)
            answers.append(label)
            width = max(width, label.content_width)
            height += label.content_height
        self.questionLabel = label = self.create_label(self.questionFont, 
            items[0].value, items[0].color)
        width = max(width, label.content_width)
        height += label.content_height
        
        width += X_MARGIN * 2
        height += Y_MARGIN * (2 + len(answers))
        
        current_y = -Y_MARGIN
        for label in [label] + answers:
            label.x = x
            label.y = y + current_y
            label.width = width
            label.set_style('align', 'center')
            label.content_valign = 'center'
            current_y -= (label.content_height + Y_MARGIN)

        self.width = width
        self.height = height
        from mmfparser.player.collision import BoundingBox
        self.collision = BoundingBox(self)
        
        self.player.pause(-2)
        
    def update_box(self):
        from mmfparser.player.collision import collides_python
        mouse = self.player.mouse
        x, y = mouse.glX, mouse.glY
        for id, answer in enumerate(self.answers):
            x1 = answer.x + 6
            y2 = answer.y + 2
            x2 = x1 + (self.width - 12)
            y1 = y2 - (answer.content_height + 4)
            if collides_python(x, y, x, y, x1, y1, x2, y2):
                self.overBox = id
                return
        self.overBox = None
            
    def on_mouse_drag(self, dx, dy, button, modifiers):
        self.update_box()
        if not button & LEFT:
            return
    
    def on_mouse_motion(self, dx, dy):
        self.update_box()
    
    def on_mouse_left(self):
        self.overBox = None
    
    def on_mouse_release(self, button, modifiers):
        if button != LEFT:
            return
        if self.overBox is None:
            return
        id = self.overBox
        self.player.resume()
        self.fire_handler('answered', id + 1)
        if id in self.correctAnswers:
            self.fire_handler('answer_true')
        else:
            self.fire_handler('answer_false')
        for label in [self.questionLabel] + self.answers:
            label.delete()
        self.parent.visible = False
    
    def draw(self):
        return
    
    def draw_question(self):
        if not self.parent.visible:
            return
        gl.glDisable(gl.GL_TEXTURE_2D)
        x, y = self.x, self.y
        draw_border(x, y, self.width, self.height)
        self.questionLabel.draw()
        pressed = self.player.mouse.left
        over = self.overBox
        for id, answer in enumerate(self.answers):
            state = id == over and pressed
            draw_border(answer.x + 6, answer.y + 2, self.width - 12, 
                answer.content_height + 4, state)
            answer.draw()

__all__ = ['Question']