"""Loading and saving Unity serialized files and UnityFS asset bundles with UnityPy."""
import gc
import inspect
import io
import os
import re
import textwrap

_patched = False


def _join_blocks(bundle, reader, blocks):
    """The bundle's decompressed blocks in one preallocated buffer (no copies)."""
    buf = bytearray(sum(b.uncompressedSize for b in blocks))
    pos = 0
    for i, b in enumerate(blocks):
        data = bundle.decompress_data(reader.read_bytes(b.compressedSize), b.uncompressedSize, b.flags, i)
        buf[pos:pos + len(data)] = data
        pos += len(data)
        del data
    return buf


def _node_view(reader, size):
    """A bundle node's bytes as a view into the decompressed buffer (no copy)."""
    view = getattr(reader, 'view', None)
    if view is None:
        return reader.read(size)
    pos = reader.Position
    reader.Position = pos + size
    return view[pos:pos + size]


def _recompile(module, cls, method, old, new, extra):
    """Recompiles cls.method with the source text old replaced by new (extra: names it needs)."""
    src = inspect.getsource(getattr(cls, method))
    i = src.find(old)
    if i < 0:
        return False                            # another UnityPy version: left as it is
    j = i + len(old)
    if old.endswith('('):                       # replace up to the matching closing parenthesis
        depth = 1
        while j < len(src) and depth:
            depth += {'(': 1, ')': -1}.get(src[j], 0)
            j += 1
    src = textwrap.dedent(src[:i] + new + src[j:])
    ns = dict(vars(module))
    ns.update(extra)
    exec(compile(src, module.__file__ + ' (pmunity)', 'exec'), ns)
    setattr(cls, method, ns[method])
    return True


_orig_chunk_based_compress = None


def _chunk_based_compress(data, block_info_flag):
    """UnityPy's CompressionHelper.chunk_based_compress (a bundle's blocks when it is saved), its
    LZ4 chunks compressed on every core: each chunk is compressed on its own, so the bytes and the
    blocks are the ones the original makes (the same raw-chunk rule)."""
    from UnityPy.helpers import CompressionHelper as C
    from . import bigbundle
    switch = block_info_flag & 0x3F
    size = C.COMPRESSION_CHUNK_SIZE_MAP.get(switch)
    if switch not in (2, 3) or not size or bigbundle.threads() <= 1:
        return _orig_chunk_based_compress(data, block_info_flag)
    out, info = bytearray(), []
    for chunk, c in bigbundle.compress_chunks((data[p:p + size] for p in range(0, len(data), size)),
                                              C.COMPRESSION_MAP[switch]):
        if len(c) >= size if len(chunk) == size else len(c) > len(chunk):
            out += chunk
            info.append((len(chunk), len(chunk), block_info_flag ^ switch))
        else:
            out += c
            info.append((len(chunk), len(c), block_info_flag))
    return bytes(out), info


_BULK = {}                              # type name -> struct code, for arrays written in one go


def _write_items(value, subtype, writer, config, write_value):
    """The elements of an array in a type tree (UnityPy's write_value calls this for them): an
    array of a plain number type without per-element alignment in one struct.pack (the bytes each
    element's own pack gives: a shader's compressed blob is millions of bytes, one Python call
    each before), anything else element by element as UnityPy does."""
    code = _BULK.get(subtype.m_Type)
    if code and not subtype.m_Children and not (subtype.m_MetaFlag or 0) & 0x4000:
        if code == 'B' and isinstance(value, (bytes, bytearray)):
            writer.write(bytes(value))
        elif value:
            import struct
            writer.write(struct.pack(f'{writer.endian}{len(value)}{code}', *value))
        return
    for sub_value in value:
        write_value(sub_value, subtype, writer, config)


