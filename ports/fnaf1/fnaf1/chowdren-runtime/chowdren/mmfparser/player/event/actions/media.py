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

class SetMainPan(Action):
    def execute(self):
        value = self.evaluate_index(0)
        self.player.media.set_main_pan(value)

class SetChannelPan(Action):
    def execute(self):
        id = self.evaluate_index(0) - 1
        value = self.evaluate_index(1)
        self.player.media.get_channel(id).set_pan(value)

class SetSamplePan(Action):
    def execute(self):
        name = self.get_parameter(0).handle
        value = self.evaluate_index(1)
        players = self.player.media.get_player(name)
        if not players:
            return
        for player in players:
            player.set_pan(value)

class PlayChannelSample(Action):
    def execute(self):
        handle = self.get_parameter(0).handle
        channel = self.evaluate_index(1) - 1
        self.player.media.play_sound_handle(handle, channel = channel)

class PlayChannelFileSample(Action):
    def execute(self):
        path = self.get_filename(self.get_parameter(0))
        channel = self.evaluate_index(1) - 1
        self.player.media.play_sound_file(path, channel = channel)

class PlayLoopingChannelFileSample(Action):
    def execute(self):
        path = self.get_filename(self.get_parameter(0))
        channel = self.evaluate_index(1) - 1
        loops = self.evaluate_index(2)
        self.player.media.play_sound_file(path, loops, channel)

class PlayLoopingSample(Action):
    def execute(self):
        handle = self.get_parameter(0).handle
        loops = self.evaluate_index(1)
        self.player.media.play_sound_handle(handle, loops)

class PlayLoopingChannelSample(Action):
    def execute(self):
        handle = self.get_parameter(0).handle
        channel = self.evaluate_index(1) - 1
        loops = self.evaluate_index(2)
        self.player.media.play_sound_handle(handle, loops, channel)

class PlaySample(Action):
    def execute(self):
        handle = self.get_parameter(0).handle
        self.player.media.play_sound_handle(handle, 1)

class StopAllSamples(Action):
    def execute(self):
        self.player.media.stop_samples()

class PlayLoopingMusic(Action):
    def execute(self):
        handle = self.get_parameter(0).handle
        loops = self.evaluate_index(1)
        self.player.media.play_music_handle(handle, loops)

class PlayMusic(Action):
    def execute(self):
        handle = self.get_parameter(0).handle
        self.player.media.play_music_handle(handle)

class PlayMusicFile(Action):
    def execute(self):
        filename = self.get_filename(self.get_parameter(0))
        self.player.media.play_music_file(filename)

class PlayLoopingMusicFile(Action):
    def execute(self):
        filename = self.get_filename(self.get_parameter(0))
        loops = self.evaluate_index(1)
        self.player.media.play_music_file(filename, loops)

class StopMusic(Action):
    def execute(self):
        self.player.media.stop_music()

class PauseMusic(Action):
    def execute(self):
        self.player.media.pause_music()
        
class PauseChannel(Action):
    def execute(self):
        self.player.media.pause_channel(self.evaluate_expression(
            self.get_parameter(0)) - 1)

class PauseAllSounds(Action):
    def execute(self):
        self.player.media.pause_sounds()

class PauseSample(Action):
    def execute(self):
        name = self.get_parameter(0).handle
        players = self.player.media.get_player(name)
        if not players:
            return
        for player in players:
            player.paused = True

class ResumeChannel(Action):
    def execute(self):
        self.player.media.resume_channel(self.evaluate_expression(
            self.get_parameter(0)) - 1)

class ResumeSample(Action):
    def execute(self):
        name = self.get_parameter(0).handle
        players = self.player.media.get_player(name)
        if not players:
            return
        for player in players:
            player.paused = False

class ResumeAllSounds(Action):
    def execute(self):
        self.player.media.resume_sounds()

class ResumeMusic(Action):
    def execute(self):
        self.player.media.resume_music()

class StopChannel(Action):
    def execute(self):
        channel = self.evaluate_index(0)
        self.player.media.stop_channel(channel - 1)

class StopSample(Action):
    def execute(self):
        name = self.get_parameter(0).handle
        self.player.media.stop_sample(name)

class SetChannelVolume(Action):
    def execute(self):
        channel = self.evaluate_index(0) - 1
        volume = self.evaluate_index(1)
        self.player.media.set_channel_volume(channel, volume)

class SetSampleVolume(Action):
    def execute(self):
        name = self.get_parameter(0).handle
        volume = self.evaluate_index(1)
        self.player.media.set_sample_volume(name, volume)

class SetMainVolume(Action):
    def execute(self):
        volume = self.evaluate_index(0)
        self.player.media.set_main_volume(volume)

class SetChannelPosition(Action):
    def execute(self):
        channel = self.evaluate_index(0) - 1
        position = self.evaluate_index(1)
        self.player.media.set_channel_position(channel, position)

class SetSamplePosition(Action):
    def execute(self):
        name = self.get_parameter(0).handle
        position = self.evaluate_index(1)
        self.player.media.set_sample_position(name, position)

class SetSampleFrequency(Action):
    def execute(self):
        name = self.get_parameter(0).handle
        frequency = self.evaluate_index(1)
        players = self.player.media.get_player(name)
        if not players:
            return
        for player in players:
            player.frequency = frequency

class SetChannelFrequency(Action):
    def execute(self):
        channel = self.evaluate_index(0) - 1
        frequency = self.evaluate_index(1)
        self.player.media.get_channel(channel).frequency = frequency

class LockChannel(Action):
    def execute(self):
        channel = self.evaluate_index(0) - 1
        self.player.media.lock_channel(channel)

class UnlockChannel(Action):
    def execute(self):
        channel = self.evaluate_index(0) - 1
        self.player.media.unlock_channel(channel)