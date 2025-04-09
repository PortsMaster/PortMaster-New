
import pyxel

import globals

MUS_IN_GAME = 0
MUS_TITLE = 1
MUS_START = 2
MUS_STAGE_COMPLETE = 3
MUS_DEATH = 4
MUS_GAME_OVER = 5

MUSIC = [
    MUS_IN_GAME,
    MUS_TITLE,
    MUS_START,
    MUS_STAGE_COMPLETE,
    MUS_DEATH,
    #MUS_GAME_OVER
]

SND_MENU_MOVE = 16
SND_MENU_SELECT = 17
SND_HIT_WALL = 18
SND_HIT_TARGET = 19
SND_USED_WEAPON = 20

SOUNDS = [
    SND_MENU_MOVE,
    SND_MENU_SELECT,
    SND_HIT_WALL,
    SND_HIT_TARGET,
    SND_USED_WEAPON,
]

def play_sound(snd, looping=False):
    if globals.g_sound_on == False:
        return
        
    if snd not in SOUNDS:
        return
        
    if pyxel.play_pos(3) != -1:
        return
        
    pyxel.play(3, snd, loop=looping)
    
def play_music(msc, looping=False):
    if globals.g_music_on == False:
        return
        
    if msc not in MUSIC:
        return
        
    pyxel.stop()
        
    pyxel.playm(msc, loop=looping)
