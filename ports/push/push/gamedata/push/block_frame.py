import pyxel
from block import Block
from play_modules.goal_block import GoalBlock
import hz3
import const

from blocks_data import BlocksData

class BlockFrame():
    def __init__(self, x:float, y:float, frames_manager):
        # ブロック
        self.block: Block = None

        from block_frame import BlockFramesManager
        self.frames_manager: BlockFramesManager = frames_manager

        # 位置座標
        self.x = 0
        self.y = 0
        self.relative_x = x
        self.relative_y = y
        # グリッド座標
        self.grid_x: int = 0
        self.grid_y: int = 0
        # グリッドサイズ
        self.grid_w: int = 0
        self.grid_h: int = 0

        self.is_mouse_focus = False

    def set_grid_pos(self, x, y):
        self.grid_x = x
        self.grid_y = y

    def set_block(self, block:Block):
        self.block = block

    def remove_block(self):
        self.block = None

    def debug_update(self, blocks_data: BlocksData):
        self.is_mouse_focus = self.is_hit_rects(self.x, self.y, self.x + 16, self.y + 16, pyxel.mouse_x, pyxel.mouse_y, pyxel.mouse_x + 1, pyxel.mouse_y + 1)

        if self.is_mouse_focus:
            tile_id = -1
            if pyxel.btnp(pyxel.MOUSE_BUTTON_RIGHT):
                tile_id = const.TILE_FLOOR
            elif pyxel.btnp(pyxel.KEY_1):
                tile_id = const.TILE_BLOCK
            elif pyxel.btnp(pyxel.KEY_2):
                tile_id = const.TILE_HOLE
            elif pyxel.btnp(pyxel.KEY_3):
                tile_id = const.TILE_WALL
            elif pyxel.btnp(pyxel.KEY_4):
                tile_id = const.TILE_GOAL

            if tile_id != -1:
                del(self.block)
                match tile_id:
                    case const.TILE_FLOOR:
                        self.block = None
                    case const.TILE_BLOCK:
                        self.block = Block()
                        self.block.reload_block_data(blocks_data, "move", 1)
                    case const.TILE_HOLE:
                        self.block = Block()
                        self.block.reload_block_data(blocks_data, "hole", 1)
                    case const.TILE_WALL:
                        self.block = Block()
                        self.block.reload_block_data(blocks_data, "wall", 1)
                    case const.TILE_GOAL:
                        self.block = GoalBlock()
                        self.block.reload_block_data(blocks_data, "goal", 4)
                        self.block.anim_interval = 8

                if self.block != None:
                    self.block.id = tile_id
                    self.frames_manager.set_block(self.block, self.grid_x, self.grid_y)

    def debug_draw(self):
        if self.is_mouse_focus:
            pyxel.rectb(self.x, self.y, 16, 16, const.COL_ORANGE_0)

    # 矩形当たり判定
    def is_hit_rects(self, 
                    ax_l: float, ay_l: float, 
                    ax_r: float, ay_r: float, 
                    bx_l: float, by_l: float, 
                    bx_r: float, by_r: float):
        """矩形当たり判定

        Args:
            ax_l (float): 矩形AのX座標:左
            ay_l (float): 矩形AのY座標:左
            ax_r (float): 矩形AのX座標:右
            ay_r (float): 矩形AのY座標:右
            bx_l (float): 矩形BのX座標:左
            by_l (float): 矩形BのY座標:左
            bx_r (float): 矩形BのX座標:右
            by_r (float): 矩形BのY座標:右

        Returns:
            _type_: 矩形A・Bの範囲が触れているかどうか
        """        
        return not (ax_l >= bx_r or bx_l >= ax_r or ay_l >= by_r or by_l >= ay_r)


class BlockFramesManager():
    def __init__(self, grid_w: int, grid_h: int):
        self.frames: list[BlockFrame] = []
        
        self.math: hz3.Math = hz3.Math()

        self.block_move_speed = 0.4

        self.edge = 2

        # 位置座標
        self.x = 0
        self.y = 0
        # グリッドのマージンサイズ
        self.grid_margin_w = 2
        self.grid_margin_h = 2
        # 各グリッドのサイズ
        self.grid_w = grid_w
        self.grid_h = grid_h

        self.blocks_data = None

    
    def generate(self, grid_col: int, grid_row: int):
        self.grid_col = grid_col
        self.grid_row = grid_row

        self.clear()

        for y in range(grid_row):
            for x in range(grid_col):
                block_frame = BlockFrame(x * self.grid_w, y * self.grid_h, self)
                block_frame.grid_x = x
                block_frame.grid_y = y
                self.frames.append(block_frame)

    def clear(self):
        for frame in self.frames:
            if frame.block != None:
                del frame.block

        self.frames.clear()

    def set_block(self, block: Block, grid_x: int, grid_y: int):
        """指定したグリッド座標がグリッド内かどうか

        Args:
            block (Block): ブロック
            grid_x (int): グリッド座標X
            grid_y (int): グリッド座標Y
        """
        if self.is_inside_grid(grid_x, grid_y):
            index = pyxel.floor(grid_x + self.grid_col * float(grid_y))

            frame = self.frames[index]
            frame.set_grid_pos(grid_x, grid_y)
            frame.set_block(block)

    def get_frame(self, grid_x, grid_y) -> BlockFrame:
        if self.is_inside_grid(grid_x, grid_y):
            index = pyxel.floor(grid_x + self.grid_col * float(grid_y))
            return self.frames[index]
        return None



    def is_inside_grid(self, x: int, y: int) -> bool:
        """指定したグリッド座標が範囲内かどうか

        Args:
            x (int): グリッド座標X
            y (int): グリッド座標Y

        Returns:
            bool: 範囲内かどうか
        """
        return x > -1 and x < self.grid_col and y > -1 and y < self.grid_row


    def get_width(self) -> float:
        return self.grid_col * (self.grid_w + self.grid_margin_w) - self.grid_margin_w


    def get_height(self) -> float:
        return self.grid_row * (self.grid_h + self.grid_margin_h) - self.grid_margin_h

    def reload_position(self):
        i = 0
        for frame in self.frames:
            x = pyxel.floor(i % self.grid_col)
            y = pyxel.floor(i / self.grid_col)
            frame.x = self.x + frame.relative_x + (self.grid_margin_w * x)
            frame.y = self.y + frame.relative_y + (self.grid_margin_h * y)
            if frame.block != None:
                frame.block.x = self.math.lerp(frame.block.x, frame.x, self.block_move_speed)
                frame.block.y = self.math.lerp(frame.block.y, frame.y, self.block_move_speed)
            i += 1


    def update(self):
        self.reload_position()

        for frame in self.frames:
            block = frame.block
            if not block == None:
                block.update()

            if const.DEBUG_MODE:
                frame.debug_update(self.blocks_data)


    def draw(self):
        pyxel.rectb(
            self.x - self.edge, 
            self.y - self.edge, 
            self.get_width() + self.edge * 2,
            self.get_height() + self.edge * 2,
            const.COL_DARK_3)
        
        for frame in self.frames:
            block = frame.block
            if not block == None:
                block.draw()

        if const.DEBUG_MODE:
            for frame in self.frames:
                frame.debug_draw()
 