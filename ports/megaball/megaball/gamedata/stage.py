
import math
import random

import pyxel

import player
import utils
import constants
import stage
import light
import input
import game
import palette
import spinner
import globals
import stagedata
import audio

TILEMAP_SCALE = 8
# Mokeypatch in get() to simulate old tilemap API
def custom_get_tile(self, x, y):
    tile_x = x // TILEMAP_SCALE
    tile_y = y // TILEMAP_SCALE
    if 0 <= tile_x < self.width and 0 <= tile_y < self.height:
        return self.pget(tile_x, tile_y)
    return None
pyxel.Tilemap.get = custom_get_tile

MAX_STAGE_NUM = 15

WIDTH_TILES = 18
HEIGHT_TILES = 15

POST_TILE = 37 # utils.get_tile_index(40, 32)

# tile_index : [angle, collision matrix if triangle]
'''
SLOPE_TILES = {
    utils.get_tile_index(56,32): [225, constants.COLLIDE_BOTTOM_RIGHT], # top-left
    utils.get_tile_index(64,32): [270, None], # top
    utils.get_tile_index(72,32): [315, constants.COLLIDE_BOTTOM_LEFT], # top-right
    utils.get_tile_index(56,40): [180, None], # left
    utils.get_tile_index(72,40): [0, None], # right
    utils.get_tile_index(56,48): [135, constants.COLLIDE_TOP_RIGHT], # bottom-left
    utils.get_tile_index(64,48): [90, None], # bottom
    utils.get_tile_index(72,48): [45, constants.COLLIDE_TOP_LEFT],  # bottom-right
    utils.get_tile_index(80,32): [225, constants.COLLIDE_TOP_LEFT], # top-left 2
    utils.get_tile_index(88,32): [135, constants.COLLIDE_BOTTOM_LEFT], # bottom-left 2
    utils.get_tile_index(80,40): [45, constants.COLLIDE_BOTTOM_RIGHT], # bottom-right 2
    utils.get_tile_index(88,40): [315, constants.COLLIDE_TOP_RIGHT] # top-right 2
    #utils.get_tile_index(),
}
'''
SLOPE_TILES = {
    39: [225, constants.COLLIDE_BOTTOM_RIGHT], # top-left
    40: [270, None], # top
    41: [315, constants.COLLIDE_BOTTOM_LEFT], # top-right
    47: [180, None], # left
    49: [0, None], # right
    55: [135, constants.COLLIDE_TOP_RIGHT], # bottom-left
    56: [90, None], # bottom
    57: [45, constants.COLLIDE_TOP_LEFT],  # bottom-right
    42: [225, constants.COLLIDE_TOP_LEFT], # top-left 2
    43: [135, constants.COLLIDE_BOTTOM_LEFT], # bottom-left 2
    50: [45, constants.COLLIDE_BOTTOM_RIGHT], # bottom-right 2
    51: [315, constants.COLLIDE_TOP_RIGHT] # top-right 2
    #utils.get_tile_index(),
}

POCKET_TILE_NW = 50 #utils.get_tile_index(80,40)
POCKET_TILE_NE = 43 #utils.get_tile_index(88,32)
POCKET_TILE_SE = 42 #utils.get_tile_index(80,32)
POCKET_TILE_SW = 51 #utils.get_tile_index(88,40)

LIGHT_TILE = 20 #utils.get_tile_index(160,0)
BLANK_TILE = 100 #utils.get_tile_index(32,24)

