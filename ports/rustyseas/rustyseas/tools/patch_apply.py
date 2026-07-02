#!/usr/bin/env python3
"""
Applies a .rspatch byte-patch to data.win and writes the result as game.droid.
Format: magic(4) + count(4) + [offset(4) + new_byte(1)] * count
"""
import struct
import sys


def apply_patch(src_path, patch_path, out_path):
    with open(patch_path, 'rb') as f:
        magic = f.read(4)
        if magic != b'RSPX':
            print(f"ERROR: invalid patch file (bad magic: {magic})", file=sys.stderr)
            return False
        count = struct.unpack('<I', f.read(4))[0]
        changes = [struct.unpack('<IB', f.read(5)) for _ in range(count)]

    print(f"Reading {src_path} ...")
    with open(src_path, 'rb') as f:
        data = bytearray(f.read())

    print(f"Applying {count} byte changes ...")
    for offset, new_byte in changes:
        data[offset] = new_byte

    print(f"Writing {out_path} ...")
    with open(out_path, 'wb') as f:
        f.write(data)

    print("Done.")
    return True


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <data.win> <patch.rspatch> <game.droid>", file=sys.stderr)
        sys.exit(1)
    sys.exit(0 if apply_patch(sys.argv[1], sys.argv[2], sys.argv[3]) else 1)
