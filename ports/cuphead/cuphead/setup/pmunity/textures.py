"""Conversion step `textures`: desktop texture formats -> ASTC, optionally downscaled for a small
screen.

Mali and most other handheld GPUs cannot sample BC1-BC7 (DXT, BPTC, RGTC) textures, so Unity's Android player
would decompress every one of them to RGBA32 on the CPU when it loads (a 4096x4096 atlas page: 16
MB on disk becomes 64 MB of RAM and GPU memory). This step decodes each such texture (UnityPy),
optionally scales it (Lanczos on premultiplied alpha, so transparent texels do not bleed into the
edges), and encodes it as ASTC LDR (ARM's astc-encoder), which the GPU samples directly.

What changes in the data:
  * the Texture2D: format, size, mip count, image size, and its pixels (in the .resS stream file
    next to the serialized file or inside the bundle; textures with inline pixels too, unless
    `inline` is False);
  * where a texture was scaled, what points into it in pixels, so everything keeps its size on
    screen: sprite atlas entries get Unity's own `downscaleMultiplier` (the mechanism the editor
    uses for atlas pages shrunk to a maximum size), and sprites that own their texture get their
    rect, offset, border and pixels-per-unit scaled with it.

Settings (cfg['textures'], defaults in DEFAULTS): scale, block, quality, per-name overrides
(sharp_names with scale_sharp / sharp_block), and the sizes left alone.
"""
import os
import re
import shutil

from . import bigbundle
from .unity_io import Loaded, NotOneSerializedFile

DEFAULTS = {
    'scale': 1.0,                # texture size factor (1.0 = only re-encode)
    'block': [4, 4],             # ASTC block footprint (4x4 = 8 bits per texel)
    'quality': 'medium',         # astc-encoder preset: fastest | fast | medium | thorough
    'mode': 'guided',            # guided: blocks that need no search are written directly (one colour,
                                 # close to one line, an unscaled DXT block), the others go to
                                 # astc-encoder at `quality` (guided_astc, convert/native); search:
                                 # every block through astc-encoder
    'guided_max_err': 64,        # a fitted block is kept when its squared error (16 texels x RGBA,
                                 # 8-bit) is at most this
    'guided_line': 128,          # blocks left to the encoder whose texels are this close to one line
    'guided_near': 1024,         # (or this close: the principal axis's residual, a sum of squares
                                 # as above) are searched with one partition (or at most two); -1: off.
                                 # docs/setup-speed.md, "Guided ASTC encoding"
    'sharp_names': '',           # regex: textures given scale_sharp / sharp_block instead
    'scale_sharp': 1.0,
    'sharp_block': [4, 4],
    'keep_max': 64,              # textures whose longest side is at most this are never scaled
    'min_side': 16,              # nor scaled below this
    'min_convert': 4,            # smaller textures are left as they are
    'mips': 'keep',              # keep: a texture with mipmaps gets a full ASTC mip chain; drop: one level
    'inline': True,              # also textures whose pixels are inside the serialized file
    'files': r'.',               # regex on the relative path: which files to look at
    'threads': 0,                # encoder threads, 0 = all cores
    'pipeline': 'auto',          # decode the next texture while one is encoded: true | false | auto
    'prepare_split': True,       # big textures decoded and scaled in strips on every core (same pixels)
    'solo_mb': 128,              # (pipeline auto, a system with under 2 GB of RAM) a texture of more
                                 # than this decoded is decoded and encoded alone, nothing overlapped
    'strips': True,              # big single-level textures kept at their size: decoded and encoded
                                 # a strip of rows at a time (the same blocks, far less memory)
    'guide': '',                 # an ASTC guide file (astc_guide.py, made on a PC): each hard block of a
                                 # guided texture searched at the effort the guide chose for it
    'inline_streams': False,     # bundles written with their textures' pixels inline and no .resS nodes
                                 # left, as android-data's packing makes them for Unity's Android player
                                 # (Unity 2017.4 never finishes a streamed texture): packing then only
                                 # moves them, instead of unpacking and recompressing each one again
    'spill_mb': 64,              # bundles with more than this (uncompressed) are unpacked to files
                                 # and rewritten from them (bigbundle.py): little memory, whatever
                                 # their size; 0 = always in memory
}

# Unity texture formats this step converts: name -> has alpha. Windows builds also use BC7 (RGBA),
# BC4 (one channel, sampled as (r, 0, 0, 1)) and BC5 (two, (r, g, 0, 1)); each is decoded to the
# RGBA a GPU samples from it (texture_image) and encoded like the others. BC6H (HDR half floats)
# is left as it is: ASTC LDR cannot hold it.
CONVERTIBLE = {
    'DXT1': False, 'DXT1Crunched': False, 'DXT5': True, 'DXT5Crunched': True, 'BC7': True,
    'BC4': False, 'BC5': False,
    'RGB24': False, 'RGBA32': True, 'ARGB32': True, 'BGRA32': True,
}


# ---------------------------------------------------------------- pixels

