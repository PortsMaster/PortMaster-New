"""Marks x86-64 IL-only .NET assemblies as ARM64.

The runtime refuses an assembly whose PE machine names another architecture, even when
it holds only IL. A 64-bit (PE32+) IL-only image without precompiled code runs the same
on either, so only the machine field changes. Already-retargeted files are left alone; the
exit status is 1 when any assembly cannot be retargeted.

    retarget.py ASSEMBLY...
"""
import struct
import sys

MACHINE_AMD64 = 0x8664
MACHINE_ARM64 = 0xAA64
PE32_PLUS = 0x20B
COMIMAGE_FLAGS_ILONLY = 0x1
CLI_HEADER_DIR = 14
DATA_DIR_START = 112
SECTION_HEADER_SIZE = 40
# Offset of ManagedNativeHeader within the CLI header.
MANAGED_NATIVE_HEADER = 64


def rva_to_offset(data, pe, rva):
    """Maps an RVA to a file offset through the section table; returns None if unmapped."""
    sections, opt_size = struct.unpack_from("<H12xH", data, pe + 6)
    table = pe + 24 + opt_size
    for i in range(sections):
        vsize, va, rsize, raw = struct.unpack_from("<IIII", data, table + i * SECTION_HEADER_SIZE + 8)
        if va <= rva < va + max(vsize, rsize):
            return rva - va + raw
    return None


def retarget(path):
    """Rewrites one assembly's machine field; returns (loads on ARM64, status line)."""
    with open(path, "r+b") as f:
        data = f.read()
        pe = struct.unpack_from("<I", data, 0x3C)[0]
        machine = struct.unpack_from("<H", data, pe + 4)[0]
        if machine == MACHINE_ARM64:
            return True, f"{path}: already ARM64"
        opt = pe + 24
        if machine != MACHINE_AMD64 or struct.unpack_from("<H", data, opt)[0] != PE32_PLUS:
            return False, f"{path}: not an x86-64 image, left as is"
        cli_rva = struct.unpack_from("<I", data, opt + DATA_DIR_START + CLI_HEADER_DIR * 8)[0]
        cli = rva_to_offset(data, pe, cli_rva) if cli_rva else None
        if cli is None:
            return False, f"{path}: no CLI header, left as is"
        flags = struct.unpack_from("<I", data, cli + 16)[0]
        native = struct.unpack_from("<I", data, cli + MANAGED_NATIVE_HEADER)[0]
        if not flags & COMIMAGE_FLAGS_ILONLY or native:
            return False, f"{path}: holds native code, left as is"
        f.seek(pe + 4)
        f.write(struct.pack("<H", MACHINE_ARM64))
    return True, f"{path}: retargeted to ARM64"


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    loadable = True
    for path in sys.argv[1:]:
        ok, status = retarget(path)
        print(status)
        loadable = loadable and ok
    sys.exit(0 if loadable else 1)


if __name__ == "__main__":
    main()
