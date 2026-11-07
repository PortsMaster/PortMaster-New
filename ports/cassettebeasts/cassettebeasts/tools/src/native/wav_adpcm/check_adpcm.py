"""Decode converted IMA-ADPCM samples and compare them with the original PCM (SNR in dB).

usage: check_adpcm.py <original pck> <converted dir> [count]
"""
import math, os, struct, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import pck_patch as P
from sample_stats import parse_sample

STEP = [7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66,
        73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408,
        449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
        2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630,
        9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767]
IDX = [-1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8]


def decode(data, channels, ch, frames):
    out, pred, idx = [], 0, 0
    for i in range(frames):
        byte = data[(4 + i // 2) * channels + ch]  # 4 header bytes per channel, byte-interleaved
        nib = (byte >> 4) if i & 1 else (byte & 15)
        step = STEP[idx]
        diff = step >> 3
        if nib & 1: diff += step >> 2
        if nib & 2: diff += step >> 1
        if nib & 4: diff += step
        pred += -diff if nib & 8 else diff
        pred = max(-32768, min(32767, pred))
        idx = max(0, min(88, idx + IDX[nib]))
        out.append(pred)
    return out


if __name__ == '__main__':
    pck, conv_dir = sys.argv[1], sys.argv[2]
    count = int(sys.argv[3]) if len(sys.argv) > 3 else 6
    with open(pck, 'rb') as f:
        base, entries = P.read_dir(f)
        files = sorted(os.listdir(conv_dir), key=lambda n: os.path.getsize(os.path.join(conv_dir, n)))
        picks = files[len(files) // 4::max(1, len(files) // count)][:count]
        for name in picks:
            orig_path = 'res://.godot/imported/' + name
            _, off, size = entries[orig_path]
            f.seek(base + off)
            ob = f.read(size)
            op = parse_sample(ob)
            cb = open(os.path.join(conv_dir, name), 'rb').read()
            cp = parse_sample(cb)
            p, l = op['data']
            ost = 2 if op.get('stereo') else 1
            frames = min(l // (2 * ost), 200000)
            pcm = struct.unpack_from('<%dh' % (frames * ost), ob, p)
            cst = 2 if cp.get('stereo') else 1
            cd = cb[cp['data'][0]:cp['data'][0] + cp['data'][1]]
            sig = err = 0
            for ch in range(cst):
                dec = decode(cd, cst, ch, frames)
                for i in range(frames):
                    s = pcm[i * ost + ch]
                    sig += s * s
                    err += (s - dec[i]) ** 2
            snr = 10 * math.log10(sig / err) if err else float('inf')
            print(f'{snr:6.1f} dB  fmt={cp.get("format")} stereo={cp.get("stereo")} loop={cp.get("loop_mode", 0)}  {name[:60]}')