def _patch_unitypy():
    """Opening a bundle, UnityPy (1.25) holds two copies of its decompressed contents: b"".join() of the
    decompressed blocks (every block plus the joined copy), then a copy of each file node read out of
    it. For the largest Cuphead bundle that is ~1.2 GB, more than a 1 GB handheld has. Recompiled
    here to decompress into one buffer and give the nodes views into it.

    Speed, the same bytes: a saved bundle's LZ4 chunks are compressed on every core
    (_chunk_based_compress), and type-tree arrays of numbers are written in one call each
    (_write_items)."""
    global _patched, _orig_chunk_based_compress
    if _patched:
        return
    _patched = True
    import importlib
    BF = importlib.import_module('UnityPy.files.BundleFile')   # the modules (UnityPy.files re-exports
    FM = importlib.import_module('UnityPy.files.File')         # the classes under the same names)
    _recompile(BF, BF.BundleFile, 'read_fs', 'b"".join(', '_join_blocks(self, reader, m_BlocksInfo)', {'_join_blocks': _join_blocks})
    _recompile(FM, FM.File, 'read_files', 'reader.read(node.size)', '_node_view(reader, node.size)', {'_node_view': _node_view})
    CH = importlib.import_module('UnityPy.helpers.CompressionHelper')
    if callable(getattr(CH, 'chunk_based_compress', None)) and getattr(CH, 'COMPRESSION_CHUNK_SIZE_MAP', None):
        _orig_chunk_based_compress = CH.chunk_based_compress
        CH.chunk_based_compress = _chunk_based_compress
    TT = importlib.import_module('UnityPy.helpers.TypeTreeHelper')
    W = importlib.import_module('UnityPy.streams.EndianBinaryWriter').EndianBinaryWriter
    codes = {W.write_byte: 'b', W.write_u_byte: 'B', W.write_short: 'h', W.write_u_short: 'H', W.write_int: 'i',
             W.write_u_int: 'I', W.write_long: 'q', W.write_u_long: 'Q', W.write_float: 'f', W.write_double: 'd',
             W.write_boolean: '?'}
    _BULK.update({t: codes[f] for t, f in getattr(TT, 'FUNCTION_WRITE_MAP', {}).items() if f in codes})
    if _BULK:
        _recompile(TT, TT, 'write_value', '[write_value(sub_value, subtype, writer, config) for sub_value in value]',
                   '_write_items(value, subtype, writer, config, write_value)', {'_write_items': _write_items})


_frozen = []                            # the freezes done (at most two: see collect)


def _tpk_loaded():
    """Whether UnityPy has read its type tree database yet (tpk: ~46,000 objects, read the first
    time a file without type trees is opened, then kept)."""
    try:
        from UnityPy.helpers import Tpk
        return Tpk.get_typetree.cache_info().currsize > 0
    except (ImportError, AttributeError):
        return True


def collect():
    """Frees a closed file's objects (UnityPy's are cycles) and hands the memory back (_trim).
    What is still alive after the first collection (modules, UnityPy's classes and type tree
    database: 80,000-130,000 objects) is frozen (gc.freeze), so the collection after each later
    file walks only the objects made since (on a handheld ~0.1 s a file before, for thousands of
    files). It is frozen once more when the type tree database is read after that, and never
    again: a freeze also keeps whatever the caller still holds at that moment, until the end."""
    gc.collect()
    tpk = _tpk_loaded()
    if not _frozen or (len(_frozen) == 1 and tpk and not _frozen[0]):
        gc.freeze()
        _frozen.append(tpk)
    _trim()


def map_big_blocks():
    """Memory blocks from 1 MB up (decoded textures and their copies, bundle buffers) mapped from the
    system each on its own and handed back when freed: glibc otherwise raises its threshold for that
    to the largest block freed so far (up to 32 MB) and keeps the next ones in its heap, where they
    stay between files and add to every texture's peak (Cuphead-sized textures in a test: peaks
    30-60 MB lower, the same files at the same speed). Called once, as pmunity starts."""
    import ctypes, sys
    if sys.platform.startswith('linux'):
        try:
            ctypes.CDLL(None).mallopt(-3, 1 << 20)          # M_MMAP_THRESHOLD (fixed: no longer raised)
        except (OSError, AttributeError):
            pass


