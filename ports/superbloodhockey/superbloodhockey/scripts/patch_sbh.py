# Detects device resolution and patches SuperBloodHockey.exe slot 14
# to match. Recalculates zoomFactor, menuZoom, franchiseZoom from
# the reference resolution (1024x768) so menus & gameplay look right.
# Safe: verifies md5 before writing, keeps original backup.
import hashlib, struct, sys, os, re

# Expected md5 of the unmodified 1.5.4 Steam EXE
EXE_MD5 = 'c6ea018babf9f000a9aee44e2a5db2e1'
# File offset of populateResolutions IL body
IL_OFF = 0x14d68c

# ---- Resolution detection ------------------------------------------------
def detect_resolution():
    # 1) fbset (reports actual visible geometry, not buffer size)
    try:
        out = os.popen('fbset 2>/dev/null').read()
        m = re.search(r'geometry\s+(\d+)\s+(\d+)', out)
        if m:
            w, h = int(m.group(1)), int(m.group(2))
            if w > 0 and h > 0:
                return w, h
    except:
        pass
    # 2) /sys/class/graphics/fb0/modes (preferred mode string like "U:720x720p-0")
    try:
        raw = open('/sys/class/graphics/fb0/modes').read().strip()
        m = re.search(r'(\d+)x(\d+)', raw)
        if m:
            w, h = int(m.group(1)), int(m.group(2))
            if w > 0 and h > 0:
                return w, h
    except:
        pass
    # 3) sdl_resolution tool (PortMaster utility)
    try:
        out = os.popen('sdl_resolution 2>/dev/null').read()
        parts = out.strip().split()
        if len(parts) >= 2:
            w, h = int(parts[0]), int(parts[1])
            if w > 0 and h > 0:
                return w, h
    except:
        pass
    # 4) /sys/class/graphics/fb0/virtual_size (buffer size, may be doubled)
    try:
        raw = open('/sys/class/graphics/fb0/virtual_size').read().strip()
        w, h = map(int, raw.split(','))
        if w > 0 and h > 0:
            return w, h
    except:
        pass
    return None, None

# ---- Patch helpers -------------------------------------------------------
def read_slot(data, off):
    w = struct.unpack('<I', data[off+1:off+5])[0]
    h = struct.unpack('<I', data[off+6:off+10])[0]
    z = struct.unpack('<f', data[off+0xb:off+0xf])[0]
    bw = struct.unpack('<I', data[off+0x10:off+0x14])[0]
    bh = struct.unpack('<I', data[off+0x15:off+0x19])[0]
    mz = struct.unpack('<f', data[off+0x1c:off+0x20])[0]
    return w, h, z, bw, bh, mz

def slot_matches(data, off, w, h, z, mz):
    cw, ch, cz, cbw, cbh, cmz = read_slot(data, off)
    return cw == w and ch == h and abs(cz - z) < 0.001 and abs(cmz - mz) < 0.001

# ---- Main -----------------------------------------------------------------
exe_path = sys.argv[1]
if not os.path.exists(exe_path):
    print('SBH: exe not found')
    sys.exit(1)

# Optional manual resolution override: patch_sbh.py <exe> <width>x<height>
manual_res = None
if len(sys.argv) >= 3:
    try:
        parts = sys.argv[2].lower().split('x')
        manual_res = (int(parts[0]), int(parts[1]))
    except:
        pass

with open(exe_path, 'rb') as f:
    data = bytearray(f.read())

cur_md5 = hashlib.md5(data).hexdigest()
backup = exe_path.replace('.exe', '_original.exe')
is_original = (cur_md5 == EXE_MD5)

if not is_original:
    if os.path.exists(backup):
        with open(backup, 'rb') as f:
            if hashlib.md5(f.read()).hexdigest() == EXE_MD5:
                print('SBH: already patched, restoring original')
                with open(backup, 'rb') as f:
                    data = bytearray(f.read())
                is_original = True
            else:
                print('SBH: unknown exe, skipping')
                sys.exit(1)
    else:
        print('SBH: unknown exe, skipping')
        sys.exit(1)

# Detect resolution (manual override takes precedence)
if manual_res:
    w, h = manual_res
else:
    w, h = detect_resolution()
if w is None:
    print('SBH: could not detect resolution')
    sys.exit(1)
print(f'SBH: detected {w}x{h}')

# Scan all 15 slots for an exact resolution match
il = IL_OFF
# Slot offsets from IL body (verified by scanning original EXE)
slot_offsets = [0x01, 0x38, 0x6f, 0xa6, 0xe2, 0x11c, 0x156,
                0x190, 0x1ca, 0x204, 0x244, 0x284, 0x2c4, 0x304, 0x344]
match_slot = None
for idx, off in enumerate(slot_offsets):
    sw, sh, sz, sbw, sbh, smz = read_slot(data, il + off)
    if sw == w and sh == h:
        match_slot = idx
        break
if match_slot is not None:
    print(f'SBH: slot {match_slot} already matches {w}x{h}, no patch needed')
    sys.exit(0)

slot14_off = il + 0x344
fz14_off = il + 0x036d

# Calculate ideal values
GW = 1280  # game world width
REF = 1024  # reference width (1024x768)
zoom_factor = w / GW
menu_zoom = w / REF
franchise_zoom = w / REF
backbuf_w = w
backbuf_h = h

# Check if slot 14 already matches
if slot_matches(data, slot14_off, w, h, zoom_factor, menu_zoom):
    fz = struct.unpack('<f', data[fz14_off+1:fz14_off+5])[0]
    if abs(fz - franchise_zoom) < 0.001:
        print(f'SBH: slot 14 already matches {w}x{h}')
        sys.exit(0)

# Save original backup if not done already
if not os.path.exists(backup):
    with open(backup, 'wb') as f:
        f.write(data)
    print(f'SBH: backup saved')

# Patch slot 14
def patch_slot(off, w, h, z, bw, bh, mz):
    data[off+0x01:off+0x05] = struct.pack('<I', w)
    data[off+0x06:off+0x0a] = struct.pack('<I', h)
    data[off+0x0b:off+0x0f] = struct.pack('<f', z)
    data[off+0x10:off+0x14] = struct.pack('<I', bw)
    data[off+0x15:off+0x19] = struct.pack('<I', bh)
    data[off+0x1c:off+0x20] = struct.pack('<f', mz)

patch_slot(slot14_off, w, h, zoom_factor, backbuf_w, backbuf_h, menu_zoom)

# Patch franchiseZoom
assert data[fz14_off:fz14_off+1] == b'\x22'
data[fz14_off+1:fz14_off+5] = struct.pack('<f', franchise_zoom)

with open(exe_path, 'wb') as f:
    f.write(data)

print(f'SBH: slot 14 set to {w}x{h} game={zoom_factor:.4f} menu={menu_zoom:.4f} fZ={franchise_zoom:.4f}')
