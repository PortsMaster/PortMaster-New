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

import os
from mmfparser.player.common import PlayerChild, convert_path
from mmfparser.player.eventdispatcher import EventDispatcher
import math
import snakesound

MUTED = 0
DEFAULT_SOUNDFONT = 'font.sf2'

if os.path.isfile(DEFAULT_SOUNDFONT):
    SOUNDFONT_PATH = os.path.join(os.getcwd(), DEFAULT_SOUNDFONT)
else:
    SOUNDFONT_PATH = None

def clamp(value):
    return max(0, min(1.0, value))

class SoundDummy(object):
    item = None
    dummy = True
    frequency = 0
    pan = 0
    volume = 1.0
    locked = False
    paused = True
    time = 0.0
    duration = 0.0
    closed = True
    
    def __init__(self, sound = None):
        if sound is not None:
            self.volume = sound.volume
            self.frequency = sound.frequency
            self.pan = sound.get_pan()

    def get_pan(self):
        return self.pan
    
    def set_pan(self, value):
        self.pan = value
    
    def close(self):
        pass
    
    def stop(self):
        pass

class PlayerSound(snakesound.Sound):
    _main_pan = 0.0
    _real_pan = 0.0
    item = None
    locked = False

    def set_pan(self, value):
        self._real_pan = value
        self.pan = value + self._main_pan
    
    def set_main_pan(self, value):
        self._main_pan = value
        self.set_pan(self._real_pan)
    
    def get_pan(self):
        return self._real_pan

class FileData(object):
    def __init__(self, name):
        self.name = name
    
    def load(self):
        return PlayerSound(filename = self.name)
        
    def __str__(self):
        return '<FileData %s>' % self.name

class MemoryData(object):
    def __init__(self, item):
        self.item = item
    
    def load(self):
        sound = PlayerSound(self.item.data)
        sound.item = self.item
        return sound

    def __str__(self):
        return '<MemoryData %s>' % self.item.name

