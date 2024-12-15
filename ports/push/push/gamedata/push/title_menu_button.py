import pyxel
import const
from pyxel import Font
from hz3 import Button

class TitleMenuButton(Button):
    def __init__(self, font: Font, text: str):
        super().__init__()
        self.font: Font = font
        self.text: str = text
        
        self.text_w = Font.text_width(self.font, self.text)
        self.text_h = 12
        
        # 初期値設定
        self.w = self.text_w + 32
        self.h = self.text_h + 32

    def is_pressed(self):
        is_pressed = super().is_pressed()
        if is_pressed:
            pyxel.play(0, const.SOUND_SELECT)
        return is_pressed

    def draw(self):
        if self.is_pressed():
            pyxel.rect(self.x, self.y, self.w, self.h, const.COL_PINK_0)
        else:
            pyxel.rectb(self.x, self.y, self.w, self.h, const.COL_GREY_0)
        pyxel.text(
            self.x + self.w / 2 - self.text_w / 2, self.y + self.h / 2 - self.text_h / 2, 
            self.text, const.COL_DARK_0, self.font)