class PauseMenu:

    SEL_RESUME = 0
    SEL_PALETTE = 1
    SEL_QUIT = 2
    
    SELECTIONS = {
        SEL_RESUME : [56,55,48,8],
        SEL_PALETTE : [52,71,56,8],
        SEL_QUIT : [64,87,32,8]
    }

    def __init__(self, stage):
        self.stage = stage
    
        self.is_visible = False
        
        self.sel_index = 0
        
        self.quitting = False
        
    def _pressed_select(self):
        if self.sel_index == self.SEL_RESUME:
            self.is_visible = False
        elif self.sel_index == self.SEL_PALETTE:
            self.stage.game.add_fade(5, palette.FADE_LEVEL_6, self.stage.game.cycle_palette)
        elif self.sel_index == self.SEL_QUIT:
            self.quitting = True
            self.stage.quit()
            
    def _change_selection(self, dir):
        self.sel_index += dir
        if self.sel_index < 0:
            self.sel_index = len(self.SELECTIONS) - 1
        elif self.sel_index >= len(self.SELECTIONS):
            self.sel_index = 0
        
    def update(self, last_inputs):
        if not self.is_visible or self.quitting:
            return
            
        if input.BUTTON_START in last_inputs.pressed:
            self.is_visible = False
            self.sel_index = 0
        elif input.BUTTON_A in last_inputs.pressed:
            self._pressed_select()
        elif input.UP in last_inputs.pressed:
            self._change_selection(-1)
        elif input.DOWN in last_inputs.pressed:
            self._change_selection(1)  
 
    def draw(self, shake_x, shake_y):
        if not self.is_visible:
            return
            
        pyxel.blt(shake_x + 24, shake_y + 52, 0, 0, 144, 116, 52, 8) # panel bg
        
        pyxel.blt(shake_x + 56, shake_y + 56, 0, 128, 72, 48, 8, 8) # resume
        pyxel.blt(shake_x + 52, shake_y + 72, 0, 104, 80, 56, 8, 8) # palette
        pyxel.blt(shake_x + 64, shake_y + 88, 0, 96, 64, 32, 8, 8) # quit
        
        pyxel.blt(
            shake_x + self.SELECTIONS[self.sel_index][0]-12, 
            shake_y + self.SELECTIONS[self.sel_index][1], 
            0, 
            16, 33, 9, 9, 8
        ) # selection ball left
        pyxel.blt(
            shake_x + self.SELECTIONS[self.sel_index][0] + self.SELECTIONS[self.sel_index][2] + 2, 
            shake_y + self.SELECTIONS[self.sel_index][1], 
            0, 
            16, 33, 9, 9, 8
        ) # selection ball right

STATE_INTRO = 0
STATE_PLAY = 1
STATE_DIED = 2
STATE_DEMO = 3
STATE_GAME_OVER = 4
STATE_STAGE_COMPLETE = 5
STATE_GAME_COMPLETE = 6
STATE_PLAYER_WEAPON = 7

MAX_SHOW_GAME_OVER_TICKS = 300 # 5 secs
MAX_SHOW_GAME_COMPLETE_TICKS = 300 # 5 secs

SPAWN_SECTOR_TOPLEFT = 0
SPAWN_SECTOR_TOPRIGHT = 1
SPAWN_SECTOR_BOTTOMLEFT = 2
SPAWN_SECTOR_BOTTOMRIGHT = 3

