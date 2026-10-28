"""`python -m pmunity il2cpp`: a Mono desktop game's managed code compiled ahead of time with
Unity's IL2CPP for the IL2CPP Android player of the same Unity version. Unity's 64-bit ARM
Android players (arm64-v8a) are IL2CPP players only; this is how a Mono game reaches them.

    python -m pmunity il2cpp <data> <out> [--abi arm64-v8a|armeabi-v7a] [--pkg DIR] [--home DIR]
                             [--jobs N] [--strip low|none] [--keep-cpp] [--unity VERSION]
                             [--managed-file DLL]... [--assembly-patch NAME COMMAND]...
                             [--asmpatch COMMAND [--streaming-assets obb|both|loose] [--data-path]]
                             [--link-xml FILE]... [--dry-run] [--on-device [--toolchain DIR]]
    python -m pmunity il2cpp fetch <version> [--abi ...] [--net 2|2subset|4] [--pkg DIR] [--home DIR]
                                   [--on-device]                                   (toolchain only)
--on-device: natively on an aarch64 Linux handheld, in a port's setup, without Docker
(il2cpp_device.py; docs/il2cpp.md, "On the handheld").

<data>: the game's desktop data folder (<Game>_Data, or <Game>.app/Contents/Resources/Data; read
only). <out> gets
  lib/<abi>/libil2cpp.so                        the game's code and the IL2CPP runtime (stripped)
  Data/Managed/Metadata/global-metadata.dat     -> assets/bin/Data/Managed/... in the APK
  Data/Managed/Resources/*-resources.dat        (`android-data --il2cpp <out>` puts them there)
  il2cpp.json                                   versions, assemblies, metadata version, options
Then `pmunity android-data --il2cpp <out> --pkg <the IL2CPP player package> ...` packs the data.
The game's code is compiled into libil2cpp.so, so what changes it goes here, not to android-data:
--managed-file, --assembly-patch, --asmpatch; and with --streaming-assets both|loose / --data-path
(StreamingAssets or the data folder read with System.IO) asmpatch's opt-in patches for them, which
android-data's options of the same names then match with the folders beside the APK.

What it uses, all fetched once into --home (default $PMUNITY_IL2CPP_HOME, else
~/.cache/pmunity/il2cpp) with HTTP range requests, never whole installers:
  <ver>/editor/il2cpp/...                       Editor/Data/il2cpp of the Windows editor installer
                                                (UnitySetup64-<ver>.exe: non-solid NSIS, nsis.py):
                                                il2cpp + UnityLinker (.NET), libil2cpp's sources
  <ver>/editor/MonoBleedingEdge/lib/mono/unityaot/   the class libraries IL2CPP builds use (bcl_profile:
                                                .NET 3.5 games Mono/lib/mono/unity or 2.0, .NET
                                                4.x of 2017.x MonoBleedingEdge/lib/mono/4.5)
  ndk-<rev>/...                                 the Android NDK's target files only (sysroot,
                                                libc++, libgcc) from Google's zip; its x86-64
                                                compilers are replaced by tools/il2cpp/ndk-clang.sh
  --pkg (default <home>/<ver>/player-<abi>)     the IL2CPP Android player (`pmunity player fetch
                                                --backend il2cpp`) + Variations/il2cpp/Managed
                                                (the IL2CPP UnityEngine assemblies) and, from
                                                Unity 2020.1, StaticLibs/<abi>/baselib.a
  root/usr, root/etc                            .NET 8, Mono, clang/lld 14 from Ubuntu 24.04's archive
                                                (tools/il2cpp/root.sh), bind-mounted over a stock
                                                ubuntu:24.04 container's own: no image is built
il2cpp and the C++ build run in Docker that way, with every file in --home and <out>. See
docs/il2cpp.md: heavy (minutes of CPU, ~1 GB of build files), for a PC or Mac, and its result is
the user's own build of their game, never something to publish.

Unity's files stay where the porter downloads them; nothing of them is in this repository.
"""
import argparse
import concurrent.futures
import contextlib
import fnmatch
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import time
import urllib.request
import zlib

from . import il2cpp_bee as BEE
from . import il2cpp_mix as MIX
from . import streaming as ST
from . import unity_version as UV

ABIS = {'arm64-v8a': ('ARM64', 'aarch64-linux-android', 21),
        'armeabi-v7a': ('ARMv7', 'arm-linux-androideabi', 19)}


def api_level(rev, abi):
    """The Android API level il2cpp's Android toolchain builds for: 21 on arm64; on armv7 16 with
    NDK r13b / r16b (Unity 2017.1 - 2019.2), 19 from r19 (2019.3+). Unity 2021.x and 2022.x
    (NDK r21d, r23b; their Bee build) link for API 22 on both (ndk_apis)."""
    return 16 if abi == 'armeabi-v7a' and rev in GNU_NDKS else ABIS[abi][2]


def ndk_apis(rev, abi):
    """The API levels whose libraries (sysroot/usr/lib/<triple>/<api>) are fetched from that NDK."""
    return sorted({api_level(rev, abi)} | ({22} if rev in BEE_NDKS else set()))


IMAGE = 'ubuntu:24.04'                   # stock; the tools are in <home>/root (tools/il2cpp/root.sh)
HERE = os.path.dirname(os.path.abspath(__file__))
# tools/il2cpp of the repository; in a port's setup folder, setup/tools/il2cpp next to setup/pmunity
TOOLS = next((t for t in (os.path.normpath(os.path.join(HERE, *up, 'tools', 'il2cpp')) for up in (('..', '..'), ('..',)))
              if os.path.isfile(os.path.join(t, 'ndk-clang.sh'))), os.path.normpath(os.path.join(HERE, '..', '..', 'tools', 'il2cpp')))
EDITOR_API = 'https://services.api.unity.com/unity/editor/release/v1/releases'
EDITOR_CDN = 'https://download.unity3d.com/download_unity/{rev}/Windows64EditorInstaller/UnitySetup64-{ver}.exe'
NDK_BASE = 'https://dl.google.com/android/repository/'
# the NDK each Unity line's IL2CPP wants (AndroidNDKUtilities, and up to 2018.2 the Android
# extension's "IL2CPP requires r13b" check; the Android Build Support of the line installs exactly
# this one). r13b's headers are per platform (platforms/android-<api>/arch-<arch>/usr/include),
# which 2017.x's il2cpp passes as --sysroot; r16b has unified headers only.
NDKS = [  # (first Unity line, name, Pkg.Revision, zip)
    ((2017, 1), 'r13b', '13.1.3345770', 'android-ndk-r13b-linux-x86_64.zip'),
    ((2018, 3), 'r16b', '16.1.4479499', 'android-ndk-r16b-linux-x86_64.zip'),
    ((2019, 3), 'r19', '19.0.5232133', 'android-ndk-r19-linux-x86_64.zip'),
    ((2021, 1), 'r21d', '21.3.6528147', 'android-ndk-r21d-linux-x86_64.zip'),
    ((2022, 2), 'r23b', '23.1.7779620', 'android-ndk-r23b-linux.zip'),
]
GNU_NDKS = ('r13b', 'r16b')              # GNU binutils layout: platforms/, sources/cxx-stl, gnustl
BEE_NDKS = ('r21d', 'r23b')              # the NDKs of Unity 2021.x / 2022.x, whose il2cpp builds with Bee (API 22)
METADATA_MAGIC = 0xFAB11BAF
# the first 2017.4 release with a 64-bit ARM IL2CPP player, and the line's last
ARM64_2017 = (16, '2017.4.40f1')
BCL_DIR = 'MonoBleedingEdge/lib/mono/unityaot'   # the class libraries of IL2CPP builds from 2018.1 (bcl_profile)
MAP_FILE_UNTIL = (2018, 4)              # il2cpp's Android builds before 2018.4 run MapFileParser on a linker map


def log(msg):
    print(msg, file=sys.stderr, flush=True)


def ndk_for(version):
    best = None
    for first, name, rev, z in NDKS:
        if version.line >= first:
            best = (name, rev, z)
    if best is None:
        raise UV.Unsupported(f'Unity {version}: IL2CPP Android builds of this tool start at 2017.4')
    return best


# --------------------------------------------------------------------------- range reads

def _get(url, off, n, tries=6):
    if n <= 0:
        return b''
    for attempt in range(tries):
        try:
            req = urllib.request.Request(url, headers={'Range': 'bytes=%d-%d' % (off, off + n - 1)})
            with urllib.request.urlopen(req, timeout=180) as r:
                if r.status != 206:
                    raise IOError('server ignored the Range request (status %d)' % r.status)
                data = r.read()
            if len(data) != n:
                raise IOError('short read %d of %d' % (len(data), n))
            return data
        except OSError as ex:
            if attempt == tries - 1:
                raise
            log(f'  retry {attempt + 1} at {off}: {ex}')
            time.sleep(3 * (attempt + 1))


def _spans(items, gap=1 << 16, limit=24 << 20):
    """[(off, size, key)] sorted -> [(start, end, [(off, size, key)])] with nearby items merged into
    one read (gaps up to `gap` bytes are read and dropped)."""
    out = []
    for off, size, key in sorted(items):
        if out and off - out[-1][1] <= gap and off + size - out[-1][0] <= limit:
            s, e, lst = out[-1]
            out[-1] = (s, max(e, off + size), lst + [(off, size, key)])
        else:
            out.append((off, off + size, [(off, size, key)]))
    return out


def _parallel(fn, jobs, workers=6):
    with concurrent.futures.ThreadPoolExecutor(workers) as ex:
        for r in ex.map(fn, jobs):
            yield r


def _write(path, data, mode=None):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path + '.part', 'wb') as f:
        f.write(data)
    os.replace(path + '.part', path)
    if mode:
        os.chmod(path, mode)


def nsis_fetch(src, select, dest, log=log):
    """Files of an NSIS installer (local or URL, or an nsis.Nsis) chosen by select(nsis path) -> relative
    output path or None, written under dest. Per-file blocks: neighbouring blocks are read together
    and several reads run at once (Unity 6's chunked installers: 8-byte block words and LZMA in
    chunks, nsis.dechunk). A solid Unity 6 installer is read file by file (nsis.Nsis.extract).
    Returns the relative paths written."""
    from . import nsis
    ns = src if isinstance(src, nsis.Nsis) else nsis.Nsis(src)
    src = ns.s.src
    want = {}
    for path, off, size in ns.files():
        rel = select(path)
        if rel:
            want.setdefault(off, (size, []))[1].append(rel)
    if not want:
        return []
    got, total = [], 0
    if ns.solid:
        for off, (size, rels) in sorted(want.items()):
            data = ns.extract(off)
            total += len(data)
            for rel in rels:
                _write(os.path.join(dest, rel), data)
                got.append(rel)
        log(f'  {len(got)} files, {total / 1e6:.1f} MB (uncompressed) read')
        return got
    word = 8 if ns.chunked else 4
    items = [(ns.data_base + off, size + word + 64, off) for off, (size, _) in want.items()]

    def read_span(span):
        start, end, lst = span
        buf = _get(src, start, end - start) if src.startswith(('http://', 'https://')) else _local(src, start, end - start)
        return start, buf, lst

    def block(buf, p, off):
        if word == 8:
            w, = struct.unpack_from('<Q', buf, p)
            n, packed = w & 0x7fffffffffffffff, w >> 63
        else:
            w, = struct.unpack_from('<I', buf, p)
            n, packed = w & 0x7fffffff, w & 0x80000000
        blk = buf[p + word:p + word + n]
        if len(blk) < n:                    # the size estimate was short (last block): read it alone
            at = ns.data_base + off + word
            blk = _get(src, at, n) if src.startswith('http') else _local(src, at, n)
        if not packed:
            return blk
        return nsis.dechunk(blk) if ns.chunked else nsis.decompress(blk)

    for start, buf, lst in _parallel(read_span, _spans(items)):
        total += len(buf)
        for absoff, _, off in lst:
            data = block(buf, absoff - start, off)
            for rel in want[off][1]:
                _write(os.path.join(dest, rel), data)
                got.append(rel)
    log(f'  {len(got)} files, {total / 1e6:.1f} MB read')
    return got


