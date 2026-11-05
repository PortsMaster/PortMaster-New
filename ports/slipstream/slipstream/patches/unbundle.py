"""Extracts one file from a .NET single-file bundle.

A single-file app is a native host with its managed assemblies appended; the host finds
them through a header whose offset sits just before a fixed signature. This reads
bundle format 6 (.NET 6 to 8): a header, then one entry per file with offset, size,
compressed size (0 when stored), type and relative path. Compressed entries are raw
deflate.

    unbundle.py BUNDLE NAME OUT    e.g. unbundle.py gamedata/slipstream slipstream.dll x.dll
"""
import os
import struct
import sys
import zlib

SIGNATURE = bytes.fromhex("8b1202b96a612038727b930214d7a03213f5b9e6efae3318ee3b2dce24b36aae")
FORMAT = 6


def read_string(data, pos):
    """Reads a 7-bit length-prefixed UTF-8 string; returns (string, next position)."""
    length = shift = 0
    while True:
        byte = data[pos]
        pos += 1
        length |= (byte & 0x7F) << shift
        shift += 7
        if not byte & 0x80:
            break
    return data[pos:pos + length].decode(), pos + length


def entries(data):
    """Parses the bundle manifest; returns {path: (offset, size, compressed size)}."""
    sig = data.rfind(SIGNATURE)
    if sig < 8:
        sys.exit("not a .NET single-file bundle")
    pos = struct.unpack_from("<q", data, sig - 8)[0]
    major, _minor, count = struct.unpack_from("<IIi", data, pos)
    if major != FORMAT:
        sys.exit(f"bundle format {major}, expected {FORMAT}")
    _bundle_id, pos = read_string(data, pos + 12)
    # deps.json and runtimeconfig.json locations, then flags
    pos += struct.calcsize("<qqqqQ")
    found = {}
    for _ in range(count):
        offset, size, csize = struct.unpack_from("<qqq", data, pos)
        # The type byte follows the three sizes.
        path, pos = read_string(data, pos + struct.calcsize("<qqqB"))
        found[path] = (offset, size, csize)
    return found


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    bundle, name, out = sys.argv[1:]
    with open(bundle, "rb") as f:
        data = f.read()
    files = entries(data)
    if name not in files:
        sys.exit(f"{name} is not in {bundle}")
    offset, size, csize = files[name]
    blob = data[offset:offset + (csize or size)]
    if csize:
        blob = zlib.decompress(blob, -zlib.MAX_WBITS)
    if len(blob) != size:
        sys.exit(f"{name}: {len(blob)} bytes, manifest says {size}")
    with open(out + ".tmp", "wb") as f:
        f.write(blob)
    os.replace(out + ".tmp", out)
    print(f"{name}: {size} bytes from {bundle}")


if __name__ == "__main__":
    main()
