#!/usr/bin/env python3
"""
Unpacks gfx.dat + offsetstex.dat to loose files under an output directory,
mirroring each entry's own recorded relative path (e.g.
data/gfx/generated_tilesets/00.png) so OeResourceManager's recursive
SetupDirectoryScan() picks them up in place of the .dat archives.

Along the way:
  - sheet.png / sheet2.png (the "generated_game" sprite atlases + their
    offset tables) are each replaced with a repacked, half-resolution
    version: every sprite is downsampled 2x linearly (4x fewer pixels) and
    placed into a new canvas. The offset tables (sheet.txt/sheet2.txt) are
    written at ORIGINAL scale and are NOT shrunk - OeSheet.mRectangle keeps
    reporting original coordinates, which lots of game code reads directly
    for its own position/scale math. A small engine patch
    (CecilPatcher2.cs, OeAtlasRectHelper.Halve) converts to the real
    half-scale coordinates only at the moment the GPU sampling rect is
    built.

    Sprites ARE repacked (not left at their original positions) - but only
    because repacking is what guarantees every sprite lands on an even
    (x, y): checked against the real game data, ~40% of sprites sit at an
    odd position in the original atlas, and halving an odd coordinate isn't
    exact - with neighbors packed as tightly as this game's original atlas
    is, that's an actual collision risk (two different sprites landing on
    the same output pixel after halving), not just a rounding nicety. This
    does NOT, however, search for the tightest possible canvas width the
    way an earlier version did - one single width, sized from total sprite
    area with a safety margin, is used directly. The result is a canvas
    that isn't as tightly packed as it could be, in exchange for much
    simpler code; the 2x linear shrink is already most of the RAM win
    either way.
  - Every other entry in gfx.dat AND in every offsets archive given
    (offsetstex.dat = sheet/sheet2 offset tables, offsetstile.dat = the
    generated_tilesets/*.txt tile-grid tables) is written out unchanged
    under its own recorded path. Nothing is dropped: that includes
    generated_tilesets/04_original - Copy.png/.txt, which looks like a
    byte-identical duplicate of 04_original but is presumably still looked
    up by that exact name, so removing it produced visual bugs.
  - Tileset PNGs (generated_tilesets/*.png) are deliberately NOT shrunk: they
    are a separate system from the sheet atlases (index,x,y grid tables, no
    OeSheet involvement) that the DLL's atlas patch never touches, so
    shrinking one without a matching engine change would break it.

Uses Pillow for all PNG decode/encode/resize work (a prebuilt wheel for
this device's exact Python ABI/libc is expected to be dropped in tools/
alongside this script). Decoding is NOT streaming - Pillow loads each full
source image (sheet.png/sheet2.png, up to 8192x8192 RGBA, ~268MB) into
memory at once; there's no simple public streaming-decode API in Pillow to
preserve the old couple-of-scanlines memory profile. Peak RSS here is
correspondingly higher than the old pure-stdlib streaming version - expect
it to roughly track one full original atlas's decoded size at a time, plus
the smaller output canvas and occupancy mask. Still bounded and
predictable, just a different trade than before. Measured on the real
game data: ~395MB peak RSS (vs ~110MB for the streaming version), ~11s.

This does NOT use sfxpack.py's container parser: that parser assumes every
entry has exactly 3 metadata strings (tag1/tag2/name), which only happens
to hold for sfx.dat/music.dat because those assets are always exactly 2
directories deep. gfx.dat entries nest arbitrarily deep
(generated_game/sheet.png, special/needsPO/origpreloaderFinal.png, ...), so
this reads the real format straight from OeDatReader.NextFilePath/
NextStream: an Int32 path-component count, that many BinaryReader-format
(7-bit length-prefixed) strings, then an Int64 payload length.
"""
import argparse
import math
import os
import struct
import sys
from io import BytesIO

from PIL import Image


# --------------------------------------------------------------------------
# .dat container parsing (unrelated to image codec - unchanged).
# --------------------------------------------------------------------------

def read_7bit_int(f):
    result = 0
    shift = 0
    while True:
        b = f.read(1)[0]
        result |= (b & 0x7f) << shift
        if (b & 0x80) == 0:
            break
        shift += 7
    return result


def read_br_string(f):
    length = read_7bit_int(f)
    return f.read(length).decode('utf-8', errors='replace')


