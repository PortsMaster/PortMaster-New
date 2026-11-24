#!/usr/bin/env python3
"""Installs the game's files from the player's own disc image, on the
handheld itself: what the README's steps on a computer make
(tools/zdir_extract.py --retail --decompress, tools/audio_pack.py,
tools/make_card.py), straight from the .iso, into gamedata/NFSHP2.

    python3 nfshp2_install.py <disc.iso> <gamedata>

It reads the disc's NFSHP2/ZDIR.BIN and NFSHP2/ZZDATA.BIN inside the ISO
(no copy of them is made) and writes the set make_card.py copies:

- every named entry as it is on the disc, but for the leftovers make_card
  leaves out (the sound banks' .MSH/.MSB/.RAW, unknown entries, KEY.TXT,
  NFS6.ICO, MARKERS/, NIS/, REPLAY/MAY31/);
- the 30 tracks' TRACKB*.LZC expanded, under the .BUN name the game loads
  (zdir_extract.py's --decompress), and not the .LZC;
- the sound banks' .SBK, which audio_pack.py's build_bank makes from each
  .MSH/.MSB pair.

The tools' own code does the work where it can (the names and their
hashes, the bank transcode), so the result is the computer's, file for
file. The track expansion is lzdecompress.py's algorithm with the copies
that cannot overlap done a slice at a time, which is the same bytes and
several times quicker on the handheld.

Every release of the game is taken: USA SLUS-20362, Europe SLES-50731
(v1.00 and v2.00), Asia SLPM-65181 and Korea SLPM-67527. They all run one
program and differ in their data only by a few files (see release.py).
The disc's release goes into NFSHP2/RELEASE.TXT, and PAL.TAG, the file
that makes the game PAL, is kept where the disc has it.

The files go to <gamedata>/NFSHP2.installing and the folder takes the
NFSHP2 name only once every file is there, so the launcher never sees half
an install; SAVES in an earlier NFSHP2 is kept. Run again after a stop,
it keeps the files already written whole. Progress lines go to stdout for
PortMaster's patcher, which shows the last ones; "Patching process failed!"
is the patcher's word for a failure, after a PATCH_FAIL_MSG line saying why.
"""
import fnmatch
import os
import shutil
import struct
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from zdir_extract import read_names, hot_chunked, TRACK_BUN, RECORD_SIZE, SECTOR  # noqa: E402
from audio_pack import build_bank  # noqa: E402
import release  # noqa: E402

NAMES = HERE / "zdir_names_retail.txt"
SECTOR_ISO = 2048
CHUNK = 4 << 20

# make_card.py's LEAVE_OUT, which the card was tested with.
LEAVE_OUT = [
    "TRACKS/TRACKB*.LZC",
    "*.MSH", "*.MSB", "*.RAW",
    "UNKNOWN/*", "MANIFEST.CSV", "KEY.TXT", "NFS6.ICO",
    "MARKERS/*", "NIS/*", "REPLAY/MAY31/*",
]


class Failed(Exception):
    pass


def say(text):
    print(text, flush=True)


def wanted(rel):
    up = rel.upper()
    return not any(fnmatch.fnmatchcase(up, g) for g in LEAVE_OUT)


# ------------------------------------------------------------- the ISO

