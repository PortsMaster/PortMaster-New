#!/usr/bin/env python3
"""RUNNER PROTOCOL - a Claude-usage extraction game for the R36S / K36.

Every 5-hour usage window is a RUN. Your usage is LOAD in the pack: salvage
accrues while you work, the multiplier peaks in a productive band, and you have
to EXTRACT (A) to bank it before the window burns out. Blow past 95% or get
rate-limited and the unbanked salvage is gone. The only way to play well is to
keep looking at the numbers.

Data arrives from the PC via receiver.py -> /tmp/claude_usage.json, with a
sample log at /roms/tools/claude/usage_hist.jsonl. There is no save file: runs,
ranks, streak and contracts are all recomputed from that log at launch.

Exit: hold SELECT+START.  Sibling of widget.py, which it deliberately does not
import - that file stays frozen.
"""
import json
import math
import os
import random
import select
import socket
import struct
import subprocess
import sys
import time

try:
    import fcntl
except ImportError:
    fcntl = None

# Simulator mode: identical rendering on a PC (no fb, no gamepad), dumping N
# frames to a GIF so layout can be judged before deploying.
SIM = os.name == "nt" or bool(os.environ.get("WIDGET_SIM"))

W, H = 640, 480
FB = "/dev/fb0"
DATA = os.environ.get("RUNNER_DATA", "/tmp/claude_usage.json")
# History lives at the legacy carousel path if one is already there, else next
# to this script; RUNNER_HIST overrides both. receiver.py resolves identically,
# so the two always agree on where samples go.
_LEGACY_HIST = "/roms/tools/claude/usage_hist.jsonl"
HIST = os.environ.get("RUNNER_HIST") or (
    _LEGACY_HIST if os.path.exists(_LEGACY_HIST)
    else os.path.join(os.path.dirname(os.path.abspath(__file__)),
                      "usage_hist.jsonl"))
ART_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "art")
FIXTURE_HIST = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "fixtures", "usage_hist.jsonl")
if SIM:
    _base = os.environ.get("WIDGET_SIM_DIR",
                           os.path.dirname(os.path.abspath(__file__)))
    DATA = os.path.join(_base, "sim_usage.json")
    HIST = os.path.join(_base, "sim_hist.jsonl")

DEBUG = bool(os.environ.get("RUNNER_DEBUG"))

# PROTOCOL DRILL: an on-device demo that swaps the data source for a synthetic
# state generator - the real framebuffer/input/audio path still runs. Opt-in
# only (env, flag, or Y on the NO SIGNAL screen); fake numbers must never
# silently stand in for live ones. Combines with WIDGET_SIM to render the
# drill to a GIF on a PC.
DEMO_START = bool(os.environ.get("RUNNER_DEMO")) or "--demo" in sys.argv


def _load_config():
    """Optional runner_config.json next to this script, e.g.
    {"ssid": "MY-NET", "host": "192.168.1.20", "port": 8788}. Network identity
    lives there (and is not committed), never in this file."""
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                     "runner_config.json")
    try:
        with open(p) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


CONFIG = _load_config()


def host_label():
    """What the LINK tab prints for HOST: configured ssid/host if present,
    else this device's own address (that's where the PC pushes to)."""
    port = CONFIG.get("port", 8788)
    if CONFIG.get("host"):
        s = "%s:%s" % (CONFIG["host"], port)
        return "%s / %s" % (CONFIG["ssid"], s) if CONFIG.get("ssid") else s
    try:
        probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        probe.connect(("10.255.255.255", 1))
        ip = probe.getsockname()[0]
        probe.close()
        return "%s:%s" % (ip, port)
    except OSError:
        return "NOT CONFIGURED"

# ---------------------------------------------------------------- palette ----
# Acid is load-bearing: it marks data and live state, never decoration.
# Flat fills only. No gradients, no glows, no rounded corners.
VOID = (6, 8, 6)
VOID_2 = (12, 15, 11)      # dither partner
GRAPHITE = (22, 26, 22)
GRAPHITE_2 = (32, 38, 30)
RULE = (48, 56, 44)
RULE_HI = (74, 86, 66)
ACID = (198, 255, 26)
ACID_D = (116, 152, 18)
ACID_XD = (62, 82, 12)
BONE = (232, 236, 224)
BONE_D = (140, 148, 132)
CYAN = (60, 220, 235)
CYAN_D = (28, 116, 126)
ALERT = (255, 58, 38)
ALERT_D = (128, 26, 18)

BAYER4 = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))

LABEL_PX = 14   # panel names and column headings
MICRO_PX = 10   # technical annotations, meant to be small


# ------------------------------------------------------------------ font ----
class Font:
    """Decoder for art/maratype.fnt as produced by tools/bake_font.py.

    Glyphs are stored as horizontal spans, so drawing a string costs a handful
    of Screen.rect calls per character and needs no font library on device."""

    MAGIC = b"MTF1"

    def __init__(self, path):
        self.faces = {}  # px -> (line_h, ascent, mono_adv, space_adv, glyphs)
        with open(path, "rb") as fh:
            b = fh.read()
        if b[:4] != self.MAGIC:
            raise ValueError("bad font magic")
        o = 4
        n_sizes = b[o]
        o += 1
        for _ in range(n_sizes):
            px, line_h, ascent, mono, space, n_g = struct.unpack_from("<BBBBBH", b, o)
            o += 7
            glyphs = {}
            for _g in range(n_g):
                cp, xoff, yoff, adv, n_sp = struct.unpack_from("<BbbBH", b, o)
                o += 6
                spans = []
                for _s in range(n_sp):
                    spans.append(struct.unpack_from("<BBB", b, o))
                    o += 3
                glyphs[chr(cp)] = (xoff, yoff, adv, spans)
            self.faces[px] = (line_h, ascent, mono, space, glyphs)
        self.sizes = sorted(self.faces)

    def face(self, px):
        """Nearest baked size - callers ask for intent, not exact pixels."""
        if px in self.faces:
            return self.faces[px]
        return self.faces[min(self.sizes, key=lambda s: abs(s - px))]

    def line_h(self, px):
        return self.face(px)[0]

    def width(self, s, px, mono=False, track=0):
        line_h, ascent, madv, space, glyphs = self.face(px)
        total = 0
        for ch in s:
            g = glyphs.get(ch)
            total += (madv if mono else (space if g is None else g[2])) + track
        return total

    def spans(self, x, y, s, px, mono=False, track=0):
        """Yield (x, y, w, h) rects for the string, y = top of the line box."""
        line_h, ascent, madv, space, glyphs = self.face(px)
        cx = int(x)
        y = int(y)
        for ch in s:
            g = glyphs.get(ch)
            if g is None:
                cx += (madv if mono else space) + track
                continue
            xoff, yoff, adv, spans = g
            gx = cx + (((madv - adv) >> 1) + xoff if mono else xoff)
            gy = y + yoff
            for dy, sx, run in spans:
                yield gx + sx, gy + dy, run, 1
            cx += (madv if mono else adv) + track


_font = None


def get_font():
    global _font
    if _font is None:
        try:
            _font = Font(os.path.join(ART_DIR, "maratype.fnt"))
        except (OSError, ValueError, struct.error) as exc:
            if DEBUG:
                print("font load failed (%s) - falling back to 5x7" % exc,
                      flush=True)
            _font = False
    return _font


# ------------------------------------------------------------------- art ----
def load_art():
    """art/<name>.raw -> {name: (w, h, [(dy, dx, bgra_bytes), ...])}
    Same format widget.py's pets use: <HH w,h header then BGRA rows, with
    alpha 0 meaning transparent. Multi-frame art uses <name>_f<k>.raw."""
    out = {}
    try:
        files = os.listdir(ART_DIR)
    except OSError:
        return {}
    for fn in sorted(files):
        if not fn.endswith(".raw"):
            continue
        try:
            data = open(os.path.join(ART_DIR, fn), "rb").read()
            w, h = struct.unpack("<HH", data[:4])
            px = memoryview(data)[4:]
            runs = []
            for yy in range(h):
                row = yy * w * 4
                xx = 0
                while xx < w:
                    if px[row + xx * 4 + 3]:
                        x0 = xx
                        while xx < w and px[row + xx * 4 + 3]:
                            xx += 1
                        runs.append((yy, x0, bytes(px[row + x0 * 4:row + xx * 4])))
                    else:
                        xx += 1
            base = fn[:-4]
            if "_f" in base:
                base = base.rsplit("_f", 1)[0]
            out.setdefault(base, []).append((w, h, runs))
        except (OSError, struct.error):
            pass
    return out


