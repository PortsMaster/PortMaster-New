#!/usr/bin/env python3
"""Maze Burrow first-run setup: installs the full game and/or the demo from the ZIP you drop in.

  maze-burrow-linux.zip                -> full game, installed to gamedata/
  MazeBurrow_v0_7_LinuxInstaller.zip   -> demo,      installed to demodata/

Rules (kept deliberately simple):
  * A ZIP in the port folder (or gamedata/) is recognised by its file name, any letter case.
  * A ZIP that is present is installed, then deleted. Drop a newer ZIP later and it updates.
  * The full game replaces the demo; once it is installed a demo ZIP is ignored.

Usage: prepare_maze_first_run.py            install what was found
       prepare_maze_first_run.py --pending  exit 0 if there is something to install, else 1
"""
from __future__ import annotations

import hashlib
import io
import json
import shutil
import sys
import zipfile
from pathlib import Path, PurePosixPath

PORT = Path(__file__).resolve().parent.parent
PATCHES = PORT / 'patch'
FULL, DEMO = PORT / 'gamedata', PORT / 'demodata'
FULL_DONE = FULL / '.mazeburrow_setup_complete'        # marker names are used by "Maze Burrow.sh"
DEMO_DONE = DEMO / '.mazeburrow_demo_setup_complete'

FULL_PREFIX = 'maze-burrow-linux'
DEMO_PREFIX = 'mazeburrow_v0_7_linuxinstaller'

# ---- full game: only app DLLs + game data; the .NET runtime itself comes from the squashfs ----
FULL_DLLS = {'PuzzleGame.dll', 'MonoGame.Framework.dll', 'MonoGame.Extended.dll',
             'MonoGame.Extended.Tiled.dll', 'Newtonsoft.Json.dll'}
FULL_PATCHED_FILES = {                                  # patch/ name -> installed name
    'PuzzleGameGL.patched.dll': 'PuzzleGameGL.dll',
    'PuzzleGameGL.patched.deps.json': 'PuzzleGameGL.deps.json',
    'PuzzleGameGL.patched.runtimeconfig.json': 'PuzzleGameGL.runtimeconfig.json',
    'MonoGame.Framework.patched.dll': 'MonoGame.Framework.dll',
}

# ---- demo v0.7: a Mono "mkbundle" inside a MojoSetup installer, all of it .NET Framework 4.x ----
DEMO_BUNDLE = 'data/MazeBurrow_v0_7'
DEMO_EXE = (0x454000, 832000, '9fbdadce473ee10cec49d09e6f9b2505')   # (offset in bundle, size, md5)
DEMO_LIBS = ['MonoGame.Framework.dll', 'MonoGame.Extended.dll', 'MonoGame.Extended.Tiled.dll']
DEMO_MONOGAME_MD5 = '9dda4dbcbf391138a85b80a5e685204e'
# (file offset, original bytes, new bytes) for the demo's MonoGame.Framework.dll
DEMO_MONOGAME_PATCHES = [
    # MonoGame only compares the SDL *patch* number (`Sdl.Patch > 4`), so SDL 2.2x.0-2.2x.4 look
    # like "SDL 2.0.4" and the game dies setting AllowUserResizing: ldc.i4.4 -> ldc.i4.m1.
    (0x36375, b'\x1a', b'\x15'),
    (0x36953, b'\x1a', b'\x15'),
    # Music is IMA ADPCM, for which OpenAL reports 0 bits per sample, so MonoGame's
    # `size / ((bits / 8) * channels)` divides by zero and the track never loads.
    # `ldloc.1; ldc.i4.8; div` -> `ldc.i4.2; nop; nop` (16-bit; the game never reads Duration).
    (0x549FE, b'\x07\x1e\x5b', b'\x18\x00\x00'),
]
DEMO_RUNTIMECONFIG = {'runtimeOptions': {
    'tfm': 'net6.0',
    'framework': {'name': 'Microsoft.NETCore.App', 'version': '6.0.0'},
    'rollForward': 'LatestPatch',
    'configProperties': {'System.Globalization.Invariant': True}}}


def log(msg):
    print(f'[Maze Burrow] {msg}', flush=True)


def find_zip(prefix):
    """Newest .zip in the port folder or gamedata/ whose name starts with `prefix`."""
    zips = [f for folder in (PORT, FULL) if folder.is_dir() for f in folder.iterdir()
            if f.suffix.lower() == '.zip' and f.name.lower().startswith(prefix)]
    return max(zips, key=lambda f: f.stat().st_mtime, default=None)


