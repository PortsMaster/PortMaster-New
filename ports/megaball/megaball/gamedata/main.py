
import pyxel

import constants
import input
import game

class App:
    def __init__(self):
        pyxel.init(
          width=constants.GAME_WIDTH, 
          height=constants.GAME_HEIGHT, 
          fps=constants.GAME_FPS
        )
        pyxel.scale=constants.GAME_SCALE
        pyxel.caption = constants.GAME_TITLE
        
        pyxel.load(constants.RESOURCE_FILE)
        pyxel.images[0].load(0, 0, constants.IMAGE_BANK_0_FILE)

        self.input = input.Input()
        self.game = game.Game()
        pyxel.mouse(False)
        #pyxel.mouse(True)

        pyxel.run(self.update, self.draw)

    def update(self):
        self.input.get()
        self.game.update(self.input)
        
    def draw(self):
        self.game.draw()

App()
  
