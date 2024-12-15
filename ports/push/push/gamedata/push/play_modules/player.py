import pyxel
from hz3 import Math
from block import Block
import const
import ease
import tween

# プレーヤー
class Player(Block):
    
    # コンストラクタ
    def __init__(self, play, grid_x, grid_y):
        # 親クラスメソッドのコンストラクタ呼び出し
        super().__init__()

        self.id = const.TILE_PLAYER
        
        self.x = const.WIDTH / 2
        self.y = const.HEIGHT / 2
        self.u = 16 * 3

        self.play = play
        self.grid_x = grid_x
        self.grid_y = grid_y

        from block_frame import BlockFramesManager
        self.frames_manager:BlockFramesManager = None
        
        self.is_moving = False
        self.pos_rate = 0.0
        self.goal_event = None
        self.math = Math()


    def set_goal_event(self, goal_event):
        self.goal_event = goal_event


    # 移動（グリッド座標）
    def move(self, dir:int):
        # 移動方向
        move_x = 0
        move_y = 0

        # 移動方向取得
        match dir:
            case const.LEFT:
                self.reload_block_data(self.blocks_data, "player_left", 4)
                move_x = -1
            case const.RIGHT:
                self.reload_block_data(self.blocks_data, "player_right", 4)
                move_x = 1
            case const.UP:
                self.reload_block_data(self.blocks_data, "player_back", 4)
                move_y = -1
            case const.DOWN:
                self.reload_block_data(self.blocks_data, "player_front", 4)
                move_y = 1
        
        if move_x == 0 and move_y == 0:
            # 移動無しの場合、これ以上の処理を行わない
            return

        # 移動先の座標
        from block_frame import BlockFrame
        current_frame: BlockFrame = self.frames_manager.get_frame(self.grid_x, self.grid_y)
        move_target_frame: BlockFrame = self.frames_manager.get_frame(self.grid_x + move_x, self.grid_y + move_y)

        # 移動制限
        if move_target_frame == None:
            return

        if move_target_frame.block == None:
            # ■→床
            pyxel.play(1, const.SOUND_FOCUS)

            current_frame.set_block(None)
            move_target_frame.set_block(self)
            self.grid_x += move_x
            self.grid_y += move_y
        else:
            # 床以外
            if move_target_frame.block.id == const.TILE_GOAL:
                # ■→G
                pyxel.play(1, const.SOUND_SELECT)

                self.reload_block_data(self.blocks_data, "player_fun", 4)
                self.anim_interval = 5

                grid_width = self.frames_manager.grid_w + self.frames_manager.grid_margin_w
                grid_height = self.frames_manager.grid_h + self.frames_manager.grid_margin_h

                wx = move_target_frame.grid_x * grid_width + self.frames_manager.x + self.frames_manager.grid_w / 2
                wy = move_target_frame.grid_y * grid_height + self.frames_manager.y + self.frames_manager.grid_h / 2

                self.play.wave_effects.append(
                    self.play.RectWaveEffect(
                        self.play, 
                        wx, 
                        wy, 
                        0, 64, 
                        60,
                        ease.expo_o,
                        const.COL_ORANGE_0
                        )
                    )

                self.play.camera_shake.shake(
                            duration=10, 
                            magnitude=2, 
                            decay_factor=0.95)
                
                # 移動処理
                current_frame.set_block(None)
                move_target_frame.set_block(self)
                self.grid_x += move_x
                self.grid_y += move_y
                
                if self.goal_event is not None:
                    self.goal_event()
            elif move_target_frame.block.id == const.TILE_BLOCK:
                # ■→ブ
                # さらに先のフレームを取得
                next_target_x = self.grid_x + move_x * 2
                next_target_y = self.grid_y + move_y * 2
                next_target_frame: BlockFrame = self.frames_manager.get_frame(next_target_x, next_target_y)

                if next_target_x < 0 or next_target_x > self.frames_manager.grid_col - 1 or next_target_y < 0 or next_target_y > self.frames_manager.grid_row - 1:
                    # 先のフレーム位置がタイルマップ外の場合
                    # ブロック移動処理などを行わない
                    return 
                
                if next_target_frame.block == None:
                    # ■→ブ床
                    pyxel.play(1, const.SOUND_FOCUS)

                    # 移動処理
                    next_target_frame.set_block(move_target_frame.block )
                    current_frame.set_block(None)
                    move_target_frame.set_block(self)
                    self.grid_x += move_x
                    self.grid_y += move_y
                elif next_target_frame.block.id == const.TILE_HOLE:
                    # ■→ブ穴
                    pyxel.play(1, const.SOUND_SELECT)

                    grid_width = self.frames_manager.grid_w + self.frames_manager.grid_margin_w
                    grid_height = self.frames_manager.grid_h + self.frames_manager.grid_margin_h

                    wx = next_target_frame.grid_x * grid_width + self.frames_manager.x + self.frames_manager.grid_w / 2
                    wy = next_target_frame.grid_y * grid_height + self.frames_manager.y + self.frames_manager.grid_h / 2

                    self.play.wave_effects.append(
                        self.play.RectWaveEffect(
                            self.play, 
                            wx, 
                            wy, 
                            0, 32, 
                            20,
                            ease.expo_o,
                            const.COL_GREY_0
                            )
                        )

                    self.play.camera_shake.shake(
                        duration=10, 
                        magnitude=2, 
                        decay_factor=0.95)
                    
                    # 移動処理
                    current_frame.set_block(None)
                    move_target_frame.set_block(self)
                    next_target_frame.set_block(None)
                    self.grid_x += move_x
                    self.grid_y += move_y

    def draw(self):
        pyxel.blt(
            self.x + self.offset_x, self.y + self.offset_y,
            self.img,
            self.u, self.v,
            self.w, self.h,
            self.clear_col
        )