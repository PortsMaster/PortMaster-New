#!/usr/bin/env python3
"""
patch_soma_spirits.py
----------------------
PortMaster/mkxp-z compatibility patcher for Soma Spirits: Rebalance
(RPG Maker VX Ace).

Problem
-------
Game.rgss3a's Scripts.rvdata2 contains two scripts that call Win32API
directly and will crash on launch under mkxp-z (Linux/ARM handhelds have
no Win32API, user32.dll, gdi32.dll, or TRGSSX.dll):

  1. "KGC Bitmap Extension" (#124)
     - A begin/rescue around TRGSSX.dll init that, on failure, prints a
       message and calls `exit` -- meaning the rescue path itself kills
       the game instead of degrading gracefully.
     - Eight more @@_api_* = Win32API.new('gdi32', ...) class-variable
       assignments (Region/RectRegion/EllipticRegion/PolygonRegion/
       CombinedRegion classes) with NO rescue guard at all. These run at
       script-load time regardless of whether the game ever uses them.

  2. "FullScreen" (Zeus81's Fullscreen++, #170)
     - Calls Win32API.new('user32'/'gdi32'/'kernel32', ...) directly in
       the module body, including FindWindow.call(...) executed
       immediately on load. No guard at all. Entirely redundant under
       mkxp-z, which handles fullscreen natively via Game.ini's
       [Fullscreen]/[FullscreenRatio] keys.

What this script does
----------------------
- Reads Game.rgss3a (RGSS3A v3 archive), locates and decrypts
  Data/Scripts.rvdata2 in memory.
- Unmarshals the script list, patches only entries #124 and #170's
  source text, re-compresses and re-marshals.
- Re-encrypts the patched Scripts.rvdata2 and writes it back IN PLACE
  into Game.rgss3a, inside its existing slot, then updates just that
  entry's size field in the archive's header table. Nothing else in the
  archive moves.

  NOTE: an earlier version of this patcher wrote the result as a loose
  Data/Scripts.rvdata2 file instead, assuming RGSS/mkxp-z would prefer
  loose files over the archive. That's wrong -- per Enterbrain's own
  RGSS documentation, when an encrypted archive is present in the game
  folder, script data is *always* read from the archive, with no way
  for a loose file to override it. Confirmed against a real log.txt
  crash where the unpatched TRGSSX exit call still fired. Patching the
  archive directly (same approach as the Disc Creatures port) is the
  only way this actually takes effect.

Everything else in Scripts.rvdata2 (190 other scripts) passes through
byte-identical to the original. If the patched Scripts.rvdata2 ever grew
larger than its original slot, the patcher aborts rather than silently
corrupting the archive -- this hasn't happened in testing (patched
content is smaller, since both patches remove code).

Additionally, patches the game's own "Font" script (#173: sets
Font.default_name/default_size/default_bold), changing
`Font.default_size = 24` to `Font.default_size = 18` to shrink dialog/
message text for handheld screens. NOTE: an earlier version of this
patcher tried setting Font.default_size from inside the FullScreen stub
instead. That doesn't work -- Font (#173) runs AFTER FullScreen (#170)
in script load order and unconditionally re-sets it to 24, silently
clobbering any earlier override. The Font script itself is the only
correct patch point.

Font.default_size ALSO does not affect this game's Luna Engine UI scripts
(a third-party RPG Maker VX Ace UI framework), which hardcode their own
:size values right next to a :font key (or as a bare int in an array
literal) instead of reading the global default. Confirmed by grepping the
real Game.rgss3a: exactly 4 scripts do this --
  - Configuration Main/Item/Skill Menu, Battle Luna Config: hash style,
    ":font => \"Grand9K Pixel\", ... :size => 24" (35 sites) -> 18,
    and Franklin Gothic Demi Cond ":size => 32" (4 sites) -> 28.
  - Lunatic Config Main Menu (gold/timer/difficulty display): array style,
    ["Grand9K Pixel", 24, true, false] (4 sites) -> 18.
  - Damage Popup (battle damage/heal numbers): array style,
    [r, g, b, 48, true, false, "Grand9K Pixel"] (23 sites) -> 24 (was a
    comically large 48pt).
All four patterns are applied to every script entry that mentions either
font name (a cheap substring pre-check skips the other ~189 scripts
without decompressing them). 66 substitution sites total.

Usage
-----
    python3 patch_soma_spirits.py /path/to/game_dir

Where game_dir contains Game.rgss3a, Game.ini, etc. Intended to be called
once from the PortMaster launch .sh before mkxp-z starts, same pattern
as the LISA/Disc Creatures/Skull Princess ports.
"""

