import json
import os
import pyxel
import const
import hz3
# シーン
import s_title
import s_play
import s_allclear
import s_levels
from hz3 import Button
from input_system import InputSystem

class App:
    def __init__(self):
        
        # 初期化
        pyxel.init(
            width=const.WIDTH, 
            height=const.HEIGHT, 
            title=const.TITLE,
            fps=const.FPS, 
            quit_key=pyxel.KEY_Q, 
            display_scale = const.DISPLAY_SCALE, 
            capture_scale = const.CAPTURE_SCALE, 
            capture_sec = 10
            )
        
        # マウス表示設定
        pyxel.mouse(False)
        
        # 整数倍モード
        self.integer_scale = True
        pyxel.integer_scale(self.integer_scale)
        
        # リソース読み込み
        pyxel.load("assets/push.pyxres")

        if const.DEBUG_MODE:
            # マウスカーソルの画像ファイル読み込み
            self.img_cursor = pyxel.Image(16, 16)
            self.img_cursor.load(x=0, y=0, filename="assets/images/cursor.png")

        # マウスカーソル座標
        self.mouse_x = pyxel.mouse_x
        self.mouse_y = pyxel.mouse_y

        self.sys = hz3.System()
        self.math = hz3.Math()

        # 背景エフェクト
        self.line0_pos_y = 0
        self.line0_speed = 16
        self.line1_pos_y = 0
        self.line1_speed = 32

        self.img_tile = pyxel.Image(32, 16)
        self.img_tile.load(x=0, y=0, filename="assets/images/tile.png")
        
        self.tile_offset_x = 0
        
        from game_data import GameData
        self.game_data: GameData = GameData()
        self.game_data.load()

        # フォント読み込み
        self.k8x12 = pyxel.Font("assets/fonts/k8x12.bdf")

        # シーンステートマシン作成
        self.st_scene = hz3.StateMachine(s_title.Title("title"))
        # self.st_scene = hz3.StateMachine(s_allclear.AllClear("allclear", self.k8x12))
        self.st_scene.add(s_play.Play("play", self.k8x12, self.game_data))
        self.st_scene.add(s_allclear.AllClear("allclear", self.k8x12))
        # self.st_scene.add(s_title.Title("title"))
        self.st_scene.add(s_levels.Levels("levels", self.k8x12, self.game_data))

        InputSystem.add(const.BUTTON_ID_ANY, [
            pyxel.KEY_SPACE,
            pyxel.KEY_RETURN,
            pyxel.GAMEPAD1_BUTTON_A,
            pyxel.GAMEPAD1_BUTTON_B,
            pyxel.GAMEPAD1_BUTTON_X,
            pyxel.GAMEPAD1_BUTTON_Y,
            pyxel.MOUSE_BUTTON_LEFT
        ])

        InputSystem.add(const.BUTTON_ID_MENU, [
            pyxel.KEY_ESCAPE,
            pyxel.GAMEPAD1_BUTTON_Y,
            pyxel.GAMEPAD1_BUTTON_START
        ])

        InputSystem.add(const.BUTTON_ID_MOVE_LEFT, [
            pyxel.KEY_LEFT,
            pyxel.KEY_A,
            pyxel.GAMEPAD1_BUTTON_DPAD_LEFT
        ])

        InputSystem.add(const.BUTTON_ID_MOVE_RIGHT, [
            pyxel.KEY_RIGHT,
            pyxel.KEY_D,
            pyxel.GAMEPAD1_BUTTON_DPAD_RIGHT
        ])

        InputSystem.add(const.BUTTON_ID_MOVE_UP, [
            pyxel.KEY_UP,
            pyxel.KEY_W,
            pyxel.GAMEPAD1_BUTTON_DPAD_UP
        ])

        InputSystem.add(const.BUTTON_ID_MOVE_DOWN, [
            pyxel.KEY_DOWN,
            pyxel.KEY_S,
            pyxel.GAMEPAD1_BUTTON_DPAD_DOWN
        ])

        InputSystem.add(const.BUTTON_ID_REPLAY, [pyxel.KEY_R])
        InputSystem.add(const.BUTTON_ID_ACTION, [pyxel.KEY_I, pyxel.GAMEPAD1_BUTTON_RIGHTSHOULDER])
        
        # 実行
        pyxel.run(self.update, self.draw)

    
    # Update
    def update(self):
        self.sys.update()

        self.tile_offset_x += 0.4
        if self.tile_offset_x > 16:
            self.tile_offset_x = 0
        
        # マウスカーソル位置
        self.mouse_x = self.math.lerp(self.mouse_x, pyxel.mouse_x, 0.6)
        self.mouse_y = self.math.lerp(self.mouse_y, pyxel.mouse_y, 0.6)

        if InputSystem.is_pressed(const.BUTTON_ID_ACTION):
            self.integer_scale = not self.integer_scale
            pyxel.integer_scale(self.integer_scale)

        # self.line0_pos_y -= self.line0_speed * self.sys.dt
        # if self.line0_pos_y < 0:
        #     self.line0_pos_y = const.HEIGHT

        # self.line1_pos_y -= self.line1_speed * self.sys.dt
        # if self.line1_pos_y < 0:
        #     self.line1_pos_y = const.HEIGHT

        # シーンステートマシン：更新
        self.st_scene.update()


    # Draw
    def draw(self):
        # 背景色
        pyxel.cls(const.COL_GREY_2)

        for y in range(17):
            for x in range(17):
                pyxel.blt(x * 16 - self.tile_offset_x, y * 16, self.img_tile, 0, 0, 16, 16, const.COL_DARK_0)

        # 背景ライン
        # pyxel.line(0, self.line0_pos_y, const.WIDTH, self.line0_pos_y, const.COL_GREY_1)
        # pyxel.line(0, self.line1_pos_y, const.WIDTH, self.line1_pos_y, const.COL_GREY_1)

        # シーンステートマシン：描画
        self.st_scene.draw()

        if const.DEBUG_MODE:
            # マウスカーソル描画
            pyxel.blt(
                self.mouse_x, 
                self.mouse_y, 
                self.img_cursor, 
                0, 0, 16, 16, 
                const.COL_DARK_0)
    

App()