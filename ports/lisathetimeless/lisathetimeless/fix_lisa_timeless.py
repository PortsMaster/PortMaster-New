#!/usr/bin/env python3
"""
fix_lisa_timeless.py
---------------------
Patches LISA The Timeless's Game.rgss3a to fix a FrozenError crash
("can't modify frozen NilClass: nil") that occurs in falcon-mkxp's
rgss_main implementation.

Root cause: falcon-mkxp invokes the RGSS3 main script block with `self`
bound to nil instead of the top-level `main` object. The stock Main
script does `@run ||= true` inside that block, which requires a valid
`self` to attach the instance variable to. With self == nil, Ruby
raises FrozenError instead of NoMethodError, because nil is a frozen
singleton.

Fix: rewrite script #187 ("Main") to use a global variable ($run)
instead of an instance variable (@run), since globals don't need a
receiver and are unaffected by what `self` is bound to.

This script is pure Python (stdlib only: struct, zlib) - no Ruby
required on the handheld device. It edits Game.rgss3a in place,
patching only the Scripts.rvdata2 entry. Every other file in the
archive is left byte-for-byte untouched.

Usage:
    python3 fix_lisa_timeless.py /path/to/lisathetimeless/gamedata/Game.rgss3a

If no path is given, it looks for Game.rgss3a in the current directory.
A backup (Game.rgss3a.bak) is created automatically before patching,
unless one already exists (so re-running is safe / idempotent).
"""

import os
import sys
import shutil
import struct
import zlib

MAIN_SCRIPT_NAME = "Main"

# The exact source we want script #187 to contain after patching.
# (Matches the original script's behavior, just self-independent.)
FIXED_MAIN_SOURCE = (
    "#==============================================================================\r\n"
    "# ** Main\r\n"
    "#------------------------------------------------------------------------------\r\n"
    "#  This processing is executed after module and class definition is finished.\r\n"
    "#  PATCHED by fix_lisa_timeless.py: uses $run (global) instead of @run\r\n"
    "#  (instance var) because falcon-mkxp's rgss_main runs this block with\r\n"
    "#  self == nil, and @run ||= true raises FrozenError in that context.\r\n"
    "#==============================================================================\r\n"
    "\r\n"
    "$run ||= false\r\n"
    "\r\n"
    "rgss_main {\r\n"
    "Light_Bitcore.dispose if $run;\r\n"
    "Light_Bitcore.initialize;\r\n"
    "$run = true;\r\n"
    "SceneManager.run }"
)


# ---------------------------------------------------------------------------
# RGSS3a v3 archive format (reverse-engineered from falcon-mkxp's rgssad.cpp)
# ---------------------------------------------------------------------------
#
# Header: 8 bytes magic "RGSSAD\x00\x03", then a 4-byte LE master key.
# Directory key = (master_key * 9 + 3) & 0xFFFFFFFF, FIXED for the whole
# directory (it does not roll between entries).
#
# Each directory entry:
#   u32 offset        (XOR'd with directory key)
#   u32 size          (XOR'd with directory key)
#   u32 file_key       (XOR'd with directory key) - per-file decrypt key
#   u32 namelen        (XOR'd with directory key)
#   name bytes         (each byte XOR'd with (dir_key >> ((i%4)*8)) & 0xFF;
#                        0x5c '\' is then mapped to 0x2f '/')
# Directory ends at the first entry whose decrypted offset == 0.
#
# File data decryption: read 4-byte blocks; each block XOR'd with the
# *current* per-file key, which is then advanced as key = key*7+3 before
# the next block. Any trailing 1-3 bytes use one more key advance and are
# XOR'd byte-by-byte with the resulting key's bytes.


def advance7(key):
    """advanceMagic(): returns (old_key, new_key) where new_key = old*7+3."""
    old = key
    return old, (old * 7 + 3) & 0xFFFFFFFF


def parse_directory(raw):
    """Parse the RGSS3a directory. `raw` must contain at least the header
    and the whole directory (a few hundred KB is always plenty)."""
    if raw[:7] != b"RGSSAD\x00":
        raise ValueError("Not an RGSSAD archive (bad magic)")
    init_key = struct.unpack("<I", raw[8:12])[0]
    key = (init_key * 9 + 3) & 0xFFFFFFFF
    kb = struct.pack("<I", key)

    pos = 12
    entries = []
    while pos + 16 <= len(raw):
        raw_off, raw_sz, raw_ek, raw_nl = struct.unpack("<4I", raw[pos:pos + 16])
        offset = raw_off ^ key
        size = raw_sz ^ key
        file_key = raw_ek ^ key
        namelen = raw_nl ^ key

        if offset == 0:
            break
        if not (0 < namelen <= 500):
            break

        name_raw = raw[pos + 16:pos + 16 + namelen]
        name_bytes = bytearray()
        for i, b in enumerate(name_raw):
            nb = b ^ kb[i % 4]
            if nb == 0x5C:  # backslash -> forward slash
                nb = 0x2F
            name_bytes.append(nb)

        entries.append({
            "name": name_bytes.decode("utf-8", errors="replace"),
            "offset": offset,
            "size": size,
            "key": file_key,
            "dir_pos": pos,       # position of this entry's 16-byte header in `raw`
        })
        pos += 16 + namelen

    return entries, key  # also return the fixed directory key for re-encoding


