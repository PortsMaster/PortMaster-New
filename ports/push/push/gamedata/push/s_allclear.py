import pyxel
import hz3
import const

from input_system import InputSystem

import ease
from tween import Tween

class AllClear(hz3.State):
    def __init__(self, id, font: pyxel.Font):
        super().__init__(id)
        self.font = font

        self.STATE_WAIT = 0
        self.STATE_INPUTWAIT = 1
        self.STATE_TRANSITION = 2

    def enter(self):
        self.img_allclear = pyxel.Image(128, 128)
        self.img_allclear.load(x=0, y=0, filename="assets/images/allclear.png")

        self.img_tile = pyxel.Image(32, 16)
        self.img_tile.load(x=0, y=0, filename="assets/images/tile.png")

        self.tile_offset_y = 0

        self.img_base_x = const.WIDTH / 2 - self.img_allclear.width / 2
        self.img_base_y = const.HEIGHT / 2 - self.img_allclear.height / 2
        self.img_x = self.img_base_x
        self.img_y = self.img_base_y

        # 初期ステート
        self.state = self.STATE_WAIT

        self.text_allclear = "THANK YOU FOR PLAYING!"
        self.text_pressbutton = "ボタンをおしてタイトルへもどる"

        # 画像スケール値
        self.img_scale: float = 0

        # ディザー値
        self.dither: float = 0

        self.move_framecount: int = 0

        # テキスト位置
        self.text_x = const.WIDTH / 2 - pyxel.Font.text_width(self.font, self.text_allclear) / 2
        self.text_y = -32

        self.wait_tween = Tween()
        self.wait_tween.append(0.0, 1.0, 60, ease.back_io, self.on_scale_value_changed)
        self.wait_tween.append_callback(lambda: pyxel.play(0, const.SOUND_FOCUS))
        self.wait_tween.append(self.text_y, 32.0, 80, ease.quint_o, self.on_text_pos_value_changed)
        self.wait_tween.append_callback(lambda: pyxel.play(0, const.SOUND_SUCCESS))
        self.wait_tween.append_interval(60)
        self.wait_tween.completed(self.on_tween_completed)
        self.wait_tween.play()

        self.transition_tween = Tween()
        self.transition_tween.append(1.0, 0.0, 60, ease.linear, self.on_transition_value_changed)
        self.transition_tween.append_interval(30)
        self.transition_tween.completed(self.on_transition_completed)
        self.is_pressbutton = False


    def exit(self):
        pyxel.dither(1)


    def update(self):
        self.tile_offset_y += 0.2
        if self.tile_offset_y > 16:
            self.tile_offset_y = 0
        
        self.wait_tween.update()
        self.transition_tween.update()

        self.move_framecount += 1
        self.img_x = self.img_base_x + pyxel.cos(self.move_framecount) * 2.0
        self.img_y = self.img_base_y + pyxel.sin(self.move_framecount) * 4.0

        if self.state == self.STATE_WAIT:
            pass
        elif self.state == self.STATE_INPUTWAIT:
            if InputSystem.is_pressed(const.BUTTON_ID_ANY):
                self.state = self.STATE_TRANSITION
                self.transition_tween.play()
        elif self.state == self.STATE_TRANSITION:
            pass


    def draw(self):
        pyxel.dither(self.dither)

        # 背景
        pyxel.rect(0, 0, const.WIDTH, const.HEIGHT, const.COL_PINK_0)

        for y in range(17):
            for x in range(17):
                pyxel.blt(x * 16, y * 16 - self.tile_offset_y, self.img_tile, 16, 0, 16, 16, const.COL_DARK_0)

        # ALL CLEARテキスト
        pyxel.text(self.text_x, self.text_y, self.text_allclear, const.COL_DARK_1, self.font)
        pyxel.text(self.text_x - 1, self.text_y - 1, self.text_allclear, const.COL_GREY_2, self.font)

        # 画像
        pyxel.blt(
            self.img_x, self.img_y, 
            self.img_allclear, 0, 0, 128, 128, const.COL_DARK_0, 0, self.img_scale)

        if self.is_pressbutton:
            if pyxel.frame_count % 120 > 30:
                pyxel.text(const.WIDTH / 2 - pyxel.Font.text_width(self.font, self.text_pressbutton) / 2, 200, self.text_pressbutton, const.COL_GREY_2, self.font)

    
    def on_scale_value_changed(self, value: float):
        self.dither = value
        self.img_scale = value

    def on_text_pos_value_changed(self, value: float):
        self.text_y = value

    def on_tween_completed(self):
        self.is_pressbutton = True
        self.state = self.STATE_INPUTWAIT

    def on_transition_value_changed(self, value: float):
        self.dither = value

    def on_transition_completed(self):
        self.statemachine.transition("title")