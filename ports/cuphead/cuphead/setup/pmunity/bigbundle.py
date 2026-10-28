"""Big UnityFS bundles in little memory.

UnityPy reads a bundle by joining every decompressed block into one buffer, and saves one by
building the whole file in memory: a bundle with 500 MB of textures needs about twice that. On a
1 GB handheld the kernel then kills the setup (Cuphead's largest atlases: 994 MB peak for one
bundle). Here a bundle is unpacked one block at a time into its nodes, each a file in a work
folder; the textures step loads the serialized file from its file and reads a texture's pixels
from the .resS file when it converts that texture. The new bundle is written from node files the
same way, one chunk at a time. Memory: about one chunk, whatever the bundle's size.

The bundle written is the one UnityPy's save(packer='lz4') writes (the same layout, flags, 128 KiB
LZ4 chunks and raw-chunk rule), so the player reads both the same.

    b = unpack(path, work_dir)          # None: a layout this module leaves to UnityPy
    b.nodes                             # [Node(name, flags, path)], in the bundle's order
    pack(b, nodes, out_path)            # nodes: the same, with new files for the changed ones

With lazy=True (a chunked bundle: Unity's LZ4 bundles, 128 KiB blocks) only the serialized files'
nodes are written to the work folder; every other node (the .resS / .resource streams, nearly all
of a texture bundle) stays where it is and is read from the bundle a block at a time when a
texture needs it: its Node.path is then a Part (open() gives a file-like reader), and b.close()
closes the bundle. On a handheld's card that saves writing the bundle's whole uncompressed
contents and reading them back (Cuphead's atlases: 12.6 GB).

pack() compresses its chunks on every core (LZ4 HC is the slow part of writing a bundle; each
chunk is compressed on its own, so the bytes are the same) and writes the bundle in one pass.
"""
import io
import os
import re
import struct
import threading
from collections import OrderedDict, deque, namedtuple

Node = namedtuple('Node', 'name flags path')
CHUNK = 0x20000                  # UnityPy's LZ4 chunk (COMPRESSION_CHUNK_SIZE_MAP)
MAX_BLOCK = 64 << 20             # bigger blocks (an LZMA bundle is one) are decompressed in pieces
LAZY_MAX_BLOCK = 4 << 20         # lazy=True: bundles whose blocks are all at most this are read in place
DATA_FLAG, BLOCK_FLAG = 194, 2   # UnityPy's packer='lz4': blocks info at the end, directory, LZ4


class Bundle:
    def __init__(self, path, version, player, engine, aligned, nodes, size, source=None):
        self.path, self.version, self.player, self.engine = path, version, player, engine
        self.aligned, self.nodes, self.size = aligned, nodes, size       # size: the nodes' bytes
        self.source = source             # lazy: the Source its Part nodes read from

    def close(self):
        """Closes the bundle file lazy nodes read from (before the bundle is replaced)."""
        if self.source is not None:
            self.source.close()


class Source:
    """A chunked bundle's uncompressed contents, read where they are: a block is decompressed when
    a read reaches it (the last few are kept)."""

    KEEP = 4

    def __init__(self, path, blocks, start):
        self.path = path
        self.f = open(path, 'rb')
        self.blocks = []                                 # (uncompressed offset, size, file offset, csize, flags)
        u, fp = 0, start
        for usize, csize, bflags in blocks:
            self.blocks.append((u, usize, fp, csize, bflags))
            u += usize
            fp += csize
        self.starts = [b[0] for b in self.blocks]
        self.size = u
        self._cache = OrderedDict()
        self._lock = threading.Lock()

    def _block(self, i):
        b = self._cache.get(i)
        if b is not None:
            self._cache.move_to_end(i)
            return b
        u, usize, fp, csize, flags = self.blocks[i]
        self.f.seek(fp)
        raw = self.f.read(csize)
        if len(raw) != csize:
            raise ValueError(f'{self.path}: block {i} ends early')
        b = _decompress(raw, usize, flags)
        if len(b) != usize:
            raise ValueError(f'{self.path}: block {i} decompressed to {len(b)} bytes, not {usize}')
        self._cache[i] = b
        while len(self._cache) > self.KEEP:
            self._cache.popitem(last=False)
        return b

    def read(self, off, n):
        """bytes [off, off + n) of the uncompressed contents (fewer at the end)."""
        import bisect
        n = max(0, min(n, self.size - off))
        if not n:
            return b''
        with self._lock:
            i = bisect.bisect_right(self.starts, off) - 1
            parts, end = [], off + n
            while off < end:
                u, usize = self.blocks[i][:2]
                b = self._block(i)
                lo, hi = off - u, min(end, u + usize) - u
                parts.append(b if (lo, hi) == (0, len(b)) else memoryview(b)[lo:hi])
                off += hi - lo
                i += 1
            return parts[0] if len(parts) == 1 and isinstance(parts[0], bytes) else b''.join(parts)

    def close(self):
        if self.f:
            self.f.close()
            self.f = None
            self._cache.clear()


