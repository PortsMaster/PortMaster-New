#!/usr/bin/env python3
# SORP - Super Off Road Port
# Copyright (C) 2026 dopaz
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.  It is distributed WITHOUT ANY WARRANTY; see
# the GNU General Public License in LICENSE for details.
#
# Developed with the assistance of Claude Opus 5 and Claude Opus 5.5.

"""padmap.py -- Knulli's controller mappings, renumbered for SDL3.

EmulationStation's configgen exports SDL_GAMECONTROLLERCONFIG before it
runs a port: one line per pad, its buttons numbered as Knulli's SDL2
counts them -- every key the pad has, in key-code order.  SDL3 counts
them differently: the joystick buttons (BTN_JOYSTICK, 0x120, and up)
first, then the keys below that (volume and the like).  Read as they
stand, the lines put SDL3's buttons in the wrong places.

So for each line, find the pad by its name under /sys/class/input, read
the keys it has, and renumber every "bN" from the one order to the other.

Only lines counted in key-code order are renumbered; other CFWs' SDL2
(ROCKNIX's, PortMaster's own) counts as SDL3 does.  A line does not say
which, but its buttons do: read both ways, the right reading puts every
pad button (a, start, the shoulders, the d-pad...) on a joystick button,
and the wrong one puts some on the keys below BTN_JOYSTICK.  "guide" is
not counted: on some pads it is one of those keys (the RG DS's).  A pad
with no keys below BTN_JOYSTICK reads the same both ways.  When neither
reading is better, the line is left as it is.

muOS's PortMaster lines are numbered the same way, but they name the pad
for the device ("TRIMUI Brick Controller") while the input device is
muOS's own virtual pad, "muOS-Keys".  A pad not found by its name is
looked for by the vendor, product and version in its GUID.

The GUID can differ too.  SDL3 makes a pad's GUID from its vendor and
product IDs only when it has a vendor ID; without one (the Anbernic RG
DS's controller: vendor 0000, product 1101) it uses the bus, a CRC-16 of
the name, and the name's first 11 characters, where the CFW's line has
the IDs.  Then SDL3 finds no line for the pad and guesses -- a d-pad on a
hat the pad does not have.  So a pad without a vendor ID gets its line
twice: under the CFW's GUID and under SDL3's.

A line whose pad is not found is left as it is.  The result is printed;
notes go to stderr.
"""
import glob
import os
import re
import sys

BTN_JOYSTICK = 0x120

# The buttons a mapping puts on joystick buttons, never on the keys below
PAD_BUTTONS = {"a", "b", "x", "y", "back", "start",
               "leftshoulder", "rightshoulder", "lefttrigger", "righttrigger",
               "leftstick", "rightstick", "dpup", "dpdown", "dpleft", "dpright"}

# /sys/class/input, or a copy of it for tests
SYSFS = os.environ.get("PADMAP_SYSFS", "/sys/class/input")


def find_device(name):
    """The sysfs directory of the input device called NAME, or None."""
    for dev in sorted(glob.glob(SYSFS + "/event*/device")):
        try:
            with open(dev + "/name") as f:
                if f.read().strip() == name:
                    return dev
        except OSError:
            continue
    return None


def find_device_by_guid(guid):
    """The sysfs directory of the input device whose vendor, product and
    version are the ones in GUID (SDL's Linux GUID: bus, CRC, vendor, 0,
    product, 0, version, 0, as little-endian 16-bit words), or None."""
    try:
        raw = bytes.fromhex(guid)
    except ValueError:
        return None
    if len(raw) != 16:
        return None
    word = lambda i: raw[i] | raw[i + 1] << 8
    want = (word(0), word(4), word(8), word(12))
    if not want[1]:
        return None
    for dev in sorted(glob.glob(SYSFS + "/event*/device")):
        try:
            got = tuple(int(open(dev + "/id/" + f).read().strip(), 16)
                        for f in ("bustype", "vendor", "product", "version"))
        except (OSError, ValueError):
            continue
        if got == want:
            return dev
    return None


