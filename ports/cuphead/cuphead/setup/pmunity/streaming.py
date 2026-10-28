"""StreamingAssets on Unity's Android player, for code written for a desktop build.

On a desktop, Application.streamingAssetsPath is a folder, `<Game>_Data/StreamingAssets`, and games
read it with System.IO (File.ReadAllText, Directory.GetFiles, FileStream, SQLite and XML files, mod
and level folders). On Android it is `jar:file://<apk or obb>!/assets`: the files are inside the
archive, where Unity's own APIs (AssetBundle, UnityWebRequest, VideoPlayer) read them and System.IO
cannot. What android-data does about it (docs/android-data.md, section 6):

- every asset bundle anywhere in StreamingAssets gets the Android platform (not only Cuphead's
  `AssetBundles/`), and an Addressables catalog's CRCs (`m_Crc`, checked by
  AssetBundle.LoadFromFile) follow the changed bundles (`catalog_crcs`);
- `--streaming-assets both|loose` also puts StreamingAssets beside the APK as a folder,
  `Game_Data/StreamingAssets/` (the desktop layout: a data folder with StreamingAssets in it), and runs
  tools/asmpatch's opt-in patch that gives the game's code that folder where it read the getter:
  `both` keeps the files in the OBB too and patches only the reads that reach System.IO
  (streaming-assets); `loose` keeps them only beside the APK and patches every read
  (streaming-assets-all), so Unity's APIs read the folder too;
- `--data-path` makes `Game_Data/` a writable folder with the data folder's own files and runs the
  data-path patch: the reads of Application.dataPath (on Android the APK or OBB file) that reach
  System.IO get that folder.

`port_check` (a pmunity.port hook) suggests `android_data.streaming_assets` when the game's code
reads StreamingAssets with System.IO, and mentions `data_path` for reads of dataPath.
"""
import base64
import json
import os
import re
import struct
import zlib

FOLDER = 'Game_Data'                    # beside the APK; asmpatch's helper returns <dir>/Game_Data/StreamingAssets
SA_DIR = FOLDER + '/StreamingAssets'
MODES = ('obb', 'both', 'loose')
PATCH = {'both': 'streaming-assets', 'loose': 'streaming-assets-all'}
BOTH_LIMIT_MB = 256                     # port check: above this, `loose` (no second copy on the card)


# --------------------------------------------------------------------------- Addressables CRCs

def bundle_crc(path):
    """Unity's CRC of an asset bundle (BuildPipeline / AssetBundle.LoadFromFile(path, crc)): CRC-32
    of its uncompressed data, block by block."""
    from .android_data import Bundle
    b = Bundle(path)
    crc = 0
    with open(path, 'rb') as f:
        for i in range(len(b.blocks)):
            crc = zlib.crc32(b.read_block(f, i)[1], crc)
    return crc


def is_catalog(rel):
    """An Addressables content catalog in StreamingAssets: JSON (aa/catalog.json, aa/catalog_*.json)
    or, Addressables 2.x, binary (aa/catalog.bin)."""
    return re.match(r'^aa[/\\]catalog[^/\\]*\.(json|bin)$', rel) is not None


# a Windows build's catalog names its bundles {RuntimePath}\StandaloneWindows64\<bundle> (Path.Combine);
# AssetBundleProvider refuses such a path elsewhere ("Invalid path in AssetBundleProvider")
_RUNTIME_PATH = rb'\{UnityEngine\.AddressableAssets\.Addressables\.RuntimePath\}'
_WIN_ID_BIN = re.compile(_RUNTIME_PATH + rb'(?:\\[^\\\x00-\x1f"]+?)+?\.bundle')      # (up to the name's end)
_WIN_ID_JSON = re.compile(_RUNTIME_PATH + rb'(?:\\\\[^\\"]+?)+?\.bundle')


