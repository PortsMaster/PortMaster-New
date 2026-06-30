# Patches SuperBloodHockey.exe for 640x480 (ID 13) and 720x720 (ID 14).
# Replaces last two (largest) resolution slots with handheld-friendly ones.
# Safe: verifies md5 before writing. Skips unknown/preexecuted exes.
import hashlib, struct, sys, os

exe_path = sys.argv[1]

if not os.path.exists(exe_path):
    sys.exit(1)

expected_md5 = 'c6ea018babf9f000a9aee44e2a5db2e1'
patched_md5 = 'dc42377e69548af3270baea342955258'

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

il = 0x14d68c

# ID 13 -> 640x480 (second-to-last slot, was 2560x1440)
o13 = il + 0x304
data[o13+0x01:o13+0x05] = struct.pack('<I', 640)
data[o13+0x06:o13+0x0a] = struct.pack('<I', 480)
data[o13+0x0b:o13+0x0f] = struct.pack('<f', 0.625)
data[o13+0x10:o13+0x14] = struct.pack('<I', 640)
data[o13+0x15:o13+0x19] = struct.pack('<I', 480)
data[o13+0x1c:o13+0x20] = struct.pack('<f', 0.625)

# ID 14 -> 720x720 (last slot, was 3840x2160)
o14 = il + 0x344
data[o14+0x01:o14+0x05] = struct.pack('<I', 720)
data[o14+0x06:o14+0x0a] = struct.pack('<I', 720)
data[o14+0x0b:o14+0x0f] = struct.pack('<f', 0.703125)
data[o14+0x10:o14+0x14] = struct.pack('<I', 720)
data[o14+0x15:o14+0x19] = struct.pack('<I', 720)
data[o14+0x1c:o14+0x20] = struct.pack('<f', 0.703125)

with open(exe_path, 'wb') as f:
    f.write(data)

print('SBH patched: slot 13=640x480, slot 14=720x720')
