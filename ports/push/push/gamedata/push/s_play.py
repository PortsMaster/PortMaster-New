import pyxel
import const
import hz3
import ease
import tween
import json
from game_data import GameData
from input_system import InputSystem

from play_modules.play_state_init import InitState
from play_modules.play_state_run import RunState
from play_modules.play_state_goal import GoalState
from play_modules.play_state_menu import MenuState
from block import Block
from play_modules.player import Player

from block_frame import BlockFramesManager

# プレイシーン
class Play(hz3.State):
    # コンストラクタ
    def __init__(self, id, font, game_data: GameData):
        super().__init__(id)

        self.font = font
        self.game_data = game_data

        self.debug_saved_count: int = 0
        

    def player_goal(self):
        self.play_statemachine.transition("goal")

    def load_json(self, file_path: str):
        json_data = None
        with open(file=file_path, mode="r", encoding="utf-8") as f:
            json_data = json.load(f)
        return json_data

    def write_json(self, file_path: str, json_data):
        with open(file=file_path, mode="w", encoding="utf-8") as f:
            json.dump(json_data, f, ensure_ascii=False, indent=4, sort_keys=True, separators=(',', ': '))

    # Enter
    def enter(self):
        if const.DEBUG_MODE:
            self.map_json = self.load_json("./data/debug_levels.json")
        else:
            self.map_json = self.load_json("./data/levels.json")

        # レベル名
        self.level_title = ""

        self.wave_effects = []

        self.camera_shake = hz3.CameraShake()

        self.dither = 1

        # 画像読み込み
        self.img_blocks = pyxel.Image(128, 128)
        self.img_blocks.load(x=0, y=0, filename="assets/images/push_blocks.png")

        # ブロック
        self.frames_manager = BlockFramesManager(16, 16)

        # プレーヤー
        self.player = Player(
            play=self, 
            grid_x=0, 
            grid_y=0
            )
        self.player.img = self.img_blocks

        self.player.set_goal_event(self.player_goal)

        # ステート生成・追加
        # Init
        init_state = InitState("init", self)
        # Run
        run_state = RunState("run", self)
        # Menu
        menu_state = MenuState("menu", self)
        # Goal
        goal_state = GoalState("goal", self)

        # Play内のステートマシン生成
        self.play_statemachine = hz3.StateMachine(init_state)
        # ステートマシンにステート追加
        self.play_statemachine.add(run_state)
        self.play_statemachine.add(menu_state)
        self.play_statemachine.add(goal_state)


    def exit(self):
        pass



    def update(self):
        self.frames_manager.update()

        # 矩形波エフェクト更新
        for we in self.wave_effects:
            we.update()

        # カメラシェイク更新
        self.camera_shake.update()

        # PlayStateMachine更新
        self.play_statemachine.update()

        if const.DEBUG_MODE:
            self.debug_saved_count -= 1
            if self.debug_saved_count < 0:
                self.debug_saved_count = 0
            
            if pyxel.btn(pyxel.KEY_SHIFT):
                if pyxel.btnp(pyxel.KEY_S):
                    # マップデータを現在の情報で書き換え
                    level_data = self.map_json[self.game_data.cur_level_index]

                    column = level_data["width"]
                    row = len(level_data["tiles"])

                    line: str = ""
                    line_num: int = 0
                    i = 0
                    for frame in self.frames_manager.frames:
                        if frame.block == None or frame.block.id == const.TILE_PLAYER:
                            line += "0"
                        else:
                            line += str(frame.block.id)
                        
                        if i == column - 1:
                            level_data["tiles"][line_num] = line
                            line = ""
                            line_num += 1
                            i = 0
                        else:
                            i += 1

                    # マップ保存
                    self.write_json("./data/debug_levels.json", self.map_json)
                return

        if self.play_statemachine.current_state.id == "run":
            # PlayStateMachineでRun実行中
            if InputSystem.is_pressed(const.BUTTON_ID_MOVE_LEFT):
                # 左移動
                self.player.move(const.LEFT)
            elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_RIGHT):
                # 右移動
                self.player.move(const.RIGHT)
            elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_UP):
                # 上移動
                self.player.move(const.UP)
            elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_DOWN):
                # 下移動
                self.player.move(const.DOWN)
        
        



    # Draw
    def draw(self):
        pyxel.dither(self.dither)

        self.frames_manager.draw()

        # RectWaveEffect描画
        for we in self.wave_effects:
            we.draw()

        pyxel.dither(1)

        # クリアゲージ
        pyxel.rect(self.camera_shake.offset_x, self.camera_shake.offset_y, const.WIDTH * (self.game_data.data_dict["cur_level_index"] / len(self.map_json)), 2, const.COL_GREY_0)

        # プレーヤーの現在位置表示UI
        pyxel.text(
            4,
            4,
            f"X[ {self.player.grid_x} ] Y[ {self.player.grid_y} ]",
            const.COL_GREY_0,
            self.font)

        # 現在のレベル表示UI
        pyxel.text(
            const.WIDTH - self.font.text_width(self.level_title) - 4, 
            4, 
            self.level_title,
            const.COL_GREY_0, 
            self.font)
        
        self.play_statemachine.draw()
        
        # デバッグSaved表示
        if self.debug_saved_count > 0:
            pyxel.text(0, const.HEIGHT - 12, "Saved!", const.COL_ORANGE_0, self.font)
    
    
    # 矩形波エフェクト
    class RectWaveEffect:
        def __init__(self, play, x:float, y:float, start_size:float, end_size:float, duration:float, ease:callable, col:int):
            self.play = play
            
            self.x = x
            self.y = y
            self.size = start_size
            self.end_size = end_size
            self.col = col

            self.dither = 1

            self.tween = tween.Tween()
            self.tween.append(start_size, end_size, duration, ease, self.on_value_changed)
            self.tween.completed(self.on_completed)
            self.tween.play()
        

        def update(self):
            self.tween.update()


        def draw(self):
            pyxel.dither(self.dither)
            pyxel.rectb(self.x - self.size / 2, self.y - self.size / 2, self.size, self.size, self.col)
            s2 = self.size - 1
            pyxel.rectb(self.x - s2 / 2, self.y - s2 / 2, s2 - 1, s2 - 1, self.col)
            pyxel.dither(1)


        def on_value_changed(self, value):
            # 値変更時呼び出し

            # サイズ変更
            self.size = value

            # Dither変更（段々薄く）
            self.dither = 1 - ease.expo_i(value / self.end_size)


        def on_completed(self):
            # 処理終了時呼び出し
            
            # リストから削除
            self.play.wave_effects.remove(self)

            # 自身を削除
            del self