def _local(path, off, n):
    with open(path, 'rb') as f:
        f.seek(off)
        return f.read(n)


class RemoteZip:
    """The central directory of a zip archive at a URL (or a local path), read with range requests;
    `extract` fetches only the chosen members (stored or deflated; zip64 sizes and offsets)."""

    def __init__(self, src):
        self.src = src
        if src.startswith(('http://', 'https://')):
            req = urllib.request.Request(src, method='HEAD')
            with urllib.request.urlopen(req, timeout=60) as r:
                self.size = int(r.headers['Content-Length'])
        else:
            self.size = os.path.getsize(src)
        tail = self.read(max(0, self.size - 65558), min(self.size, 65558))
        i = tail.rfind(b'PK\x05\x06')
        if i < 0:
            raise ValueError(f'{src}: no zip end record')
        n, cdsize, cdoff = struct.unpack_from('<HII', tail, i + 10)
        if 0xffffffff in (cdsize, cdoff) or n == 0xffff:
            j = tail.rfind(b'PK\x06\x07', 0, i)
            z64, = struct.unpack_from('<Q', tail, j + 8)
            rec = self.read(z64, 56)
            n, cdsize, cdoff = struct.unpack_from('<QQQ', rec, 32)
        cd = self.read(cdoff, cdsize)
        self.entries = []
        p = 0
        while p + 46 <= len(cd) and cd[p:p + 4] == b'PK\x01\x02':
            (meth, crc, cs, us, nl, el, cl), ea, lho = struct.unpack_from('<H4xIIIHHH', cd, p + 10), \
                struct.unpack_from('<I', cd, p + 38)[0], struct.unpack_from('<I', cd, p + 42)[0]
            name = cd[p + 46:p + 46 + nl].decode('utf-8', 'replace')
            extra = cd[p + 46 + nl:p + 46 + nl + el]
            vals = [v for v, m in ((us, 0xffffffff), (cs, 0xffffffff), (lho, 0xffffffff)) if v == m]
            if vals:                         # zip64 extra field: the 0xffffffff fields, in order
                q = 0
                while q + 4 <= len(extra):
                    hid, hl = struct.unpack_from('<HH', extra, q)
                    if hid == 1:
                        f64 = list(struct.unpack_from('<%dQ' % (hl // 8), extra, q + 4))
                        if us == 0xffffffff: us = f64.pop(0)
                        if cs == 0xffffffff: cs = f64.pop(0)
                        if lho == 0xffffffff: lho = f64.pop(0)
                        break
                    q += 4 + hl
            self.entries.append((name, meth, cs, us, lho, ea >> 16, crc))
            p += 46 + nl + el + cl

    def read(self, off, n):
        return _get(self.src, off, n) if self.src.startswith(('http://', 'https://')) else _local(self.src, off, n)

    def extract(self, select, dest, log=log):
        """Members chosen by select(name) -> relative output path or None; symbolic links are made
        as links. Returns the relative paths written."""
        want = []
        for e in self.entries:
            if e[0].endswith('/'):
                continue
            rel = select(e[0])
            if rel:
                want.append((e[4], e[2] + 30 + 1024, (e, rel)))     # local header + name + extra slack
        got, total = [], 0

        def read_span(span):
            start, end, lst = span
            return start, self.read(start, min(end, self.size) - start), lst

        for start, buf, lst in _parallel(read_span, _spans(want)):
            total += len(buf)
            for off, _, ((name, meth, cs, us, lho, mode, crc), rel) in lst:
                p = off - start
                nl, el = struct.unpack_from('<HH', buf, p + 26)
                d0 = p + 30 + nl + el
                blk = buf[d0:d0 + cs]
                if len(blk) < cs:
                    blk = self.read(off + 30 + nl + el, cs)
                data = blk if meth == 0 else zlib.decompressobj(-15).decompress(blk)
                if len(data) != us or (zlib.crc32(data) & 0xffffffff) != crc:
                    raise IOError(f'{name}: bad size or CRC')
                dst = os.path.join(dest, rel)
                if mode & 0o170000 == 0o120000:              # a symbolic link: data = its target
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    if os.path.lexists(dst):
                        os.unlink(dst)
                    os.symlink(data.decode(), dst)
                else:
                    _write(dst, data, (mode & 0o777) or None)
                got.append(rel)
        log(f'  {len(got)} files, {total / 1e6:.1f} MB read')
        return got


# --------------------------------------------------------------------------- toolchain

def editor_installer(version):
    """URL of the Windows editor installer of a Unity version (Unity's release API)."""
    from urllib.parse import urlencode
    with urllib.request.urlopen(f'{EDITOR_API}?{urlencode({"version": version, "limit": 1})}', timeout=60) as r:
        d = json.load(r)
    for rec in d.get('results', []):
        if rec.get('version') != version:
            continue
        for dl in rec.get('downloads', []):
            if dl.get('platform') == 'WINDOWS' and str(dl.get('url', '')).endswith('.exe'):
                return dl['url']
        if rec.get('shortRevision'):
            return EDITOR_CDN.format(rev=rec['shortRevision'], ver=version)
    raise SystemExit(f'Unity does not list version {version} (check `python -m pmunity version <data>`)')


def editor_rel(nsis_path):
    """Editor installer path -> path under Editor/Data ('$_OUTDIR/il2cpp/x' or
    '$INSTDIR/Editor/Data/il2cpp/x' -> 'il2cpp/x'), else None."""
    p = nsis_path
    if p.startswith('$_OUTDIR/'):
        return p[len('$_OUTDIR/'):]
    i = p.find('/Editor/Data/')
    return p[i + len('/Editor/Data/'):] if i >= 0 else None


EDITOR_PARTS = ('il2cpp/il2cpp_root', 'MonoBleedingEdge/etc/mono/config')   # (fetched with every part)


def bcl_wanted(rel, bcl):
    """The assemblies of a class library folder (bcl_profile; the 4.5 folder's AOT images and tools
    are not needed) and the etc folder of its Mono, which il2cpp copies into the data (Managed/etc)."""
    return (rel.startswith(bcl + '/') and rel.endswith('.dll')) or rel.startswith(bcl.split('/')[0] + '/etc/')


def editor_wanted(rel, bcl=BCL_DIR):
    """Whether il2cpp's build needs this file of Editor/Data: il2cpp/, MonoBleedingEdge/etc and a
    class library folder (bcl_wanted)."""
    if rel.startswith('MonoBleedingEdge/etc/') or bcl_wanted(rel, bcl):
        return True
    if not rel.startswith('il2cpp/'):
        return False
    return not (rel.startswith(('il2cpp/MapFileParser/', 'il2cpp/external/mono/mono/tests/')) or rel.endswith(('.pdb', '.mdb')))


def bcl_complete(dest, bcl):
    """Whether the class library folder is all there (its own mark; the unityaot folder of a home
    made before the marks came with the editor's .complete)."""
    if os.path.isfile(os.path.join(dest, bcl, '.complete')):
        return True
    return bcl == BCL_DIR and os.path.isfile(os.path.join(dest, '.complete')) and \
        os.path.isfile(os.path.join(dest, bcl, 'mscorlib.dll'))


def runtime_pack_files(deps):
    """File names a self-contained .NET build's deps.json lists from the .NET runtime pack (the
    framework a Windows build of il2cpp carries; the image's .NET runs the tools instead)."""
    out = set()
    for name, lib in deps.get('libraries', {}).items():
        if lib.get('type') != 'runtimepack':
            continue
        for tgt in deps.get('targets', {}).values():
            for asset in ('runtime', 'native'):
                for f in (tgt.get(name) or {}).get(asset, {}):
                    out.add(f.split('/')[-1].lower())
    return out


def fetch_editor(version, dest, installer=None, bcl=BCL_DIR):
    """Editor/Data/il2cpp, MonoBleedingEdge/etc and one class library folder (bcl_profile) of the
    Windows editor installer; a home that has the first two gets just another class library
    folder. A self-contained .NET build of il2cpp (2020.1+) leaves out the .NET runtime it carries."""
    from . import nsis
    base = os.path.isfile(os.path.join(dest, '.complete')) and all(os.path.exists(os.path.join(dest, p)) for p in EDITOR_PARTS)
    if base and bcl_complete(dest, bcl):
        return dest
    if base:
        installer = installer or json.load(open(os.path.join(dest, '.complete'))).get('installer') or editor_installer(str(version))
        log(f'editor {version}: the class libraries of {bcl} from {installer}')
        got = nsis_fetch(installer, lambda p: (lambda r: r if r and bcl_wanted(r, bcl) else None)(editor_rel(p)), dest)
        if f'{bcl}/mscorlib.dll' not in got:
            raise SystemExit(f'{installer}: no {bcl}/mscorlib.dll in this installer')
        open(os.path.join(dest, bcl, '.complete'), 'w').close()
        return dest
    installer = installer or editor_installer(str(version))
    log(f'editor {version}: il2cpp and the class libraries of {bcl} from {installer}')
    ns = nsis.Nsis(installer)
    deps = {}
    for rel in nsis_fetch(ns, lambda p: (lambda r: r if r and r.startswith('il2cpp/build/') and r.endswith('.deps.json') else None)(
            editor_rel(p)), dest):
        with open(os.path.join(dest, rel), encoding='utf-8-sig') as f:
            deps.setdefault(os.path.dirname(rel), set()).update(runtime_pack_files(json.load(f)))

    def select(p):
        r = editor_rel(p)
        if not r or not editor_wanted(r, bcl) or r.endswith('.deps.json'):
            return None
        if r.split('/')[-1].lower() in deps.get(os.path.dirname(r), ()):
            return None
        return r
    got = nsis_fetch(ns, select, dest)
    if not any(g.startswith('il2cpp/libil2cpp/') for g in got):
        raise SystemExit(f'{installer}: no Editor/Data/il2cpp in this installer')
    if f'{bcl}/mscorlib.dll' not in got:
        raise SystemExit(f'{installer}: no {bcl}/mscorlib.dll in this installer')
    open(os.path.join(dest, bcl, '.complete'), 'w').close()
    # framework-dependent from here on: the deps files would name the runtime pack's files
    for d in deps:
        for n in os.listdir(os.path.join(dest, d)):
            if n.endswith('.deps.json'):
                os.replace(os.path.join(dest, d, n), os.path.join(dest, d, n + '.orig'))
    open(os.path.join(dest, 'il2cpp', 'il2cpp_root'), 'a').close()
    with open(os.path.join(dest, '.complete'), 'w') as f:
        json.dump({'version': str(version), 'installer': installer, 'files': len(got),
                   'runtime_pack_files_left_out': sorted({n for v in deps.values() for n in v})}, f, indent=0)
    return dest


def ndk_wanted(name, rev, abi, apis=None):
    """NDK zip member -> relative path (without the top folder) when il2cpp's Android build needs it
    (apis: the per-API library folders, default ndk_apis)."""
    _, triple, _ = ABIS[abi]
    api = api_level(rev, abi)
    apis = ndk_apis(rev, abi) if apis is None else apis
    parts = name.split('/', 1)
    if len(parts) < 2:
        return None
    rel = parts[1]
    if rel == 'source.properties':
        return rel
    llvm = 'toolchains/llvm/prebuilt/linux-x86_64/'
    if rev in GNU_NDKS:                  # GNU binutils layout: platforms/ (+ sysroot/ in r16b) + sources/cxx-stl, GNU libstdc++
        arch = 'arm64' if abi == 'arm64-v8a' else 'arm'
        gcc = f'toolchains/{triple}-4.9/prebuilt/linux-x86_64/'
        stl = 'sources/cxx-stl/gnu-libstdc++/4.9/'
        if rel.startswith('sysroot/usr/include/') or rel.startswith(f'platforms/android-{api}/arch-{arch}/'):
            return rel                    # (r13b: the platform's own headers and libraries)
        if rel.startswith(stl + 'include/') or rel.startswith(stl + f'libs/{abi}/'):
            return rel if not rel.endswith('.so') else None
        if rel.startswith(gcc + f'lib/gcc/{triple}/') or rel.startswith(gcc + f'{triple}/lib'):
            return rel if not rel.endswith('/') else None
        return None
    if not rel.startswith(llvm):
        return None
    r = rel[len(llvm):]
    if r.startswith(('sysroot/usr/include/', 'sysroot/usr/local/include/')):
        return rel                        # (usr/local/include: libandroid_support's headers, API < 21)
    if r.startswith(f'sysroot/usr/lib/{triple}/'):
        rest = r[len(f'sysroot/usr/lib/{triple}/'):]
        return rel if '/' not in rest or rest.split('/', 1)[0] in {str(a) for a in apis} else None
    if r.startswith(f'lib/gcc/{triple}/') or r.startswith(f'{triple}/lib'):
        return rel if 'ldscripts' not in r else None
    if re.match(r'^lib64/clang/[^/]+/lib/linux/', r) and ('android' in r or f'/{triple.split("-")[0]}/' in r or '/arm/' in r):
        return rel
    return None


def ndk_api_dir(ndk, rev, abi, api):
    """The per-API library folder of the unified sysroot (r19+), else None."""
    if rev in GNU_NDKS:
        return None
    return os.path.join(ndk, 'toolchains', 'llvm', 'prebuilt', 'linux-x86_64', 'sysroot', 'usr', 'lib', ABIS[abi][1], str(api))


def fetch_ndk(rev_name, zipname, abi, dest, extra_apis=()):
    mark = os.path.join(dest, f'.complete-{abi}')
    url = NDK_BASE + zipname
    apis = sorted(set(ndk_apis(rev_name, abi)) | set(extra_apis))
    if os.path.isfile(mark):
        # a folder fetched before an API level was added (r21d / r23b: 22): only those libraries
        more = [a for a in apis if ndk_api_dir(dest, rev_name, abi, a) and
                not os.path.isfile(os.path.join(ndk_api_dir(dest, rev_name, abi, a), 'libc.so'))]
        if not more:
            return dest
        log(f'NDK {rev_name} ({abi}): the API {", ".join(map(str, more))} libraries from {url}')
        dirs = tuple(f'/{ABIS[abi][1]}/{a}/' for a in more)
        got = RemoteZip(url).extract(lambda n: (lambda r: r if r and any(x in r for x in dirs) else None)(
            ndk_wanted(n, rev_name, abi, more)), dest)
        with open(mark) as f:
            info = json.load(f)
        info['apis'] = apis
        info['files'] = info.get('files', 0) + len(got)
        with open(mark, 'w') as f:
            json.dump(info, f)
        return dest
    log(f'NDK {rev_name} ({abi}): sysroot, C++ runtime and libgcc from {url}')
    z = RemoteZip(url)
    got = z.extract(lambda n: ndk_wanted(n, rev_name, abi), dest)
    if 'source.properties' not in got:
        raise SystemExit(f'{url}: not an NDK archive (no source.properties)')
    install_ndk_shims(dest, abi)
    with open(mark, 'w') as f:
        json.dump({'ndk': rev_name, 'zip': url, 'files': len(got), 'apis': apis}, f)
    return dest


def android_note(path):
    """(API level, NDK revision) of an NDK-built library's .note.android.ident (crtbegin_so's note:
    name "Android", the API level it was linked for, the NDK's revision string), else (None, None).
    Unity 6000.0's arm64 players: (23, 'r27c'); 2022.3's: (22, 'r23b')."""
    try:
        with open(path, 'rb') as f:
            b = f.read()
    except OSError:
        return None, None
    i = b.find(b'\x08\x00\x00\x00\x84\x00\x00\x00\x01\x00\x00\x00Android\x00')
    if i < 0:
        return None, None
    api, = struct.unpack_from('<I', b, i + 20)
    return api, b[i + 24:i + 24 + 64].split(b'\0')[0].decode('ascii', 'replace') or None


def install_ndk_shims(ndk, abi):
    """tools/il2cpp/ndk-clang.sh where il2cpp's Android toolchain runs the NDK's x86-64 programs."""
    with open(os.path.join(TOOLS, 'ndk-clang.sh'), 'rb') as f:
        script = f.read()
    _, triple, _ = ABIS[abi]
    llvm = 'toolchains/llvm/prebuilt/linux-x86_64/'
    paths = [llvm + 'bin/clang', llvm + 'bin/clang++']
    for tool in ('objcopy', 'strip', 'ar', 'nm'):
        paths.append(f'toolchains/{triple}-4.9/prebuilt/linux-x86_64/bin/{triple}-{tool}')
        paths.append(f'{llvm}bin/{triple}-{tool}')
        paths.append(f'{llvm}{triple}/bin/{tool}')        # (r21d's binutils, which Unity 2021.x's Bee build runs)
        paths.append(f'{llvm}bin/llvm-{tool}')            # (r23b has LLVM's only)
    for p in paths:
        dst = os.path.join(ndk, p)
        try:
            with open(dst, 'rb') as f:
                if f.read() == script and os.access(dst, os.X_OK):
                    continue                # (unchanged: its time stays, which the Bee graph's records use)
        except OSError:
            pass
        _write(dst, script, 0o755)


def player_wanted(abi):
    return [f'Variations/il2cpp/Managed/*.dll', f'Variations/il2cpp/Release/StaticLibs/{abi}/baselib.a']


def fetch_player(version, pkg, abi):
    """The IL2CPP player package: `pmunity player fetch --backend il2cpp` (libmain, libunity, the
    default resources) plus what the IL2CPP build reads (the IL2CPP UnityEngine assemblies, baselib)."""
    from . import player
    pj = os.path.join(pkg, 'player.json')
    info = json.load(open(pj)) if os.path.isfile(pj) else None
    if info and (info.get('backend') != 'il2cpp' or info.get('abi') != abi):
        raise SystemExit(f'{pkg} holds the {info.get("backend")} / {info.get("abi")} player; use another --pkg '
                         f'for the IL2CPP {abi} one')
    if info is None:
        info = player.fetch(str(version), pkg, 'il2cpp', abi, log=log)
    man = os.path.join(pkg, 'Variations', 'il2cpp', 'Managed')
    if not (os.path.isdir(man) and any(n.endswith('.dll') for n in os.listdir(man))):
        log(f'player {version}: the IL2CPP UnityEngine assemblies and static libraries')
        globs = player_wanted(abi)
        src = info['installer']
        if not src.startswith(('http://', 'https://')) and not os.path.isfile(src):
            # (a local installer the player was read from, removed since: a setup deletes the copy
            # it downloaded once the player is out of it) Unity's own, by range requests
            src = player.installer_url(player.release(str(version)))
            log(f'player {version}: {info["installer"]} is gone: from {src}')
        nsis_fetch(src, lambda p: (lambda r: r if r and any(fnmatch.fnmatchcase(r, g) for g in globs) else None)(
            player.package_path(p)), pkg)
    return info


# libil2cpp's armv7 64-bit atomics (2017.4, 2018.4) bind their operands to r0-r3 and also list
# those registers as clobbered; clang 3.8 took that, clang 11+ refuses it ("asm-specifier for input
# or output variable conflicts with asm clobber list"). None of these asm blocks writes a register
# it binds an input to, and Unity's own later file (2019.4) lists only "cc" and "memory": the same
# change is made in the fetched copy.
SOURCE_FIXES = {
    'il2cpp/libil2cpp/os/Unity/ExtendedAtomicOps-arm.h':
        (re.compile(r'^([ \t]*: "cc"(?:, "memory")?)(?:, "r\d+")+[ \t]*(\r?)$', re.M), r'\1\2'),
}


def fix_editor_sources(editor):
    """SOURCE_FIXES in the fetched Editor/Data (idempotent); returns the files changed."""
    changed = []
    for rel, (pat, rep_) in SOURCE_FIXES.items():
        p = os.path.join(editor, rel)
        if not os.path.isfile(p):
            continue
        with open(p, encoding='utf-8', newline='') as f:
            text = f.read()
        new = pat.sub(rep_, text)
        if new != text:
            _write(p, new.encode('utf-8'))
            changed.append(rel)
    return changed


def toolchain(version, abi, home, pkg=None, bcl=BCL_DIR):
    """Fetches what is missing; returns the paths."""
    vdir = os.path.join(home, str(version))
    editor = fetch_editor(version, os.path.join(vdir, 'editor'), bcl=bcl)
    for rel in fix_editor_sources(editor):
        log(f'{rel}: armv7 asm clobber lists as in later Unity releases (SOURCE_FIXES)')
    BEE.install(editor)                          # (2021.2+: the stand-in for Bee's native backend)
    name, rev, zipname = ndk_for(version)
    ndk = fetch_ndk(name, zipname, abi, os.path.join(home, 'ndk-' + name))
    install_ndk_shims(ndk, abi)                  # (again: the script may be newer than the fetch)
    pkg = pkg or os.path.join(vdir, 'player-' + abi)
    info = fetch_player(version, pkg, abi)
    tc = {'editor': editor, 'ndk': ndk, 'ndk_name': name, 'ndk_revision': rev, 'pkg': pkg, 'player': info, 'bcl': bcl,
          'il2cpp_editor': editor}
    if MIX.needed(version):
        # Unity 2023.1+: il2cpp is a native program; 2022.3's .NET one converts for this
        # version's libil2cpp (il2cpp_mix.py), from a folder that is this editor's il2cpp/ with
        # the converter's build/
        tc['il2cpp_editor'], tc['converter'] = MIX.prepare(version, editor, home, log=log)
        # ... and its build program targets 2022.3's API level (22): a player linked for a later
        # one (Unity 6: 23, whose baselib.a calls API 23's libc) gets libil2cpp.so built for that
        # (ndk-clang.sh raises the target to PMUNITY_ANDROID_API)
        api, _ = android_note(os.path.join(pkg, 'Variations', 'il2cpp', 'Release', 'Libs', abi, 'libunity.so'))
        if api and api > max(ndk_apis(name, abi)):
            fetch_ndk(name, zipname, abi, ndk, extra_apis=(api,))
            tc['android_api'] = api
    return tc


def tool_version(data_version, abi, unity=None):
    """The Unity version whose IL2CPP and player the build uses: the data's own, or `unity` (same
    line). A 2017.4 release before 2017.4.16f1 has no 64-bit ARM IL2CPP player: its data gets the
    line's last release (2017.4.40f1; a line keeps its serialized layouts, see android-data's
    same-line player rule)."""
    if unity:
        v = UV.Version(unity)
        if v.line != data_version.line:
            raise UV.Unsupported(f'--unity {v}: the data is Unity {data_version}; the IL2CPP player must be of the '
                                 f'same line ({data_version.major}.{data_version.minor})')
        return v
    if abi == 'arm64-v8a' and data_version.line == (2017, 4) and data_version.patch < ARM64_2017[0]:
        log(f'Unity {data_version} has no arm64-v8a IL2CPP player (2017.4.{ARM64_2017[0]}f1 and later): '
            f'building with {ARM64_2017[1]}\'s IL2CPP for its player (--unity chooses another)')
        return UV.Version(ARM64_2017[1])
    return data_version


# --------------------------------------------------------------------------- the build

def deploy_tool(editor, name):
    """A .NET program of Editor/Data/il2cpp/build: net471 <name>.exe (Unity 2018.4 - 2019.4) or the
    .NET Core / .NET <name>.dll (2020.1+)."""
    b = os.path.join(editor, 'il2cpp', 'build')
    for rel in (f'deploy/net471/{name}.exe', f'{name}.exe'):
        if os.path.isfile(os.path.join(b, rel)):
            return os.path.join(b, rel)
    d = os.path.join(b, 'deploy')
    for sub in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        p = os.path.join(d, sub, f'{name}.dll')
        if os.path.isfile(p):
            return p
    p = os.path.join(d, f'{name}.dll')
    if os.path.isfile(p):
        return p
    if os.path.isfile(os.path.join(d, f'{name}.exe')):
        # Unity 6: il2cpp is a natively compiled program (the Windows editor's a Windows x86-64 one),
        # with no .NET il2cpp.dll for the container's or the handheld's .NET to run
        raise SystemExit(f'{editor}: this Unity\'s {name} is a native Windows program ({name}.exe without a .NET '
                         f'{name}.dll); the IL2CPP route runs Unity 2017.4 - 2022.3\'s .NET il2cpp (docs/il2cpp.md)')
    raise SystemExit(f'{editor}: no {name} program under il2cpp/build')


RUNTIMECONFIG = {'runtimeOptions': {
    'tfm': 'net8.0', 'rollForward': 'Major',
    'framework': {'name': 'Microsoft.NETCore.App', 'version': '6.0.0'},
    'configProperties': {
        'System.Globalization.Invariant': True,
        'System.Runtime.Serialization.EnableUnsafeBinaryFormatterSerialization': True,
        'System.GC.Concurrent': False}}}


def bcl_profile(version, net, subset=False):
    """(il2cpp's --dotnetprofile, the folder of Editor/Data with its class libraries) of an IL2CPP
    Android build of that Unity version and .NET level (net: 2 = the .NET 3.5 runtime, 4 = .NET
    4.x), as the editor picks them (ApiCompatibilityLevelToDotNetProfileArgument) and il2cpp
    resolves them (its LegacyUnity and Net20 profiles are the old Mono's, Net45 and UnityAot
    MonoBleedingEdge's):
      .NET 3.5, ".NET 2.0 Subset"   legacyunity  Mono/lib/mono/unity       (2017.x, 2018.x)
      .NET 3.5, ".NET 2.0"          net20        Mono/lib/mono/2.0
      .NET 4.x, 2017.x              net45        MonoBleedingEdge/lib/mono/4.5
      .NET 4.x, 2018.1 - 2021.1     unityaot     MonoBleedingEdge/lib/mono/unityaot
      .NET 4.x, 2021.2+             unityaot-linux  MonoBleedingEdge/lib/mono/unityaot-linux (the
                                    class libraries became per platform: -linux, -macos, -win32;
                                    Android builds take the Linux one; Unity 6's installer has no
                                    plain unityaot folder)
    `subset`: the game's own class libraries are the "unity" profile (subset_profile)."""
    if net == 2:
        if version.line >= (2019, 1):
            raise UV.Unsupported(f'Unity {version}: a .NET 3.5 game (IL2CPP builds of .NET 3.5 games are made for '
                                 f'2017.x - 2018.x; 2019.1 is the last line with that runtime, 2019.2+ have none)')
        return ('legacyunity', 'Mono/lib/mono/unity') if subset else ('net20', 'Mono/lib/mono/2.0')
    if version.line < (2018, 1):
        return 'net45', 'MonoBleedingEdge/lib/mono/4.5'
    if version.line >= (2021, 2):
        return 'unityaot-linux', 'MonoBleedingEdge/lib/mono/unityaot-linux'
    return 'unityaot', BCL_DIR


def dotnet_level(data, version=None):
    """2 or 4: the game's scripting runtime, .NET 3.5 (class libraries 2.0.0.0) or .NET 4.x: the
    version of the mscorlib.dll it ships, else of the one Assembly-CSharp references (netstandard:
    4). Unity 2019.2+ has only .NET 4.x (2019.1 still had the deprecated .NET 3.5 runtime: its
    Android player package has libmono.so, and such games ship the 2.0.0.0 mscorlib)."""
    from . import clrmeta as CM
    if version is not None and version.line >= (2019, 2):
        return 4
    gm = os.path.join(data, 'Managed')
    try:
        a = CM.Assembly(os.path.join(gm, 'mscorlib.dll'))
        if a.rows(0x20):                        # Assembly: HashAlgId, Major, ...
            return 2 if a.rows(0x20)[0][1] == 2 else 4
    except (OSError, CM.NotAssembly, ValueError, IndexError, struct.error):
        pass
    try:
        b = CM.Assembly(os.path.join(gm, 'Assembly-CSharp.dll'))
        refs = {b.string(r[6]): r[0] for r in b.rows(CM.ASSEMBLYREF)}
        if 'netstandard' in refs:
            return 4
        if 'mscorlib' in refs:
            return 2 if refs['mscorlib'] == 2 else 4
    except (OSError, CM.NotAssembly, ValueError, IndexError, struct.error):
        pass
    raise UV.Unsupported(f'{gm}: no mscorlib.dll, no Assembly-CSharp.dll that references it: which .NET?')


def subset_profile(data):
    """Whether a .NET 3.5 game ships the old Mono's "unity" profile (API compatibility level ".NET
    2.0 Subset"; its mscorlib has Unity's AOT helper and no console drivers) rather than the
    "2.0" one: the desktop game ran on that profile, so IL2CPP compiles the same one."""
    from . import clrmeta as CM
    p = os.path.join(data, 'Managed', 'mscorlib.dll')
    if not os.path.isfile(p):
        return False
    types = {t['full'] for t in CM.Assembly(p).types()}
    return 'System.MonoTouchAOTHelper' in types and 'System.TermInfoDriver' not in types


def is_engine(name):
    return name == 'UnityEngine.dll' or bool(re.match(r'^UnityEngine\.\w+Module\.dll$', name))


def assembly_refs(path):
    """Names of the assemblies a .NET assembly references (its AssemblyRef table)."""
    return [r + '.dll' for r in _AsmRefs(path).refs]


class _AsmRefs:
    """Minimal ECMA-335 reader: the AssemblyRef table's names (enough to follow references)."""

    def __init__(self, path):
        with open(path, 'rb') as f:
            d = f.read()
        self.refs = []
        pe = struct.unpack_from('<I', d, 0x3c)[0]
        if d[pe:pe + 4] != b'PE\0\0':
            raise ValueError(f'{path}: not a PE file')
        nsec, = struct.unpack_from('<H', d, pe + 6)
        optsz, = struct.unpack_from('<H', d, pe + 20)
        opt = pe + 24
        magic, = struct.unpack_from('<H', d, opt)
        dd = opt + (96 if magic == 0x10b else 112)
        cli_rva, _ = struct.unpack_from('<II', d, dd + 14 * 8)
        secs = [struct.unpack_from('<8sIIII', d, opt + optsz + 40 * i) for i in range(nsec)]

        def off(rva):
            for _, vsz, va, rsz, ro in secs:
                if va <= rva < va + max(vsz, rsz):
                    return rva - va + ro
            raise ValueError('rva outside sections')
        if not cli_rva:
            raise ValueError(f'{path}: not a .NET assembly')
        c = off(cli_rva)
        md_rva, _ = struct.unpack_from('<II', d, c + 8)
        m = off(md_rva)
        vlen, = struct.unpack_from('<I', d, m + 12)
        p = m + 16 + vlen
        nstreams, = struct.unpack_from('<H', d, p + 2)
        p += 4
        streams = {}
        for _ in range(nstreams):
            so, ss = struct.unpack_from('<II', d, p)
            e = d.index(b'\0', p + 8)
            nm = d[p + 8:e].decode()
            streams[nm] = (m + so, ss)
            p = (e + 4) & ~3
        t, _ = streams.get('#~') or streams['#-']
        strings = streams['#Strings'][0]
        hs = d[t + 6]
        valid, = struct.unpack_from('<Q', d, t + 8)
        rows = []
        q = t + 24
        for i in range(64):
            if valid >> i & 1:
                rows.append(struct.unpack_from('<I', d, q)[0]); q += 4
            else:
                rows.append(0)
        if not valid >> 0x23 & 1:
            return                          # no AssemblyRef table
        si = 4 if hs & 1 else 2
        gi = 4 if hs & 2 else 2
        bi = 4 if hs & 4 else 2
        idx = lambda *tabs: 4 if max(rows[x] for x in tabs) >= 1 << 16 else 2
        def coded(bits, *tabs):
            return 4 if max(rows[x] for x in tabs) >= 1 << (16 - bits) else 2
        tdor = coded(2, 0x02, 0x01, 0x1b)
        rs = coded(2, 0x00, 0x1a, 0x23, 0x01)
        mrp = coded(3, 0x02, 0x01, 0x1a, 0x06, 0x1b)
        hc = coded(2, 0x04, 0x08, 0x17)
        hfm = coded(1, 0x04, 0x08)
        hs_ = coded(1, 0x14, 0x17)
        mdor = coded(1, 0x06, 0x0a)
        cat = coded(3, 0x06, 0x0a)
        hca = coded(5, 0x06, 0x04, 0x01, 0x02, 0x08, 0x09, 0x0a, 0x00, 0x0e, 0x17, 0x14, 0x11, 0x1a, 0x1b,
                    0x20, 0x23, 0x26, 0x27, 0x28, 0x2a, 0x2b, 0x2c)
        hds = coded(2, 0x02, 0x06, 0x20)
        impl = coded(2, 0x26, 0x23, 0x27)
        mf = coded(1, 0x04, 0x06)
        tom = coded(1, 0x02, 0x06)
        sizes = {
            0x00: 2 + si + gi * 3, 0x01: rs + si * 2, 0x02: 4 + si * 2 + tdor + idx(0x04) + idx(0x06),
            0x03: idx(0x04), 0x04: 2 + si + bi, 0x05: idx(0x06), 0x06: 4 + 2 + 2 + si + bi + idx(0x08),
            0x07: idx(0x08), 0x08: 2 + 2 + si, 0x09: idx(0x02) + tdor, 0x0a: mrp + si + bi,
            0x0b: 2 + hc + bi, 0x0c: hca + cat + bi, 0x0d: hfm + bi, 0x0e: 2 + hds + bi,
            0x0f: 2 + 4 + idx(0x02), 0x10: 4 + idx(0x04), 0x11: bi, 0x12: idx(0x02) + idx(0x14),
            0x13: idx(0x14), 0x14: 2 + si + tdor, 0x15: idx(0x02) + idx(0x17), 0x16: idx(0x17),
            0x17: 2 + si + bi, 0x18: 2 + idx(0x06) + hs_, 0x19: idx(0x02) + mdor * 2, 0x1a: si,
            0x1b: bi, 0x1c: 2 + mf + si + idx(0x1a), 0x1d: 4 + idx(0x04), 0x1e: 4 + 4, 0x1f: 4,
            0x20: 4 + 2 * 4 + 4 + bi + si * 2, 0x21: 4, 0x22: 4 * 3,
        }
        for i in range(0x23):
            q += sizes[i] * rows[i]
        n = rows[0x23]
        rsz = 2 * 4 + 4 + bi + si + si + bi
        for k in range(n):
            r = q + k * rsz
            nm_off = r + 12 + bi
            name_idx = struct.unpack_from('<I' if si == 4 else '<H', d, nm_off)[0]
            e = d.index(b'\0', strings + name_idx)
            self.refs.append(d[strings + name_idx:e].decode('utf-8', 'replace'))


def listed_assemblies(data):
    """The script assemblies the data names (ScriptingAssemblies.json, Unity 2019.3+, else
    MonoManager.m_AssemblyNames in globalgamemanagers): the game's, its packages' and its plugin
    assemblies, which the player loads by name. Empty when neither can be read."""
    p = os.path.join(data, 'ScriptingAssemblies.json')
    try:
        if os.path.isfile(p):
            with open(p, encoding='utf-8') as f:
                return {n for n in json.load(f).get('names') or [] if n}
        g = os.path.join(data, 'globalgamemanagers')
        if os.path.isfile(g):
            return monomanager_names(g)
    except (OSError, ValueError, AttributeError):
        pass
    return set()


def monomanager_names(src):
    """MonoManager.m_AssemblyNames of a globalgamemanagers file, a data.unity3d (its path or bytes)."""
    try:
        import UnityPy
    except ImportError:
        return set()
    try:
        env = UnityPy.load(src)
        for o in env.objects:
            if o.type.name == 'MonoManager':
                return {n for n in o.read_typetree().get('m_AssemblyNames') or [] if n}
    except Exception:                       # noqa: BLE001 - only a hint for staging
        pass
    return set()


def stage_assemblies(data, tc, out_dir, log=log, managed_files=(), listed=()):
    """The assembly set il2cpp compiles, in out_dir: the game's own assemblies (and Unity's package
    assemblies the build shipped) from <data>/Managed, the IL2CPP player's UnityEngine assemblies
    instead of the desktop ones, and the IL2CPP class libraries (tc['bcl']: bcl_profile) instead of
    the desktop Mono's, following references from the game's assemblies. `managed_files`: assemblies
    compiled instead of the data's copies of the same name, or added (a port's patched
    Assembly-CSharp, its helper, asmpatch's output). `listed`: the data's script assemblies
    (listed_assemblies): one with a class library's name (a project's Plugins/I18N.dll for code
    pages, which nothing references) is the game's, staged from its own copy and kept whole, as
    Unity's build does with a plugin assembly. Returns {name: source}."""
    gm = os.path.join(data, 'Managed')
    eng = os.path.join(tc['pkg'], 'Variations', 'il2cpp', 'Managed')
    bcl = os.path.join(tc['editor'], tc.get('bcl', BCL_DIR))
    bcl_files = {}
    for r, ds, fs in os.walk(bcl):
        for n in fs:
            if n.endswith('.dll'):
                bcl_files.setdefault(n, os.path.join(r, n))         # unityaot/ before unityaot/Facades/
    engine = {n: os.path.join(eng, n) for n in os.listdir(eng) if n.endswith('.dll')}
    override = {os.path.basename(f): os.path.abspath(f) for f in managed_files}
    game = {}
    listed = set(listed or ())
    for n in sorted(set(os.listdir(gm)) | set(override)):
        if not n.endswith('.dll') or (n not in override and (is_engine(n) or n in bcl_files and n not in listed)):
            continue
        game[n] = override.get(n) or os.path.join(gm, n)
        if n in bcl_files and n in listed and n not in override:
            log(f'  {n}: a class library\'s name, but one of the game\'s own assemblies (the data lists it): its copy, whole')
    chosen = dict(engine)
    chosen.update(game)
    todo = list(chosen)
    missing = []
    while todo:
        n = todo.pop()
        for ref in assembly_refs(chosen[n]):
            if ref in chosen:
                continue
            src = bcl_files.get(ref) or engine.get(ref)
            if src is None and os.path.isfile(os.path.join(gm, ref)):
                src = os.path.join(gm, ref)
                log(f'  {ref}: not in the IL2CPP class libraries; the game\'s copy is used')
            if src is None:
                missing.append((ref, n))
                continue
            chosen[ref] = src
            todo.append(ref)
    for ref, by in sorted(set(missing)):
        log(f'  WARNING: {by} references {ref}, which is nowhere (il2cpp may refuse or leave calls to it failing)')
    if os.path.isdir(out_dir):
        shutil.rmtree(out_dir)
    os.makedirs(out_dir)
    for n, src in sorted(chosen.items()):
        shutil.copyfile(src, os.path.join(out_dir, n))
    log(f'assemblies: {len(game)} of the game, {len(engine)} UnityEngine (IL2CPP player), '
        f'{len(chosen) - len(game) - len(engine)} class libraries ({tc.get("bcl", BCL_DIR)})')
    return chosen


def player_settings(data):
    """What of the game's settings the IL2CPP build depends on: incremental GC. The editor writes
    gc-max-time-slice=<ms> into boot.config when it is on (Unity 2019.1+); an IL2CPP build then
    compiles the code with GC write barriers (--incremental-g-c-time-slice), and the player turns
    the incremental collector on from boot.config: the two must agree."""
    out = {'gcIncremental': False}
    try:
        with open(os.path.join(data, 'boot.config'), encoding='utf-8', errors='replace') as f:
            for line in f:
                k, _, v = line.strip().partition('=')
                if k == 'gc-max-time-slice' and v.strip().isdigit() and int(v) > 0:
                    out = {'gcIncremental': True, 'gcTimeSlice': int(v)}
    except OSError:
        pass
    return out


def _elf_symbols(path, table):
    """(data, string table offset, [(name offset, value, size, info, shndx)]) of one symbol table
    of an ELF file (32- or 64-bit, little endian): table 11 = SHT_DYNSYM, 2 = SHT_SYMTAB."""
    with open(path, 'rb') as f:
        d = f.read()
    if d[:4] != b'\x7fELF':
        raise ValueError(f'{path}: not an ELF file')
    is64 = d[4] == 2
    if is64:
        shoff, = struct.unpack_from('<Q', d, 0x28); shentsize, shnum = struct.unpack_from('<HH', d, 0x3a)
    else:
        shoff, = struct.unpack_from('<I', d, 0x20); shentsize, shnum = struct.unpack_from('<HH', d, 0x2e)
    secs = []
    for i in range(shnum):
        o = shoff + i * shentsize
        if is64:
            name, typ, flags, addr, off, size, link, info, align, ent = struct.unpack_from('<IIQQQQIIQQ', d, o)
        else:
            name, typ, flags, addr, off, size, link, info, align, ent = struct.unpack_from('<IIIIIIIIII', d, o)
        secs.append((typ, off, size, link, ent))
    syms, stro = [], 0
    for typ, off, size, link, ent in secs:
        if typ != table:
            continue
        stro = secs[link][1]
        for k in range(1, size // ent):
            o = off + k * ent
            if is64:
                nm, info, other, shndx, value, sz = struct.unpack_from('<IBBHQQ', d, o)
            else:
                nm, value, sz, info, other, shndx = struct.unpack_from('<IIIBBH', d, o)
            syms.append((nm, value, sz, info, shndx))
    return d, stro, syms


def elf_exports(path):
    """Names of the defined dynamic symbols of an ELF shared library."""
    d, stro, syms = _elf_symbols(path, 11)
    out = set()
    for nm, value, size, info, shndx in syms:
        if shndx == 0 or (info >> 4) == 0:      # undefined or local
            continue
        e = d.index(b'\0', stro + nm)
        out.add(d[stro + nm:e].decode('ascii', 'replace'))
    return out


def write_symbol_map(elf, path, thumb=False):
    """Data/Managed/SymbolMap-<arch> of a 2017.x Android IL2CPP build, from the unstripped library's
    symbol table instead of the linker map Unity's MapFileParser reads: int32 count, then each code
    symbol's (uint64 offset, uint32 length) in address order. libil2cpp finds the method of a
    managed stack frame with it (without it, by the method pointer table, which names a frame in
    native code after a neighbouring method). `thumb`: armv7 (bit 0 marks Thumb code, not part of
    the address). Returns the number of symbols."""
    d, stro, syms = _elf_symbols(elf, 2)
    funcs = sorted({((v & ~1) if thumb else v, n) for _, v, n, info, shndx in syms
                    if info & 0xf == 2 and n > 0 and shndx != 0})          # STT_FUNC, defined, sized
    with open(path, 'wb') as f:
        f.write(struct.pack('<i', len(funcs)))
        f.write(b''.join(struct.pack('<QI', a, n) for a, n in funcs))
    return len(funcs)


def il2cpp_api_check(libunity, libil2cpp):
    """The il2cpp_* functions the player's libunity.so looks up by name (dlsym of the strings it
    holds) that the built libil2cpp.so does not export: [] when the two are of the same IL2CPP."""
    with open(libunity, 'rb') as f:
        wanted = {m.decode() for m in re.findall(rb'\0(il2cpp_[a-z0-9_]+)\0', f.read())}
    have = elf_exports(libil2cpp)
    return sorted(w for w in wanted if w not in have), len(wanted)


def metadata_version(path):
    with open(path, 'rb') as f:
        magic, ver = struct.unpack('<Ii', f.read(8))
    if magic != METADATA_MAGIC:
        raise ValueError(f'{path}: not IL2CPP metadata (magic {magic:#x})')
    return ver


def ensure_root(root, image):
    """<home>/root: the tool folders bind-mounted over the stock image's /usr and /etc."""
    if os.path.isfile(os.path.join(root, '.complete')):
        return root
    log(f'making the il2cpp tool folders in {root} (tools/il2cpp/root.sh: Ubuntu packages, once, ~0.85 GB)')
    subprocess.run(['sh', os.path.join(TOOLS, 'root.sh'), root], check=True,
                   env=dict(os.environ, PMUNITY_IL2CPP_BASE=image))
    return root


def il2cpp_args(version, abi, managed, cpp, cache, so, ndk, settings, pkg, profile='unityaot'):
    arch = ABIS[abi][0]
    a = ['--convert-to-cpp', '--compile-cpp', '--libil2cpp-static',
         '--emit-null-checks', '--enable-array-bounds-check',
         f'--dotnetprofile={profile}',
         '--platform=Android', f'--architecture={arch}', '--configuration=Release',
         f'--outputpath={so}', f'--cachedirectory={cache}', f'--generatedcppdir={cpp}',
         f'--directory={managed}', f'--tool-chain-path={ndk}', '--verbose']
    if version.line < MAP_FILE_UNTIL:
        # 2017.x - 2018.3 link with a map file and then run MapFileParser on it for
        # Data/SymbolMap-<arch> (which libil2cpp's managed stack traces can do without: it falls
        # back to the method pointer table); with no --map-file-parser il2cpp builds one from its
        # sources with the host's GCC (finish() writes the file from the symbol table instead)
        a.append('--map-file-parser=/bin/true')
    if settings.get('gcIncremental') and version.line >= (2019, 1):
        a.append(f'--incremental-g-c-time-slice={settings.get("gcTimeSlice", 3)}')
    baselib = os.path.join(pkg, 'Variations', 'il2cpp', 'Release', 'StaticLibs', abi)
    if os.path.isfile(os.path.join(baselib, 'baselib.a')):
        a.append(f'--baselib-directory={baselib}')
    return a


class Container:
    """Runs commands in the stock image with the tool folders (<home>/root) over its /usr and /etc,
    the toolchain and output folders mounted at the same paths and /tmp in the work folder: the
    container's own file system gets nothing. As the calling user, with --jobs CPUs."""

    def __init__(self, image, root, mounts, jobs, work):
        self.image, self.root, self.work = image, root, work
        try:                                     # the CPUs Docker's machine has (a VM on macOS / Windows)
            n = int(subprocess.run(['docker', 'info', '--format', '{{.NCPU}}'], capture_output=True, text=True).stdout)
        except ValueError:
            n = jobs
        self.jobs = max(1, min(jobs, n))
        ms = sorted({os.path.realpath(p) for p in mounts})
        self.mounts = [m for m in ms if not any(m != o and m.startswith(o + os.sep) for o in ms)]

    def docker_args(self, name):
        # --cpuset-cpus as well as --cpus: il2cpp starts one compiler per CPU it sees (Mono counts the
        # CPUs it may run on, not the quota)
        tmp = os.path.join(self.work, 'tmp')
        os.makedirs(tmp, exist_ok=True)
        d = ['docker', 'run', '--rm', f'--cpus={self.jobs}', f'--cpuset-cpus=0-{self.jobs - 1}',
             '-v', f'{os.path.join(self.root, "usr")}:/usr:ro', '-v', f'{os.path.join(self.root, "etc")}:/etc:ro',
             '-v', f'{tmp}:/tmp', '-e', 'HOME=/tmp', '-e', 'DOTNET_CLI_HOME=/tmp', '-e', 'TMPDIR=/tmp',
             '-e', 'DOTNET_CLI_TELEMETRY_OPTOUT=1', '-e', 'DOTNET_NOLOGO=1', '-e', 'DOTNET_ROLL_FORWARD=Major',
             '-e', 'PMUNITY_LLVM=/usr/lib/llvm-14/bin',
             '-e', f'PMUNITY_IL2CPP_CCLOG={os.path.join(self.work, "cc.log")}']
        if hasattr(os, 'getuid'):
            d += ['--user', f'{os.getuid()}:{os.getgid()}']
        if os.environ.get('PMUNITY_IL2CPP_DEBUG_INFO'):
            d += ['-e', 'PMUNITY_IL2CPP_DEBUG_INFO=1']
        if os.environ.get('PMUNITY_ANDROID_API'):
            d += ['-e', f'PMUNITY_ANDROID_API={os.environ["PMUNITY_ANDROID_API"]}']
        if name:
            d += ['--name', name]
        for m in self.mounts:
            d += ['-v', f'{m}:{m}']
        return d + ['-w', self.work, self.image]

    @staticmethod
    def name_for(step):
        # PMUNITY_IL2CPP_DOCKER_NAME: a name for `docker ps` / `docker kill` (+ the step)
        n = os.environ.get('PMUNITY_IL2CPP_DOCKER_NAME')
        return f'{n}-{step}' if n else None

    def run(self, cmd, logname, quiet=False):
        d = self.docker_args(self.name_for(logname.split('.')[0])) + cmd
        path = os.path.join(self.work, logname)
        t0 = time.time()
        with open(path, 'w') as lf:
            p = subprocess.Popen(d, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors='replace')
            tail = []
            for line in p.stdout:
                lf.write(line)
                lf.flush()
                tail = (tail + [line])[-40:]
            rcode = p.wait()
        if rcode != 0:
            sys.stderr.write(''.join(tail))
            prog = next((os.path.basename(w) for w in cmd if w.endswith(('.exe', '.dll'))), cmd[0])
            raise SystemExit(f'{prog} failed (exit {rcode}); full log: {path}')
        return time.time() - t0

    @contextlib.contextmanager
    def shell(self):
        """A container kept running for many commands (the Bee graph's): yields
        sh(command, cwd, env) -> (exit code, output), callable from several threads."""
        name = self.name_for('cc') or f'pmunity-il2cpp-{os.getpid()}-{int(time.time())}'
        subprocess.run(['docker', 'rm', '-f', name], capture_output=True)
        r = subprocess.run(['docker', 'run', '-d'] + self.docker_args(name)[2:] + ['sleep', 'infinity'],
                           capture_output=True, text=True)
        if r.returncode != 0:
            raise SystemExit(f'docker run failed: {r.stderr.strip()}')

        def sh(command, cwd, env):
            e = [w for k, v in sorted(env.items()) for w in ('-e', f'{k}={v}')]
            p = subprocess.run(['docker', 'exec', '-w', cwd] + e + [name, 'sh', '-c', command],
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors='replace')
            return p.returncode, p.stdout
        try:
            yield sh
        finally:
            subprocess.run(['docker', 'rm', '-f', name], capture_output=True)


def run_bee_graph(box, editor, cache, work, progress=None):
    """Unity 2021.2+ (il2cpp_bee): il2cpp only wrote the build graph; its commands run here, in the
    container or on the handheld. Returns the seconds spent."""
    if not BEE.uses_bee(editor):
        return 0
    dag = BEE.graph_path(cache)
    if not os.path.isfile(dag):
        raise SystemExit(f'il2cpp wrote no build graph ({dag})')
    t0 = time.time()
    with box.shell() as sh:
        ran, before = BEE.run_graph(dag, sh, getattr(box, 'threads', box.jobs), log, os.path.join(work, 'build.log'), progress=progress or (
            lambda n, total, el: f'  compiled {n} of {total} ({100 * n // max(1, total)}%), {el / 60:.0f} min'))
    t = time.time() - t0
    log(f'il2cpp: build graph run, {ran} commands ({before} done before) in {t:.0f} s')
    return t


def clear_bee_graph(editor, cache):
    """An earlier run's graph is removed before il2cpp writes this one (run_bee_graph reads it)."""
    if BEE.uses_bee(editor):
        for n in ('bee.dag.json', BEE.ARGS_FILE):
            p = os.path.join(cache, 'buildstate', n)
            if os.path.exists(p):
                os.unlink(p)


def has_option(tool, field):
    """Whether a Unity .NET tool has an option field of that name (Unity.Options: one public
    static field per option, its name in the metadata strings)."""
    with open(tool, 'rb') as f:
        return b'\0' + field.encode() + b'\0' in f.read()


def link_args(version, abi, staged, linked, roots, profile='unityaot'):
    """UnityLinker as an Android IL2CPP build with Managed Stripping Level "Low" runs it: the
    "Conservative" rules (the class libraries are linked with Unity's own descriptors; every root
    assembly is kept whole, MonoBehaviours, [Preserve] and [RequiredByNativeCode] members too).
    Here every assembly but the class libraries is a root (the game's, Unity's packages' and the
    UnityEngine modules): a desktop build carries no record of the types its scenes use (the
    editor's TypesInScenes / editor data), so nothing the data might name is stripped."""
    a = [f'--out={linked}', f'--search-directory={staged}', f'--include-directory={staged}',
         '--dotnetruntime=il2cpp', f'--dotnetprofile={profile}', '--use-editor-options',
         '--rule-set=Conservative', '--platform=Android', f'--architecture={ABIS[abi][0]}']
    a += [f'--include-unity-root-assembly={os.path.join(staged, n)}' for n in sorted(roots)]
    return a


def link_args_2017(net, staged, linked, roots, descriptors, subset=False, keep_xml=None):
    """UnityLinker of 2017.x (Mono's linker with Unity's steps and its own options) as that editor
    runs it for IL2CPP: the class libraries linked (--core-action=link) with il2cpp's descriptors
    (<assembly>.xml in --descriptor-directory), the game's and the packages' assemblies roots kept
    whole (--include-assembly: a library root is copied, all its types marked), the UnityEngine
    ones kept whole by `keep_xml` (engine_keep_xml) but linked, not copied: the linker gives the
    engine assembly it writes a stub for each member the game calls and it lacks (a desktop-only
    API such as Input.IsJoystickPreconfigured: the stub throws, as Mono's call of a missing method
    does; a copied assembly would keep no stub, and il2cpp stops at the unresolved call)."""
    api = 'NET_4_6' if net == 4 else 'NET_2_0_Subset' if subset else 'NET_2_0'
    a = [f'--api={api}', f'--out={linked}', '--i18n=none', '--core-action=link',
         f'--descriptor-directory={descriptors}', f'--search-directory={staged}']
    if keep_xml:
        a.append(f'--include-link-xml={keep_xml}')
    a += [f'--include-assembly={os.path.join(staged, n)}' for n in sorted(roots)]
    return a


def engine_keep_xml(names, path):
    """A link.xml keeping the named assemblies whole (preserve="all")."""
    from xml.sax.saxutils import quoteattr
    with open(path, 'w') as f:
        f.write('<linker>\n' + ''.join(f'  <assembly fullname={quoteattr(n[:-4])} preserve="all"/>\n' for n in sorted(names))
                + '</linker>\n')
    return path


def linker_descriptors(editor, profile, work):
    """The folder the 2017.x UnityLinker reads <assembly>.xml descriptors from: il2cpp's
    LinkerDescriptors as it is for the 2.0 profile (its *45.xml and *_mono.xml match no assembly);
    for net45 a copy where each *45.xml takes the place of the file without 45, as the editor
    picks the 4.5 descriptors."""
    src = os.path.join(editor, 'il2cpp', 'LinkerDescriptors')
    if profile != 'net45':
        return src
    dst = os.path.join(work, 'LinkerDescriptors')
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(dst)
    names = set(os.listdir(src))
    for n in sorted(names):
        if not n.endswith('.xml') or n.endswith('_mono.xml') or (not n.endswith('45.xml') and n[:-4] + '45.xml' in names):
            continue
        shutil.copyfile(os.path.join(src, n), os.path.join(dst, n[:-6] + '.xml' if n.endswith('45.xml') else n))
    return dst


def run_asmpatch(command, managed, work):
    """tools/asmpatch (its command line) on the game's Managed folder: the assemblies its patches
    change, written to <work>/asmpatch, for --managed-file (as android-data --asmpatch)."""
    import shlex
    dst = os.path.join(work, 'asmpatch')
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(work, exist_ok=True)
    r = subprocess.run(shlex.split(command) + [managed, dst], capture_output=True, text=True)
    for line in r.stdout.splitlines():
        log('asmpatch: ' + line)
    if r.returncode != 0:
        raise SystemExit(f'asmpatch failed (exit {r.returncode}):\n{r.stdout}{r.stderr}')
    return [os.path.join(dst, n) for n in sorted(os.listdir(dst)) if n.endswith('.dll')] if os.path.isdir(dst) else []


def run_assembly_patches(patches, managed, work):
    """A port's assembly patches ([(name, command)], as android-data --assembly-patch): each command
    runs with {managed} = the game's Managed folder and {out} = an empty folder, where it writes
    <name>; the results go to <work>/assembly-patch for --managed-file."""
    import shlex
    dst = os.path.join(work, 'assembly-patch')
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(dst)
    out = []
    for name, command in patches:
        tmp = os.path.join(work, 'assembly-patch.tmp')
        shutil.rmtree(tmp, ignore_errors=True)
        os.makedirs(tmp)
        cmd = [w.replace('{managed}', managed).replace('{out}', tmp) for w in shlex.split(command)]
        r = subprocess.run(cmd, capture_output=True, text=True)
        for line in r.stdout.splitlines():
            log(f'assembly patch {name}: {line}')
        if r.returncode != 0 or not os.path.isfile(os.path.join(tmp, name)):
            raise SystemExit(f'assembly patch for {name} failed (exit {r.returncode}' +
                             ('' if r.returncode else f', no {name} written') + f'):\n{r.stdout}{r.stderr}')
        os.replace(os.path.join(tmp, name), os.path.join(dst, name))
        shutil.rmtree(tmp, ignore_errors=True)
        out.append(os.path.join(dst, name))
    return out


def folder_patches(streaming_assets='obb', data_path=False):
    """asmpatch's opt-in patches for StreamingAssets and the data folder read with System.IO (the
    folders android-data --streaming-assets / --data-path puts beside the APK)."""
    if streaming_assets not in ST.MODES:
        raise SystemExit(f'--streaming-assets {streaming_assets!r}: one of {", ".join(ST.MODES)}')
    return ([ST.PATCH[streaming_assets]] if streaming_assets in ST.PATCH else []) + (['data-path'] if data_path else [])


def build(data, out, abi='arm64-v8a', home=None, pkg=None, jobs=None, image=IMAGE, keep_cpp=False, dry=False,
          strip='low', unity=None, managed_files=(), asmpatch=None, on_device=False, device_tc=None, link_xml=(),
          assembly_patches=(), streaming_assets='obb', data_path=False, data_version=None, listed=None):
    """on_device: run the tools natively on this aarch64 Linux machine (a handheld's setup) with the
    device toolchain (il2cpp_device.py; fetched into device_tc, default <home>/device-arm64) instead
    of Docker; the steps resume after a kill and the compiler jobs fit the memory.
    streaming_assets (both, loose) and data_path add asmpatch's opt-in patches for files the game
    reads with System.IO to the asmpatch command (as android-data does for Mono): they are compiled
    in, and il2cpp.json says so, for android-data's options of the same names.
    data_version: the Unity version, when `data` has no serialized file to read it from (`pmunity apk
    --il2cpp` gives the assemblies and boot.config of an Android build's data.unity3d), and listed
    the data's script assemblies (else listed_assemblies(data))."""
    with_patches = folder_patches(streaming_assets, data_path)
    if with_patches and not asmpatch:
        raise SystemExit(f'--streaming-assets {streaming_assets}' + (' --data-path' if data_path else '') +
                         f': these need --asmpatch (tools/asmpatch\'s command): its {", ".join(with_patches)} '
                         f'patch is what gives the game\'s code the folder, compiled into libil2cpp.so')
    data_version = data_version or UV.of_data(data)
    UV.check(data_version)
    version = tool_version(data_version, abi, unity)
    home = os.path.abspath(home or default_home())
    out = os.path.abspath(out)
    data = os.path.abspath(data)
    net = dotnet_level(data, data_version)
    subset = net == 2 and subset_profile(data)
    profile, bcl = bcl_profile(version, net, subset)
    log(f'data: Unity {data_version}, .NET {"3.5" if net == 2 else "4.x"}; IL2CPP of {version} for {abi} '
        f'(profile {profile}, {bcl})')
    tc = toolchain(version, abi, home, pkg and os.path.abspath(pkg), bcl)
    if tc.get('android_api'):                   # (the container and the handheld's commands see it)
        os.environ['PMUNITY_ANDROID_API'] = str(tc['android_api'])
    work = os.path.join(out, '.work')
    staged, linked = os.path.join(work, 'Managed-in'), os.path.join(work, 'Managed')
    managed_files = list(managed_files)
    given = {os.path.basename(f) for f in managed_files}
    patches = {'managed_file': sorted(given)}
    if assembly_patches:
        names = [n for n, _ in assembly_patches]
        clash = sorted(set(n for n in names if names.count(n) > 1) | (set(names) & given))
        if clash:
            raise SystemExit(f'--assembly-patch {", ".join(clash)}: given twice, or also by --managed-file')
        managed_files += run_assembly_patches(assembly_patches, os.path.join(data, 'Managed'), work)
        given |= set(names)
        patches['assembly_patch'] = sorted(names)
    if asmpatch:
        asmpatch = ' '.join([asmpatch] + [f'--with={p}' for p in with_patches])
        patched = run_asmpatch(asmpatch, os.path.join(data, 'Managed'), work)
        clash = sorted({os.path.basename(f) for f in patched} & given)
        if clash:
            raise SystemExit(f'asmpatch changed {", ".join(clash)}, which --managed-file or --assembly-patch also '
                             f'gives: run asmpatch on that assembly when making it instead')
        managed_files += patched
        patches['asmpatch'] = sorted(os.path.basename(f) for f in patched)
        patches['asmpatch_with'] = with_patches
    # (android-data --streaming-assets / --data-path check these against their own)
    patches['streaming_assets'] = streaming_assets
    patches['data_path'] = bool(data_path)
    if listed is None:
        listed = listed_assemblies(data)
    chosen = stage_assemblies(data, tc, staged, managed_files=managed_files, listed=listed)
    settings = player_settings(data)
    cpp, cache = os.path.join(work, 'cpp'), os.path.join(work, 'cache')
    so = os.path.join(out, 'lib', abi, 'libil2cpp.so')
    os.makedirs(os.path.dirname(so), exist_ok=True)
    rc = os.path.join(work, 'tools.runtimeconfig.json')
    with open(rc, 'w') as f:
        json.dump(RUNTIMECONFIG, f)

    def runner(tool, net471='mono'):
        # .NET Framework builds (2018.4 - 2019.4) run on Mono, as in Unity's Linux and macOS editors
        # (UnityLinker uses .NET Framework-only types); .NET Core / .NET builds on .NET 8.
        # PMUNITY_IL2CPP_NET471=dotnet runs a .NET Framework il2cpp.exe on .NET 8 instead (about
        # twice as fast at converting; not what Unity itself does)
        if tool.endswith('.exe') and net471 == 'mono':
            return ['mono', '--gc=sgen', tool]
        return ['dotnet', 'exec', '--runtimeconfig', rc, tool]
    root = os.path.join(home, 'root')
    if on_device:
        from . import il2cpp_device as dev
        device_tc = os.path.abspath(device_tc or dev.default_toolchain(home))
        box = dev.Native(device_tc, jobs, work)
    else:
        box = Container(image, root, (home, out, tc['pkg']), jobs or min(4, os.cpu_count() or 2), work)
    if os.path.exists(os.path.join(work, 'cc.log')):
        os.unlink(os.path.join(work, 'cc.log'))
    roots = [n for n, src in chosen.items() if not src.startswith(os.path.join(tc['editor'], bcl) + os.sep)]
    linker = deploy_tool(tc['editor'], 'UnityLinker')
    if has_option(linker, 'IncludeUnityRootAssembly'):
        largs = link_args(version, abi, staged, linked, roots, profile)
        if has_option(linker, 'AllowedAssembly'):
            # (2022.x: with --use-editor-options the linker resolves only the assemblies it is
            # given, as the editor gives it every assembly of the build)
            largs += [f'--allowed-assembly={os.path.join(staged, n)}' for n in sorted(os.listdir(staged)) if n.endswith('.dll')]
    else:                                       # 2017.x: the older UnityLinker
        engine = [n for n in roots if is_engine(n)]
        os.makedirs(work, exist_ok=True)
        largs = link_args_2017(net, staged, linked, [n for n in roots if n not in engine],
                               linker_descriptors(tc['editor'], profile, work), subset,
                               engine_keep_xml(engine, os.path.join(work, 'engine-link.xml')))
    # a port's own link.xml files (types the game reaches only by reflection, e.g. XmlSerializer):
    # copied into the work folder, which the container and the device toolchain both see
    for i, x in enumerate(link_xml or ()):
        os.makedirs(work, exist_ok=True)
        dst = os.path.join(work, f'port-link-{i}.xml')
        shutil.copyfile(x, dst)
        largs.append(f'--include-link-xml={dst}')
    lcmd = runner(linker) + largs
    tool = deploy_tool(tc['il2cpp_editor'], 'il2cpp')
    # (on the handheld il2cpp.exe runs on .NET 8 unless PMUNITY_IL2CPP_NET471=mono: the same C++ up
    # to how floating-point literals are written (the same values, byte-identical objects), with a
    # sixth of Mono's CPU time and less memory; il2cpp_device.py falls back to Mono if it fails)
    net471 = os.environ.get('PMUNITY_IL2CPP_NET471', 'dotnet' if on_device else 'mono')
    icmd = runner(tool, net471) + \
        il2cpp_args(version, abi, linked, cpp, cache, so, tc['ndk'], settings, tc['pkg'], profile)
    if has_option(tool, 'Jobs'):                # (2020.x+; older ones run a compiler per CPU they see)
        icmd.append(f'--jobs={box.jobs}')
    icmd += os.environ.get('PMUNITY_IL2CPP_EXTRA_ARGS', '').split()     # e.g. --additional-cpp=... (debugging)
    if strip == 'none':
        icmd = [w.replace(f'--directory={linked}', f'--directory={staged}') for w in icmd]
    log('UnityLinker: ' + ' '.join(lcmd) if strip != 'none' else 'UnityLinker: not run (--strip none)')
    log('il2cpp: ' + ' '.join(icmd))
    if dry:
        return None
    if on_device:
        tools = [deploy_tool(tc['editor'], 'UnityLinker'), tool]
        dev.fetch(device_tc, dev.groups_for(tools, net471))
        secs = dev.run_steps(box, lcmd, icmd, work, staged, linked, cpp, cache, tc['il2cpp_editor'], strip)
        return finish(out, work, cpp, so, version, abi, tc, chosen, settings, keep_cpp, secs, strip,
                      data_version=data_version, profile=profile, more={'on_device': dev.report(box), **patches})
    for where, need in ((out, 2 << 30), (home, 1 << 30)):
        st = os.statvfs(where)
        if st.f_bavail * st.f_frsize < need:
            raise SystemExit(f'{where}: {st.f_bavail * st.f_frsize / 2**30:.1f} GiB free; the build needs about '
                             f'{need >> 30} GiB there (generated C++, objects; the tool folders)')
    ensure_root(root, image)
    secs = 0
    if strip != 'none':
        shutil.rmtree(linked, ignore_errors=True)
        secs += box.run(lcmd, 'unitylinker.log')
        kept = sorted(n for n in os.listdir(linked) if n.endswith('.dll'))
        log(f'UnityLinker: {len(kept)} assemblies kept, {sum(os.path.getsize(os.path.join(linked, n)) for n in kept) / 2**20:.1f} MiB '
            f'(from {sum(os.path.getsize(os.path.join(staged, n)) for n in chosen) / 2**20:.1f} MiB) in {secs:.0f} s')
    clear_bee_graph(tc['il2cpp_editor'], cache)
    t = box.run(icmd, 'il2cpp.log')
    t += run_bee_graph(box, tc['il2cpp_editor'], cache, work)
    secs += t
    log(f'il2cpp: done in {t:.0f} s')
    return finish(out, work, cpp, so, version, abi, tc, chosen, settings, keep_cpp, secs, strip,
                  data_version=data_version, profile=profile, more=patches)


def finish(out, work, cpp, so, version, abi, tc, chosen, settings, keep_cpp, secs, strip, data_version=None,
           profile='unityaot', more=None):
    """The data folder il2cpp wrote (Metadata, Resources) -> <out>/Data/Managed; il2cpp.json."""
    src = None
    for cand in (os.path.join(cpp, 'Data'), os.path.join(os.path.dirname(so), 'Data'), os.path.join(work, 'Data')):
        if os.path.isfile(os.path.join(cand, 'Metadata', 'global-metadata.dat')):
            src = cand
            break
    if src is None:
        raise SystemExit(f'il2cpp wrote no Metadata/global-metadata.dat (looked in {cpp}/Data)')
    dst = os.path.join(out, 'Data', 'Managed')
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if src == os.path.join(os.path.dirname(so), 'Data'):
        os.replace(src, dst)                     # (il2cpp writes it beside the library)
    else:
        shutil.copytree(src, dst)
    shutil.rmtree(os.path.join(os.path.dirname(so), 'Data'), ignore_errors=True)   # (2019.4: also there)
    mv = metadata_version(os.path.join(dst, 'Metadata', 'global-metadata.dat'))
    libunity = os.path.join(tc['pkg'], 'Variations', 'il2cpp', 'Release', 'Libs', abi, 'libunity.so')
    missing, nwanted = il2cpp_api_check(libunity, so) if os.path.isfile(libunity) else ([], 0)
    if missing:
        log(f'WARNING: the player\'s libunity.so looks up {len(missing)} il2cpp_* functions libil2cpp.so lacks: {missing[:8]}')
    syms = [p for p in (os.path.join(os.path.dirname(so), n) for n in ('libil2cpp.so.debug', 'libil2cpp.sym')) if os.path.isfile(p)]
    if version.line < MAP_FILE_UNTIL and syms:  # (2017.x - 2018.3: see il2cpp_args' --map-file-parser)
        n = write_symbol_map(syms[0], os.path.join(dst, 'SymbolMap-' + ABIS[abi][0]), abi == 'armeabi-v7a')
        log(f'SymbolMap-{ABIS[abi][0]}: {n} code symbols')
    # the unstripped library and the linker's map (dropped), the symbols (kept in .work): 2019.4+
    # name them .dbg.so / .sym.so, 2017.4 and 2018.4 .so.debug / .sym / .map
    for extra in ('libil2cpp.dbg.so', 'libil2cpp.so.debug', 'libil2cpp.map', 'libil2cpp.sym.so', 'libil2cpp.sym'):
        p = os.path.join(os.path.dirname(so), extra)
        if os.path.exists(p):
            if extra.endswith(('.dbg.so', '.debug', '.map')):
                os.unlink(p)
            else:
                os.replace(p, os.path.join(work, extra))
    info = {
        'unity': str(version), 'data_unity': str(data_version or version), 'abi': abi, 'metadata_version': mv,
        'dotnet_profile': profile,
        'libil2cpp_bytes': os.path.getsize(so),
        'player_api': {'looked_up': nwanted, 'missing': missing},
        'ndk': tc['ndk_name'], 'player': tc['player'].get('version'),
        **({'il2cpp_converter': tc['converter']} if tc.get('converter') else {}),
        **({'android_api': tc['android_api']} if tc.get('android_api') else {}),
        'assemblies': sorted(chosen), 'gc_incremental': settings.get('gcIncremental', False), 'strip': strip,
        'build_seconds': round(secs),
        **(more or {}),
        'files': sorted(os.path.relpath(os.path.join(r, n), out) for r, _, fs in os.walk(os.path.join(out, 'Data')) for n in fs),
    }
    with open(os.path.join(out, 'il2cpp.json'), 'w') as f:
        json.dump(info, f, indent=1)
    if not keep_cpp:
        shutil.rmtree(cpp, ignore_errors=True)
        shutil.rmtree(os.path.join(work, 'cache'), ignore_errors=True)
    shutil.rmtree(os.path.join(work, 'tmp'), ignore_errors=True)
    log(f'il2cpp: {so} ({os.path.getsize(so) / 2**20:.1f} MiB), metadata version {mv}, '
        f'{len(info["files"])} data files -> {dst}')
    return info


def default_home():
    return os.environ.get('PMUNITY_IL2CPP_HOME') or os.path.join(os.path.expanduser('~'), '.cache', 'pmunity', 'il2cpp')


def port_new(ctx):
    """`pmunity port new` hook: port.json for the il2cpp-arm64 route (no 32-bit userland needed; the
    setup compiles the game's code on the handheld)."""
    p = ctx.cfg['port']
    if p['route'] != 'il2cpp-arm64':
        return
    pj_path = os.path.join(ctx.out, p['name'], 'port.json')
    if not os.path.isfile(pj_path):
        return
    with open(pj_path) as f:
        pj = json.load(f)
    a = pj['attr']
    a['reqs'] = [r for r in a.get('reqs') or [] if r != 'armhf']
    if not p.get('desc'):
        a['desc'] = f"{p['title']} on Unity's 64-bit Android player (its code compiled with IL2CPP on the handheld)."
    if not p.get('inst'):
        a['inst'] = (f"Requires {ctx.cfg['game']['what']}: put it in ports/{p['name']}/gamedata. The first launch builds "
                     f"the game on the handheld and compiles its code with Unity's IL2CPP ({p['setup_time']}, plus one to a "
                     f"few hours for the code; about 1.6 GB free; Wi-Fi for Unity's and Debian's files).")
    ctx.write(f"{p['name']}/port.json", json.dumps(pj, indent=4) + '\n')


def main(argv):
    if argv[:1] == ['fetch']:
        ap = argparse.ArgumentParser(prog='pmunity il2cpp fetch')
        ap.add_argument('version')
        ap.add_argument('--abi', default='arm64-v8a', choices=sorted(ABIS))
        ap.add_argument('--home'); ap.add_argument('--pkg')
        ap.add_argument('--net', default='4', choices=('2', '2subset', '4'),
                        help='the class libraries to fetch: 2 / 2subset = the .NET 3.5 runtime\'s ".NET 2.0" / '
                             '".NET 2.0 Subset" profile, 4 = .NET 4.x (default)')
        ap.add_argument('--on-device', action='store_true', help="also the compiler tools for this aarch64 Linux machine")
        ap.add_argument('--toolchain', help='where they go (default <home>/device-arm64)')
        a = ap.parse_args(argv[1:])
        home = os.path.abspath(a.home or default_home())
        if a.on_device:
            from . import il2cpp_device as dev
            dev.install_ca()
        v = UV.Version(a.version)
        bcl = bcl_profile(v, int(a.net[0]), a.net == '2subset')[1]
        tc = toolchain(v, a.abi, home, a.pkg, bcl)
        if a.on_device:
            tools = [deploy_tool(tc['editor'], 'UnityLinker'), deploy_tool(tc['il2cpp_editor'], 'il2cpp')]
            tc['device_toolchain'] = dev.fetch(a.toolchain or dev.default_toolchain(home),
                                               dev.groups_for(tools, os.environ.get('PMUNITY_IL2CPP_NET471', 'dotnet')))
        print(json.dumps({k: v for k, v in tc.items() if k != 'player' and not (k == 'il2cpp_editor' and v == tc['editor'])},
                         indent=1))
        return
    ap = argparse.ArgumentParser(prog='pmunity il2cpp', description=__doc__.split('\n\n')[0],
                                 epilog='See docs/il2cpp.md.')
    ap.add_argument('data', help="the game's desktop data folder (read only)")
    ap.add_argument('out')
    ap.add_argument('--abi', default='arm64-v8a', choices=sorted(ABIS))
    ap.add_argument('--home', help='toolchain folder (default $PMUNITY_IL2CPP_HOME, else ~/.cache/pmunity/il2cpp)')
    ap.add_argument('--pkg', help='the IL2CPP Android player package (default <home>/<version>/player-<abi>)')
    ap.add_argument('--jobs', type=int, help='parallel compiles (CPUs given to the container; default min(4, CPUs))')
    ap.add_argument('--image', default=IMAGE, help='the stock image the tool folders are mounted into (default ubuntu:24.04)')
    ap.add_argument('--keep-cpp', action='store_true', help='keep the generated C++ and the object cache (<out>/.work)')
    ap.add_argument('--strip', default='low', choices=['low', 'none'],
                    help="managed code stripping: low (UnityLinker's conservative rules, as Unity's default for IL2CPP; "
                         "the game's and the engine's assemblies are kept whole) or none (every class library compiled "
                         "whole: about 3x the C++ and the build time)")
    ap.add_argument('--unity', metavar='VERSION',
                    help="the Unity version whose IL2CPP and player to build for (default: the data's; same line only; "
                         "2017.4 data before 2017.4.16f1 gets 2017.4.40f1 for arm64-v8a, the first with that player)")
    ap.add_argument('--managed-file', action='append', default=[], metavar='DLL',
                    help="an assembly compiled instead of the data's copy of the same name (or added): a port's patched "
                         "or helper assembly")
    ap.add_argument('--asmpatch', metavar='COMMAND',
                    help="tools/asmpatch's command (e.g. 'asmpatch --only=rewired-android'), run on <data>/Managed; the "
                         "assemblies it changes are compiled instead of the game's copies (as android-data --asmpatch)")
    ap.add_argument('--assembly-patch', nargs=2, action='append', default=[], metavar=('NAME', 'COMMAND'),
                    help="a port's patch of one of the game's assemblies (as android-data --assembly-patch): COMMAND runs "
                         "with {managed} = <data>/Managed and {out} = a folder where it writes NAME, which is compiled "
                         "instead of the game's copy")
    ap.add_argument('--streaming-assets', choices=ST.MODES, default='obb',
                    help="both / loose: also compile asmpatch's streaming-assets / streaming-assets-all patch (needs "
                         "--asmpatch): the game's System.IO reads of StreamingAssets get the folder android-data "
                         "--streaming-assets of the same mode puts beside the APK (docs/android-data.md, section 6)")
    ap.add_argument('--data-path', action='store_true',
                    help="also compile asmpatch's data-path patch (needs --asmpatch), for android-data --data-path")
    ap.add_argument('--link-xml', action='append', default=[], metavar='FILE',
                    help="a link.xml for UnityLinker (types and members to keep: what the game reaches only by "
                         "reflection, e.g. XmlSerializer's); nothing may come before <linker>, not even a comment, "
                         "or the 2017.x linker ignores the whole file")
    ap.add_argument('--dry-run', action='store_true', help='fetch and stage, print the commands, do not run them')
    ap.add_argument('--on-device', action='store_true',
                    help='run natively on this aarch64 Linux machine (a handheld\'s setup), without Docker: the tools '
                         'come from Debian\'s and Microsoft\'s servers (docs/il2cpp.md, "On the handheld")')
    ap.add_argument('--toolchain', help='--on-device: the tools folder (default <home>/device-arm64)')
    a = ap.parse_args(argv)
    if a.on_device:
        from . import il2cpp_device as dev
        dev.install_ca()
    try:
        build(a.data, a.out, a.abi, a.home, a.pkg, a.jobs, a.image, a.keep_cpp, a.dry_run, a.strip, a.unity,
              a.managed_file, a.asmpatch, a.on_device, a.toolchain, [os.path.abspath(x) for x in a.link_xml],
              [tuple(x) for x in a.assembly_patch], a.streaming_assets, a.data_path)
    except UV.Unsupported as ex:
        sys.exit(str(ex))
