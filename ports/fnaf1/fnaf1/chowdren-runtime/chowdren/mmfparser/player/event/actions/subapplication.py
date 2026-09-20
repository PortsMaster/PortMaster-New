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
from mmfparser.data.gamedata import GameData

class SubApplicationAction(Action):
    def execute(self, instance):
        player = instance.objectPlayer.gamePlayer
        if player is None:
            return
        self.execute_player(player)
    
    def execute_player(self, player):
        pass

class JumpSubApplicationFrame(SubApplicationAction):
    def execute_player(self, player):
        value = self.evaluate_index(0)
        player.set_frame(value)

class RestartSubApplication(Action):
    def execute(self, instance):
        instance.objectPlayer.restart()

class NextSubApplicationFrame(SubApplicationAction):
    def execute_player(self, player):
        player.set_frame(player.frameIndex + 1)

class PreviousSubApplicationFrame(SubApplicationAction):
    def execute_player(self, player):
        player.set_frame(player.frameIndex - 1)

class RestartSubApplicationFrame(SubApplicationAction):
    def execute_player(self, player):
        player.set_frame(player.frameIndex)

class SetSubApplicationGlobalValue(SubApplicationAction):
    def execute_player(self, player):
        index = self.evaluate_index(0)
        value = self.evaluate_index(1)
        player.globals.set_value(index - 1, value)

class SetSubApplicationGlobalString(SubApplicationAction):
    def execute_player(self, player):
        index = self.evaluate_index(0)
        value = self.evaluate_index(1)
        player.globals.set_string(index - 1, value)

class PauseSubApplication(SubApplicationAction):
    def execute_player(self, player):
        player.pause(-2)

class ResumeSubApplication(SubApplicationAction):
    def execute_player(self, player):
        player.resume()

class ShowSubApplication(Action):
    def execute(self, instance):
        instance.visible = True

class HideSubApplication(Action):
    def execute(self, instance):
        instance.visible = False

class EndSubApplication(SubApplicationAction):
    def execute(self, instance):
        instance.objectPlayer.gamePlayer.stop()

class LoadApplication(Action):
    def execute(self, instance):
        value = self.get_filename(self.get_parameter(0))
        instance.objectPlayer.load_file(value)