#!/usr/bin/env python3
"""
Low-RAM Comet Striker .dat OGG packer.

The important option for the 1 GB handheld build is:
    --downmix --resample 22050

That changes music from the original 48 kHz stereo PCM representation to
22.05 kHz mono 16-bit PCM after Vorbis decoding, cutting the persistent
music PCM footprint to about 23% of the original 48 kHz stereo footprint.
"""
import argparse
import json
import os
import struct
import subprocess
import sys
import tempfile


def read_u32(data, pos):
    return struct.unpack_from('<I', data, pos)[0], pos + 4


def read_str(data, pos):
    length = data[pos]
    return data[pos + 1:pos + 1 + length], pos + 1 + length


def write_str(b: bytes) -> bytes:
    if len(b) > 255:
        raise ValueError(f"string too long for 1-byte length prefix: {b!r}")
    return bytes([len(b)]) + b


def parse_wav_loop(wav_bytes):
    """
    Walk a canonical RIFF/WAVE's chunks and pull out the sample rate (from
    'fmt ') and the first loop's start/end sample offsets (from 'smpl'), if
    present. Mirrors OeWaveFileData.FromStream's own chunk walk so that
    whatever this function finds is exactly what the game engine would have
    found in the original wav.

    Returns (sample_rate, loop_start, loop_end) or None if there's no smpl
    loop (most sound effects won't have one - that's expected, not an error).
    """
    if wav_bytes[0:4] != b'RIFF' or wav_bytes[8:12] != b'WAVE':
        return None

    pos = 12
    sample_rate = None
    loop = None

    while pos + 8 <= len(wav_bytes):
        chunk_id = wav_bytes[pos:pos + 4]
        chunk_size = struct.unpack_from('<I', wav_bytes, pos + 4)[0]
        body_start = pos + 8

        if chunk_id == b'fmt ':
            # wFormatTag(2) nChannels(2) nSamplesPerSec(4) ...
            sample_rate = struct.unpack_from('<I', wav_bytes, body_start + 4)[0]
        elif chunk_id == b'smpl':
            # 7 x u32 header fields, then cSampleLoops(u32), cbSamplerData(u32)
            num_loops = struct.unpack_from('<I', wav_bytes, body_start + 28)[0]
            if num_loops > 0:
                loop_off = body_start + 36  # first SampleLoop entry
                # CuePointID(4) Type(4) Start(4) End(4) Fraction(4) PlayCount(4)
                loop_start = struct.unpack_from('<i', wav_bytes, loop_off + 8)[0]
                loop_end = struct.unpack_from('<i', wav_bytes, loop_off + 12)[0]
                loop = (loop_start, loop_end)

        # chunks are word-aligned
        pos = body_start + chunk_size + (chunk_size & 1)

    if sample_rate is None or loop is None:
        return None
    return sample_rate, loop[0], loop[1]


def iter_container_entries(path):
    """Like parse_container, but reads one entry's header+payload directly
    off disk at a time instead of loading the whole file into memory first.
    parse_container's `data = f.read()` followed by `data[pos:pos+size]`
    slicing for every entry means the *whole* file and a second full copy
    (spread across every entry's payload) are resident simultaneously right
    before it returns - fine for a 36MB sfx.dat, but a ~700MB transient
    peak for a 344MB music.dat, which is enough to get OOM-killed on more
    memory-constrained devices before a single entry is even processed.
    This yields entries one at a time so peak memory is one entry's payload
    (tens of MB at most), not the whole archive.
    """
    with open(path, 'rb') as f:
        header = f.read(8)
        zero, pos = read_u32(header, 0)
        count, pos = read_u32(header, 4)

        yield ('header', zero, count)

        for _ in range(count):
            ver = struct.unpack('<I', f.read(4))[0]
            tag1 = _read_str_from_file(f)
            tag2 = _read_str_from_file(f)
            name = _read_str_from_file(f)
            size, flag = struct.unpack('<II', f.read(8))
            payload = f.read(size)
            yield ('entry', {
                'ver': ver, 'tag1': tag1, 'tag2': tag2,
                'name': name.decode('latin1'), 'flag': flag,
                'payload': payload,
            })


def _read_str_from_file(f):
    length = f.read(1)[0]
    return f.read(length)


def parse_container(path):
    with open(path, 'rb') as f:
        data = f.read()

    pos = 0
    zero, pos = read_u32(data, pos)
    count, pos = read_u32(data, pos)
    entries = []

    for _ in range(count):
        ver, pos = read_u32(data, pos)
        tag1, pos = read_str(data, pos)
        tag2, pos = read_str(data, pos)
        name, pos = read_str(data, pos)
        size, pos = read_u32(data, pos)
        flag, pos = read_u32(data, pos)
        payload = data[pos:pos + size]
        pos += size
        entries.append({
            'ver': ver,
            'tag1': tag1,
            'tag2': tag2,
            'name': name.decode('latin1'),
            'flag': flag,
            'payload': payload,
        })

    return zero, entries


