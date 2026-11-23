#!/usr/bin/env python3
r"""bWare 'COMP' decompressor -- the .LZC container used throughout ZZDATA.BIN.

Ported 1:1 from `LZDecompress(unsigned char *, unsigned char *)` at
0x001aa460 in NFSHP2.ELF. Note this is **not** JDLZ: NFSU2/most later EA
Black Box titles use JDLZ, but HP2 predates it and ships its own LZSS in
`LZCompress.obj`.

Header (16 bytes, little-endian):

    0x00  u32  magic  'COMP' (0x504d4f43)
    0x04  u16  version         (0x1001 in every HP2 file)
    0x06  u16  method          1 = stored, anything else = LZSS below
    0x08  u32  uncompressed size
    0x0c  u32  total file size (header + payload)

Payload is LZSS with 16-bit control words, LSB-first:

    bit 0 -> copy one literal byte
    bit 1 -> two bytes b0,b1:
                 distance = ((b0 & 0xf0) << 4) | b1     (1..4095, backwards)
                 length   = 3 + (b0 & 0x0f)             (3..18)

The 16 control bits are read as `b0 | b1 << 8` with an extra sentinel bit at
position 16, so the shift register hits exactly 1 after 16 tokens and the
outer loop knows to refill.

Usage:
    python tools/lzdecompress.py <in.LZC> <out.BIN>
"""
import struct
import sys
from pathlib import Path

MAGIC = 0x504D4F43


def decompress(buf):
    """Decompress a whole 'COMP' file (header included); returns bytes."""
    if len(buf) < 16 or struct.unpack_from("<I", buf, 0)[0] != MAGIC:
        raise ValueError("not a COMP container")
    method, = struct.unpack_from("<H", buf, 6)
    out_size, total = struct.unpack_from("<II", buf, 8)
    if method == 1:
        return bytes(buf[16:total])

    end = total
    src = 16
    out = bytearray()
    ctrl = 1
    while src != end:
        if ctrl == 1:
            ctrl = buf[src] | 0x10000 | (buf[src + 1] << 8)
            src += 2
        # The engine only unrolls 16 tokens at a time while it is safely away
        # from the end of the payload; within the last 32 bytes it steps one
        # token at a time so a truncated final group cannot overrun.
        n = 16 if src <= end - 0x20 else 1
        for _ in range(n):
            if ctrl & 1:
                b0 = buf[src]
                b1 = buf[src + 1]
                src += 2
                dist = ((b0 & 0xF0) << 4) | b1
                length = 3 + (b0 & 0x0F)
                p = len(out) - dist
                for k in range(length):          # may overlap; byte-at-a-time
                    out.append(out[p + k])
            else:
                out.append(buf[src])
                src += 1
            ctrl >>= 1
    if len(out) != out_size:
        raise ValueError("COMP declared %d bytes, produced %d" % (out_size, len(out)))
    return bytes(out)


def main():
    if len(sys.argv) != 3:
        print("usage: lzdecompress.py <in.LZC> <out.BIN>", file=sys.stderr)
        raise SystemExit(2)
    data = decompress(Path(sys.argv[1]).read_bytes())
    Path(sys.argv[2]).write_bytes(data)
    print("wrote %d bytes" % len(data))


if __name__ == "__main__":
    main()
