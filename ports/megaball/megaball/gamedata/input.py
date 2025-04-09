
import pyxel

UP = 0
DOWN = 1
LEFT = 2
RIGHT = 3
BUTTON_A = 4
BUTTON_B = 5
BUTTON_START = 6
BUTTON_SELECT = 7

class Input:

    def __init__(self):
        self.pressing = []
        self.pressed = []
        
    def get(self):
        self.pressing.clear()
        self.pressed.clear()

        # pressing
        if pyxel.btn(pyxel.KEY_UP) or pyxel.btn(pyxel.KEY_W) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_UP):
            self.pressing.append(UP)
        elif pyxel.btn(pyxel.KEY_DOWN) or pyxel.btn(pyxel.KEY_S) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_DOWN):
            self.pressing.append(DOWN)
            
        if pyxel.btn(pyxel.KEY_LEFT) or pyxel.btn(pyxel.KEY_A) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_LEFT):
            self.pressing.append(LEFT)
        elif pyxel.btn(pyxel.KEY_RIGHT) or pyxel.btn(pyxel.KEY_D) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_DPAD_RIGHT):
            self.pressing.append(RIGHT)
        
        if pyxel.btn(pyxel.KEY_Z) or pyxel.btn(pyxel.KEY_K) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_A):
            self.pressing.append(BUTTON_A)
        
        if pyxel.btn(pyxel.KEY_X) or pyxel.btn(pyxel.KEY_L) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_B):
            self.pressing.append(BUTTON_B)
            
        if pyxel.btn(pyxel.KEY_RETURN) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_START):
            self.pressing.append(BUTTON_START)
            
        if pyxel.btn(pyxel.KEY_SPACE) or \
            pyxel.btn(pyxel.GAMEPAD1_BUTTON_BACK):
            self.pressing.append(BUTTON_SELECT)
            
        # pressed
        if pyxel.btnp(pyxel.KEY_UP) or pyxel.btnp(pyxel.KEY_W) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_UP):
            self.pressed.append(UP)
        elif pyxel.btnp(pyxel.KEY_DOWN) or pyxel.btnp(pyxel.KEY_S) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_DOWN):
            self.pressed.append(DOWN)
            
        if pyxel.btnp(pyxel.KEY_LEFT) or pyxel.btnp(pyxel.KEY_A) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_LEFT):
            self.pressed.append(LEFT)
        elif pyxel.btnp(pyxel.KEY_RIGHT) or pyxel.btnp(pyxel.KEY_D) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_DPAD_RIGHT):
            self.pressed.append(RIGHT)
        
        if pyxel.btnp(pyxel.KEY_Z) or pyxel.btnp(pyxel.KEY_K) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_A):
            self.pressed.append(BUTTON_A)
        
        if pyxel.btnp(pyxel.KEY_X) or pyxel.btnp(pyxel.KEY_L) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_B):
            self.pressed.append(BUTTON_B)
            
        if pyxel.btnp(pyxel.KEY_RETURN) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_START):
            self.pressed.append(BUTTON_START)
            
        if pyxel.btnp(pyxel.KEY_SPACE) or \
            pyxel.btnp(pyxel.GAMEPAD1_BUTTON_BACK):
            self.pressed.append(BUTTON_SELECT)
       
        
