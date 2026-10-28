"""A game's data for the Android player of another release of the same Unity line
(`android-data --data-version player`, the default when the player package's exact version is
another patch release than the data's).

The serialized files of a build's data (globalgamemanagers, level<n>, sharedassets<n>.assets,
resources.assets, Resources/unity_builtin_extra) have no type trees, so the player reads them
with its own layouts, and it only opens them when they name its own version. Unity 2017.4.40f1
with 2017.4.9f1 data: 'Invalid serialized file version. File: ".../globalgamemanagers". Expected
version: 2017.4.40f1. Actual version: 2017.4.9f1.', then "Unable to initialize the Unity
Engine". (Asset bundles carry type trees and load in other releases as they are.)

Within a line the layouts rarely change, and when they do, UnityPy's type tree package (AssetRipper's
dumps of every release) shows it: 2017.4.9f1 -> 2017.4.40f1 changes PlayerSettings
(iosAppInBackgroundBehavior, an int, became iosUseCustomAppBackgroundBehavior, a bool after
displayResolutionDialog) and TilemapRenderer (m_ChunkCullingBounds added), of the classes a player
reads. Retargeting a file:
 - writes the player's version into its metadata. The rest of the metadata is written again as it
   was (the version string's length moves the 4-byte alignments after it): in place when the space
   between metadata and object data allows (the data stays where it is), else with the data moved
   by a multiple of 16 bytes (object offsets count from the data's start, so they stay);
 - rewrites the objects of classes whose layout changed: read with the data's tree, written with
   the player's, fields kept by name, new ones zero / false / empty (convert()). This needs the
   file loaded in UnityPy (migrate()); a file without such objects is only patched in its metadata.
"""
import os
import struct

TREE_FLAG = 0x4000                  # kAlignBytesFlag: the only meta flag that changes the binary layout


def _uv(text):
    from UnityPy.helpers.Tpk import UnityVersion
    return UnityVersion.from_str(text)


def _flat(node):
    return [(d['m_Level'], d['m_Type'], d['m_Name'], d['m_ByteSize'], d['m_MetaFlag'] & TREE_FLAG)
            for d in node.to_dict_list()]


_changed = {}


def layout_change(class_id, src, dst):
    """(tree in src, tree in dst) of a class whose release layout differs between Unity versions
    src and dst (version strings), else None (also for classes UnityPy has no tree of)."""
    key = (class_id, src, dst)
    if key not in _changed:
        from UnityPy.helpers.Tpk import get_typetree_node
        try:
            a, b = get_typetree_node(class_id, _uv(src)), get_typetree_node(class_id, _uv(dst))
        except Exception:
            _changed[key] = None
        else:
            _changed[key] = None if _flat(a) == _flat(b) else (a, b)
    return _changed[key]


def changed_classes(src, dst):
    """{class id: class name} of every class whose release layout differs between src and dst."""
    from UnityPy.helpers.Tpk import get_typetree
    out = {}
    for cid in sorted(get_typetree().ClassInformation):
        ch = layout_change(cid, src, dst)
        if ch:
            out[cid] = ch[1].m_Type
    return out


# --------------------------------------------------------------------------- values

_FLOATS = ('float', 'double')


def _scalar(t):
    from UnityPy.helpers.TypeTreeHelper import FUNCTION_WRITE_MAP
    return t in FUNCTION_WRITE_MAP and t not in ('string', 'TypelessData')


def _is_array(node):
    return bool(node.m_Children) and node.m_Children[0].m_Type == 'Array'


def default(node):
    """The value of a newly added field: 0, 0.0, False, '', empty array, a structure of those."""
    t = node.m_Type
    if t == 'bool':
        return False
    if t in _FLOATS:
        return 0.0
    if t == 'string':
        return ''
    if t == 'TypelessData':
        return b''
    if _scalar(t):
        return 0
    if t == 'pair':
        return (default(node.m_Children[0]), default(node.m_Children[1]))
    if _is_array(node):
        return []
    return {c.m_Name: default(c) for c in node.m_Children}


