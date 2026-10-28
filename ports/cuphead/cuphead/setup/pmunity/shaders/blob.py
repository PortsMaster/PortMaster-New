"""Unity's compiled shader programs: the per-platform program blob of a Shader asset.

A Shader (Unity 5.5 and later) keeps its compiled programs in `compressedBlob`, LZ4 blocks per
shader compiler platform (`platforms`, with `offsets`, `compressedLengths`, `decompressedLengths`).

Up to Unity 2019.2 a platform has one block; decompressed it is

    int32 count
    count x (int32 offset, int32 length)       entries, offsets from the blob's start
    entries

From 2019.3 a platform's blob is cut into segments (Unity's "shader variant chunks"; the three
lists hold one list per platform, a block per segment). The entry table is at the start of
segment 0 and its entries are 12 bytes, (int32 offset, int32 length, int32 segment): an entry is
read from its segment's decompressed bytes at that offset. ShaderBlobs reads and writes both forms;
a new platform's entries keep the segments of the entries they were made from.

Every entry is one serialized subprogram:

    int32 version                              the serializer's date (SERIALIZERS)
    int32 gpu program type                     6 GLCore32, 4 GLES3, 15-22 D3D11, 23/24 Metal, ...
    int32 x 4                                  statistics (ALU, TEX, flow, temp registers)
    string[] keywords                          int32 count, then each: int32 length, bytes, pad to 4
    string[] local keywords                    2019.1 - 2021.1 only (serializer 201806140)
    string code                                int32 length, bytes, pad to 4 (GL: GLSL source;
                                               D3D11: Unity's 6-byte header + DXBC, see dxbc.py)
    bytes                                      binding info (kept as is; dxbc.Bindings): the vertex
                                               channel source map and channels, then up to 2021.1
                                               the constant buffers and bindings

From 2021.2 (serializer 202012090) the constant buffers and bindings are entries of their own in
the same blob (ParamEntry: int32 version, then the binding info from the constant buffers on); a
subprogram names its code entry by m_BlobIndex and its parameter entry by the program's
m_ParameterBlobIndices. Code entries then end after the channels. 6000.6 (serializer 202605290)
lays the parameter entries out anew (dxbc's docstring; dxbc.Bindings typed).

The layouts in SERIALIZERS are checked by writing every entry back byte for byte (Unity's own
built-in resources of every LTS line, 2017.4 - 2022.3, and Cuphead's 5914 GLCore entries). For
another version the entries are tried with each candidate layout; one is only taken when the
keywords decode, the code is GLSL (or DXBC) and the entry writes back to the same bytes, and the
converter says so (Entry.guessed). GL, D3D11, Vulkan (a stage table + SMOL-V modules) and Metal
(Unity's 0xf00dcafe header + MSL) entries are parsed; others are kept as they are.
"""
import struct

import lz4.block

# shader compiler platforms (ShaderCompilerPlatform)
PLATFORM_D3D11, PLATFORM_GLES20, PLATFORM_GLES3PLUS, PLATFORM_METAL, PLATFORM_GLCORE, PLATFORM_VULKAN = 4, 5, 9, 14, 15, 18
# GPU program types (ShaderGpuProgramType, the same numbers in Unity 5.5 - 2022.3)
GPU_GLES31AEP, GPU_GLES31, GPU_GLES3, GPU_GLES = 2, 3, 4, 5
GPU_GLCORE32, GPU_GLCORE41, GPU_GLCORE43 = 6, 7, 8
GPU_SPIRV = 25                                  # Vulkan
GPU_METAL_VS, GPU_METAL_FS = 23, 24
METAL_MAGIC = b'\xfe\xca\x0d\xf0'                # (0xf00dcafe: Unity's header before a Metal program's MSL)


class Layout:
    """What a serializer version writes: statistics ints, keyword lists, parameters apart."""

    def __init__(self, unity, stats, keyword_lists, separate_params):
        self.unity, self.stats, self.keyword_lists, self.separate_params = unity, stats, keyword_lists, separate_params