class Stage:
    def __init__(self, game, num):
        self.game = game
        self.num = num
        self.tm = 0
        self.tmu = 0
        self.tmv = num * 16 *TILEMAP_SCALE
        
        self.state = STATE_INTRO
        if self.num <= 0:
            self.state = STATE_DEMO
        elif self.num == MAX_STAGE_NUM + 1:
            self.tm = 1
            self.tmu = 0
            self.tmv = 0
            self.state = STATE_GAME_COMPLETE
        
        self.solid_rects = [
            [0, 0, 160, 16], # [x, y, w, h]
            [0, 16, 8, 128],
            [152, 16, 8, 128],
            [0, 136, 160, 8]
        ]
        
        self.slopes = [] # [x, y]
        self.pockets = [] # [x, y, w, h]
        self.lights = [] # Light objects
        self.spinners = [] # Spinner objects
        
        #self.en_spawn_locs_topleft = [] # [[x,y],[x,y],[x,y]...]
        #self.en_spawn_locs_topright = [] # [[x,y],[x,y],[x,y]...]
        #self.en_spawn_locs_bottomleft = [] # [[x,y],[x,y],[x,y]...]
        #self.en_spawn_locs_bottomright = [] # [[x,y],[x,y],[x,y]...]

        # Hardcode spawn locations (becuase they stopped working)
        self.en_spawn_locs_topleft = [
            [12, 20], [20, 20], [28, 20], [36, 20], [44, 20],
            [12, 28], [20, 28], [28, 28], [36, 28], [44, 28],
            [12, 36], [20, 36], [28, 36], [36, 36], [44, 36],
            [12, 44], [20, 44], [28, 44], [36, 44], [44, 44]
        ]
        self.en_spawn_locs_topright = [
            [92, 20], [100, 20], [108, 20], [116, 20], [124, 20],
            [92, 28], [100, 28], [108, 28], [116, 28], [124, 28],
            [92, 36], [100, 36], [108, 36], [116, 36], [124, 36],
            [92, 44], [100, 44], [108, 44], [116, 44], [124, 44]
        ]
        self.en_spawn_locs_bottomleft = [
            [12, 76], [20, 76], [28, 76], [36, 76], [44, 76],
            [12, 84], [20, 84], [28, 84], [36, 84], [44, 84],
            [12, 92], [20, 92], [28, 92], [36, 92], [44, 92],
            [12, 100], [20, 100], [28, 100], [36, 100], [44, 100]
        ]
        self.en_spawn_locs_bottomright = [
            [92, 76], [100, 76], [108, 76], [116, 76], [124, 76],
            [92, 84], [100, 84], [108, 84], [116, 84], [124, 84],
            [92, 92], [100, 92], [108, 92], [116, 92], [124, 92],
            [92, 100], [100, 100], [108, 100], [116, 100], [124, 100]
        ]

        if self.state != STATE_GAME_COMPLETE:
            for yc in range(0, HEIGHT_TILES *TILEMAP_SCALE, TILEMAP_SCALE):
                y = self.tmv + yc
                for xc in range(0, WIDTH_TILES *TILEMAP_SCALE, TILEMAP_SCALE):
                    x = self.tmu + xc
                    tile = pyxel.tilemaps[self.tm].get(x, y)
                    tile_index = tile[1] * TILEMAP_SCALE + tile[0]

                    if tile_index == POST_TILE: #if tile == POST_TILE:
                        #self.solid_rects.append([xc*8 + 8, yc*8 + 16, 8, 8])
                        self.solid_rects.append([xc*8//TILEMAP_SCALE + 8, yc*8//TILEMAP_SCALE + 16, 8, 8])
                    elif tile_index in SLOPE_TILES: #if tile == SLOPE_TILES:
                        #self.slopes.append([xc*8 + 8, yc*8 + 16])
                        self.slopes.append([xc*8//TILEMAP_SCALE + 8, yc*8//TILEMAP_SCALE + 16])
                    elif tile_index == LIGHT_TILE: #if tile == LIGHT_TILE:
                        #self.lights.append(light.Light(xc*8 + 8, yc*8 + 16))
                        self.lights.append(light.Light(xc*8//TILEMAP_SCALE + 8, yc*8//TILEMAP_SCALE + 16))

                    if tile == POCKET_TILE_NW:
                        if x < self.tmu + WIDTH_TILES-1 and y < self.tmv + HEIGHT_TILES-1:
                            if pyxel.tilemaps[self.tm].get(x+1, y) == POCKET_TILE_NE and\
                                pyxel.tilemaps[self.tm].get(x+1, y+1) == POCKET_TILE_SE and\
                                pyxel.tilemaps[self.tm].get(x, y+1) == POCKET_TILE_SW:
                                    self.pockets.append([xc*8 + 8, yc*8 + 16, 16, 16])
                                    
                    if tile != POST_TILE and \
                        xc > 0 and \
                        xc < WIDTH_TILES-1 and \
                        yc > 0 and \
                        yc < HEIGHT_TILES-1 and \
                        (xc < 5 or xc > WIDTH_TILES-6) and \
                        (yc < 5 or yc > HEIGHT_TILES-6):
                        
                        loc = [xc*8 + 8 + 4, yc*8 + 16 + 4]
                        
                        if xc < 9:
                            if yc < 7:
                                self.en_spawn_locs_topleft.append(loc)
                            else:
                                self.en_spawn_locs_bottomleft.append(loc)
                        else:
                            if yc < 7:
                                self.en_spawn_locs_topright.append(loc)
                            else:
                                self.en_spawn_locs_bottomright.append(loc)

            #print(self.pockets)
            num_spinners = 0
            stage_diff_name = stagedata.STAGE_DIFFICULTY[self.num]
            for i in range(len(spinner.TYPES)):
                en_qty = stagedata.ENEMIES[stage_diff_name][stagedata.SPINNER_KEY][i]
                for sq in range(en_qty):
                    loc = self.get_random_spawn_loc(-1)
                    self.spinners.append(spinner.Spinner(loc[0], loc[1], i))
        
        self.player = player.Player(75,75)#(12, 20)
        if self.state == STATE_GAME_COMPLETE:
            self.player.state = player.STATE_GAME_COMPLETE
            audio.play_music(audio.MUS_IN_GAME, True)
        else:
            if self.state != STATE_DEMO:
                audio.play_music(audio.MUS_START, False)
        
        self.pause_menu = PauseMenu(self)
        
        self.stage_over_ticks = 0
        
        self.next_stage_flash_num = 0
        
    def restart_music(self):
        if self.state == STATE_PLAY:
            audio.play_music(audio.MUS_IN_GAME)
        
    def get_random_spawn_loc(self, sector):
        if sector == SPAWN_SECTOR_TOPLEFT:
            return random.choice(self.en_spawn_locs_topleft)
        elif sector == SPAWN_SECTOR_TOPRIGHT:
            return random.choice(self.en_spawn_locs_topright)
        elif sector == SPAWN_SECTOR_BOTTOMLEFT:
            return random.choice(self.en_spawn_locs_bottomleft)
        elif sector == SPAWN_SECTOR_BOTTOMRIGHT:
            return random.choice(self.en_spawn_locs_bottomright)
        else:
            ranlist = random.choice([
                self.en_spawn_locs_topleft,
                self.en_spawn_locs_topright,
                self.en_spawn_locs_bottomleft,
                self.en_spawn_locs_bottomright
            ])
            return random.choice(ranlist)
        
    def player_used_weapon(self):
        audio.play_sound(audio.SND_USED_WEAPON)
        self.state = STATE_PLAYER_WEAPON
        
    def player_intro_done(self):
        if self.state != STATE_PLAYER_WEAPON:
            audio.play_music(audio.MUS_IN_GAME, True)
            
        self.state = STATE_PLAY
        
    def player_hit(self):
        self.state = STATE_DIED
        audio.play_music(audio.MUS_DEATH, False)
        
    def is_complete(self):
        for i in self.lights:
            if i.is_hit == False:
                return False
                
        audio.play_music(audio.MUS_STAGE_COMPLETE, False)
        self._check_next_stage()
        
        return True
        
    def player_death_anim_done(self):
        if globals.g_lives >= 1:
            globals.g_lives -= 1
            self.game.add_fade(palette.FADE_STEP_TICKS_DEFAULT, 
                palette.FADE_LEVEL_6, self.game.restart_stage)
        else:
            self.state = STATE_GAME_OVER
            audio.play_music(audio.MUS_GAME_OVER, False)
            
    def _check_next_stage(self):
        #if self.num < MAX_STAGE_NUM:
        self.state = STATE_STAGE_COMPLETE
        self.game.add_fade(palette.FADE_STEP_TICKS_DEFAULT, 
            palette.FADE_LEVEL_0, self.go_to_next_stage)
        #else:
        #    self.state = STATE_GAME_COMPLETE
            
    def go_to_next_stage(self):
        if self.next_stage_flash_num == 0:
            self.game.add_fade(palette.FADE_STEP_TICKS_SLOW, 
                palette.FADE_LEVEL_3, self.go_to_next_stage)
        elif self.next_stage_flash_num == 1:
            self.game.add_fade(palette.FADE_STEP_TICKS_SLOW, 
                palette.FADE_LEVEL_0, self.go_to_next_stage)
        #elif self.next_stage_flash_num == 2:
        #    self.game.add_fade(palette.FADE_STEP_TICKS_SLOW, 
        #        palette.FADE_LEVEL_3, self.go_to_next_stage)
        #elif self.next_stage_flash_num == 3:
        #    self.game.add_fade(palette.FADE_STEP_TICKS_SLOW, 
        #        palette.FADE_LEVEL_0, self.go_to_next_stage)
        else:
            if self.num == stage.MAX_STAGE_NUM:
                self.game.add_fade(palette.FADE_STEP_TICKS_SLOW, 
                    palette.FADE_LEVEL_6, self.game.go_to_game_complete_stage)
            else:
                globals.add_lives(1)
                self.game.add_fade(palette.FADE_STEP_TICKS_SLOW, 
                    palette.FADE_LEVEL_6, self.game.go_to_next_stage)
                
        self.next_stage_flash_num += 1
        
    def quit(self):
        self.game.add_fade(palette.FADE_STEP_TICKS_DEFAULT, 
            palette.FADE_LEVEL_6, self.game.quit_to_main_menu)
        
    def player_hit_solid(self):
        audio.play_sound(audio.SND_HIT_WALL)
        self.game.add_screen_shake(5, 1, queue=False)
    
    # returns None or angle
    def get_tile_angle(self, x, y):  # x, y is screen pixels
        tile = pyxel.tilemaps[self.tm].get(
            self.tmu + math.floor((x - 8) / 8 * TILEMAP_SCALE),
            self.tmv + math.floor((y - 16) / 8 * TILEMAP_SCALE)
        )
        tile_index = tile[1] * TILEMAP_SCALE + tile[0]
        #print(tile_index)

        if tile_index in SLOPE_TILES:
            # Check if triangle matrix collision is needed
            if SLOPE_TILES[tile_index][1] is not None:
                t = SLOPE_TILES[tile_index]

                tx = math.floor(abs(x - math.floor(x / 8) * 8 * TILEMAP_SCALE))
                ty = math.floor(abs(y - math.floor(y / 8) * 8 * TILEMAP_SCALE))

                #print(f"Checking matrix x,y: {tx},{ty} ...")

                if constants.is_colliding_matrix(tx, ty, t[1]):
                    #print(f"{x}, {y} hit triangle")
                    #print("... collides.")
                    return t[0]
                else:
                    #print("... no collision.")
                    return None
            else:
                #print(SLOPE_TILES[tile_index][0])
                return SLOPE_TILES[tile_index][0]
        else:
            return None

    def update(self, last_inputs):
        if self.num > 0: # dont allow inputs on demo/main menu stage 0.
            if self.pause_menu.is_visible:
                self.pause_menu.update(last_inputs)
            else:
                if input.BUTTON_START in last_inputs.pressed:
                    if self.state == STATE_PLAY or \
                        self.state == STATE_PLAYER_WEAPON:
                        self.pause_menu.is_visible = True
                else:
                    self.player.update(self, last_inputs)
                    
                    if self.state == STATE_PLAY or\
                        self.state == STATE_DEMO:
                        for s in self.spinners:
                            s.update(self)
                            
                if self.state == STATE_GAME_OVER:
                    self.stage_over_ticks += 1
                    if self.stage_over_ticks == MAX_SHOW_GAME_OVER_TICKS:
                        self.quit()
                elif self.state == STATE_GAME_COMPLETE:
                    self.stage_over_ticks += 1
                    if self.stage_over_ticks >= MAX_SHOW_GAME_COMPLETE_TICKS:
                        if input.BUTTON_A in last_inputs.pressed:
                            self.quit()
                            
        if self.state == STATE_PLAY or\
            self.state == STATE_DEMO:            
            for i in self.lights:
                i.update(self)
            
    def draw(self, shake_x, shake_y):
        pyxel.bltm(shake_x + 8, shake_y + 16, self.tm, self.tmu, self.tmv, 
            WIDTH_TILES *TILEMAP_SCALE, HEIGHT_TILES *TILEMAP_SCALE, 8)
            
        for i in self.lights:
            i.draw(shake_x, shake_y)
            
        if self.state == STATE_GAME_COMPLETE:
            pyxel.blt(24 + shake_x, 32 + shake_y, 0, 136, 136, 112, 88)
        
        if self.num > 0:
            self.player.draw(shake_x, shake_y)
            
        for s in self.spinners:
            s.draw(shake_x, shake_y)
            
        if self.num > 0:
            self.pause_menu.draw(shake_x, shake_y)
            
        if self.state == STATE_GAME_OVER and self.stage_over_ticks > 30:
            pyxel.blt(32 + shake_x, 66 + shake_y, 0, 0, 196, 100, 26, 8) # game over bg
            pyxel.blt(44 + shake_x, 72 + shake_y, 0, 40, 80, 32, 8, 8) # "game"
            pyxel.blt(84 + shake_x, 72 + shake_y, 0, 72, 80, 32, 8, 8) # "over"

        # DEBUGGING
        '''
        for solid_rect in self.solid_rects:
            x, y, w, h = solid_rect
            pyxel.rectb(shake_x + x, shake_y + y, TILEMAP_SCALE, TILEMAP_SCALE, pyxel.COLOR_BLACK)

        for slope in self.slopes:
            x = slope[0]
            y = slope[1]
            pyxel.rectb(shake_x + x, shake_y + y, TILEMAP_SCALE, TILEMAP_SCALE, pyxel.COLOR_YELLOW)

        for light in self.lights:
            x = light.x
            y = light.y
            pyxel.rectb(shake_x + x, shake_y + y, TILEMAP_SCALE, TILEMAP_SCALE, pyxel.COLOR_RED)
        '''
