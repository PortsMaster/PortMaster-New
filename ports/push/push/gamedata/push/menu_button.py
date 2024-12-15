import pyxel
import const
import ease

from hz3 import Math
from hz3 import Label

# メニューボタン
class MenuButton():
    # コンストラクタ
    def __init__(self, font:pyxel.Font, text:str):
        super().__init__()

        self.math = Math()

        self.label = Label(font, 0, -5)

        self.font = font
        self.text = text
        self.text_width = self.label.get_width(text)
        self.font_height = 6
        self.w = self.text_width + 4
        self.h = self.font_height + 3
        self.col_bg = const.COL_GREEN_0
        self.col_text = const.COL_GREY_0

        self.is_focus = False
        self.bg_w = 0

        self.rate:float = 1.0


    def focus(self):
        self.is_focus = True
        self.rate = 0.2

        self.col_bg = const.COL_GREEN_0
        self.col_text = const.COL_GREY_2

        pyxel.play(0, const.SOUND_FOCUS)


    def unfocus(self):
        self.is_focus = False
        self.rate = 0

        self.col_bg = const.COL_GREY_0
        self.col_text = const.COL_GREY_0


    def press(self):
        pass


    def update(self):
        if self.is_focus:
            self.rate += 0.2
            if self.rate > 1.0:
                self.rate = 1.0
            self.bg_w = self.w * ease.quint_o(self.rate) - 1
        else:
            self.rate += 0.05
            if self.rate > 1.0:
                self.rate = 1.0
            self.bg_w = self.w * ease.sine_i(1.0 - self.rate) - 1


    # Draw
    def draw(self):
        if self.is_focus:
            # フォーカス時表示
            pyxel.rect(self.pos.x, self.pos.y, self.bg_w, self.h, self.col_bg)
 
            if pyxel.frame_count % 30 > 5:
                pyxel.rectb(self.pos.x - 1, self.pos.y - 1, self.bg_w + 2, self.h + 2, const.COL_DARK_1)
            else:
                pyxel.rectb(self.pos.x - 1, self.pos.y - 1, self.bg_w + 2, self.h + 2, self.col_bg)
        else:
            # 非フォーカス時表示
            if pyxel.frame_count % 2 != 0:
                # 点滅
                pyxel.rect(self.pos.x, self.pos.y, self.bg_w, self.h, self.col_bg)
        
        # ラベルテキスト表示
        self.label.text(
            self.pos.x + self.w / 2 - self.label.get_width(self.text) / 2, 
            self.pos.y + self.h / 2 - self.font_height / 2 - 1, 
            self.text, 
            self.col_text
            )