# Detects device resolution and patches SuperBloodHockey.exe slot 14
# to match. Recalculates zoomFactor, menuZoom, franchiseZoom from
# the reference resolution (1024x768) so menus & gameplay look right.
# Safe: verifies md5 before writing, keeps original backup.
import hashlib, struct, sys, os, re

# Expected md5 of the unmodified 1.5.4 Steam EXE
EXE_MD5 = 'c6ea018babf9f000a9aee44e2a5db2e1'
# File offset of populateResolutions IL body
IL_OFF = 0x14d68c

# ---- Camera zoom fix: prevent franchise zoom compounding -------------------
# Root cause: get_transformation() and get_transformationFacility() multiply
# Camera::Zoom into the scale transform. When OpenLineUpMenu or DrawScene set
# Camera::Zoom to a non-1.0 value, the compound (franchiseZoom * Zoom) gives
# ~0.393 instead of ~0.625 at 640x480 → 1628 virtual pixels (zoom way out).
# Fix: replace ldsfld Camera::Zoom with ldc.r4 1.0 in those methods, and nop
# the stsfld Camera::Zoom in OpenLineUpMenu and DrawScene.
CAMERA_ZOOM_PATCHES = [
    # (file_offset, old_5bytes, new_5bytes)
    # get_transformation (RVA 0x4b80, code_off 0x2d8c): 4x ldsfld -> ldc.r4 1.0
    (0x2db5, b'\x7e\x25\x00\x00\x04', b'\x22\x00\x00\x80\x3f'),
    (0x2dc0, b'\x7e\x25\x00\x00\x04', b'\x22\x00\x00\x80\x3f'),
    (0x2e25, b'\x7e\x25\x00\x00\x04', b'\x22\x00\x00\x80\x3f'),
    (0x2e30, b'\x7e\x25\x00\x00\x04', b'\x22\x00\x00\x80\x3f'),
    # get_transformationFacility (RVA 0x4cf0, code_off 0x2efc): 2x ldsfld -> ldc.r4 1.0
    (0x2f2f, b'\x7e\x25\x00\x00\x04', b'\x22\x00\x00\x80\x3f'),
    (0x2f3f, b'\x7e\x25\x00\x00\x04', b'\x22\x00\x00\x80\x3f'),
    # OpenLineUpMenu (RVA 0x7ede0, code_off 0x7cfec): stsfld -> pop + 4 nops
    (0x7cff7, b'\x80\x25\x00\x00\x04', b'\x26\x00\x00\x00\x00'),
    # DrawScene (RVA 0x76df4, code_off 0x75000): stsfld -> pop + 4 nops
    (0x75059, b'\x80\x25\x00\x00\x04', b'\x26\x00\x00\x00\x00'),
]

def apply_camera_zoom_fix(data):
    # Must be called on original (unpatched) data
    for off, old, new in CAMERA_ZOOM_PATCHES:
        if data[off:off+5] != old:
            print(f'SBH: camera-zoom: unexpected bytes at 0x{off:x}')
            print(f'  expected {old.hex()}, got {data[off:off+5].hex()}')
            return False
        data[off:off+5] = new
    return True

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
                print('SBH: backup exists but is not the original EXE')
                print('SBH: patching current EXE in-place (camera fix + slot 14)')
    else:
        print('SBH: no backup found, patching current EXE in-place')

# Save original backup (before any modifications)
if not os.path.exists(backup):
    with open(backup, 'wb') as f:
        f.write(data)
    print('SBH: original backup saved')

# Apply camera-zoom fix (IL patches to prevent franchise zoom compounding)
# On first-run or after restore, the bytes are original and patching works.
# If re-patching in-place, the fix may already be applied — check patched patterns.
CAMERA_PATCHED = [b'\x22\x00\x00\x80\x3f', b'\x26\x00\x00\x00\x00']
def camera_patch_already_applied(data):
    for off, old, new in CAMERA_ZOOM_PATCHES:
        actual = bytes(data[off:off+5])
        if actual not in (old, new):
            return False  # unknown bytes — can't safely determine
        if actual == old:
            return False  # still original — needs patching
    return True

if not apply_camera_zoom_fix(data):
    if camera_patch_already_applied(data):
        print('SBH: camera-zoom fix already applied, skipping')
    else:
        print('SBH: camera-zoom fix FAILED — unknown EXE version')
        sys.exit(1)
else:
    print('SBH: camera-zoom fix applied')

# Detect resolution (manual override takes precedence)
if manual_res:
    w, h = manual_res
else:
    w, h = detect_resolution()
if w is None:
    print('SBH: could not detect resolution')
    sys.exit(1)
print(f'SBH: detected {w}x{h}')

il = IL_OFF
slot14_off = il + 0x344
fz14_off = il + 0x036d

# Calculate ideal values
# Unified zoom ref (1024 minus a few px) to hide TV frame edges on small screens.
# All three zoom values are unified so get_transformation* methods produce
# consistent scaling regardless of which transform is active.
ZOOM_REF = 1020
zoom_factor = w / ZOOM_REF
menu_zoom = w / ZOOM_REF
franchise_zoom = w / ZOOM_REF
backbuf_w = w
backbuf_h = h

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

print(f'SBH: slot 14 set to {w}x{h} zoom={zoom_factor:.4f} menu={menu_zoom:.4f} fZ={franchise_zoom:.4f}')
