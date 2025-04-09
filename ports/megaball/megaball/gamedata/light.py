
import pyxel

import globals

TICKS_PER_FRAME = 10
MAX_FRAMES = 5

class Light:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        
        self.frame = 0
        self.frame_ticks = 0
        self.anim_dir = 1
        
        self.is_hit = False
        
    def got_hit(self):
        if self.is_hit == False:
            self.frame = 4
            self.is_hit = True
            globals.add_score(globals.SCORE_HIT_LIGHT)
            return True
        return False
        
    def update(self, stage):
        if not self.is_hit:
            self.frame_ticks += 1
            
            if self.frame_ticks == TICKS_PER_FRAME:
                self.frame_ticks = 0
                self.frame += self.anim_dir
                
                if self.frame == 0 or self.frame == MAX_FRAMES - 1:
                    self.anim_dir *= -1
            
    def draw(self, shake_x, shake_y):
        pyxel.blt(shake_x + self.x, shake_y + self.y, 0, 160 + self.frame*8, 0, 8, 8)
        