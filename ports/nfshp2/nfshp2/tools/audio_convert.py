#!/usr/bin/env python3
r"""Unpack a bWare sound bank (`SOUND\*.MSH` + `SOUND\*.MSB`) into WAV files.

A bank is two files. The `.MSH` is the index and the `.MSB` is one long blob
of PS2 SPU ADPCM, one patch after another. Both structs come straight out of
the recovered `.mdebug` type info (`docs/mdebug_structs.txt`), so none of this
is guesswork -- the field names below are the engine's own:

    SOUND_MSH_HEADER_INFO   12 bytes, the whole .MSH header
        0   u32  MSHSize          total .MSH size, header + patches + padding
        4   u32  MSHPad           padding bytes after the last patch record
        8   u32  NumberOfPatches

    SOUND_PATCH_INFO        52 bytes, one per patch
        0   char[32]  Name
        32  s8        Pan            0 in every bank on this disc
        33  s8        LoopChannel    bit 0 = looping, bit 4 = right channel
        34  u16       Pitch          sample rate in Hz (8000..44100)
        36  u16       Volume         0..0x7fff
        38  u16       EffectVolume
        40  u32       Offset         byte offset into the .MSB
        44  u32       ADSR           0 in every bank on this disc
        48  u32       Reserved       0 in every bank on this disc

A patch runs from its `Offset` to the next patch's, or to the end of the
`.MSB` for the last one. The engine reads these through
`SOUND_GetMSHInfo__FUiP14SOUND_MSH_INFOUi` (`0x00252fb0`) and uploads the
result to SPU memory with `SOUND_TransIOPToSPU__FUiUiUi` (`0x00253f80`).

`LoopChannel` bit 4 marks the right half of a stereo pair: those patches
always repeat the previous patch's name and length, and there are exactly as
many of them as there are adjacent same-name pairs (30 across the 30 banks on
this disc). They are merged into one stereo WAV unless `--no-stereo` is given.

Audio is standard PS2 SPU ADPCM: 16-byte frames, 28 samples each. Byte 0 is
`predictor << 4 | shift`, byte 1 is the loop/end flag, and the remaining 14
bytes hold 28 nibbles, low nibble first.

Usage:
    python tools/audio_convert.py SOUND/COMMON.MSH --list
    python tools/audio_convert.py SOUND/COMMON.MSH out/
    python tools/audio_convert.py SOUND/COMMON.MSH out/ --no-stereo
    python tools/audio_convert.py SOUND/COMMON.MSH out/ --raw
"""
import argparse
import array
import struct
import sys
import wave
from pathlib import Path

HEADER_SIZE = 12
PATCH_SIZE = 52
FRAME_SIZE = 16
SAMPLES_PER_FRAME = 28

LOOP_FLAG = 0x01
RIGHT_FLAG = 0x10

# Sony's ADPCM predictor coefficients, scaled by 64.
COEF = ((0, 0), (60, 0), (115, -52), (98, -55), (122, -60))

# Frame flag byte, as the SPU reads it.
FLAG_NAMES = {0: "", 1: "end", 2: "loop-body", 3: "loop-end",
              4: "loop-start", 6: "loop-start", 7: "end-mute"}


def read_bank(msh_path):
    msh = Path(msh_path)
    msb = msh.with_suffix(".MSB")
    if not msb.exists():
        msb = msh.with_suffix(".msb")
    if not msb.exists():
        raise SystemExit("no .MSB next to %s" % msh)

    head = msh.read_bytes()
    body = msb.read_bytes()
    # A file under the wrong name -- the extractor's, before 2026-10-21, on
    # another release's disc -- says so here, not in a struct.error. The
    # discs' largest index is 3.5 KB.
    count = struct.unpack_from("<I", head, 8)[0] if len(head) >= HEADER_SIZE else 0
    if not HEADER_SIZE + count * PATCH_SIZE <= len(head) <= 0x10000:
        raise SystemExit(
            "%s isn't a sound bank's index (%d bytes). Delete "
            "extracted-retail and run tools/zdir_extract.py again."
            % (msh, len(head)))
    size, pad, count = struct.unpack_from("<3I", head, 0)
    if size != len(head):
        print("warning: %s declares %d bytes but is %d" % (msh.name, size, len(head)),
              file=sys.stderr)

    patches = []
    for i in range(count):
        r = HEADER_SIZE + i * PATCH_SIZE
        name = head[r:r + 32].split(b"\0")[0].decode("latin-1")
        pan, loop_channel = struct.unpack_from("<2b", head, r + 32)
        pitch, volume, effect = struct.unpack_from("<3H", head, r + 34)
        offset, adsr, reserved = struct.unpack_from("<3I", head, r + 40)
        patches.append(dict(index=i, name=name, pan=pan, loop_channel=loop_channel,
                            pitch=pitch, volume=volume, effect_volume=effect,
                            offset=offset, adsr=adsr, reserved=reserved))
    for i, p in enumerate(patches):
        end = patches[i + 1]["offset"] if i + 1 < len(patches) else len(body)
        if not p["offset"] <= end <= len(body):
            raise SystemExit(
                "%s: patch %d (%s) runs from %d to %d, outside %s's %d bytes. "
                "Delete extracted-retail and run tools/zdir_extract.py again."
                % (msh.name, i, p["name"], p["offset"], end, msb.name, len(body)))
        p["size"] = end - p["offset"]
        p["data"] = body[p["offset"]:end]
    del pad
    return patches


