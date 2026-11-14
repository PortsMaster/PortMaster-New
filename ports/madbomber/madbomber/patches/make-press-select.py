#!/usr/bin/env python3
# Renders data/images/game/press-select.png ("Press SELECT") in the style of
# upstream press-escape.png: blue metallic bands on black, dark blue glow.
# Usage: make-press-select.py <press-escape.png> <out.png>
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

FONT = "/usr/share/fonts/opentype/urw-base35/NimbusSans-BoldItalic.otf"
src = Image.open(sys.argv[1]).convert("RGB")
H = src.height

# Per-row letter color: mean of the upstream image's lit pixels in that row.
bands = []
for y in range(H):
    lit = [src.getpixel((x, y)) for x in range(src.width) if src.getpixel((x, y))[0] > 60]
    bands.append(tuple(sum(c[i] for c in lit) // len(lit) for i in range(3)) if lit else (20, 20, 120))

# Caps fill rows 3-20 like the upstream lettering.
font = ImageFont.truetype(FONT, 25)
text = "Press SELECT"
l, t, r, b = font.getbbox(text)
cap_top = font.getbbox("P")[1]
W = (r - l) + 8
mask = Image.new("L", (W, H), 0)
ImageDraw.Draw(mask).text((4 - l, 3 - cap_top), text, font=font, fill=255)

glow = mask.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(2))
out = Image.new("RGB", (W, H), (0, 0, 0))
px = out.load()
m = mask.load()
g = glow.load()
for y in range(H):
    fr, fg, fb = bands[y]
    for x in range(W):
        a = m[x, y] / 255.0
        k = g[x, y] / 255.0
        gr, gg, gb = 10 * k, 10 * k, 110 * k
        c = (gr + (fr - gr) * a, gg + (fg - gg) * a, gb + (fb - gb) * a)
        # pure white is the game's transparent color key
        px[x, y] = tuple(min(250, int(v)) for v in c)
out.save(sys.argv[2])