class Part:
    """A node left in the bundle (lazy=True): size, and open() for a file-like reader of its bytes."""

    def __init__(self, source, offset, size):
        self.source, self.offset, self.size = source, offset, size

    def open(self):
        return PartReader(self)

    def __getitem__(self, s):
        """part[a:b]: those bytes (as a memoryview of a node file is sliced)."""
        if not isinstance(s, slice) or s.step not in (None, 1):
            raise TypeError('a Part is read by slices')
        a, b, _ = s.indices(self.size)
        return self.source.read(self.offset + a, max(0, b - a))

    def __len__(self):
        return self.size


class PartReader(io.RawIOBase):
    """A Part's bytes as a read-only, seekable file (UnityPy reads streams through one)."""

    def __init__(self, part):
        super().__init__()
        self.part, self.pos = part, 0

    def readable(self):
        return True

    def seekable(self):
        return True

    def tell(self):
        return self.pos

    def seek(self, pos, whence=0):
        self.pos = max(0, pos if whence == 0 else self.pos + pos if whence == 1 else self.part.size + pos)
        return self.pos

    def read(self, n=-1):
        if n is None or n < 0:
            n = self.part.size - self.pos
        b = self.part[self.pos:self.pos + n]
        self.pos += len(b)
        return b

    def readinto(self, buf):
        b = self.read(len(buf))
        buf[:len(b)] = b
        return len(b)


def node_size(n):
    """A node's bytes: its file's size, or a Part's."""
    return n.path.size if isinstance(n.path, Part) else os.path.getsize(n.path)


def node_open(n):
    """A node's bytes as a file opened for reading (its file, or a Part's reader)."""
    return n.path.open() if isinstance(n.path, Part) else open(n.path, 'rb')


def _cstr(f):
    b = bytearray()
    while True:
        c = f.read(1)
        if not c or c == b'\0':
            return bytes(b)
        b += c


def _engine(s):
    m = re.match(r'(\d+)\.(\d+)\.(\d+)', s)
    return tuple(int(x) for x in m.groups()) if m else (0, 0, 0)


def _decompress(data, usize, flag):
    from UnityPy.helpers import CompressionHelper as C
    kind = flag & 0x3F
    if kind not in (0, 1, 2, 3):
        raise ValueError(f'compression {kind}')
    return C.DECOMPRESSION_MAP[kind](data, usize)


