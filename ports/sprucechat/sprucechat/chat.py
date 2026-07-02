#!/usr/bin/env python3
"""SpruceChat - A local AI chat app for spruceOS"""

import ctypes
import http.client
import json
import os
import struct
import threading
import time

import sdl2
import sdl2.ext
import sdl2.sdlttf

# ── Constants ──────────────────────────────────────────────────────────────────

# Screen dimensions — env vars override detection. Defaults are updated by
# _detect_screen() below: if SCREEN_WIDTH/HEIGHT aren't set, we query SDL for
# the real display resolution so the UI fills higher-res screens properly.
SCREEN_W = 640
SCREEN_H = 480
SCREEN_ROTATION = 0
# Scale factor relative to 640x480 base resolution; updated in lock-step with
# SCREEN_W so s() always scales against the live dimensions.
S = 1.0
def s(v):
    """Scale a pixel value from 640x480 base to actual resolution."""
    return int(v * S)

def _detect_screen():
    """Resolve SCREEN_W/H/ROTATION/S from env vars, or SDL if env is empty."""
    global SCREEN_W, SCREEN_H, SCREEN_ROTATION, S
    env_w = os.environ.get("SCREEN_WIDTH")
    env_h = os.environ.get("SCREEN_HEIGHT")
    if env_w and env_h:
        SCREEN_W, SCREEN_H = int(env_w), int(env_h)
    else:
        # SDL_Init is idempotent — Gfx.__init__ can still init normally after.
        if sdl2.SDL_Init(sdl2.SDL_INIT_VIDEO) == 0:
            mode = sdl2.SDL_DisplayMode()
            if sdl2.SDL_GetCurrentDisplayMode(0, ctypes.byref(mode)) == 0 and mode.w > 0:
                SCREEN_W, SCREEN_H = mode.w, mode.h
    SCREEN_ROTATION = int(os.environ.get("SCREEN_ROTATION", 0))
    S = SCREEN_W / 640.0

_detect_screen()

APP_DIR = os.path.dirname(os.path.abspath(__file__))
# Fonts: spruceOS theme → PixelReader fallback → bundled font in the port
FONT_PATH = "/mnt/SDCARD/Themes/SPRUCE/nunwen.ttf"
FONT_PATH_FB = "/mnt/SDCARD/App/PixelReader/resources/fonts/DejaVuSans.ttf"
FONT_PATH_BUNDLED = os.path.join(APP_DIR, "fonts", "DejaVuSans.ttf")
MODEL_PATH = os.path.join(APP_DIR, "models", "qwen2.5-0.5b-instruct-q4_0.gguf")
MODEL_PATH_FB = os.path.join(APP_DIR, "models", "qwen2.5-0.5b-instruct-q2_k.gguf")
# Saves: honor $XDG_DATA_HOME when set (PortMaster sets this to $CONFDIR);
# otherwise use the spruceOS path for backward compatibility.
SAVES_DIR = os.environ.get("XDG_DATA_HOME") or "/mnt/SDCARD/Saves/spruce/SpruceChat"
HISTORY_PATH = os.path.join(SAVES_DIR, "chat_history.jsonl")
SERVER_LOG = os.path.join(APP_DIR, "server.log")
MAX_HISTORY = 12
CTX_TOKENS = 1024
MAX_TOKENS = 64
PORT = 8086

# Colors
BG       = (16, 16, 22, 255)
CHAT_BG  = (20, 20, 28, 255)
HEADER   = (24, 24, 34, 255)
LINE     = (50, 50, 70, 255)
C_USER   = (130, 190, 255, 255)
C_AI     = (160, 220, 170, 255)
C_DIM    = (130, 130, 155, 255)
C_TEXT   = (210, 210, 220, 255)
BUB_USER = (38, 52, 78, 255)
BUB_AI   = (32, 50, 40, 255)
KEY_BG   = (32, 32, 46, 255)
KEY_SEL  = (65, 120, 220, 255)
KEY_TXT  = (180, 180, 195, 255)
INPUT_BG = (26, 26, 38, 255)
ACCENT   = (75, 130, 230, 255)
C_ERR    = (230, 95, 95, 255)

# Input — two modes:
#   "raw" (default): read /dev/input/event* directly. Button type/code/value
#       come from spruceOS platform cfg env vars (B_A, B_B, etc.).
#   "sdl": use SDL2 GameController events. Used by PortMaster, whose launcher
#       ("Spruce Chat.sh") sets SPRUCE_INPUT_MODE=sdl. No platform cfg needed.
INPUT_MODE = os.environ.get("SPRUCE_INPUT_MODE", "raw")
EVENT_FMT = 'llHHI'
EVENT_SZ = struct.calcsize(EVENT_FMT)
INPUT_DEV = os.environ.get("EVENT_PATH_READ_INPUTS_SPRUCE", "/dev/input/event3")
EV_KEY, EV_ABS = 1, 3