def catalog_fix_paths(data, binary):
    """(data, n): the catalog with the backslashes of its {RuntimePath} ids made '/' (in a binary
    catalog byte for byte, so its lengths and offsets stay)."""
    rx, sep = (_WIN_ID_BIN, b'\\') if binary else (_WIN_ID_JSON, b'\\\\')
    n = 0

    def fix(m):
        nonlocal n
        n += 1
        return m.group(0).replace(sep, b'/')
    return rx.sub(fix, data), n


def catalog_needs_fix(path):
    """Whether a catalog is rewritten after the bundles: bundle CRCs (JSON with m_Crc, any binary
    catalog: its CRCs are matched by value) or Windows paths."""
    try:
        with open(path, 'rb') as f:
            data = f.read()
    except OSError:
        return False
    binary = path.endswith('.bin')
    return binary or catalog_fix_paths(data, binary)[1] > 0 or catalog_has_crcs(path)


def catalog_bin_crcs(data, crcs):
    """(data, n): a binary catalog (Addressables 2.x) with each bundle CRC in `crcs` ({old: new})
    replaced where its 4 little-endian bytes occur exactly once (each did in the catalogs seen;
    one found twice or not at all is left as it is)."""
    out = bytearray(data)
    n = 0
    for old, new in crcs.items():
        b = struct.pack('<I', old)
        if old != new and data.count(b) == 1:
            i = data.index(b)
            out[i:i + 4] = struct.pack('<I', new)
            n += 1
    return bytes(out), n


def fix_catalog(path, data, crcs):
    """(data, CRCs replaced, paths made '/'): a catalog as the Android player's Addressables reads it."""
    binary = path.endswith('.bin')
    data, n_paths = catalog_fix_paths(data, binary)
    if binary:
        data, n = catalog_bin_crcs(data, crcs)
    else:
        data, n = catalog_crcs(data, crcs)
    return data, n, n_paths


def _records(c):
    """(entries, extra, [(record offset, json offset, json size, json text)]) of a catalog's
    JsonObject records that its entries point at, highest offset first."""
    extra = bytearray(base64.b64decode(c['m_ExtraDataString']))
    entries = bytearray(base64.b64decode(c['m_EntryDataString']))
    n, = struct.unpack_from('<i', entries, 0)
    out = []
    for off in sorted({struct.unpack_from('<i', entries, 4 + 28 * k + 16)[0] for k in range(n)} - {-1}, reverse=True):
        if off >= len(extra) or extra[off] != 7:            # 7: a JsonObject record
            continue
        p = off + 1
        p += 1 + extra[p]                                   # assembly name
        p += 1 + extra[p]                                   # class name
        size, = struct.unpack_from('<i', extra, p)
        out.append((off, p, size, extra[p + 4:p + 4 + size].decode('utf-16-le')))
    return entries, extra, out


def catalog_has_crcs(path):
    """True if a catalog's bundle locations carry CRCs (AssetBundle.LoadFromFile then checks them)."""
    try:
        with open(path, 'rb') as f:
            c = json.loads(f.read())
        recs = _records(c)[2]
    except (OSError, ValueError, KeyError, TypeError, struct.error):
        return False
    return any(int(m.group(1)) for _, _, _, js in recs for m in re.finditer(r'"m_Crc":(\d+)', js))


