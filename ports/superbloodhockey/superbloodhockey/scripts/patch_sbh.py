# Patches SuperBloodHockey.exe for 640x480 displays (RG35XX-H etc).
# Replaces resolution ID 14 (3840x2160, useless on handhelds) with a
# native 640x480 entry. 
# Safe: verifies md5 before writing. Skips unknown/preexecuted exes.
import hashlib, struct, sys, os

exe_path = sys.argv[1]

if not os.path.exists(exe_path):
    sys.exit(1)

expected_md5 = 'c6ea018babf9f000a9aee44e2a5db2e1'
patched_md5 = '984271e37f659ffe9b65ee6be24d27fc'

with open(exe_path, 'rb') as f:
    data = bytearray(f.read())

cur = hashlib.md5(data).hexdigest()

if cur == patched_md5:
    sys.exit(0)

if cur != expected_md5:
    print(f'SBH patcher: unknown exe ({cur}), skipping')
    sys.exit(1)

backup = exe_path.replace('.exe', '_original.exe')
if not os.path.exists(backup):
    with open(backup, 'wb') as f:
        f.write(data)
    print(f'SBH: backup saved to {backup}')

# populateResolutions ID 0 -> 1024x768 (restore)
il = 0x14d68c
data[il+0x02:il+0x06] = struct.pack('<I', 1024)
data[il+0x07:il+0x0b] = struct.pack('<I', 768)
data[il+0x0c:il+0x10] = struct.pack('<f', 1.0)
data[il+0x11:il+0x15] = struct.pack('<I', 1024)
data[il+0x16:il+0x1a] = struct.pack('<I', 768)

# populateResolutions ID 14 -> 640x480
off = il + 0x344
data[off+0x01:off+0x05] = struct.pack('<I', 640)
data[off+0x06:off+0x0a] = struct.pack('<I', 480)
data[off+0x0b:off+0x0f] = struct.pack('<f', 0.625)
data[off+0x10:off+0x14] = struct.pack('<I', 640)
data[off+0x15:off+0x19] = struct.pack('<I', 480)
data[off+0x1c:off+0x20] = struct.pack('<f', 0.625)

# 6-param ctor: menuZoom default 1.0 -> 0.625
ctor = 0x14d444
data[ctor+0x23:ctor+0x27] = struct.pack('<f', 0.625)

# Game1.setResolution: yOffset/Camera offset formulas
sr = 0xc9714
data[sr+0x1a2:sr+0x1a6] = struct.pack('<I', 480)
data[sr+0x1ba:sr+0x1be] = struct.pack('<I', 480)
data[sr+0x1d2:sr+0x1d6] = struct.pack('<I', 640)

with open(exe_path, 'wb') as f:
    f.write(data)
print('SBH patched for 640x480')