def _parse_btn(env_name, fallback_type, fallback_code, fallback_val=None):
    """Parse platform cfg button format: 'type code [value]'"""
    raw = os.environ.get(env_name, "")
    if raw:
        parts = raw.split()
        t = int(parts[0])
        c = int(parts[1])
        v = int(parts[2]) if len(parts) > 2 else None
        return (t, c, v)
    return (fallback_type, fallback_code, fallback_val)

BTN_A = _parse_btn("B_A", 1, 57)
BTN_B = _parse_btn("B_B", 1, 29)
BTN_X = _parse_btn("B_X", 1, 42)
BTN_Y = _parse_btn("B_Y", 1, 56)
BTN_UP = _parse_btn("B_UP", 1, 103, 1)
BTN_DOWN = _parse_btn("B_DOWN", 1, 108, 1)
BTN_LEFT = _parse_btn("B_LEFT", 1, 105, 1)
BTN_RIGHT = _parse_btn("B_RIGHT", 1, 106, 1)
BTN_L1 = _parse_btn("B_L1", 1, 15)
BTN_R1 = _parse_btn("B_R1", 1, 14)
BTN_START = _parse_btn("B_START", 1, 28)
BTN_SELECT = _parse_btn("B_SELECT", 1, 97)
BTN_MENU = _parse_btn("B_MENU", 1, 1)

SYSTEM_PROMPT = {
    "role": "system",
    "content": "You are SpruceChat, a tiny spruce AI. 0.5B parameters of pure spruce energy. Keep responses short. You're on a tiny chip and that's part of the charm."
}

# ── Store ─────────────────────────────────────────────────────────────────────

class Store:
    def __init__(self):
        self.msgs = []
        os.makedirs(os.path.dirname(HISTORY_PATH), exist_ok=True)
        try:
            with open(HISTORY_PATH) as f:
                for ln in f:
                    ln = ln.strip()
                    if ln:
                        m = json.loads(ln)
                        if m.get("role") != "system":
                            self.msgs.append(m)
            self.msgs = self.msgs[-MAX_HISTORY:]
        except (OSError, json.JSONDecodeError):
            pass

    def add(self, role, content):
        self.msgs.append({"role": role, "content": content})
        self.msgs = self.msgs[-MAX_HISTORY:]
        try:
            with open(HISTORY_PATH, "w") as f:
                for m in self.msgs:
                    f.write(json.dumps(m) + "\n")
        except OSError:
            pass

    def prompt(self):
        return [SYSTEM_PROMPT] + list(self.msgs)

    def display(self):
        return [("user" if m["role"] == "user" else "ai", m["content"]) for m in self.msgs]

    def clear(self):
        self.msgs = []
        try:
            open(HISTORY_PATH, "w").close()
        except OSError:
            pass

# ── Input ─────────────────────────────────────────────────────────────────────

class Input:
    """Dispatches to a raw /dev/input or SDL GameController implementation."""
    def __new__(cls):
        return (InputSDL() if INPUT_MODE == "sdl" else InputRaw())


class InputRaw:
    """Reads /dev/input/event* with button codes from spruceOS platform cfg."""
    def __init__(self):
        self.events = []
        self.lock = threading.Lock()
        self.running = True
        self.fd = None
        self._key_map = {}  # code -> button name for EV_KEY
        self._abs_map = {}  # (code, sign) -> button name for EV_ABS
        for name, btn in [
            ("A", BTN_A), ("B", BTN_B), ("X", BTN_X), ("Y", BTN_Y),
            ("UP", BTN_UP), ("DOWN", BTN_DOWN), ("LEFT", BTN_LEFT), ("RIGHT", BTN_RIGHT),
            ("L1", BTN_L1), ("R1", BTN_R1),
            ("START", BTN_START), ("SELECT", BTN_SELECT), ("MENU", BTN_MENU),
        ]:
            t, c, v = btn
            if t == EV_KEY:
                self._key_map[c] = name
            elif t == EV_ABS:
                sign = -1 if v is not None and v < 0 else 1
                self._abs_map[(c, sign)] = name
        try:
            self.fd = os.open(INPUT_DEV, os.O_RDONLY | os.O_NONBLOCK)
        except OSError:
            pass
        threading.Thread(target=self._poll, daemon=True).start()

    def _poll(self):
        while self.running:
            if not self.fd:
                time.sleep(0.1)
                continue
            try:
                data = os.read(self.fd, EVENT_SZ)
                if len(data) == EVENT_SZ:
                    _, _, t, c, v = struct.unpack(EVENT_FMT, data)
                    btn = None
                    if t == EV_KEY and v == 1:
                        btn = self._key_map.get(c)
                    elif t == EV_ABS:
                        sv = struct.unpack('i', struct.pack('I', v))[0]
                        if sv != 0:
                            sign = -1 if sv < 0 else 1
                            btn = self._abs_map.get((c, sign))
                    if btn:
                        with self.lock:
                            self.events.append(btn)
            except BlockingIOError:
                time.sleep(0.016)
            except OSError:
                time.sleep(0.05)

    def get(self):
        with self.lock:
            e = list(self.events)
            self.events.clear()
        return e

    def close(self):
        self.running = False
        if self.fd:
            os.close(self.fd)