def catalog_crcs(text, crcs):
    """An Addressables catalog (catalog.json's bytes) with every bundle CRC in `crcs` ({old: new})
    replaced: returns (new bytes, replacements). The CRCs are in the JSON of each location's
    AssetBundleRequestOptions, stored in m_ExtraDataString (base64) as records [7, len, assembly,
    len, class, int32 size, UTF-16 JSON] that m_EntryDataString's entries (28 bytes: internal id,
    provider, dependency key, dependency hash, data offset, primary key, type) point at by offset;
    a record that grows or shrinks moves the offsets after it. Everything else stays byte for byte."""
    c = json.loads(text)
    entries, extra, recs = _records(c)
    n, = struct.unpack_from('<i', entries, 0)
    done = 0
    for off, p, size, js in recs:
        new = re.sub(r'"m_Crc":(\d+)', lambda m: f'"m_Crc":{crcs.get(int(m.group(1)), int(m.group(1)))}', js)
        if new == js:
            continue
        done += sum(1 for m in re.finditer(r'"m_Crc":(\d+)', js) if int(m.group(1)) in crcs)
        nb = new.encode('utf-16-le')
        delta = len(nb) - size
        extra[p:p + 4 + size] = struct.pack('<i', len(nb)) + nb
        if delta:
            for k in range(n):
                q = 4 + 28 * k + 16
                d, = struct.unpack_from('<i', entries, q)
                if d > off:
                    struct.pack_into('<i', entries, q, d + delta)
    if not done:
        return text, 0
    out = text
    for key, val in (('m_ExtraDataString', extra), ('m_EntryDataString', entries)):
        old = f'"{key}":"{c[key]}"'.encode()
        if out.count(old) != 1:
            raise ValueError(f'catalog: {key} not found once as written')
        out = out.replace(old, f'"{key}":"{base64.b64encode(bytes(val)).decode()}"'.encode())
    return out, done


# --------------------------------------------------------------------------- the folder beside the APK

def place(mode, files, zdir, clone, log):
    """pack(): StreamingAssets beside the APK as zip/Game_Data/StreamingAssets/ (both, loose).
    files: [(arcname 'assets/<path>', tree path)] of StreamingAssets. Returns the OBB's share."""
    import shutil
    dst = os.path.join(zdir, SA_DIR)
    shutil.rmtree(dst, ignore_errors=True)                  # (an earlier run's files)
    if mode == 'obb':
        if os.path.isdir(os.path.join(zdir, FOLDER)) and not os.listdir(os.path.join(zdir, FOLDER)):
            os.rmdir(os.path.join(zdir, FOLDER))
        return files
    size = 0
    for a, p in files:
        clone(p, os.path.join(dst, a[len('assets/'):]), allow_hardlink=True)
        size += os.path.getsize(p)
    os.makedirs(dst, exist_ok=True)
    log(f'pack: StreamingAssets: {len(files)} files ({size / 2**20:.1f} MiB) beside the APK in {SA_DIR}/' +
        (', and in the OBB (or the APK)' if mode == 'both' else ' (not in the OBB or APK)'))
    return files if mode == 'both' else []


# a data folder's own entries Unity reads itself (or never ships): not copied by --data-path
UNITY_DIRS = {'Managed', 'Resources', 'StreamingAssets', 'Plugins', 'Mono', 'MonoBleedingEdge', 'il2cpp_data', 'Il2CppData',
              'UnitySubsystems', 'GI', 'Raw'}


def data_folder_items(src, dst):
    """--data-path: the data folder's own sub-folders (not Unity's) under Game_Data/; its own top-level
    files are planned by android-data (whatever it does not ship itself)."""
    items = []
    for n in sorted(os.listdir(src)):
        p = os.path.join(src, n)
        if not os.path.isdir(p) or n in UNITY_DIRS or n.startswith('.'):
            continue
        for r, ds, fs in os.walk(p):
            ds.sort()
            for f in sorted(fs):
                s = os.path.join(r, f)
                items.append((os.path.join(dst, os.path.relpath(s, src)), s, 'link'))
    return items


def asmpatch_command(cmd, mode):
    """--asmpatch with the patch the mode needs (asmpatch runs opt-in patches only when named)."""
    if mode not in PATCH:
        return cmd
    return f'{cmd} --with={PATCH[mode]}'


# --------------------------------------------------------------------------- port check