def build_container(zero, entries, path):
    out = bytearray()
    out += struct.pack('<II', zero, len(entries))
    for e in entries:
        out += struct.pack('<I', e['ver'])
        out += write_str(e['tag1'])
        out += write_str(e['tag2'])
        out += write_str(e['name'].encode('latin1'))
        out += struct.pack('<II', len(e['payload']), e['flag'])
        out += e['payload']
    with open(path, 'wb') as f:
        f.write(out)


def cmd_pack(args):
    entry_iter = iter_container_entries(args.archive)
    kind, zero, n = next(entry_iter)
    assert kind == 'header'

    out_entries = []
    total_in = 0
    total_out = 0
    tmpdir = args.tmpdir or tempfile.gettempdir()
    os.makedirs(tmpdir, exist_ok=True)

    extra = []
    if args.downmix:
        extra.append('--downmix')
    if args.resample:
        extra += ['--resample', str(args.resample)]

    for i, (kind, e) in enumerate(entry_iter, 1):
        wav_path = os.path.join(tmpdir, f'_sfxpack_tmp_{i}.wav')
        ogg_path = os.path.join(tmpdir, f'_sfxpack_tmp_{i}.ogg')
        try:
            with open(wav_path, 'wb') as f:
                f.write(e['payload'])

            # Preserve the source wav's 'smpl' loop points across the Vorbis
            # round-trip. oggenc drops arbitrary WAV metadata chunks and the
            # runtime decoder produces a bare fmt/data WAV, so without this
            # every repacked track loses its loop points (both default to 0,
            # which is what caused the overlapping/broken looping).
            #
            # We rescale the sample offsets to the *target* sample rate here,
            # at pack time, and hand them to oggenc as plain Vorbis comments.
            # The runtime bridge reads those comments back out after
            # ov_read-ing PCM at that same target rate, so no further
            # rescaling is needed on the decode side.
            loop_comments = []
            loop_info = parse_wav_loop(e['payload'])
            if loop_info is not None:
                orig_rate, loop_start, loop_end = loop_info
                target_rate = args.resample or orig_rate
                scale = target_rate / orig_rate
                new_start = round(loop_start * scale)
                new_end = round(loop_end * scale)
                loop_comments = [
                    '-c', f'LOOPSTART={new_start}',
                    '-c', f'LOOPEND={new_end}',
                ]
                if not args.quiet:
                    print(
                        f"  {e['name']}: loop {loop_start}-{loop_end} @{orig_rate}Hz "
                        f"-> {new_start}-{new_end} @{target_rate}Hz"
                    )

            cmd = [
                args.oggenc,
                '-q', str(args.quality),
                '-Q',
            ] + extra + loop_comments + [
                '-o', ogg_path,
                wav_path,
            ]

            r = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
            if r.returncode != 0:
                print(f"oggenc failed on {e['name']}:\n{r.stderr}", file=sys.stderr)
                sys.exit(1)

            with open(ogg_path, 'rb') as f:
                payload = f.read()
        finally:
            for p in (wav_path, ogg_path):
                try:
                    os.remove(p)
                except OSError:
                    pass

        in_size = len(e['payload'])
        total_in += in_size
        total_out += len(payload)

        if not args.quiet:
            print(
                f"[{i}/{n}] {e['name']}: {in_size} -> {len(payload)} bytes "
                f"({len(payload) / max(in_size, 1) * 100:.0f}%)"
            )

        out_entries.append({
            'ver': e['ver'],
            'tag1': e['tag1'],
            'tag2': e['tag2'],
            'name': e['name'],
            'flag': e['flag'],
            'payload': payload,
        })

    build_container(zero, out_entries, args.output)
    print(f"wrote {args.output}")
    print(
        f"total: {total_in / 1e6:.2f} MB -> {total_out / 1e6:.2f} MB "
        f"({total_out / max(total_in, 1) * 100:.1f}%)"
    )


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest='cmd', required=True)

    pp = sub.add_parser('pack')
    pp.add_argument('archive')
    pp.add_argument('output')
    pp.add_argument('--quality', type=float, default=2)
    pp.add_argument('--oggenc', default='oggenc')
    pp.add_argument('--tmpdir', default=None)
    pp.add_argument('--downmix', action='store_true')
    pp.add_argument('--resample', type=int, default=None)
    pp.add_argument('--quiet', action='store_true')
    pp.set_defaults(func=cmd_pack)

    args = p.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