import os
import re
import struct
import sys
import zlib

# ---------------------------------------------------------------------------
# Minimal Ruby Marshal reader/writer (subset sufficient for RGSS3
# Scripts.rvdata2: an Array of [Fixnum id, String name, String zlib_data]).
# ---------------------------------------------------------------------------


class MarshalReader:
    def __init__(self, data):
        self.data = data
        assert data[0:2] == b'\x04\x08', "not a Marshal 4.8 stream"
        self.pos = 2
        self.symbols = []
        self.objects = []

    def read_byte(self):
        b = self.data[self.pos]
        self.pos += 1
        return b

    def read_bytes(self, n):
        b = self.data[self.pos:self.pos + n]
        self.pos += n
        return b

    def read_fixnum(self):
        b = self.read_byte()
        c = struct.unpack('b', bytes([b]))[0]
        if c == 0:
            return 0
        if c > 0:
            if 4 < c < 128:
                return c - 5
            n = c
            bs = self.read_bytes(n)
            val = 0
            for i, byte in enumerate(bs):
                val |= byte << (8 * i)
            return val
        else:
            if -129 < c < -4:
                return c + 5
            n = -c
            bs = self.read_bytes(n)
            val = 0
            for i, byte in enumerate(bs):
                val |= byte << (8 * i)
            val -= (1 << (8 * n))
            return val

    def read_object(self):
        t = self.read_byte()
        return self.read_object_type(t)

    def read_object_type(self, t):
        ch = chr(t)
        if ch == '0':
            return None
        elif ch == 'T':
            return True
        elif ch == 'F':
            return False
        elif ch == 'i':
            return self.read_fixnum()
        elif ch == ':':
            n = self.read_fixnum()
            s = self.read_bytes(n)
            self.symbols.append(s)
            return ('symbol', s)
        elif ch == ';':
            idx = self.read_fixnum()
            return ('symbol', self.symbols[idx])
        elif ch == '"':
            n = self.read_fixnum()
            s = self.read_bytes(n)
            self.objects.append(s)
            return s
        elif ch == '@':
            idx = self.read_fixnum()
            return self.objects[idx]
        elif ch == '[':
            n = self.read_fixnum()
            arr = []
            self.objects.append(arr)
            for _ in range(n):
                arr.append(self.read_object())
            return arr
        elif ch == 'I':
            obj = self.read_object()
            n = self.read_fixnum()
            for _ in range(n):
                self.read_object()  # symbol
                self.read_object()  # value
            return obj
        elif ch == 'u':
            self.read_object()  # class symbol
            n = self.read_fixnum()
            s = self.read_bytes(n)
            self.objects.append(s)
            return s
        elif ch == 'l':
            sign = self.read_byte()
            n = self.read_fixnum()
            bs = self.read_bytes(2 * n)
            val = 0
            for i, byte in enumerate(bs):
                val |= byte << (8 * i)
            if chr(sign) == '-':
                val = -val
            return val
        else:
            raise Exception(f"Unsupported marshal type {ch!r} at pos {self.pos}")


def marshal_load(data):
    return MarshalReader(data).read_object()


def _encode_fixnum_raw(n):
    if n == 0:
        return b'\x00'
    if 0 < n < 123:
        return bytes([n + 5])
    if -124 < n < 0:
        return struct.pack('b', n - 5)
    neg = n < 0
    val = -n if neg else n
    nbytes = []
    v = val
    while v > 0:
        nbytes.append(v & 0xFF)
        v >>= 8
    if not nbytes:
        nbytes = [0]
    if neg:
        total = 1 << (8 * len(nbytes))
        stored = total - val
        tmp = []
        vv = stored
        while vv > 0:
            tmp.append(vv & 0xFF)
            vv >>= 8
        nbytes = tmp if tmp else [0]
        return struct.pack('b', -len(nbytes)) + bytes(nbytes)
    return struct.pack('b', len(nbytes)) + bytes(nbytes)


def _write_fixnum(n):
    return b'i' + _encode_fixnum_raw(n)


def _write_symbol(s):
    return b':' + _encode_fixnum_raw(len(s)) + s


