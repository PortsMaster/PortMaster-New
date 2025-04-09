
import math

import pyxel

import utils
import input
import rect
import circle
import light
import weapon
import globals
import audio

MAX_SPEED = 1.2
DECEL = 0.01
ACCEL = 0.06
SLOPE_ACCEL = 0.10

HIT_SOLID_DAMP = 0.7

INTRO_TICKS_PER_FRAME = 10
DEAD_TICKS_PER_FRAME = 10

STATE_INTRO = 0
STATE_PLAY = 1
STATE_DEAD = 2
STATE_STAGE_COMPLETE = 3
STATE_GAME_COMPLETE = 4
STATE_WEAPON = 5

class Player:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        
        self.vx = 0
        self.vy = 0
        
        self.radius = 4
        
        self.state = STATE_INTRO
        
        self.intro_frame = 4
        self.dead_frame = 0
        
        self.anim_ticks = 0
        
        self.weapon = weapon.Weapon()
        
    def _do_solid_collisions(self, stage):
        new_x = self.x + self.vx
        
        for b in stage.solid_rects:
            if utils.circle_rect_overlap(new_x, self.y, self.radius,
                b[0], b[1], b[2], b[3]):
                if self.x > b[0] + b[2]: # was prev to right of border.
                    new_x = b[0] + b[2] + self.radius
                elif self.x < b[0]: # was prev to left of border.
                    new_x = b[0] - self.radius
                
                self.vx *= -HIT_SOLID_DAMP
                stage.player_hit_solid()
                break
                
        new_y = self.y + self.vy
        
        for b in stage.solid_rects:
            if utils.circle_rect_overlap(self.x, new_y, self.radius,
                b[0], b[1], b[2], b[3]):
                if self.y > b[1] + b[3]: # was prev below border.
                    new_y = b[1] + b[3] + self.radius
                elif self.y < b[1]: # was prev above border.
                    new_y = b[1] - self.radius
                
                self.vy *= -HIT_SOLID_DAMP
                stage.player_hit_solid()
                break
                
        self.x = new_x
        self.y = new_y
        
    def _get_input_angle(self, last_inputs):
        press_angle = None
        if input.LEFT in last_inputs.pressing:
            press_angle = 180
        elif input.RIGHT in last_inputs.pressing:
            press_angle = 0
            
        if input.UP in last_inputs.pressing:
            if press_angle == 0:
                press_angle = 315
            elif press_angle == 180:
                press_angle = 225
            else:
                press_angle = 270
        elif input.DOWN in last_inputs.pressing:
            if press_angle == 0:
                press_angle = 45
            elif press_angle == 180:
                press_angle = 135
            else:
                press_angle = 90
            
        return press_angle
        
    # a "force" is a list of lists: [[speed, angle]... etc].
    def _apply_forces(self, forces):
        for f in forces:
            self.vx = max(-MAX_SPEED, 
                min(MAX_SPEED, 
                self.vx + f[0] * math.cos(math.radians(f[1]))))
            self.vy = max(-MAX_SPEED, 
                min(MAX_SPEED, 
                self.vy + f[0] * math.sin(math.radians(f[1]))))
            #print("py after: " + str(self.y))
                
    def _get_tile_force(self, stage, forces):
        angle = stage.get_tile_angle(self.x, self.y)
        if angle is not None:
            forces.append([SLOPE_ACCEL, angle])
            #print("Got tile force: spd:{a}, accl:{b}".format(a=SLOPE_ACCEL, b=angle))
            
    def _is_stuck_in_pocket(self, stage):
        if abs(self.vx) > 0.01 or abs(self.vy) > 0.01:
            return False
            
        for p in stage.pockets:
            if rect.contains_point(p[0], p[1], p[2], p[3], self.x, self.y):
                return True
                
    def _do_enemy_collisions(self, stage):
        for s in stage.spinners:
            if s.is_dead:
                continue
            if circle.overlap(s.x, s.y, s.radius, self.x, self.y, self.radius):
                self.state = STATE_DEAD
                stage.player_hit()
                return
                
    def _do_light_collisions(self, stage):
        for s in stage.lights:
            if rect.contains_point(s.x, s.y, 8, 8, self.x, self.y):
                if s.got_hit() == True:
                    audio.play_sound(audio.SND_HIT_TARGET)
                    if stage.is_complete():
                        self.state = STATE_STAGE_COMPLETE
                        globals.add_score(globals.SCORE_STAGE_COMPLETE)
                return
                
    def fire_weapon(self, stage):
        self.weapon.fire(self.x, self.y)
        self.state = STATE_WEAPON
        globals.g_lives -= 1
        stage.player_used_weapon()
        globals.add_score(globals.SCORE_USE_WEAPON)
                
    def weapon_done(self):
        self.state = STATE_INTRO
        self.intro_frame = 4
        self.anim_ticks = 0
        self.vx = 0
        self.vy = 0
        
    def update(self, stage, last_inputs):
        if self.state == STATE_INTRO:
            self.anim_ticks += 1
            if self.anim_ticks == INTRO_TICKS_PER_FRAME:
                self.anim_ticks = 0
                if self.intro_frame > -1:
                    self.intro_frame -= 1
                    
                    if self.intro_frame == -1:
                        self.intro_frame = 4
                        self.state = STATE_PLAY
                        stage.player_intro_done()
            return
        elif self.state == STATE_DEAD:
            self.anim_ticks += 1
            if self.anim_ticks == DEAD_TICKS_PER_FRAME:
                self.anim_ticks = 0
                
                if self.dead_frame < 11:
                    self.dead_frame += 1
                    
                    if self.dead_frame == 11:
                        stage.player_death_anim_done()
            return
        elif self.state == STATE_STAGE_COMPLETE:
            return
        elif self.state == STATE_WEAPON:
            self.weapon.update(self, stage)
            return
    
        forces = []
    
        #print("py after: " + str(self.y))
    
        input_angle = self._get_input_angle(last_inputs)
        if input_angle is not None:
            forces.append([ACCEL, input_angle])
            
        if not self._is_stuck_in_pocket(stage):
            self._get_tile_force(stage, forces)
                
        self._apply_forces(forces)
        
        if self.vx > 0:
            self.vx = max(0, self.vx - DECEL)
        elif self.vx < 0:
            self.vx = min(0, self.vx + DECEL)
            
        if self.vy > 0:
            self.vy = max(0, self.vy - DECEL)
        elif self.vy < 0:
            self.vy = min(0, self.vy + DECEL)
            
        #print("vx,vy: {a},{b}".format(a=self.vx, b=self.vy))
        
        self._do_solid_collisions(stage)
        
        self._do_enemy_collisions(stage)
        
        if self.state != STATE_DEAD and self.state != STATE_GAME_COMPLETE:
            self._do_light_collisions(stage)

            if input.BUTTON_A in last_inputs.pressed and \
                self.state != STATE_WEAPON and \
                globals.g_lives > 0:
                self.fire_weapon(stage)
        
        #print("py after: " + str(self.y))
        
        #if pyxel.mouse_x >= 8 and pyxel.mouse_x < 152 and \
        #    pyxel.mouse_y >= 16 and pyxel.mouse_y < 136:
        #    ang = stage.get_tile_angle(pyxel.mouse_x, pyxel.mouse_y)
            #if ang is not None:
            #    print("Hit slope angle {a},{b}: ".format(a=pyxel.mouse_x,b=pyxel.mouse_y)\
            #        + str(ang) + ", " + str(pyxel.frame_count))
                    
        
    def draw(self, shake_x, shake_y):
        if self.state == STATE_INTRO:   
            pyxel.blt(shake_x + self.x-10, shake_y + self.y-10, 0,
                self.intro_frame*21, 231, 21, 21, 8)
        elif self.state == STATE_DEAD:
            pyxel.blt(shake_x + self.x-10, shake_y + self.y-10, 0,
                self.dead_frame*21, 231, 21, 21, 8)
        elif self.state == STATE_WEAPON:
            self.weapon.draw(shake_x, shake_y)
        else:
            pyxel.blt(shake_x + self.x-self.radius, shake_y + self.y-self.radius, 0,
                16, 33, 9, 9, 8)
            
        #pyxel.circb(self.x, self.y, self.radius, 8)
        