#!/usr/bin/env python3
"""The PS2 releases of Need for Speed: Hot Pursuit 2 the port installs from,
and how to tell them apart (docs/releases.md).

All of them run one program: the USA one, the European v1.00 disc's (the
same bytes), the European v2.00 disc's (two stack frames larger), and the
Asian and Korean discs' (the same code linked again, with their own product
numbers). Their data differs only in a few files, so the port, which reads
only the data, runs on any of them. What differs for the port is PAL.TAG:
the European discs have it and the game runs as PAL (a language screen at
every start, Languages in Options); the others don't and run as NTSC
(English, no language choice), as on a PS2.
"""
import hashlib
import re
from collections import namedtuple

RELEASE_FILE = "RELEASE.TXT"

Release = namedtuple("Release", "id label boot sha1 known")

# (boot program, SHA-1 of it) -> (id, label). USA and Europe v1.00 boot the
# same bytes under their own names.
KNOWN = {
    ("SLUS_203.62", "6397d4425d55056678ed5a405cc81542f7d4d2ee"):
        ("SLUS-20362", "USA (SLUS-20362)"),
    ("SLES_507.31", "6397d4425d55056678ed5a405cc81542f7d4d2ee"):
        ("SLES-50731-1.00", "Europe v1.00 (SLES-50731)"),
    ("SLES_507.31", "e8983ff7e3517fd6fce5c1ca3673b71619c777f5"):
        ("SLES-50731-2.00", "Europe v2.00 (SLES-50731)"),
    ("SLPM_651.81", "ffcfeedaba5deeec3b80c9f700739c2e080343f5"):
        ("SLPM-65181", "Asia (SLPM-65181)"),
    ("SLPM_675.27", "548fbe75a6096231a72254aea539fd0bea4406dc"):
        ("SLPM-67527", "Korea (SLPM-67527)"),
}
BOOT_NAMES = {boot for boot, _ in KNOWN}
SUPPORTED = ("USA SLUS-20362, Europe SLES-50731, Asia SLPM-65181 or "
             "Korea SLPM-67527")

# bStringHash of the names (tools/bhash.py).
PAL_TAG = 0xbf0a6606        # PAL.TAG, empty, on the European discs only
HOTCHUNK_TAG = 0x29ac9c8d   # HOTCHUNK.TAG, a build leftover on Europe v2.00
KNOWN_EXTRA = {HOTCHUNK_TAG: "HOTCHUNK.TAG"}


def boot_name(cnf):
    """The boot program's name from SYSTEM.CNF's BOOT2 line, or None."""
    text = cnf.decode("latin-1", "replace")
    m = re.search(r"BOOT2\s*=\s*cdrom0?:\\?([^;\s]+)", text, re.I)
    return m.group(1).lstrip("\\").upper() if m else None


def sha1_of(read, size, chunk=1 << 20):
    """SHA-1 of `size` bytes from read(offset, n)."""
    h, at = hashlib.sha1(), 0
    while at < size:
        n = min(chunk, size - at)
        h.update(read(at, n))
        at += n
    return h.hexdigest()


def identify(boot, sha1):
    hit = KNOWN.get(((boot or "").upper(), sha1))
    if hit:
        return Release(hit[0], hit[1], boot.upper(), sha1, True)
    return Release("unknown", "unknown (%s)" % (boot or "?"),
                   (boot or "?").upper(), sha1, False)


def optional(name):
    """Files of the PAL v1.00 directory that another release may lack:
    PAL.TAG (not on the NTSC discs) and the attract mode's replays (two
    are gone from Europe v2.00, Asia and Korea; attract mode skips a
    replay it can't find)."""
    up = name.upper()
    return up == "PAL.TAG" or up.startswith("REPLAY\\")


def compare_directory(hashes, names, listed):
    """A disc's ZDIR hashes against the port's list (zdir_names_retail.txt):
    (names the disc lacks that the game needs, hashes the list doesn't
    have). Unnamed entries of the list are never needed: nothing the port
    loads is among them."""
    missing = sorted(names[h] for h in listed - hashes
                     if h in names and not optional(names[h]))
    extra = sorted(hashes - listed)
    return missing, extra


def release_text(info, pal):
    """RELEASE.TXT, which the game reads for PAL or NTSC (gamedata.c)."""
    return ("# The disc this NFSHP2 folder was installed from.\n"
            "release=%s\nlabel=%s\nboot=%s\nsha1=%s\nvideo=%s\n"
            % (info.id, info.label, info.boot, info.sha1 or "",
               "PAL" if pal else "NTSC"))

