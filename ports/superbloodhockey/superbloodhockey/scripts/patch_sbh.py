# Patches SuperBloodHockey.exe resolution table for handheld displays.
# Replaces slots 13 (640x480) and 14 (720x720) with handheld-friendly values.
# Slot 13: 640x480, game=0.5, menu=0.629, fZ=0.625
# Slot 14: 720x720, game=0.5625, menu=0.703125, fZ=0.703125
# Safe: verifies md5 before writing. Skips unknown/preexecuted exes.
import hashlib, struct, sys, os

exe_path = sys.argv[1]

if not os.path.exists(exe_path):
    sys.exit(1)

expected_md5 = 'c6ea018babf9f000a9aee44e2a5db2e1'

with open(exe_path, 'rb') as f:
    data = bytearray(f.read())

cur = hashlib.md5(data).hexdigest()

backup = exe_path.replace('.exe', '_original.exe')

if cur != expected_md5 and os.path.exists(backup):
    with open(backup, 'rb') as f:
        backup_hash = hashlib.md5(f.read()).hexdigest()
    if backup_hash == expected_md5:
        sys.exit(0)
    else:
        print(f'SBH patcher: unknown exe ({cur}), skipping')
        sys.exit(1)

if cur != expected_md5:
    print(f'SBH patcher: unknown exe ({cur}), skipping')
    sys.exit(1)

if not os.path.exists(backup):
    with open(backup, 'wb') as f:
        f.write(data)
    print(f'SBH: backup saved to {backup}')

il = 0x14d68c  # file offset of populateResolutions IL body start

def patch_slot(slot_start, w, h, scale, bw, bh, menu_z):
    # slot_start points to the first ldc.i4 opcode
    data[slot_start+0x01:slot_start+0x05] = struct.pack('<I', w)
    data[slot_start+0x06:slot_start+0x0a] = struct.pack('<I', h)
    data[slot_start+0x0b:slot_start+0x0f] = struct.pack('<f', scale)
    data[slot_start+0x10:slot_start+0x14] = struct.pack('<I', bw)
    data[slot_start+0x15:slot_start+0x19] = struct.pack('<I', bh)
    data[slot_start+0x1c:slot_start+0x20] = struct.pack('<f', menu_z)

# Slot 13: 640x480, zoomFactor=640/1280=0.5 (full game width), menuZoom=0.629 (visible)
patch_slot(il + 0x304, 640, 480, 0.5, 640, 480, 0.629)

# Slot 14: 720x720, zoomFactor=720/1280=0.5625, menuZoom=0.703125 (match 1024 width), franchiseZoom=0.703125
patch_slot(il + 0x344, 720, 720, 0.5625, 720, 720, 0.703125)

# Slot 13 franchiseZoom: il+0x032d, was 1.501
fo = il + 0x032d
assert data[fo:fo+1] == b'\x22'
data[fo+1:fo+5] = struct.pack('<f', 0.625)

# Slot 14 franchiseZoom: il+0x036d, was 2.0
fo = il + 0x036d
assert data[fo:fo+1] == b'\x22'
data[fo+1:fo+5] = struct.pack('<f', 0.703125)

with open(exe_path, 'wb') as f:
    f.write(data)

print('SBH: slot 13=640x480 game=0.5 menu=0.629 fZ=0.625; slot 14=720x720 game=0.5625 menu=0.703 fZ=0.703')