def _write_string_utf8(s):
    out = b'I"' + _encode_fixnum_raw(len(s)) + s
    out += _encode_fixnum_raw(1)
    out += _write_symbol(b'E')
    out += b'T'
    return out


def _write_array(items):
    out = b'[' + _encode_fixnum_raw(len(items))
    for it in items:
        out += _write_object(it)
    return out


def _write_object(obj):
    if obj is None:
        return b'0'
    if obj is True:
        return b'T'
    if obj is False:
        return b'F'
    if isinstance(obj, int):
        return _write_fixnum(obj)
    if isinstance(obj, bytes):
        return _write_string_utf8(obj)
    if isinstance(obj, list):
        return _write_array(obj)
    raise TypeError(f"Unsupported type for marshal write: {type(obj)}")


def marshal_dump(obj):
    return b'\x04\x08' + _write_object(obj)


# ---------------------------------------------------------------------------
# RGSS3A archive reading (metadata_key = seed*9+3, held CONSTANT across all
# entries and all fields -- RGSS3A does not permutate its key per field like
# v1/v2 archives do. File data itself uses a separate per-file key that DOES
# permutate via key = key*7+3 every 4 bytes, cycled from each entry's own
# file_key value.)
# ---------------------------------------------------------------------------


def rgss3a_list_entries(data):
    assert data[:8] == b'RGSSAD\x00\x03', "not an RGSS3A v3 archive"
    seed = struct.unpack('<I', data[8:12])[0]
    key = (seed * 9 + 3) & 0xFFFFFFFF
    kbytes = key.to_bytes(4, 'little')
    pos = 12
    entries = []
    n = len(data)
    while True:
        offset = struct.unpack('<I', data[pos:pos + 4])[0] ^ key
        pos += 4
        if offset == 0:
            break
        size_field_pos = pos
        size = struct.unpack('<I', data[pos:pos + 4])[0] ^ key
        pos += 4
        file_key = struct.unpack('<I', data[pos:pos + 4])[0] ^ key
        pos += 4
        namelen = struct.unpack('<I', data[pos:pos + 4])[0] ^ key
        pos += 4
        name_enc = data[pos:pos + namelen]
        pos += namelen
        name = bytes(b ^ kbytes[i % 4] for i, b in enumerate(name_enc)).decode('utf-8')
        entries.append({
            'name': name, 'offset': offset, 'size': size, 'file_key': file_key,
            'size_field_pos': size_field_pos, 'metadata_key': key,
        })
    return entries


def rgss3a_decrypt_file(data, offset, size, file_key):
    raw = data[offset:offset + size]
    out = bytearray(len(raw))
    k = file_key & 0xFFFFFFFF
    kb = k.to_bytes(4, 'little')
    for i in range(len(raw)):
        j = i % 4
        out[i] = raw[i] ^ kb[j]
        if j == 3:
            k = (k * 7 + 3) & 0xFFFFFFFF
            kb = k.to_bytes(4, 'little')
    return bytes(out)


# ---------------------------------------------------------------------------
# Script patches
# ---------------------------------------------------------------------------

TRGSSX_OLD_START = "  DLL_NAME = 'TRGSSX'\r\n  begin\r\n    NO_TRGSSX = false"
TRGSSX_OLD_END = (
    "  rescue\r\n    NO_TRGSSX = true\r\n"
    "    print \"\\\"#{DLL_NAME}.dll\\\" is not found or\" +\r\n"
    "      \"you are using an older version.\"\r\n"
    "    exit\r\n  end\r\n"
)
TRGSSX_REPLACEMENT = "  DLL_NAME = 'TRGSSX'\r\n  NO_TRGSSX = true\r\n"

GDI32_PATTERN = re.compile(r"(@@_api_\w+\s*=\s*Win32API\.new\([^)]*\))(?! rescue nil)", re.DOTALL)

FULLSCREEN_STUB = (
    "# Fullscreen++ (Zeus81) disabled for mkxp-z / PortMaster.\r\n"
    "# mkxp-z handles fullscreen natively via Game.ini [Fullscreen]/[FullscreenRatio].\r\n"
    "# Original script relied on unguarded native window-API calls (user32/gdi32) that\r\n"
    "# crash immediately on non-Windows RGSS runtimes.\r\n"
    "$imported ||= {}\r\n"
    "$imported[:Zeus_Fullscreen] = __FILE__\r\n"
)

