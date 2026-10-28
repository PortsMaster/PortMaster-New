"""ASTC guide files: the encoder's effort chosen per block ahead of time, on a PC.

`python -m pmunity astc-guide <data> <guide> --config game.json [--target medium|fast] [--tol 0]`

The texture step's guided mode (textures.py, guided_astc) writes the blocks that need no search
itself and hands the others (the "hard" blocks: about a quarter of Cuphead's) to astc-encoder at
one preset. Most of the setup's encoding time is that search, and most hard blocks do not need all
of it: for each one, a smaller search (a faster preset, or one or two partitions) finds a block as
good as the target preset's. Which one is only known by trying, which a PC does in minutes. A guide
file holds that choice, a tier number per hard block, and the handheld encodes each hard block at
its tier only: the target preset's quality (every block at most as far from the pixels as the
target's own block, give or take --tol) for a fraction of its search.

A guide holds no pixels: per texture level, the number of its hard blocks, a CRC of their
positions and a byte per block (zlib). The texture step uses a level's entry only when its own
hard blocks are the same ones (same count and CRC: the same pixels, scaled the same way, which the
header's settings must match too); any other texture is encoded as without a guide.

Built by running the texture step itself (the same files, order, decoding and scaling) with a
recorder that encodes each texture's hard blocks at every tier, measures each block's error against
its pixels and keeps the cheapest tier that reaches the target's.
"""
import json
import os
import struct
import tempfile
import zlib

MAGIC = b'PMUNITY-ASTC-GUIDE\n'
VERSION = 1
# (preset, limits on its settings), cheapest first (astc-encoder 4.x, 4x4 blocks, on a Mac: s per 100k
# blocks 0.048, 0.059, 0.108, 0.123, 0.135, 0.154, 0.206, 0.264, 0.29, 0.486, 0.885)
_P1, _P2 = {'tune_partition_count_limit': 1}, {'tune_partition_count_limit': 2}
TIERS = (
    ('fastest', _P1),
    ('fast', _P1),
    ('fastest', {}),
    ('fast', dict(_P2, tune_2partition_index_limit=8)),
    ('fast', _P2),
    ('medium', _P1),
    ('fast', {}),
    ('medium', dict(_P2, tune_2partition_index_limit=16)),
    ('medium', _P2),
    ('medium', {}),
    ('thorough', {}),
)
TARGETS = {'fast': 6, 'medium': 9, 'thorough': 10}
# the texture settings a guide's blocks depend on (which textures, their size, which blocks are hard)
KEYS = ('scale', 'scale_sharp', 'sharp_names', 'block', 'sharp_block', 'keep_max', 'min_side', 'min_convert',
        'mips', 'mode', 'guided_max_err', 'guided_line', 'guided_near')


def settings(c):
    return {k: c.get(k) for k in KEYS}


def rest_crc(rest):
    return zlib.crc32(rest) & 0xffffffff


class Reader:
    """A guide file opened for the texture step: codes(key, rest) -> one tier byte per hard block,
    or None (no entry, or not these blocks)."""

    def __init__(self, path, c, log=None):
        self.f = open(path, 'rb')
        if self.f.read(len(MAGIC)) != MAGIC:
            raise ValueError(f'{path}: not an ASTC guide')
        n, = struct.unpack('<I', self.f.read(4))
        self.head = json.loads(self.f.read(n))
        self.base = self.f.tell()
        self.index = self.head['index']
        self.ok = self.head.get('version') == VERSION and self.head.get('settings') == settings(c) and \
            [tuple(t) for t in self.head.get('tiers', [])] == [(p, kw) for p, kw in TIERS]
        self.used = self.missed = 0
        if not self.ok and log:
            log(f'textures: {os.path.basename(path)} was made for other texture settings: not used')

    def codes(self, key, rest):
        if not self.ok:
            return None
        e = self.index.get(key)
        if e is None or e[2] != len(rest) // 4 or e[3] != rest_crc(rest):
            self.missed += 1
            return None
        self.f.seek(self.base + e[0])
        codes = zlib.decompress(self.f.read(e[1]))
        if len(codes) != e[2] or max(codes, default=0) >= len(TIERS):
            self.missed += 1
            return None
        self.used += 1
        return codes

    def close(self):
        self.f.close()


def split(rest, codes):
    """The hard blocks' positions (int32 bytes) of each tier, in their order."""
    from array import array
    from itertools import compress
    idx = array('i')
    idx.frombytes(rest)
    out = []
    for t in range(len(TIERS)):
        mask = codes.translate(bytes(1 if i == t else 0 for i in range(256)))
        out.append(array('i', compress(idx, mask)).tobytes() if mask.count(1) else b'')
    return out


