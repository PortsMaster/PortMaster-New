#!/usr/bin/env python3
"""Build the port's 3DS sound banks from the disc's SOUND/*.MSH + .MSB pairs.

The PS2 kept its samples as SPU ADPCM in SPU RAM and let the SPU2 decode
them; the 3DS has its own DSP, which reads Nintendo DSPADPCM and nothing
else. The two are the same codec in different clothes, so this is a
transcode frame by frame and not a re-encode: nothing is decoded, and the
3DS plays the disc's own samples bit for bit.

Both predict each sample from the two before it with one of a small table
of coefficient pairs, and add a 4-bit delta shifted by a per-frame amount:

    SPU:  s = (d << 12 >> shift) + ((c0 * h1 + c1 * h2 + 32) >> 6)
    DSP:  s = (d * 2**scale * 2048 + k0 * h1 + k1 * h2 + 1024) >> 11

With k = c * 32 and scale = 12 - shift the two are the same integer
arithmetic: the delta term is a whole multiple of 2048, so it comes out of
the DSP's shift intact, and what is left is the SPU's own rounding. So one
16-byte SPU frame of 28 samples becomes two 8-byte DSP frames of 14, each
headed `predictor << 4 | (12 - shift)`, with every data byte's nibbles
swapped (the SPU plays the low nibble first, the DSP the high). Every patch
carries the same coefficient table, the SPU's five pairs scaled by 32. The
discs keep to predictors 0..4 and shifts 0..12, which is all DSPADPCM can
say; a frame outside that stops the pack rather than playing wrong.

It was not always so: until 2026-09-27 the path went through PCM16 and
`tools/bin/dspenc.exe`, which is lossy, and the worst patch came back at
22.6 dB. `tools/sndbank_check.py --audio` now asks for every sample.

Stereo pairs are joined the way the engine sees them: the 30 records with
LoopChannel bit 4 set repeat the previous record's name and are its right
channel, so they become one two-channel patch under one name, which is
what bSnd_GetPatchChannels() returns 2 for.

Looping patches lose their lead-in. Every one of the discs' looping
patches (336 on the demo, 269 on retail) loops from sample 28 to its end --
the SPU convention of a silent first frame with the loop-start flag on the
second -- so dropping that frame makes the whole buffer the loop body, which
is the only shape ndsp can loop without a second queued waveBuf. The
lead-in decodes to silence in all of them, so the DSP starts from the same
zero history the SPU had reached.

Format: docs/formats/sound-bank.md, section "The port's .SBK".

Usage:
    python tools/audio_pack.py extracted-retail/SOUND <data>/SOUND
    python tools/audio_pack.py extracted-retail/SOUND/COMMON.MSH out/ --report

The output goes next to the .MSH/.MSB it was built from, inside the data
directory gamedata.c resolves. Nothing on the disc is overwritten; .SBK is
a new extension.
"""
import argparse
import array
import struct
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from audio_convert import (read_bank, decode_adpcm, group, LOOP_FLAG,   # noqa: E402
                           COEF, FRAME_SIZE, SAMPLES_PER_FRAME)
from bhash import bhash                                               # noqa: E402

MAGIC = 0x314B4253          # 'SBK1' little-endian
VERSION = 1
HEADER_SIZE = 32
PATCH_SIZE = 128
FRAME_SAMPLES = 14          # DSPADPCM: 14 samples in 8 bytes
LEAD_IN = 28                # the SPU lead-in frame every looping patch carries

# The DSPADPCM coefficient table: the SPU's five pairs at 11 bits of fraction
# instead of 6, and three unused pairs.
DSP_COEFS = tuple([c * 32 for pair in COEF for c in pair] + [0] * 6)