def convert(value, a, b, path, notes):
    """value (read with tree a) as a value of tree b: fields matched by name, scalars cast,
    added fields default(), dropped fields listed in notes."""
    if _flat(a) == _flat(b):
        return value
    if _scalar(a.m_Type) and _scalar(b.m_Type):
        if b.m_Type == 'bool':
            return bool(value)
        return float(value) if b.m_Type in _FLOATS else int(value)
    if a.m_Type == 'pair' and b.m_Type == 'pair':
        return tuple(convert(v, ca, cb, path, notes) for v, ca, cb in zip(value, a.m_Children, b.m_Children))
    if _is_array(a) and _is_array(b):
        ea, eb = a.m_Children[0].m_Children[1], b.m_Children[0].m_Children[1]
        return [convert(v, ea, eb, path + '[]', notes) for v in value]
    if isinstance(value, dict) and b.m_Children and not _is_array(b) and not _scalar(b.m_Type):
        have = {c.m_Name: c for c in a.m_Children}
        out = {}
        for c in b.m_Children:
            if c.m_Name in have and c.m_Name in value:
                out[c.m_Name] = convert(value[c.m_Name], have[c.m_Name], c, path + '.' + c.m_Name, notes)
            else:
                out[c.m_Name] = default(c)
                notes.append(f'{path}.{c.m_Name} added ({c.m_Type} {out[c.m_Name]!r})')
        for n in have:
            if n not in out:
                notes.append(f'{path}.{n} dropped (was {value.get(n)!r})')
        return out
    notes.append(f'{path}: {a.m_Type} -> {b.m_Type}, reset to {default(b)!r}')
    return default(b)


def migrate(sf, src, dst):
    """Objects of UnityPy SerializedFile sf (data of Unity src) whose class layout differs in dst,
    rewritten in dst's layout (an object edited before, obj.data set, is converted from that data).
    Returns notes. The caller sets sf.unity_version = dst and saves."""
    from UnityPy.helpers import TypeTreeHelper
    from UnityPy.streams import EndianBinaryReader
    notes = []
    for o in sf.objects.values():
        ch = layout_change(o.class_id, src, dst)
        if ch is None:
            continue
        a, b = ch
        if o.data is not None:
            r = EndianBinaryReader(o.data, endian=o.reader.endian)
            tree = TypeTreeHelper.read_typetree(a, r, as_dict=True, byte_size=len(o.data), check_read=True, assetsfile=sf)
        else:
            tree = o.read_typetree(a)
        n0 = len(notes)
        new = convert(tree, a, b, b.m_Type, notes)
        o.save_typetree(new, b)
        if len(notes) == n0:
            notes.append(f'{b.m_Type}: layout of {dst} written')
    return notes


# --------------------------------------------------------------------------- metadata only

def _head(path):
    """(format, header size, metadata size, file size, data offset, first 64 bytes) of a
    SerializedFile of format 9 or later."""
    with open(path, 'rb') as f:
        head = f.read(64)
    fmt, = struct.unpack_from('>I', head, 8)
    if fmt < 9:
        raise ValueError(f'{path}: SerializedFile format {fmt} (before Unity 5) keeps its metadata at the end')
    if fmt >= 22:
        msize, fsize, doff = struct.unpack_from('>IQQ', head, 20)
        return fmt, 48, msize, fsize, doff, head
    msize, fsize, _, doff = struct.unpack_from('>IIII', head, 0)
    return fmt, 20, msize, fsize, doff, head


def parse_metadata(path):
    """UnityPy's SerializedFile of path's header and metadata only (object data not read)."""
    from UnityPy.files.SerializedFile import SerializedFile
    from UnityPy.streams import EndianBinaryReader
    doff = _head(path)[4]
    with open(path, 'rb') as f:
        buf = f.read(doff)
    return SerializedFile(EndianBinaryReader(buf), None, name=os.path.basename(path))


