
import pyxel

import constants
import palette
import hud
import input
import stage
import screenshake
import mainmenu
import globals
import audio

class Game:
    def __init__(self):
        self.pal_control = palette.PaletteControl()
        
        self.screen_shake = screenshake.ScreenShake(self)
        
        self.main_menu = mainmenu.MainMenu(self)
        self.stage = stage.Stage(self, 0)
        self.hud = hud.Hud(self)
        
        self.pal_index = 0
        
        audio.play_music(audio.MUS_TITLE, True)
        
    def restart_music(self):
        if self.main_menu.is_visible:
            audio.play_music(audio.MUS_TITLE)
        else:
            self.stage.restart_music()
        
    def quit_to_main_menu(self):
        del self.stage
        self.stage = stage.Stage(self, 0)
        globals.set_high_score()
        globals.reset()
        self.main_menu.reset()
        self.add_fade(palette.FADE_STEP_TICKS_DEFAULT, palette.FADE_LEVEL_3)
        
    def go_to_next_stage(self):
        globals.g_stage_num += 1
        del self.stage
        self.stage = stage.Stage(self, globals.g_stage_num)
        self.add_fade(palette.FADE_STEP_TICKS_DEFAULT, palette.FADE_LEVEL_3)
        
    def go_to_game_complete_stage(self):
        del self.stage
        self.stage = stage.Stage(self, stage.MAX_STAGE_NUM + 1)
        self.add_fade(palette.FADE_STEP_TICKS_DEFAULT, palette.FADE_LEVEL_3)
        
    def restart_stage(self):
        del self.stage
        self.stage = stage.Stage(self, globals.g_stage_num)
        self.add_fade(palette.FADE_STEP_TICKS_DEFAULT, palette.FADE_LEVEL_3)
        
    def start_game(self):
        self.main_menu.hide()
        del self.stage
        self.stage = stage.Stage(self, globals.g_stage_num)
        self.add_fade(palette.FADE_STEP_TICKS_DEFAULT, palette.FADE_LEVEL_3)
        
    def add_screen_shake(self, ticks, magnitude, queue=False):
        self.screen_shake.add_event(ticks, magnitude, queue)
        
    def cycle_palette(self):
        self.pal_index += 1
        if self.pal_index == len(palette.ALL):
            self.pal_index = 0
        self.pal_control.add_palette_event(1, palette.ALL[self.pal_index])
        self.add_fade(palette.FADE_STEP_TICKS_DEFAULT, palette.FADE_LEVEL_3)
        
    def add_fade(self, ticks_per_level, target_level, callback=None):
        self.pal_control.add_fade_event(ticks_per_level, target_level, callback)

    def update(self, last_inputs):
        if pyxel.btnp(pyxel.KEY_F1):
            globals.toggle_sound()
            
        if pyxel.btnp(pyxel.KEY_F2):
            globals.toggle_music(self)
    
        self.main_menu.update(last_inputs)
    
        self.stage.update(last_inputs)
    
        self.pal_control.update()
        self.screen_shake.update()
        
    def draw(self):
        for c in range(palette.NUM_COLOURS):
            pyxel.pal(palette.DEFAULT[c], self.pal_control.get_col(c))
    
        pyxel.cls(self.pal_control.get_col(0))
        
        self.stage.draw(self.screen_shake.x, self.screen_shake.y)
        self.hud.draw(self.screen_shake.x, self.screen_shake.y)
        
        self.main_menu.draw(self.screen_shake.x, self.screen_shake.y)
        
        pyxel.pal()
        