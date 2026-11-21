#!/usr/bin/env python3
# Builds controls.png, the gamepad replacement for Graphics.fpg graph 421 ("ControlInfoP").
# Keeps the original companion-orders diagram (top 65 rows) and draws a button legend below it
# with Bennu's own 8x8 system font, the font the game uses for all its dialogue text.
# Usage: make_controls.py Graphics.fpg BennuGD64/modules/libfont/libfont.c controls.png
import re
import struct
import sys

from PIL import Image, ImageDraw

W, H = 270, 190
KEEP_ROWS = 65


def fpg_graph(path, code):
    d = open(path, 'rb').read()
    if d[:3] != b'f16':
        sys.exit('not a 16-bit FPG')
    o = 8
    while o + 64 <= len(d):
        c, _ = struct.unpack_from('<ii', d, o)
        w, h, ncp = struct.unpack_from('<iii', d, o + 52)
        px = o + 64 + ncp * 4
        if c == code:
            im = Image.new('RGB', (w, h))
            for y in range(h):
                for x in range(w):
                    v = struct.unpack_from('<H', d, px + (y * w + x) * 2)[0]
                    im.putpixel((x, y), (((v >> 11) & 31) * 255 // 31,
                                         ((v >> 5) & 63) * 255 // 63,
                                         (v & 31) * 255 // 31))
            return im
        o = px + w * h * 2
    sys.exit('graph %d not found' % code)


def sysfont(path):
    src = open(path).read()
    body = src[src.index('default_font[256*8]'):]
    body = body[body.index('{') + 1:body.index('};')]
    data = [int(v, 0) for v in re.findall(r'0x[0-9A-Fa-f]+|\b\d+\b', body)]
    if len(data) != 256 * 8:
        sys.exit('unexpected font size %d' % len(data))
    return data


def text(img, font, x, y, s, col):
    for i, ch in enumerate(s):
        g = font[ord(ch) * 8:ord(ch) * 8 + 8]
        for row in range(8):
            for bit in range(8):
                if g[row] & (0x80 >> bit):
                    img.putpixel((x + i * 8 + bit, y + row), col)


ROWS = [
    ('A', 'SELECT - TALK', (172, 234, 123)),
    ('B', 'USE POWER', (180, 80, 156)),
    ('L1', 'POWER SELECTION', (238, 76, 172)),
    ('Y', 'USE ITEM', (180, 44, 90)),
    ('X', 'ITEM SELECTION', (123, 210, 123)),
    ('R1', 'COMPANION ORDERS', (205, 149, 115)),
    ('SELECT', 'LOG', (238, 76, 172)),
    ('START', 'OPTIONS', (123, 121, 238)),
    ('L2/R2', 'VOLUME', (200, 200, 200)),
]


def main():
    fpg, fontsrc, out = sys.argv[1:4]
    orig = fpg_graph(fpg, 421)
    font = sysfont(fontsrc)
    img = Image.new('RGB', (W, H), (0, 0, 0))
    img.paste(orig.crop((0, 0, W, KEEP_ROWS)), (0, 0))
    dr = ImageDraw.Draw(img)
    key_w, gap, line = 56, 8, 13
    label_w = max(len(r[1]) for r in ROWS) * 8
    x0 = (W - (key_w + gap + label_w)) // 2
    y0 = KEEP_ROWS + (H - KEEP_ROWS - len(ROWS) * line) // 2
    for i, (btn, label, col) in enumerate(ROWS):
        y = y0 + i * line
        dr.rectangle((x0, y, x0 + key_w - 1, y + 11), fill=(238, 238, 238), outline=(123, 121, 123))
        text(img, font, x0 + (key_w - len(btn) * 8) // 2, y + 2, btn, (16, 16, 16))
        text(img, font, x0 + key_w + gap, y + 2, label, col)
    img.save(out)


main()
