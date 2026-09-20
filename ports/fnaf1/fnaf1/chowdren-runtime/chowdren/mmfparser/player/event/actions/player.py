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

from mmfparser.player.event.actions.common import Action

class PlayerAction(Action):
    def created(self):
        self.playerHandler = self.player.players.items[self.loader.objectInfo]

class SubtractScore(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        self.playerHandler.set_score(self.playerHandler.score - value)

class SetPlayerName(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        self.playerHandler.name = value

class AddScore(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        self.playerHandler.set_score(self.playerHandler.score + value)

class SetScore(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        self.playerHandler.set_score(value)

class AddLives(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        self.playerHandler.set_lives(self.playerHandler.lives + value)

class SubtractLives(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        self.playerHandler.set_lives(self.playerHandler.lives - value)

class SetLives(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        self.playerHandler.set_lives(value)

class IgnoreControls(PlayerAction):
    def execute(self):
        self.playerHandler.controls_ignored = True

class RestoreControls(PlayerAction):
    def execute(self):
        self.playerHandler.controls_ignored = False

class ChangeControlType(PlayerAction):
    def execute(self):
        value = self.evaluate_index(0)
        if value != 0:
            raise NotImplementedError('only the Keyboard control is supported')

class ChangeInputKey(PlayerAction):
    def created(self):
        self.key = self.get_parameter(1).key
        PlayerAction.created(self)

    def execute(self):
        index = self.evaluate_index(0)
        self.playerHandler.set_key(index, self.key)