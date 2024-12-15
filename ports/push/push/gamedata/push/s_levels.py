import pyxel
import json
import hz3
from hz3 import StateMachine
from input_system import InputSystem
import const
import tween as tw
import ease
from game_data import GameData


# レベル選択シーン
class Levels(hz3.State):
    def __init__(self, id, font, game_data: GameData):
        super().__init__(id)
        self.game_data = game_data
        self.font = font


    def enter(self):
        # カメラシェイク
        self.camera_shake = hz3.CameraShake()

        self.title_statemachine: StateMachine = StateMachine(SelectState("select", self))
        self.title_statemachine.add(TransitionState("transition_play", self, self.statemachine, "play"))

        self.img_carrot = pyxel.Image(16, 16)
        self.img_carrot.load(0, 0, "assets/images/carrot_icon.png")
        
        self.map_json = []
        with open(file="./data/levels.json", mode="r", encoding="utf-8") as f:
            self.map_json = json.load(f)

        # もし現在の選択番号がレベルの数を上回っていたら0に戻す
        if self.game_data.data_dict["cur_level_index"] > len(self.map_json):
            self.game_data.data_dict["cur_level_index"] = 0
            self.game_data.save()
        
        # もしレベルの数が増えている場合、それに合わせてデータのレベル数も差分のみ増やす
        for i in range(len(self.map_json) - len(self.game_data.data_dict["level_states"])):
            self.game_data.data_dict["level_states"].append(0)
            self.game_data.save()

        self.level_rects: list[LevelRect] = []
        self.level_count: int = len(self.map_json)

        self.column = 9
        offset_x = const.WIDTH / 2 - self.column * 20 / 2 + 1
        offset_y = 96

        for i in range(self.level_count):
            # LevelRect作成
            level_rect: LevelRect = LevelRect(self, i)
            level_rect.x = pyxel.floor(i % self.column) * 20 + offset_x
            level_rect.y = pyxel.floor(i / self.column) * 20 + offset_y
            self.level_rects.append(level_rect)

        # 選択中のレベル番号
        self.level_index = self.game_data.data_dict["cur_level_index"]
        
        if self.level_index > len(self.game_data.data_dict["level_states"]) - 1:
            self.level_index = 0

        # 前回選択したレベル番号
        self.prev_level_index = self.level_index

        # 初期レベル選択
        self.change_level(self.level_index)


    def change_level(self, index: int):
        # 現在選択中のレベルのフォーカスを外す
        self.level_rects[self.level_index].unfocus()

        # 次のレベル番号を取得
        self.level_index = index
        self.prev_level_index = index

        # 番号が範囲外の場合、範囲内に収める
        if self.level_index < 0:
            self.level_index = self.level_count - 1
        elif self.level_index > self.level_count - 1:
            self.level_index = 0
        
        # 次のレベルをフォーカス
        self.level_rects[self.level_index].focus()


    def move_level(self, vx: int, vy: int):
        # 最大列数
        max_column = self.column

        # 最大行数
        max_row = pyxel.floor(self.level_count / max_column) + 1
        
        x = pyxel.floor(self.level_index % max_column)
        y = pyxel.floor(self.level_index / max_column)

        move_x = x + vx
        move_y = y + vy

        if move_x < 0:
            move_x = 0
        elif move_x > max_column - 1:
            move_x = max_column - 1

        if move_y < 0:
            move_y = 0
        elif move_y > max_row - 1:
            move_y = max_row - 1

        # 最終行の最大数
        last_row_count = pyxel.floor(self.level_count % max_column) - 1
        if move_y == max_row - 1 and move_x > last_row_count:
            # 最終行かつX移動位置が最大数を超えている場合
            # 要素の数が半端になる可能性があるので収める
            move_x = last_row_count
        
        # 次のレベル番号を取得
        self.level_index = move_x + max_column * move_y

        if self.level_index != self.prev_level_index:
            # 現在選択中のレベルのフォーカスを外す
            self.level_rects[self.prev_level_index].unfocus()
            # 前回選択レベル番号更新
            self.prev_level_index = self.level_index

            # 次のレベルをフォーカス
            self.level_rects[self.level_index].focus()
            # 効果音再生
            pyxel.play(0, const.SOUND_FOCUS)


    def exit(self):
        pass


    def update(self):
        self.title_statemachine.update()


    def draw(self):
        pyxel.dither(1)

        self.title_statemachine.draw()

        pyxel.text(
            const.WIDTH / 2 - pyxel.Font.text_width(self.font, "LEVEL SELET") / 2, 16, 
            "LEVEL SELECT", 
            const.COL_GREY_0, self.font)
        
        level_data = self.map_json[self.level_index]
        self.level_title = f"LEVEL {level_data['title']}"

        pyxel.text(
            const.WIDTH / 2 - pyxel.Font.text_width(self.font, self.level_title) / 2, 80, 
            self.level_title, 
            const.COL_DARK_1, self.font)

        for level_rect in self.level_rects:
            level_rect.draw()