def _pieces(f, csize, usize, flag):
    """A block's decompressed bytes in pieces of at most a few MB: an LZMA block (Unity's default
    bundle compression makes the whole bundle one block) or a stored one streamed from the file,
    any other block decompressed whole (LZ4 blocks are 128 KiB)."""
    kind = flag & 0x3F
    if usize <= MAX_BLOCK or kind not in (0, 1):
        yield _decompress(f.read(csize), usize, flag)
        return
    if kind == 0:
        left = csize
        while left > 0:
            b = f.read(min(left, 4 << 20))
            if not b:
                raise ValueError('a stored block ends early')
            left -= len(b)
            yield b
        return
    import lzma
    p, dict_size = struct.unpack('<BI', f.read(5))          # UnityPy's decompress_lzma, in pieces
    dec = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=[{
        'id': lzma.FILTER_LZMA1, 'dict_size': dict_size, 'lc': p % 9, 'lp': p // 9 % 5, 'pb': p // 9 // 5}])
    left, out = csize - 5, 0
    while out < usize:
        data = b''
        if dec.needs_input:
            if left <= 0:
                break
            data = f.read(min(left, 1 << 20))
            left -= len(data)
        piece = dec.decompress(data, max_length=4 << 20)
        if piece:
            out += len(piece)
            yield piece


def header(path):
    """(version, player, engine, flags, aligned, blocks, nodes, data start) of a UnityFS file, or None
    for any other file and for layouts left to UnityPy (encrypted, unknown flags)."""
    with open(path, 'rb') as f:
        if _cstr(f) != b'UnityFS':
            return None
        version = struct.unpack('>I', f.read(4))[0]
        player, engine = _cstr(f).decode(), _cstr(f).decode()
        _, csize, usize, flags = struct.unpack('>qIII', f.read(20))
        ev = _engine(engine)
        # UnityPy's rules: flag 0x200 is Unity CN's encryption before the alignment fix, then
        # BlockInfoNeedPaddingAtStart (and 0x400 encryption)
        old = ev < (2020,) or (ev[0] == 2020 and ev < (2020, 3, 34)) or \
            (ev[0] == 2021 and ev < (2021, 3, 2)) or (ev[0] == 2022 and ev < (2022, 1, 1))
        if flags & ~0x3FF or (old and flags & 0x200) or (not old and flags & 0x100):
            return None
        pad = not old and bool(flags & 0x200)
        aligned = version >= 7 or (ev[0] == 2019 and ev >= (2019, 4, 15))
        if aligned:
            f.seek(-f.tell() % 16, 1)
        start = f.tell()
        if flags & 0x80:
            f.seek(-csize, 2)
        info = _decompress(f.read(csize), usize, flags)
        if not flags & 0x80:
            start = f.tell()
        if pad:
            start += -start % 16
        n = struct.unpack_from('>i', info, 16)[0]
        p = 20
        blocks = []
        for _ in range(n):
            blocks.append(struct.unpack_from('>IIH', info, p))
            p += 10
        n = struct.unpack_from('>i', info, p)[0]
        p += 4
        nodes = []
        for _ in range(n):
            off, size, nflags = struct.unpack_from('>qqI', info, p)
            e = info.index(b'\0', p + 20)
            nodes.append((off, size, nflags, info[p + 20:e].decode()))
            p = e + 1
        return version, player, engine, flags, aligned, blocks, nodes, start


def size(path):
    """The bytes of a UnityFS bundle's nodes (what UnityPy holds in memory), or 0."""
    try:
        h = header(path)
    except (OSError, ValueError, struct.error):
        return 0
    return sum(n[1] for n in h[6]) if h else 0


def serialized_nodes(nodes):
    """The nodes UnityPy opens as serialized files: those flagged so (4), else every node that is
    not a .resS / .resource stream."""
    return [n for n in nodes if n.flags & 4] or [n for n in nodes if not n.name.endswith(('.resS', '.resource'))]


def unpack(path, work_dir, lazy=False):
    """The bundle's nodes as files in work_dir (a block, or a few MB of a big one, in memory at a
    time), or None when this module leaves the bundle to UnityPy (a layout it does not read).
    lazy: only the serialized files' nodes are written, the others are Parts read from the bundle
    (a bundle of blocks up to LAZY_MAX_BLOCK; else everything is written as without it)."""
    h = header(path)
    if h is None:
        return None
    version, player, engine, flags, aligned, blocks, nodes, start = h
    if any(b[0] > MAX_BLOCK and b[2] & 0x3F not in (0, 1) for b in blocks):
        return None
    os.makedirs(work_dir, exist_ok=True)
    order = sorted(range(len(nodes)), key=lambda i: nodes[i][0])
    out = []
    for i, (off, sz, nflags, name) in enumerate(nodes):
        safe = re.fullmatch(r'[A-Za-z0-9._-]+', name) and name not in ('.', '..')
        out.append(Node(name, nflags, os.path.join(work_dir, name if safe else f'node{i}')))
    if lazy and all(b[0] <= LAZY_MAX_BLOCK and b[2] & 0x3F in (0, 1, 2, 3) for b in blocks):
        src = Source(path, blocks, start)
        try:
            if max((n[0] + n[1] for n in nodes), default=0) > src.size:
                raise ValueError(f'{path}: the nodes reach past the blocks\' {src.size} bytes')
            files = {id(n) for n in serialized_nodes(out)}
            for i, n in enumerate(out):
                off, sz = nodes[i][0], nodes[i][1]
                if id(n) in files:
                    with open(n.path, 'wb') as f:
                        for p in range(off, off + sz, 4 << 20):
                            f.write(src.read(p, min(4 << 20, off + sz - p)))
                    if os.path.getsize(n.path) != sz:
                        raise ValueError(f'{path}: node {n.name}: {os.path.getsize(n.path)} bytes unpacked, not {sz}')
                else:
                    out[i] = n._replace(path=Part(src, off, sz))
        except BaseException:
            src.close()
            raise
        return Bundle(path, version, player, engine, aligned, out, sum(n[1] for n in nodes), src)
    files = {i: open(out[i].path, 'wb') for i in range(len(nodes))}
    try:
        with open(path, 'rb') as f:
            f.seek(start)
            pos = 0                                      # in the uncompressed data
            for usize, csize, bflags in blocks:
                start_pos = pos
                for piece in _pieces(f, csize, usize, bflags):
                    data = memoryview(piece)
                    end = pos + len(data)
                    for i in order:
                        off, sz = nodes[i][0], nodes[i][1]
                        lo, hi = max(off, pos), min(off + sz, end)
                        if lo < hi:
                            files[i].write(data[lo - pos:hi - pos])
                    pos = end
                if pos - start_pos != usize:
                    raise ValueError(f'{path}: a block decompressed to {pos - start_pos} bytes, not {usize}')
    finally:
        for fh in files.values():
            fh.close()
    for i, (off, sz, _, name) in enumerate(nodes):
        if os.path.getsize(out[i].path) != sz:
            raise ValueError(f'{path}: node {name}: {os.path.getsize(out[i].path)} bytes unpacked, not {sz}')
    return Bundle(path, version, player, engine, aligned, out, sum(n[1] for n in nodes))


def _chunks(nodes):
    """The nodes' bytes, concatenated, in CHUNK-sized pieces (the last one shorter)."""
    buf = bytearray()
    for n in nodes:
        with node_open(n) as f:
            while True:
                b = f.read(CHUNK - len(buf))
                if not b:
                    break
                buf += b
                if len(buf) == CHUNK:
                    yield bytes(buf)
                    buf.clear()
    if buf:
        yield bytes(buf)


def threads():
    """Threads for compressing chunks: the cores this process may use."""
    try:
        return max(1, len(os.sched_getaffinity(0)))
    except (AttributeError, OSError):
        return os.cpu_count() or 1


def compress_chunks(chunks, compress, n=None):
    """(chunk, compress(chunk)) for each chunk, in order, compressed on n threads (default: every
    core) with two chunks a thread in flight (LZ4 lets go of the GIL while it compresses)."""
    n = threads() if n is None else n
    if n <= 1:
        for c in chunks:
            yield c, compress(c)
        return
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=n) as ex:
        window = deque()
        for c in chunks:
            window.append((c, ex.submit(compress, c)))
            if len(window) >= 2 * n:
                c0, f0 = window.popleft()
                yield c0, f0.result()
        while window:
            c0, f0 = window.popleft()
            yield c0, f0.result()


def pack(bundle, nodes, out_path):
    """Writes the bundle with these node files (or Parts) to out_path, as UnityPy's
    save(packer='lz4') does: the header first with its sizes left zero, the blocks as they are
    compressed, the blocks info, then the header's sizes (the same bytes, written in one pass)."""
    from UnityPy.helpers import CompressionHelper as C
    lz4 = C.COMPRESSION_MAP[BLOCK_FLAG & 0x3F]
    blocks = []
    with open(out_path, 'wb') as o:
        o.write(b'UnityFS\0' + struct.pack('>I', bundle.version) + bundle.player.encode() + b'\0' +
                bundle.engine.encode() + b'\0')
        size_pos = o.tell()
        o.write(struct.pack('>qIII', 0, 0, 0, DATA_FLAG))               # (the sizes: below)
        if bundle.aligned:
            o.write(b'\0' * (-o.tell() % 16))
        # DATA_FLAG has 0x80 (blocks info at the end) and not 0x200 (no padding)
        for chunk, c in compress_chunks(_chunks(nodes), lz4):
            # UnityPy keeps a chunk raw when LZ4 does not make it smaller (a full chunk: >=, the
            # last one: >)
            raw = len(c) >= CHUNK if len(chunk) == CHUNK else len(c) > len(chunk)
            if raw:
                o.write(chunk)
                blocks.append((len(chunk), len(chunk), BLOCK_FLAG ^ (BLOCK_FLAG & 0x3F)))
            else:
                o.write(c)
                blocks.append((len(chunk), len(c), BLOCK_FLAG))
        info = bytearray(16) + struct.pack('>i', len(blocks))
        for u, c, fl in blocks:
            info += struct.pack('>IIH', u, c, fl)
        info += struct.pack('>i', len(nodes))
        off = 0
        for n in nodes:
            sz = node_size(n)
            info += struct.pack('>qqI', off, sz, n.flags) + n.name.encode() + b'\0'
            off += sz
        cinfo = C.COMPRESSION_MAP[DATA_FLAG & 0x3F](bytes(info))
        o.write(cinfo)
        total = o.tell()
        o.seek(size_pos)
        o.write(struct.pack('>qIII', total, len(cinfo), len(info), DATA_FLAG))