SERIALIZERS = {
    201609010: Layout('5.5 - 2017.2', 4, 1, False),       # Unity 5.6.7, 2017.1.5, 2017.2.5's built-ins
    201708220: Layout('2017.3 - 2018.1', 4, 1, False),     # Cuphead 1.3.4: 5914 GLCore entries; Unity 2017.4's built-ins
    201802150: Layout('2018.2 - 2018.4', 4, 1, False),     # Unity 2018.4.36's built-ins
    201806140: Layout('2019.1 - 2021.1', 4, 2, False),     # Unity 2019.4.40, 2020.3.48's built-ins
    202012090: Layout('2021.2 - 6000.5', 4, 1, True),      # Unity 2021.3.45 - 6000.5.11's built-ins
    202605290: Layout('6000.6', 4, 1, True),               # Unity 6000.6's built-ins: written as 202012090
}
LAYOUTS = {v: l.stats for v, l in SERIALIZERS.items()}     # (older name: version -> statistics ints)
_CANDIDATES = [(n, k) for n in (4, 3, 5, 2) for k in (1, 2)]    # unknown versions, most likely first


def _pad4(n):
    return (n + 3) & ~3


def _is_d3d11(code):
    """D3D11 program code: Unity's header (6 bytes up to 2018.4, 38 from 2019.1), then a DXBC
    container (dxbc.py)."""
    i = code.find(b'DXBC', 0, 64)
    return i >= 6 and len(code) >= i + 32


def _is_vulkan(code):
    """Vulkan program code: int32 flags, a table of (int32 offset, int32 size) per stage, then the
    stages' SPIR-V modules, SMOL-V compressed (vulkan.py): a stage at its offset starts with
    SMOL-V's or SPIR-V's magic."""
    if len(code) < 20:
        return False
    first, p, found = len(code), 4, False
    while p + 8 <= first and p < 4 + 8 * 9:     # at most 9 stage slots (2022.1+: more data after them)
        off, size = struct.unpack_from('<ii', code, p)
        if size:
            if size < 0 or off < p + 8 or off + size > len(code) or code[off:off + 4] not in (b'LOMS', b'\x03\x02\x23\x07'):
                return False
            first, found = min(first, off), True
        p += 8
    return found


def _strings(data, p):
    n, = struct.unpack_from('<i', data, p); p += 4
    if not 0 <= n < 4096:
        return None, p
    out = []
    for _ in range(n):
        k, = struct.unpack_from('<i', data, p)
        if not 0 < k < 1024 or p + 4 + k > len(data):
            return None, p
        out.append(bytes(data[p + 4:p + 4 + k]).decode('ascii'))
        p = _pad4(p + 4 + k)
    return out, p


def _wstrings(out, strs):
    out += struct.pack('<i', len(strs))
    for k in strs:
        b = k.encode('ascii')
        out += struct.pack('<i', len(b)) + b + b'\0' * (_pad4(len(b)) - len(b))


class Entry:
    """One subprogram of a platform blob (local_keywords: None for layouts with one keyword list)."""

    __slots__ = ('version', 'gpu_type', 'stats', 'keywords', 'local_keywords', 'code', 'rest', 'guessed')

    def __init__(self, version, gpu_type, stats, keywords, code, rest, local_keywords=None):
        self.version, self.gpu_type, self.stats = version, gpu_type, list(stats)
        self.keywords, self.code, self.rest = list(keywords), code, rest
        self.local_keywords = None if local_keywords is None else list(local_keywords)
        self.guessed = False

    @classmethod
    def parse(cls, data):
        version, gpu_type = struct.unpack_from('<ii', data)
        lay = SERIALIZERS.get(version)
        if lay is not None:
            e = cls._try(data, version, gpu_type, lay.stats, lay.keyword_lists)
            if e is None:
                raise ValueError(f'shader program entry (serializer {version}, gpu type {gpu_type}) does not match its layout')
            return e
        for n, k in _CANDIDATES:
            e = cls._try(data, version, gpu_type, n, k)
            if e is not None:
                e.guessed = True
                return e
        raise ValueError(f'shader program entry (serializer {version}, gpu type {gpu_type}): unknown layout')

    @classmethod
    def _try(cls, data, version, gpu_type, nstats, nlists):
        try:
            p = 8
            stats = struct.unpack_from('<%di' % nstats, data, p); p += 4 * nstats
            kws, p = _strings(data, p)
            if kws is None:
                return None
            local = None
            if nlists == 2:
                local, p = _strings(data, p)
                if local is None:
                    return None
            n, = struct.unpack_from('<i', data, p)
            if not 0 <= n <= len(data) - p - 4:
                return None
            code = bytes(data[p + 4:p + 4 + n])
            rest = bytes(data[_pad4(p + 4 + n):])
            if _is_d3d11(code):
                pass                            # D3D11: Unity's header + DXBC (dxbc.py)
            elif gpu_type == GPU_SPIRV and _is_vulkan(code):
                pass                            # Vulkan: a stage table + SMOL-V modules (vulkan.py)
            elif gpu_type in (GPU_METAL_VS, GPU_METAL_FS) and code[:4] == METAL_MAGIC:
                pass                            # Metal: Unity's header + MSL text (metal.py)
            elif code and not code.lstrip()[:1] in (b'#', b'/'):
                return None
            else:
                code.decode('utf-8')
            if b'#version' in rest or b'DXBC' in rest:
                return None                     # the code is further on: a list was taken for it
            e = cls(version, gpu_type, stats, kws, code, rest, local)
        except (struct.error, UnicodeDecodeError):
            return None
        return e if e.serialize() == bytes(data) else None

    def serialize(self):
        out = bytearray(struct.pack('<ii', self.version, self.gpu_type))
        out += struct.pack('<%di' % len(self.stats), *self.stats)
        _wstrings(out, self.keywords)
        if self.local_keywords is not None:
            _wstrings(out, self.local_keywords)
        out += struct.pack('<i', len(self.code)) + self.code + b'\0' * (_pad4(len(self.code)) - len(self.code))
        out += self.rest
        return bytes(out)

    def copy(self):
        e = Entry(self.version, self.gpu_type, self.stats, self.keywords, self.code, self.rest, self.local_keywords)
        e.guessed = self.guessed
        return e


