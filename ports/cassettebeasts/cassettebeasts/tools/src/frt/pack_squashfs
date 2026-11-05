#!/bin/bash
# Packs a built frt binary as the port's engine image, cassettebeasts/frt_3.5.2_cb.squashfs (gzip, 128 KB blocks,
# root-owned, like PortMaster's runtime images); the launcher mounts it at $HOME/godot_cb. Run in WSL as root.
#   bash pack_squashfs <frt binary> <out.squashfs>
# License: 0BSD.
set -e
BIN=${1:?frt binary}
OUT=${2:?output squashfs}
S=$(mktemp -d)
# the image root must be world-readable: mktemp makes it 700, and dArkOS runs games as the user (ark), who then
# got "Permission denied" on the engine (R36S, 2026-10-10); root-run firmwares (Knulli, ROCKNIX) never noticed
chmod 755 "$S"
cp "$BIN" "$S/frt_3.5.2"
chmod 755 "$S/frt_3.5.2"
rm -f "$OUT"
mksquashfs "$S" "$OUT" -comp gzip -b 131072 -all-root -noappend -no-progress -quiet
rm -rf "$S"
ls -la "$OUT"