class SelectState(hz3.State):
    def __init__(self, id, levels: Levels):
        super().__init__(id)

        self.levels: Levels = levels

    def update(self):
        if InputSystem.is_pressed(const.BUTTON_ID_CANCEL):
            self.levels.statemachine.transition("title")

        if InputSystem.is_pressed(const.BUTTON_ID_MOVE_LEFT, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            self.levels.move_level(-1, 0)
        elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_RIGHT, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            self.levels.move_level(1, 0)
        elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_UP, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            self.levels.move_level(0, -1)
        elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_DOWN, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            self.levels.move_level(0, 1)

        if InputSystem.is_pressed(const.BUTTON_ID_SUBMIT):
            self.levels.game_data.data_dict["cur_level_index"] = self.levels.level_index
            self.levels.title_statemachine.transition("transition_play")


# 遷移ステート
class TransitionState(hz3.State):
    def __init__(self, id:str, levels: Levels, main_statemachine:hz3.StateMachine, scene_name:str):
        super().__init__(id)
        self.levels: Levels = levels
        self.main_statemachine = main_statemachine
        self.tween = None
        self.dither = 1
        self.scene_name = scene_name


    def enter(self):
        self.tween = tw.Tween()
        self.tween.append(1, 0, 60, ease.expo_o, self.on_value_changed)
        self.tween.completed(self.on_completed)
        self.tween.play()

        # カメラシェイク
        self.levels.camera_shake.shake(20, 5, 0.9)

        # 効果音再生
        pyxel.play(0, const.SOUND_SELECT)


    def exit(self):
        pass


    def update(self):
        self.tween.update()
        self.levels.camera_shake.update()


    def draw(self):
        pyxel.dither(self.dither)


    def on_completed(self):
        self.main_statemachine.transition(self.scene_name)


    def on_value_changed(self, value):
        self.dither = value


class LevelRect:
    def __init__(self, levels: Levels, index: int):
        self.x = 0
        self.y = 0
        self.w = 16
        self.h = 16

        self.index = index

        self.levels: Levels = levels

        self.col = const.COL_DARK_1
        self.col_flash = const.COL_GREEN_1
        self.is_focus = False
        self.is_success = False

        self.frame_count: int = 0


    def focus(self):
        self.is_focus = True
        self.col = const.COL_GREEN_0
        self.frame_count = 0


    def unfocus(self):
        self.is_focus = False
        self.col = const.COL_DARK_1


    def draw(self):
        self.frame_count += 1

        if self.is_success:
            pass

        if self.is_focus:
            pyxel.rect(self.x, self.y, self.w, self.h, self.col)
            pyxel.rectb(self.x, self.y, self.w, self.h, const.COL_DARK_1)

            if self.frame_count % 30 < 5:
                pyxel.rectb(self.x, self.y, self.w, self.h, self.col_flash)
        else:
            pyxel.rectb(self.x, self.y, self.w, self.h, const.COL_GREY_0)
        
        if self.levels.game_data.data_dict["level_states"][self.index] > 0:
            # pyxel.rect(self.x + 2, self.y + 2, self.w - 4, self.h - 4, const.COL_ORANGE_0)
            pyxel.blt(self.x, self.y, self.levels.img_carrot, 0, 0, 16, 16, const.COL_DARK_0)
