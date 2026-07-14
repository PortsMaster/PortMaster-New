#!/usr/bin/env python3
"""Validate the exact Bully 1.4.311 library and its indexed data archives."""

import hashlib
import os
import struct
import sys
import time
import zipfile
from pathlib import Path


LIBGAME_MD5 = "47468f5ce23ad05dc2a855b2801133b5"
LIBGAME_BUILD_ID = "6139a628aa7a260dd7bf443665bb822a459d5ba1"
LIBCXX_SHA256 = "83269b3124a287fac36b17c9fb64beb398c83dad6677b19ce63cf80d09966fd7"
EXPECTED_COUNTS = (549, 407, 823, 2003, 26427)
EXPECTED_ZIP_SIZES = (175603992, 864079869, 536975677, 537122756, 774609572)
EXPECTED_IDX_SHA256 = (
    "357efd8fb79743807eecc1f4e451d13c5905b7fc6d05a273caa04ed0b5e05dcf",
    "7a7163f4a35633673aabf1a925582c6ac7de0b02380d9c070a57fc57107c8da2",
    "20b1deaf1a52ca09eb3cd672d29ee595ee4060642eeeffb6984788f9db21abd2",
    "47301aa41c4c18c206e3b7e1562de05c7fe43186a015f0b9a845fd6bff9138b2",
    "b25fe73bae7fac402ecbd0bb9f3c7b22444f7aff41104ab7a7977479e64db49d",
)

PROGRESS_CHUNK_SIZE = 1024 * 1024
PROGRESS_MIN_INTERVAL = 0.10


def fail(message):
    raise SystemExit("validation failed: %s" % message)


def env_int(name, default):
    try:
        return int(os.environ.get(name, str(default)))
    except ValueError:
        return default


class SetupProgressReporter:
    """Best-effort UI updates; validation never depends on this side channel."""

    def __init__(self):
        self.path = os.environ.get("BULLY_SETUP_PROGRESS_FILE", "")
        self.phase = max(0, min(8, env_int("BULLY_SETUP_PHASE", 2)))
        self.base = max(0, min(1000, env_int("BULLY_VALIDATION_BASE", 0)))
        self.span = max(0, min(1000 - self.base, env_int("BULLY_VALIDATION_SPAN", 1000)))
        self.extraction = max(0, min(1000, env_int("BULLY_EXTRACTION_PERMILLE", 0)))
        message = os.environ.get("BULLY_SETUP_MESSAGE", "VALIDATING DATA")
        self.message = " ".join(message.replace("\r", " ").replace("\n", " ").split())
        self.last_value = -1
        self.last_write = 0.0
        self.disabled = not self.path

    def update(self, done, total, force=False):
        if self.disabled:
            return
        if total <= 0:
            value = self.base + (self.span if force else 0)
        else:
            done = max(0, min(done, total))
            value = self.base + self.span * done // total
        value = max(0, min(1000, value))

        now = time.monotonic()
        if not force and value == self.last_value:
            return
        if not force and self.last_write and now - self.last_write < PROGRESS_MIN_INTERVAL:
            return

        tmp = "%s.py.%d" % (self.path, os.getpid())
        try:
            with open(tmp, "w", encoding="utf-8") as stream:
                stream.write("1 %d 1000\n" % value)
                stream.write("%s\n" % (self.message or "VALIDATING DATA"))
                stream.write(
                    "BULLY_SETUP_V2 %d %d %d\n"
                    % (self.phase, value, self.extraction)
                )
            os.replace(tmp, self.path)
        except OSError:
            try:
                os.unlink(tmp)
            except OSError:
                pass
            self.disabled = True
            return
        self.last_value = value
        self.last_write = now


def validate_archive_crc(path, announce=True):
    archive_path = Path(path)
    reporter = SetupProgressReporter()
    done = 0
    try:
        with zipfile.ZipFile(archive_path, "r") as archive:
            members = [info for info in archive.infolist() if not info.is_dir()]
            total = sum(info.file_size for info in members)
            reporter.update(0, total, force=True)
            for info in members:
                with archive.open(info, "r") as source:
                    while True:
                        chunk = source.read(PROGRESS_CHUNK_SIZE)
                        if not chunk:
                            break
                        done += len(chunk)
                        reporter.update(done, total)
            reporter.update(total, total, force=True)
    except (OSError, zipfile.BadZipFile, RuntimeError, NotImplementedError) as error:
        fail("%s ZIP test failed: %s" % (archive_path.name, error))
    if announce:
        print("%s ZIP CRC OK size=%d" % (archive_path.name, archive_path.stat().st_size))