def extract(archive, pick, dest):
    """Copy archive members to dest. pick(path parts) gives the path under dest, or None to skip."""
    count = 0
    for member in archive.infolist():
        parts = PurePosixPath(member.filename).parts
        if member.is_dir() or '..' in parts or member.filename.startswith('/'):
            continue
        rel = pick(parts)
        if rel:
            target = dest.joinpath(*rel)
            target.parent.mkdir(parents=True, exist_ok=True)
            with archive.open(member) as src, open(target, 'wb') as out:
                shutil.copyfileobj(src, out)
            count += 1
    return count


def check_md5(data, expected, what):
    if hashlib.md5(data).hexdigest() != expected:
        raise RuntimeError(f'{what} is not the expected v0.7 build, so it cannot be patched safely')


def install_full(zip_path):
    log(f'Full game: installing from {zip_path.name}')

    def pick(parts):  # the official ZIP keeps everything inside maze-burrow-linux/
        rel = parts[1:] if parts[0] == FULL_PREFIX else ()
        if rel and (rel[0] in ('Content', 'Config') or (len(rel) == 1 and rel[0] in FULL_DLLS)):
            return rel

    with zipfile.ZipFile(zip_path) as archive:
        count = extract(archive, pick, FULL)
    for src, name in FULL_PATCHED_FILES.items():
        shutil.copyfile(PATCHES / src, FULL / name)

    missing = [n for n in FULL_DLLS | set(FULL_PATCHED_FILES.values()) if not (FULL / n).is_file()]
    if missing or count == 0:
        raise RuntimeError('missing after extraction: ' + ', '.join(missing or ['Content']))

    FULL_DONE.write_text('installed\n')
    zip_path.unlink()
    log(f'Full game: done ({count} files + {len(FULL_PATCHED_FILES)} patches)')
    if DEMO.is_dir():                                    # the full game replaces the demo
        shutil.rmtree(DEMO, ignore_errors=True)          # (demo saves live in savedata/demo)
        log('Demo: removed, the full game is installed')


def install_demo(zip_path):
    log(f'Demo: installing from {zip_path.name}')
    DEMO.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(zip_path) as outer:
        # the downloaded ZIP holds one file, the MojoSetup installer, which is itself a ZIP
        installer = zipfile.ZipFile(io.BytesIO(outer.read(outer.namelist()[0])))
    with installer:
        offset, size, md5 = DEMO_EXE
        exe = installer.read(DEMO_BUNDLE)[offset:offset + size]
        check_md5(exe, md5, 'The demo executable')
        (DEMO / 'PuzzleGameGL.dll').write_bytes(exe)

        for lib in DEMO_LIBS:
            data = installer.read('data/lib/' + lib)
            if lib == 'MonoGame.Framework.dll':
                check_md5(data, DEMO_MONOGAME_MD5, lib)
                data = bytearray(data)
                for at, _old, new in DEMO_MONOGAME_PATCHES:
                    data[at:at + len(new)] = new
            (DEMO / lib).write_bytes(data)
        # The demo's own Newtonsoft.Json targets .NET Framework and cannot save on .NET 6
        # (needs System.Security.Permissions); use the netstandard build, same assembly version.
        shutil.copyfile(PATCHES / 'Newtonsoft.Json.netstandard.dll', DEMO / 'Newtonsoft.Json.dll')
        (DEMO / 'PuzzleGameGL.runtimeconfig.json').write_text(json.dumps(DEMO_RUNTIMECONFIG, indent=2))

        count = extract(installer, lambda p: p[1:] if p[:2] == ('data', 'Content') else None, DEMO)
    if count == 0:
        raise RuntimeError('the demo installer contains no Content')

    DEMO_DONE.write_text('installed\n')
    zip_path.unlink()
    log(f'Demo: done ({count} content files)')


def main():
    full_zip = find_zip(FULL_PREFIX)
    demo_zip = None if full_zip or FULL_DONE.exists() else find_zip(DEMO_PREFIX)

    if '--pending' in sys.argv:
        return 0 if full_zip or demo_zip else 1
    if not (full_zip or demo_zip):
        if FULL_DONE.exists() or DEMO_DONE.exists():
            return 0
        log(f'No game files found. Put maze-burrow-linux.zip (full game) or '
            f'MazeBurrow_v0_7_LinuxInstaller.zip (demo) in {PORT}')
        return 1
    try:
        if full_zip:
            install_full(full_zip)
        else:
            install_demo(demo_zip)
    except (OSError, RuntimeError, KeyError, zipfile.BadZipFile) as exc:
        print(f'[Maze Burrow] SETUP ERROR: {exc} (is the ZIP complete? copy it again)', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
