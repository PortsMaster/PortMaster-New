"""`python -m pmunity player`: Unity's Android player of an exact Unity version, fetched from Unity.

    python -m pmunity player url <version>
    python -m pmunity player fetch <version> <dir> [--backend mono|il2cpp] [--abi armeabi-v7a|arm64-v8a]
                                                   [--installer FILE|URL] [--symbols | --symbols-only] [--managed]
    python -m pmunity player donor <version> <dir> --apk APK [--apk APK] [--backend ...] [--abi ...] [--managed]

A game runs on the Android player of the Unity version it was built with (`python -m pmunity version
<data>` reads it). Unity's release API (services.api.unity.com) names that version's Android Build
Support installer (TargetSupportInstaller/UnitySetup-Android-Support-for-Editor-<version>.exe). It is
a non-solid NSIS installer, so only the files a port needs are read, one HTTP range request each
(nsis.py): about 10 MB of a 200-700 MB download. --installer reads a local copy (or another URL).

<dir> gets the player package layout `android-data --pkg` reads:
  Data/unity default resources                   (Unity 6: Data/Resources/unity default resources)
  Variations/mono/Managed/*.dll                  the Android UnityEngine assemblies (mono; il2cpp with --managed:
                                                 the IL2CPP player's, for the Mono route on it, docs/mono-arm64.md)
  Variations/<backend>/Release/Libs/<abi>/*.so   libmain.so, libunity.so
  Variations/mono/Release/MonoLibs/<abi>/*.so    libmono.so (Mono 2.x), libmonobdwgc-2.0.so (4.x), ...
  Apk/MemoryAdvice/*                             the Android Game SDK's Memory Advice models (realtime.tflite,
                                                 realtime_features.json, ...): 2023.1's players read them from
                                                 the APK's assets and abort without them
  player.json                                    version, changeset, backend, abi, installer
  Variations/<backend>/Release/Symbols/<abi>/*.sym.so   with --symbols: libunity's and libmain's symbol
                                                 files, for crash reports and samplers (tools/analysis); a
                                                 game's own Android build (pmunity apk) carries the libraries
                                                 but not these: --symbols-only fetches just them
Unity's files stay Unity's: whoever installs a port fetches them, or the port ships a donor: a game
of its own built with Unity (the same version, a free licence), whose APK carries the player (`donor`:
the same layout from its lib/ and assets/bin/Data/, no network). An IL2CPP donor has no UnityEngine
assemblies, so --managed takes them from a Mono donor of the same version (the IL2CPP player's own
copies differ only in what the IL2CPP build itself uses).
"""
import argparse
import fnmatch
import json
import os
import re
import sys
import urllib.parse
import urllib.request

API = 'https://services.api.unity.com/unity/editor/release/v1/releases'
CDN = 'https://download.unity3d.com/download_unity/{rev}/TargetSupportInstaller/UnitySetup-Android-Support-for-Editor-{ver}.exe'


def release(version):
    """Unity's release record of `version` (e.g. '2019.4.40f1'), or None if Unity does not list it."""
    q = urllib.parse.urlencode({'version': version, 'limit': 1})
    with urllib.request.urlopen(f'{API}?{q}', timeout=60) as r:
        d = json.load(r)
    for rec in d.get('results', []):
        if rec.get('version') == version:
            return rec
    return None


def installer_url(rec):
    """The Windows Android Build Support installer of a release record: the API's module URL, else
    the CDN path built from the changeset (the API lists the module for every version so far)."""
    for dl in rec.get('downloads', []):
        if dl.get('platform') != 'WINDOWS':
            continue
        for m in dl.get('modules', []):
            if m.get('id') == 'android' and str(m.get('url', '')).endswith('.exe'):
                return m['url']
    rev = rec.get('shortRevision')
    if not rev:
        raise SystemExit(f"Unity's release record of {rec.get('version')} has no Android installer or changeset")
    return CDN.format(rev=rev, ver=rec['version'])


