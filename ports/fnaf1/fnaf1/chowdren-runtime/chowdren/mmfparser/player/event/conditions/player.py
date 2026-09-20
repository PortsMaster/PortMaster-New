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

from mmfparser.player.event.conditions.common import TrueCondition, Condition

from mmfparser.bitdict import BitDict

from pyglet.event import EVENT_HANDLED

class PlayerCondition(Condition):
    playerHandler = None
    def created(self):
        self.playerHandler = self.player.players.items[self.loader.objectInfo]

class NumberOfLives(PlayerCondition):
    def check(self):
        value = self.evaluate_index(0)
        return self.compare(self.playerHandler.lives, value)

class PlayerDied(PlayerCondition):
    def created(self):
        PlayerCondition.created(self)
        self.playerHandler.push_handlers(
            lives_changed = self.lives_changed
        )
    
    def lives_changed(self, value):
        if value == 0:
            self.generate()
            return EVENT_HANDLED
    
    def check(self):
        return self.playerHandler.lives == 0
    
    def on_detach(self):
        self.playerHandler.remove_handlers(
            lives_changed = self.lives_changed
        )

KEY_FLAGS = BitDict(
    'Up',
    'Down',
    'Left',
    'Right',
    'Button1',
    'Button2',
    'Button3',
    'Button4'
)

class PlayerKeyPressed(PlayerCondition):
    playerHandler = None
    keys = None
    pressed = False
    fire = False
    
    def key_pressed(self, name):
        if self.keys_down():
            if not self.pressed:
                self.pressed = self.fire = True
                if self.isTriggered:
                    self.generate()
        else:
            self.pressed = False
    
    def key_released(self, name):
        self.pressed = self.keys_down()
    
    def keys_down(self):
        for k, v in self.keys.iteritems():
            if v and not self.playerHandler.is_down(k):
                return False
        return True

    def created(self):
        PlayerCondition.created(self)
        self.keys = KEY_FLAGS.copy()
        self.keys.setFlags(self.get_parameter(0).value)
        self.playerHandler.push_handlers(
            player_key_pressed = self.key_pressed,
            player_key_released = self.key_released,
        )
    
    def check(self):
        if self.fire:
            self.fire = False
            return not self.negated
        return self.negated
    
    def on_detach(self):
        self.playerHandler.remove_handlers(
            player_key_pressed = self.key_pressed
        )

class PlayerKeyDown(PlayerCondition):
    playerHandler = None
    keys = None
    
    def keys_down(self):
        for k, v in self.keys.iteritems():
            if v and not self.playerHandler.is_down(k):
                return False
        return True

    def created(self):
        PlayerCondition.created(self)
        self.keys = KEY_FLAGS.copy()
        self.keys.setFlags(self.get_parameter(0).value)
    
    def check(self):
        return self.keys_down() != self.negated

class CompareScore(PlayerCondition):
    def check(self):
        value = self.evaluate_index(0)
        return self.compare(self.playerHandler.score, value)