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

"""
kchisc.mfx
Hi-Score object - ClickTeam (http://www.clickteam.com)
Records the top scores for a game.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Ask for a player's name

    Parameters:
    0: Ask for a player's name (SHORT, Short)
    """

    def execute(self, instance):
        player = self.get_parameter(0).value
        score = self.player.players.items[player].score
        instance.objectPlayer.pendingScores.append(score, player)

class Action1(Action):
    """
    Visibility->Make object invisible
    """

    def execute(self, instance):
        instance.visible = False

class Action2(Action):
    """
    Visibility->Make object reappear
    """

    def execute(self, instance):
        instance.visible = True

class Action3(Action):
    """
    Reset
    """

    def execute(self, instance):
        instance.objectPlayer.scores = instance.objectPlayer.originalScores[:]
        instance.objectPlayer.scores_changed()

class Action4(Action):
    """
    Change one name

    Parameters:
    0: Change one name (EXPRESSION, ExpressionParameter)
    1: Change one name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        name = self.evaluate_index(1)
        objectPlayer = instance.objectPlayer
        objectPlayer.scores[index] = (name, objectPlayer.scores[index][1])
        objectPlayer.scores_changed()

class Action5(Action):
    """
    Change one score

    Parameters:
    0: Change one score (EXPRESSION, ExpressionParameter)
    1: Change one score (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        score = self.evaluate_index(1)
        objectPlayer = instance.objectPlayer
        objectPlayer.scores[index] = (objectPlayer.scores[index][0], score)
        objectPlayer.scores_changed()

class Action6(Action):
    """
    Position->Select position...

    Parameters:
    0: Select position... (POSITION, Position)
    """

    def execute(self, instance):
        try:
            x, y, _ = self.get_positions(self.get_parameter(0))[0]
        except IndexError:
            return
        instance.set_position(x, y)

class Action7(Action):
    """
    Position->Set Horizontal Position

    Parameters:
    0: Set Horizontal Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.set_position(self.evaluate_index(0),
            instance.y)

class Action8(Action):
    """
    Position->Set Vertical Position

    Parameters:
    0: Set Vertical Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.set_position(instance.x,
            self.evaluate_index(0))

class Action9(Action):
    """
    Insert a hiscore

    Parameters:
    0: Please enter score value... (EXPRESSION, ExpressionParameter)
    1: Please enter player's name... (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        score = self.evaluate_index(0)
        name = self.evaluate_index(1)
        instance.objectPlayer.add_score(name, score)

class Action10(Action):
    """
    File->Set current file

    Parameters:
    0: Enter a new filename for the ini file (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_file(
            self.evaluate_index(0))

# Conditions

class Condition0(Condition):
    """
    Has player a hiscore?

    Parameters:
    0: Has player a hiscore? (SHORT, Short)
    """

    def check(self, instance):
        player = self.get_parameter(0).value
        score = self.player.players.items[player].score
        objectPlayer = instance.objectPlayer
        if (score > objectPlayer.scores[-1][1] 
        and score > objectPlayer.savedScores[player]):
            objectPlayer.savedScores[player] = score
            return True
        return False

class Condition1(Condition):
    """
    Is visible ?
    """

    def check(self, instance):
        return instance.visible


# Expressions

class Expression0(Expression):
    """
    Hiscore value

    Parameters:
    0: Score number (Int)
    Return type: Int
    """

    def get(self, instance):
        try:
            instance.scores[self.next_argument() - 1][1]
        except IndexError:
            return ''

class Expression1(Expression):
    """
    Hiscore name

    Parameters:
    0: Score number (Int)
    Return type: Int
    """

    def get(self, instance):
        try:
            instance.scores[self.next_argument() - 1][0]
        except IndexError:
            return ''

class Expression2(Expression):
    """
    X Position of hiscore table
    Return type: Int
    """

    def get(self, instance):
        return instance.x

class Expression3(Expression):
    """
    Y Position of hiscore table
    Return type: Int
    """

    def get(self, instance):
        return instance.y

from mmfparser.data.font import LogFont
from mmfparser.bitdict import BitDict

HIGHSCORE_FLAGS = BitDict(
    'HideOnStart',
    'NameFirst',
    'CheckOnStart',
    'HideScores',
    'FullPath'
)

from mmfparser.player.objects.question import (draw_rectangle, draw_border,
    X_MARGIN, Y_MARGIN)
from pyglet.text import Label
from mmfparser.player.ini import FastINI
import os

from pyglet import gl
from pyglet.window import key

BOX_WIDTH = 400
BOX_HEIGHT = 70

class DefaultObject(HiddenObject):
    currentScore = None
    labels = None
    nameFirst = False
    hideScores = False
    ini = None
    savedScores = None
    def created(self, data):
        self.savedPlayers = [0 for _ in xrange(4)]
        self.scoreCount = data.readShort(True)
        self.nameLength = data.readShort(True)
        self.flags = HIGHSCORE_FLAGS.copy()
        self.flags.setFlags(data.readShort(True))
        if self.flags['HideOnStart']:
            self.parent.visible = False
        self.hideScores = self.flags['HideScores']
        self.nameFirst = self.flags['NameFirst'] or self.hideScores
        self.font = LogFont(data, old = True)
        self.color = data.readColor()
        data.skipBytes(40)
        name_list = []
        score_list = []
        for _ in xrange(20):
            name_list.append(data.readString(41))
        for _ in xrange(20):
            score_list.append(data.readInt())
        self.originalScores = [(name_list[i], score_list[i])
            for i in xrange(self.scoreCount)]
        self.scores = self.originalScores[:]
        self.width = data.readShort(True)
        self.height = data.readShort(True)
        self.name = data.readString(260)
        self.enable_mouse()
        self.pendingScores = []
        self.set_file(self.name or 'Game.ini')
        if self.flags['CheckOnStart']:
            for index, item in enumerate(self.player.players.items):
                if item.score > self.scores[-1][1]:
                    self.pendingScores.insert(0, (item.score, index + 1))
        self.nameLabel = Label('Enter your name', color = (0, 0, 0, 255), 
            bold = True, anchor_x = 'center', anchor_y = 'center',
            y = 25)
        self.currentName = Label('', color = (0, 0, 0, 255), 
            anchor_x = 'center', anchor_y = 'center', width = BOX_WIDTH - 20)
        self.labels = labels = []
        height = self.height / self.scoreCount
        y = 0
        for name, score in self.scores:
            label1 = self.create_label(self.font, '', self.color, 
                self.width,
                self.height)
            label2 = self.create_label(self.font, '', self.color, 
                self.width, self.height)
            label2.set_style('align', 'right')
            for label in (label1, label2):
                label.y = y
            labels.append((label1, label2))
            y -= height
        self.update_labels()
        self.updateEnabled = True
        self.player.window.push_handlers(
            on_text_motion = self.on_text_motion,
            on_text = self.on_text,
            on_key_press = self.on_key_press
        )
    
    def set_file(self, filename):
        load = self.ini is None
        self.ini = ini = FastINI(filename)
        if load:
            section = self.player.gameData.name
            for i in xrange(self.scoreCount):
                name = ini.get_key(section, 'N%s' % i)
                score = ini.get_key(section, 'S%s' % i)
                if score == '':
                    return
                score = int(score)
                self.scores[i] = (name, score)
    
    def on_key_press(self, symbol, modifiers):
        if self.currentScore is None:
            return
        if symbol == key.ENTER:
            name = self.currentName.text.encode('windows-1252')
            self.add_score(name, self.currentScore)
            self.currentScore = None
            self.player.resume()
    
    def add_score(self, name, score):
        self.scores.append((name, score))
        self.scores.sort(key = lambda x: x[1], reverse = True)
        self.scores = self.scores[:self.scoreCount]
        self.scores_changed()
    
    def scores_changed(self):
        self.save()
        self.update_labels()
    
    def update_labels(self):
        for i, (label1, label2) in enumerate(self.labels):
            name, score = self.scores[i]
            if self.nameFirst:
                label1.text = name
                label2.text = '%s' % score
            else:
                label1.text = '%s' % score
                label2.text = name
    
    def on_text_motion(self, motion):
        if self.currentScore is None:
            return
        if motion == key.MOTION_BACKSPACE:
            self.currentName.text = self.currentName.text[:-1]
        
    def on_text(self, value):
        if self.currentScore is None:
            return
        self.currentName.text += value
        
    def update(self):
        if self.pendingScores and self.currentScore is None:
            score, player = self.pendingScores.pop()
            if score > self.scores[-1][1]:
                self.add_name(score, player)
            return
    
    def add_name(self, score, player):
        self.currentScore = score
        self.currentName.text = ''
        self.nameLabel.text = 'Enter your name, player %s' % player
        self.player.pause(-2)
    
    def draw(self):
        gl.glPushMatrix()
        gl.glTranslatef(self.x, self.y, 0)
        for label1, label2 in self.labels:
            label1.draw()
            if not self.hideScores:
                label2.draw()
        gl.glPopMatrix()
        gl.glPushMatrix()
        width = self.player.realWidth
        height = self.player.realHeight
        x = width / 2.0
        y = height / 2.0
        x1 = x - BOX_WIDTH / 2.0
        y1 = y + BOX_HEIGHT / 2.0
        if self.currentScore is not None:
            gl.glDisable(gl.GL_TEXTURE_2D)
            draw_border(x1, y1, BOX_WIDTH, BOX_HEIGHT)
            gl.glPushMatrix()
            gl.glTranslatef(x, y, 0)
            self.nameLabel.draw()
            self.currentName.draw()
            gl.glPopMatrix()
        gl.glPopMatrix()
    
    def on_detach(self):
        self.player.window.remove_handlers(
            on_text_motion = self.on_text_motion,
            on_text = self.on_text,
            on_key_press = self.on_key_press
        )
    
    def save(self):
        section = self.player.gameData.name
        for i, (name, score) in enumerate(self.scores):
            self.ini.set_key(section, 'N%s' % i, name)
            self.ini.set_key(section, 'S%s' % i, '%s' % score)

class kchisc(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
        10 : Action10,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
    }

extension = kchisc()

def get_extension():
    return extension