# The real default-font settings live in the game's own "Font" script (#173),
# which runs AFTER FullScreen (#170) -- so overriding Font.default_size from
# within the FullScreen stub gets silently clobbered back to the game's own
# value every time. Must be patched at the source: Font.default_size = 24 -> 10.
FONT_SIZE_PATTERN = re.compile(rb'Font\.default_size\s*=\s*\d+')
FONT_SIZE_NEW = b'Font.default_size = 18'

# ---------------------------------------------------------------------------
# The Luna Engine (RPG Maker VX Ace UI framework this game is built on) does
# NOT respect Font.default_size for its own custom-drawn UI elements (config
# menus, gold/timer/difficulty display, battle damage popups). Those scripts
# hardcode :size => N directly next to a :font => "..." key, or as a bare
# integer inside an array literal, so Font.default_size alone leaves them all
# at their original (much larger) size. Confirmed against the real
# Game.rgss3a: exactly 4 scripts use these patterns (Configuration Main/Item/
# Skill Menu, Battle Luna Config use the hash style; Lunatic Config Main Menu
# and Damage Popup use array styles), 66 total substitution sites.
#
# Patterns are scoped tightly (font name + size must appear together) so they
# cannot accidentally match unrelated numbers elsewhere in a 60K-line script.
GRAND9K_HASH_PATTERN = re.compile(rb'(:font\s+=>\s+"Grand9K Pixel",[^\r\n]*\r?\n\s*:size\s+=>\s+)(\d+)(,)')
FRANKLIN_HASH_PATTERN = re.compile(rb'(:font\s+=>\s+"Franklin Gothic Demi Cond",[^\r\n]*\r?\n\s*:size\s+=>\s+)(\d+)(,)')
GRAND9K_ARRAY_PATTERN = re.compile(rb'("Grand9K Pixel",\s*)(\d+)(,\s*true,\s*false\])')
POPUP_ARRAY_PATTERN = re.compile(rb'(,\s*)(\d+)(,\s*true,\s*false,\s*"Grand9K Pixel"\])')

GRAND9K_SIZE_NEW = b'18'          # dialog/menu text, matches Font.default_size
FRANKLIN_SIZE_NEW = b'28'         # user-tested: 32 -> 28, no visible issues
POPUP_SIZE_NEW = b'24'            # damage/heal popup numbers, was a huge 48


def patch_kgc_bitmap_extension(src: str) -> str:
    if TRGSSX_OLD_START in src and TRGSSX_OLD_END in src:
        start_i = src.index(TRGSSX_OLD_START)
        end_i = src.index(TRGSSX_OLD_END) + len(TRGSSX_OLD_END)
        src = src[:start_i] + TRGSSX_REPLACEMENT + src[end_i:]
    src = GDI32_PATTERN.sub(lambda m: m.group(1) + " rescue nil", src)
    return src


def patch_luna_font_sizes(src: bytes) -> tuple:
    """Apply all four hardcoded-size patterns. Returns (new_src, total_count)."""
    total = 0
    src, n = GRAND9K_HASH_PATTERN.subn(lambda m: m.group(1) + GRAND9K_SIZE_NEW + m.group(3), src)
    total += n
    src, n = FRANKLIN_HASH_PATTERN.subn(lambda m: m.group(1) + FRANKLIN_SIZE_NEW + m.group(3), src)
    total += n
    src, n = GRAND9K_ARRAY_PATTERN.subn(lambda m: m.group(1) + GRAND9K_SIZE_NEW + m.group(3), src)
    total += n
    src, n = POPUP_ARRAY_PATTERN.subn(lambda m: m.group(1) + POPUP_SIZE_NEW + m.group(3), src)
    total += n
    return src, total


