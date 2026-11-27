#!/usr/bin/env python3
"""Read a .NET for Android v2 AArch64 assembly store without loading its code."""

import argparse
import hashlib
from pathlib import Path
import re
import struct
import zipfile


MEMBER = "lib/arm64-v8a/libassemblies.arm64-v8a.blob.so"
STORE_VERSION = 0x80010002
STORE_HEADER = struct.Struct("<4s4I")
DESCRIPTOR = struct.Struct("<7I")
ELF_SECTION = struct.Struct("<IIQQQQIIQQ")
MAX_IMAGE = 32 * 1024 * 1024


def elf_payload(elf):
    if elf[:6] != b"\x7fELF\x02\x01" or struct.unpack_from("<H", elf, 18)[0] != 183:
        raise ValueError("Expected a little-endian AArch64 ELF assembly store")
    table, = struct.unpack_from("<Q", elf, 40)
    size, count, names_index = struct.unpack_from("<HHH", elf, 58)
    if size != ELF_SECTION.size or names_index >= count or table + size * count > len(elf):
        raise ValueError("Invalid ELF section table")
    sections = [ELF_SECTION.unpack_from(elf, table + index * size) for index in range(count)]
    _, _, _, _, offset, length, *_ = sections[names_index]
    names = elf[offset:offset + length]
    for name, _, _, _, offset, length, *_ in sections:
        if names[name:name + 8] == b"payload\0":
            if offset + length > len(elf):
                raise ValueError("Assembly store payload extends past the ELF")
            return elf[offset:offset + length]
    raise ValueError("Assembly store payload section is missing")


def lz4_block(data, expected):
    if not 0 < expected <= MAX_IMAGE:
        raise ValueError("Unsupported uncompressed assembly size")
    output = bytearray()
    cursor = 0

    def length(initial):
        nonlocal cursor
        if initial == 15:
            while True:
                if cursor >= len(data):
                    raise ValueError("Truncated LZ4 length")
                value = data[cursor]
                cursor += 1
                initial += value
                if value != 255:
                    break
        return initial

    while cursor < len(data):
        token = data[cursor]
        cursor += 1
        literals = length(token >> 4)
        if cursor + literals > len(data) or len(output) + literals > expected:
            raise ValueError("LZ4 literals exceed assembly bounds")
        output.extend(data[cursor:cursor + literals])
        cursor += literals
        if cursor == len(data):
            break
        if cursor + 2 > len(data):
            raise ValueError("Truncated LZ4 offset")
        distance, = struct.unpack_from("<H", data, cursor)
        cursor += 2
        amount = length(token & 15) + 4
        if not 0 < distance <= len(output) or len(output) + amount > expected:
            raise ValueError("LZ4 match exceeds assembly bounds")
        chunk = output[-distance:]
        output.extend((chunk * ((amount + distance - 1) // distance))[:amount])
    if len(output) != expected:
        raise ValueError("Incorrect decompressed assembly size")
    return bytes(output)


def assemblies(elf):
    payload = elf_payload(elf)
    magic, version, count, indexes, index_size = STORE_HEADER.unpack_from(payload)
    if magic != b"XABA" or version != STORE_VERSION or not 0 < count < 512:
        raise ValueError("Unsupported Android assembly store format")
    if indexes != count * 2 or index_size != indexes * 12:
        raise ValueError("Invalid Android assembly store index")
    descriptor_start = STORE_HEADER.size + index_size
    names = descriptor_start + count * DESCRIPTOR.size
    descriptors = []
    seen = set()
    for index in range(count):
        mapping, start, size, *_ = DESCRIPTOR.unpack_from(payload, descriptor_start + index * DESCRIPTOR.size)
        length, = struct.unpack_from("<I", payload, names)
        names += 4
        name = payload[names:names + length].decode("utf-8")
        names += length
        if not re.fullmatch(r"[A-Za-z0-9_.-]+\.dll", name) or name.casefold() in seen:
            raise ValueError("Unsafe or duplicate assembly name: " + name)
        seen.add(name.casefold())
        if not 0 < size <= MAX_IMAGE or start + size > len(payload):
            raise ValueError("Invalid assembly bounds: " + name)
        descriptors.append((name, mapping, start, size))
    for name, mapping, start, size in descriptors:
        if start < names:
            raise ValueError("Assembly overlaps its descriptor table: " + name)
        image = payload[start:start + size]
        if image.startswith(b"XALZ"):
            compressed_mapping, expected = struct.unpack_from("<II", image, 4)
            if compressed_mapping != mapping:
                raise ValueError("Compressed mapping index differs for " + name)
            image = lz4_block(image[12:], expected)
        if not image.startswith(b"MZ"):
            raise ValueError("Assembly does not contain a managed PE: " + name)
        yield name, image


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    parser.add_argument("--output", type=Path, help="Directory for diagnostic assembly copies")
    args = parser.parse_args()
    with zipfile.ZipFile(args.apk) as apk:
        for name, image in assemblies(apk.read(MEMBER)):
            print(hashlib.sha256(image).hexdigest(), len(image), name)
            if args.output:
                args.output.mkdir(parents=True, exist_ok=True)
                (args.output / name).write_bytes(image)


if __name__ == "__main__":
    main()