def iter_dat_entries(path):
    """Streams one entry at a time (path parts + payload), matching
    OeDatReader's own read order. Mirrors iter_container_entries' one-entry-
    at-a-time approach in sfxpack.py to avoid holding the whole archive (and
    a second full copy across every entry's payload) in memory at once."""
    with open(path, 'rb') as f:
        zero = struct.unpack('<I', f.read(4))[0]
        count = struct.unpack('<I', f.read(4))[0]
        for _ in range(count):
            n = struct.unpack('<i', f.read(4))[0]
            parts = [read_br_string(f) for _ in range(n)]
            length = struct.unpack('<q', f.read(8))[0]
            payload = f.read(length)
            yield parts, payload


def parse_offset_txt(text):
    rects = {}
    order = []
    for line in text.splitlines():
        line = line.strip()
        if not line or '=' not in line:
            continue
        key, val = line.split('=', 1)
        key = key.strip()
        vparts = val.strip().split(' ')
        if len(vparts) != 4:
            continue
        x, y, w, h = map(int, vparts)
        rects[key] = (x, y, w, h)
        order.append(key)
    return rects, order


def shelf_pack_rects(rects_dict, width, padding=4):
    """Places each rect at an EVEN (x, y) position, and advances shelf
    cursors/heights by even amounts too (padding itself is rounded up to
    keep this true regardless of each rect's own width/height parity).

    padding=4 (not 2) because this atlas gets halved afterward: a full-scale
    gap of N pixels between two sprites becomes only N/2 pixels in the
    shrunk canvas, and extrude_sprite_borders wants a real 2px gap there
    for a margin=1 extrusion on each side to never reach a neighbor's own
    pixels - checked against real game data, padding=2 here shows up as
    only ~1px after halving, one pixel short of what that needs.

    This one property (even placement) is what lets a sprite's position in
    the shrunk atlas be found by simply dividing its ORIGINAL (unshrunk)
    packed position by 2, both here and in OeAtlasRectHelper.Halve: an odd
    placement could put half a downsampled pixel over the line into a
    neighboring sprite. Reported (w, h) in the result are the caller's
    real, unrounded values - only placement/cursor math rounds up to even.
    """
    width += width % 2
    items = sorted(rects_dict.items(), key=lambda kv: -kv[1][3])  # height desc
    shelves = []  # [y, shelf_h, x_cursor]
    result = {}
    height = 0
    for name, (x, y, w, h) in items:
        pw, ph = w + padding + (w % 2), h + padding + (h % 2)
        placed = False
        for shelf in shelves:
            sy, sh, sx = shelf
            if ph <= sh and sx + pw <= width:
                result[name] = (sx, sy, w, h)
                shelf[2] += pw
                placed = True
                break
        if not placed:
            sy = height
            shelves.append([sy, ph, pw])
            height = sy + ph
            result[name] = (0, sy, w, h)
    return result, width, height


def pick_pack_width(rects_dict, padding=4):
    """One reasonable canvas width, sized from total sprite area with
    headroom for packing inefficiency and padding - not a search for the
    tightest fit, just a single, good-enough guess. A roughly-square
    canvas (width = sqrt(total area)) is a reasonable default for a shelf
    packer; the ~40% headroom covers shelf-packing waste (a shelf's height
    is set by its tallest item, so shorter neighbors leave unused space
    below them) plus per-sprite padding.
    """
    total_area = sum((w + padding) * (h + padding) for w, h in
                      (wh[2:] for wh in rects_dict.values()))
    width = int(math.sqrt(total_area) * 1.4)
    return max(width, 64)


# --------------------------------------------------------------------------
# Image handling - Pillow-backed.
# --------------------------------------------------------------------------