def package_path(nsis_path):
    """The installer's path of a player file relative to the AndroidPlayer folder: the first
    component is the install folder variable ('$_OUTDIR', or '$INSTDIR$_59_' in older installers)."""
    parts = nsis_path.split('/')
    return '/'.join(parts[1:]) if parts and parts[0].startswith('$') else None


DEFAULT_RESOURCES = ('Data/unity default resources', 'Data/Resources/unity default resources')   # Unity 6: the second


def wanted(backend, abi, symbols=False, symbols_only=False, managed=False):
    sym = [f'Variations/{backend}/Release/Symbols/{abi}/*.sym.so']
    if symbols_only:
        return sym
    g = list(DEFAULT_RESOURCES) + [f'Variations/{backend}/Release/Libs/{abi}/*.so', 'Apk/MemoryAdvice/*']
    if backend == 'mono':
        g += ['Variations/mono/Managed/*.dll', f'Variations/mono/Release/MonoLibs/{abi}/*.so']
    elif managed:
        g += [f'Variations/{backend}/Managed/*.dll']
    return g + (sym if symbols else [])


def fetch(version, out, backend='mono', abi='armeabi-v7a', installer=None, log=print, symbols=False, symbols_only=False,
          managed=False):
    from . import nsis
    rec = None
    if not installer:
        rec = release(version)
        if rec is None:
            raise SystemExit(f'Unity does not list version {version} (check `python -m pmunity version <data>`)')
        installer = installer_url(rec)
    log(f'player {version} ({backend}, {abi}) from {installer}')
    ns = nsis.Nsis(installer)
    globs = wanted(backend, abi, symbols, symbols_only, managed)
    got = []
    for path, off, _ in sorted(ns.files()):
        rel = package_path(path)
        if rel is None or not any(fnmatch.fnmatchcase(rel, g) for g in globs):
            continue
        if rel.endswith(('.sym.so', '.dbg.so')) and '/Symbols/' not in rel:
            continue
        data = ns.extract(off)
        dst = os.path.join(out, *rel.split('/'))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        with open(dst + '.part', 'wb') as f:
            f.write(data)
        os.replace(dst + '.part', dst)
        got.append(rel)
    libs = f'Variations/{backend}/Release/Libs/{abi}/'
    missing = [n for n in ('libmain.so', 'libunity.so') if libs + n not in got]
    if not any(n in got for n in DEFAULT_RESOURCES):
        missing.append('Data/unity default resources')
    if symbols_only:
        missing = [] if any(r.endswith('/libunity.sym.so') for r in got) else ['libunity.sym.so']
    if missing:
        raise SystemExit(f'the installer has no {", ".join(missing)} for {backend}/{abi} '
                         f'(Unity ships arm64-v8a players only with IL2CPP, from 2017.4.16 / 2018.2)')
    info = {'version': version, 'changeset': (rec or {}).get('shortRevision'), 'backend': backend, 'abi': abi,
            'installer': installer, 'files': len(got)}
    if symbols or symbols_only:
        info['symbols'] = sorted(r for r in got if '/Symbols/' in r)
    if not symbols_only:
        with open(os.path.join(out, 'player.json'), 'w') as f:
            json.dump(info, f, indent=1)
    log(f'{len(got)} files, {ns.s.fetched / 1e6:.1f} MB read ({ns.s.requests} requests) -> {out}')
    return info


