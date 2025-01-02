
import pyxel

import game
import constants
import globals
import utils
import stage

class Hud:
    def __init__(self, game):
        self.game = game
        
    def update(self):
        pass
        
    def draw(self, shake_x, shake_y):
        # top bar
        pyxel.blt(shake_x + 0, shake_y + 0, 0, 0, 0, constants.GAME_WIDTH, 16)
        # bottom bar
        pyxel.blt(shake_x + 0, shake_y + 136, 0, 0, 16, constants.GAME_WIDTH, 8)
        # left bar
        pyxel.blt(shake_x + 0, shake_y + 16, 0, 0, 24, 8, 120)
        # right bar
        pyxel.blt(shake_x + 152, shake_y + 16, 0, 8, 24, 8, 120)
            
        utils.draw_number_shadowed(shake_x + 31, shake_y + 5, globals.g_lives, zeropad=2)
        utils.draw_number_shadowed(shake_x + 57, shake_y + 5, globals.g_score, zeropad=6)
        utils.draw_number_shadowed(shake_x + 113, shake_y + 5, globals.g_stage_num, zeropad=2)
        utils.draw_number_shadowed(shake_x + 137, shake_y + 5, stage.MAX_STAGE_NUM, zeropad=2)
        