def metadata_bytes(sf, version, platform):
    """sf's metadata as the file holds it, with another version string and target platform; the
    object entries keep their data offsets and sizes (the order they were read in)."""
    from UnityPy.streams import EndianBinaryWriter
    h = sf.header
    w = EndianBinaryWriter(endian=h.endian)
    if h.version >= 7:
        w.write_string_to_null(version)
    if h.version >= 8:
        w.write_u_int(platform)
    if h.version >= 13:
        w.write_boolean(sf._enable_type_tree)
    w.write_int(len(sf.types))
    for t in sf.types:
        t.write(sf, w, False)
    if 7 <= h.version < 14:
        w.write_int(sf.big_id_enabled)
    w.write_int(len(sf.objects))
    for o in sf.objects.values():
        if sf.big_id_enabled:
            w.write_long(o.path_id)
        elif h.version < 14:
            w.write_int(o.path_id)
        else:
            w.align_stream()
            w.write_long(o.path_id)
        start = o.byte_start - h.data_offset
        (w.write_long if h.version >= 22 else w.write_u_int)(start)
        w.write_u_int(o.byte_size)
        w.write_int(o.type_id)
        if h.version < 16:
            w.write_u_short(o.class_id)
        if h.version < 11:
            w.write_u_short(o.is_destroyed)
        if 11 <= h.version < 17:
            w.write_short(o.serialized_type.script_type_index)
        if h.version in (15, 16):
            w.write_byte(o.is_stripped)
    if h.version >= 11:
        w.write_int(len(sf.script_types))
        for s in sf.script_types:
            s.write(h, w)
    w.write_int(len(sf.externals))
    for e in sf.externals:
        e.write(h, w)
    if h.version >= 20:
        w.write_int(len(sf.ref_types))
        for r in sf.ref_types:
            r.write(sf, w, True)
    if h.version >= 5:
        w.write_string_to_null(sf.userInformation)
    return w.bytes


def retarget_metadata(path, version, platform, sf=None):
    """Rewrites path's metadata with Unity version `version` and target platform `platform`.
    Returns the bytes the object data moved (0: rewritten in place). sf: its parse_metadata()."""
    fmt, hsize, msize, fsize, doff, head = _head(path)
    sf = sf or parse_metadata(path)
    meta = metadata_bytes(sf, version, platform)
    end = hsize + len(meta)
    shift = 0 if end <= doff else -(-(end - doff) // 16) * 16
    ndoff = doff + shift
    if fmt >= 22:
        header = head[:20] + struct.pack('>IQQ', len(meta), fsize + shift, ndoff) + head[40:48]
    else:
        header = struct.pack('>IIII', len(meta), fsize + shift, fmt, ndoff) + head[16:20]
    blob = header + meta + b'\0' * (ndoff - end)
    if shift == 0:
        with open(path, 'r+b') as f:
            f.write(blob)
        return 0
    import shutil
    tmp = path + '.retarget'
    with open(path, 'rb') as fi, open(tmp, 'wb') as fo:
        fo.write(blob)
        fi.seek(doff)
        shutil.copyfileobj(fi, fo, 1 << 20)
    os.replace(tmp, path)
    return shift


def retarget_file(path, src, dst, platform, save_streamed=None):
    """A plain serialized file (data of Unity src) made for the player of Unity dst, in place.
    Objects of classes whose layout changed need UnityPy: the file is then loaded, migrated and
    written again (save_streamed(sf, out) -> bool, unity_io.save_serialized_to, else sf.save()).
    Returns a note for the report."""
    sf = parse_metadata(path)
    if sf._enable_type_tree:              # (a player reads these in any release: platform only)
        fmt, hsize = _head(path)[:2]
        with open(path, 'r+b') as f:
            f.seek(hsize + len(sf.unity_version.encode()) + 1)
            f.write(struct.pack(sf.header.endian + 'I', platform))
        return f'platform -> {platform}; type trees: version {sf.unity_version} kept'
    classes = {t.class_id for t in sf.types}
    if not any(layout_change(c, src, dst) for c in classes):
        shift = retarget_metadata(path, dst, platform, sf)
        return f'platform -> {platform}, version {src} -> {dst}' + (f' (object data moved by {shift} bytes)' if shift else '')
    import UnityPy
    env = UnityPy.load(path)
    full = env.file
    notes = migrate(full, src, dst)
    full._m_target_platform = platform
    full.unity_version = dst
    tmp = path + '.retarget'
    if not (save_streamed and save_streamed(full, tmp)):
        with open(tmp, 'wb') as f:
            f.write(full.save())
    del env, full
    os.replace(tmp, path)
    return f'platform -> {platform}, version {src} -> {dst}; ' + '; '.join(notes)
