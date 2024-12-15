
import math

import pyxel

import rect
import constants
import player
import stage
import spinner
import circle
import globals

MAX_SHOTS = 10
SHOT_RADIUS = 3
SHOT_SPEED = 1.5

VEL = []
for i in range(MAX_SHOTS):
    VEL.append(
        [
            SHOT_SPEED * math.cos(math.radians(i*36)),
            SHOT_SPEED * math.sin(math.radians(i*36)),
        ]
    )

class Weapon:
    def __init__(self):
        self.active = False
        
        self.shots = []
        for i in range(MAX_SHOTS):
            self.shots.append([0,0])
            
    def fire(self, from_x, from_y):
        self.active = True
        for s in self.shots:
            s[0] = from_x
            s[1] = from_y
            
    def update(self, player, stage):
        if not self.active:
            return
            
        done = True
  
        for i, s in enumerate(self.shots):
            s[0] += VEL[i][0]
            s[1] += VEL[i][1]
            
            if done != False and\
                rect.contains_point(0, 0, 
                    constants.GAME_WIDTH, constants.GAME_HEIGHT, 
                    s[0], s[1]):
                done = False
                
            for spin in stage.spinners:
                if not spin.is_dead:
                    if circle.overlap(
                        s[0], s[1], SHOT_RADIUS, 
                        spin.x, spin.y, spin.radius):
                        globals.add_score(globals.SCORE_KILLED_SPINNER)
                        spin.kill()
                
        if done:
            spinners_killed = sum(s.is_dead == True for s in stage.spinners)
            if spinners_killed == len(stage.spinners):
                globals.add_score(globals.SCORE_KILLED_ALL_SPINNERS)
            self.active = False
            player.weapon_done()
            
    def draw(self, shake_x, shake_y):
        if not self.active:
            return
            
        for s in self.shots:
            pyxel.blt(shake_x + s[0] - 10, 
                shake_y + s[1] - 10, 
                0, 21, 231, 21, 21, 8)
                
                