def donor(version, out, apks, backend='mono', abi='armeabi-v7a', managed=False, log=print):
    """The player package layout from donor APKs (a Unity game's Android build of `version`)."""
    import zipfile
    got = []
    for apk in apks:
        with zipfile.ZipFile(apk) as z:
            names = z.namelist()
            lib_abi = f'lib/{abi}/libunity.so' in names
            if lib_abi:
                v = z.read(f'lib/{abi}/libunity.so')
                if version.encode() not in v:
                    raise SystemExit(f'{apk}: its player is not Unity {version}')
            for n in names:
                rel = None
                if lib_abi and n in (f'lib/{abi}/libmain.so', f'lib/{abi}/libunity.so'):
                    rel = f'Variations/{backend}/Release/Libs/{abi}/' + n.rsplit('/', 1)[1]
                elif lib_abi and backend == 'mono' and n.startswith(f'lib/{abi}/libmono'):
                    rel = f'Variations/mono/Release/MonoLibs/{abi}/' + n.rsplit('/', 1)[1]
                elif re.fullmatch(r'assets/bin/Data/Managed/UnityEngine(\.\w+Module)?\.dll', n) \
                        and (backend == 'mono' or managed):     # (the engine's; the class libraries are the game's)
                    rel = f'Variations/{backend}/Managed/' + n.rsplit('/', 1)[1]
                elif n == 'assets/bin/Data/unity default resources':
                    rel = 'Data/unity default resources'
                if rel is None:
                    continue
                dst = os.path.join(out, *rel.split('/'))
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                with open(dst + '.part', 'wb') as f:
                    f.write(z.read(n))
                os.replace(dst + '.part', dst)
                got.append(rel)
    libs = f'Variations/{backend}/Release/Libs/{abi}/'
    need = [libs + 'libmain.so', libs + 'libunity.so', 'Data/unity default resources']
    if backend == 'mono' or managed:
        need.append(f'Variations/{backend}/Managed/UnityEngine.dll')
    if backend == 'mono':
        need.append(f'Variations/mono/Release/MonoLibs/{abi}/libmono.so')
    missing = [n for n in need if n not in got and not any(g.startswith(n) for g in got)]
    if missing:
        raise SystemExit(f'the donors have no {", ".join(missing)} for {backend}/{abi}')
    info = {'version': version, 'backend': backend, 'abi': abi, 'donors': [os.path.basename(a) for a in apks],
            'files': len(got)}
    with open(os.path.join(out, 'player.json'), 'w') as f:
        json.dump(info, f, indent=1)
    log(f'player {version} ({backend}, {abi}) from {len(apks)} donor(s): {len(got)} files -> {out}')
    return info


def main(argv):
    ap = argparse.ArgumentParser(prog='pmunity player', description=__doc__.split('\n\n')[0])
    sub = ap.add_subparsers(dest='cmd', required=True)
    u = sub.add_parser('url', help="the version's Android Build Support installer")
    u.add_argument('version')
    f = sub.add_parser('fetch', help="the player files a port needs, into DIR")
    f.add_argument('version'); f.add_argument('dir')
    f.add_argument('--backend', default='mono', choices=['mono', 'il2cpp'])
    f.add_argument('--abi', default='armeabi-v7a', choices=['armeabi-v7a', 'arm64-v8a'])
    f.add_argument('--installer', help='a local copy (or another URL) of the installer')
    f.add_argument('--symbols', action='store_true', help="also libunity's and libmain's symbol files (*.sym.so)")
    f.add_argument('--symbols-only', action='store_true', help='only the symbol files (for a game\'s own Android build)')
    f.add_argument('--managed', action='store_true',
                   help="with --backend il2cpp: also the IL2CPP player's UnityEngine assemblies (the Mono route on it)")
    d = sub.add_parser('donor', help="the same files from donor APKs (no network)")
    d.add_argument('version'); d.add_argument('dir')
    d.add_argument('--apk', action='append', required=True, help='a donor APK (repeatable)')
    d.add_argument('--backend', default='mono', choices=['mono', 'il2cpp'])
    d.add_argument('--abi', default='armeabi-v7a', choices=['armeabi-v7a', 'arm64-v8a'])
    d.add_argument('--managed', action='store_true', help='with --backend il2cpp: UnityEngine assemblies from a Mono donor')
    a = ap.parse_args(argv)
    if a.cmd == 'url':
        rec = release(a.version)
        if rec is None:
            raise SystemExit(f'Unity does not list version {a.version}')
        print(installer_url(rec))
    elif a.cmd == 'donor':
        donor(a.version, a.dir, a.apk, a.backend, a.abi, a.managed, log=lambda m: print(m, file=sys.stderr))
    else:
        fetch(a.version, a.dir, a.backend, a.abi, a.installer, log=lambda m: print(m, file=sys.stderr),
              symbols=a.symbols, symbols_only=a.symbols_only, managed=a.managed)