def decode_adpcm(data):
    """PS2 SPU ADPCM -> (16-bit PCM array, loop_start_sample, loop_end_sample).

    Loop points are in samples and are None when the stream carries no loop
    flags. They are the SPU frame flags, not a separate table.
    """
    out = array.array("h")
    h1 = h2 = 0
    loop_start = loop_end = None
    for i in range(0, len(data) - FRAME_SIZE + 1, FRAME_SIZE):
        head = data[i]
        shift = head & 0x0F
        predictor = head >> 4
        if predictor > 4:            # the SPU clamps rather than faulting
            predictor = 0
        f0, f1 = COEF[predictor]

        flag = data[i + 1]
        if flag in (4, 6) and loop_start is None:
            loop_start = len(out)
        if flag == 3:
            loop_end = len(out) + SAMPLES_PER_FRAME
        if flag == 7:                # end marker, and do not decode this frame
            break

        for j in range(14):
            byte = data[i + 2 + j]
            for nibble in (byte & 0x0F, byte >> 4):
                v = nibble << 12
                if v & 0x8000:
                    v -= 0x10000
                s = (v >> shift) + ((f0 * h1 + f1 * h2 + 32) >> 6)
                if s > 32767:
                    s = 32767
                elif s < -32768:
                    s = -32768
                h2 = h1
                h1 = s
                out.append(s)

        if flag == 1:                # end marker, this frame still counts
            break
    return out, loop_start, loop_end


def group(patches, stereo=True):
    """Yield (patches_in_this_output, channels). Stereo pairs come out joined."""
    i = 0
    while i < len(patches):
        p = patches[i]
        nxt = patches[i + 1] if i + 1 < len(patches) else None
        if (stereo and nxt is not None
                and nxt["loop_channel"] & RIGHT_FLAG
                and not (p["loop_channel"] & RIGHT_FLAG)
                and nxt["name"] == p["name"]):
            yield [p, nxt], 2
            i += 2
        else:
            yield [p], 1
            i += 1


def write_wav(path, channels, rate, tracks):
    if channels == 2:
        left, right = tracks
        n = min(len(left), len(right))
        frames = array.array("h", [0] * (n * 2))
        frames[0::2] = left[:n]
        frames[1::2] = right[:n]
    else:
        frames = tracks[0]
    with wave.open(str(path), "wb") as w:
        w.setnchannels(channels)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(frames.tobytes())


def safe_name(s):
    return "".join(c if c.isalnum() or c in "._-" else "_" for c in s) or "patch"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("msh", help="path to a SOUND/*.MSH (the .MSB must sit beside it)")
    ap.add_argument("out_dir", nargs="?")
    ap.add_argument("--list", action="store_true", help="print the patch table only")
    ap.add_argument("--no-stereo", action="store_true",
                    help="write every patch on its own instead of joining L/R pairs")
    ap.add_argument("--raw", action="store_true",
                    help="also write each patch as raw SPU ADPCM next to the WAV")
    a = ap.parse_args()
    if not a.list and not a.out_dir:
        ap.error("give an output directory, or --list")

    patches = read_bank(a.msh)
    stem = Path(a.msh).stem

    if a.list:
        print("== %s: %d patches ==" % (stem, len(patches)))
        print("%-3s %-26s %6s %6s %6s %-5s %9s %9s %s"
              % ("#", "name", "rate", "vol", "efxvol", "loop", "offset", "bytes", "flags"))
        for p in patches:
            pcm, ls, le = decode_adpcm(p["data"])
            loops = []
            if ls is not None:
                loops.append("start=%d" % ls)
            if le is not None:
                loops.append("end=%d" % le)
            print("%-3d %-26s %6d %6d %6d %-5s %9d %9d %s"
                  % (p["index"], p["name"], p["pitch"], p["volume"],
                     p["effect_volume"],
                     ("L+R" if p["loop_channel"] & RIGHT_FLAG else
                      "loop" if p["loop_channel"] & LOOP_FLAG else "-"),
                     p["offset"], p["size"], " ".join(loops)))
            del pcm
        return

    out = Path(a.out_dir) / stem
    out.mkdir(parents=True, exist_ok=True)
    manifest = [("index", "name", "channels", "rate", "volume", "effect_volume",
                 "looping", "samples", "loop_start", "loop_end", "file")]
    written = 0

    for members, channels in group(patches, stereo=not a.no_stereo):
        tracks, ls, le = [], None, None
        for p in members:
            pcm, s, e = decode_adpcm(p["data"])
            tracks.append(pcm)
            if ls is None:
                ls, le = s, e
        head = members[0]
        fname = "%02d_%s.wav" % (head["index"], safe_name(head["name"]))
        write_wav(out / fname, channels, head["pitch"] or 22050, tracks)
        if a.raw:
            for p in members:
                (out / ("%02d_%s.adpcm" % (p["index"], safe_name(p["name"])))
                 ).write_bytes(p["data"])
        manifest.append((head["index"], head["name"], channels, head["pitch"],
                         head["volume"], head["effect_volume"],
                         1 if head["loop_channel"] & LOOP_FLAG else 0,
                         len(tracks[0]),
                         "" if ls is None else ls, "" if le is None else le,
                         fname))
        written += 1

    with open(out / "patches.csv", "w", encoding="utf-8", newline="\n") as f:
        for row in manifest:
            f.write(",".join(str(c) for c in row) + "\n")
    print("wrote %d WAVs from %d patches to %s" % (written, len(patches), out))


if __name__ == "__main__":
    main()
