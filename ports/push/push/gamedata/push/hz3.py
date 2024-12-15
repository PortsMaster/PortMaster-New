# title: HZ3 Software Pyxel Library
# author: yuta
# desc: HZ3 Software Original Pyxel library.
# site: https://hz3software.com/
# version: 1.0.0

import time
import pyxel

class System:
    
    def __init__(self):
        # delta_time
        self.dt = 0.0

        # 前フレーム時間
        self.last_time = time.time()

        # FPS
        self.fps = 0

        # FPS更新間隔
        self.fps_update_interval = 1.0

        # FPS計測用の経過時間
        self.elapsed_time = 0

        # フレーム数カウント用
        self.frame_count = 0


    def update(self):
        # 現在時間
        cur_time = time.time()

        # フレーム経過時間計測
        self.dt = cur_time - self.last_time
        self.last_time = cur_time

        # FPS計測
        self.elapsed_time += self.dt
        self.frame_count += 1

        if self.elapsed_time >= self.fps_update_interval:
            self.fps = self.frame_count / self.elapsed_time
            self.elapsed_time = 0
            self.frame_count = 0
    

    def draw_fps(self):
        pyxel.text(1, 1, f"{self.fps:.2f}", 1)



# ステート
class State:
    # コンストラクタ
    def __init__(self, id:str):
        self.statemachine:StateMachine = None
        self.id:str = id

    # Enter
    def enter(self):
        pass

    # Exit
    def exit(self):
        pass

    # Update
    def update(self):
        pass

    # Draw
    def draw(self):
        pass


# ステートマシン
class StateMachine:
    # コンストラクタ
    def __init__(self, init_state:State = None):
        # ステートリスト
        self.states = []
        # 現在のステート
        self.current_state = None
        # 一時停止
        self.is_pause = False

        if init_state is not None:
            # 初期ステート設定
            self.add(init_state)
            self.current_state = init_state
            self.current_state.enter()


    def update(self):
        if self.is_playing():
            self.current_state.update()


    def draw(self):
        if self.is_playing():
            self.current_state.draw()


    # ステート追加
    def add(self, state:State):
        # if not any(isinstance(s, state.__class__) for s in self.states):
        if not any(s.id == state.id for s in self.states):
            # リストに存在しない場合は追加
            # print("[StateMachine:add]", state, "を追加しました。")
            state.statemachine = self
            self.states.append(state)

            if self.current_state is None:
                # 現在のステートが指定されていない場合
                self.current_state = state


    # ステート削除
    def remove(self, state:State):
        if any(isinstance(s, state.__class__) for s in self.states):
            # リストに存在
            self.states.remove(state)
    

    # ステート遷移
    def transition(self, id:str):
        next_state = self.get_state_by_id(id)
        if next_state is not None:
            # 指定したIDのステートが存在する場合はステート変更
            if self.current_state is not None:
                self.current_state.exit()
            self.current_state = next_state
            self.current_state.enter()


    # 指定したIDのステートがstates内に存在するかどうか
    def has_state(self, id):
        return any(s.id == id for s in self.states)
    

    # 指定のIDがstatesの要素のIDと一致した場合そのStateを返す
    def get_state_by_id(self, state_id):
        state = next((s for s in self.states if s.id == state_id), None)
        return state
    

    # 実行中かどうか
    def is_playing(self):
        return self.current_state is not None and not self.is_pause
    

    # 実行
    def play(self):
        self.is_pause = False


    # 一時停止
    def pause(self):
        self.is_pause = True
        

# Vector2クラス
class Vec2:
    # コンストラクタ
    def __init__(self, x:float, y:float):
        self.x: float = x
        self.y: float = y


# Rectクラス
class Rect:
    def __init__(self, x:float, y:float, w:float, h:float):
        self.x: float = x
        self.y: float = y
        self.w: float = w
        self.h: float = h


