import os
import pygame
pygame.mixer.init(48000, -16, 2, 1024*3)

soundcache = {}

def load_sound(sound):
    if not soundcache.has_key(sound):
        soundcache[sound] = pygame.mixer.Sound(os.path.join('sounds', sound))
    return soundcache[sound]

def find_music(filename):
    return os.path.join('music', filename)