class Recorder:
    """Chooses each hard block's tier while the texture step runs on a PC (numpy, texture2ddecoder)."""

    def __init__(self, target='medium', tol=0.0):
        self.ref, self.tol = TARGETS[target], tol
        self.target = target
        self.entries = {}                    # key -> (count, crc, zlib'd codes)
        self.picked = [0] * len(TIERS)

    def choose(self, enc, G, data, w, h, block, rest, key):
        """Encodes the hard blocks at every tier; returns (codes, the blocks of the chosen tiers) and
        records the codes under key."""
        import numpy as np
        import texture2ddecoder as T
        import astc_encoder as A
        n = len(rest) // 4
        bw, bh = block
        cols = min(n, enc.GATHER_COLS)
        rows = -(-n // cols)
        sub = G.gather(data, w, h, bw, bh, rest, cols)
        src = np.frombuffer(sub, np.uint8).reshape(rows * bh, cols * bw, 4).astype(np.int32)
        encs, errs = [], []
        for i in range(len(TIERS)):
            b = enc._context(block, ('guide', i)).compress(A.ASTCImage(A.ASTCType.U8, cols * bw, rows * bh, 1, sub),
                                                           A.ASTCSwizzle.from_str('RGBA'))
            dec = np.frombuffer(T.decode_astc(b, cols * bw, rows * bh, bw, bh), np.uint8)
            dec = dec.reshape(rows * bh, cols * bw, 4)[..., [2, 1, 0, 3]].astype(np.int32)
            e = ((dec - src) ** 2).reshape(rows, bh, cols, bw, 4).sum(axis=(1, 3, 4)).reshape(-1)[:n]
            encs.append(np.frombuffer(b, np.uint8).reshape(-1, 16)[:n])
            errs.append(e)
        E = np.stack(errs)
        ok = E <= (E[self.ref] * (1 + self.tol))[None]
        ok[self.ref] = True
        ch = ok.argmax(axis=0)                       # the first (cheapest) tier that reaches it
        codes = ch.astype(np.uint8).tobytes()
        for i, k in enumerate(np.bincount(ch, minlength=len(TIERS))):
            self.picked[i] += int(k)
        chosen = np.stack(encs)[ch, np.arange(n)].tobytes()
        self.entries[key] = (n, rest_crc(rest), zlib.compress(codes, 9))
        return codes, chosen

    def save(self, path, c):
        index, blobs, off = {}, [], 0
        for k in sorted(self.entries):
            n, crc, z = self.entries[k]
            index[k] = [off, len(z), n, crc]
            blobs.append(z)
            off += len(z)
        head = json.dumps({'version': VERSION, 'target': self.target, 'tol': self.tol, 'settings': settings(c),
                           'tiers': [[p, kw] for p, kw in TIERS], 'index': index}, sort_keys=True).encode()
        tmp = path + '.tmp'
        with open(tmp, 'wb') as f:
            f.write(MAGIC + struct.pack('<I', len(head)) + head)
            for z in blobs:
                f.write(z)
        os.replace(tmp, path)
        return os.path.getsize(path)


def main(argv):
    import argparse
    import sys
    from . import textures
    from .job import Job
    ap = argparse.ArgumentParser(prog='pmunity astc-guide', description=__doc__.split('\n\n')[0])
    ap.add_argument('data'), ap.add_argument('guide')
    ap.add_argument('--config', required=True, help="the game's config (its textures settings)")
    ap.add_argument('--set', action='append', default=[], help='textures.<key>=<json value> (as convert --set)')
    ap.add_argument('--target', choices=sorted(TARGETS), default='medium', help='the preset whose blocks the tiers must match')
    ap.add_argument('--tol', type=float, default=0.0, help="a tier's block may be this much further (relative) than the target's")
    ap.add_argument('--only', default=None, help='regex on the files (a partial guide, for tests)')
    a = ap.parse_args(argv)
    cfg = json.load(open(a.config))
    cfg.setdefault('version', 1)
    for kv in a.set:
        k, _, v = kv.partition('=')
        try:
            v = json.loads(v)
        except ValueError:
            pass
        cfg.setdefault(k.partition('.')[0], {})[k.partition('.')[2]] = v
    tc = cfg.setdefault('textures', {})
    tc['mode'] = 'guided'
    tc.pop('guide', None)
    rec = Recorder(a.target, a.tol)
    with tempfile.TemporaryDirectory(prefix='astc-guide-') as out:
        job = Job(a.data, out, cfg)
        textures.run(job, a.only, recorder=rec)
    c = dict(textures.DEFAULTS, **tc)
    size = rec.save(a.guide, c)
    total = sum(rec.picked) or 1
    print(f'astc-guide: {len(rec.entries)} texture levels, {total} hard blocks, {size >> 10} KB; tiers: ' +
          ', '.join(f'{p}{"/" + str(kw.get("tune_partition_count_limit")) + "p" if kw else ""} {k * 100 / total:.1f} %'
                    for (p, kw), k in zip(TIERS, rec.picked)), file=sys.stderr)
