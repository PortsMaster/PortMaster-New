
import pyxel

import utils
import globals
import game
import input
import palette
import audio

SEL_START_GAME = 0
SEL_PALETTE = 1
SEL_EXIT_GAME = 2

SELECTIONS = {
    SEL_START_GAME : [40,87,80,8], # [x, y, w, h]
    SEL_PALETTE : [52,103,56,8],
    SEL_EXIT_GAME : [44,119,72,8]
}

class MainMenu:
    def __init__(self, game):
        self.game = game
        
        self.is_visible = True
        
        self.show_press_start = True
        self.press_start_flash_ticks = 0
        self.sel_index = 0
        
    def hide(self):
        self.is_visible = False
        
    def reset(self):
        self.is_visible = True
        self.show_press_start = True
        self.press_start_flash_ticks = 0
        self.sel_index = 0
        audio.play_music(audio.MUS_TITLE, True)
        
    def _pressed_select(self):
        audio.play_sound(audio.SND_MENU_SELECT)
        if self.sel_index == SEL_START_GAME:
            self.game.add_fade(palette.FADE_STEP_TICKS_DEFAULT, 
                palette.FADE_LEVEL_6, self.game.start_game)
        elif self.sel_index == SEL_PALETTE:
            self.game.add_fade(palette.FADE_STEP_TICKS_DEFAULT, 
                palette.FADE_LEVEL_6, self.game.cycle_palette)
        elif self.sel_index == SEL_EXIT_GAME:
            self.game.add_fade(palette.FADE_STEP_TICKS_DEFAULT, 
                palette.FADE_LEVEL_0, pyxel.quit)
            
    def _change_selection(self, dir):
        audio.play_sound(audio.SND_MENU_MOVE)
        self.sel_index += dir
        if self.sel_index < 0:
            self.sel_index = len(SELECTIONS) - 1
        elif self.sel_index >= len(SELECTIONS):
            self.sel_index = 0
        
    def update(self, last_inputs):
        if not self.is_visible:
            return
    
        if self.show_press_start:
            self.press_start_flash_ticks += 1
            if self.press_start_flash_ticks == 50:
                self.press_start_flash_ticks = 0
            if input.BUTTON_START in last_inputs.pressed:
                self.show_press_start = False
                self.sel_index = 0
        else:
            if input.BUTTON_A in last_inputs.pressed:
                self._pressed_select()
            elif input.UP in last_inputs.pressed:
                self._change_selection(-1)
            elif input.DOWN in last_inputs.pressed:
                self._change_selection(1)
        
    def draw(self, shake_x, shake_y):
        if not self.is_visible:
            return
            
        if self.show_press_start:
            if self.press_start_flash_ticks < 30:
                pyxel.blt(shake_x + 36, shake_y + 104, 0, 16, 72, 40, 8, 8) # press
                pyxel.blt(shake_x + 84, shake_y + 104, 0, 56, 72, 40, 8, 8) # start
        else:
            pyxel.blt(shake_x + 24, shake_y + 84, 0, 0, 144, 116, 52, 8) # panel bg
        
            pyxel.blt(shake_x + 40, shake_y + 88, 0, 56, 72, 40, 8, 8) # start
            pyxel.blt(shake_x + 88, shake_y + 88, 0, 40, 80, 32, 8, 8) # game
            
            pyxel.blt(shake_x + 52, shake_y + 104, 0, 104, 80, 56, 8, 8) # palette
            
            pyxel.blt(shake_x + 44, shake_y + 120, 0, 96, 72, 32, 8, 8) # exit
            pyxel.blt(shake_x + 84, shake_y + 120, 0, 40, 80, 32, 8, 8) # game
            
            pyxel.blt(
                shake_x + SELECTIONS[self.sel_index][0]-12, 
                shake_y + SELECTIONS[self.sel_index][1], 
                0, 
                16, 33, 9, 9, 8
            ) # selection ball left
            pyxel.blt(
                shake_x + SELECTIONS[self.sel_index][0] + SELECTIONS[self.sel_index][2] + 2, 
                shake_y + SELECTIONS[self.sel_index][1], 
                0, 
                16, 33, 9, 9, 8
            ) # selection ball right
    
        pyxel.blt(shake_x + 44, shake_y + 20, 0, 16, 80, 24, 8, 8) # hi-
        utils.draw_number_shadowed(shake_x + 68, shake_y + 20, 
            globals.g_highscore, zeropad=6) # highscore number
        pyxel.blt(shake_x + 13, shake_y + 36, 0, 16, 88, 135, 44, 8) # logo
        
        
        