def elf_build_id(data):
    if len(data) < 64 or data[:4] != b"\x7fELF":
        fail("libGame.so is not an ELF file")
    if data[4] != 2 or data[5] != 1:
        fail("libGame.so is not little-endian ELF64")
    if struct.unpack_from("<H", data, 18)[0] != 183:
        fail("libGame.so is not AArch64")

    phoff = struct.unpack_from("<Q", data, 32)[0]
    phentsize = struct.unpack_from("<H", data, 54)[0]
    phnum = struct.unpack_from("<H", data, 56)[0]
    if phentsize < 56 or phnum > 1024:
        fail("invalid ELF program-header table")

    for index in range(phnum):
        pos = phoff + index * phentsize
        if pos + 56 > len(data):
            fail("truncated ELF program-header table")
        p_type, _flags, p_offset, _vaddr, _paddr, p_filesz, _memsz, _align = (
            struct.unpack_from("<IIQQQQQQ", data, pos)
        )
        if p_type != 4:  # PT_NOTE
            continue
        end = p_offset + p_filesz
        if end > len(data):
            fail("truncated ELF note segment")
        note = p_offset
        while note + 12 <= end:
            namesz, descsz, note_type = struct.unpack_from("<III", data, note)
            note += 12
            name_end = note + namesz
            desc_start = (name_end + 3) & ~3
            desc_end = desc_start + descsz
            next_note = (desc_end + 3) & ~3
            if name_end > end or desc_end > end or next_note > end:
                fail("truncated ELF note")
            name = data[note:name_end].rstrip(b"\0")
            if name == b"GNU" and note_type == 3:
                return data[desc_start:desc_end].hex()
            note = next_note
    fail("GNU BuildID not found in libGame.so")


def validate_library(path, libcxx_path):
    data = Path(path).read_bytes()
    digest = hashlib.md5(data).hexdigest()
    if digest != LIBGAME_MD5:
        fail("libGame.so MD5 %s (expected %s)" % (digest, LIBGAME_MD5))
    build_id = elf_build_id(data)
    if build_id != LIBGAME_BUILD_ID:
        fail("libGame.so BuildID %s (expected %s)" % (build_id, LIBGAME_BUILD_ID))
    print("libGame.so OK md5=%s buildid=%s" % (digest, build_id))

    libcxx_digest = hashlib.sha256(Path(libcxx_path).read_bytes()).hexdigest()
    if libcxx_digest != LIBCXX_SHA256:
        fail(
            "libc++_shared.so SHA256 %s (expected %s)"
            % (libcxx_digest, LIBCXX_SHA256)
        )
    print("libc++_shared.so OK sha256=%s" % libcxx_digest)


def validate_index(zip_path, idx_path, index):
    zip_file = Path(zip_path)
    idx_file = Path(idx_path)
    zip_size = zip_file.stat().st_size
    data = idx_file.read_bytes()
    if zip_size != EXPECTED_ZIP_SIZES[index]:
        fail(
            "%s size %d (expected %d)"
            % (zip_file.name, zip_size, EXPECTED_ZIP_SIZES[index])
        )
    idx_digest = hashlib.sha256(data).hexdigest()
    if idx_digest != EXPECTED_IDX_SHA256[index]:
        fail(
            "%s SHA256 %s (expected %s)"
            % (idx_file.name, idx_digest, EXPECTED_IDX_SHA256[index])
        )
    if len(data) < 4:
        fail("%s is shorter than its count header" % idx_file.name)

    count = struct.unpack_from("<I", data, 0)[0]
    expected_count = EXPECTED_COUNTS[index]
    if count != expected_count:
        fail("%s count %d (expected %d)" % (idx_file.name, count, expected_count))
    if count == 0 or count > 1000000:
        fail("%s has unreasonable count %d" % (idx_file.name, count))

    pos = 4
    for record in range(count):
        if pos + 10 > len(data):
            fail("%s truncated at record %d" % (idx_file.name, record))
        offset, size, name_len = struct.unpack_from("<IIH", data, pos)
        pos += 10
        if name_len == 0 or name_len >= 512 or pos + name_len > len(data):
            fail("%s invalid name length at record %d" % (idx_file.name, record))
        name = data[pos : pos + name_len]
        pos += name_len
        if b"\0" in name or b".." in name.replace(b"\\", b"/").split(b"/"):
            fail("%s unsafe name at record %d" % (idx_file.name, record))
        if size == 0 or offset > zip_size or size > zip_size - offset:
            fail("%s range outside %s at record %d" % (idx_file.name, zip_file.name, record))

    if pos != len(data):
        fail("%s has %d trailing bytes" % (idx_file.name, len(data) - pos))

    validate_archive_crc(zip_file, announce=False)
    print("%s + %s OK count=%d size=%d" % (zip_file.name, idx_file.name, count, zip_size))


def usage():
    fail(
        "usage: validate-bully-data.py archive ZIP | lib LIBGAME LIBCXX | "
        "pair ZIP IDX INDEX"
    )


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "archive":
        validate_archive_crc(sys.argv[2])
        return
    if len(sys.argv) == 4 and sys.argv[1] == "lib":
        validate_library(sys.argv[2], sys.argv[3])
        return
    if len(sys.argv) == 5 and sys.argv[1] == "pair":
        try:
            index = int(sys.argv[4])
        except ValueError:
            usage()
        if not 0 <= index < len(EXPECTED_COUNTS):
            usage()
        validate_index(sys.argv[2], sys.argv[3], index)
        return
    usage()


if __name__ == "__main__":
    main()