def shrink_sprite(crop):
    """crop: an RGBA Image. Returns a (ceil(w/2), ceil(h/2)) RGBA Image,
    downsampled with an exact 2x2 box filter (the mathematically exact
    choice for a clean integer halving - no ringing, no aliasing).

    Odd dimensions are first edge-replicated up to even (the last column /
    row duplicated), so the box filter always sees clean, non-overlapping
    2x2 blocks: averaging a lone leftover pixel with its own copy leaves it
    unchanged, i.e. the final output column/row is just the last source
    column/row as-is. Without this, Pillow resizes an odd source (say
    23->12) with a fractional scale of 1.917, which shifts EVERY output
    pixel's sample window slightly, not just the last one - checked against
    an independent numpy implementation, nearly every odd-sized sprite in
    the real atlases differed noticeably (even-sized ones matched
    essentially exactly). Exact 2x keeps content pixel-aligned with the
    original everywhere except that single trailing row/column.

    Deliberately NO manual alpha premultiply/unpremultiply around the
    resize: Pillow's resize() already does that internally for RGBA images
    (so transparent pixels' leftover RGB values don't bleed into the
    average and darken sprite edges). An earlier version of this function
    did its own premultiply -> resize -> unpremultiply on top of that,
    which double-premultiplied and corrupted most sprites' colors (whole
    color channels coming out saturated white wherever alpha was partial).
    """
    w, h = crop.size
    pw, ph = w + (w % 2), h + (h % 2)
    if (pw, ph) != (w, h):
        padded = Image.new('RGBA', (pw, ph))
        padded.paste(crop, (0, 0))
        if pw != w:
            padded.paste(crop.crop((w - 1, 0, w, h)), (w, 0))
        if ph != h:
            padded.paste(padded.crop((0, h - 1, pw, h)), (0, h))
        crop = padded
    return crop.resize((pw // 2, ph // 2), Image.Resampling.BOX)


def extrude_sprite_borders(canvas, occupied, new_rects, cw, ch, margin=1):
    """Fills each sprite's padding margin by replicating its own edge pixels
    outward, so GPU bilinear texture filtering (which only blends a texel
    with its immediate neighbor) sampling slightly outside a sprite's exact
    rect reads more of the same opaque edge color instead of the fully-
    transparent black padding between sprites. Without this, a bright/
    opaque sprite's edges show a visible dark fringe against that padding
    once magnified - and this atlas is always drawn at 2x, via
    OeAtlasRectHelper's compensating scale, making every texel boundary
    (and this artifact) twice as visible as it would otherwise be.

    With padding=4 packing the shrunk-space gap is exactly 2px, enough for
    margin=1 (one pixel claimed by each side) with no collision - `occupied`
    (an 'L' mode mask painted with every sprite's own rect) is still
    checked before every write as a second line of defense, so this is
    safe even if that assumption is ever violated.
    """
    occ_px = occupied.load()

    def free(x, y):
        return 0 <= x < cw and 0 <= y < ch and occ_px[x, y] == 0

    for name, (x, y, w, h) in new_rects.items():
        x1, y1 = x + w, y + h  # exclusive

        for row in range(y, y1):
            left_px = canvas.getpixel((x, row))
            xx = x - 1
            while xx >= x - margin and free(xx, row):
                canvas.putpixel((xx, row), left_px)
                xx -= 1

            right_px = canvas.getpixel((x1 - 1, row))
            xx = x1
            while xx < x1 + margin and free(xx, row):
                canvas.putpixel((xx, row), right_px)
                xx += 1

        span_x0, span_x1 = x - margin, x1 + margin
        for col in range(max(0, span_x0), min(cw, span_x1)):
            top_px = canvas.getpixel((col, y))
            yy = y - 1
            while yy >= y - margin and free(col, yy):
                canvas.putpixel((col, yy), top_px)
                yy -= 1

            bot_px = canvas.getpixel((col, y1 - 1))
            yy = y1
            while yy < y1 + margin and free(col, yy):
                canvas.putpixel((col, yy), bot_px)
                yy += 1


def shrink_and_repack_sheet(png_payload, txt_payload):
    """Repacks every sprite at its original size into a fresh, even-aligned
    layout (one single canvas width - see pick_pack_width - not a search
    for the tightest fit), then downsamples the whole thing by 2x linearly.
    The offsets text is written at the new (repacked) positions, still at
    ORIGINAL scale - only the PNG shrinks; OeAtlasRectHelper.Halve maps to
    real half-scale coordinates at draw time.
    """
    rects, order = parse_offset_txt(txt_payload.decode('utf-8'))

    width = pick_pack_width(rects)
    packed_rects, pack_w, pack_h = shelf_pack_rects(rects, width)
    assert pack_w % 2 == 0 and pack_h % 2 == 0

    cw, ch = pack_w // 2, pack_h // 2

    # Don't blindly .convert('RGBA'): when the source is already RGBA,
    # convert() still returns a full COPY - for an 8192x8192 atlas that's a
    # second 268MB buffer alive at the same time as the first, which
    # doubled this step's peak memory (558MB measured) for nothing.
    old_img = Image.open(BytesIO(png_payload))
    if old_img.mode != 'RGBA':
        old_img = old_img.convert('RGBA')
    else:
        old_img.load()
    old_w, old_h = old_img.size

    new_canvas = Image.new('RGBA', (cw, ch), (0, 0, 0, 0))

    new_rects = {}
    for name in order:
        ox, oy, ow, oh = rects[name]
        px, py, pw_, ph_ = packed_rects[name]
        assert px % 2 == 0 and py % 2 == 0

        crop = old_img.crop((ox, oy, ox + ow, oy + oh))
        small = shrink_sprite(crop)
        nx, ny = px // 2, py // 2
        nw, nh = small.size
        assert nw == max(1, (pw_ + 1) // 2) and nh == max(1, (ph_ + 1) // 2)

        new_canvas.paste(small, (nx, ny))
        new_rects[name] = (nx, ny, nw, nh)

    del old_img  # done with the big source image before extrusion/encode

    # Occupancy mask only needed for extrusion, so allocate it AFTER the
    # ~268MB source image is gone rather than alongside it.
    # (Image.paste with a plain value + box fills a rectangle using only
    # Pillow's core - no ImageDraw, which pulls in font/freetype modules a
    # minimal custom-built wheel may not include.)
    occupied = Image.new('L', (cw, ch), 0)
    for nx, ny, nw, nh in new_rects.values():
        occupied.paste(1, (nx, ny, nx + nw, ny + nh))

    extrude_sprite_borders(new_canvas, occupied, new_rects, cw, ch, margin=1)

    out = BytesIO()
    new_canvas.save(out, format='PNG', compress_level=9)
    new_png_bytes = out.getvalue()

    lines = [f"{name}={packed_rects[name][0]} {packed_rects[name][1]} {packed_rects[name][2]} {packed_rects[name][3]}"
             for name in order]
    new_txt_bytes = ('\n'.join(lines) + '\n').encode('utf-8')

    return new_png_bytes, new_txt_bytes, (old_w, old_h), (cw, ch)


SHEET_PNG = 'data/gfx/generated_game/sheet.png'
SHEET_TXT = 'data/gfx/generated_game/sheet.txt'
SHEET2_PNG = 'data/gfx/generated_game/sheet2.png'
SHEET2_TXT = 'data/gfx/generated_game/sheet2.txt'


def cmd_unpack(args):
    os.makedirs(args.output_dir, exist_ok=True)

    sheets = {
        'sheet': {'png': SHEET_PNG, 'txt': SHEET_TXT},
        'sheet2': {'png': SHEET2_PNG, 'txt': SHEET2_TXT},
    }
    for info in sheets.values():
        info['png_payload'] = None
        info['txt_payload'] = None

    for parts, payload in iter_dat_entries(args.gfx_dat):
        name = '/'.join(parts)
        for info in sheets.values():
            if name == info['png']:
                info['png_payload'] = payload
    # The sheet offset tables live in offsetstex.dat, but don't assume which
    # of the given offsets archives holds them - look through all of them.
    for offsets_dat in args.offsets_dats:
        for parts, payload in iter_dat_entries(offsets_dat):
            name = '/'.join(parts)
            for info in sheets.values():
                if name == info['txt']:
                    info['txt_payload'] = payload

    for label, info in sheets.items():
        if info['png_payload'] is None or info['txt_payload'] is None:
            print(f"ERROR: could not find {info['png']}/{info['txt']} in the given archives", file=sys.stderr)
            sys.exit(1)

        new_png, new_txt, old_dims, new_dims = shrink_and_repack_sheet(info['png_payload'], info['txt_payload'])
        info['new_png'] = new_png
        info['new_txt'] = new_txt
        info['png_payload'] = info['txt_payload'] = None  # free the big source PNG
        print(f"{label}.png: {old_dims[0]}x{old_dims[1]} -> {new_dims[0]}x{new_dims[1]} "
              f"({old_dims[0]*old_dims[1]*4/1e6:.1f}MB -> {new_dims[0]*new_dims[1]*4/1e6:.1f}MB decoded)")

    replacements = {}
    for info in sheets.values():
        replacements[info['png']] = info['new_png']
        replacements[info['txt']] = info['new_txt']

    written = 0
    replaced = 0
    seen = set()
    for src_path in (args.gfx_dat, *args.offsets_dats):
        for parts, payload in iter_dat_entries(src_path):
            name = '/'.join(parts)
            if name in replacements:
                payload = replacements[name]
                replaced += 1
            if name in seen:
                print(f"WARNING: {name} appears in more than one archive; "
                      f"the copy from {os.path.basename(src_path)} overwrites the earlier one", file=sys.stderr)
            seen.add(name)

            out_path = os.path.join(args.output_dir, *parts)
            os.makedirs(os.path.dirname(out_path), exist_ok=True)
            with open(out_path, 'wb') as f:
                f.write(payload)
            written += 1

    print(f"wrote {written} loose files to {args.output_dir} "
          f"({replaced} replaced with repacked versions, 0 dropped)")


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest='cmd', required=True)

    up = sub.add_parser('unpack')
    up.add_argument('gfx_dat')
    up.add_argument('output_dir')
    up.add_argument('offsets_dats', nargs='+',
                    help='offsetstex.dat and, if present, offsetstile.dat')
    up.set_defaults(func=cmd_unpack)

    args = p.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