class MediaPlayer(PlayerChild, EventDispatcher):
    soundHandles = None
    musicHandles = None
    
    channels = None
    main_pan = 0
    musicId = None
    locked = None
    
    def initialize(self):
        snakesound.open()
        self.reset_channels()
        self.loaded = {}
        self.soundHandles = {}
        self.musicHandles = {}
        self.finishedPlayers = []
        self.locked = set()
        self.music = SoundDummy()
        if MUTED:
            snakesound.listener.volume = 0.0
        
    def reset_channels(self):
        self.channels = [SoundDummy() for _ in xrange(32)]
    
    def stop(self):
        self.update()
        snakesound.close()
    
    def load_sound(self, item):
        if item not in self.loaded:
            self.loaded[item] = MemoryData(item)
        return self.loaded[item]
    
    def get_sound(self, handle):
        try:
            return self.soundHandles[handle]
        except KeyError:
            item = self.player.gameData.sounds.fromHandle(handle)
            self.soundHandles[handle] = item
            return item
    
    def get_music(self, handle):
        try:
            return self.musicHandles[handle]
        except KeyError:
            item = self.player.gameData.music.fromHandle(handle)
            self.musicHandles[handle] = item
            return item
    
    def play_sound(self, item, loops = 1, channel = None):
        sound = self.load_sound(item)
        self.play_sound_item(sound, loops, channel)

    def play_sound_file(self, path, loops = 1, channel = None):
        path = convert_path(path)
        if path not in self.loaded:
            self.loaded[path] = FileData(path)
        self.play_sound_item(self.loaded[path], loops, channel)

    def play_sound_item(self, sound, loops = 1, channel = None):
        inherit = channel is not None
        if channel is None:
            for index in xrange(32):
                if not self.channels[index].closed or index in self.locked:
                    continue
                channel = index
                break
            if channel is None:
                return
        else:
            if channel not in xrange(32):
                return
            old_sound = self.channels[channel]
            if not old_sound.closed and old_sound.locked:
                return
        try:
            new_sound = sound.load()
        except snakesound.AudioError:
            return
        old_sound = self.channels[channel]
        if inherit:
            if old_sound.frequency != 0:
                new_sound.frequency = old_sound.frequency
            new_sound.set_pan(old_sound.get_pan())
            new_sound.volume = old_sound.volume
        old_sound.close()
        self.channels[channel] = new_sound
        new_sound.set_main_pan(self.main_pan)
        new_sound.set_callback(self.player_finished, new_sound)
        new_sound.play(loops)
    
    def update(self):
        while self.finishedPlayers:
            player = self.finishedPlayers.pop()
            if player.closed:
                continue
            self.sample_finished(player)
    
    def player_finished(self, player):
        self.finishedPlayers.append(player)
    
    def sample_finished(self, player):
        sound_dummy = SoundDummy(player)
        if player in self.channels:
            for k, v in enumerate(self.channels):
                if v == player:
                    self.channels[k] = sound_dummy
                    break
        player.close()
    
    def play_sound_handle(self, handle, *arg, **kw):
        return self.play_sound(self.get_sound(handle), *arg, **kw)

    def stop_samples(self):
        for player in self.channels:
            player.close()
        self.reset_channels()
    
    def stop_sample(self, name):
        for player in self.get_player(name):
            self.sample_finished(player)
        
    def get_player(self, identifier):
        players = []
        for player in self.channels:
            item = player.item
            if item is None:
                continue
            if identifier in (item.name, item.handle):
                players.append(player)
        return players
    
    # music stuff
    
    def play_music(self, item, loops = 1):
        self.musicId = item.handle
        self.music.stop()
        self.music = MemoryData(item).load()
        self.load_soundfont()
        self.music.play(loops)
        
    def play_music_file(self, filename, loops = 1):
        self.musicId = item.handle
        self.music.stop()
        self.music = FileData(filename).load()
        self.load_soundfont()
        self.music.play(loops)
    
    def load_soundfont(self):
        if SOUNDFONT_PATH is None:
            return
        self.music.set_soundfont(SOUNDFONT_PATH)
    
    def stop_music(self):
        self.music.stop()
    
    def pause_music(self):
        self.music.paused = True
    
    def resume_music(self):
        self.music.paused = False
    
    def play_music_handle(self, handle, *arg, **kw):
        return self.play_music(self.get_music(handle), *arg, **kw)
    
    # channel stuff
    
    def get_channel(self, id):
        id = min(max(0, id), 32)
        return self.channels[id]
    
    def lock_channel(self, id):
        self.locked.add(id)

    def unlock_channel(self, id):
        self.locked.discard(id)
    
    def stop_channel(self, id):
        channel = self.channels[id]
        dummy = SoundDummy(channel)
        channel.close()
        self.channels[id] = dummy
    
    def pause_channel(self, id):
        try:
            self.channels[id].paused = True
        except IndexError:
            pass
    
    def pause_sounds(self):
        for channel in self.channels:
            channel.paused = True

    def resume_channel(self, id):
        try:
            self.channels[id].paused = False
        except IndexError:
            pass

    def resume_sounds(self):
        for channel in self.channels:
            channel.paused = False
    
    def set_channel_volume(self, id, volume):
        channel = self.get_channel(id)
        volume = volume / 100.0
        channel.volume = volume

    def set_sample_volume(self, name, volume):
        players = self.get_player(name)
        if not players:
            return
        volume = volume / 100.0
        for player in players:
            player.volume = volume
    
    def set_channel_position(self, id, position):
        channel = self.get_channel(id)
        channel.time = position / 1000.0
    
    def set_sample_position(self, name, position):
        players = self.get_player(name)
        if not players:
            return
        for player in players:
            player.time = position / 1000.0
    
    def reset(self):
        self.stop_samples()
    
    def get_players(self):
        return self.channels
    
    # main stuff
    def set_main_volume(self, value):
        snakesound.listener.volume = clamp(value / 100.0)
    
    def get_main_volume(self):
        return snakesound.listener.volume * 100.0
    
    def set_main_pan(self, value):
        self.main_pan = value
        for player in self.channels:
            player.set_main_pan(value)
    
    def get_main_pan(self):
        return self.main_pan
    
    # event-specific stuff
    
    def samples_playing(self):
        for player in self.channels:
            if not player.paused:
                return True
        return False

    def channel_playing(self, id):
        try:
            return not self.channels[id].paused
        except IndexError:
            return False
    
    def music_playing(self, handle = None):
        if handle is None:
            return not self.music.paused
        return self.musicId == handle and not self.music.paused
    
    def music_paused(self):
        return self.music.paused
    
    def sample_paused(self, handle):
        for player in self.get_player(handle):
            return player.paused
        return False
    
    def channel_paused(self, id):
        try:
            return self.channels[id].paused
        except IndexError:
            return False