# ---------------------------------------------------------------- screen ----
class Screen:
    def __init__(self):
        try:
            with open("/sys/class/graphics/fb0/stride") as f:
                self.stride = int(f.read().strip())
        except OSError:
            self.stride = W * 4
        self.pages = 1
        self.page = 0
        self.var = None
        self.font = get_font()
        if SIM:
            self.stride = W * 4
            self.fb = None
            self.frames = []
            self.buf = bytearray(self.stride * H)
            self.template = self._make_bg()
            return
        self.fb = open(FB, "r+b", buffering=0)
        self.buf = bytearray(self.stride * H)
        self.template = self._make_bg()
        # double buffering via fb panning (kills tearing); fallback: direct
        try:
            v = bytearray(160)
            fcntl.ioctl(self.fb.fileno(), 0x4600, v)  # FBIOGET_VSCREENINFO
            if struct.unpack_from("<I", v, 12)[0] < H * 2:
                struct.pack_into("<I", v, 12, H * 2)  # yres_virtual
                fcntl.ioctl(self.fb.fileno(), 0x4601, v)  # FBIOPUT
                fcntl.ioctl(self.fb.fileno(), 0x4600, v)
            if struct.unpack_from("<I", v, 12)[0] >= H * 2:
                self.pages = 2
                self.var = v
        except OSError:
            self.pages = 1

    def reset_pan(self):
        if self.var is not None:
            try:
                struct.pack_into("<I", self.var, 20, 0)
                fcntl.ioctl(self.fb.fileno(), 0x4606, self.var)
            except OSError:
                pass

    def _make_bg(self):
        """Void ground with a Bayer dither field, scanlines and a 32px grid.
        Built once and memcpy'd per frame. Bayer has period 4 in y and the
        scanline period 3, so only 12 distinct rows exist - build those and
        stamp them, instead of touching 300k pixels one at a time."""
        pad = b"\x00" * (self.stride - W * 4)
        rows = []
        for ry in range(12):
            cells = []
            for rx in range(4):
                lit = BAYER4[ry % 4][rx] < 2
                c = VOID_2 if lit else VOID
                if ry % 3 == 2:  # scanline: one row in three sits darker
                    c = tuple(max(0, v - 3) for v in c)
                cells.append(struct.pack("<BBBB", c[2], c[1], c[0], 0))
            rows.append(b"".join(cells) * (W // 4) + pad)
        tpl = bytearray()
        for y in range(H):
            tpl += rows[y % 12]
        self.buf, saved = tpl, self.buf
        for gx in range(0, W, 32):  # grid
            self.rect(gx, 0, 1, H, (10, 13, 10))
        for gy in range(0, H, 32):
            self.rect(0, gy, W, 1, (10, 13, 10))
        for cx, cy in ((0, 0), (W - 8, 0), (0, H - 8), (W - 8, H - 8)):
            self.rect(cx, cy, 8, 1, RULE)      # corner ticks
            self.rect(cx, cy, 1, 8, RULE)
        self.buf = saved
        return bytes(tpl)

    def clear(self):
        self.buf[:] = self.template

    def rect(self, x, y, w, h, c):
        x, y, w, h = int(x), int(y), int(w), int(h)
        if x < 0:
            w += x
            x = 0
        if y < 0:
            h += y
            y = 0
        w, h = min(w, W - x), min(h, H - y)
        if w <= 0 or h <= 0:
            return
        px = struct.pack("<BBBB", c[2], c[1], c[0], 0) * w
        st = self.stride
        buf = self.buf
        for yy in range(y, y + h):
            off = yy * st + x * 4
            buf[off:off + w * 4] = px

    def frame(self, x, y, w, h, c, t=1):
        self.rect(x, y, w, t, c)
        self.rect(x, y + h - t, w, t, c)
        self.rect(x, y, t, h, c)
        self.rect(x + w - t, y, t, h, c)

    # -- text ---------------------------------------------------------------
    def text(self, x, y, s, c, px=14, mono=False, track=0):
        """Draw with the baked Maratype face. y is the top of the line box."""
        f = self.font
        if not f:
            return self._text57(x, y, s, c, max(1, px // 7))
        for rx, ry, rw, rh in f.spans(x, y, s, px, mono, track):
            self.rect(rx, ry, rw, rh, c)
        return x + f.width(s, px, mono, track)

    def text_w(self, s, px=14, mono=False, track=0):
        f = self.font
        if not f:
            return len(s) * 6 * max(1, px // 7)
        return f.width(s, px, mono, track)

    def text_h(self, px=14):
        f = self.font
        return f.line_h(px) if f else 7 * max(1, px // 7)

    def rtext(self, xr, y, s, c, px=14, mono=False, track=0):
        """Right-aligned at xr."""
        return self.text(xr - self.text_w(s, px, mono, track), y, s, c, px,
                         mono, track)

    def vtext(self, x, y, s, c, px=14, mono=False, track=0):
        """Vertical text reading bottom-to-top; (x, y) is the bottom-left of
        the run. Same baked spans as text(), rotated 90 degrees - the board's
        single most repeated device (sideways titles, coordinate strings).
        """
        f = self.font
        if not f:
            return
        for sx, sy, sw, sh in f.spans(0, 0, s, px, mono, track):
            self.rect(x + sy, y - sx - sw, sh, sw, c)

    def ctext(self, xc, y, s, c, px=14, mono=False, track=0):
        return self.text(xc - self.text_w(s, px, mono, track) // 2, y, s, c,
                         px, mono, track)

    _F57 = {
        'A': [0x0E, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
        'B': [0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E],
        'C': [0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E],
        'D': [0x1E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1E],
        'E': [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F],
        'F': [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10],
        'G': [0x0E, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0F],
        'H': [0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
        'I': [0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E],
        'J': [0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0C],
        'K': [0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11],
        'L': [0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F],
        'M': [0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11],
        'N': [0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11],
        'O': [0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
        'P': [0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10],
        'Q': [0x0E, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0D],
        'R': [0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11],
        'S': [0x0F, 0x10, 0x10, 0x0E, 0x01, 0x01, 0x1E],
        'T': [0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04],
        'U': [0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
        'V': [0x11, 0x11, 0x11, 0x11, 0x11, 0x0A, 0x04],
        'W': [0x11, 0x11, 0x11, 0x15, 0x15, 0x1B, 0x11],
        'X': [0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11],
        'Y': [0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04],
        'Z': [0x1F, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1F],
        '0': [0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E],
        '1': [0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E],
        '2': [0x0E, 0x11, 0x01, 0x06, 0x08, 0x10, 0x1F],
        '3': [0x0E, 0x11, 0x01, 0x06, 0x01, 0x11, 0x0E],
        '4': [0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02],
        '5': [0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E],
        '6': [0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E],
        '7': [0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08],
        '8': [0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E],
        '9': [0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C],
        '%': [0x19, 0x19, 0x02, 0x04, 0x08, 0x13, 0x13],
        ':': [0x00, 0x0C, 0x0C, 0x00, 0x0C, 0x0C, 0x00],
        '.': [0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x0C],
        ',': [0x00, 0x00, 0x00, 0x00, 0x0C, 0x04, 0x08],
        '-': [0x00, 0x00, 0x00, 0x1F, 0x00, 0x00, 0x00],
        '/': [0x01, 0x01, 0x02, 0x04, 0x08, 0x10, 0x10],
        '+': [0x00, 0x04, 0x04, 0x1F, 0x04, 0x04, 0x00],
        '!': [0x04, 0x04, 0x04, 0x04, 0x04, 0x00, 0x04],
        '?': [0x0E, 0x11, 0x01, 0x02, 0x04, 0x00, 0x04],
        '=': [0x00, 0x1F, 0x00, 0x1F, 0x00, 0x00, 0x00],
        '[': [0x0E, 0x08, 0x08, 0x08, 0x08, 0x08, 0x0E],
        ']': [0x0E, 0x02, 0x02, 0x02, 0x02, 0x02, 0x0E],
        '(': [0x02, 0x04, 0x08, 0x08, 0x08, 0x04, 0x02],
        ')': [0x08, 0x04, 0x02, 0x02, 0x02, 0x04, 0x08],
        '*': [0x00, 0x0A, 0x04, 0x1F, 0x04, 0x0A, 0x00],
        ' ': [0, 0, 0, 0, 0, 0, 0],
    }

    def _text57(self, x, y, s, c, scale):
        """Emergency fallback if the baked font is missing."""
        cx = int(x)
        y = int(y)
        for ch in s.upper():
            g = self._F57.get(ch, self._F57['?'])
            for ry, bits in enumerate(g):
                rx = 0
                while rx < 5:
                    if bits & (0x10 >> rx):
                        run = 1
                        while rx + run < 5 and bits & (0x10 >> (rx + run)):
                            run += 1
                        self.rect(cx + rx * scale, y + ry * scale,
                                  run * scale, scale, c)
                        rx += run
                    else:
                        rx += 1
            cx += 6 * scale
        return cx

    def restore(self, x, y, w, h):
        """Put the background template back over a region - used to cut
        notches out of panels without leaving a flat black hole in the
        dither."""
        x, y, w, h = int(x), int(y), int(w), int(h)
        if x < 0:
            w += x
            x = 0
        if y < 0:
            h += y
            y = 0
        w, h = min(w, W - x), min(h, H - y)
        if w <= 0 or h <= 0:
            return
        st = self.stride
        for yy in range(y, y + h):
            off = yy * st + x * 4
            self.buf[off:off + w * 4] = self.template[off:off + w * 4]

    def blit(self, x, y, art):
        w, h, runs = art
        x, y = int(x), int(y)
        st = self.stride
        buf = self.buf
        for dy, dx, b in runs:
            yy = y + dy
            if yy < 0 or yy >= H:
                continue
            xx = x + dx
            n = len(b) // 4
            if xx >= W or xx + n <= 0:
                continue
            if xx < 0:
                b = b[-xx * 4:]
                n += xx
                xx = 0
            if xx + n > W:
                b = b[:(W - xx) * 4]
                n = W - xx
            off = yy * st + xx * 4
            buf[off:off + n * 4] = b

    def flush(self):
        if SIM:
            self.frames.append(bytes(self.buf))
            return
        if self.pages > 1:
            page = 1 - self.page
            try:
                self.fb.seek(page * self.stride * H)
                self.fb.write(self.buf)
                struct.pack_into("<I", self.var, 20, page * H)  # yoffset
                fcntl.ioctl(self.fb.fileno(), 0x4606, self.var)  # FBIOPAN
                self.page = page
                return
            except OSError:
                self.pages = 1
        self.fb.seek(0)
        self.fb.write(self.buf)


# ---------------------------------------------------------------- chrome ----
def plate(scr, x, y, w, h, label=None, fill=GRAPHITE, edge=RULE,
          label_col=None, notch=10):
    """Brutalist panel: flat fill, 1px rule, one clipped corner, and a solid
    label tab knocked out of the frame line."""
    scr.rect(x, y, w, h, fill)
    scr.frame(x, y, w, h, edge, 1)
    # clipped top-right corner, cut back to the background rather than to flat
    # black, so the dither reads continuously through the notch
    for i in range(notch):
        scr.restore(x + w - notch + i, y + i, notch - i, 1)
        scr.rect(x + w - notch + i, y + i, 1, 1, edge)
    if label:
        # Panel names carry at 14px; the 10px face is reserved for the
        # deliberately-tiny technical annotations. The tab overhangs the top
        # edge by 2px, so panel content must start at y+16 or below.
        lw = scr.text_w(label, LABEL_PX, track=1) + 12
        scr.rect(x + 6, y - 2, lw, 16, ACID if label_col is None else label_col)
        scr.text(x + 12, y - 1, label, VOID, LABEL_PX, track=1)
    return x + 6, y + 18, w - 12, h - 24  # inner content box


def bar(scr, x, y, w, h, pct, col, seg=6, gap=2, track_col=None,
        zones=(), marker=None):
    """Segmented horizontal meter. Discrete blocks, not a smooth fill - the
    segmentation is what makes it read as instrumentation."""
    n = max(1, (w + gap) // (seg + gap))
    lit = int(round(n * max(0.0, min(100.0, pct)) / 100.0))
    for i in range(n):
        sx = x + i * (seg + gap)
        if i < lit:
            c = col
        else:
            c = track_col if track_col else GRAPHITE_2
            for z0, z1, zc in zones:  # unlit band tinting
                if z0 <= (i + 0.5) * 100.0 / n < z1:
                    c = zc
                    break
        scr.rect(sx, y, seg, h, c)
    if marker is not None:
        mx = x + int(w * max(0.0, min(100.0, marker)) / 100.0)
        scr.rect(mx, y - 3, 1, h + 6, BONE)
    return n


def vbar(scr, x, y, w, h, pct, col, seg=6, gap=2, zones=()):
    """Segmented vertical meter, filling upward."""
    n = max(1, (h + gap) // (seg + gap))
    lit = int(round(n * max(0.0, min(100.0, pct)) / 100.0))
    for i in range(n):
        sy = y + h - seg - i * (seg + gap)
        if i < lit:
            c = col
        else:
            c = GRAPHITE_2
            for z0, z1, zc in zones:
                if z0 <= (i + 0.5) * 100.0 / n < z1:
                    c = zc
                    break
        scr.rect(x, sy, w, seg, c)
    return n


def hazard(scr, x, y, w, h, phase=0.0, col=ALERT, back=VOID, pitch=12):
    """Diagonal warning stripes, scrolling with phase."""
    off = int(phase * pitch) % pitch
    scr.rect(x, y, w, h, back)
    for sy in range(h):
        sx = x + ((sy + off) % pitch)
        while sx < x + w:
            wpx = min(pitch // 2, x + w - sx)
            if wpx > 0:
                scr.rect(sx, y + sy, wpx, 1, col)
            sx += pitch

def invert_plate(scr, x, y, w, h, text, px=20, col=ACID, notch=8):
    """Solid acid slab with the label knocked out in void - the poster
    'LAUNCH' move. Use sparingly; it takes over wherever it lands."""
    scr.rect(x, y, w, h, col)
    for i in range(notch):
        scr.rect(x + w - notch + i, y + i, notch - i, 1, VOID)
        scr.rect(x, y + h - notch + i, notch - i, 1, VOID)
    scr.ctext(x + w // 2, y + (h - scr.text_h(px)) // 2 + 1, text, VOID, px,
              track=1)


GLYPHS = ("bars", "x", "target", "checker", "cross", "arrow", "dots")


def glyph(scr, x, y, s, kind, col):
    """The small technical marks from the reference posters: barcode, X,
    reticle, checker, plus, arrow, dot matrix. All drawn from rects."""
    if kind == "bars":
        for i, wd in enumerate((1, 2, 1, 3, 1, 1, 2)):
            scr.rect(x + i * 3, y, wd, s, col)
    elif kind == "x":
        for i in range(s):
            scr.rect(x + i, y + i, 2, 1, col)
            scr.rect(x + s - 1 - i, y + i, 2, 1, col)
    elif kind == "target":
        scr.frame(x, y, s, s, col, 1)
        scr.rect(x + s // 2 - 1, y + s // 2 - 1, 3, 3, col)
    elif kind == "checker":
        c = max(2, s // 4)
        for iy in range(4):
            for ix in range(4):
                if (ix + iy) % 2 == 0:
                    scr.rect(x + ix * c, y + iy * c, c, c, col)
    elif kind == "cross":
        scr.rect(x + s // 2 - 1, y, 2, s, col)
        scr.rect(x, y + s // 2 - 1, s, 2, col)
    elif kind == "arrow":
        for i in range(s // 2):
            scr.rect(x + i, y + s // 2 - i - 1, 1, 2 * i + 2, col)
        scr.rect(x + s // 2, y + s // 2 - 1, s // 2, 2, col)
    elif kind == "dots":
        for iy in range(3):
            for ix in range(3):
                scr.rect(x + ix * 4, y + iy * 4, 2, 2, col)


def glyph_row(scr, x, y, s, seed, col, n=6, pitch=22):
    rnd = random.Random(seed)
    for i in range(n):
        glyph(scr, x + i * pitch, y, s, rnd.choice(GLYPHS), col)
    return x + n * pitch


def dotted(scr, x, y, w, col, pitch=4):
    for sx in range(x, x + w, pitch):
        scr.rect(sx, y, 2, 1, col)


# ----------------------------------------------------------------- worms ----
# The specimen-tray motif: a parallel row of ribbed acid-green larvae
# on a red ribbed bed, each one individually serial-numbered (133083, 133084,
# ...). It reads as a specimen tray, which is exactly what a run history is -
# so the worms are not decoration here, they ARE the log.
#
# Built from rects: ribs along an axis, fat in the middle and tapering at both
# ends, with a travelling sine so the body undulates and a bright top edge for
# the glossy translucent look. About 3 rects per rib.

def worm_tones(col):
    """(body, gloss) from a base colour. The reference larvae are bright
    overall with a lighter top, not dark bodies with a bright rim - dividing
    the base by three made them read as wires."""
    return tuple(int(v * 0.55) for v in col), col


def worm(scr, x, y, length, thick, phase, body, hi, waves=1.7, amp=2.2,
         ribs=None):
    """One larva, laid horizontally, head at the left."""
    ribs = ribs or max(4, int(length // 7))
    pitch = length / float(ribs)
    rw = max(1, int(pitch) - 1)          # the -1 leaves the segment gap
    for i in range(ribs):
        u = (i + 0.5) / ribs
        prof = math.sin(math.pi * u) ** 0.45      # rounded ends, fat middle
        h = max(2, int(round(thick * prof)))
        dy = amp * math.sin(2 * math.pi * (u * waves - phase))
        rx = int(x + i * pitch)
        ry = int(y + (thick - h) * 0.5 + dy)
        scr.rect(rx, ry, rw, h, body)
        scr.rect(rx, ry, rw, max(1, h // 3), hi)  # gloss along the top
    # head cap: a touch taller than the first rib, no gap
    hp = math.sin(math.pi * (0.5 / ribs)) ** 0.45
    hh = max(2, int(round(thick * hp)) + 1)
    hy = int(y + (thick - hh) * 0.5 + amp * math.sin(2 * math.pi * -phase))
    scr.rect(int(x) - 2, hy, 3, hh, hi)


def specimen_bed(scr, x, y, w, h, col, pitch=5):
    """The ribbed substrate the larvae lie on - vertical hairlines, not stripes,
    so it stays quiet under the worms."""
    for sx in range(x, x + w, pitch):
        scr.rect(sx, y, 1, h, col)


def specimen_tray(scr, app, x, y, w, h, t):
    """The run history as a specimen tray: one serial-numbered larva per closed
    window, coloured by rank, the most recent first and still moving."""
    scr.rect(x, y, w, h, (16, 12, 10))
    scr.frame(x, y, w, h, RULE, 1)
    scr.rect(x, y, 3, h, ALERT_D)

    runs = list(reversed(app.runs))
    if not runs:
        scr.ctext(x + w // 2, y + h // 2 - 8, "NO SPECIMENS", BONE_D, 14,
                  track=2)
        return
    # A larva is roughly 8:1, not 50:1. Stretching one specimen across the full
    # panel width turned it into a flat ribbon with no readable taper, so the
    # body size is fixed and the tray columns instead.
    WL, WT, ROW, LAB = 96, 12, 17, 52
    cw = WL + LAB + 10
    cols = max(1, min(5, (w - 10) // cw))
    per_col = max(1, (h - 10) // ROW)
    for i, r in enumerate(runs[:per_col * cols]):
        # row-major: specimens spread across the tray before starting a new
        # row, so six runs read as a filled tray rather than one lonely column
        c, k = i % cols, i // cols
        wx = x + 10 + c * cw
        wy = y + 6 + k * ROW
        # the ribbed red substrate goes only under an occupied slot - drawn
        # across the whole panel it read as a barcode field, not a bed
        specimen_bed(scr, wx - 4, wy - 2, WL + 8, WT + 3, (68, 26, 16))
        n = len(app.runs) - i
        col = RANK_COL.get(r["rank"], BONE_D)
        # baked specimen art if present (three undulation poses per rank
        # palette); the newest cycles poses fastest, older ones settle
        frames = ART.get("worm_" + WORM_PAL.get(r["rank"], "boned"))
        if frames:
            k = int(t * (2.4 if i == 0 else 0.5) + i * 1.7) % len(frames)
            scr.blit(wx - 2, wy - 2, frames[k])
        else:
            dim, col = worm_tones(col)
            # the newest specimen breathes hardest; older ones settle down
            ph = t * (0.34 if i == 0 else 0.09 + 0.012 * (i % 5)) + i * 0.37
            worm(scr, wx, wy, WL, WT, ph, dim, col,
                 amp=2.6 if i == 0 else 1.3)
        scr.text(wx + WL + 8, wy + 2, "%06d" % (133000 + n), BONE_D, 10,
                 track=1)
    shown = min(len(runs), per_col * cols)
    if shown < len(runs):
        scr.rtext(x + w - 6, y + h - 13, "+%d OLDER" % (len(runs) - shown),
                  BONE_D, 10, track=1)


# ================================================================= model ====
# Everything durable is recomputed from the history log. There is no save
# file: open the game twice and you get the same numbers both times.

WINDOW_S = 5 * 3600      # the 5-hour usage window
DROP = 5                 # a fall of more than this in fh means a new window
GAP_S = 6 * 3600         # a gap this long also splits windows

# load% -> (name, base multiplier). IN BAND additionally ramps with time held.
BANDS = (
    (0, 35, "COLD", 0.6),
    (35, 60, "NOMINAL", 1.0),
    (60, 85, "IN BAND", 2.0),
    (85, 95, "CRITICAL", 1.2),
    (95, 1e9, "BLACKOUT", 0.0),
)
BAND_LO, BAND_HI = 60, 85
BLACKOUT_AT = 95
IN_BAND_RAMP_S = 3600.0  # time in band to take the multiplier 2.0 -> 3.0

# banked = salvage * this, by the band you extract in. Extracting is always
# allowed; extracting badly just pays badly.
EXTRACT_BONUS = {"COLD": 0.7, "NOMINAL": 1.0, "IN BAND": 1.5,
                 "CRITICAL": 1.2, "BLACKOUT": 0.0}

# Calibrated against the reachable range, not a guess: a clean window banks
# roughly 6 (never touched it) to 170 (climbed slowly and parked at the top of
# the band). Riding to 94 banks less than holding at 84 - that is the point.
RANKS = ((160, "S"), (120, "A"), (75, "B"), (30, "C"), (0, "D"))


def band_of(pct):
    for lo, hi, name, mult in BANDS:
        if lo <= pct < hi:
            return name, mult
    return BANDS[-1][2], BANDS[-1][3]


def rank_of(salvage, blackout):
    if blackout:
        return "F"
    for need, r in RANKS:
        if salvage >= need:
            return r
    return "D"


def read_hist(path=None):
    """[(t, fh, sd, fb, rl), ...] oldest first."""
    pts = []
    try:
        with open(path or HIST) as f:
            for line in f:
                try:
                    r = json.loads(line)
                    pts.append((int(r["t"]), int(r.get("fh", 0)),
                                int(r.get("sd", 0)), int(r.get("fb", 0)),
                                int(r.get("rl", 0))))
                except (ValueError, KeyError, TypeError):
                    pass
    except OSError:
        return []
    pts.sort(key=lambda p: p[0])
    return pts


def segment(pts):
    """Split the sample log into 5-hour windows. A boundary is a drop in the
    5h percentage (the meter reset) or a long silence."""
    if not pts:
        return []
    wins = [[pts[0]]]
    for prev, cur in zip(pts, pts[1:]):
        if cur[1] < prev[1] - DROP or cur[0] - prev[0] > GAP_S:
            wins.append([cur])
        else:
            wins[-1].append(cur)
    return wins


def score_window(win):
    """Salvage for one window, walked sample by sample.

    Salvage accrues only on *rises* in load - it is paid for work done, not for
    sitting still - and each rise is paid at the multiplier of the band it
    happened in. Time already held in band ramps the in-band multiplier, so a
    long productive stretch beats the same usage spiked."""
    salvage = 0.0
    held = 0.0
    peak = win[0][1] if win else 0
    for prev, cur in zip(win, win[1:]):
        dt = max(0, cur[0] - prev[0])
        mid = (prev[1] + cur[1]) * 0.5
        name, mult = band_of(mid)
        if name == "IN BAND":
            mult += min(1.0, held / IN_BAND_RAMP_S)
            held += dt
        else:
            held = 0.0
        salvage += max(0, cur[1] - prev[1]) * mult
        peak = max(peak, cur[1])
    blackout = peak >= BLACKOUT_AT or any(p[4] for p in win)
    return {
        "salvage": salvage,
        "held": held,
        "peak": peak,
        "blackout": blackout,
        "t0": win[0][0] if win else 0,
        "t1": win[-1][0] if win else 0,
        "start": win[0][1] if win else 0,
        "end": win[-1][1] if win else 0,
        "n": len(win),
    }


def auto_bank(r):
    """What a window banks with no player in the loop.

    Closed windows predate this session - with no save file there is no record
    of an extraction - so they resolve as though extracted at whatever band
    they ended in. That puts historical ranks on the same scale as the live
    one instead of ranking raw salvage against banked salvage."""
    return r["salvage"] * EXTRACT_BONUS.get(band_of(r["end"])[0], 1.0)


def resolve_runs(wins):
    """Score every closed window. Callers pass only closed ones - the live
    window is still being played."""
    out = []
    for w in wins:
        r = score_window(w)
        r["banked"] = auto_bank(r)
        r["rank"] = rank_of(r["banked"], r["blackout"])
        out.append(r)
    return out


def streak_of(runs):
    """Consecutive most-recent closed windows that did not black out."""
    n = 0
    for r in reversed(runs):
        if r["blackout"]:
            break
        n += 1
    return n


def parse_reset(s, now):
    """The pusher formats resets as 'HH:MM' (today) or 'DDD HH:MM'. Turn that
    back into an epoch so the season can be projected."""
    if not s or not isinstance(s, str):
        return None
    parts = s.strip().upper().split()
    try:
        if len(parts) == 1:
            hh, mm = [int(v) for v in parts[0].split(":")]
            lt = time.localtime(now)
            cand = time.mktime((lt.tm_year, lt.tm_mon, lt.tm_mday, hh, mm, 0,
                                0, 0, -1))
            return cand + 86400 if cand < now else cand
        days = ("MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN")
        if parts[0][:3] not in days:
            return None
        want = days.index(parts[0][:3])
        hh, mm = [int(v) for v in parts[1].split(":")]
        lt = time.localtime(now)
        base = time.mktime((lt.tm_year, lt.tm_mon, lt.tm_mday, hh, mm, 0,
                            0, 0, -1))
        cand = base + ((want - lt.tm_wday) % 7) * 86400
        return cand + 7 * 86400 if cand < now else cand
    except (ValueError, IndexError, OverflowError):
        return None


def project(pts, idx, reset_at, now, hours=24):
    """Linear extrapolation of a series to the reset instant. None when there
    is not enough recent movement to say anything honest."""
    if not reset_at or reset_at <= now:
        return None
    t0 = now - hours * 3600
    rec = [(p[0], p[idx]) for p in pts if p[0] >= t0]
    if len(rec) < 4:
        return None
    span = rec[-1][0] - rec[0][0]
    if span < 1800:
        return None
    rate = (rec[-1][1] - rec[0][1]) / float(span)
    if rate <= 0:
        return float(rec[-1][1])
    return min(999.0, rec[-1][1] + rate * (reset_at - now))


def contracts_of(runs, live, pts, sd, sd_reset_at, now):
    """Objectives, all derived - nothing is stored between launches.
    Each is (label, detail, progress 0..1, done)."""
    day = now - 86400
    recent = [r for r in runs if r["t1"] >= day]
    in_band = sum(1 for r in recent if BAND_LO <= r["peak"] <= 90)
    clean = bool(recent) and not any(r["blackout"] for r in recent)
    held_min = (live["held"] / 60.0) if live else 0.0
    out = [
        ("SALVAGE RUNS", "3 WINDOWS PEAKING 60-90 IN 24H",
         min(1.0, in_band / 3.0), in_band >= 3),
        ("CLEAN SHEET", "NO BLACKOUT IN 24H",
         1.0 if clean else 0.0, clean),
        ("SUSTAIN", "60 MIN HELD IN BAND THIS RUN",
         min(1.0, held_min / 60.0), held_min >= 60),
    ]
    proj = project(pts, 2, sd_reset_at, now)
    if proj is not None:
        out.append(("SEASON DISCIPLINE",
                    "PROJECTED %d%% AT RESET - HOLD UNDER 90" % int(proj),
                    min(1.0, max(0.0, (100.0 - proj) / 10.0)), proj < 90))
    else:
        out.append(("SEASON DISCIPLINE", "HOLD SEASON UNDER 90",
                    min(1.0, max(0.0, (100.0 - sd) / 10.0)), sd < 90))
    return out


class Run:
    """The live window, plus the one thing the player actually does.

    EXTRACT is in-memory only: with no save file it cannot outlive the session.
    That is a known, deliberate limit of the session-only design, not a bug."""

    def __init__(self):
        self.banked = 0.0
        self.banked_at = None     # (epoch, band, rank) at the moment of extract
        self.extracted = False
        self.window_t0 = None

    def sync(self, window_t0):
        """A new window is a new run: any extraction from the old one is void."""
        if self.window_t0 != window_t0:
            self.window_t0 = window_t0
            self.banked = 0.0
            self.banked_at = None
            self.extracted = False

    def extract(self, live, load, now):
        if self.extracted:
            return None
        name, _m = band_of(load)
        self.banked = live["salvage"] * EXTRACT_BONUS.get(name, 1.0)
        self.extracted = True
        rank = rank_of(self.banked, live["blackout"])
        self.banked_at = (now, name, rank)
        return rank

    def at_risk(self, live):
        """Salvage still in the pack: everything if you have not extracted,
        only the over-extension if you have."""
        if not self.extracted:
            return live["salvage"]
        return max(0.0, live["salvage"] - self.banked)

    def state(self, load, live):
        if live["blackout"] or load >= BLACKOUT_AT:
            return "BLACKOUT"
        if self.extracted:
            return "OVER-EXTENSION" if self.at_risk(live) > 1 else "EXTRACTED"
        return band_of(load)[0]


# ================================================================ drill =====
# One full window compressed into a 90-second loop: cold -> climb -> ride the
# band -> critical -> blackout -> reset. Every mechanic (including a live
# EXTRACT on the A button) can be seen without burning a real 5-hour window.
DEMO_CYCLE_S = 90.0
DEMO_CURVE = ((0, 3), (10, 18), (35, 61), (55, 72), (70, 88), (78, 97),
              (88, 97))


def demo_state(el, now):
    """Synthetic pusher payload for the PROTOCOL DRILL at `el` seconds in."""
    c = el % DEMO_CYCLE_S
    fh = DEMO_CURVE[-1][1]
    for (t0, v0), (t1, v1) in zip(DEMO_CURVE, DEMO_CURVE[1:]):
        if c <= t1:
            fh = v0 + (v1 - v0) * (c - t0) / float(t1 - t0)
            break
    d = {
        "five_hour_pct": int(fh),
        "seven_day_pct": min(85, 72 + int(el // DEMO_CYCLE_S)),
        "fable_pct": 81,
        "updated": time.strftime("%H:%M:%S", time.localtime(now)),
        "five_hour_reset": time.strftime(
            "%H:%M", time.localtime(now + (DEMO_CYCLE_S - c))),
        "seven_day_reset": time.strftime(
            "%a %H:%M", time.localtime(now + 2 * 86400)).upper(),
        "sessions": "DRILL DECK",
        "note": "PROTOCOL DRILL - SYNTHETIC",
    }
    if fh >= 96:
        d["rl"] = 1
    return d


# ================================================================== app =====
TABS = ("RUN", "TRACE", "LOG", "TASKS", "LINK")

HEAD_Y, HEAD_H = 4, 26
BODY_Y, BODY_B = 36, 446
FOOT_Y = 452
MARGIN = 8

STATE_COL = {
    "COLD": CYAN, "NOMINAL": BONE, "IN BAND": ACID, "CRITICAL": (255, 176, 40),
    "BLACKOUT": ALERT, "EXTRACTED": ACID, "OVER-EXTENSION": (255, 176, 40),
}

# unlit band tinting for the LOAD meter, so the productive stretch is visible
# before you get there
LOAD_ZONES = ((0, 35, (26, 34, 30)), (35, 60, (32, 40, 32)),
              (60, 85, ACID_XD), (85, 95, (74, 40, 18)), (95, 101, ALERT_D))


def commas(v):
    s = "%d" % int(v)
    out = ""
    while len(s) > 3:
        out = "," + s[-3:] + out
        s = s[:-3]
    return s + out


def fmt_dur(s):
    s = int(max(0, s))
    if s < 3600:
        return "%dM" % (s // 60)
    return "%dH %02dM" % (s // 3600, (s % 3600) // 60)


def fmt_clock(t):
    return time.strftime("%H:%M", time.localtime(t))


class App:
    """Holds everything the frame loop needs, and decides when the (relatively
    expensive) model recompute is allowed to happen."""

    MODEL_EVERY = 5.0  # seconds; segmenting a full log is not a per-frame job

    def __init__(self):
        self.tab = 0
        self.run = Run()
        self.data = None
        self.data_mtime = 0.0
        self.pts = []
        self.runs = []
        self.live = None
        self.live_win = []
        self.next_model = 0.0
        self.wipe_until = 0.0
        self.stamp_until = 0.0
        self.burn_until = 0.0     # blackout burn flash (alert burst)
        self.stamp_rank = None
        self.trace_zoom = 2       # index into TRACE_SPANS
        self.msg = None           # (text, until)
        self.alarm_state = None   # 'clear' | 'alarm' | 'blackout'
        self.boot_at = time.time()
        self.log = []
        self.frame_ms = 0.0
        self.last_input = time.time()
        self.attract = False
        self.demo = DEMO_START
        self.demo_t0 = time.time()
        self.demo_pts = None

    # -- data ---------------------------------------------------------------
    def poll(self, t, force=False):
        if self.demo:
            self.data = demo_state(t - self.demo_t0, t)
            self.data_mtime = t
            if force or t >= self.next_model:
                self.next_model = t + self.MODEL_EVERY
                self.rebuild(t)
            return
        try:
            mt = os.path.getmtime(DATA)
        except OSError:
            mt = 0.0
        fresh = mt != self.data_mtime
        if fresh:
            self.data_mtime = mt
            try:
                with open(DATA) as f:
                    self.data = json.load(f)
            except (OSError, ValueError):
                self.data = None
        if fresh or force or t >= self.next_model:
            self.next_model = t + self.MODEL_EVERY
            self.rebuild(t)

    def demo_feed(self, t):
        """In-memory history for the drill: the committed fixture (rebased so
        its closed windows read as recent) plus one synthetic sample per model
        tick. Nothing is ever written to the real history file."""
        if self.demo_pts is None:
            base = read_hist(FIXTURE_HIST)
            if base:
                shift = int(self.demo_t0 - GAP_S - 60) - base[-1][0]
                base = [(p[0] + shift, p[1], p[2], p[3], p[4]) for p in base]
            self.demo_pts = base
        d = self.data or {}
        fh = int(d.get("five_hour_pct", 0))
        last = self.demo_pts[-1] if self.demo_pts else None
        if not last or last[0] < int(t) - 2 or last[1] != fh:
            self.demo_pts.append((int(t), fh, int(d.get("seven_day_pct", 0)),
                                  int(d.get("fable_pct", 0)),
                                  1 if d.get("rl") else 0))
        return list(self.demo_pts)

    def rebuild(self, t):
        self.pts = self.demo_feed(t) if self.demo else read_hist()
        wins = segment(self.pts)
        if wins:
            self.live_win = wins[-1]
            self.runs = resolve_runs(wins[:-1])
            self.live = score_window(self.live_win)
        else:
            self.live_win = []
            self.runs = []
            self.live = score_window([])
        self.run.sync(self.live["t0"] if self.live_win else None)
        self.rebuild_log()

    def rebuild_log(self):
        """The ticker: newest first, phrased as terminal output."""
        out = []
        for i, r in enumerate(reversed(self.runs[-6:])):
            out.append("WINDOW %03d  PEAK %d%%  %s  %s CR"
                       % (len(self.runs) - i, r["peak"], "RANK " + r["rank"],
                          commas(r["banked"])))
        if not out:
            out.append("NO CLOSED WINDOWS YET - COLLECTING")
        self.log = out

    # -- derived ------------------------------------------------------------
    def age(self, t):
        return t - self.data_mtime if self.data_mtime else 1e9

    def load(self):
        if self.data:
            return int(self.data.get("five_hour_pct", 0))
        return self.live["end"] if self.live_win else 0

    def season(self):
        return int(self.data.get("seven_day_pct", 0)) if self.data else 0

    def core(self):
        return int(self.data.get("fable_pct", 0)) if self.data else 0

    def trend(self, t, window=900):
        """Rate of change of load over the last quarter hour."""
        rec = [p for p in self.pts if p[0] >= t - window]
        if len(rec) < 2:
            return 0.0
        return rec[-1][1] - rec[0][1]

    def state(self):
        return self.run.state(self.load(), self.live) if self.live else "COLD"

    def say(self, text, secs=2.5):
        self.msg = (text, time.time() + secs)


# --------------------------------------------------------------- chrome -----
def draw_header(scr, app, t):
    y = HEAD_Y
    # identity cell
    scr.rect(MARGIN, y, 150, HEAD_H, GRAPHITE)
    scr.frame(MARGIN, y, 150, HEAD_H, RULE, 1)
    scr.text(MARGIN + 5, y + 2, "RUNNER PROTOCOL", ACID, 10, track=1)
    if app.demo:
        # the drill badge lives where the deck id normally sits: unmissable,
        # and it reads as mode, not data
        scr.text(MARGIN + 5, y + 13, "PROTOCOL DRILL / SYNTHETIC",
                 ALERT if int(t) % 2 else ALERT_D, 10, track=1)
    else:
        scr.text(MARGIN + 5, y + 13, "R36S / SEC-7 / 640X480", BONE_D, 10,
                 track=1)

    # tab strip: active tab is a solid slab with the label knocked out
    tx = 158
    for i, name in enumerate(TABS):
        tw = 72
        if i == app.tab:
            scr.rect(tx, y, tw, HEAD_H, ACID)
            scr.ctext(tx + tw // 2, y + 7, name, VOID, 14, track=1)
        else:
            scr.rect(tx, y, tw, HEAD_H, GRAPHITE)
            scr.frame(tx, y, tw, HEAD_H, RULE, 1)
            scr.ctext(tx + tw // 2, y + 7, name, BONE_D, 14, track=1)
        tx += tw + 2

    # clock cell
    cx = 532
    scr.rect(cx, y, W - MARGIN - cx, HEAD_H, GRAPHITE)
    scr.frame(cx, y, W - MARGIN - cx, HEAD_H, RULE, 1)
    scr.text(cx + 6, y + 3, fmt_clock(t), ACID, 20, mono=True)
    stale = app.age(t) > 300
    scr.rect(W - MARGIN - 12, y + 8, 6, 6, ALERT if stale else ACID)


def draw_footer(scr, app, t):
    y = FOOT_Y
    scr.rect(MARGIN, y, W - 2 * MARGIN, 1, RULE)
    hint = ("Y END DRILL   A EXTRACT   SEL+START EXIT" if app.demo
            else "L1/R1 TAB   A EXTRACT   SEL+START EXIT")
    hw = scr.text_w(hint, 10, track=1)
    tick_r = W - MARGIN - hw - 14   # the ticker's hard right edge

    if app.msg and t < app.msg[1]:
        scr.text(MARGIN, y + 6, app.msg[0], ACID, 14, track=1)
    else:
        # ticker: the log scrolls as one continuous line, clipped to its lane
        # so it never collides with the control hints
        line = "   ///   ".join(app.log) + "   ///   "
        wpx = scr.text_w(line, 10, track=1)
        if wpx > 0:
            off = int((t * 22) % wpx)
            scr.text(MARGIN - off, y + 8, line + line, ACID_D, 10, track=1)
            scr.restore(0, y + 6, MARGIN, 14)
            scr.restore(tick_r, y + 6, W - tick_r, 14)
    scr.rect(tick_r + 4, y + 6, 1, 13, RULE)
    scr.rtext(W - MARGIN, y + 8, hint, BONE_D, 10, track=1)


def draw_wait(scr, t):
    """No data at all: the PC side is not talking to us."""
    plate(scr, MARGIN, BODY_Y, W - 2 * MARGIN, BODY_B - BODY_Y, "NO SIGNAL")
    cy = BODY_Y + 120
    scr.ctext(W // 2, cy, "AWAITING UPLINK", ALERT if int(t * 2) % 2 else
              ALERT_D, 32, track=2)
    net = ("CONNECT TO THE %s HOTSPOT" % CONFIG["ssid"].upper()
           if CONFIG.get("ssid") else "CHECK THE CONSOLE'S WIFI LINK")
    for i, s in enumerate((
            "THE PC IS NOT PUSHING USAGE DATA.",
            "",
            "1. " + net,
            "2. START THE USAGE PUSHER ON THE PC",
            "3. THIS SCREEN CLEARS ON ITS OWN")):
        scr.ctext(W // 2, cy + 60 + i * 22, s, BONE_D, 14, track=1)
    scr.ctext(W // 2, cy + 192, "NO PC?  PRESS  Y  -  PROTOCOL DRILL",
              ACID, 14, track=1)
    scr.ctext(W // 2, cy + 212, "(A FULL RUN ON SYNTHETIC DATA)", ACID_D, 10,
              track=1)
    glyph_row(scr, W // 2 - 66, cy + 240, 12, 7, ACID_XD, 6, 22)


# ------------------------------------------------------------- screen: RUN --
ART = {}


def callout(scr, pxx, pxy, lx, ly, label, col, box=True):
    """A boxed label pinned to a point with a thin leader line - the board's
    annotated-callout move. The leader runs diagonally from the pin until it
    is level with the label, then straight. (lx, ly) is the label's left edge
    baseline; the label sits on whichever side of the pin it was placed."""
    scr.rect(pxx - 1, pxy - 1, 3, 3, col)  # the pin itself
    yy = ly + 5
    sx = 1 if lx >= pxx else -1
    x = pxx
    for i in range(abs(yy - pxy)):  # 45-degree segment...
        x = pxx + sx * i
        scr.rect(x, pxy + (1 if yy > pxy else -1) * i, 1, 1, col)
    tw = scr.text_w(label, 10, track=1)
    x2 = lx - 4 if sx > 0 else lx + tw + 4
    scr.rect(min(x, x2), yy, abs(x2 - x) + 1, 1, col)  # ...then level
    if box:
        scr.frame(lx - 3, ly - 3, tw + 8, 16, col, 1)
    scr.text(lx, ly, label, col, 10, track=1)


# which hero art set serves which game state; anything unlisted gets the
# inband set, and all of it falls back to the single baked "hero"
HERO_STATE_ART = {"CRITICAL": "hero_critical", "OVER-EXTENSION":
                  "hero_critical", "BLACKOUT": "hero_blackout"}


def hero_art(t, state=None):
    key = HERO_STATE_ART.get(state, "hero_inband")
    frames = ART.get(key) or ART.get("hero")
    if not frames:
        return None
    # 4-frame sets are dither shimmer (fast, 6fps); longer sets are real
    # animation loops and play at 8fps so motion reads smooth
    rate = 6 if len(frames) <= 4 else 8
    return frames[int(t * rate) % len(frames)]


def draw_hero(scr, x, y, w, h, state, col, t, load=None):
    plate(scr, x, y, w, h, "RUNNER")
    art = hero_art(t, state)
    if art:
        ax = x + (w - art[0]) // 2
        scr.blit(ax, y + 16, art)
        if state != "BLACKOUT":
            # annotated callouts pinned to the portrait; on a dead feed the
            # telemetry dies with it
            callout(scr, ax + 96, y + 44, x + 130, y + 22, "SEC-7", RULE_HI)
            if load is not None:
                callout(scr, ax + 74, y + 66, x + 14, y + 100,
                        "%d" % load, ACID_XD, box=False)
    else:
        # no baked portrait yet: a standing wave, so the panel still reads as
        # a live feed rather than an empty box
        for i in range(26):
            ph = math.sin(t * 1.4 + i * 0.34)
            bh = int(6 + abs(ph) * 46)
            scr.rect(x + 12 + i * 6, y + 96 - bh // 2, 4, bh,
                     ACID_D if i % 3 else ACID_XD)
        glyph_row(scr, x + 16, y + 116, 10, 3, ACID_XD, 6, 26)
    invert_plate(scr, x + 6, y + h - 30, w - 12, 24, state, 14, col)


def draw_run(scr, app, t):
    load = app.load()
    live = app.live
    state = app.state()
    col = STATE_COL.get(state, BONE)
    d = app.data or {}

    # -- LOAD ---------------------------------------------------------------
    px, py, pw, ph = MARGIN, BODY_Y, W - 2 * MARGIN, 112
    plate(scr, px, py, pw, ph, "LOAD / 5H WINDOW")
    big = "%d%%" % load
    scr.text(px + 12, py + 18, big, col, 56, mono=True)
    bx = px + 12 + scr.text_w("100%", 56, mono=True) + 18
    scr.text(bx, py + 22, state, col, 32, track=1)
    scr.text(bx, py + 58, "RESETS " + str(d.get("five_hour_reset", "?")),
             BONE_D, 14, track=1)
    delta = app.trend(t)
    if delta > 0.5:
        # rising is good news in band and very bad news above it, so the trend
        # takes the state's colour rather than always reading as healthy
        arrow, acol = "RISING", col if load >= 85 else ACID
    elif delta < -0.5:
        arrow, acol = "FALLING", CYAN
    else:
        arrow, acol = "HOLDING", BONE_D
    scr.rtext(px + pw - 12, py + 20, arrow, acol, 20, track=1)
    if live and app.live_win:
        scr.rtext(px + pw - 12, py + 46, "ELAPSED " + fmt_dur(t - live["t0"]),
                  BONE_D, 14, track=1)
    bar(scr, px + 12, py + 84, pw - 24, 16, load, col,
        zones=LOAD_ZONES, marker=BLACKOUT_AT)

    # -- hero / salvage / extract -------------------------------------------
    ry, rh = 156, 160
    draw_hero(scr, MARGIN, ry, 188, rh, state, col, t, load=load)

    sx, sw = 204, 200
    plate(scr, sx, ry, sw, rh, "SALVAGE")
    if app.run.extracted:
        scr.text(sx + 10, ry + 20, commas(app.run.banked), ACID, 32, mono=True)
        scr.text(sx + 10, ry + 56, "BANKED", ACID_D, 10, track=2)
        risk = app.run.at_risk(live) if live else 0
        scr.text(sx + 10, ry + 76, commas(risk), STATE_COL["OVER-EXTENSION"]
                 if risk > 1 else BONE_D, 20, mono=True)
        scr.text(sx + 10, ry + 100, "OVER-EXTENSION, UNBANKED", BONE_D, 10,
                 track=1)
    else:
        scr.text(sx + 10, ry + 20, commas(live["salvage"] if live else 0),
                 col, 32, mono=True)
        scr.text(sx + 10, ry + 56, "IN THE PACK, UNBANKED", BONE_D, 10, track=1)
        name, mult = band_of(load)
        if name == "IN BAND" and live:
            mult += min(1.0, live["held"] / IN_BAND_RAMP_S)
        scr.text(sx + 10, ry + 74, "MULT x%.1f" % mult, col, 20, track=1)
        if live and live["held"] > 0:
            scr.text(sx + 10, ry + 98, "HELD " + fmt_dur(live["held"]),
                     BONE_D, 14, track=1)
    dotted(scr, sx + 10, ry + rh - 26, sw - 20, RULE)
    scr.text(sx + 10, ry + rh - 22, "SESSION TOTAL ONLY", BONE_D, 10, track=1)

    ex, ew = 412, 220
    draw_extract(scr, app, ex, ry, ew, rh, load, state, col, t)

    # -- season / core ------------------------------------------------------
    gy, gh = 324, 72
    season, core = app.season(), app.core()
    plate(scr, MARGIN, gy, 308, gh, "SEASON / 7D")
    scr.text(MARGIN + 10, gy + 18, "%d%%" % season, pct_col(season), 32,
             mono=True)
    scr.rtext(MARGIN + 298, gy + 20, "RESET " + str(d.get("seven_day_reset",
                                                         "?")), BONE_D, 14,
              track=1)
    proj = project(app.pts, 2, parse_reset(d.get("seven_day_reset"), t), t)
    if proj is not None:
        scr.rtext(MARGIN + 298, gy + 38, "PROJ %d%% AT RESET" % int(proj),
                  pct_col(proj), 14, track=1)
    bar(scr, MARGIN + 10, gy + 54, 288, 10, season, pct_col(season), seg=4,
        gap=2)

    plate(scr, 324, gy, 308, gh, "CORE / FABLE WEEKLY")
    scr.text(334, gy + 18, "%d%%" % core, pct_col(core), 32, mono=True)
    scr.rtext(622, gy + 20, "MODEL-SCOPED", BONE_D, 14, track=1)
    bar(scr, 334, gy + 54, 288, 10, core, pct_col(core), seg=4, gap=2)

    # -- status strip -------------------------------------------------------
    ay, ah = 404, 42
    plate(scr, MARGIN, ay, W - 2 * MARGIN, ah, None)
    streak = streak_of(app.runs)
    scr.text(MARGIN + 12, ay + 8, "STREAK", BONE_D, 10, track=2)
    scr.text(MARGIN + 12, ay + 20, "%02d" % streak, ACID if streak else BONE_D,
             20, mono=True)
    scr.text(MARGIN + 78, ay + 8, "RUNS", BONE_D, 10, track=2)
    scr.text(MARGIN + 78, ay + 20, "%03d" % len(app.runs), BONE, 20, mono=True)
    scr.text(MARGIN + 150, ay + 8, "LAST", BONE_D, 10, track=2)
    scr.text(MARGIN + 150, ay + 20,
             app.runs[-1]["rank"] if app.runs else "-", ACID, 20, mono=True)
    sess = (d.get("sessions") or "") if d else ""
    if isinstance(sess, str):
        sess = [s for s in sess.split(",") if s]
    scr.text(MARGIN + 216, ay + 8, "ACTIVE SESSIONS", BONE_D, 10, track=2)
    scr.text(MARGIN + 216, ay + 20,
             (", ".join(sess)[:26] if sess else "NONE"),
             ACID if sess else BONE_D, 14, track=1)
    # the live specimen: this window, undulating faster the harder it is loaded
    scr.text(W - MARGIN - 186, ay + 6, "THIS WINDOW", BONE_D, 10, track=2)
    rate = 0.10 + (load / 100.0) * 0.55
    wbody, whi = worm_tones(col)
    worm(scr, W - MARGIN - 180, ay + 20, 126, 12, t * rate, wbody, whi,
         amp=1.0 + (load / 100.0) * 2.6)
    scr.text(W - MARGIN - 46, ay + 21, "%06d" % (133000 + len(app.runs) + 1),
             BONE_D, 10, track=1)

    # vertical type up the seam between the hero and salvage plates - machine
    # string as texture, quiet enough to sit over the panel frames
    scr.vtext(194, 398, "RUNNER PROTOCOL // SEC-7 // W%03d"
              % (len(app.runs) + 1), ACID_XD, 10, track=2)


def pct_col(p):
    if p >= 90:
        return ALERT
    if p >= 75:
        return (255, 176, 40)
    return ACID


def draw_extract(scr, app, x, y, w, h, load, state, col, t):
    if state == "BLACKOUT":
        plate(scr, x, y, w, h, "EXTRACT", edge=ALERT_D)
        hazard(scr, x + 6, y + 18, w - 12, 22, t * 0.9)
        scr.ctext(x + w // 2, y + 52, "BLACKOUT", ALERT, 32, track=2)
        scr.ctext(x + w // 2, y + 90, "UNBANKED SALVAGE LOST", BONE_D, 14,
                  track=1)
        scr.ctext(x + w // 2, y + 108, "WAIT FOR THE WINDOW TO RESET",
                  BONE_D, 10, track=1)
        hazard(scr, x + 6, y + h - 34, w - 12, 22, -t * 0.9)
        return

    plate(scr, x, y, w, h, "EXTRACT")
    scr.text(x + 10, y + 18, "BAND %d-%d" % (BAND_LO, BAND_HI), BONE_D, 14,
             track=1)
    in_band = BAND_LO <= load < BAND_HI
    scr.rect(x + w - 22, y + 20, 8, 8, ACID if in_band else GRAPHITE_2)
    scr.rtext(x + w - 28, y + 18, "IN BAND" if in_band else band_of(load)[0],
              ACID if in_band else BONE_D, 14, track=1)
    # where you are against the payout band
    bar(scr, x + 10, y + 40, w - 20, 8, load, col, seg=4, gap=2,
        zones=LOAD_ZONES, marker=BLACKOUT_AT)

    if app.run.extracted:
        _at, bname, brank = app.run.banked_at
        scr.text(x + 10, y + 58, "EXTRACTED IN %s" % bname, BONE_D, 10, track=1)
        invert_plate(scr, x + 6, y + 74, w - 12, 40, "RANK " + brank, 32, ACID)
        scr.ctext(x + w // 2, y + 122, "x%.1f BONUS APPLIED"
                  % EXTRACT_BONUS.get(bname, 1.0), BONE_D, 10, track=1)
    else:
        bonus = EXTRACT_BONUS.get(band_of(load)[0], 1.0)
        scr.text(x + 10, y + 58, "PAYOUT x%.1f AT THIS LOAD" % bonus,
                 ACID if bonus >= 1.5 else BONE_D, 14, track=1)
        pulse = in_band and int(t * 3) % 2 == 0
        invert_plate(scr, x + 6, y + 80, w - 12, 34, "[A] EXTRACT", 20,
                     ACID if pulse or in_band else ACID_D)
        scr.ctext(x + w // 2, y + 122, "BANKS %s CR"
                  % commas((app.live["salvage"] if app.live else 0) * bonus),
                  BONE_D, 10, track=1)


RANK_COL = {"S": ACID, "A": ACID, "B": BONE, "C": BONE_D, "D": BONE_D,
            "F": ALERT}
# rank -> baked worm palette suffix (see bake_art.py PALETTES)
WORM_PAL = {"S": "acid", "A": "acid", "B": "bone", "C": "boned",
            "D": "boned", "F": "alert"}


def rank_stamp(scr, x, y, s, rank, filled=False):
    col = RANK_COL.get(rank, BONE_D)
    if filled:
        scr.rect(x, y, s, s, col)
        scr.ctext(x + s // 2, y + (s - scr.text_h(20)) // 2 + 1, rank, VOID, 20)
    else:
        scr.frame(x, y, s, s, col, 1)
        scr.ctext(x + s // 2, y + (s - scr.text_h(20)) // 2 + 1, rank, col, 20)


# ----------------------------------------------------------- screen: TRACE --
TRACE_SPANS = ((3600, "1H"), (3 * 3600, "3H"), (12 * 3600, "12H"),
               (86400, "24H"), (3 * 86400, "3D"), (7 * 86400, "7D"))
TRACE_COLS = 145  # buckets across the plot; keeps the per-frame rect count sane


def draw_trace(scr, app, t):
    span, label = TRACE_SPANS[app.trace_zoom]
    px, py, pw, ph = MARGIN, BODY_Y, W - 2 * MARGIN, BODY_B - BODY_Y
    plate(scr, px, py, pw, ph, "TELEMETRY / %s" % label)

    # legend
    lx = px + 12
    for name, c in (("5H LOAD", ACID), ("SEASON", CYAN), ("CORE", BONE_D)):
        scr.rect(lx, py + 20, 10, 10, c)
        lx = scr.text(lx + 14, py + 19, name, BONE_D, 10, track=1) + 16
    scr.rtext(px + pw - 12, py + 18, "L2/R2 ZOOM", BONE_D, 10, track=1)

    gx, gy = px + 34, py + 42
    gw, gh = pw - 46, ph - 76
    scr.rect(gx, gy, gw, gh, (14, 17, 13))
    scr.frame(gx, gy, gw, gh, RULE, 1)
    # the telemetry sea: dim-palette filament wave rolling under the data
    # (in-place undulation only - nothing drifts horizontally)
    sea = ART.get("trace_wave")
    if sea:
        sf = sea[int(t * 6) % len(sea)]
        scr.blit(gx + (gw - sf[0]) // 2, gy + gh - sf[1] - 1, sf)

    def ypos(v):
        return gy + gh - 2 - int(max(0, min(100, v)) * (gh - 4) / 100.0)

    for pct in (25, 50, 75, 95):
        yy = ypos(pct)
        dotted(scr, gx + 1, yy, gw - 2,
               ALERT_D if pct == 95 else (34, 40, 32), 6)
        scr.rtext(gx - 4, yy - 5, "%d" % pct,
                  ALERT_D if pct == 95 else BONE_D, 10)

    t0 = t - span
    pts = [p for p in app.pts if p[0] >= t0]
    if len(pts) < 2:
        scr.ctext(gx + gw // 2, gy + gh // 2 - 8, "COLLECTING TELEMETRY",
                  BONE_D, 20, track=2)
        scr.ctext(gx + gw // 2, gy + gh // 2 + 16,
                  "%d SAMPLES IN THE LOG" % len(app.pts), BONE_D, 10, track=1)
        return

    # bucket into fixed columns: the log can hold thousands of samples and the
    # plot is only ~580px wide
    cw = max(2, gw // TRACE_COLS)
    ncol = gw // cw
    cols = [None] * ncol
    for p in pts:
        i = int((p[0] - t0) / float(span) * ncol)
        i = max(0, min(ncol - 1, i))
        cur = cols[i]
        if cur is None or p[1] > cur[1]:
            cols[i] = p

    # window boundaries, drawn under the traces
    for win in segment(pts):
        i = int((win[0][0] - t0) / float(span) * ncol)
        if 0 < i < ncol:
            scr.rect(gx + i * cw, gy + 1, 1, gh - 2, (52, 62, 46))

    last = None
    for i, p in enumerate(cols):
        if p is None:
            continue
        cx = gx + i * cw
        # 5H as a filled seismic column
        yy = ypos(p[1])
        burned = p[1] >= BLACKOUT_AT or p[4]
        scr.rect(cx, yy, cw - 1, gy + gh - 1 - yy,
                 ALERT_D if burned else ACID_XD)
        scr.rect(cx, yy, cw - 1, 2, ALERT if burned else ACID)
        # season + core as thin steps
        scr.rect(cx, ypos(p[2]), cw - 1, 2, CYAN_D)
        scr.rect(cx, ypos(p[3]), cw - 1, 1, BONE_D)
        last = p

    if last:
        scr.rect(gx, ypos(last[1]), gw, 1, ACID_D)
    scr.text(gx, gy + gh + 6, fmt_clock(t0), BONE_D, 10, track=1)
    scr.rtext(gx + gw, gy + gh + 6, "NOW", BONE_D, 10, track=1)
    scr.ctext(gx + gw // 2, gy + gh + 6, "%d SAMPLES / %d WINDOWS"
              % (len(pts), len(segment(pts))), BONE_D, 10, track=1)


# ------------------------------------------------------------- screen: LOG --
def draw_log(scr, app, t):
    px, py, pw, ph = MARGIN, BODY_Y, W - 2 * MARGIN, BODY_B - BODY_Y
    plate(scr, px, py, pw, ph, "DEBRIEF / CLOSED WINDOWS")
    streak = streak_of(app.runs)
    total = sum(r["banked"] for r in app.runs)
    scr.text(px + 12, py + 18, "STREAK %02d" % streak,
             ACID if streak else BONE_D, 20, track=1)
    scr.ctext(px + pw // 2, py + 18, "LIFETIME %s CR" % commas(total), BONE, 20,
              track=1)
    scr.rtext(px + pw - 12, py + 18, "%d RUNS" % len(app.runs), BONE_D, 20,
              track=1)
    dotted(scr, px + 12, py + 44, pw - 24, RULE)

    # 6 detailed rows, then the specimen tray gets the rest - the list used to
    # run to 11 and leave the bottom third of the panel empty. 6 and not 7:
    # the 7th row's box overlaps the tray's caption.
    tray_h = 118
    tray_y = py + ph - tray_h - 10
    rows = list(reversed(app.runs))[:6]
    if not rows:
        scr.ctext(px + pw // 2, py + 120, "NO CLOSED WINDOWS YET", BONE_D, 32,
                  track=2)
        scr.ctext(px + pw // 2, py + 160,
                  "A RUN RESOLVES WHEN THE 5H WINDOW RESETS", BONE_D, 14,
                  track=1)
        specimen_tray(scr, app, px + 8, tray_y, pw - 16, tray_h, t)
        return
    ry = py + 52
    # SPAN, not HELD: this is how long the window ran, not time spent in band
    scr.text(px + 46, ry, "WINDOW", BONE_D, LABEL_PX, track=2)
    scr.text(px + 150, ry, "PEAK", BONE_D, LABEL_PX, track=2)
    scr.text(px + 220, ry, "SPAN", BONE_D, LABEL_PX, track=2)
    scr.text(px + 300, ry, "BANKED", BONE_D, LABEL_PX, track=2)
    scr.text(px + 400, ry, "PROFILE", BONE_D, LABEL_PX, track=2)
    ry += 18
    for i, r in enumerate(rows):
        n = len(app.runs) - i
        y = ry + i * 30
        if i % 2 == 0:
            scr.rect(px + 6, y - 2, pw - 12, 28, (18, 22, 18))
        rank_stamp(scr, px + 10, y, 26, r["rank"], filled=r["rank"] in "SA")
        scr.text(px + 46, y + 4, "%03d" % n, BONE, 20, mono=True)
        scr.text(px + 150, y + 4, "%d%%" % r["peak"], pct_col(r["peak"]), 20,
                 mono=True)
        scr.text(px + 220, y + 6, fmt_dur(r["t1"] - r["t0"]), BONE_D, 14,
                 track=1)
        scr.text(px + 300, y + 4, commas(r["banked"]),
                 ALERT if r["blackout"] else ACID, 20, mono=True)
        bar(scr, px + 400, y + 8, pw - 412, 10, r["peak"],
            ALERT if r["blackout"] else ACID_D, seg=4, gap=2, zones=LOAD_ZONES,
            marker=BLACKOUT_AT)
    scr.text(px + 12, tray_y - 15, "SPECIMEN TRAY / ALL WINDOWS", BONE_D,
             MICRO_PX, track=2)
    specimen_tray(scr, app, px + 8, tray_y, pw - 16, tray_h, t)
    # the prize specimen: the biomata grub writhing at the tray's right end
    grub = ART.get("log_grub_bone") or ART.get("log_grub")
    if grub:
        gf = grub[int(t * 8) % len(grub)]
        gxx = px + pw - 24 - gf[0]
        scr.blit(gxx, tray_y + (tray_h - gf[1]) // 2, gf)
        scr.text(gxx + 2, tray_y + tray_h - 14, "SPECIMEN 0X0", BONE_D,
                 MICRO_PX, track=1)


# ----------------------------------------------------------- screen: TASKS --
def draw_tasks(scr, app, t):
    px, py, pw, ph = MARGIN, BODY_Y, W - 2 * MARGIN, BODY_B - BODY_Y
    plate(scr, px, py, pw, ph, "CONTRACTS")
    d = app.data or {}
    cs = contracts_of(app.runs, app.live, app.pts, app.season(),
                      parse_reset(d.get("seven_day_reset"), t), t)
    scr.text(px + 12, py + 18,
             "DERIVED FROM THE LAST 24 HOURS - NOTHING IS STORED", BONE_D, 10,
             track=1)
    done = sum(1 for c in cs if c[3])
    scr.rtext(px + pw - 12, py + 16, "%d/%d" % (done, len(cs)),
              ACID if done == len(cs) else BONE, 20, mono=True)
    for i, (label, detail, prog, ok) in enumerate(cs):
        y = py + 44 + i * 88
        scr.rect(px + 8, y, pw - 16, 78, (18, 22, 18))
        scr.frame(px + 8, y, pw - 16, 78, ACID_XD if ok else RULE, 1)
        scr.rect(px + 8, y, 4, 78, ACID if ok else RULE_HI)
        scr.text(px + 22, y + 10, label, ACID if ok else BONE, 20, track=1)
        scr.text(px + 22, y + 36, detail, BONE_D, 14, track=1)
        sx = px + pw - 24 - (ART.get("tasks_helm") and 104 or 0)
        if ok:
            scr.rtext(sx, y + 10, "COMPLETE", ACID, 20, track=1)
        else:
            scr.rtext(sx, y + 10, "%d%%" % int(prog * 100), BONE_D,
                      20, mono=True)
        # the field agent: helmet-turn stamp, each card a step out of phase.
        # It owns the card's right edge; the bar and status text stop short.
        helm = ART.get("tasks_helm")
        hw = helm[0][0] + 16 if helm else 0
        if helm:
            hf = helm[(int(t * 8) + i * 3) % len(helm)]
            scr.blit(px + pw - 12 - hf[0], y + (78 - hf[1]) // 2, hf)
        bar(scr, px + 22, y + 58, pw - 60 - hw, 10, prog * 100,
            ACID if ok else ACID_D, seg=6, gap=3)


# ------------------------------------------------------------ screen: LINK --
def draw_link(scr, app, t):
    px, py, pw, ph = MARGIN, BODY_Y, W - 2 * MARGIN, BODY_B - BODY_Y
    plate(scr, px, py, pw, ph, "UPLINK / INTEL")
    d = app.data or {}
    age = app.age(t)
    if age > 1e8:
        link, lcol = "NO SIGNAL", ALERT
    elif age > 300:
        link, lcol = "STALE", (255, 176, 40)
    else:
        link, lcol = "NOMINAL", ACID
    scr.text(px + 16, py + 22, "LINK", BONE_D, MICRO_PX, track=2)
    scr.text(px + 16, py + 34, link, lcol, 32, track=1)
    scr.rtext(px + pw - 16, py + 36, "LAST PACKET %s"
              % (fmt_dur(age) + " AGO" if age < 1e8 else "NEVER"), BONE_D, 14,
              track=1)
    ry = py + 76
    if d.get("rl"):
        hazard(scr, px + 12, py + 76, pw - 24, 18, t)
        scr.ctext(px + pw // 2, py + 100, "ANTHROPIC RATE LIMIT ACTIVE", ALERT,
                  20, track=1)
        ry = py + 130
    glyph_row(scr, px + 16, ry, 12, len(app.pts), ACID_XD, 8, 24)
    dotted(scr, px + 16, ry + 22, pw - 32, RULE, 6)
    ry += 34

    rows = [
        ("HOST", host_label()),
        ("UPDATED", str(d.get("updated", "-"))),
        ("5H RESET", str(d.get("five_hour_reset", "-"))),
        ("7D RESET", str(d.get("seven_day_reset", "-"))),
        ("NOTE", str(d.get("note", "-"))),
        ("SAMPLES", "%d IN LOG / %d WINDOWS" % (len(app.pts),
                                                len(app.runs) + 1)),
    ]
    for i, (k, v) in enumerate(rows):
        y = ry + i * 32
        scr.text(px + 16, y, k, BONE_D, LABEL_PX, track=1)
        scr.text(px + 150, y, v[:42], BONE, 14, track=1)
        dotted(scr, px + 16, y + 22, pw - 32, (28, 34, 26), 6)

    # the calibration specimen: the astronaut figure, T-posed like a technical
    # manual figure, with annotated callouts - the board's aerial-pin motif
    spec = ART.get("specimen") or ART.get("specimen_bone")
    if spec:
        dxx, dyy = px + 500, py + 116
        scr.blit(dxx, dyy, spec[int(t * 8) % len(spec)])
        callout(scr, dxx + 45, dyy + 22, dxx + 98, dyy + 6, "HELM", RULE_HI)
        callout(scr, dxx + 45, dyy + 62, dxx + 98, dyy + 84, "CORE", RULE_HI)
        scr.text(dxx, dyy + spec[0][1] + 8, "SPECIMEN 133", BONE_D, 10,
                 track=1)
        scr.text(dxx, dyy + spec[0][1] + 20, "CALIBRATION POSE", BONE_D, 10,
                 track=1)

    sess = (d.get("sessions") or "")
    if isinstance(sess, str):
        sess = [s for s in sess.split(",") if s]
    y = ry + 6 * 32 + 4
    scr.text(px + 16, y + 4, "SESSIONS", BONE_D, LABEL_PX, track=1)
    if sess:
        for i, s in enumerate(sess[:3]):
            bxx = px + 150 + i * 152
            scr.rect(bxx, y, 142, 26, GRAPHITE_2)
            scr.frame(bxx, y, 142, 26, ACID_D, 1)
            scr.rect(bxx, y, 3, 26, ACID)
            scr.text(bxx + 10, y + 4, s[:14], ACID, 14, track=1)
    else:
        scr.text(px + 150, y + 4, "NONE ACTIVE", BONE_D, 14, track=1)


SCREENS = (draw_run, draw_trace, draw_log, draw_tasks, draw_link)


# ---------------------------------------------------------------- effects ---
ALARM_AT = 90


def draw_alarm(scr, app, t):
    """Edge hazard crawl once the window is nearly spent, plus a banner when
    Anthropic is actively rate-limiting.

    It runs on every tab on purpose: the whole point of the game is that you
    cannot be looking at the wrong screen and miss this."""
    load = app.load()
    rl = bool((app.data or {}).get("rl"))
    if load < ALARM_AT and not rl:
        return
    col = ALERT if (load >= BLACKOUT_AT or rl) else (255, 176, 40)
    hazard(scr, 0, 0, 4, H, t * 1.4, col, VOID, 10)
    hazard(scr, W - 4, 0, 4, H, -t * 1.4, col, VOID, 10)
    if rl:
        bw, bh = 300, 22
        bx, by = (W - bw) // 2, FOOT_Y - bh - 2
        scr.rect(bx, by, bw, bh, VOID)
        scr.frame(bx, by, bw, bh, col, 1)
        if int(t * 2) % 2:
            scr.ctext(W // 2, by + 4, "RATE LIMITED - SIGNAL DEGRADED", col,
                      14, track=1)


_sfx_at = {}


def sfx(name, cooldown=3.0):
    """Fire an interface stinger. Detached so a dead audio stack can never
    stall the frame loop, and rate-limited per sound so a state that flickers
    across a threshold cannot machine-gun it."""
    if SIM:
        return
    now = time.time()
    if now - _sfx_at.get(name, 0.0) < cooldown:
        return
    _sfx_at[name] = now
    path = os.path.join(ART_DIR, "sfx_%s.wav" % name)
    if not os.path.exists(path):
        return
    os.system("setsid nohup mpv --no-video --really-quiet --volume=70 '%s' "
              ">/dev/null 2>&1 &" % path)


def check_alarms(app, t):
    """Edge-triggered audio: sounds mark transitions, not conditions, so they
    fire once when things change instead of every frame they stay changed."""
    load = app.load()
    rl = bool((app.data or {}).get("rl"))
    state = "blackout" if (load >= BLACKOUT_AT or rl) else (
        "alarm" if load >= ALARM_AT else "clear")
    if state != app.alarm_state:
        if state == "blackout":
            sfx("blackout", 30.0)
            # the burn: the extraction burst in alert red, played once as
            # the window blacks out
            app.burn_until = t + 1.1
        elif state == "alarm":
            sfx("alarm", 30.0)
        app.alarm_state = state


def glitch(scr, amount, seed):
    """Horizontal band displacement. Cheap because each band moves as a whole
    row slice, not pixel by pixel."""
    rnd = random.Random(seed)
    st = scr.stride
    buf = scr.buf
    for _ in range(int(4 + amount * 12)):
        y0 = rnd.randrange(0, H - 10)
        hh = rnd.randrange(3, 16)
        dx = rnd.randrange(-30, 31)
        if dx == 0:
            continue
        n = abs(dx) * 4
        for yy in range(y0, min(H, y0 + hh)):
            off = yy * st
            row = bytes(buf[off:off + W * 4])
            if dx > 0:
                buf[off:off + W * 4] = bytes(n) + row[:-n]
            else:
                buf[off:off + W * 4] = row[n:] + bytes(n)
        if rnd.random() < 0.3:
            scr.rect(0, y0, W, 1, ACID_XD)


def veil_art(scope):
    """The fibre-face backdrop. 'boot' takes only the half-screen bake (the
    poster layout is sized for it); 'attract' prefers the full-screen bake
    and can fall back to the boot one."""
    if scope == "attract":
        return ART.get("veil_full") or ART.get("veil")
    return ART.get("veil")


def draw_boot(scr, el):
    """The terminal wake-up from the reference posters. ~2.2s, skippable."""
    scr.clear()
    # the fibre-face backdrop anchors the right half; everything else layers
    # over it, poster-style. Hard cut in (no fades on this panel).
    veil = veil_art("boot")
    if veil and el > 0.30:
        vf = veil[int(el * 6) % len(veil)]
        scr.blit(W - vf[0] - 6, 130, vf)
    lines = [
        (0.00, "INIT", 56, ACID),
        (0.45, "CORE REVIEW [START]", 20, BONE_D),
        (0.65, "CORE 1 ................ OK", 14, BONE_D),
        (0.78, "CORE 2 ................ OK", 14, BONE_D),
        (0.91, "CORE 3 ................ OK", 14, BONE_D),
        (1.04, "CORE 4 ................ OK", 14, BONE_D),
        (1.20, "CORES STABLE", 20, BONE),
        (1.40, "USAGE UPLINK .......... BIND", 14, BONE_D),
        (1.55, "SALVAGE MODEL ......... LOAD", 14, BONE_D),
        (1.75, "RESULTS [PRNTD]", 20, ACID),
    ]
    y = 60
    for at, s, px, col in lines:
        if el < at:
            break
        # type-on: reveal a character at a time
        n = min(len(s), int((el - at) / 0.014))
        scr.text(60, y, s[:n], col, px, track=2 if px >= 20 else 1)
        if n < len(s) and int(el * 20) % 2:
            scr.rect(60 + scr.text_w(s[:n], px, track=2 if px >= 20 else 1),
                     y + 2, px // 2, px - 2, col)
        y += scr.text_h(px) + (10 if px >= 20 else 2)
    # the bioluminescent bloom: a very slow luminance ramp with nothing else
    # moving. Three baked exposure steps stand in for the ramp; the
    # reflection is part of the render. It is baked OPAQUE on its own dark
    # ground, so it only draws when there is no veil backdrop - layered over
    # the fibre face its rectangle reads as a pasted photo.
    bloom = ART.get("bloom")
    if bloom and not veil and el > 0.2:
        step = 0 if el < 1.0 else (1 if el < 1.7 else 2)
        art = bloom[min(step, len(bloom) - 1)]
        scr.blit(400, 110, art)
    if el > 1.55:
        art = ART.get("sigil")
        if art:
            sf = art[int(el * 6) % len(art)]
            scr.blit((W - sf[0]) // 2, 330, sf)
    if el > 1.95:
        invert_plate(scr, 60, 400, 300, 44, "RUNNER PROTOCOL", 32, ACID)
        scr.text(374, 412, "SOMEWHERE IN THE HEAVENS", ACID_D, 14, track=2)
    glyph_row(scr, W - 200, 60, 14, 3, ACID_XD, 6, 26)


def draw_attract(scr, app, t):
    """Idle attract mode: the fibre-face full screen, shimmering like a live
    feed, grubs breathing in place, annotation tags pinned to it. Any button
    wakes the deck. Nothing here is data - this is the poster on the wall."""
    frames = veil_art("attract")
    if frames:
        # same rule as hero_art: short sets are shimmer, long sets are real
        # animation; full-screen loops run at 5fps (12-frame RAM cap)
        rate = 6 if len(frames) <= 4 else 5
        art = frames[int(t * rate) % len(frames)]
        scr.blit((W - art[0]) // 2, max(36, (H - art[1]) // 2 - 8), art)
    # two specimens resting on the art, undulating in place (position fixed:
    # horizontal drift reads as tearing on this panel)
    wb, wh = worm_tones(BONE_D)
    worm(scr, 120, 96, 96, 12, t * 0.22, wb, wh, amp=1.6)
    ab, ah = worm_tones(ACID)
    worm(scr, 420, 356, 96, 12, t * 0.15 + 0.4, ab, ah, amp=1.3)
    callout(scr, 214, 104, 268, 82, "133007", RULE_HI)
    callout(scr, 424, 360, 352, 388, "SEC-7", RULE_HI)
    scr.vtext(W - 18, H - 60, "SOMEWHERE IN THE HEAVENS", ACID_XD, 10,
              track=2)
    scr.text(12, H - 24, "RUNNER PROTOCOL", BONE_D, 10, track=2)
    scr.rtext(W - 12, H - 24, "ANY BUTTON", BONE_D, 10, track=2)


ATTRACT_AFTER_S = 120.0


def draw_debug(scr, app, t):
    scr.rect(W - 190, HEAD_Y + HEAD_H + 4, 182, 60, VOID)
    scr.frame(W - 190, HEAD_Y + HEAD_H + 4, 182, 60, ACID, 1)
    scr.text(W - 184, HEAD_Y + HEAD_H + 8, "FRAME %.1f MS" % app.frame_ms,
             ACID, 14, track=1)
    scr.text(W - 184, HEAD_Y + HEAD_H + 24, "PTS %d  WIN %d"
             % (len(app.pts), len(app.runs) + 1), BONE_D, 14, track=1)
    scr.text(W - 184, HEAD_Y + HEAD_H + 40, "AGE %s" % fmt_dur(app.age(t)),
             BONE_D, 14, track=1)


# ------------------------------------------------------------------ input ---
# GO-Super Gamepad (this clone): SELECT=704, START=705; the standard codes are
# kept as fallbacks for other devices.
SELECT_CODES = {704, 314}
START_CODES = {705, 315}
BTN_A, BTN_B, BTN_Y, BTN_X = 304, 305, 307, 308
BTN_L1, BTN_R1, BTN_L2, BTN_R2 = 310, 311, 312, 313
DPAD_L, DPAD_R = 546, 547


def ensure_receiver():
    """Revive the push-receiver if it died (ES kills it on tool exit)."""
    if SIM:
        return
    for pid in os.listdir("/proc"):
        if pid.isdigit():
            try:
                with open("/proc/%s/cmdline" % pid, "rb") as f:
                    if b"receiver.py" in f.read():
                        return
            except OSError:
                pass
    rcv = os.path.join(os.path.dirname(os.path.abspath(__file__)), "receiver.py")
    with open("/tmp/recv.log", "ab") as log:
        subprocess.Popen(["python3", rcv], stdout=log, stderr=log,
                         start_new_session=True)


def kill_siblings():
    """Kill any other instance of THIS script (ES can relaunch without the
    previous one exiting). Matches the full path, not the bare filename, so an
    unrelated runner.py elsewhere is left alone."""
    if SIM:
        return
    me = os.getpid()
    my_path = os.path.abspath(__file__).encode()
    for pid in os.listdir("/proc"):
        if not pid.isdigit() or int(pid) == me:
            continue
        try:
            with open("/proc/%s/cmdline" % pid, "rb") as f:
                if my_path in f.read():
                    os.kill(int(pid), 9)
        except (OSError, ValueError, ProcessLookupError):
            pass


def open_inputs():
    """Open every /dev/input/event* non-blocking; missing ones are skipped."""
    evs = []
    if SIM:
        return evs
    for n in sorted(os.listdir("/dev/input")):
        if n.startswith("event"):
            try:
                f = open("/dev/input/" + n, "rb", buffering=0)
                os.set_blocking(f.fileno(), False)
                evs.append(f)
            except OSError:
                pass
    return evs


def start_drill(app, t):
    app.demo = True
    app.demo_t0 = t
    app.demo_pts = None
    app.run = Run()
    app.next_model = 0.0
    app.alarm_state = None
    app.poll(t, force=True)
    app.wipe_until = t + 0.16
    app.say("PROTOCOL DRILL ENGAGED - ALL TELEMETRY SYNTHETIC", 4.0)


def stop_drill(app, t):
    app.demo = False
    app.demo_pts = None
    app.data = None
    app.data_mtime = 0.0
    app.run = Run()
    app.next_model = 0.0
    app.alarm_state = None
    app.poll(t, force=True)
    app.wipe_until = t + 0.16
    app.say("DRILL TERMINATED - AWAITING LIVE UPLINK", 4.0)


def on_button(app, code, t):
    app.last_input = t
    if app.attract:
        # the waking press only wakes; it never acts
        app.attract = False
        app.wipe_until = t + 0.16
        return
    if code == BTN_L1:
        app.tab = (app.tab - 1) % len(TABS)
        app.wipe_until = t + 0.16
    elif code == BTN_R1:
        app.tab = (app.tab + 1) % len(TABS)
        app.wipe_until = t + 0.16
    elif code == DPAD_L:
        app.tab = (app.tab - 1) % len(TABS)
        app.wipe_until = t + 0.16
    elif code == DPAD_R:
        app.tab = (app.tab + 1) % len(TABS)
        app.wipe_until = t + 0.16
    elif code == BTN_B:
        if app.tab != 0:
            app.tab = 0
            app.wipe_until = t + 0.16
    elif code in (BTN_L2, BTN_R2) and app.tab == 1:
        step = -1 if code == BTN_L2 else 1
        app.trace_zoom = max(0, min(len(TRACE_SPANS) - 1,
                                    app.trace_zoom + step))
    elif code == BTN_A:
        do_extract(app, t)
    elif code == BTN_Y:
        # the drill is only offered from the NO SIGNAL screen; once running,
        # the same button ends it from anywhere
        if app.demo:
            stop_drill(app, t)
        elif app.data is None and not app.pts:
            start_drill(app, t)


def do_extract(app, t):
    if not app.live or not app.live_win:
        app.say("NOTHING TO EXTRACT - NO TELEMETRY YET")
        return
    load = app.load()
    if app.run.extracted:
        app.say("ALREADY EXTRACTED THIS WINDOW")
        return
    if app.state() == "BLACKOUT":
        app.say("BLACKOUT - THE PACK IS GONE")
        return
    rank = app.run.extract(app.live, load, t)
    app.stamp_rank = rank
    app.stamp_until = t + 1.4
    app.wipe_until = t + 0.12
    sfx("extract", 0.5)
    app.say("EXTRACTED AT %d%% - RANK %s - %s CR BANKED"
            % (load, rank, commas(app.run.banked)), 4.0)


def draw_stamp(scr, app, t):
    """The rank slamming down on a successful extraction."""
    left = app.stamp_until - t
    k = max(0.0, min(1.0, 1.0 - left / 1.4))
    # slams down fast then holds; the settled size has to clear the 56px rank
    # glyph and its caption without the two colliding
    s = max(164, int(300 - 200 * min(1.0, k * 3.0)))
    x, y = (W - s) // 2, (H - s) // 2
    col = RANK_COL.get(app.stamp_rank, ACID)
    # the payoff burst: a one-shot baked light explosion under the stamp,
    # played front-to-back across the slam
    fx = ART.get("extract_fx")
    if fx:
        bf = fx[min(len(fx) - 1, int(k * len(fx)))]
        scr.blit((W - bf[0]) // 2, (H - bf[1]) // 2, bf)
    scr.rect(x, y, s, s, VOID)
    scr.frame(x, y, s, s, col, 3)
    for i in range(10):  # corner ticks, same language as the panels
        scr.rect(x + 6 + i, y + 6, 1, 1, col)
        scr.rect(x + s - 7 - i, y + s - 7, 1, 1, col)
    scr.ctext(W // 2, y + (s - scr.text_h(56)) // 2 - 12, app.stamp_rank, col,
              56, track=2)
    scr.ctext(W // 2, y + s - 30, "EXTRACTED", BONE, 14, track=2)
    if k < 0.35:
        glitch(scr, 1.0 - k, int(t * 60))


def main():
    """Entry point: claim the framebuffer, load assets, run the loop, and in
    SIM mode write the captured frames out as a GIF on exit."""
    kill_siblings()
    time.sleep(0.2)
    global ART
    ART = load_art()
    scr = Screen()
    if DEBUG:
        print("fb pages: %d  font: %s  art: %s"
              % (scr.pages, "maratype" if scr.font else "5x7 fallback",
                 ",".join(sorted(ART)) or "none"), flush=True)
    app = App()
    evs = open_inputs()
    held = set()
    if SIM:
        tab = os.environ.get("WIDGET_SIM_TAB", "").upper()
        app.tab = TABS.index(tab) if tab in TABS else 0
    try:
        run(scr, app, evs, held)
    finally:
        scr.reset_pan()
    if SIM and scr.frames:
        from PIL import Image
        imgs = [Image.frombytes("RGBA", (W, H), fr, "raw", "BGRA").convert("RGB")
                for fr in scr.frames]
        out = os.environ.get("WIDGET_SIM_OUT", "runner_sim.gif")
        imgs[0].save(out, save_all=True, append_images=imgs[1:],
                     duration=50, loop=0)
        print("sim gif: %s (%d frames)" % (out, len(imgs)))


def run(scr, app, evs, held):
    """The 20fps main loop: poll data, draw the active tab (or boot/attract),
    pump input. Returns when SELECT+START is held or SIM frames run out."""
    # the type-on finishes by ~2.2s; the rest is the finished poster holding
    # (any button still skips)
    boot_s = 0.0 if (SIM and os.environ.get("WIDGET_SIM_BOOT") == "0") else 5.5
    sim_left = int(os.environ.get("WIDGET_SIM_FRAMES", "80")) if SIM else -1
    recv_check = 0.0
    app.poll(time.time(), force=True)
    sim_state = os.environ.get("WIDGET_SIM_STATE", "") if SIM else ""
    if sim_state == "extracted":
        do_extract(app, time.time())
        app.stamp_until = 0.0     # show the settled panel, not the stamp
        app.msg = None
    frame = 0
    while True:
        if SIM:
            if sim_left <= 0:
                return
            sim_left -= 1
            frame += 1
            # 'extracting' presses A a few frames in, so the preview captures
            # the stamp animation rather than only its aftermath
            if sim_state == "extracting" and frame == 6:
                do_extract(app, time.time())
        t = time.time()
        el = t - app.boot_at
        if el < boot_s:
            draw_boot(scr, el)
            scr.flush()
            _pump(evs, held, app, t, boot_only=True)
            if app.boot_at == 0:      # skipped
                boot_s = 0.0
            _cap(t)
            continue

        if not app.demo and t - recv_check > 60:
            ensure_receiver()
            recv_check = t
        app.poll(t)
        check_alarms(app, t)

        # idle -> attract poster; alarms always break out of it
        alarmed = app.load() >= ALARM_AT or bool((app.data or {}).get("rl"))
        if app.attract and alarmed:
            app.attract = False
        elif (not app.attract and not alarmed and (app.data or app.pts)
              and t - app.last_input > ATTRACT_AFTER_S):
            app.attract = True
            app.wipe_until = t + 0.16

        scr.clear()
        if app.attract:
            draw_attract(scr, app, t)
        else:
            draw_header(scr, app, t)
            if app.data is None and not app.pts:
                draw_wait(scr, t)
            else:
                SCREENS[app.tab](scr, app, t)
            draw_alarm(scr, app, t)
            draw_footer(scr, app, t)
            if held & SELECT_CODES:
                draw_debug(scr, app, t)
            if t < app.stamp_until:
                draw_stamp(scr, app, t)
            if t < app.burn_until:
                # blackout burn: the alert-red burst plus hard glitch, once
                fx = ART.get("extract_fx_alert")
                if fx:
                    k = 1.0 - (app.burn_until - t) / 1.1
                    bf = fx[min(len(fx) - 1, int(k * len(fx)))]
                    scr.blit((W - bf[0]) // 2, (H - bf[1]) // 2, bf)
                glitch(scr, (app.burn_until - t), int(t * 70))
        if t < app.wipe_until:
            glitch(scr, (app.wipe_until - t) * 6, int(t * 90))
        scr.flush()
        app.frame_ms = (time.time() - t) * 1000.0

        if _pump(evs, held, app, t):
            return
        _cap(t)


def _pump(evs, held, app, t, boot_only=False):
    """Drain the evdev queues. Returns True when SELECT+START asks to exit."""
    r = select.select(evs, [], [], 0.01)[0] if evs else []
    for f in r:
        while True:
            try:
                pkt = f.read(24)
            except (OSError, BlockingIOError):
                break
            if not pkt or len(pkt) < 24:
                break
            _s, _us, etype, code, value = struct.unpack("<qqHHi", pkt)
            if etype != 1:
                continue
            if value == 1:
                held.add(code)
                if boot_only:
                    app.boot_at = 0   # any button skips the boot sequence
                else:
                    on_button(app, code, t)
            elif value == 0:
                held.discard(code)
            if held & SELECT_CODES and held & START_CODES:
                return True
    return False


def _cap(t):
    """Sleep out the remainder of the 20fps frame budget."""
    dt = time.time() - t
    if dt < 1 / 20.0:
        time.sleep(1 / 20.0 - dt)


if __name__ == "__main__":
    main()
