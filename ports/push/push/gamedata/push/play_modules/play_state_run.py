import pyxel
from hz3 import State
from input_system import InputSystem
import const

# PlayState:実行ステート
class RunState(State):
    def __init__(self, id:str, play):
        super().__init__(id)
        from s_play import Play
        self.play: Play = play


    def enter(self):
        pass

    def update(self):
        if const.DEBUG_MODE:
            if pyxel.btnp(pyxel.KEY_E):
                self.debug_show_map()

        if InputSystem.is_pressed(const.BUTTON_ID_REPLAY):
            self.statemachine.transition("init")

        if InputSystem.is_pressed(const.BUTTON_ID_MENU):
            self.play.play_statemachine.transition("menu")


    def debug_show_map(self):
        print("col:", self.play.frames_manager.grid_col, " x row:", self.play.frames_manager.grid_row)

        text = ""
        print("--------------------")
        for frame in self.play.frames_manager.frames:
            if frame.block == None or frame.block.id == const.TILE_PLAYER:
                text += "0"
            else:
                text += str(frame.block.id)
            
            if len(text) > self.play.frames_manager.grid_col - 1:
                print(text)
                text = ""
        print("--------------------")