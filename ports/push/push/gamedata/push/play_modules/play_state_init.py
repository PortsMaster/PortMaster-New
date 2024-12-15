import pyxel
from hz3 import State
import ease
import tween
import const

from block import Block
from play_modules.goal_block import GoalBlock

from blocks_data import BlocksData

# PlayState:初期化ステート
class InitState(State):
    
    def __init__(self, id:str, play):
        super().__init__(id)
        
        # Play取得
        from s_play import Play
        self.play: Play = play

        # 
        self.blocks_data: BlocksData = BlocksData()
        self.blocks_data.img = self.play.img_blocks

        self.tw = tween.Tween()
        self.raw_mapdata = ""


    def enter(self):
        self.play.dither = 0

        self.tw.append(0, 1, 25, ease.linear, self.on_value_changed)
        self.tw.completed(self.on_completed).play()

        level_data = self.play.map_json[self.play.game_data.data_dict["cur_level_index"]]

        # レベル名取得
        self.play.level_title = level_data["title"]

        # タイルマップデータ
        self.raw_mapdata = ""
        for c in level_data["tiles"]:
            self.raw_mapdata += c

        # フレーム作成
        frames_manager = self.play.frames_manager
        frames_manager.blocks_data = self.blocks_data
        frames_manager.generate(
            grid_col=level_data["width"], 
            grid_row=len(level_data["tiles"]))
        
        # データからブロックを生成し、フレームに設定
        i: int = 0
        for data in self.raw_mapdata:
            tile_id = int(data)
            if tile_id != const.TILE_FLOOR:
                x = pyxel.floor(i % frames_manager.grid_col)
                y = pyxel.floor(i / frames_manager.grid_col)
                
                if tile_id == const.TILE_BLOCK:
                    block = Block()
                    block.reload_block_data(self.blocks_data, "move", 1)
                elif tile_id == const.TILE_HOLE:
                    block = Block()
                    block.reload_block_data(self.blocks_data, "hole", 1)
                elif tile_id == const.TILE_WALL:
                    block = Block()
                    block.reload_block_data(self.blocks_data, "wall", 1)
                elif tile_id == const.TILE_GOAL:
                    block = GoalBlock()
                    block.reload_block_data(self.blocks_data, "goal", 4)
                    block.anim_interval = 8
                
                # ブロック共通設定
                # ID設定
                block.id = tile_id
                # 生成したブロックをフレームに設定
                frames_manager.set_block(block, x, y)

            i += 1
        
        frames_manager.x = const.WIDTH / 2 - frames_manager.get_width() / 2
        frames_manager.y = const.HEIGHT / 2 - frames_manager.get_height() / 2

        # プレーヤー
        player = self.play.player
        player.frames_manager = frames_manager

        init_player_pos_x = int(level_data["start_pos_x"])
        init_player_pos_y = int(level_data["start_pos_y"])
        player.grid_x = init_player_pos_x
        player.grid_y = init_player_pos_y
        
        player.reload_block_data(self.blocks_data, "player_front", 4)
        player.anim_interval = 20

        frames_manager.set_block(player, init_player_pos_x, init_player_pos_y)


    def exit(self):
        # Tween停止
        self.tw.stop()


    def update(self):
        # Tween更新
        self.tw.update()


    def on_value_changed(self, value):
        self.play.dither = value


    def on_completed(self):
        self.statemachine.transition("run")