def repack_bundle(path, platform, write_bytes, why=''):
    """A bundle android-data's own reader cannot patch in place: every serialized file's platform
    set and the bundle saved again (chunked LZ4) by UnityPy. Same contents, other compression."""
    import UnityPy
    env = UnityPy.load(path)
    res = []
    for name, f in env.file.files.items():
        if hasattr(f, '_m_target_platform'):
            res.append((name, f._m_target_platform, 'repack' + (f' ({why})' if why else '')))
            f._m_target_platform = platform
    data = env.file.save(packer='lz4')
    env = None
    write_bytes(path, data)
    return res


_IO_TYPES = {('System.IO', n) for n in ('File', 'Directory', 'FileInfo', 'DirectoryInfo', 'FileStream', 'StreamReader')}


def code_reads(managed):
    """Without .NET (names only): the game's assemblies that reference both
    Application.streamingAssetsPath and System.IO's file or directory APIs."""
    from .port import Assembly, NotAssembly
    out = []
    if not os.path.isdir(managed):
        return out
    for n in sorted(os.listdir(managed)):
        if not n.endswith('.dll') or n.startswith(('System', 'Mono.', 'mscorlib', 'netstandard', 'Microsoft.')) or \
                n == 'UnityEngine.dll' or n.startswith('UnityEngine.') and n.endswith('Module.dll'):
            continue
        try:
            refs = Assembly(os.path.join(managed, n)).memberrefs
        except (NotAssembly, struct.error, ValueError, IndexError, OSError):
            continue
        sa = any((ns, c, m) == ('UnityEngine', 'Application', 'get_streamingAssetsPath') for ns, c, m in refs)
        io = any((ns, c) in _IO_TYPES for ns, c, m in refs)
        if sa and io:
            out.append(n[:-4])
    return out


def _sa_size(data):
    total = 0
    for r, ds, fs in os.walk(os.path.join(data, 'StreamingAssets')):
        total += sum(os.path.getsize(os.path.join(r, f)) for f in fs)
    return total


def port_check(rep):
    """Suggests android_data.streaming_assets when the game's code reads StreamingAssets with
    System.IO: from asmpatch's --list (which reads reach System.IO: `would streaming-assets`), else
    from the assemblies' names (references only: a hint). Notes reads of dataPath that reach System.IO."""
    if rep.get('backend') != 'mono' or not rep.get('data'):
        return
    data_path_note(rep)
    data = rep['data']
    if not os.path.isdir(os.path.join(data, 'StreamingAssets')):
        return
    size = _sa_size(data)
    would = rep.get('asmpatch_would')
    if would is not None:
        found = 'streaming-assets' in would
        where = 'asmpatch: reads of Application.streamingAssetsPath reach System.IO'
    else:
        names = code_reads(os.path.join(data, 'Managed'))
        found = bool(names)
        where = 'references to Application.streamingAssetsPath and System.IO in ' + ', '.join(names[:4]) + \
            (' (asmpatch, when built, says which reads reach System.IO)' if names else '')
    rep['streaming_assets'] = {'mb': round(size / 2**20, 1), 'io': found}
    if not found:
        return
    mode = 'both' if size < BOTH_LIMIT_MB << 20 else 'loose'
    rep.setdefault('suggest', {}).setdefault('android_data', {})['streaming_assets'] = mode
    rep.setdefault('notes', []).append(
        f'StreamingAssets read as files ({where}): android_data.streaming_assets = "{mode}" puts them '
        f'beside the APK ({SA_DIR}/, {size / 2**20:.1f} MB' + (', also in the OBB' if mode == 'both' else '') +
        f') and asmpatch\'s {PATCH[mode]} patch gives those reads that folder')


def data_path_note(rep):
    """A note (no suggestion) when asmpatch finds reads of Application.dataPath that reach System.IO."""
    if 'data-path' in (rep.get('asmpatch_would') or []):
        rep.setdefault('notes', []).append(
            'reads of Application.dataPath reach System.IO (asmpatch --survey says where; on Android dataPath is the APK '
            'or OBB file): when the game needs files there or writes there, android_data.data_path = true gives those '
            f'reads {FOLDER}/ beside the APK, with the data folder\'s own files')
