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

from mmfparser.player.event.expressions.common import Expression

class PlayerExpression(Expression):
    def created(self):
        self.playerReference = self.player.players.items[
            self.loader.objectInfo]

class PlayerScore(PlayerExpression):
    def get(self):
        return self.playerReference.score

class PlayerLives(PlayerExpression):
    def get(self):
        return self.playerReference.lives

class PlayerInputDevice(PlayerExpression):
    def get(self):
        return 0 # mouse + keyboard

class PlayerKeyName(PlayerExpression):
    def get(self):
        return self.playerReference.keyNames[self.next_argument()]

class PlayerName(PlayerExpression):
    def get(self):
        return self.playerReference.name

class PlayerCount(Expression):
    def get(self):
        return self.player.frameLoader.events.numberOfPlayers