# ゲームオブジェクトクラス
class GameObject:
    # コンストラクタ
    def __init__(self, pos:Vec2):
        # 座標
        self.pos = pos


    # Update
    def update(self):
        pass


    # Draw
    def draw(self):
        pass
    

class Label:
    def __init__(self, font:pyxel.Font, offset_x:float, offset_y:float):
        self.font = font
        self.offset_x = offset_x
        self.offset_y = offset_y


    def get_width(self, s:str):
        return self.font.text_width(s)


    def text(self, x:float, y:float, s:str, col:int):
        pyxel.text(
            x + self.offset_x, 
            y + self.offset_y, 
            s, col, self.font)
    
class Math:
    def lerp(self, a: float, b: float, t: float) -> float:
        """
        a: 開始値
        b: 終了値
        t: 補間率 (0.0 〜 1.0 の範囲)
        """
        return (1 - t) * a + t * b

    def lerp2d(self, x1: float, y1: float, x2: float, y2: float, t: float):
        """
        (x1, y1): 開始座標
        (x2, y2): 終了座標
        t: 補間率 (0.0 〜 1.0 の範囲)
        """
        x = (1 - t) * x1 + t * x2
        y = (1 - t) * y1 + t * y2
        
        return x, y


class CameraShake:
    def __init__(self):
        self.offset_x = 0
        self.offset_y = 0
        self.duration = 0
        self.magnitude = 0
        self.decay_factor = 1.0
    

    def shake(self, duration, magnitude, decay_factor=0.95):
        self.duration = duration
        self.magnitude = magnitude
        self.decay_factor = decay_factor

    
    def update(self):
        if self.duration > 0:
            self.offset_x = pyxel.rndf(-self.magnitude, self.magnitude)
            self.offset_y = pyxel.rndf(-self.magnitude, self.magnitude)
            self.magnitude *= self.decay_factor
            self.duration -= 1
        else:
            self.offset_x = 0
            self.offset_y = 0

        pyxel.camera(self.offset_x, self.offset_y)


class Button:
    # コンストラクタ
    def __init__(self):
        # 位置座標
        self.x = 64
        self.y = 64

        # サイズ
        self.w = 32
        self.h = 32


    def is_pressed(self):
        # マウス座標
        mx = pyxel.mouse_x
        my = pyxel.mouse_y

        if pyxel.btnp(pyxel.MOUSE_BUTTON_LEFT):
            if self.is_hit_rects(self.x, self.y, self.x + self.w, self.y + self.h, mx, my, mx + 1, my + 1):
                return True
        
        return False
    
    def is_released(self):
        # マウス座標
        mx = pyxel.mouse_x
        my = pyxel.mouse_y
        
        if pyxel.btnr(pyxel.MOUSE_BUTTON_LEFT):
            if self.is_hit_rects(self.x, self.y, self.x + self.w, self.y + self.h, mx, my, mx + 1, my + 1):
                return True
        
        return False

    def draw(self):
        if self.is_pressed():
            pyxel.rectb(self.x, self.y, self.w, self.h, 3)
        else:
            pyxel.rect(self.x, self.y, self.w, self.h, 3)

    # 矩形当たり判定
    def is_hit_rects(self, 
                    ax_l: float, ay_l: float, 
                    ax_r: float, ay_r: float, 
                    bx_l: float, by_l: float, 
                    bx_r: float, by_r: float):
        """矩形当たり判定

        Args:
            ax_l (float): 矩形AのX座標:左
            ay_l (float): 矩形AのY座標:左
            ax_r (float): 矩形AのX座標:右
            ay_r (float): 矩形AのY座標:右
            bx_l (float): 矩形BのX座標:左
            by_l (float): 矩形BのY座標:左
            bx_r (float): 矩形BのX座標:右
            by_r (float): 矩形BのY座標:右

        Returns:
            _type_: 矩形A・Bの範囲が触れているかどうか
        """        
        return not (ax_l >= bx_r or bx_l >= ax_r or ay_l >= by_r or by_l >= ay_r)