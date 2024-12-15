import pyxel
from hz3 import State
from hz3 import Vec2
from menu_button import MenuButton
from input_system import InputSystem
import const

class MenuState(State):
    def __init__(self, id:str, play):
        super().__init__(id)
        self.play = play

        # メニュー番号
        self.menu_index = 0

        # フォント読み込み
        self.magniflop = pyxel.Font("assets/fonts/Magniflop.bdf")

        # メニューボタン作成
        self.menu_btns: MenuButton = []
        self.menu_btns.append(MenuButton(self.magniflop, "REPLAY"))
        self.menu_btns.append(MenuButton(self.magniflop, "BACK TO LEVEL SELECT"))

        self.window_w = pyxel.Font.text_width(self.magniflop, "BACK TO LEVEL SELECT") + 16
        self.window_h = 32

        # メニューボタン設定
        i = 0
        for btn in self.menu_btns:
            if i == 0:
                btn.focus()
            btn.pos = Vec2(64, 15 + 96 + i * 10)
            i += 1


    def update(self):
        if InputSystem.is_pressed(const.BUTTON_ID_MENU) or InputSystem.is_pressed(const.BUTTON_ID_CANCEL):
            pyxel.play(0, const.SOUND_SELECT)
            self.play.play_statemachine.transition("run")
        
        for btn in self.menu_btns:
            btn.update()
        
        if InputSystem.is_pressed(const.BUTTON_ID_SUBMIT):
            pyxel.play(0, const.SOUND_SELECT)

            st = self.play.statemachine

            if st:
                match self.menu_index:
                    case 0:
                        # やり直し
                        self.statemachine.transition("init")
                    case 1:
                        # タイトル画面へ戻る
                        st.transition("levels")

        if InputSystem.is_pressed(const.BUTTON_ID_MOVE_UP, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            # 上移動
            self.reload_menu_buttons(-1)
        elif InputSystem.is_pressed(const.BUTTON_ID_MOVE_DOWN, const.BUTTON_HOLD, const.BUTTON_REPEAT):
            # 下移動
            self.reload_menu_buttons(1)


    def draw(self):
        pyxel.dither(0.2)
        pyxel.rect(0, 0, const.WIDTH, const.HEIGHT, const.COL_DARK_0)

        pyxel.dither(1)
        pyxel.rect(
            const.WIDTH / 2 - self.window_w / 2, 
            const.HEIGHT / 2 - self.window_h / 2,
            self.window_w,
            self.window_h,
            const.COL_DARK_0)
        
        for btn in self.menu_btns:
            btn.draw()
        
        pyxel.dither(1)


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
