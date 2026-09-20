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

class ChannelNotPlaying(Condition):
    def check(self):
        channel = self.evaluate_index(0) - 1
        return (not self.player.media.channel_playing(channel)) != self.negated

class NoSamplesPlaying(Condition):
    def check(self):
        return (not self.player.media.samples_playing()) != self.negated

class SampleNotPlaying(Condition):
    def check(self):
        name = self.get_parameter(0).handle
        players = self.player.media.get_player(name)
        if not players:
            return not self.negated
        return (players[0].paused) != self.negated
    
class SpecificMusicNotPlaying(Condition):
    def check(self):
        handle = self.get_parameter(0).handle
        return (not self.player.media.music_playing(handle)) != self.negated

class NoMusicPlaying(Condition):
    def check(self):
        return (not self.player.media.music_playing()) != self.negated

class MusicPaused(Condition):
    def check(self):
        return self.player.media.music_paused() != self.negated

class SamplePaused(Condition):
    def check(self):
        return self.player.media.sample_paused(
            self.get_parameter(0).handle) != self.negated

class ChannelPaused(Condition):
    def check(self):
        id = self.evaluate_index(0) - 1
        return self.player.media.channel_paused(id) != self.negated

class MusicFinished(Condition):
    playing = False
    def check(self):
        handle = self.get_parameter(0).handle
        if self.playing and not self.player.media.music_playing(handle):
            self.playing = False
            return not self.negated
        elif self.player.media.music_playing(handle):
            self.playing = True
        return self.negated