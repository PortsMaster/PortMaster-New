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

from mmfparser.player.event.conditions.common import Condition

class SubApplicationCondition(Condition):
    def check(self, instance):
        player = instance.objectPlayer.gamePlayer
        if player is None:
            return False
        return self.check_player(player)
    
    def check_player(self, player):
        return False

class SubApplicationPaused(SubApplicationCondition):
    def check_player(self, player):
        return player.paused

class SubApplicationVisible(Condition):
    def check(self, instance):
        return instance.visible

class SubApplicationFinished(SubApplicationCondition):
    def check_player(self, player):
        return player.finished

class SubApplicationFrameChanged(SubApplicationCondition):
    currentFrame = -1
    def check_player(self, player):
        index = player.frameIndex
        if self.currentFrame != index:
            self.currentFrame = index
            return True
        return False