class Iso:
    """An ISO 9660 image's files by path, case blind, without the ;1."""

    def __init__(self, path):
        self.f = open(path, "rb")
        self.f.seek(16 * SECTOR_ISO)
        pvd = self.f.read(SECTOR_ISO)
        if len(pvd) != SECTOR_ISO or pvd[:6] != b"\x01CD001":
            raise Failed("%s isn't an ISO 9660 disc image" % Path(path).name)
        self.root = self._record(pvd, 156)

    @staticmethod
    def _record(buf, at):
        n = buf[at]
        if n < 34 or at + n > len(buf) or buf[at + 32] > n - 33:
            raise Failed("Invalid ISO 9660 directory record")
        lba, size = struct.unpack_from("<I", buf, at + 2)[0], struct.unpack_from("<I", buf, at + 10)[0]
        flags = buf[at + 25]
        name = buf[at + 33:at + 33 + buf[at + 32]].decode("latin-1")
        return n, lba, size, bool(flags & 2), name.split(";")[0].rstrip(".").upper()

    def _list(self, lba, size):
        self.f.seek(lba * SECTOR_ISO)
        data = self.f.read(size)
        out, at = {}, 0
        while at < len(data):
            if data[at] == 0:          # the rest of this sector is padding
                at = (at // SECTOR_ISO + 1) * SECTOR_ISO
                continue
            rec = self._record(data, at)
            if rec[4] not in ("\x00", "\x01"):
                out[rec[4]] = rec
            at += rec[0]
        return out

    def find(self, path):
        """(byte offset, size) of a file, or None."""
        _, lba, size, is_dir, _ = self.root
        for part in path.upper().split("/"):
            if not is_dir:
                return None
            rec = self._list(lba, size).get(part)
            if rec is None:
                return None
            _, lba, size, is_dir, _ = rec
        return None if is_dir else (lba * SECTOR_ISO, size)

    def read(self, offset, size):
        self.f.seek(offset)
        return self.f.read(size)


# ------------------------------------------------------- the expansion

def expand(buf):
    """lzdecompress.decompress, with a copy that cannot overlap itself done
    as one slice: the same bytes."""
    if len(buf) < 16 or buf[:4] != b"COMP":
        raise Failed("a track bundle isn't a COMP container")
    method, = struct.unpack_from("<H", buf, 6)
    out_size, total = struct.unpack_from("<II", buf, 8)
    if method == 1:
        return bytes(buf[16:total])
    end, src, ctrl = total, 16, 1
    out = bytearray()
    append = out.append
    while src != end:
        if ctrl == 1:
            ctrl = buf[src] | 0x10000 | (buf[src + 1] << 8)
            src += 2
        n = 16 if src <= end - 0x20 else 1
        for _ in range(n):
            if ctrl & 1:
                b0 = buf[src]
                dist = ((b0 & 0xF0) << 4) | buf[src + 1]
                length = 3 + (b0 & 0x0F)
                src += 2
                p = len(out) - dist
                if dist >= length:
                    out += out[p:p + length]
                else:
                    for k in range(length):
                        append(out[p + k])
            else:
                append(buf[src])
                src += 1
            ctrl >>= 1
    if len(out) != out_size:
        raise Failed("a track bundle expanded to %d bytes, not %d" % (len(out), out_size))
    return bytes(out)


# ---------------------------------------------------------- the install

def identify(iso):
    """The disc's release, from SYSTEM.CNF's boot program and its SHA-1."""
    cnf = iso.find("SYSTEM.CNF")
    if cnf is None:
        raise Failed("This disc image has no SYSTEM.CNF: it isn't a PS2 game")
    boot = release.boot_name(iso.read(*cnf))
    elf = iso.find(boot) if boot else None
    if elf is None:
        raise Failed("This disc's boot program (%s) isn't on it" % (boot or "?"))
    sha1 = release.sha1_of(lambda off, n: iso.read(elf[0] + off, n), elf[1])
    info = release.identify(boot, sha1)
    if info.known:
        say("Disc: %s" % info.label)
    elif boot.upper() in release.BOOT_NAMES:
        say("Disc: %s, a version the port hasn't seen (SHA-1 %s); "
            "installing it anyway" % (boot, sha1))
    else:
        raise Failed("This disc boots %s, which isn't Need for Speed: Hot "
                     "Pursuit 2 for the PS2 (%s)" % (boot, release.SUPPORTED))
    return info


def plan(iso):
    """What to write: (kind, rel path, disc offset, disc size, out size)."""
    zdir = iso.find("NFSHP2/ZDIR.BIN")
    zz = iso.find("NFSHP2/ZZDATA.BIN")
    if zdir is None or zz is None:
        raise Failed("This disc has no NFSHP2/ZDIR.BIN and ZZDATA.BIN: it "
                     "isn't Need for Speed: Hot Pursuit 2 for the PS2")
    data = iso.read(*zdir)
    if len(data) % RECORD_SIZE:
        raise Failed("The disc's ZDIR.BIN is damaged")
    entries = [struct.unpack_from("<III", data, i) for i in range(0, len(data), RECORD_SIZE)]
    names, listed = read_names(NAMES)
    hashes = {h for h, _, _ in entries}
    missing, extra = release.compare_directory(hashes, names, listed)
    if missing:
        raise Failed("This disc lacks %d of the game's files (%s%s): it isn't "
                     "a release of Need for Speed: Hot Pursuit 2 the port "
                     "knows, or the image is damaged"
                     % (len(missing), ", ".join(missing[:3]),
                        ", ..." if len(missing) > 3 else ""))
    if extra:
        say("%d entries on this disc aren't in the port's list; they are "
            "left out" % len(extra))
    lzcs = {names[h].upper()[:-4] for h in hashes if h in names and hot_chunked(names[h])}
    zz_off, zz_size = zz
    todo, banks = [], []
    for h, fad, size in entries:
        name = names.get(h)
        if name is None:
            continue
        if fad * SECTOR + size > zz_size:
            raise Failed("The disc image is cut short (ZZDATA.BIN)")
        up = name.upper()
        rel = name.replace(chr(92), "/")
        off = zz_off + fad * SECTOR
        if fnmatch.fnmatchcase(up, TRACK_BUN) and up[:-4] in lzcs:
            continue                    # superseded by the .LZC's expansion
        if hot_chunked(name):
            out_size = struct.unpack_from("<I", iso.read(off + 8, 4))[0]
            todo.append(("expand", rel[:-4] + ".BUN", off, size, out_size))
        elif up.endswith(".MSH"):
            msb = up[:-4] + ".MSB"
            banks.append((rel, off, size, msb))
        if wanted(rel) and not hot_chunked(name):
            todo.append(("copy", rel, off, size, size))
    # Three names are in the directory twice (GLOBAL/HUDTEX.BIN,
    # CARS/TEXTURES.BIN, SOUND/SPEECH/EVENTS.EVT, the same bytes each time
    # on the PAL disc). zdir_extract.py writes both, so the later one is
    # what it leaves: the same here.
    last = {}
    for t in todo:
        last[t[1].upper()] = t
    todo = [t for t in todo if last[t[1].upper()] is t]
    # The .MSB of each bank, by name.
    by_name = {names[h].upper(): (zz_off + fad * SECTOR, size)
               for h, fad, size in entries if h in names}
    sbks = []
    for rel, off, size, msb in banks:
        if msb not in by_name:
            raise Failed("The disc has %s without its .MSB" % rel)
        sbks.append((rel, off, size) + by_name[msb])
    return todo, sbks


def write_atomic(dest, chunks):
    tmp = dest.with_name(dest.name + ".part")
    with open(tmp, "wb") as f:
        for c in chunks:
            f.write(c)
    os.replace(tmp, dest)


def install(iso_path, gamedata):
    t0 = time.time()
    iso = Iso(iso_path)
    rel_info = identify(iso)
    say("Reading the disc's file directory...")
    todo, sbks = plan(iso)
    pal = any(t[1].upper() == "PAL.TAG" for t in todo)
    gamedata = Path(gamedata)
    final = gamedata / "NFSHP2"
    work = gamedata / "NFSHP2.installing"
    work.mkdir(parents=True, exist_ok=True)

    def done_already(dest, size):
        return dest.is_file() and dest.stat().st_size == size

    need = sum(o for _, rel, _, _, o in todo if not done_already(work / rel, o))
    free = shutil.disk_usage(str(work)).free
    if need + (64 << 20) > free:
        raise Failed("The SD card needs %.1f GB free for the game's files "
                     "and has %.1f GB" % (need / 1e9, free / 1e9))
    total = sum(o for _, _, _, _, o in todo) or 1
    say("%d files, %.1f GB to write" % (len(todo) + len(sbks), total / 1e9))

    written, last = 0, -1
    for i, (kind, rel, off, size, out_size) in enumerate(todo, 1):
        dest = work / rel
        if not done_already(dest, out_size):
            dest.parent.mkdir(parents=True, exist_ok=True)
            if kind == "copy":
                def chunks(off=off, size=size):
                    left = size
                    while left:
                        n = min(CHUNK, left)
                        yield iso.read(off + size - left, n)
                        left -= n
                write_atomic(dest, chunks())
            else:
                say("Unpacking %s..." % rel.split("/")[-1])
                write_atomic(dest, [expand(iso.read(off, size))])
        written += out_size
        pct = written * 100 // total
        if pct != last and (pct % 5 == 0 or kind == "expand"):
            say("[%3d%%] %s" % (pct, rel[-50:]))
            last = pct

    tmp = work / "_banks"
    tmp.mkdir(exist_ok=True)
    for rel, off, size, msb_off, msb_size in sbks:
        stem = rel.split("/")[-1][:-4]
        dest = work / "SOUND" / (stem + ".SBK")
        msh = tmp / (stem + ".MSH")
        msh.write_bytes(iso.read(off, size))
        (tmp / (stem + ".MSB")).write_bytes(iso.read(msb_off, msb_size))
        name, blob, _ = build_bank(str(msh))
        dest.parent.mkdir(parents=True, exist_ok=True)
        write_atomic(dest, [blob])
    shutil.rmtree(str(tmp))
    say("Sound banks: %d made" % len(sbks))
    write_atomic(work / release.RELEASE_FILE,
                 [release.release_text(rel_info, pal).encode("ascii")])

    # Into place, with the saves of an earlier NFSHP2.
    if final.exists():
        saves = final / "SAVES"
        if saves.is_dir():
            shutil.move(str(saves), str(work / "SAVES"))
        old = gamedata / "NFSHP2.old"
        if old.exists():
            shutil.rmtree(str(old))
        os.replace(str(final), str(old))
        shutil.rmtree(str(old))
    os.replace(str(work), str(final))
    say("Done in %d min %02d s" % divmod(int(time.time() - t0), 60))


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    try:
        install(sys.argv[1], sys.argv[2])
    except Failed as e:
        say("PATCH_FAIL_MSG:%s" % e)
        say(str(e))
        say("Patching process failed!")
        sys.exit(1)
    except (OSError, SystemExit) as e:
        msg = str(e) or "the install stopped"
        say("PATCH_FAIL_MSG:%s" % msg)
        say(msg)
        say("Patching process failed!")
        sys.exit(1)


if __name__ == "__main__":
    main()
