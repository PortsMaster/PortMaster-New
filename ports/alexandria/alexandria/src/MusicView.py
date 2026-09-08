import os.path
import pygame.mixer
import Event
import Config
import Sound

class MusicView(object):
    '''Music playing class.'''
    def __init__(self):
        self.playingsong = None
        self.nowplaying = {}

    def Notify(self, event):
        if isinstance(event, Event.NewSoundEvent):
            if event.loop:
                loop = -1
            else:
                loop = 0
            if not event.music:
                f = event.file.replace('wav', 'ogg')
                s = Sound.load_sound(f)
                event.sound = s
                c = pygame.mixer.find_channel()
                if c == None: return # Meh
                vol = Config.Config.fxvolume
                vol *= event.vol
                if not self.nowplaying.has_key((event.file, event.source)):
                    c.play(s, loop)
                    c.set_volume(vol)
                    time = pygame.time.get_ticks()
                    self.nowplaying[event.file, event.source] = (s, time)
                return
            if self.playingsong != event.file:
                self.playingsong = event.file
                pygame.mixer.music.load(Sound.find_music(event.file))
                pygame.mixer.music.set_volume(.8*Config.Config.musicvolume)
                pygame.mixer.music.play(loop)

        if isinstance(event, Event.StopSoundEvent):
            if self.sounds.has_key(event.file):
                self.sounds[event.file].stop()
                del self.sounds[event.file]

        if isinstance(event, Event.ConfigChangedEvent):
            if event.key == 'musicvolume':
                pygame.mixer.music.set_volume(.8*Config.Config.musicvolume)

    def thread(self):
        while True:
            yield None
            t = pygame.time.get_ticks()
            for key, value in self.nowplaying.items():
                s, start = value
                if t > s.get_length()*1000+start:
                    del self.nowplaying[key]