def _trim():
    """Hands freed heap memory back to the system (glibc keeps it otherwise, and a setup that
    converts hundreds of files one after the other grows until a 1 GB handheld runs out)."""
    import ctypes, sys
    if sys.platform.startswith('linux'):
        try:
            ctypes.CDLL(None).malloc_trim(0)
        except (OSError, AttributeError):
            pass


_save_streamed = None


def _make_save_streamed():
    """UnityPy's SerializedFile.save, recompiled to write the object data into a file (the caller's)
    instead of memory, with a hook before each object; None for another UnityPy version."""
    import importlib
    SF = importlib.import_module('UnityPy.files.SerializedFile')
    src = inspect.getsource(SF.SerializedFile.save)
    reps = [
        ('def save(self, packer: Optional[str] = None) -> bytes:', 'def save_streamed(self, _data_stream, _prepare):', 1),
        ('data_writer = EndianBinaryWriter(endian=header.endian)',
         'data_writer = EndianBinaryWriter(_data_stream, endian=header.endian)', 1),
        ('            obj.write(header, meta_writer, data_writer)\n',
         '            _tmp = _prepare(obj)\n            obj.write(header, meta_writer, data_writer)\n'
         '            if _tmp:\n                obj.data = None\n', 1),
        ('            writer.write_bytes(data_writer.bytes)\n', '', 2),      # the data follows, from the file
    ]
    for old, new, count in reps:
        if src.count(old) != count:
            return None
        src = src.replace(old, new)
    ns = dict(vars(SF))
    exec(compile(textwrap.dedent(src), SF.__file__ + ' (pmunity streamed)', 'exec'), ns)
    return ns['save_streamed']


class _Sink(io.RawIOBase):
    """A write-only stream that keeps nothing (a dry run's object data: none)."""

    def __init__(self):
        super().__init__()
        self.pos = self.end = 0

    def writable(self):
        return True

    def seekable(self):
        return True

    def write(self, b):
        self.pos += len(b)
        self.end = max(self.end, self.pos)
        return len(b)

    def tell(self):
        return self.pos

    def seek(self, pos, whence=0):
        self.pos = pos if whence == 0 else self.pos + pos if whence == 1 else self.end + pos
        return self.pos


class _At(io.RawIOBase):
    """The file f from offset base on, as a stream of its own (positions relative to base)."""

    def __init__(self, f, base):
        super().__init__()
        self.f, self.base = f, base
        f.seek(base)

    def writable(self):
        return True

    def seekable(self):
        return True

    def write(self, b):
        return self.f.write(b)

    def tell(self):
        return self.f.tell() - self.base

    def seek(self, pos, whence=0):
        if whence == 0:
            return self.f.seek(self.base + pos) - self.base
        return self.f.seek(pos, whence) - self.base


def _head_size(sf):
    """The length of what sf.save() writes before the object data (header and metadata, padded to
    16): a dry run of the streamed save with every object's data empty, whose metadata has the same
    layout (an object's entry holds its offset and size in fixed-size fields)."""
    objs = list(sf.objects.values())
    old = [o.data for o in objs]
    try:
        for o in objs:
            o.data = b''
        return len(_save_streamed(sf, _Sink(), lambda o: False))
    finally:
        for o, d in zip(objs, old):
            o.data = d


def save_serialized_to(sf, path, prepare=None):
    """Writes a SerializedFile to path, the bytes sf.save() gives, its object data streamed into
    the file: in memory only the metadata and one object at a time. prepare(obj) is called
    before each object is written and returns True when it set obj.data for this write only (a
    texture given its pixels): that data is dropped again once written. Returns False, writing
    nothing, for a layout it does not stream (header version < 9, another UnityPy version).

    The data goes straight to its place (after the header and metadata, whose length a dry run
    gives first), then the header and metadata are written before it: one pass over the file,
    where a copy through a second file was needed before (on a handheld's card, the file's size
    written and read once more)."""
    global _save_streamed
    if sf.header.version < 9:
        return False
    if _save_streamed is None:
        _save_streamed = _make_save_streamed() or False
    if not _save_streamed:
        return False
    import shutil
    base = _head_size(sf)
    with open(path, 'w+b') as out:
        out.write(b'\0' * base)
        head = _save_streamed(sf, _At(out, base), prepare or (lambda o: False))
        if len(head) == base:
            out.seek(0)
            out.write(head)
            return True
        # (not seen: the metadata came out another length) the data moved after the real head
        tmp = path + '.data'
        try:
            with open(tmp, 'w+b') as d:
                out.seek(base)
                shutil.copyfileobj(out, d, 1 << 20)
                out.seek(0)
                out.truncate()
                out.write(head)
                d.seek(0)
                shutil.copyfileobj(d, out, 1 << 20)
        finally:
            if os.path.exists(tmp):
                os.remove(tmp)
    return True


