
import random

import pyxel

import utils
import stage

TYPE_AGGRESSIVE = 0
TYPE_MILD = 1
TYPE_RANDOM_SLOW = 2
TYPE_RANDOM_FAST = 3

TYPES = [
    TYPE_AGGRESSIVE,
    TYPE_MILD,
    TYPE_RANDOM_SLOW,
    TYPE_RANDOM_FAST
]

TICKS_PER_FRAME = 10
MAX_FRAME = 4

MAX_SPEED = 0.4
MAX_RESPAWN_TICKS = 300 # 5 secs

class Spinner:
    def __init__(self, x, y, type):
        self.x = x
        self.y = y
        self.type = 2
        if type in TYPES:
            self.type = type
            
        self.vx = random.choice([-MAX_SPEED, MAX_SPEED])
        self.vy = random.choice([-MAX_SPEED, MAX_SPEED])
        
        self.radius = 4
            
        self.frame = 0
        self.frame_ticks = 0
        
        self.is_dead = False
        
        self.respawn_ticks = MAX_RESPAWN_TICKS
        
    def _set_new_position(self, stageObj):
        px = stageObj.player.x
        py = stageObj.player.y
        loc = None
        loclist = [
            stage.SPAWN_SECTOR_TOPLEFT,
            stage.SPAWN_SECTOR_BOTTOMLEFT,
            stage.SPAWN_SECTOR_TOPRIGHT,
            stage.SPAWN_SECTOR_BOTTOMRIGHT
        ]
        if px < 80:
            if py < 75:
                loclist.remove(stage.SPAWN_SECTOR_TOPLEFT)
            else:
                loclist.remove(stage.SPAWN_SECTOR_BOTTOMLEFT)
        else:
            if py < 75:
                loclist.remove(stage.SPAWN_SECTOR_TOPRIGHT)
            else:
                loclist.remove(stage.SPAWN_SECTOR_BOTTOMRIGHT)
        
        loc = stageObj.get_random_spawn_loc(random.choice(loclist))
        self.x = loc[0]
        self.y = loc[1]
        
    def kill(self):
        self.is_dead = True
        self.respawn_ticks = MAX_RESPAWN_TICKS
        
    def _do_collisions(self, stage):
        new_x = self.x + self.vx
        
        for b in stage.solid_rects:
            if utils.circle_rect_overlap(new_x, self.y, self.radius,
                b[0], b[1], b[2], b[3]):
                if self.x > b[0] + b[2]: # was prev to right of border.
                    new_x = b[0] + b[2] + self.radius
                elif self.x < b[0]: # was prev to left of border.
                    new_x = b[0] - self.radius
                
                self.vx *= -1
                break
                
        new_y = self.y + self.vy
        
        for b in stage.solid_rects:
            if utils.circle_rect_overlap(self.x, new_y, self.radius,
                b[0], b[1], b[2], b[3]):
                if self.y > b[1] + b[3]: # was prev below border.
                    new_y = b[1] + b[3] + self.radius
                elif self.y < b[1]: # was prev above border.
                    new_y = b[1] - self.radius
                
                self.vy *= -1
                break
                
        self.x = new_x
        self.y = new_y
        
    def respawn(self):
        self.is_dead = False
                
    def update(self, stage):
        if self.is_dead:
            self.respawn_ticks -= 1
            if self.respawn_ticks == 0:
                self.respawn()
            elif self.respawn_ticks == 30:
                self._set_new_position(stage)
        else:
            self._do_collisions(stage)
        
            self.frame_ticks += 1
            if self.frame_ticks == TICKS_PER_FRAME:
                self.frame_ticks = 0
                self.frame += 1
                if self.frame == MAX_FRAME:
                    self.frame = 0
        
    def draw(self, shake_x, shake_y):
        if self.is_dead:
            framex = None
            if self.respawn_ticks < 10:
                framex = 42
            elif self.respawn_ticks < 20:
                framex = 63
            elif self.respawn_ticks < 30:
                framex = 84
            if framex is not None:
                pyxel.blt(
                    self.x + shake_x - 10, 
                    self.y + shake_y - 10, 
                    0, 
                    framex, 
                    231, 
                    21, 21, 
                    8
                )
        else:
            pyxel.blt(
                self.x + shake_x - 4, 
                self.y + shake_y - 4, 
                0, 
                160 + self.frame*9, 
                8, 
                9, 9, 
                8
            )
        
        