class InputSDL:
    """Polls SDL2 GameController events. PortMaster devices expose a gamepad
    via SDL_GAMECONTROLLERCONFIG set by control.txt, so button mapping is
    automatic across all supported handhelds."""
    # Face-button label layout varies by CFW. Some CFWs ship a positional
    # SDL_GAMECONTROLLERCONFIG (BUTTON_A = south) — on Nintendo-labeled
    # handhelds we swap so app output matches the printed labels. Others
    # ship label-based mappings (physical A → BUTTON_A) where no swap is
    # correct. A/B and X/Y can even differ within one CFW (unofficialOS
    # reports A/B positionally but X/Y by label), so the launcher controls
    # each pair independently via SPRUCE_SWAP_AB and SPRUCE_SWAP_XY.
    # Legacy SPRUCE_SWAP_FACE_BUTTONS still applies to both if set.
    _legacy = os.environ.get("SPRUCE_SWAP_FACE_BUTTONS")
    _swap_ab = os.environ.get("SPRUCE_SWAP_AB", _legacy if _legacy is not None else "1") != "0"
    _swap_xy = os.environ.get("SPRUCE_SWAP_XY", _legacy if _legacy is not None else "1") != "0"
    _FACE = {
        "A": "B" if _swap_ab else "A",
        "B": "A" if _swap_ab else "B",
        "X": "Y" if _swap_xy else "X",
        "Y": "X" if _swap_xy else "Y",
    }
    _BTN = {
        sdl2.SDL_CONTROLLER_BUTTON_A: _FACE["A"],
        sdl2.SDL_CONTROLLER_BUTTON_B: _FACE["B"],
        sdl2.SDL_CONTROLLER_BUTTON_X: _FACE["X"],
        sdl2.SDL_CONTROLLER_BUTTON_Y: _FACE["Y"],
        sdl2.SDL_CONTROLLER_BUTTON_DPAD_UP: "UP",
        sdl2.SDL_CONTROLLER_BUTTON_DPAD_DOWN: "DOWN",
        sdl2.SDL_CONTROLLER_BUTTON_DPAD_LEFT: "LEFT",
        sdl2.SDL_CONTROLLER_BUTTON_DPAD_RIGHT: "RIGHT",
        sdl2.SDL_CONTROLLER_BUTTON_LEFTSHOULDER: "L1",
        sdl2.SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: "R1",
        sdl2.SDL_CONTROLLER_BUTTON_START: "START",
        sdl2.SDL_CONTROLLER_BUTTON_BACK: "SELECT",
        sdl2.SDL_CONTROLLER_BUTTON_GUIDE: "MENU",
    }

    def __init__(self):
        self.running = True
        sdl2.SDL_InitSubSystem(sdl2.SDL_INIT_GAMECONTROLLER)
        self._pads = []
        for i in range(sdl2.SDL_NumJoysticks()):
            if sdl2.SDL_IsGameController(i):
                p = sdl2.SDL_GameControllerOpen(i)
                if p:
                    self._pads.append(p)

    def get(self):
        events = []
        ev = sdl2.SDL_Event()
        while sdl2.SDL_PollEvent(ctypes.byref(ev)) != 0:
            if ev.type == sdl2.SDL_CONTROLLERBUTTONDOWN:
                btn = self._BTN.get(ev.cbutton.button)
                if btn:
                    events.append(btn)
            elif ev.type == sdl2.SDL_CONTROLLERDEVICEADDED:
                i = ev.cdevice.which
                if sdl2.SDL_IsGameController(i):
                    p = sdl2.SDL_GameControllerOpen(i)
                    if p:
                        self._pads.append(p)
            elif ev.type == sdl2.SDL_QUIT:
                events.append("MENU")
        return events

    def close(self):
        self.running = False
        for p in self._pads:
            sdl2.SDL_GameControllerClose(p)

# ── Graphics ──────────────────────────────────────────────────────────────────