def patch_scripts_rvdata2(raw_scripts_data: bytes) -> bytes:
    obj = marshal_load(raw_scripts_data)
    patched_any = {'kgc': False, 'fullscreen': False, 'font': False}
    luna_font_sites = 0
    for entry in obj:
        sid, name, comp = entry
        if name == b'KGC Bitmap Extension':
            src = zlib.decompress(comp).decode('utf-8')
            new_src = patch_kgc_bitmap_extension(src)
            entry[2] = zlib.compress(new_src.encode('utf-8'), 9)
            patched_any['kgc'] = True
            continue
        elif name == b'FullScreen':
            entry[2] = zlib.compress(FULLSCREEN_STUB.encode('utf-8'), 9)
            patched_any['fullscreen'] = True
            continue
        elif name == b'Font':
            src_bytes = zlib.decompress(comp)
            new_src_bytes, n = FONT_SIZE_PATTERN.subn(FONT_SIZE_NEW, src_bytes)
            if n == 1:
                entry[2] = zlib.compress(new_src_bytes, 9)
                patched_any['font'] = True
            continue

        # Cheap pre-check before decompressing/regexing every one of the
        # other ~190 scripts: only Luna Engine UI scripts mention these
        # font names at all.
        raw = zlib.decompress(comp)
        if b'Grand9K Pixel' in raw or b'Franklin Gothic Demi Cond' in raw:
            new_raw, n = patch_luna_font_sizes(raw)
            if n:
                entry[2] = zlib.compress(new_raw, 9)
                luna_font_sites += n

    missing = [k for k, v in patched_any.items() if not v]
    if missing:
        print(f"WARNING: expected script(s) not found (already patched, or a different "
              f"Scripts.rvdata2 build): {missing}", file=sys.stderr)
    print(f"Patched {luna_font_sites} hardcoded Luna Engine font-size sites "
          f"(expected 66: 35 Grand9K hash + 4 Franklin Gothic hash + 4 Grand9K "
          f"array + 23 Damage Popup array).", file=sys.stderr)
    return marshal_dump([list(e) for e in obj])


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} /path/to/game_dir", file=sys.stderr)
        sys.exit(1)

    game_dir = sys.argv[1]
    rgss3a_path = os.path.join(game_dir, 'Game.rgss3a')
    marker_path = os.path.join(game_dir, 'patchlog.txt')

    if not os.path.isfile(rgss3a_path):
        print(f"ERROR: {rgss3a_path} not found", file=sys.stderr)
        sys.exit(1)

    if os.path.isfile(marker_path):
        print(f"{marker_path} already exists -- skipping (already patched).")
        return

    print(f"Reading {rgss3a_path} ...")
    data = bytearray(open(rgss3a_path, 'rb').read())

    entries = rgss3a_list_entries(bytes(data))
    scripts_entry = next((e for e in entries if e['name'].endswith('Scripts.rvdata2')), None)
    if scripts_entry is None:
        print("ERROR: Scripts.rvdata2 not found inside Game.rgss3a", file=sys.stderr)
        sys.exit(1)

    off = scripts_entry['offset']
    sz = scripts_entry['size']
    file_key = scripts_entry['file_key']
    size_field_pos = scripts_entry['size_field_pos']
    metadata_key = scripts_entry['metadata_key']
    print(f"Scripts.rvdata2 found at offset {off}, size {sz}")

    print("Decrypting Scripts.rvdata2 ...")
    raw_scripts = rgss3a_decrypt_file(bytes(data), off, sz, file_key)

    print("Patching KGC Bitmap Extension (#TRGSSX + Region Win32API) and FullScreen (Zeus81) ...")
    patched = patch_scripts_rvdata2(raw_scripts)
    new_sz = len(patched)
    print(f"Patched Scripts.rvdata2: {sz} -> {new_sz} bytes")

    if new_sz > sz:
        print(
            f"ERROR: patched content ({new_sz} bytes) no longer fits in the original "
            f"archive slot ({sz} bytes). Refusing to patch -- would require rebuilding "
            f"the whole archive with shifted offsets, which this patcher does not do.",
            file=sys.stderr,
        )
        sys.exit(1)

    print("Re-encrypting patched Scripts.rvdata2 ...")
    new_encrypted = rgss3a_decrypt_file(patched, 0, new_sz, file_key)  # XOR cipher: symmetric

    # Overwrite the blob within its existing slot. Any leftover bytes beyond
    # new_sz within the old slot are never read, since the size field below
    # tells the archive reader exactly how many bytes belong to this entry.
    data[off:off + new_sz] = new_encrypted

    # Update just the size field in the header table (still XORed with the
    # constant metadata_key, same as every other field).
    data[size_field_pos:size_field_pos + 4] = struct.pack('<I', new_sz ^ metadata_key)

    tmp_path = rgss3a_path + '.tmp'
    with open(tmp_path, 'wb') as f:
        f.write(data)
    os.replace(tmp_path, rgss3a_path)

    with open(marker_path, 'w') as f:
        f.write("Soma Spirits Rebalance patched successfully.\n")

    print(f"Patched {rgss3a_path} in place ({new_sz} of {sz} bytes used in the Scripts slot).")


if __name__ == '__main__':
    main()
