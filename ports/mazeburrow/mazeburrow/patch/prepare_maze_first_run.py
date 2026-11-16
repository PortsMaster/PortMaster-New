#!/usr/bin/env python3
"""Maze Burrow PortMaster: first-run installation for the full game AND the demo.

Expected placement: mazeburrow/patch/prepare_maze_first_run.py
Run:      python3 "$GAMEDIR/patch/prepare_maze_first_run.py"
Probe:    python3 "$GAMEDIR/patch/prepare_maze_first_run.py" --pending
          (exit 0 = there is something to install, exit 3 = nothing to do)

Drop either of these into mazeburrow/ (or into gamedata/ / demodata/):
  maze-burrow-linux.zip                 full game, itch.io Linux ZIP  -> installed to gamedata/
  MazeBurrow_v0_7_LinuxInstaller.zip    demo, MojoSetup Linux installer -> installed to demodata/

Files are recognised by their CONTENT, not only by name, so a renamed ZIP still works.
Each ZIP is deleted once its install succeeds. No game data or executables are bundled here.

Updating: every install records a signature of the ZIP it came from. A different ZIP dropped
later is installed on the next launch; the same ZIP left lying around is ignored.
  * the full game always supersedes the demo: installing it removes the demo's game files
    (demo saves in savedata/demo are kept);
  * once the full game is installed a demo ZIP is ignored (no downgrade).
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import struct
import sys
import zipfile

PORT_DIR = Path(__file__).resolve().parent.parent
PATCH_DIR = PORT_DIR / 'patch'
FULL_DIR = PORT_DIR / 'gamedata'
DEMO_DIR = PORT_DIR / 'demodata'
SEARCH_DIRS = (PORT_DIR, FULL_DIR, DEMO_DIR)

FULL_MARKER = FULL_DIR / '.mazeburrow_setup_complete'
DEMO_MARKER = DEMO_DIR / '.mazeburrow_demo_setup_complete'

# ---- full game ---------------------------------------------------------------------------
FULL_ROOT = 'maze-burrow-linux'
# Application DLLs only, not the desktop .NET runtime's System.* DLLs.
FULL_DLLS = {
    'PuzzleGame.dll',
    'MonoGame.Framework.dll',
    'MonoGame.Extended.dll',
    'MonoGame.Extended.Tiled.dll',
    'Newtonsoft.Json.dll',
}
FULL_PATCHES = {
    'PuzzleGameGL.patched.dll': 'PuzzleGameGL.dll',
    'PuzzleGameGL.patched.deps.json': 'PuzzleGameGL.deps.json',
    'PuzzleGameGL.patched.runtimeconfig.json': 'PuzzleGameGL.runtimeconfig.json',
    'MonoGame.Framework.patched.dll': 'MonoGame.Framework.dll',
}

# ---- demo (v0.7, .NET Framework 4.7.2 / Mono mkbundle inside a MojoSetup installer) --------
DEMO_BUNDLE = 'data/MazeBurrow_v0_7'
DEMO_LIBS = (
    'MonoGame.Framework.dll',
    'MonoGame.Extended.dll',
    'MonoGame.Extended.Tiled.dll',
    'Newtonsoft.Json.dll',
)
DEMO_MG_MD5 = '9dda4dbcbf391138a85b80a5e685204e'   # MonoGame.Framework.dll shipped in the demo
# The demo ships Newtonsoft.Json built for .NET Framework 4.5; its BsonWriter/serializer needs
# System.Security.Permissions, which .NET 6 does not have (saving fails). The netstandard2.0 build
# (same assembly version 12.0.0.0, MIT licensed) is bundled in patch/ and used instead.
DEMO_NEWTONSOFT = 'Newtonsoft.Json.netstandard.dll'
# Bump when the demo patches change. Demo installs recorded with an older revision are upgraded in
# place on the next launch (their ZIP is long gone, so they cannot be reinstalled from it).
#   1 = SDL version check only (older package builds; no revision stored)
#   2 = + ADPCM music fix, + netstandard Newtonsoft.Json
DEMO_PATCH_REV = 2
DEMO_RUNTIMECONFIG = {
    'runtimeOptions': {
        'tfm': 'net6.0',
        'framework': {'name': 'Microsoft.NETCore.App', 'version': '6.0.0'},
        'rollForward': 'LatestPatch',
        'configProperties': {'System.Globalization.Invariant': True},
    }
}


def log(msg: str) -> None:
    print(f'[Maze Burrow] {msg}', flush=True)


# ---- helpers -----------------------------------------------------------------------------
def write_atomic(target: Path, data: bytes) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    temp = target.with_name(target.name + '.maze_tmp')
    try:
        temp.write_bytes(data)
        os.replace(temp, target)
    finally:
        if temp.exists():
            temp.unlink()


def safe_parts(name: str) -> tuple[str, ...]:
    p = PurePosixPath(name)
    parts = p.parts
    if not parts or p.is_absolute() or any(x in ('', '.', '..') for x in parts):
        raise ValueError(f'Unsafe ZIP path: {name}')
    return parts


def is_symlink(member: zipfile.ZipInfo) -> bool:
    return ((member.external_attr >> 16) & 0o170000) == 0o120000


def signature(path: Path) -> str:
    """Identity of a download: hash of the member names/CRCs/sizes of its ZIP directory."""
    h = hashlib.sha1()
    with zipfile.ZipFile(path) as z:
        for i in sorted(z.infolist(), key=lambda m: m.filename):
            h.update(f'{i.filename}|{i.CRC}|{i.file_size}\n'.encode())
    return h.hexdigest()


def read_marker(marker: Path) -> dict:
    try:
        data = json.loads(marker.read_text())
        return data if isinstance(data, dict) else {}
    except (OSError, ValueError):
        return {}                                  # missing, or an old plain-text marker


def read_marker_signature(marker: Path) -> str | None:
    return read_marker(marker).get('signature')


def write_marker(marker: Path, kind: str, sig: str | None, **extra) -> None:
    marker.write_text(json.dumps({'kind': kind, 'signature': sig, **extra}) + '\n')


def demo_needs_upgrade() -> bool:
    return (DEMO_MARKER.is_file() and not FULL_MARKER.is_file()
            and int(read_marker(DEMO_MARKER).get('patch_rev', 1)) < DEMO_PATCH_REV)


def candidates() -> list[Path]:
    """Every file that could be one of our two downloads."""
    seen: dict[Path, None] = {}
    for d in SEARCH_DIRS:
        if not d.is_dir():
            continue
        for f in sorted(d.iterdir()):
            if not f.is_file() or f.name.startswith('.'):
                continue
            low = f.name.lower()
            if low.endswith(('.txt', '.json', '.log', '.py')):
                continue
            if low.endswith('.zip') or 'mazeburrow_v0_7_linuxinstaller' in low:
                seen[f.resolve()] = None
    return sorted(seen, key=lambda f: f.stat().st_mtime, reverse=True)   # newest first


def classify(path: Path) -> str | None:
    """Return 'full', 'demo' or None by looking inside the file."""
    try:
        with zipfile.ZipFile(path) as z:
            names = z.namelist()
    except (zipfile.BadZipFile, OSError):
        return None
    if any(PurePosixPath(n).name == 'PuzzleGameGL.dll' and 'src' not in PurePosixPath(n).parts
           for n in names):
        return 'full'
    if DEMO_BUNDLE in names:                      # the MojoSetup ELF itself (zip appended)
        return 'demo'
    if len(names) == 1 and 'linuxinstaller' in names[0].lower():
        return 'demo'                             # the zip wrapper around the ELF
    return None


def find_work() -> dict[str, Path]:
    """What to install: the newest recognised download of each kind that is new or changed."""
    found: dict[str, list[Path]] = {'full': [], 'demo': []}
    for c in candidates():
        kind = classify(c)
        if kind:
            found[kind].append(c)

    work: dict[str, Path] = {}
    for c in found['full']:
        if not FULL_MARKER.is_file() or signature(c) != read_marker_signature(FULL_MARKER):
            work['full'] = c
            break
    # The demo is only ever installed while there is no full game (installed or about to be).
    if not FULL_MARKER.is_file() and 'full' not in work:
        for c in found['demo']:
            if not DEMO_MARKER.is_file() or signature(c) != read_marker_signature(DEMO_MARKER):
                work['demo'] = c
                break
    if 'demo' not in work and 'full' not in work and demo_needs_upgrade():
        work['demo_upgrade'] = DEMO_MARKER
    return work


# ---- full game ---------------------------------------------------------------------------
def install_full(zip_path: Path) -> None:
    log(f'Full game: installing from {zip_path.name}')
    for src in FULL_PATCHES:
        if not (PATCH_DIR / src).is_file():
            raise FileNotFoundError(f'Missing patched file: {PATCH_DIR / src}')
    FULL_DIR.mkdir(parents=True, exist_ok=True)

    count = 0
    with zipfile.ZipFile(zip_path) as archive:
        bad = archive.testzip()
        if bad:
            raise ValueError(f'Corrupt ZIP member: {bad}')
        for member in archive.infolist():
            if member.is_dir():
                continue
            parts = safe_parts(member.filename)
            # Official itch.io ZIP wraps all game files in maze-burrow-linux/.
            if parts[0] != FULL_ROOT or len(parts) < 2:
                continue
            rel = parts[1:]
            root = rel[0]
            # Keep compiled game content and config, plus app-managed DLLs.
            # Skip /src, /Docs, platform executables, x86-64 libraries, and
            # all System.* .NET runtime assemblies already in the squashfs.
            if root not in {'Content', 'Config'} and not (len(rel) == 1 and root in FULL_DLLS):
                continue
            if is_symlink(member):
                raise ValueError(f'Symlink ZIP entry not supported: {member.filename}')
            target = FULL_DIR.joinpath(*rel)
            target.parent.mkdir(parents=True, exist_ok=True)
            temp = target.with_name(target.name + '.maze_tmp')
            try:
                with archive.open(member) as inp, open(temp, 'wb') as out:
                    shutil.copyfileobj(inp, out, 1024 * 1024)
                os.replace(temp, target)
            finally:
                if temp.exists():
                    temp.unlink()
            count += 1

    # Only install the verified ARM64-ready modified game entry and deployment
    # metadata after extracting the original app dependencies and assets.
    for src, dest in FULL_PATCHES.items():
        write_atomic(FULL_DIR / dest, (PATCH_DIR / src).read_bytes())
        log(f'Full game: installed patched {dest}')

    essentials = [
        FULL_DIR / 'PuzzleGameGL.dll',
        FULL_DIR / 'PuzzleGame.dll',
        FULL_DIR / 'MonoGame.Framework.dll',
        FULL_DIR / 'MonoGame.Extended.Tiled.dll',
        FULL_DIR / 'Newtonsoft.Json.dll',
        FULL_DIR / 'PuzzleGameGL.deps.json',
        FULL_DIR / 'PuzzleGameGL.runtimeconfig.json',
    ]
    missing = [str(p) for p in essentials if not p.is_file()]
    if missing:
        raise RuntimeError('Missing required files after extraction: ' + ', '.join(missing))

    write_marker(FULL_MARKER, 'full', signature(zip_path))
    log(f'Full game: installation completed: {count} original game files + {len(FULL_PATCHES)} patches.')
    remove_source(zip_path)

    # The full game supersedes the demo. Its saves (savedata/demo) are not touched.
    if DEMO_DIR.is_dir():
        shutil.rmtree(DEMO_DIR, ignore_errors=True)
        log('Demo: removed demo game files (full game installed); demo saves were kept.')


# ---- demo --------------------------------------------------------------------------------
def carve_game_assembly(bundle: bytes) -> bytes:
    """Cut PuzzleGameGL.exe out of the Mono mkbundle. It is plain AnyCPU IL (PE32/I386/ILONLY),
    which CoreCLR loads on arm64 as-is, so no PE header patch is needed."""
    for m in re.finditer(rb'MZ\x90\x00\x03', bundle):
        o = m.start()
        if o + 0x40 > len(bundle):
            continue
        pe = struct.unpack_from('<I', bundle, o + 0x3C)[0]
        if bundle[o + pe:o + pe + 4] != b'PE\0\0':
            continue
        nsec, = struct.unpack_from('<H', bundle, o + pe + 6)
        opt, = struct.unpack_from('<H', bundle, o + pe + 20)
        st, end = o + pe + 24 + opt, 0
        for i in range(nsec):
            raw, rawp = struct.unpack_from('<II', bundle, st + 40 * i + 16)
            end = max(end, rawp + raw)
        blob = bundle[o:o + end]
        if b'PuzzleGameGL.exe' in blob and b'BSJB' in blob:
            return blob
    raise RuntimeError('PuzzleGameGL assembly not found inside the demo executable')


def patch_demo_monogame(dll: bytes) -> bytes:
    """Two IL fixes in the demo's MonoGame.Framework.dll.

    1) SDL version check. MonoGame guards SdlGameWindow.AllowUserResizing (and the window-position
       logic) with `Sdl.Patch > 4`, i.e. only the SDL *patch* number. SDL 2.2x.0-2.2x.4 therefore
       count as "SDL 2.0.4" and the game dies with 'SDL 2.0.4 does not support changing
       resizable...'.  ldc.i4.4 -> ldc.i4.m1 makes both checks behave as 'newer SDL'.

    2) Music ("Attempted to divide by zero"). All music is IMA ADPCM. After uploading a buffer,
       OALSoundBuffer.BindDataBuffer computes Duration = size / ((bits / 8) * channels) using
       AL_BITS, which current OpenAL Soft reports as 0 (or 4) for ADPCM, so bits/8 == 0 and the
       integer division throws; the music never loads. OpenAL decodes ADPCM to 16-bit, and the
       game never reads Duration, so `ldloc.1; ldc.i4.8; div` -> `ldc.i4.2; nop; nop`
       (2 bytes per sample) is both safe and correct for PCM16/ADPCM."""
    data = bytearray(dll)
    if hashlib.md5(data).hexdigest() != DEMO_MG_MD5:
        log('Demo: MonoGame.Framework.dll is not the pristine v0.7 build (already patched?), using pattern patches')
    raw = bytes(data)

    # (1) ldsfld Sdl::Patch ; ldc.i4.4 ; ble.s|bgt.s     (patched form: ldc.i4.m1 = 0x15)
    todo = [m.start() + 5 for m in re.finditer(rb'\x7e\x04\x00\x00\x04\x1a[\x30\x31]', raw)]
    done = len(re.findall(rb'\x7e\x04\x00\x00\x04\x15[\x30\x31]', raw))
    if len(todo) + done != 2:
        raise RuntimeError(f'Demo: expected 2 Sdl.Patch checks in MonoGame.Framework.dll, found {len(todo) + done}')
    for h in todo:
        data[h] = 0x15

    # (2) ldloc.0 ; ldloc.1 ; ldc.i4.8 ; div ; ldloc.2 ; mul ; div ; conv.r4
    #     (patched form: ldloc.0 ; ldc.i4.2 ; nop ; nop ; ldloc.2 ; ...)
    todo2 = [m.start() for m in re.finditer(rb'\x06\x07\x1e\x5b\x08\x5a\x5b\x6b', raw)]
    done2 = len(re.findall(rb'\x06\x18\x00\x00\x08\x5a\x5b\x6b', raw))
    if len(todo2) + done2 != 1:
        raise RuntimeError('Demo: expected 1 audio duration calculation in MonoGame.Framework.dll, '
                           f'found {len(todo2) + done2}')
    for h in todo2:
        data[h + 1:h + 4] = b'\x18\x00\x00'

    log('Demo: MonoGame.Framework.dll patched (SDL version check, ADPCM music)')
    return bytes(data)


def install_demo(path: Path) -> None:
    log(f'Demo: installing from {path.name}')
    sig = signature(path)
    DEMO_DIR.mkdir(parents=True, exist_ok=True)
    tmp_elf = None
    try:
        # Either the .zip wrapper (one member: the ELF installer) or the ELF itself.
        with zipfile.ZipFile(path) as outer:
            names = outer.namelist()
            if DEMO_BUNDLE in names:
                installer = path
            else:
                tmp_elf = DEMO_DIR / '.installer.maze_tmp'
                with outer.open(names[0]) as inp, open(tmp_elf, 'wb') as out:
                    shutil.copyfileobj(inp, out, 1024 * 1024)
                installer = tmp_elf

        count = 0
        with zipfile.ZipFile(installer) as z:   # zipfile skips the ELF stub in front of the archive
            if DEMO_BUNDLE not in z.namelist():
                raise RuntimeError('Not a Maze Burrow demo installer (game executable missing)')

            write_atomic(DEMO_DIR / 'PuzzleGameGL.dll', carve_game_assembly(z.read(DEMO_BUNDLE)))
            netstandard_json = PATCH_DIR / DEMO_NEWTONSOFT
            if not netstandard_json.is_file():
                raise FileNotFoundError(f'Missing bundled file: {netstandard_json}')
            for lib in DEMO_LIBS:
                data = z.read('data/lib/' + lib)
                if lib == 'MonoGame.Framework.dll':
                    data = patch_demo_monogame(data)
                elif lib == 'Newtonsoft.Json.dll':
                    data = netstandard_json.read_bytes()
                    log('Demo: using the netstandard Newtonsoft.Json (saving needs it on .NET 6)')
                write_atomic(DEMO_DIR / lib, data)
            write_atomic(DEMO_DIR / 'PuzzleGameGL.runtimeconfig.json',
                         json.dumps(DEMO_RUNTIMECONFIG, indent=2).encode())
            # A deps.json would only get in the way: the host adds every DLL in the folder itself.
            stale = DEMO_DIR / 'PuzzleGameGL.deps.json'
            if stale.exists():
                stale.unlink()

            for member in z.infolist():
                if member.is_dir() or not member.filename.startswith('data/Content/'):
                    continue
                parts = safe_parts(member.filename)
                if is_symlink(member):
                    raise ValueError(f'Symlink ZIP entry not supported: {member.filename}')
                target = DEMO_DIR.joinpath(*parts[1:])
                target.parent.mkdir(parents=True, exist_ok=True)
                temp = target.with_name(target.name + '.maze_tmp')
                try:
                    with z.open(member) as inp, open(temp, 'wb') as out:
                        shutil.copyfileobj(inp, out, 1024 * 1024)
                    os.replace(temp, target)
                finally:
                    if temp.exists():
                        temp.unlink()
                count += 1
    finally:
        if tmp_elf is not None and tmp_elf.exists():
            tmp_elf.unlink()

    essentials = [DEMO_DIR / n for n in ('PuzzleGameGL.dll', 'PuzzleGameGL.runtimeconfig.json', *DEMO_LIBS)]
    missing = [str(p) for p in essentials if not p.is_file()]
    if missing or count == 0:
        raise RuntimeError('Demo: missing required files after extraction: ' + ', '.join(missing or ['Content']))

    write_marker(DEMO_MARKER, 'demo', sig, patch_rev=DEMO_PATCH_REV)
    log(f'Demo: installation completed: {count} content files + game + 4 libraries.')
    remove_source(path)


def upgrade_demo() -> None:
    """Bring an existing demo install (older package build) up to the current patch revision."""
    log('Demo: upgrading installed demo files to the current patches')
    mg = DEMO_DIR / 'MonoGame.Framework.dll'
    bundled = PATCH_DIR / DEMO_NEWTONSOFT
    for need in (mg, bundled):
        if not need.is_file():
            raise FileNotFoundError(f'Cannot upgrade the demo, missing {need}')
    write_atomic(mg, patch_demo_monogame(mg.read_bytes()))
    write_atomic(DEMO_DIR / 'Newtonsoft.Json.dll', bundled.read_bytes())
    write_marker(DEMO_MARKER, 'demo', read_marker_signature(DEMO_MARKER), patch_rev=DEMO_PATCH_REV)
    log('Demo: upgrade complete')


def remove_source(path: Path) -> None:
    try:
        path.unlink()
        log(f'Removed {path.name}')
    except OSError as exc:
        log(f'Could not remove {path}: {exc}')


# ---- entry point -------------------------------------------------------------------------
def main(argv: list[str]) -> int:
    work = find_work()
    nothing_installed = not FULL_MARKER.is_file() and not DEMO_MARKER.is_file()
    if '--pending' in argv:
        # Also report "pending" when nothing is installed but a download is lying around that we
        # could not recognise, so the real run can explain what is wrong with it.
        return 0 if work or (nothing_installed and candidates()) else 3
    if not work:
        if not nothing_installed:
            log('Setup already complete.')
            return 0
        bad = [c.name for c in candidates()]
        if bad:
            raise ValueError(
                'Found ' + ', '.join(bad) + ' but it is not a complete Maze Burrow download '
                '(full game: maze-burrow-linux.zip, demo: MazeBurrow_v0_7_LinuxInstaller.zip). '
                'It may be corrupt or incompletely copied: copy it again.')
        raise FileNotFoundError(
            'No game files found. Put maze-burrow-linux.zip (full game) and/or '
            f'MazeBurrow_v0_7_LinuxInstaller.zip (demo) in {PORT_DIR}')
    failed = False
    for kind, installer in (('full', install_full), ('demo', install_demo),
                            ('demo_upgrade', lambda _marker: upgrade_demo())):
        if kind in work:
            try:
                installer(work[kind])
            except (OSError, ValueError, RuntimeError, zipfile.BadZipFile) as exc:
                failed = True
                print(f'[Maze Burrow] SETUP ERROR ({kind}): {exc}', file=sys.stderr)
    return 1 if failed else 0


if __name__ == '__main__':
    try:
        sys.exit(main(sys.argv[1:]))
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile) as exc:
        print(f'[Maze Burrow] SETUP ERROR: {exc}', file=sys.stderr)
        sys.exit(1)