def load(path):
    """UnityPy.load(path), a plain serialized file read through a read-only map of it: UnityPy
    then parses its metadata (the type and object tables: a scene can list 10,000 objects) from
    memory, about 2.5 times faster than through a file object, one small read call per field;
    the same objects and bytes. The map's pages are the file's (the page cache's, as a read's),
    not the process's. A bundle, an empty file or anything that cannot be mapped is left to
    UnityPy.load. release(env) unmaps it when nothing reads it any more (else it goes with env)."""
    import mmap
    import UnityPy
    try:
        with open(path, 'rb') as f:
            if f.read(8) == b'UnityFS\0' or not os.fstat(f.fileno()).st_size:
                raise ValueError('a bundle or empty')
            m = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
    except (OSError, ValueError):
        return UnityPy.load(path)
    env = UnityPy.Environment()
    env.path = os.path.dirname(path) or os.curdir          # (as UnityPy.load(path) sets it)
    env.load_file(memoryview(m), name=path)
    if len(env.files) == 1:
        env.file = list(env.files.values())[0]
    env._pmunity_map = m
    return env


def release(env):
    """Unmaps a file load() mapped (once its objects are gone; a view still alive keeps it)."""
    m = getattr(env, '_pmunity_map', None) if env is not None else None
    if m is not None:
        try:
            m.close()
        except BufferError:
            pass


class NotOneSerializedFile(ValueError):
    """A bundle with no serialized file or several (scene bundles): not opened."""


def current_typetree(o):
    """o.read_typetree(), but of the object's data as last saved (save_typetree): UnityPy's
    read_typetree reads the bytes the file was loaded with, even after a save."""
    if getattr(o, 'data', None) is None:
        return o.read_typetree()
    from UnityPy.helpers import TypeTreeHelper
    from UnityPy.streams import EndianBinaryReader
    return TypeTreeHelper.read_typetree(o._get_typetree_node(None), EndianBinaryReader(o.data, endian=o.reader.endian),
                                        as_dict=True, byte_size=len(o.data), assetsfile=o.assets_file)