def decrypt_block_cipher(enc_bytes, file_key):
    """Symmetric XOR-with-rolling-key cipher used for RGSS3a file contents.
    Works identically for encryption and decryption (pure XOR)."""
    key = file_key
    out = bytearray()
    n_full = len(enc_bytes) // 4
    for i in range(n_full):
        block = struct.unpack("<I", enc_bytes[i * 4:i * 4 + 4])[0]
        k, key = advance7(key)
        out.extend(struct.pack("<I", block ^ k))
    rem = len(enc_bytes) - n_full * 4
    if rem:
        k, key = advance7(key)
        kb = struct.pack("<I", k)
        for j in range(rem):
            out.append(enc_bytes[n_full * 4 + j] ^ kb[j])
    return bytes(out)


def read_file_from_archive(path, entry):
    with open(path, "rb") as f:
        f.seek(entry["offset"])
        enc = f.read(entry["size"])
    return decrypt_block_cipher(enc, entry["key"])


# ---------------------------------------------------------------------------
# Minimal Marshal(4.8) splicer for the Scripts.rvdata2 array.
#
# Scripts.rvdata2 is `Marshal.dump([[id, name, zlib_compressed_code], ...])`.
# We don't need a general Marshal codec - just enough to walk the array of
# 3-element entries and locate/replace one entry's compressed-code string.
# ---------------------------------------------------------------------------

def _decode_fixnum(data, pos):
    b = data[pos]
    pos += 1
    if b == 0:
        return 0, pos
    elif 1 <= b <= 4:
        return int.from_bytes(data[pos:pos + b], "little"), pos + b
    elif 5 <= b <= 127:
        return b - 5, pos
    elif 0xFC <= b <= 0xFF:
        nbytes = 256 - b
        val = int.from_bytes(data[pos:pos + nbytes], "little")
        return val - (1 << (8 * nbytes)), pos + nbytes
    else:
        raise ValueError(f"Unhandled Marshal fixnum lead byte {b:#x} at {pos - 1}")