def downscale(img, w, h):
    """PIL RGBA image -> w x h, filtered with premultiplied alpha."""
    from PIL import Image
    if img.size == (w, h):
        return img
    return img.convert('RGBa').resize((w, h), Image.Resampling.LANCZOS).convert('RGBA')


def guided_module():
    """The guided_astc extension, or None when it is not installed (then every block is searched)."""
    try:
        import guided_astc
        return guided_astc
    except ImportError:
        return None


class Astc:
    """astc-encoder contexts, one per block footprint (and, guided, per search effort)."""

    PRESETS = ('fastest', 'fast', 'medium', 'thorough')
    MODES = ('guided', 'search')
    # guided: what blocks close to one line are searched with (the preset's other limits kept)
    TIERS = {'line': {'tune_partition_count_limit': 1}, 'near': {'tune_partition_count_limit': 2}, 'other': {}}
    GATHER_COLS = 256                        # blocks across the image of the blocks left to the encoder

    def __init__(self, quality, threads, mode='search', max_err=64, line=128, near=1024, log=None):
        if quality not in self.PRESETS:
            raise ValueError(f'ASTC quality {quality!r}: one of {", ".join(self.PRESETS)}')
        if mode not in self.MODES:
            raise ValueError(f'textures mode {mode!r}: one of {", ".join(self.MODES)}')
        self.quality, self.threads = quality, threads or os.cpu_count() or 4
        self.guided = guided_module() if mode == 'guided' else None
        if mode == 'guided' and self.guided is None and log:
            log('textures: guided_astc is not installed: every block is searched (mode "search")')
        self.mode = mode if self.guided else 'search'
        self.max_err, self.line, self.near = max_err, line, near
        self.counts = [0] * 6                # guided: one colour, fitted, seeded, line, near, other
        self._ctx = {}
        self.guide = self.recorder = None    # astc_guide.Reader / Recorder (guided mode)

    def _context(self, block, tier='other'):
        """tier: one of TIERS (at the quality preset), or ('guide', i): astc_guide.TIERS[i]."""
        import astc_encoder as A
        key = (tuple(block), tier)
        if key not in self._ctx:
            if isinstance(tier, tuple):
                from .astc_guide import TIERS as GT
                preset, limits = GT[tier[1]]
            else:
                preset, limits = self.quality, self.TIERS[tier]
            cfg = A.ASTCConfig(A.ASTCProfile.LDR, block[0], block[1], block_z=1,
                               quality=getattr(A.ASTCQualityPreset, preset.upper()),
                               flags=A.ASTCConfigFlags.USE_DECODE_UNORM8)
            for k, v in limits.items():
                setattr(cfg, k, min(v, getattr(cfg, k)))
            self._ctx[key] = A.ASTCContext(cfg, threads=self.threads)
        return self._ctx[key]

    def encode(self, img, block, seed=None, key=None):
        """PIL RGBA image (top row first) -> ASTC blocks, bottom row first as Unity stores textures.
        seed: (the DXT1 or DXT5 blocks these pixels were decoded from, in Unity's order, is DXT5).
        key: the texture level's name in an ASTC guide."""
        from PIL import Image
        return self.encode_rows(img.transpose(Image.Transpose.FLIP_TOP_BOTTOM), block, seed, key)

    def encode_rows(self, img, block, seed=None, key=None):
        """PIL RGBA image whose rows are already in Unity's order (bottom first) -> ASTC blocks."""
        import astc_encoder as A
        data = img.tobytes()
        if self.guided is not None:
            return self._guided_rows(data, img.width, img.height, tuple(block), seed, key)
        src = A.ASTCImage(A.ASTCType.U8, img.width, img.height, 1, data)
        return self._context(block).compress(src, A.ASTCSwizzle.from_str('RGBA'))

    def _guided_rows(self, data, w, h, block, seed, key=None):
        """guided_astc writes the blocks that need no search; each group of the others is gathered
        into one image and encoded by astc-encoder (every block on its own: the blocks it would
        write for the whole image, at that group's effort), then put in its place."""
        import astc_encoder as A
        G = self.guided
        dxt, dxt5 = seed if seed is not None and block == (4, 4) else (None, 0)
        blocks, rests, counts, _ = G.encode(data, w, h, block[0], block[1], self.max_err, self.threads,
                                            self.line, self.near, dxt, int(bool(dxt5)))
        for i, n in enumerate(counts):
            self.counts[i] += n
        groups = zip(('line', 'near', 'other'), rests)
        if key is not None and (self.guide or self.recorder) and any(rests):
            from . import astc_guide
            hard = b''.join(rests)
            if self.recorder:                # (making a guide: every tier tried, the chosen blocks kept)
                G.place(blocks, self.recorder.choose(self, G, data, w, h, block, hard, key)[1], hard)
                return bytes(blocks)
            codes = self.guide.codes(key, hard)
            if codes is not None:
                groups = ((('guide', i), part) for i, part in enumerate(astc_guide.split(hard, codes)))
        for tier, rest in groups:
            n = len(rest) // 4
            if not n:
                continue
            cols = min(n, self.GATHER_COLS)
            sub = G.gather(data, w, h, block[0], block[1], rest, cols)
            img = A.ASTCImage(A.ASTCType.U8, cols * block[0], -(-n // cols) * block[1], 1, sub)
            G.place(blocks, self._context(block, tier).compress(img, A.ASTCSwizzle.from_str('RGBA')), rest)
        return bytes(blocks)


def astc_format_id(block, alpha, unity=None):
    """Unity's TextureFormat of ASTC LDR with this footprint. Up to Unity 2018 there are RGB (48-53)
    and RGBA (54-59) formats; from 2019.1 only ASTC_<n>x<n> (48-53, alpha included: ASTC blocks
    carry it either way), the RGBA numbers being deprecated. unity: the data's version string."""
    from UnityPy.enums import TextureFormat
    if unity and int(unity.split('.')[0]) >= 2019:
        alpha = False
    return int(TextureFormat[f'ASTC_{"RGBA" if alpha else "RGB"}_{block[0]}x{block[1]}'])


def mip_chain(img, levels):
    """[img, img/2, ...] down to `levels` images (each side halved, at least 1)."""
    out = [img]
    while len(out) < levels:
        w, h = out[-1].size
        if w == 1 and h == 1:
            break
        out.append(downscale(out[-1], max(1, w // 2), max(1, h // 2)))
    return out


# ---------------------------------------------------------------- decisions

class Choice:
    __slots__ = ('block', 'width', 'height', 'alpha', 'mips')

    def __init__(self, block, width, height, alpha, mips):
        self.block, self.width, self.height, self.alpha, self.mips = block, width, height, alpha, mips


def choose(tree, fmt_name, c, sharp_rx):
    """What to do with one Texture2D (its typetree): a Choice, or None to leave it."""
    w, h = tree['m_Width'], tree['m_Height']
    if fmt_name not in CONVERTIBLE:
        return None
    if tree.get('m_IsReadable'):                       # scripts read its pixels (GetPixels): keep the format
        return None
    if tree.get('m_TextureDimension', 2) != 2 or tree.get('m_ImageCount', 1) != 1:
        return None
    if min(w, h) < c['min_convert']:
        return None
    sharp = bool(sharp_rx and sharp_rx.search(tree['m_Name']))
    s = c['scale_sharp'] if sharp else c['scale']
    if max(w, h) <= c['keep_max'] or min(w, h) * s < c['min_side']:
        s = 1.0
    nw, nh = max(1, round(w * s)), max(1, round(h * s))
    mips = tree.get('m_MipCount', 1) if c['mips'] == 'keep' else 1
    if mips > 1:
        mips = min(mips, max(nw, nh).bit_length())
    return Choice(tuple(c['sharp_block'] if sharp else c['block']), nw, nh, CONVERTIBLE[fmt_name], mips)


# ---------------------------------------------------------------- what points into a texture

def _mul(d, keys, f):
    for k in keys:
        d[k] *= f


def scale_render_data(rd, sx, sy):
    """A SpriteRenderData's pixel-space fields (its rectangle in the texture)."""
    _mul(rd['textureRect'], ('x', 'width'), sx)
    _mul(rd['textureRect'], ('y', 'height'), sy)
    rd['textureRectOffset']['x'] *= sx
    rd['textureRectOffset']['y'] *= sy
    aro = rd['atlasRectOffset']
    if (aro['x'], aro['y']) != (-1, -1):               # -1, -1: not set
        aro['x'] *= sx
        aro['y'] *= sy
    uv = rd['uvTransform']                             # (x, y) scale/offset in pixels, (z, w) likewise
    _mul(uv, ('x', 'y'), sx)
    _mul(uv, ('z', 'w'), sy)


def scale_own_sprite(sp, sx, sy):
    """A sprite drawn from its own (scaled) texture: rect, offset and border are in that texture's
    pixels; pixels-per-unit scale with it, so the sprite keeps its size in the world."""
    _mul(sp['m_Rect'], ('x', 'width'), sx)
    _mul(sp['m_Rect'], ('y', 'height'), sy)
    sp['m_Offset']['x'] *= sx
    sp['m_Offset']['y'] *= sy
    _mul(sp['m_Border'], ('x', 'z'), sx)              # left, right
    _mul(sp['m_Border'], ('y', 'w'), sy)              # bottom, top
    sp['m_PixelsToUnits'] *= sx
    scale_render_data(sp['m_RD'], sx, sy)


def fix_references(lf, sizes, stats):
    """Sprite atlases and sprites of one file that use its scaled textures. sizes: {path id of a
    texture: (old w, old h, new w, new h)}. Returns [(object, tree)] to save. (A packed sprite
    keeps its render data in the atlas's pixels: the atlas entry's multiplier covers it.)"""
    out = []
    for _, o in lf.objects('SpriteAtlas'):
        t = o.read_typetree()
        n = 0
        for _key, rd in t['m_RenderDataMap']:
            ref = rd['texture']
            if ref['m_FileID'] == 0 and ref['m_PathID'] in sizes:
                ow, _, nw, _ = sizes[ref['m_PathID']]
                rd['downscaleMultiplier'] = rd.get('downscaleMultiplier', 1.0) * nw / ow
                n += 1
        if n:
            out.append((o, t))
            stats['atlas_entries'] += n
    for _, o in lf.objects('Sprite'):
        t = o.read_typetree()
        ref = t['m_RD']['texture']
        if ref['m_FileID'] == 0 and ref['m_PathID'] in sizes:
            ow, oh, nw, nh = sizes[ref['m_PathID']]
            scale_own_sprite(t, nw / ow, nh / oh)
            out.append((o, t))
            stats['sprites'] += 1
    return out


# ---------------------------------------------------------------- files

class StreamFile:
    """The new contents of a texture stream file (.resS): blobs, each 16-byte aligned, in memory or
    (path) written to that file as they come."""

    def __init__(self, path=None):
        self.path, self.size = path, 0
        self.data = bytearray() if path is None else None
        self._f = open(path, 'wb') if path else None

    def add(self, blob):
        pad = -self.size % 16
        if self._f:
            self._f.write(b'\0' * pad)
            self._f.write(blob)
        else:
            self.data += b'\0' * pad
            self.data += blob
        off = self.size + pad
        self.size = off + len(blob)
        return off

    def close(self):
        if self._f:
            self._f.close()
            self._f = None


def _format_name(tree):
    from UnityPy.enums import TextureFormat
    try:
        return TextureFormat(tree['m_TextureFormat']).name
    except ValueError:
        return None


def texture_image(img, fmt_name):
    """A decoded texture (UnityPy's PIL image) -> the RGBA image a GPU samples from it. UnityPy
    gives BC4 as luminance (r, r, r); the GPU samples it as (r, 0, 0, 1) (and BC5 as (r, g, 0, 1),
    which UnityPy's RGB already is)."""
    if fmt_name == 'BC4':
        from PIL import Image
        r = img.convert('L')
        zero = Image.new('L', r.size, 0)
        return Image.merge('RGBA', (r, zero, zero, Image.new('L', r.size, 255)))
    return img if img.mode == 'RGBA' else img.convert('RGBA')     # (convert would copy an RGBA image)


DXT_SEED = {'DXT1': False, 'DXT5': True}     # source formats whose blocks seed guided encoding: is DXT5


def dxt_seed(o, tex, fmt_name, raw):
    """(the first level's DXT1 or DXT5 blocks, is DXT5) of an unscaled texture, for guided encoding
    (Unity stores them bottom row first, as the encoder is given the image), or None."""
    from UnityPy.enums import BuildTarget
    from UnityPy.export import Texture2DConverter as C
    if fmt_name not in DXT_SEED or not raw:
        return None
    platform = getattr(o, 'platform', BuildTarget.UnknownPlatform)
    if platform == BuildTarget.XBOX360 or C.TextureSwizzler.is_switch_swizzled(platform, getattr(tex, 'm_PlatformBlob', None)):
        return None
    n = -(-tex.m_Width // 4) * -(-tex.m_Height // 4) * (16 if DXT_SEED[fmt_name] else 8)
    return (bytes(raw[:n]), DXT_SEED[fmt_name]) if len(raw) >= n else None


STRIP_MIN_PX = 2048 * 2048      # single-level textures from this size up are converted in strips
STRIP_PX = 1 << 21              # pixels per strip (8 MB of RGBA)


def strip_blocks(o, t, raw, ch, enc, fmt_name):
    """The ASTC blocks of a single-level texture kept at its size, decoded (UnityPy's decoder) and
    encoded a strip of rows at a time, in the order Unity stores rows (bottom first) and both
    formats store blocks. The blocks are the ones the whole image gives (every block is encoded on
    its own), in a few MB instead of several copies of the whole image (an 8192x8192 atlas: 256 MB
    each). None when the data cannot be cut in rows (crunched, console-swizzled, unexpected size)."""
    from math import gcd
    from UnityPy.enums import BuildTarget, TextureFormat as TF
    from UnityPy.export import Texture2DConverter as C
    fmt = TF(t['m_TextureFormat'])
    platform = getattr(o, 'platform', BuildTarget.UnknownPlatform)
    blob = t.get('m_PlatformBlob')
    if 'Crunched' in fmt.name or platform == BuildTarget.XBOX360 or \
            C.TextureSwizzler.is_switch_swizzled(platform, blob):
        return None
    w, h = t['m_Width'], t['m_Height']
    bs = C.TEXTURE_FORMAT_BLOCK_SIZE_TABLE.get(fmt)
    bh = bs[1] if bs else 1                          # the source's rows of blocks (or of pixels)
    units = C.get_compressed_image_size(w, h, fmt)[1] // bh
    if not units or len(raw) % units:
        return None
    per = len(raw) // units
    step = bh * ch.block[1] // gcd(bh, ch.block[1])
    rows = max(step, STRIP_PX // w // step * step)
    out = []
    for y in range(0, h, rows):
        sh = min(rows, h - y)
        part = raw[y // bh * per:-(-(y + sh) // bh) * per]
        img = C.parse_image_data(part, w, sh, fmt, getattr(o, 'version', (0, 0, 0, 0)), platform, blob, flip=False)
        seed = (part, DXT_SEED[fmt_name]) if fmt_name in DXT_SEED else None
        out.append(enc.encode_rows(texture_image(img, fmt_name), ch.block, seed))
        del img
    return b''.join(out)


def mem_total_mb():
    """The system's RAM in MB (Linux; elsewhere: plenty)."""
    try:
        with open('/proc/meminfo') as f:
            for line in f:
                if line.startswith('MemTotal:'):
                    return int(line.split()[1]) >> 10
    except OSError:
        pass
    return 1 << 20


PREP_MIN_PX = 1 << 20           # textures from this size up are decoded and scaled on every core


def decode_parallel(o, tex, pool, cores):
    """tex.image (UnityPy's decoder, top row first) decoded a strip of block rows per task: block
    formats decode every block on its own, so the pixels are the same as one decode. None when the
    data cannot be cut in rows (as strip_blocks)."""
    from UnityPy.enums import BuildTarget, TextureFormat as TF
    from UnityPy.export import Texture2DConverter as C
    from PIL import Image
    fmt = TF(tex.m_TextureFormat)
    platform = getattr(o, 'platform', BuildTarget.UnknownPlatform)
    blob = getattr(tex, 'm_PlatformBlob', None)
    if 'Crunched' in fmt.name or platform == BuildTarget.XBOX360 or \
            C.TextureSwizzler.is_switch_swizzled(platform, blob):
        return None
    w, h, raw = tex.m_Width, tex.m_Height, tex.get_image_data()      # (streamed data read as .image does)
    bs = C.TEXTURE_FORMAT_BLOCK_SIZE_TABLE.get(fmt)
    bh = bs[1] if bs else 1
    units = C.get_compressed_image_size(w, h, fmt)[1] // bh
    if not raw or not units or len(raw) % units:
        return None
    per = len(raw) // units
    rows = max(bh, -(-h // (4 * cores)) // bh * bh)      # a few strips per core
    version = getattr(o, 'version', (0, 0, 0, 0))

    def strip(y):
        sh = min(rows, h - y)
        part = raw[y // bh * per:-(-(y + sh) // bh) * per]
        return y, C.parse_image_data(part, w, sh, fmt, version, platform, blob, flip=False)
    img = None
    for y, part in pool.map(strip, range(0, h, rows)):               # rows bottom first, as stored
        img = img or Image.new(part.mode, (w, h))
        img.paste(part, (0, y))
    return img.transpose(Image.Transpose.FLIP_TOP_BOTTOM)


def downscale_parallel(img, w, h, pool, cores):
    """downscale() a strip of output rows per task (Pillow's box= reads the rows around each strip
    as one resize would). Only where every strip edge falls on a whole source row and the strip's
    scale is the whole image's, so each output row gets the same filter: the same pixels as
    downscale(). None otherwise."""
    from math import gcd
    from PIL import Image
    W, H = img.size
    if (W, H) == (w, h):
        return img
    unit = h // gcd(H, h)                                    # output rows per whole number of source rows
    n = min(4 * cores, h // unit)
    if n < 2:
        return None
    bounds = [round(i * (h // unit) / n) * unit for i in range(n + 1)]
    if any(abs((b1 * H // h - b0 * H // h) / (b1 - b0) - H / h) > 0 for b0, b1 in zip(bounds, bounds[1:])):
        return None
    pm = img.convert('RGBa')

    def strip(i):
        y0, y1 = bounds[i], bounds[i + 1]
        return y0, pm.resize((w, y1 - y0), Image.Resampling.LANCZOS, box=(0, y0 * H // h, W, y1 * H // h))
    out = Image.new('RGBa', (w, h))
    for y0, part in pool.map(strip, range(n)):
        out.paste(part, (0, y0))
    return out.convert('RGBA')


HUGE_PX = 1 << 24              # textures from 4096 x 4096 up that are scaled: decoded a band at a time


def decode_downscale(o, tex, w, h, fmt_name, pool=None):
    """downscale(texture_image(tex.image)) without the whole decoded image: each band of output
    rows is scaled from just the source rows its Lanczos filter reads (decoded from the block rows
    holding them), so a 8192 x 8192 texture needs a few bands' memory instead of its 256 MB plus
    copies (Cuphead's DLC map atlas, killed on 1 GB handhelds). Every output row gets the same
    filter and the same source pixels as one resize: the same image. None when the data cannot be
    cut in rows (as decode_parallel)."""
    from math import ceil, floor
    from UnityPy.enums import BuildTarget, TextureFormat as TF
    from UnityPy.export import Texture2DConverter as C
    from PIL import Image
    fmt = TF(tex.m_TextureFormat)
    platform = getattr(o, 'platform', BuildTarget.UnknownPlatform)
    blob = getattr(tex, 'm_PlatformBlob', None)
    if 'Crunched' in fmt.name or platform == BuildTarget.XBOX360 or \
            C.TextureSwizzler.is_switch_swizzled(platform, blob):
        return None
    W, H, raw = tex.m_Width, tex.m_Height, tex.get_image_data()
    bs = C.TEXTURE_FORMAT_BLOCK_SIZE_TABLE.get(fmt)
    bh = bs[1] if bs else 1
    units = C.get_compressed_image_size(W, H, fmt)[1] // bh
    if not raw or not units or len(raw) % units:
        return None
    per = len(raw) // units
    version = getattr(o, 'version', (0, 0, 0, 0))
    sy = H / h
    margin = ceil(3 * max(sy, 1.0)) + 2                       # Lanczos' support (3 taps, scaled) and a row
    rows = max(1, int(512 / sy))                              # output rows a band (about 512 source rows)

    def band(y0):
        y1 = min(h, y0 + rows)
        a, b = max(0, floor(y0 * sy) - margin), min(H, ceil(y1 * sy) + margin)    # source rows, top first
        s0, s1 = (H - b) // bh * bh, min(H, -(-(H - a) // bh) * bh)              # stored rows (bottom first)
        part = C.parse_image_data(raw[s0 // bh * per:s1 // bh * per], W, s1 - s0, fmt, version, platform, blob, flip=False)
        top = part.transpose(Image.Transpose.FLIP_TOP_BOTTOM)    # top first: row r is source row H - s1 + r
        off = H - s1
        img = texture_image(top.crop((0, a - off, W, b - off)), fmt_name).convert('RGBa')
        return y0, img.resize((w, y1 - y0), Image.Resampling.LANCZOS, box=(0, y0 * sy - a, W, y1 * sy - a))
    out = Image.new('RGBa', (w, h))
    for y0, part in (pool.map(band, range(0, h, rows)) if pool else map(band, range(0, h, rows))):
        out.paste(part, (0, y0))
    return out.convert('RGBA')


def _prepare(o, ch, fmt_name=None, pool=None, cores=1, seeds=False):
    """Decoded and scaled mip levels of one texture (runs on the worker thread; with pool, a big
    texture's decoding and scaling are split over every core, with the same pixels). seeds: also
    the first level's DXT blocks when it keeps its size (dxt_seed): returns (levels, seed)."""
    tex = o.read()
    seed = None
    if seeds and fmt_name in DXT_SEED and (ch.width, ch.height) == (tex.m_Width, tex.m_Height):
        seed = dxt_seed(o, tex, fmt_name, tex.get_image_data())
    huge = ch is not None and tex.m_Width * tex.m_Height >= HUGE_PX and (ch.width, ch.height) != (tex.m_Width, tex.m_Height)
    small = huge and decode_downscale(o, tex, ch.width, ch.height, fmt_name, pool)
    if small:
        levels = mip_chain(small, ch.mips)
    elif pool is None or ch is None:
        img = texture_image(tex.image, fmt_name)
        levels = mip_chain(downscale(img, ch.width, ch.height), ch.mips)
    else:
        big = tex.m_Width * tex.m_Height >= PREP_MIN_PX
        img = (big and decode_parallel(o, tex, pool, cores)) or tex.image
        img = texture_image(img, fmt_name)
        small = (big and downscale_parallel(img, ch.width, ch.height, pool, cores)) or downscale(img, ch.width, ch.height)
        levels = mip_chain(small, ch.mips)
    return (levels, seed) if seeds else levels


def convert_file(lf, rel, c, enc, sharp_rx, read_stream, stats, log, stream=None):
    """Converts the textures of one opened file into stream (a StreamFile; default: in memory).
    Returns (stream name, the StreamFile or None, {path id: sizes}) or None when nothing changed.

    Decoding and scaling a texture (one core each) run on a worker thread while the previous
    texture is encoded (ASTC on every core), one texture ahead at most. Everything else, and every
    other read of the file, happens with the worker idle, in the textures' order, so the output is
    the same as one texture after the other (c['pipeline'] = False does exactly that)."""
    unity = getattr(lf.sf, 'unity_version', None)
    from concurrent.futures import ThreadPoolExecutor
    stream_name = None
    stream = stream if stream is not None else StreamFile()
    sizes, save, converted = {}, [], 0
    items = [(pid, o, o.read_typetree()) for pid, o in lf.objects('Texture2D')]   # (no reads later)
    pool = ThreadPoolExecutor(max_workers=1) if c.get('pipeline', True) else None
    prep = ThreadPoolExecutor(max_workers=enc.threads) if c.get('prepare_split', True) else None
    # (what overlaps a texture's decoding is the encoding of the one before, which holds only its
    # scaled levels: a few MB beside the decode's own peak. Only the largest decodes go alone)
    solo_px = (c.get('solo_mb', 128) << 20) // 4 if c.get('pipeline', True) == 'auto' and mem_total_mb() < 2048 else None
    pending = []

    def finish():
        while pending:
            pid, o, t, sd, streamed, ch, fut = pending.pop(0)
            levels, seed = fut.result() if pool else _prepare(o, ch, _format_name(t), prep, enc.threads, True)
            blob = b''.join(enc.encode(level, ch.block, seed if i == 0 else None, f'{rel}|{pid}|{i}')
                            for i, level in enumerate(levels))
            nlevels = len(levels)
            del levels
            store(pid, o, t, sd, streamed, ch, blob, nlevels)

    def store(pid, o, t, sd, streamed, ch, blob, nlevels):
        nonlocal converted
        old = (t['m_Width'], t['m_Height'])
        if (ch.width, ch.height) != old:
            sizes[pid] = (old[0], old[1], ch.width, ch.height)
        stats['in'] += sd.get('size') or len(t.get('image data') or b'')
        stats['out'] += len(blob)
        t['m_TextureFormat'] = astc_format_id(ch.block, ch.alpha, unity)
        t['m_Width'], t['m_Height'], t['m_MipCount'] = ch.width, ch.height, nlevels
        t['m_CompleteImageSize'] = len(blob)
        if streamed:
            t['m_StreamData'] = dict(sd, offset=stream.add(blob), size=len(blob))
            t['image data'] = b''
        else:
            t['image data'] = blob
        save.append((o, t))
        converted += 1

    try:
        for pid, o, t in items:
            sd = t.get('m_StreamData') or {}
            streamed = bool(sd.get('size'))
            if streamed:
                name = sd['path']
                if stream_name not in (None, name):
                    raise ValueError(f'{rel}: textures stream from more than one file ({stream_name}, {name})')
                stream_name = name
            elif not c['inline'] or not t.get('image data'):
                continue
            ch = choose(t, _format_name(t), c, sharp_rx)
            if ch is not None and c['strips'] and ch.mips == 1 and t.get('m_MipCount', 1) == 1 and \
                    (ch.width, ch.height) == (t['m_Width'], t['m_Height']) and ch.width * ch.height >= STRIP_MIN_PX:
                finish()                                   # (the worker is idle while the file is read)
                raw = read_stream(sd['path'], sd['offset'], sd['size']) if streamed else t['image data']
                blob = strip_blocks(o, t, raw, ch, enc, _format_name(t))
                del raw
                if blob is not None:
                    store(pid, o, t, sd, streamed, ch, blob, 1)
                    continue
            if ch is None:
                if streamed:                               # copied into the new stream file unchanged
                    finish()                               # (the worker is idle while the file is read)
                    blob = read_stream(sd['path'], sd['offset'], sd['size'])
                    t['m_StreamData'] = dict(sd, offset=stream.add(blob))
                    save.append((o, t))
                continue
            solo = pool and solo_px and t['m_Width'] * t['m_Height'] > solo_px
            if solo:                                       # a big one on a small system: alone
                finish()
            fut = pool.submit(_prepare, o, ch, _format_name(t), prep, enc.threads, True) if pool else None
            finish()                                       # the previous one, while this one is prepared
            pending.append((pid, o, t, sd, streamed, ch, fut))
            if solo:
                finish()
        finish()
    finally:
        if pool:
            pool.shutdown(wait=True)
        if prep:
            prep.shutdown(wait=True)
    if not converted:
        return None
    if stream_name:
        # everything else that streams from the same file goes along (Unity 2018+ meshes; cubemaps,
        # texture arrays, 3D textures): the stream file is rewritten
        for _, o in lf.objects():
            if o.type.name not in OTHER_STREAMED:
                continue
            t = o.read_typetree()
            sd = t.get('m_StreamData') or {}
            if sd.get('size') and sd.get('path') == stream_name:
                t['m_StreamData'] = dict(sd, offset=stream.add(read_stream(sd['path'], sd['offset'], sd['size'])))
                save.append((o, t))
    stats['textures'] += converted
    save += fix_references(lf, sizes, stats)
    for o, t in save:
        o.save_typetree(t)
    stream.close()
    return stream_name, (stream if stream_name else None), sizes


# classes besides Texture2D whose data can be in a .resS stream (StreamingInfo m_StreamData)
OTHER_STREAMED = ('Mesh', 'Cubemap', 'CubemapArray', 'Texture2DArray', 'Texture3D')


def texture_files(job, files_rx):
    rx = re.compile(files_rx)
    out = job.list('', lambda n: (n.endswith('.assets') or n == 'globalgamemanagers' or re.match(r'level\d+$', n)))
    for d, _, names in os.walk(os.path.join(job.src, 'StreamingAssets')):
        rel = os.path.relpath(d, job.src)
        for n in sorted(names):
            p = os.path.join(d, n)
            try:
                with open(p, 'rb') as f:
                    if f.read(8) == b'UnityFS\0':
                        out.append(os.path.join(rel, n))
            except OSError:
                pass
    return [r for r in out if rx.search(r)]


def run(job, only=None, recorder=None):
    """recorder: an astc_guide.Recorder (making a guide)."""
    c = dict(DEFAULTS, **job.cfg.get('textures', {}))
    sharp_rx = re.compile('(?i)' + c['sharp_names']) if c['sharp_names'] else None
    enc = Astc(c['quality'], c['threads'], c['mode'], c['guided_max_err'], c['guided_line'], c['guided_near'], job.log)
    if enc.mode == 'guided':
        enc.recorder = recorder
        if c['guide'] and recorder is None:
            from . import astc_guide
            if os.path.isfile(c['guide']):
                enc.guide = astc_guide.Reader(c['guide'], c, job.log)
            else:
                job.log(f'textures: no ASTC guide at {c["guide"]}')
    elif recorder is not None:
        raise SystemExit('an ASTC guide needs the guided mode (guided_astc installed)')
    stats = dict(textures=0, sprites=0, atlas_entries=0, **{'in': 0, 'out': 0})
    files = texture_files(job, c['files'])
    if only:
        files = [f for f in files if re.search(only, f)]
    for i, rel in enumerate(files, 1):
        if job.is_done('textures', rel):
            continue
        src = job.path_in(rel)
        spilled = c['spill_mb'] and bigbundle.size(src) > c['spill_mb'] << 20
        beside = sum(os.path.getsize(p) for p in (src + '.resS', os.path.splitext(src)[0] + '.resS',
                                                   os.path.splitext(src)[0] + '.resource') if os.path.isfile(p))
        job.need_space(os.path.getsize(src) + beside + (64 << 20) + (bigbundle.size(src) * 2 if spilled else 0),
                       f'convert {rel}')
        before = (stats['in'], stats['out'])
        res_dir = os.path.dirname(os.path.join(job.src, rel))
        handles = {}
        work = job.work_dir('textures')
        try:
            lf = Loaded(src, res_dir, spill_dir=os.path.join(work, 'nodes'), spill_mb=c['spill_mb'])
        except NotOneSerializedFile as ex:
            job.log(f'textures: {rel}: left as it is ({ex})')
            lf = r = None
        if lf is not None:
            # the new stream: written to a file as it is made, except for a bundle held in memory
            stream = StreamFile() if lf.is_bundle and not lf.spilled else StreamFile(os.path.join(work, 'stream.new'))

            def read_stream(path, off, size):
                name = os.path.basename(path)
                if lf.is_bundle:
                    node = lf.bundle_res(name)
                    return bytes(node[off:off + size])
                p = job.path_in(os.path.join(os.path.dirname(rel), name))
                if not os.path.exists(p):
                    p = os.path.join(res_dir, name)
                if p not in handles:
                    handles[p] = open(p, 'rb')
                handles[p].seek(off)
                return handles[p].read(size)

            try:
                r = convert_file(lf, rel, c, enc, sharp_rx, read_stream, stats, job.log, stream)
            finally:
                for h in handles.values():
                    h.close()
                stream.close()
            if r is not None:
                stream_name, new_stream, sizes = r
                stream_node = os.path.basename(stream_name) if stream_name else None
                if lf.is_bundle:
                    if new_stream is not None:
                        lf.set_bundle_res(stream_node, new_stream.path if lf.spilled else new_stream.data)
                    lf.write_to(job, rel, inline=c['inline_streams'])
                else:
                    sf_new = os.path.join(work, 'file.new')
                    with open(sf_new, 'wb') as f:
                        f.write(lf.save())
                    lf.close()
                    pair = [(rel, sf_new)]
                    if new_stream is not None:
                        pair.insert(0, (os.path.join(os.path.dirname(rel), stream_node), new_stream.path))
                    job.commit(pair)                   # the file and its stream together
                if sizes:
                    job.state['scaled'][rel] = {str(k): list(v) for k, v in sizes.items()}
                r = True
            lf.close()
            stream = None
        shutil.rmtree(work, ignore_errors=True)
        try:
            os.rmdir(os.path.dirname(work))
        except OSError:
            pass
        job.mark_done('textures', rel)
        if r is not None:
            job.log(f'textures: {rel}: {(stats["in"] - before[0]) >> 20} -> {(stats["out"] - before[1]) >> 20} MB ({i}/{len(files)})')
    job.log(f'textures: {stats["textures"]} converted ({stats["in"] >> 20} -> {stats["out"] >> 20} MB), '
            f'{stats["atlas_entries"]} atlas entries and {stats["sprites"]} sprites follow their scaled textures')
    if enc.guide:
        job.log(f'textures: ASTC guide: {enc.guide.used} texture levels guided, {enc.guide.missed} not in it '
                f'(searched at {c["quality"]})')
        enc.guide.close()
    if enc.mode == 'guided' and sum(enc.counts):
        job.log('textures: guided blocks: ' + ', '.join(
            f'{k} {n * 100 / sum(enc.counts):.1f} %' for k, n in
            zip(('one colour', 'fitted', 'DXT seed', 'one partition', 'two partitions', 'searched'), enc.counts)))
    return stats