class ParamEntry:
    """2021.2+: the parameters of a subprogram as an entry of their own (int32 serializer version,
    then the binding info from the constant buffers on, dxbc.Bindings without the source map and
    channels). Kept as bytes; the GL platforms of Unity's builds share them unchanged."""

    __slots__ = ('version', 'data')
    gpu_type, code, guessed = None, b'', False

    def __init__(self, version, data):
        self.version, self.data = version, bytes(data)

    @classmethod
    def parse(cls, data):
        version, = struct.unpack_from('<i', data)
        return cls(version, data[4:])

    def serialize(self):
        return struct.pack('<i', self.version) + self.data

    def copy(self):
        return ParamEntry(self.version, self.data)


class RawEntry:
    """An entry kept as its bytes: one that does not parse as a program and that no subprogram of
    the platform names as its program or parameters (e.g. 2021.2+ parameters only a left-out
    variant used)."""

    __slots__ = ('data',)
    gpu_type, code, guessed, keywords, local_keywords = None, b'', False, (), None

    def __init__(self, data):
        self.data = bytes(data)

    def serialize(self):
        return self.data

    def copy(self):
        return RawEntry(self.data)


def _table(seg0, nested):
    """[(offset, length, segment)] of a platform blob's entry table."""
    count, = struct.unpack_from('<i', seg0)
    if nested:
        return [struct.unpack_from('<iii', seg0, 4 + 12 * i) for i in range(count)]
    return [struct.unpack_from('<ii', seg0, 4 + 8 * i) + (0,) for i in range(count)]


def parse_blob(data, params=(), nested=None, programs=None):
    """A decompressed platform blob -> list of Entry (ParamEntry for the indices in `params`, None
    for an empty slot). data: bytes (one block, up to 2019.2) or a list of segments (2019.3+).
    programs: the indices subprograms name as programs; any other entry that does not parse as one
    is kept as a RawEntry (None: every entry not in `params` must parse)."""
    segs = data if isinstance(data, list) else [data]
    if nested is None:
        nested = isinstance(data, list)
    out = []
    for i, (off, length, seg) in enumerate(_table(segs[0], nested)):
        if not length:
            out.append(None)
            continue
        b = bytes(segs[seg][off:off + length])
        if i in params:
            out.append(ParamEntry.parse(b))
            continue
        try:
            out.append(Entry.parse(b))
        except ValueError:
            if programs is None or i in programs:
                raise
            out.append(RawEntry(b))
    return out


def blob_segments(data):
    """The segment of every entry of a segmented blob (list of decompressed segments)."""
    return [s for _, _, s in _table(data[0], True)]