def _encode_fixnum(val):
    if val == 0:
        return bytes([0])
    elif 0 < val <= 122:
        return bytes([val + 5])
    elif -123 <= val < 0:
        return bytes([(val - 5) & 0xFF])
    elif val > 0:
        nbytes = max(1, (val.bit_length() + 7) // 8)
        return bytes([nbytes]) + val.to_bytes(nbytes, "little")
    else:
        nbytes = 4
        return bytes([256 - nbytes]) + (val & 0xFFFFFFFF).to_bytes(nbytes, "little")


def _parse_maybe_wrapped_string(data, pos):
    """Parses a Marshal string that may be wrapped in an 'I' (instance-var,
    i.e. carries an :E encoding flag) container. Returns metadata dict."""
    is_wrapped = False
    if data[pos] == 0x49:  # 'I'
        is_wrapped = True
        pos += 1
    if data[pos] != 0x22:  # '"'
        raise ValueError(f"Expected string tag at {pos}, got {data[pos]:#x}")
    pos += 1
    slen, pos = _decode_fixnum(data, pos)
    str_data_start = pos
    pos += slen
    if is_wrapped:
        ivcount, pos = _decode_fixnum(data, pos)
        for _ in range(ivcount):
            tag = data[pos]; pos += 1
            if tag == 0x3A:       # ':' new symbol
                slen2, pos = _decode_fixnum(data, pos)
                pos += slen2
            elif tag == 0x3B:     # ';' symlink
                _, pos = _decode_fixnum(data, pos)
            else:
                raise ValueError(f"Unexpected ivar key tag {tag:#x} at {pos - 1}")
            vtag = data[pos]; pos += 1  # 'T'/'F' (true/false), no payload
            if vtag not in (0x54, 0x46):
                raise ValueError(f"Unexpected ivar value tag {vtag:#x} at {pos - 1}")
    return {"str_data_start": str_data_start, "str_len": slen, "end": pos}


def patch_scripts_marshal(scripts_data, target_index, new_source_code):
    """Given the raw decrypted Scripts.rvdata2 bytes, replace the compressed
    code blob of the entry at `target_index` with zlib.compress(new_source_code),
    re-encoding only the length prefix that changed. Returns new bytes."""
    data = scripts_data
    if data[:2] != b"\x04\x08":
        raise ValueError("Not a Marshal 4.8 stream")
    pos = 2
    if data[pos] != 0x5B:  # Array
        raise ValueError("Expected top-level Array in Scripts.rvdata2")
    pos += 1
    arr_len, pos = _decode_fixnum(data, pos)

    if not (0 <= target_index < arr_len):
        raise IndexError(f"target_index {target_index} out of range (0..{arr_len - 1})")

    out = bytearray(data[:pos])  # header + array length, copied verbatim

    for idx in range(arr_len):
        if data[pos] != 0x5B:
            raise ValueError(f"Expected nested Array at entry {idx}, pos {pos}")
        out += data[pos:pos + 1]
        pos += 1

        triplet_len, new_pos = _decode_fixnum(data, pos)
        if triplet_len != 3:
            raise ValueError(f"Expected 3-tuple at entry {idx}, got length {triplet_len}")
        out += _encode_fixnum(triplet_len)
        pos = new_pos

        if data[pos] != 0x69:  # Integer
            raise ValueError(f"Expected Integer id at entry {idx}, pos {pos}")
        out += data[pos:pos + 1]
        pos += 1
        id_val, new_pos = _decode_fixnum(data, pos)
        out += _encode_fixnum(id_val)
        pos = new_pos

        name_info = _parse_maybe_wrapped_string(data, pos)
        out += data[pos:name_info["end"]]  # name field copied verbatim
        pos = name_info["end"]

        blob_info = _parse_maybe_wrapped_string(data, pos)

        if idx == target_index:
            # Replace the compressed-code blob's string contents.
            new_compressed = zlib.compress(new_source_code.encode("utf-8"))
            # Re-emit: same wrapper structure (we know the original isn't
            # encoding-wrapped for binary zlib blobs in this file - verified
            # empirically), just a new length + new bytes.
            wrapper_start = pos
            # Detect if it WAS wrapped, to preserve that structure exactly.
            was_wrapped = data[wrapper_start] == 0x49
            if was_wrapped:
                out += bytes([0x49])  # 'I'
            out += bytes([0x22])      # '"'
            out += _encode_fixnum(len(new_compressed))
            out += new_compressed
            if was_wrapped:
                # Re-copy the original ivar suffix (encoding flag etc.) verbatim -
                # it's a fixed few bytes after the original string data.
                orig_str_end = blob_info["str_data_start"] + blob_info["str_len"]
                out += data[orig_str_end:blob_info["end"]]
        else:
            out += data[pos:blob_info["end"]]

        pos = blob_info["end"]

    if pos != len(data):
        raise ValueError(
            f"Marshal walk did not consume the whole buffer "
            f"({pos} consumed, {len(data)} total) - format assumption mismatch"
        )

    return bytes(out)


def find_main_script_index(scripts_data):
    """Find the array index of the script named 'Main' by walking the
    Marshal structure (without fully decompressing every entry)."""
    data = scripts_data
    pos = 2
    assert data[pos] == 0x5B
    pos += 1
    arr_len, pos = _decode_fixnum(data, pos)

    for idx in range(arr_len):
        assert data[pos] == 0x5B
        pos += 1
        triplet_len, pos = _decode_fixnum(data, pos)
        assert triplet_len == 3

        assert data[pos] == 0x69
        pos += 1
        _id_val, pos = _decode_fixnum(data, pos)

        name_info = _parse_maybe_wrapped_string(data, pos)
        name_bytes = data[name_info["str_data_start"]:
                           name_info["str_data_start"] + name_info["str_len"]]
        name_str = name_bytes.decode("utf-8", errors="replace")
        pos = name_info["end"]

        blob_info = _parse_maybe_wrapped_string(data, pos)
        pos = blob_info["end"]

        if name_str == MAIN_SCRIPT_NAME:
            return idx

    return None


# ---------------------------------------------------------------------------
# Archive-level patch: re-encrypt the new Scripts.rvdata2 and append it to
# the .rgss3a file, then update the directory entry to point at it. All
# other files in the archive are left completely untouched.
# ---------------------------------------------------------------------------

def patch_archive(rgss3a_path):
    with open(rgss3a_path, "rb") as f:
        full = f.read()

    # The directory is always near the start; reading a generous slice is
    # enough (a few hundred KB easily covers thousands of entries).
    dir_slice = full[:max(300_000, min(len(full), 2_000_000))]
    entries, dir_key = parse_directory(dir_slice)

    scripts_entry = next((e for e in entries if e["name"] == "Data/Scripts.rvdata2"), None)
    if scripts_entry is None:
        raise RuntimeError("Could not find Data/Scripts.rvdata2 in the archive directory")

    scripts_plain = read_file_from_archive(rgss3a_path, scripts_entry)

    main_idx = find_main_script_index(scripts_plain)
    if main_idx is None:
        raise RuntimeError("Could not find a script named 'Main' inside Scripts.rvdata2")

    # Check whether it's already patched (idempotency).
    # Quick heuristic: decompress just that entry's blob and look for our marker.
    already_patched = _entry_source_contains(scripts_plain, main_idx, "fix_lisa_timeless.py")
    if already_patched:
        print("Main script already contains the patch marker - nothing to do.")
        return False

    new_scripts_plain = patch_scripts_marshal(scripts_plain, main_idx, FIXED_MAIN_SOURCE)

    # Re-encrypt with the SAME per-file key (cipher is pure XOR, symmetric).
    new_scripts_enc = decrypt_block_cipher(new_scripts_plain, scripts_entry["key"])

    # Sanity round-trip check before touching the file on disk.
    roundtrip = decrypt_block_cipher(new_scripts_enc, scripts_entry["key"])
    if roundtrip != new_scripts_plain:
        raise RuntimeError("Internal error: re-encryption round-trip check failed")

    new_offset = len(full)
    new_size = len(new_scripts_enc)

    # Append the new encrypted Scripts.rvdata2 at the end of the file.
    with open(rgss3a_path, "ab") as f:
        f.write(new_scripts_enc)

    # Patch the directory entry's offset/size fields in place.
    new_raw_off = new_offset ^ dir_key
    new_raw_sz = new_size ^ dir_key
    with open(rgss3a_path, "r+b") as f:
        f.seek(scripts_entry["dir_pos"])
        f.write(struct.pack("<I", new_raw_off))
        f.write(struct.pack("<I", new_raw_sz))

    return True


def _entry_source_contains(scripts_plain, idx, needle):
    """Decompress one entry's code blob (by index) and check for `needle`."""
    data = scripts_plain
    pos = 2
    pos += 1
    arr_len, pos = _decode_fixnum(data, pos)
    for i in range(arr_len):
        pos += 1  # '['
        triplet_len, pos = _decode_fixnum(data, pos)
        pos += 1  # 'i'
        _id_val, pos = _decode_fixnum(data, pos)
        name_info = _parse_maybe_wrapped_string(data, pos)
        pos = name_info["end"]
        blob_info = _parse_maybe_wrapped_string(data, pos)
        if i == idx:
            blob = data[blob_info["str_data_start"]:
                        blob_info["str_data_start"] + blob_info["str_len"]]
            try:
                code = zlib.decompress(blob).decode("utf-8", errors="replace")
            except zlib.error:
                return False
            return needle in code
        pos = blob_info["end"]
    return False


def main():
    if len(sys.argv) > 1:
        target = sys.argv[1]
    else:
        # Look in the current directory, and a couple of common PortMaster
        # locations, for convenience.
        candidates = [
            "Game.rgss3a",
            os.path.join("gamedata", "Game.rgss3a"),
            os.path.join("lisathetimeless", "gamedata", "Game.rgss3a"),
        ]
        target = next((c for c in candidates if os.path.isfile(c)), None)
        if target is None:
            print("Usage: python3 fix_lisa_timeless.py /path/to/Game.rgss3a")
            print("(No Game.rgss3a found automatically in the expected locations.)")
            sys.exit(1)

    target = os.path.abspath(target)
    if not os.path.isfile(target):
        print(f"File not found: {target}")
        sys.exit(1)

    backup = target + ".bak"
    if not os.path.exists(backup):
        print(f"Backing up original to: {backup}")
        shutil.copy2(target, backup)
    else:
        print(f"Backup already exists at {backup} (not overwriting).")

    print(f"Patching: {target}")
    try:
        changed = patch_archive(target)
    except Exception as e:
        print(f"FAILED: {e}")
        print("The original file was not modified beyond what's in this run; "
              f"restore from {backup} if needed.")
        sys.exit(1)

    if changed:
        print("Done. Script #Main now uses $run instead of @run.")
        print("You can launch the game normally now.")
    else:
        print("No changes were needed.")


if __name__ == "__main__":
    main()
