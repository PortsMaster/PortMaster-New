"""Inspect and repack standalone MonoGame Android XNB textures."""

import ctypes
import struct

from assembly_store import lz4_block


ASTC_BLOCKS = (
    (4, 4), (5, 4), (5, 5), (6, 5), (6, 6), (8, 5), (8, 6),
    (8, 8), (10, 5), (10, 6), (10, 8), (10, 10), (12, 10), (12, 12),
)
ASTC_FORMAT = 96
ANDROID_ASTC = {96: 4, 97: 5, 98: 6, 102: 4}
TEXTURE_READER = b"Microsoft.Xna.Framework.Content.Texture2DReader"
MAX_RGBA = 64 * 1024 * 1024


def read_int7(data, offset):
    result = 0
    for shift in range(0, 35, 7):
        value = data[offset]
        offset += 1
        result |= (value & 0x7f) << shift
        if value < 0x80:
            return result, offset
    raise ValueError("Invalid XNB variable-length integer")


def read_texture(raw, decompress=lz4_block):
    if len(raw) < 10 or raw[:4] != b"XNBa" or raw[5] & 0x80:
        return None
    if struct.unpack_from("<I", raw, 6)[0] != len(raw):
        raise ValueError("XNB length does not match its header")
    if raw[5] & 0x40:
        body = decompress(raw[14:], struct.unpack_from("<I", raw, 10)[0])
    else:
        body = raw[10:]
    count, offset = read_int7(body, 0)
    if not 0 < count <= 256:
        raise ValueError("Invalid XNB reader table")
    readers = []
    for _ in range(count):
        length, offset = read_int7(body, offset)
        readers.append(body[offset:offset + length].split(b",", 1)[0])
        offset += length + 4
    shared, offset = read_int7(body, offset)
    primary, offset = read_int7(body, offset)
    if shared or not 0 < primary <= len(readers) or readers[primary - 1] != TEXTURE_READER:
        return None
    fmt, width, height, levels = struct.unpack_from("<4I", body, offset)
    if not (width and height and levels and width * height * 4 <= MAX_RGBA):
        raise ValueError("Unsupported texture dimensions")
    head = body[:offset]
    offset += 16
    mips = []
    for _ in range(levels):
        size, = struct.unpack_from("<I", body, offset)
        offset += 4
        if not size or offset + size > len(body):
            raise ValueError("Invalid XNB mip length")
        mips.append(body[offset:offset + size])
        offset += size
    if offset != len(body):
        raise ValueError("Trailing data in a standalone texture")
    return head, fmt, width, height, mips


def astc_size(width, height, bx, by):
    return ((width + bx - 1) // bx) * ((height + by - 1) // by) * 16


def software_footprint(width, height, requested):
    # The shipped GLES fallback derives the footprint from the first mip's
    # byte count. Only write a footprint it can resolve without ambiguity.
    for block in range(requested, 3, -1):
        size = astc_size(width, height, block, block)
        inferred = next((candidate for candidate in ASTC_BLOCKS
                         if astc_size(width, height, *candidate) == size), None)
        if inferred == (block, block):
            return block
    raise AssertionError("ASTC 4x4 must be the first size candidate")


class TextureCodec:
    def __init__(self, library):
        self.library = ctypes.CDLL(str(library))
        self.transcode = self.library.repack_astc
        self.transcode.argtypes = [
            ctypes.c_char_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_uint,
            ctypes.c_uint, ctypes.c_uint, ctypes.c_uint, ctypes.c_void_p, ctypes.c_size_t,
        ]
        self.transcode.restype = ctypes.c_int
        self.inflate = self.library.LZ4_decompress_safe
        self.deflate = self.library.LZ4_compress_default
        for function in (self.inflate, self.deflate):
            function.argtypes = [ctypes.c_char_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
            function.restype = ctypes.c_int

    def decompress(self, data, size):
        if not 0 < size <= MAX_RGBA:
            raise ValueError("Unsupported decompressed XNB length")
        result = ctypes.create_string_buffer(size)
        if self.inflate(data, result, len(data), size) != size:
            raise ValueError("Invalid LZ4 XNB payload")
        return result.raw

    def write_xnb(self, raw, body):
        payload = bytes(body)
        # This buffer also covers the LZ4 expansion bound.
        result = ctypes.create_string_buffer(len(payload) + len(payload) // 255 + 16)
        size = self.deflate(payload, result, len(payload), len(result))
        if size and size + 14 < len(payload) + 10:
            return (raw[:5] + bytes([raw[5] | 0x40])
                    + struct.pack("<II", size + 14, len(payload)) + result.raw[:size])
        return raw[:5] + bytes([raw[5] & ~0x40]) + struct.pack("<I", len(payload) + 10) + payload

    def repack(self, name, raw):
        texture = read_texture(raw, self.decompress)
        if texture is None:
            return raw, None
        head, fmt, width, height, mips = texture
        if fmt not in ANDROID_ASTC:
            # The APK stores the original retro sprites in RGBA. Keep those
            # palette colors byte-exact and transcode the ASTC textures only.
            return raw, None
        original = ANDROID_ASTC[fmt]
        destination = software_footprint(width, height, original)
        sizes = []
        for level, mip in enumerate(mips):
            w, h = max(width >> level, 1), max(height >> level, 1)
            expected = astc_size(w, h, original, original)
            if len(mip) != expected:
                raise ValueError(f"{name} has a texture payload inconsistent with format {fmt}")
            sizes.append((w, h, astc_size(w, h, destination, destination)))
        desktop_format = ASTC_FORMAT + ASTC_BLOCKS.index((destination, destination))
        if original == destination and fmt == desktop_format:
            return raw, destination
        body = bytearray(head)
        body.extend(struct.pack("<4I", desktop_format, width, height, len(mips)))
        for mip, (w, h, size) in zip(mips, sizes):
            body.extend(struct.pack("<I", size))
            if original == destination:
                body.extend(mip)
                continue
            output = ctypes.create_string_buffer(size)
            result = self.transcode(mip, len(mip), w, h, original, original,
                                    destination, output, size)
            if result:
                raise ValueError(f"ASTC encoder error {result} for {name}")
            body.extend(output.raw)
        return self.write_xnb(raw, body), destination