class Gfx:
    def __init__(self):
        sdl2.ext.init(controller=False)
        sdl2.sdlttf.TTF_Init()
        self.rotated = SCREEN_ROTATION == 270
        if self.rotated:
            win_size = (SCREEN_H, SCREEN_W)
        else:
            win_size = (SCREEN_W, SCREEN_H)
        self.win = sdl2.ext.Window("SpruceChat", size=win_size,
                                    flags=sdl2.SDL_WINDOW_FULLSCREEN)
        self.win.show()
        sdl2.SDL_SetHint(sdl2.SDL_HINT_RENDER_SCALE_QUALITY, b"1")
        self.ren = sdl2.ext.Renderer(self.win, flags=sdl2.SDL_RENDERER_ACCELERATED)
        self.r = self.ren.sdlrenderer

        # Offscreen canvas (always renders at SCREEN_W x SCREEN_H)
        self.canvas = sdl2.SDL_CreateTexture(self.r, sdl2.SDL_PIXELFORMAT_ARGB8888,
                                              sdl2.SDL_TEXTUREACCESS_TARGET, SCREEN_W, SCREEN_H)
        if self.rotated:
            self.rot_tex = sdl2.SDL_CreateTexture(self.r, sdl2.SDL_PIXELFORMAT_ARGB8888,
                                                   sdl2.SDL_TEXTUREACCESS_TARGET, SCREEN_H, SCREEN_W)
        sdl2.SDL_SetRenderTarget(self.r, self.canvas)

        fp = next((p for p in (FONT_PATH, FONT_PATH_FB, FONT_PATH_BUNDLED)
                   if os.path.exists(p)), FONT_PATH_BUNDLED)
        self.f_sm = sdl2.sdlttf.TTF_OpenFont(fp.encode(), s(16))
        self.f_md = sdl2.sdlttf.TTF_OpenFont(fp.encode(), s(20))
        self.f_lg = sdl2.sdlttf.TTF_OpenFont(fp.encode(), s(26))

    def clear(self, c=BG):
        sdl2.SDL_SetRenderTarget(self.r, self.canvas)
        sdl2.SDL_SetRenderDrawColor(self.r, *c)
        sdl2.SDL_RenderClear(self.r)

    def present(self):
        if self.rotated:
            # Rotate canvas into cached texture (A30: 270°)
            sdl2.SDL_SetRenderTarget(self.r, self.rot_tex)
            sdl2.SDL_SetRenderDrawColor(self.r, 0, 0, 0, 255)
            sdl2.SDL_RenderClear(self.r)
            dst = sdl2.SDL_Rect((SCREEN_H - SCREEN_W) // 2, (SCREEN_W - SCREEN_H) // 2,
                                 SCREEN_W, SCREEN_H)
            ctr = sdl2.SDL_Point(SCREEN_W // 2, SCREEN_H // 2)
            sdl2.SDL_RenderCopyEx(self.r, self.canvas, None, dst, 270, ctr, sdl2.SDL_FLIP_NONE)
            sdl2.SDL_SetRenderTarget(self.r, None)
            sdl2.SDL_RenderCopy(self.r, self.rot_tex, None, None)
        else:
            # No rotation — blit canvas directly
            sdl2.SDL_SetRenderTarget(self.r, None)
            sdl2.SDL_RenderCopy(self.r, self.canvas, None, None)
        sdl2.SDL_RenderPresent(self.r)
        sdl2.SDL_SetRenderTarget(self.r, self.canvas)

    def rect(self, x, y, w, h, c):
        sdl2.SDL_SetRenderDrawColor(self.r, *c)
        sdl2.SDL_RenderFillRect(self.r, sdl2.SDL_Rect(int(x), int(y), int(w), int(h)))

    def text(self, s, x, y, font=None, color=C_TEXT, wrap=0):
        tx, w, h = self.prepare_text(s, font=font, color=color, wrap=wrap)
        if not tx:
            return 0, 0
        sdl2.SDL_RenderCopy(self.r, tx, None, sdl2.SDL_Rect(int(x), int(y), w, h))
        sdl2.SDL_DestroyTexture(tx)
        return w, h

    def prepare_text(self, s, font=None, color=C_TEXT, wrap=0):
        """Render text to a texture without blitting. Caller must destroy."""
        if not s:
            return None, 0, 0
        font = font or self.f_md
        c = sdl2.SDL_Color(*color)
        if wrap > 0:
            sf = sdl2.sdlttf.TTF_RenderUTF8_Blended_Wrapped(font, s.encode('utf-8'), c, int(wrap))
        else:
            sf = sdl2.sdlttf.TTF_RenderUTF8_Blended(font, s.encode('utf-8'), c)
        if not sf:
            return None, 0, 0
        tx = sdl2.SDL_CreateTextureFromSurface(self.r, sf)
        w, h = sf.contents.w, sf.contents.h
        sdl2.SDL_FreeSurface(sf)
        return tx, w, h

    def size_text(self, s, font=None):
        """Return (w, h) pixel size of unwrapped text."""
        if not s:
            return 0, 0
        font = font or self.f_md
        w = ctypes.c_int(0)
        h = ctypes.c_int(0)
        sdl2.sdlttf.TTF_SizeUTF8(font, s.encode('utf-8'), ctypes.byref(w), ctypes.byref(h))
        return w.value, h.value

    def font_ascent(self, font):
        return sdl2.sdlttf.TTF_FontAscent(font)

    def font_height(self, font):
        return sdl2.sdlttf.TTF_FontHeight(font)

    def measure_wrapped(self, s, font=None, wrap=0):
        """Return pixel height of wrapped text without keeping a texture."""
        if not s:
            return 0
        font = font or self.f_md
        c = sdl2.SDL_Color(255, 255, 255, 255)
        if wrap > 0:
            sf = sdl2.sdlttf.TTF_RenderUTF8_Blended_Wrapped(font, s.encode('utf-8'), c, int(wrap))
        else:
            sf = sdl2.sdlttf.TTF_RenderUTF8_Blended(font, s.encode('utf-8'), c)
        if not sf:
            return 0
        h = sf.contents.h
        sdl2.SDL_FreeSurface(sf)
        return h

    def blit_prepared(self, tx, x, y, w, h):
        if not tx:
            return
        sdl2.SDL_RenderCopy(self.r, tx, None, sdl2.SDL_Rect(int(x), int(y), w, h))
        sdl2.SDL_DestroyTexture(tx)

    def destroy(self):
        if self.rotated:
            sdl2.SDL_DestroyTexture(self.rot_tex)
        sdl2.SDL_DestroyTexture(self.canvas)
        for f in [self.f_sm, self.f_md, self.f_lg]:
            if f:
                sdl2.sdlttf.TTF_CloseFont(f)
        sdl2.sdlttf.TTF_Quit()
        self.ren.destroy()
        self.win.close()
        sdl2.SDL_Quit()

# ── Keyboard ──────────────────────────────────────────────────────────────────

KB_ROWS = [
    list("1234567890"), list("qwertyuiop"), list("asdfghjkl"),
    list("zxcvbnm.,"), ["SPC", "DEL", "SEND"],
]

class Keyboard:
    def __init__(self):
        self.row, self.col, self.shifted = 2, 4, False
        self.y0 = SCREEN_H - s(180)

    @property
    def rows(self):
        if not self.shifted:
            return KB_ROWS
        return [
            list("1234567890"), list("QWERTYUIOP"), list("ASDFGHJKL"),
            list("ZXCVBNM!?"), ["SPC", "DEL", "SEND"],
        ]

    def move(self, d):
        rows = self.rows
        if d == "up":    self.row = (self.row - 1) % len(rows)
        elif d == "down":  self.row = (self.row + 1) % len(rows)
        elif d == "left":  self.col = (self.col - 1) % len(rows[self.row])
        elif d == "right": self.col = (self.col + 1) % len(rows[self.row])
        self.col = min(self.col, len(self.rows[self.row]) - 1)

    def press(self):
        k = self.rows[self.row][self.col]
        if k == "SPC": return " "
        if k == "DEL": return "BACKSPACE"
        if k == "SEND": return "SEND"
        if self.shifted: self.shifted = False
        return k

    def draw(self, g):
        rows = self.rows
        g.rect(0, self.y0, SCREEN_W, SCREEN_H - self.y0, BG)
        g.text("A·type   B·back   Y·send   X·spc   L1·shift   R1·del",
               s(14), self.y0 + s(4), font=g.f_sm, color=C_DIM)
        ky = self.y0 + s(22)
        for ri, row in enumerate(rows):
            bottom = ri == len(rows) - 1
            kw = s(80) if bottom else s(42)
            gap = s(3)
            tw = len(row) * kw + (len(row) - 1) * gap
            sx = (SCREEN_W - tw) // 2
            for ci, key in enumerate(row):
                x = sx + ci * (kw + gap)
                y = ky + ri * s(31)
                sel = ri == self.row and ci == self.col
                if sel:
                    bg = KEY_SEL
                elif key == "SEND":
                    bg = ACCENT
                else:
                    bg = KEY_BG
                g.rect(x, y, kw, s(28), bg)
                lw, lh = g.size_text(key, font=g.f_sm)
                txt_c = (255, 255, 255, 255) if sel or key == "SEND" else KEY_TXT
                g.text(key, x + (kw - lw) // 2, y + (s(28) - lh) // 2,
                       font=g.f_sm, color=txt_c)

# ── AI Engine ─────────────────────────────────────────────────────────────────

class AI:
    def __init__(self):
        self.generating = False
        self.response = ""
        self.toks = 0
        self.tps = 0.0
        self.t0 = 0
        self._conn = None
        self.ok = self._health()

    def _health(self):
        try:
            c = http.client.HTTPConnection("127.0.0.1", PORT, timeout=1)
            c.request("GET", "/health")
            r = c.getresponse()
            c.close()
            return r.status == 200
        except Exception:
            return False

    def generate(self, msgs):
        self.generating = True
        self.response = ""
        self.toks = 0
        self.tps = 0.0
        self.t0 = time.time()
        # The stream thread only mutates AI state; the UI polls self.response
        # from the main loop. Callbacks used to fire per-token from here, but
        # they reached SDL_ttf (not thread-safe) and eventually corrupted the
        # allocator — so all SDL work stays on the main thread now.
        threading.Thread(target=self._stream, args=(msgs,), daemon=True).start()

    def _prompt(self, msgs):
        p = ""
        for m in msgs:
            p += f"<|im_start|>{m['role']}\n{m['content']}<|im_end|>\n"
        return p + "<|im_start|>assistant\n"

    def _stream(self, msgs):
        payload = json.dumps({
            "prompt": self._prompt(msgs),
            "n_predict": MAX_TOKENS, "temperature": 0.7, "top_k": 20, "top_p": 0.9,
            "stream": True, "stop": ["<|im_end|>", "<|endoftext|>", "<|im_start|>"],
            "cache_prompt": True,
        }).encode()
        first = 0
        try:
            self._conn = http.client.HTTPConnection("127.0.0.1", PORT, timeout=300)
            self._conn.request("POST", "/completion", body=payload,
                               headers={"Content-Type": "application/json"})
            resp = self._conn.getresponse()
            buf = b""
            while self.generating:
                ch = resp.read(1)
                if not ch:
                    break
                buf += ch
                if ch == b"\n":
                    line = buf.decode("utf-8", errors="replace").strip()
                    buf = b""
                    if line.startswith("data: "):
                        try:
                            d = json.loads(line[6:])
                        except json.JSONDecodeError:
                            continue
                        tok = d.get("content", "")
                        if tok:
                            if not first:
                                first = time.time()
                            self.response += tok
                            self.toks += 1
                            dt = time.time() - first
                            if dt > 0:
                                self.tps = self.toks / dt
                        if d.get("stop"):
                            ts = d.get("timings", {})
                            if ts.get("predicted_per_second"):
                                self.tps = ts["predicted_per_second"]
                            break
            self._conn.close()
        except Exception as e:
            if not self.response:
                self.response = f"[Error: {e}]"
        for t in ["<|im_end|>", "<|endoftext|>", "<|im_start|>"]:
            self.response = self.response.split(t)[0]
        self.response = self.response.strip()
        self.generating = False

    def cancel(self):
        self.generating = False
        if self._conn:
            try: self._conn.close()
            except: pass

# ── App ───────────────────────────────────────────────────────────────────────

class App:
    def __init__(self):
        self.g = Gfx()
        self.inp = Input()
        self.kb = Keyboard()
        self.store = Store()
        self.msgs = self.store.display()
        self._mw = SCREEN_W - s(44)  # AI bubble wrap width (full width minus padding)
        self._user_mw = int(SCREEN_W * 0.72) - s(16)  # user bubble caps ~72% width
        self._heights = []
        self._resync_heights()
        self.text = ""
        self.scroll = 0
        self.state = "chat"
        self.running = True
        self.t0 = 0
        self._last_seen_response = ""
        self._was_generating = False

        self._boot()
        self.ai = AI()
        if not self.ai.ok:
            self.msgs.append(("ai", "[Server not connected. Restart the app to retry.]"))
        elif not self.msgs:
            self.msgs.append(("ai", "Hey! I'm a tiny spruce AI. What's up?"))
        self._resync_heights()

    def _boot(self):
        start = time.time()
        pos = 0
        lines = []
        mfile = os.path.basename(MODEL_PATH if os.path.exists(MODEL_PATH) else MODEL_PATH_FB)
        progress = 0.0
        tensor_t = 0

        while self.running:
            dt = time.time() - start
            for c in self.inp.get():
                if c in ("B", "MENU"):
                    self.running = False
                    return

            # Health check (short timeout so UI stays responsive)
            try:
                c = http.client.HTTPConnection("127.0.0.1", PORT, timeout=0.15)
                c.request("GET", "/health")
                r = c.getresponse()
                c.close()
                if r.status == 200:
                    lines.append("[OK] Ready! ({:.0f}s)".format(dt))
                    progress = 1.0
                    self._draw_boot(mfile, lines, progress, dt, True)
                    time.sleep(0.4)
                    return
            except Exception:
                pass

            # Read server log
            try:
                if os.path.exists(SERVER_LOG):
                    with open(SERVER_LOG) as f:
                        f.seek(pos)
                        new = f.read()
                        pos = f.tell()
                    for ln in new.splitlines():
                        ln = ln.strip()
                        if not ln:
                            continue
                        if "load_tensors:" in ln:
                            tensor_t = time.time()
                            progress = max(progress, 0.4)
                        elif "llama_model_loader" in ln:
                            progress = max(progress, min(0.3, progress + 0.01))
                        elif "print_info:" in ln:
                            progress = max(progress, min(0.4, progress + 0.005))
                        elif "llama_context:" in ln:
                            progress = max(progress, 0.85)
                        elif "model loaded" in ln.lower():
                            progress = max(progress, 0.93)
                        elif "listening" in ln.lower():
                            progress = 0.97
                        if len(ln) > 68:
                            ln = ln[:65] + "..."
                        lines.append(ln)
            except OSError:
                pass

            # Time-based interpolation during tensor loading
            if tensor_t:
                tp = 0.4 + min((time.time() - tensor_t) / 50.0, 1.0) * 0.45
                progress = max(progress, tp)
            elif progress < 0.05:
                progress = 0.02 + 0.01 * (dt % 3)

            self._draw_boot(mfile, lines, progress, dt, False)
            time.sleep(0.15)
            if dt > 180:
                return

    def _draw_boot(self, mfile, lines, progress, dt, ready):
        self.g.clear()
        tw, _ = self.g.size_text("SpruceChat", font=self.g.f_lg)
        self.g.text("SpruceChat", (SCREEN_W - tw) // 2, s(20), font=self.g.f_lg, color=C_TEXT)
        self.g.text(mfile, s(14), s(60), font=self.g.f_sm, color=C_DIM)

        spin = "|/-\\"[int(dt * 4) % 4]
        pct = int(progress * 100)
        st = "ready" if ready else f"{spin} loading {pct}%  {dt:.0f}s"
        self.g.text(st, s(14), s(80), font=self.g.f_sm, color=C_AI if ready else C_DIM)

        # Progress bar
        bw = SCREEN_W - s(28)
        bh = s(6)
        self.g.rect(s(14), s(100), bw, bh, HEADER)
        fw = int(bw * min(progress, 1.0))
        if fw > 0:
            self.g.rect(s(14), s(100), fw, bh, C_AI if ready else ACCENT)

        # Log
        vis = lines[-16:]
        y = s(116)
        for ln in vis:
            col = C_AI if ln.startswith("[OK]") else C_DIM
            self.g.text(ln, s(14), y, font=self.g.f_sm, color=col)
            y += s(16)

        self.g.text("B: cancel", s(14), SCREEN_H - s(20), font=self.g.f_sm, color=C_DIM)
        self.g.present()

    def _input(self):
        for c in self.inp.get():
            if c == "MENU":
                self.ai.cancel(); self.running = False; return
            if self.ai.generating:
                if c == "B":
                    self.ai.cancel(); self.running = False; return
                continue
            if self.state == "keyboard":
                self._kb_input(c)
            else:
                self._chat_input(c)

    def _chat_input(self, c):
        if c == "A": self.state = "keyboard"
        elif c == "B": self.running = False
        elif c == "UP": self.scroll = max(0, self.scroll - s(30))
        elif c == "DOWN": self.scroll = max(0, self.scroll + s(30))
        elif c == "SELECT":
            self.store.clear()
            self.msgs = [("ai", "Chat cleared.")]
            self._resync_heights()
            self.scroll = 0

    def _kb_input(self, c):
        if c == "UP": self.kb.move("up")
        elif c == "DOWN": self.kb.move("down")
        elif c == "LEFT": self.kb.move("left")
        elif c == "RIGHT": self.kb.move("right")
        elif c == "A":
            r = self.kb.press()
            if r == "BACKSPACE": self.text = self.text[:-1]
            elif r == "SEND": self._send()
            else: self.text += r
        elif c == "B":
            if self.text: self.text = self.text[:-1]
            else: self.state = "chat"
        elif c == "X": self.text += " "
        elif c in ("Y", "START"): self._send()
        elif c == "L1": self.kb.shifted = not self.kb.shifted
        elif c == "R1": self.text = self.text[:-1]
        elif c == "MENU": self.running = False

    def _send(self):
        t = self.text.strip()
        if not t or self.ai.generating:
            return
        self.text = ""
        self.state = "chat"
        self.msgs.append(("user", t))
        self._heights.append(self._block_h("user", t))
        self.store.add("user", t)
        self.msgs.append(("ai", ""))
        self._heights.append(self._block_h("ai", ""))
        self.t0 = time.time()
        self._last_seen_response = ""
        self.ai.generate(self.store.prompt())

    def _poll_ai(self):
        """Mirror AI streaming state into the UI on the main thread.

        We used to take callbacks from the streaming thread, but SDL_ttf is
        not thread-safe and measuring text from the wrong thread eventually
        corrupted the allocator (`free(): invalid pointer`)."""
        resp = self.ai.response
        if resp != self._last_seen_response:
            self._last_seen_response = resp
            if self.msgs and self.msgs[-1][0] == "ai":
                self.msgs[-1] = ("ai", resp)
                self._update_last_height()
                self.scroll = max(0, self._total_h() - self._chat_h())

        if self._was_generating and not self.ai.generating:
            # Generation just finished; persist the final response.
            if self.msgs and self.msgs[-1][0] == "ai":
                self.msgs[-1] = ("ai", resp)
                self._update_last_height()
            self.store.add("assistant", resp)
            self.scroll = max(0, self._total_h() - self._chat_h())
        self._was_generating = self.ai.generating

    def _chat_h(self):
        return (self.kb.y0 - s(76)) if self.state == "keyboard" else (SCREEN_H - s(36))

    def _block_h(self, role, txt):
        wrap = self._user_mw if role == "user" else self._mw
        th = self.g.measure_wrapped(txt or " ", wrap=wrap)
        return (th + s(12)) + s(10)

    def _resync_heights(self):
        self._heights = [self._block_h(r, t) for r, t in self.msgs]

    def _update_last_height(self):
        if self.msgs:
            r, t = self.msgs[-1]
            h = self._block_h(r, t)
            if len(self._heights) == len(self.msgs):
                self._heights[-1] = h
            else:
                self._resync_heights()

    def _total_h(self):
        return s(8) + sum(self._heights)

    def _draw(self):
        self.g.clear()

        # Header
        hdr_h = s(34)
        self.g.rect(0, 0, SCREEN_W, hdr_h, HEADER)
        self.g.rect(0, hdr_h, SCREEN_W, 1, LINE)

        # Shared baseline so title (f_md) and hint (f_sm) align
        fh_md = self.g.font_height(self.g.f_md)
        asc_md = self.g.font_ascent(self.g.f_md)
        asc_sm = self.g.font_ascent(self.g.f_sm)
        title_y = (hdr_h - fh_md) // 2
        baseline = title_y + asc_md
        hint_y = baseline - asc_sm

        if self.ai.generating:
            dt = int(time.time() - self.t0) if self.t0 else 0
            if self.ai.response:
                status = f"{self.ai.toks}tok  {self.ai.tps:.1f}t/s  {dt}s"
                col = C_AI
            else:
                status = f"thinking  {dt}s"
                col = C_DIM
            sw, _ = self.g.size_text(status, font=self.g.f_sm)
            # Pulsing dots to the left of the status text
            dot_d = s(5)
            dot_gap = s(4)
            dots_w = 3 * dot_d + 2 * dot_gap
            total_w = dots_w + s(8) + sw
            base_x = SCREEN_W - s(14) - total_w
            dots_y = (hdr_h - dot_d) // 2
            now = time.time()
            for i in range(3):
                phase = ((now * 1.6) - i * 0.18) % 1.0
                a = 0.25 + 0.75 * (1.0 - abs(phase * 2 - 1.0))
                dc = tuple(int(HEADER[k] + (col[k] - HEADER[k]) * a) for k in range(3)) + (255,)
                self.g.rect(base_x + i * (dot_d + dot_gap), dots_y, dot_d, dot_d, dc)
            self.g.text(status, base_x + dots_w + s(8), hint_y,
                        font=self.g.f_sm, color=col)
        elif self.state == "chat":
            hint = "A:type  B:quit  SEL:clear"
            hw, _ = self.g.size_text(hint, font=self.g.f_sm)
            self.g.text(hint, SCREEN_W - s(14) - hw, hint_y,
                        font=self.g.f_sm, color=C_DIM)

        # Chat area
        top = s(36)
        bot = self._chat_h() + top
        self.g.rect(0, top, SCREEN_W, bot - top, CHAT_BG)

        y = top + s(8) - self.scroll

        for role, txt in self.msgs:
            if y > bot:
                break
            if not txt and role == "ai" and self.ai.generating:
                txt = "..."

            is_user = role == "user"
            is_err = not is_user and txt.startswith("[Error") or txt.startswith("[Server")
            tc = C_USER if is_user else (C_ERR if is_err else C_AI)
            bc = BUB_USER if is_user else BUB_AI
            wrap = self._user_mw if is_user else self._mw

            # Pre-render text to get true pixel size
            tx, tw, th = self.g.prepare_text(txt or " ", color=tc, wrap=wrap)
            bubble_h = th + s(12)
            block_h = bubble_h + s(10)

            # Cull fully offscreen
            if y + block_h < top - s(10):
                if tx:
                    sdl2.SDL_DestroyTexture(tx)
                y += block_h
                continue

            if is_user:
                bubble_w = max(tw + s(16), s(40))
                bubble_x = SCREEN_W - s(14) - bubble_w
                text_x = bubble_x + s(8)
                stripe_x = bubble_x + bubble_w - s(3)
            else:
                bubble_x = s(14)
                bubble_w = SCREEN_W - s(28)
                text_x = bubble_x + s(8)
                stripe_x = bubble_x

            self.g.rect(bubble_x, y, bubble_w, bubble_h, bc)
            self.g.rect(stripe_x, y, s(3), bubble_h, tc)
            self.g.blit_prepared(tx, text_x, y + s(6), tw, th)
            y += block_h

        # Input bar
        if self.state == "keyboard":
            iy = self.kb.y0 - s(38)
            self.g.rect(0, iy, SCREEN_W, 1, LINE)
            self.g.rect(0, iy + 1, SCREEN_W, s(36), INPUT_BG)
            cur = "_" if int(time.time() * 2) % 2 == 0 else " "
            self.g.text(self.text + cur, s(14), iy + s(8), color=C_TEXT)
            self.kb.draw(self.g)

        self.g.present()

    def run(self):
        try:
            while self.running:
                self._input()
                self._poll_ai()
                self._draw()
                time.sleep(0.05)
        finally:
            self.inp.close()
            self.g.destroy()

if __name__ == "__main__":
    App().run()