def transcode(data, samples, first):
    """SPU ADPCM frames `first`.. -> DSPADPCM for `samples` samples.

    `samples` is a whole number of SPU frames (decode_adpcm's count, less
    the lead-in), so the output is exactly ceil(samples / 14) DSP frames.
    """
    out = bytearray()
    for i in range(first, first + samples // SAMPLES_PER_FRAME):
        f = data[i * FRAME_SIZE:(i + 1) * FRAME_SIZE]
        shift, pred = f[0] & 0x0F, f[0] >> 4
        if pred > 4:                 # the SPU clamps rather than faulting
            pred = 0
        if shift > 12:
            raise SystemExit("an SPU frame with shift %d has no DSPADPCM scale" % shift)
        head = (pred << 4) | (12 - shift)
        body = bytes(((b & 0x0F) << 4) | (b >> 4) for b in f[2:16])
        out.append(head)
        out += body[0:7]
        out.append(head)
        out += body[7:14]
    return bytes(out)


def dsp_decode(data, coefs, samples):
    """DSPADPCM -> PCM16, from a zero history, for --report."""
    out = array.array("h")
    h1 = h2 = 0
    for i in range(0, len(data), 8):
        scale = 1 << (data[i] & 0x0F)
        c = (data[i] >> 4) & 0x07
        k0, k1 = coefs[c * 2], coefs[c * 2 + 1]
        for j in range(14):
            byte = data[i + 1 + j // 2]
            nib = byte >> 4 if j % 2 == 0 else byte & 0x0F
            if nib > 7:
                nib -= 16
            s = (nib * scale * 2048 + k0 * h1 + k1 * h2 + 1024) >> 11
            s = 32767 if s > 32767 else (-32768 if s < -32768 else s)
            h2, h1 = h1, s
            out.append(s)
    return out[:samples]


def build_bank(msh, verify=False):
    """One .MSH/.MSB pair -> (bank name, .SBK bytes, per-patch report rows)."""
    name = Path(msh).stem
    recs, blob, report = [], bytearray(), []

    for members, channels in group(read_bank(msh)):
        head = members[0]
        looping = bool(head["loop_channel"] & LOOP_FLAG)
        # Pan and ADSR are 0 in every record on both discs, so .SBK leaves
        # them out and the port substitutes BSND_PATCH_PAN and the driver's
        # own 0x1a00000a default. A bank that broke that would play centred
        # and with the wrong envelope and nothing would say so, so say so
        # here instead.
        for m in members:
            if m["pan"] or m.get("adsr", 0):
                raise SystemExit(
                    "%s/%s carries Pan=%d ADSR=%08x; .SBK has nowhere to put "
                    "them -- see docs/formats/sound-driver.md"
                    % (Path(msh).stem, m["name"], m["pan"], m.get("adsr", 0)))
        pcms = []
        for m in members:
            pcm, _, _ = decode_adpcm(m["data"])
            if looping and (pcm[LEAD_IN - 1] or pcm[LEAD_IN - 2]):
                raise SystemExit("%s/%s: the lead-in leaves a history the DSP "
                                 "would not start from" % (name, m["name"]))
            pcms.append(pcm[LEAD_IN:] if looping else pcm)
        n = min(len(t) for t in pcms)
        if n == 0:
            report.append((head["name"], channels, 0, []))
            continue

        first = 1 if looping else 0
        data = [transcode(m["data"], n, first) for m in members]
        exact = []
        if verify:
            exact = [dsp_decode(d, DSP_COEFS, n) == pcm[:n] for d, pcm in zip(data, pcms)]
        per = len(data[0])
        rec = bytearray(PATCH_SIZE)
        rec[0:32] = head["name"].encode("latin-1", "replace")[:31].ljust(32, bytes(1))
        struct.pack_into("<4I", rec, 0x20, bhash(head["name"]), n,
                         len(blob), per * channels)
        struct.pack_into("<3H2B", rec, 0x30, head["pitch"], head["volume"],
                         head["effect_volume"], channels, 1 if looping else 0)
        for c in range(channels):
            struct.pack_into("<16h", rec, 0x38 + c * 32, *DSP_COEFS)
        recs.append(bytes(rec))
        for c in range(channels):
            blob += data[c]
        report.append((head["name"], channels, n, exact))

    data_off = HEADER_SIZE + PATCH_SIZE * len(recs)
    out = bytearray(data_off)
    struct.pack_into("<6I", out, 0, MAGIC, VERSION, len(recs), data_off,
                     len(blob), bhash(name))
    out[0x18:0x20] = name.encode("latin-1", "replace")[:7].ljust(8, bytes(1))
    for i, r in enumerate(recs):
        out[HEADER_SIZE + i * PATCH_SIZE: HEADER_SIZE + (i + 1) * PATCH_SIZE] = r
    return name, bytes(out) + bytes(blob), report


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src", help="a SOUND/ directory, or one .MSH inside it")
    ap.add_argument("out_dir")
    ap.add_argument("--report", action="store_true",
                    help="decode each patch back and check it is sample-exact")
    a = ap.parse_args()

    src = Path(a.src)
    mshs = sorted(src.glob("*.MSH")) if src.is_dir() else [src]
    if not mshs:
        sys.exit("no .MSH under %s" % src)
    out_dir = Path(a.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    total_p = total_b = 0
    checked = inexact = 0
    for msh in mshs:
        name, blob, report = build_bank(msh, a.report)
        (out_dir / (name + ".SBK")).write_bytes(blob)
        total_p += len(report)
        total_b += len(blob)
        if a.report:
            for pname, ch, n, exact in report:
                checked += len(exact)
                inexact += exact.count(False)
                print("  %-10s %-24s %dch %7d  %s"
                      % (name, pname, ch, n,
                         " ".join("exact" if e else "DIFFERS" for e in exact)))
        print("%-12s %3d patches, %8.1f KB"
              % (name, len(report), len(blob) / 1024.0))
    print("%d banks, %d patches, %.2f MB" % (len(mshs), total_p, total_b / 1048576.0))
    if a.report:
        print("%d channels decoded back, %d differ" % (checked, inexact))
        sys.exit(1 if inexact else 0)


if __name__ == "__main__":
    main()