def build_blob(entries):
    """List of Entry -> decompressed platform blob of one block (entries 4-aligned, in order)."""
    head = 4 + 8 * len(entries)
    body = bytearray()
    table = []
    for e in entries:
        b = e.serialize() if e is not None else b''
        table.append((head + len(body), len(b)))
        body += b
        body += b'\0' * (_pad4(len(body)) - len(body))
    out = bytearray(struct.pack('<i', len(entries)))
    for off, n in table:
        out += struct.pack('<ii', off, n)
    return bytes(out + body)


def build_segments(entries, segments=None):
    """List of Entry (and the segment of each, default 0) -> the decompressed segments of a 2019.3+
    blob: segment 0 starts with the 12-byte entry table, each segment holds its entries in order."""
    segments = list(segments) if segments is not None else [0] * len(entries)
    nseg = max(segments, default=0) + 1
    head = 4 + 12 * len(entries)
    bodies = [bytearray() for _ in range(nseg)]
    table = []
    for e, s in zip(entries, segments):
        b = e.serialize() if e is not None else b''
        table.append(((head if s == 0 else 0) + len(bodies[s]), len(b), s))
        bodies[s] += b
        bodies[s] += b'\0' * (_pad4(len(bodies[s])) - len(bodies[s]))
    seg0 = bytearray(struct.pack('<i', len(entries)))
    for t in table:
        seg0 += struct.pack('<iii', *t)
    return [bytes(seg0 + bodies[0])] + [bytes(b) for b in bodies[1:]]


class ShaderBlobs:
    """The per-platform blobs of one Shader typetree (dict from UnityPy read_typetree); the tree's
    other fields are not touched until store(). platforms: {platform: decompressed blob (bytes), or
    its list of segments (2019.3+)}."""

    def __init__(self, tree):
        self.tree = tree
        raw = bytes(tree['compressedBlob'])
        offs = tree['offsets']
        self.nested = bool(offs) and isinstance(offs[0], list)
        self.platforms = {}
        for i, plat in enumerate(tree['platforms']):
            o, c, d = offs[i], tree['compressedLengths'][i], tree['decompressedLengths'][i]
            if self.nested:
                self.platforms[plat] = [lz4.block.decompress(raw[a:a + b], uncompressed_size=n) for a, b, n in zip(o, c, d)]
            else:
                self.platforms[plat] = lz4.block.decompress(raw[o:o + c], uncompressed_size=d)
        # 2021.2+: per platform, the number of stages its subprograms are listed under (D3D11 and
        # Metal 2, vertex and fragment; the GL platforms and Vulkan 1, one program for all stages)
        self.stage_counts = dict(zip(tree['platforms'], tree['stageCounts'])) if 'stageCounts' in tree else None

    def entries(self, platform, params=(), programs=None):
        return parse_blob(self.platforms[platform], params, self.nested, programs)

    def segments(self, platform):
        """The segment of each entry of a platform (all 0 up to 2019.2)."""
        data = self.platforms[platform]
        return blob_segments(data) if self.nested else [0] * len(_table(data, False))

    def set_entries(self, platform, entries, segments=None, stage_count=None):
        self.platforms[platform] = build_segments(entries, segments) if self.nested else build_blob(entries)
        if self.stage_counts is not None and (stage_count is not None or platform not in self.stage_counts):
            self.stage_counts[platform] = 1 if stage_count is None else stage_count

    def remove(self, platform):
        self.platforms.pop(platform, None)
        if self.stage_counts is not None:
            self.stage_counts.pop(platform, None)

    def store(self):
        """Write the blobs back into the tree, platforms in ascending order as Unity writes them."""
        blob = bytearray()
        plats, offs, clens, dlens = [], [], [], []
        for plat in sorted(self.platforms):
            data = self.platforms[plat]
            plats.append(plat)
            if self.nested:
                o, c, d = [], [], []
                for seg in data:
                    z = lz4.block.compress(seg, mode='high_compression', store_size=False)
                    o.append(len(blob)); c.append(len(z)); d.append(len(seg))
                    blob += z
                offs.append(o); clens.append(c); dlens.append(d)
            else:
                z = lz4.block.compress(data, mode='high_compression', store_size=False)
                offs.append(len(blob)); clens.append(len(z)); dlens.append(len(data))
                blob += z
        t = self.tree
        t['platforms'], t['offsets'], t['compressedLengths'], t['decompressedLengths'] = plats, offs, clens, dlens
        t['compressedBlob'] = bytes(blob)
        if self.stage_counts is not None:
            t['stageCounts'] = [self.stage_counts[p] for p in plats]