def key_codes(dev):
    """The key codes the input device has, in order."""
    try:
        with open(dev + "/capabilities/key") as f:
            words = f.read().split()
    except OSError:
        return None
    bits = 64 if sys.maxsize > 2**32 else 32          # the kernel's long
    codes = [k * bits + b
             for k, w in enumerate(reversed(words))
             for b in range(bits) if int(w, 16) >> b & 1]
    return sorted(codes)


def crc16(data, crc=0):
    """SDL_crc16: CRC-16/ARC."""
    for b in data:
        crc ^= b
        for _ in range(8):
            crc = (crc >> 1) ^ 0xA001 if crc & 1 else crc >> 1
    return crc


def sdl3_guid(dev, name):
    """The GUID SDL3 gives a pad WITHOUT a vendor ID (SDL_CreateJoystickGUID):
    bus and name CRC, little-endian, then the name's first 11 characters;
    None for a pad that has one, whose GUID is made from its IDs."""
    try:
        def read_id(field):
            with open(dev + "/id/" + field) as f:
                return int(f.read().strip(), 16)
        bus, vendor = read_id("bustype"), read_id("vendor")
    except (OSError, ValueError):
        return None
    if vendor:
        return None
    crc = crc16(name.encode("utf-8"))
    raw = bytes([bus & 0xff, bus >> 8, crc & 0xff, crc >> 8])
    raw += name.encode("utf-8")[:11].ljust(12, b"\0")
    return raw.hex()


def misses(fields, order):
    """How many of the pad buttons the mapping FIELDS puts on keys below
    BTN_JOYSTICK (or on no key), its numbers read as indices into ORDER."""
    n = 0
    for f in fields:
        m = re.match(r"^([^:]+):b(\d+)$", f)
        if m and m.group(1) in PAD_BUTTONS:
            i = int(m.group(2))
            n += i >= len(order) or order[i] < BTN_JOYSTICK
    return n


def renumber(line):
    fields = line.split(",")
    if len(fields) < 3:
        return line
    dev = find_device(fields[1]) or find_device_by_guid(fields[0])
    codes = key_codes(dev) if dev else None
    if not codes:
        return line
    sdl3 = ([c for c in codes if c >= BTN_JOYSTICK] +
            [c for c in codes if c < BTN_JOYSTICK])
    out = fields[2:]
    if sdl3 == codes:
        print("padmap: %s: the same in either order, left" % fields[1],
              file=sys.stderr)
    else:
        by_code, by_sdl3 = misses(out, codes), misses(out, sdl3)
        if by_code < by_sdl3:
            new = {codes.index(c): sdl3.index(c) for c in codes}

            def fix(m):
                return "%sb%d" % (m.group(1),
                                  new.get(int(m.group(2)), int(m.group(2))))

            out = [re.sub(r"^([^:]+:)b(\d+)$", fix, f) for f in out]
            print("padmap: %s: key-code order (pad buttons on low keys: "
                  "%d read SDL3's way, %d in key-code order), renumbered: %s"
                  % (fields[1], by_sdl3, by_code, ",".join(out)),
                  file=sys.stderr)
        else:
            print("padmap: %s: not key-code order (pad buttons on low keys: "
                  "%d read SDL3's way, %d in key-code order), left"
                  % (fields[1], by_sdl3, by_code), file=sys.stderr)
    lines = [",".join(fields[:2] + out)]
    guid = sdl3_guid(dev, fields[1])
    if guid and guid != fields[0].lower():
        print("padmap: %s: also as %s, SDL3's GUID" % (fields[1], guid),
              file=sys.stderr)
        lines.append(",".join([guid] + fields[1:2] + out))
    return "\n".join(lines)


def main():
    config = os.environ.get("SDL_GAMECONTROLLERCONFIG", "")
    if not config:
        print("padmap: no SDL_GAMECONTROLLERCONFIG", file=sys.stderr)
        return 1
    print("\n".join(renumber(l) for l in config.split("\n")))
    return 0


if __name__ == "__main__":
    sys.exit(main())