class Loaded:
    """One data file opened with UnityPy: a plain serialized file (.assets, level, globalgamemanagers)
    or a UnityFS bundle holding one serialized file (CAB-...) and optionally its .resS."""

    def __init__(self, path, resource_dir=None, streams=None, spill_dir=None, spill_mb=64):
        """resource_dir: where the file's .resS / .resource streams are when they are not beside it
        (a conversion writing to an overlay folder rewrites the file, not its streams).
        streams: {name: file} for streams elsewhere under their own names; each is read from its
        file where needed, never loaded whole.
        spill_dir: an empty scratch folder on the output's file system. A bundle of more than
        spill_mb MB (uncompressed) is then unpacked there into its nodes (bigbundle.py) and opened
        from them: the same objects in little memory (UnityPy holds a whole bundle, twice while
        reading it). Only its serialized file is written there: its streams (.resS) are read from
        the bundle itself where a texture needs them (bigbundle's lazy nodes), for a chunked
        bundle. Write it with write_to()."""
        import os
        import UnityPy
        from . import bigbundle
        _patch_unitypy()
        self.path = path
        self.spilled = None                  # (bigbundle.Bundle, its serialized file's node)
        self._res, self._maps = {}, {}       # a spilled bundle's changed nodes; {file: (mmap, view)}
        self.env, self._spill_dir = None, spill_dir
        load = path
        if spill_dir and spill_mb and bigbundle.size(path) > spill_mb << 20:
            b = bigbundle.unpack(path, spill_dir, lazy=True)
            if b:
                sfs = bigbundle.serialized_nodes(b.nodes)
                if len(sfs) != 1:
                    b.close()
                    raise NotOneSerializedFile(f'{path}: expected one serialized file in the bundle, found {len(sfs)}')
                self.spilled = (b, sfs[0])
                streams = dict(streams or {}, **{n.name: n.path.open() if isinstance(n.path, bigbundle.Part) else n.path
                                                 for n in b.nodes if n is not sfs[0]})
                load = sfs[0].path
        try:
            self._open(path, load, resource_dir, streams)
        except BaseException:
            if self.spilled:
                self.spilled[0].close()
            raise

    def _open(self, path, load_path, resource_dir, streams):
        import os
        self.env = load(load_path)
        if streams:
            from UnityPy.streams import EndianBinaryReader
            for n, p in streams.items():
                self.env.register_cab(n, EndianBinaryReader(p))
        # a plain file's streams (beside it, else in resource_dir) are read from their files where
        # needed: UnityPy itself would read a whole .resS into memory at the first texture
        base = os.path.basename(path)
        stem = os.path.splitext(base)[0]
        for n in (base + '.resS', stem + '.resource', stem + '.resS'):
            if streams and n in streams:
                continue
            for d in (os.path.dirname(path), resource_dir):
                if d and os.path.isfile(os.path.join(d, n)):
                    from UnityPy.streams import EndianBinaryReader
                    self.env.register_cab(n, EndianBinaryReader(os.path.join(d, n)))
                    break
        f = self.env.file
        if self.spilled:
            if type(f).__name__ != 'SerializedFile':
                raise NotOneSerializedFile(f'{path}: its node {self.spilled[1].name} is not a serialized file')
            self.is_bundle, self.bundle = True, None
            self.cab_name, self.sf = self.spilled[1].name, f
            return
        self.is_bundle = type(f).__name__ == 'BundleFile'
        if self.is_bundle:
            self.bundle = f
            sfs = [(k, v) for k, v in f.files.items() if type(v).__name__ == 'SerializedFile']
            if len(sfs) != 1:
                raise NotOneSerializedFile(f'{path}: expected one serialized file in the bundle, found {len(sfs)}')
            self.cab_name, self.sf = sfs[0]
        else:
            self.bundle = None
            self.sf = f

    def objects(self, type_name=None):
        for pid, o in self.sf.objects.items():
            if type_name is None or o.type.name == type_name:
                yield pid, o

    def bundle_res(self, name):
        """A node (e.g. CAB-xxx.resS) inside the bundle as a memoryview (no copy), or None. A
        spilled bundle's node is its file, mapped (its pages stay the file's, not the process's),
        or a node left in the bundle: a bigbundle.Part, sliced the same way (part[a:b] reads those
        bytes from the bundle)."""
        if self.spilled:
            import mmap
            from . import bigbundle
            n = next((n for n in self.spilled[0].nodes if n.name == name), None)
            if n is None:
                return None
            p = self._res.get(name, n.path)
            if isinstance(p, bigbundle.Part):
                return p
            if p not in self._maps:
                with open(p, 'rb') as f:
                    if not os.fstat(f.fileno()).st_size:
                        return memoryview(b'')
                    m = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
                self._maps[p] = (m, memoryview(m))
            return self._maps[p][1]
        n = self.bundle.files.get(name)
        if n is None:
            return None
        if hasattr(n, 'view'):
            return n.view
        return memoryview(n.bytes if hasattr(n, 'bytes') else n)

    def _read_node(self, path, off, size):
        """read_stream for inlining: <size> bytes at <off> of the bundle's node <path> (its new
        contents when set_bundle_res changed it). A node written to a file is read with a seek and
        a read (through a memory map, each page faulted in on its own: seconds a texture on some
        drives)."""
        name = path.split('/')[-1]
        p = self._res.get(name) if self.spilled else None
        if isinstance(p, str):
            with open(p, 'rb') as f:
                f.seek(off)
                return f.read(size)
        return bytes(self.bundle_res(name)[off:off + size])

    def set_bundle_res(self, name, data):
        """A node's new contents: bytes, or (a spilled bundle) the path of a file holding them."""
        if self.spilled:
            n = next(n for n in self.spilled[0].nodes if n.name == name)
            if isinstance(data, str):
                self._res[name] = data
            else:
                p = (n.path if isinstance(n.path, str) else
                     os.path.join(self._spill_dir, re.sub(r'[^A-Za-z0-9._-]', '_', n.name))) + '.new'
                with open(p, 'wb') as f:
                    f.write(data)
                self._res[name] = p
            return
        from UnityPy.streams import EndianBinaryReader
        old = self.bundle.files[name]
        r = EndianBinaryReader(bytes(data))
        r.flags = getattr(old, 'flags', 0)
        self.bundle.files[name] = r

    def save(self):
        """Serialized bytes of the whole file (bundles: chunked LZ4, which Unity reads in place)."""
        if self.spilled:
            raise RuntimeError(f'{self.path}: a spilled bundle is written with write_to()')
        if self.is_bundle:
            return self.bundle.save(packer='lz4')
        return self.sf.save()

    def write_to(self, job, rel, inline=False):
        """The file, changed, into the job's output as <rel> (a spilled bundle: packed again from
        its node files, one chunk at a time). inline (a bundle): its textures' streamed pixels go
        into the texture objects and the .resS nodes nothing reads any more are dropped, as
        android-data's packing does for Unity's Android player (android_data.inline_bundle), so
        packing has nothing left to rewrite."""
        if not self.spilled:
            if inline and self.is_bundle:
                from .android_data import inline_texture_streams
                _, still = inline_texture_streams(self.sf.objects.values(), self._read_node)
                for n in [n for n in self.bundle.files if n.endswith('.resS') and n not in still]:
                    del self.bundle.files[n]
            job.write(rel, self.save())
            return
        import os
        from . import bigbundle
        b, sf_node = self.spilled
        dropped = set()
        if inline:
            from .android_data import _inline_plan, _inline_streamed
            plan, still = _inline_plan(self.sf.objects.values())
            if not _inline_streamed(self.sf, plan, self._read_node, sf_node.path + '.new'):
                from .android_data import inline_texture_streams     # (a layout that does not stream)
                inline_texture_streams(self.sf.objects.values(), self._read_node)
                with open(sf_node.path + '.new', 'wb') as f:
                    f.write(self.sf.save())
            dropped = {n.name for n in b.nodes if n.name.endswith('.resS') and n.name not in still}
        else:
            with open(sf_node.path + '.new', 'wb') as f:
                f.write(self.sf.save())
        nodes = [n._replace(path=sf_node.path + '.new') if n is sf_node else
                 n._replace(path=self._res.get(n.name, n.path)) for n in b.nodes if n.name not in dropped]
        out = os.path.join(os.path.dirname(sf_node.path), 'bundle.new')
        bigbundle.pack(b, nodes, out)
        b.close()                            # (the bundle it read from is replaced next)
        job.write_file(rel, out)

    def close(self):
        for m, v in self._maps.values():
            try:
                v.release()
                m.close()
            except BufferError:              # a slice of it still alive: unmapped with that
                pass
        self._maps = {}
        for r in list(getattr(self.env, 'cabs', {}).values()) if self.env else ():
            f = getattr(r, 'stream', None)          # streams registered from files
            if f is not None and hasattr(f, 'close'):
                f.close()
        if self.spilled:
            self.spilled[0].close()
        env, self.env = self.env, None
        self.sf = self.bundle = None
        m = getattr(env, '_pmunity_map', None)
        env = None
        collect()
        if m is not None:                    # (the file is replaced next: not mapped any more)
            try:
                m.close()
            except BufferError:
                pass
