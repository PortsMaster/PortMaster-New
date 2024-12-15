import pyxel

import os
import const
import webbrowser
import hz3
import ease
from input_system import InputSystem

import tween as tw
from menu_button import MenuButton

import json


# タイトルシーン
class Title(hz3.State):
    # コンストラクタ
    def __init__(self, id: str):
        super().__init__(id)


    # Enter
    def enter(self):
        self.test = "NONE"
        self.test_col = const.COL_PINK_0
                
        # カメラシェイク
        self.camera_shake = hz3.CameraShake()

        # メニュー番号
        self.menu_index = 0

        # フォント読み込み
        self.magniflop = pyxel.Font("assets/fonts/Magniflop.bdf")

        # 画像ファイル読み込み
        self.img_title_logo = pyxel.Image(256, 64)
        self.img_title_logo.load(x=0, y=0, filename="assets/images/title_logo.png")

        # メニューボタン作成
        self.menu_btns:MenuButton = []
        self.menu_btns.append(MenuButton(self.magniflop, "GAMESTART"))
        self.menu_btns.append(MenuButton(self.magniflop, "WEBSITE"))
        # self.menu_btns.append(MenuButton(self.magniflop, "CREDITS"))
        # self.menu_btns.append(MenuButton(self.magniflop, "QUIT"))

        # メニューボタン設定
        i = 0
        for btn in self.menu_btns:
            if i == 0:
                btn.focus()
            btn.pos = hz3.Vec2(156, 128 + i * 10 + 12)
            i += 1

        # タイトルステートマシン作成
        menu_state = MenuState("menu", self)
        play_transition_state = TransitionState("play_transition", self.statemachine, "play")
        help_transition_state = TransitionState("help_transition", self.statemachine, "help")
        levels_transition_state = TransitionState("levels_transition", self.statemachine, "levels")

        # タイトルステートマシン追加
        self.title_st = hz3.StateMachine(menu_state)
        self.title_st.add(play_transition_state)
        self.title_st.add(help_transition_state)
        self.title_st.add(levels_transition_state)


    # Exit
    def exit(self):
        pass


    # Update
    def update(self):
        self.camera_shake.update()

        self.title_st.update()
        
        for btn in self.menu_btns:
            btn.update()
    

    # Draw
    def draw(self):
        for btn in self.menu_btns:
            btn.draw()

        self.title_st.draw()

        # タイトルロゴ
        pyxel.blt(
            const.WIDTH / 2 - self.img_title_logo.width / 2, 
            const.HEIGHT / 2 - self.img_title_logo.height / 2 - 32, 
            self.img_title_logo, 
            0, 0, self.img_title_logo.width, self.img_title_logo.height, 
            const.COL_DARK_0)

        # バージョン
        pyxel.text(
            const.WIDTH - self.magniflop.text_width(const.TEXT_VERSION) - self.camera_shake.offset_x,
            -2-+ self.camera_shake.offset_y,
            const.TEXT_VERSION,
            const.COL_GREY_0,
            self.magniflop
        )

        # コピーライト
        pyxel.text(
            const.WIDTH / 2 - self.magniflop.text_width(const.TEXT_COPYRIGHT) / 2 - self.camera_shake.offset_x, 
            const.HEIGHT - 24 - self.camera_shake.offset_y, 
            str(const.TEXT_COPYRIGHT), 
            const.COL_GREY_0, 
            self.magniflop)
        
        if const.DEBUG_MODE:
            pyxel.text(0, -2, "[DEBUG MODE]", const.COL_ORANGE_0, self.magniflop)


        
    # メニューボタン更新
    def reload_menu_buttons(self, add_index:int):
        # 現在選択中のメニューのフォーカスを外す
        self.menu_btns[self.menu_index].unfocus()

        # メニュー番号に加算
        self.menu_index += add_index

        # メニュー番号ループ
        if self.menu_index < 0:
            self.menu_index = len(self.menu_btns) - 1
        if self.menu_index > len(self.menu_btns) - 1:
            self.menu_index = 0

        # 新しいメニューボタンをフォーカス
        self.menu_btns[self.menu_index].focus()


# メニュー選択ステート
class MenuState(hz3.State):
    def __init__(self, id:str, title:Title):
        super().__init__(id)
        self.title = title

    def enter(self):
        pass

    def exit(self):
        self.title.camera_shake.shake(20, 5, 0.9)

    def update(self):
        if InputSystem.is_pressed(const.BUTTON_ID_SUBMIT):
            pyxel.play(0, const.SOUND_SELECT)
            if self.title.statemachine:
                match self.title.menu_index:
                    case 0:
                        # GAMESTART
                        self.statemachine.transition("levels_transition")
                    case 1:
                        # WEBSITE
                        webbrowser.open("https://hz3software.com/", 2, False)

        if InputSystem.is_pressed(const.BUTTON_ID_MOVE_UP, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            # 上移動
            self.title.reload_menu_buttons(-1)
        elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_DOWN, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            # 下移動
            self.title.reload_menu_buttons(1)

    def draw(self):
        pass


# 遷移ステート
class TransitionState(hz3.State):
    def __init__(self, id:str, main_statemachine:hz3.StateMachine, scene_name:str):
        super().__init__(id)

        self.main_statemachine = main_statemachine
        self.tween = None
        self.dither = 1
        self.scene_name = scene_name


    def enter(self):
        self.tween = tw.Tween()
        self.tween.append(1, 0, 60, ease.expo_o, self.on_value_changed)
        self.tween.completed(self.on_completed)
        self.tween.play()


    def exit(self):
        pass


    def update(self):
        self.tween.update()


    def draw(self):
        pyxel.dither(self.dither)


    def on_completed(self):
        self.main_statemachine.transition(self.scene_name)


    def on_value_changed(self, value):
        self.dither = value
