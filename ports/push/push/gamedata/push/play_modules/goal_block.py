import pyxel
from block import Block

class GoalBlock(Block):
    def __init__(self):
        super().__init__()

    
    def draw(self):
        pyxel.blt(
            self.x + self.offset_x, self.y + self.offset_y,
            self.img,
            self.u, self.v,
            self.w, self.h,
            self.clear_col
        )

        # pyxel.rect(
        #     self.x + self.offset_x, 
        #     self.y + self.offset_y, 
        #     16, 16, 
        #     pyxel.frame_count % 3)