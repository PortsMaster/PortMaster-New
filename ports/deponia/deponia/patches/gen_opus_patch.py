#!/usr/bin/env python3
"""Generate deponia_opus.patch for the Deponia 4.0.1386 Linux binary (GOG and Steam builds are identical).

1. Redirects the game's statically linked opus_multistream_* decoder API to the system libopus.so.0.
   Under box64 that library is wrapped, so Opus decoding runs as native aarch64 code.
   The stubs live in opus_multistream_decode_native, which is unreachable once its callers are redirected.
2. Disables opusfile's noise-shaping dither in op_float2short_filter (6-byte NOP), which is very slow emulated.

Output: one "fileoffset hexbytes" line per patched region.
Usage: gen_opus_patch.py Deponia > deponia_opus.patch
"""
import hashlib
import struct
import sys

ORIG_MD5 = "f432c959baa8bdbf225f54ceb19623e7"
TEXT_VA = 0x400000            # first PT_LOAD: file offset 0 maps to this address
GOT_DLOPEN = 0x11df158        # R_X86_64_JUMP_SLOT dlopen
GOT_DLSYM = 0x11df4f0         # R_X86_64_JUMP_SLOT dlsym
STUB_BASE = 0xd13630          # opus_multistream_decode_native, 0x47a bytes
STUB_LIMIT = STUB_BASE + 0x47a
DITHER_JE = 0x7fcb78          # je 0x7fcc40 (dither enabled path), 0f 84 c2 00 00 00

FUNCS = [  # (entry address, symbol name, entry size)
    (0xd13cf0, "opus_multistream_decoder_create", 0x120),
    (0xd14250, "opus_multistream_decoder_destroy", 0x5),
    (0xd13e70, "opus_multistream_decoder_ctl", 0x3d9),
    (0xd13e40, "opus_multistream_decode_float", 0x23),
    (0xd13e10, "opus_multistream_decode", 0x23),
]


def rel32(src_next, dst):
    return struct.pack("<i", dst - src_next)


def build():
    code = bytearray()
    va = lambda: STUB_BASE + len(code)
    fixups = []  # (position of rel32, label, address of next instruction)

    def emit(b):
        code.extend(b)

    def emit_rip(prefix, label, tail=b""):
        emit(prefix)
        pos = len(code)
        emit(b"\0\0\0\0")
        emit(tail)
        fixups.append((pos, label, STUB_BASE + pos + 4))

    labels = {"got_dlopen": GOT_DLOPEN, "got_dlsym": GOT_DLSYM}

    # common resolver, r11 = pointer to symbol name
    labels["common"] = va()
    emit(b"\x57\x56\x52\x51\x41\x50\x41\x51\x41\x53")        # push rdi,rsi,rdx,rcx,r8,r9,r11 (rsp 16-aligned)
    emit_rip(b"\x48\x8d\x3d", "libname")                     # lea rdi,[rip+libname]
    emit(b"\xbe\x02\x01\x00\x00")                            # mov esi,RTLD_NOW|RTLD_GLOBAL
    emit_rip(b"\xff\x15", "got_dlopen")                      # call [rip+got_dlopen]
    emit(b"\x48\x89\xc7")                                    # mov rdi,rax
    emit(b"\x48\x8b\x34\x24")                                # mov rsi,[rsp]
    emit_rip(b"\xff\x15", "got_dlsym")                       # call [rip+got_dlsym]
    emit(b"\x49\x89\xc3")                                    # mov r11,rax
    emit(b"\x58\x41\x59\x41\x58\x59\x5a\x5e\x5f")            # pop rax(saved r11),r9,r8,rcx,rdx,rsi,rdi
    emit(b"\x31\xc0")                                        # xor eax,eax (no vector varargs)
    emit(b"\x41\xff\xe3")                                    # jmp r11

    stubs = {}
    for addr, name, _ in FUNCS:
        stubs[name] = va()
        emit_rip(b"\x4c\x8d\x1d", "s_" + name)               # lea r11,[rip+name]
        emit(b"\xe9")                                        # jmp common
        pos = len(code)
        emit(b"\0\0\0\0")
        fixups.append((pos, "common", STUB_BASE + pos + 4))

    labels["libname"] = va()
    emit(b"libopus.so.0\0")
    for _, name, _ in FUNCS:
        labels["s_" + name] = va()
        emit(name.encode() + b"\0")

    assert va() <= STUB_LIMIT, "stubs do not fit"
    for pos, label, nxt in fixups:
        code[pos:pos + 4] = rel32(nxt, labels[label])

    patches = [(STUB_BASE, bytes(code))]
    for addr, name, size in FUNCS:
        assert size >= 5
        patches.append((addr, b"\xe9" + rel32(addr + 5, stubs[name])))
    patches.append((DITHER_JE, b"\x66\x0f\x1f\x44\x00\x00"))
    return patches


def main():
    data = bytearray(open(sys.argv[1], "rb").read())
    if hashlib.md5(data).hexdigest() != ORIG_MD5:
        sys.exit("unexpected Deponia binary (md5 mismatch)")
    assert data[DITHER_JE - TEXT_VA:DITHER_JE - TEXT_VA + 6] == bytes.fromhex("0f84c2000000")
    patches = build()
    for addr, blob in patches:
        off = addr - TEXT_VA
        data[off:off + len(blob)] = blob
        print(f"{off} {blob.hex()}")
    print(f"# patched md5 {hashlib.md5(data).hexdigest()}", file=sys.stderr)


if __name__ == "__main__":
    main()
