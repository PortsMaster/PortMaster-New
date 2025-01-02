
import pyxel

import constants
import game

STARTING_LIVES = 2
MAX_SCORE = 999999
MAX_LIVES = 99

SCORE_HIT_LIGHT = 200
SCORE_STAGE_COMPLETE = 1000
SCORE_USE_WEAPON = 4000
SCORE_KILLED_SPINNER = 200
SCORE_KILLED_ALL_SPINNERS = 10000

g_lives = STARTING_LIVES
g_score = 0
g_highscore = 0
g_stage_num = 1
g_sound_on = True
g_music_on = True

def reset():
    global g_lives
    global g_score
    global g_stage_num
    
    g_lives = STARTING_LIVES
    g_score = 0
    g_stage_num = 1
    
def toggle_sound():
    global g_sound_on
    
    g_sound_on = not g_sound_on
    
    if g_sound_on == False:
        pyxel.stop()
    
def toggle_music(game_obj):
    global g_music_on
    
    g_music_on = not g_music_on
    
    if g_music_on == False:
        pyxel.stop()
    else:
        game_obj.restart_music()
    
def set_high_score():
    global g_score
    global g_highscore
    
    g_highscore = max(g_score, g_highscore)
    
def add_lives(amt):
    global g_lives
    
    g_lives = max(0, min(g_lives + amt, MAX_LIVES))
    
def add_score(amt):
    global g_score
    
    g_score = max(0, min(g_score + amt, MAX_SCORE))
    