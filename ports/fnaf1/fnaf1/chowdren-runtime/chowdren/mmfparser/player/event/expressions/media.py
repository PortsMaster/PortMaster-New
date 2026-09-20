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

class GetSamplePosition(Expression):
    def get(self):
        name = self.next_argument()
        players = self.player.media.get_player(name)
        if not players:
            return 0
        return int(players[0].time * 1000)

class GetChannelPosition(Expression):
    def get(self):
        id = self.next_argument() - 1
        player = self.player.media.get_channel(id)
        return int(player.time * 1000)

class GetMainPan(Expression):
    def get(self):
        return self.player.media.get_main_pan()

class GetChannelPan(Expression):
    def get(self):
        id = self.next_argument() - 1
        player = self.player.media.get_channel(id)
        return player.get_pan()

class GetSamplePan(Expression):
    def get(self):
        name = self.next_argument()
        players = self.player.media.get_player(name)
        if not players:
            return 0
        return players[0].get_pan()

class GetMainVolume(Expression):
    def get(self):
        return self.player.media.get_main_volume()

class GetChannelVolume(Expression):
    def get(self):
        id = self.next_argument() - 1
        player = self.player.media.get_channel(id)
        return player.volume * 100

class GetSampleVolume(Expression):
    def get(self):
        name = self.next_argument()
        players = self.player.media.get_player(name)
        if not players:
            return 0
        return int(players[0].volume * 100)

class GetChannelDuration(Expression):
    def get(self):
        id = self.next_argument() - 1
        player = self.player.media.get_channel(id)
        return player.duration * 1000

class GetSampleDuration(Expression):
    def get(self):
        name = self.next_argument()
        players = self.player.media.get_player(name)
        if not players:
            return 0
        return players[0].duration * 1000

class GetSampleFrequency(Expression):
    def get(self):
        name = self.next_argument()
        players = self.player.media.get_player(name)
        if not players:
            return 0
        return players[0].frequency

class GetChannelFrequency(Expression):
    def get(self):
        id = self.next_argument() - 1
        player = self.player.media.get_channel(id)
        return player.frequency

class GetSampleFrequency(Expression):
    def get(self):
        name = self.next_argument()
        players = self.player.media.get_player(name)
        if not players:
            return 0
        return players[0].frequency