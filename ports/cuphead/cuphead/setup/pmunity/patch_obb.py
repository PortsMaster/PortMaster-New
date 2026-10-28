"""`python -m pmunity patch-obb`: asset bundles added to an installed game as its patch OBB.

    python -m pmunity patch-obb new <bundles dir> <game dir>     the bundles the game does not have yet
    python -m pmunity patch-obb ggm <game dir> <out file>        the game's globalgamemanagers (its
                                                                 Unity version, for `convert`)
    python -m pmunity patch-obb pack <bundles dir> <game dir>    patch.<version>.<package>.obb

An add-on that comes after the setup (Cuphead's DLC: asset bundles only) is converted on its own
(`convert` on a folder of the new bundles beside the game's globalgamemanagers) and packed beside the
installed game (<game dir>: its APK, main OBB and android_package.json, as android-data left them):
Unity's Android player mounts patch.<version>.<package>.obb next to the main one and finds a bundle
in either. Each bundle gets the Android platform as android-data gives the game's own (streamed
textures inlined, the CAB platform set), the OBB the build-id marker. The built game is not touched.
"""
import json
import os
import shutil
import sys
import zipfile

from . import android_data as AD
from . import streaming as ST

PREFIX = 'assets/AssetBundles/'


def package(game):
    with open(os.path.join(game, 'android_package.json')) as f:
        return json.load(f)


def archives(game):
    pk = package(game)
    names = [pk.get('apk', ''), pk.get('main_obb', ''), f"patch.{pk['version_code']}.{pk['package']}.obb"]
    return [os.path.join(game, n) for n in names if n and os.path.isfile(os.path.join(game, n))]


def have(game):
    """The bundle names the installed game's archives hold."""
    got = set()
    for a in archives(game):
        with zipfile.ZipFile(a) as z:
            got |= {n[len(PREFIX):] for n in z.namelist() if n.startswith(PREFIX)}
    return got


def new(bundles, game):
    got = have(game)
    return sorted(n for n in os.listdir(bundles) if not n.startswith('.') and n not in got
                  and os.path.isfile(os.path.join(bundles, n)))


def ggm(game, out):
    pk = package(game)
    with zipfile.ZipFile(os.path.join(game, pk['apk'])) as z, open(out, 'wb') as f:
        f.write(z.read('assets/bin/Data/globalgamemanagers'))


def pack(bundles, game, log=print):
    pk = package(game)
    obb = os.path.join(game, f"patch.{pk['version_code']}.{pk['package']}.obb")
    if os.path.exists(obb):
        raise SystemExit(f'{obb}: there is a patch OBB already')
    stage = os.path.join(bundles, '.android')
    shutil.rmtree(stage, ignore_errors=True)
    os.makedirs(stage)
    entries = [('assets/' + pk['build_id'], b'')]               # the main OBB's marker
    for n in sorted(os.listdir(bundles)):
        src = os.path.join(bundles, n)
        if n.startswith('.') or not os.path.isfile(src) or not AD.is_unityfs(src):
            continue
        dst = os.path.join(stage, n)
        if any(nm.endswith('.resS') for _, _, _, nm in AD.Bundle(src).nodes):
            AD.inline_bundle(src, dst)                          # (as android-data: streamed textures inlined)
        else:
            shutil.copyfile(src, dst)
            try:
                AD.patch_bundle_platform(dst)
            except ValueError as ex:                            # (LZMA blocks: rewritten as LZ4)
                ST.repack_bundle(dst, AD.ANDROID, AD.write_bytes, why=str(ex))
        entries.append((PREFIX + n, dst))
    if len(entries) == 1:
        raise SystemExit(f'{bundles}: no asset bundles')
    AD._write_zip(obb, entries, log)
    AD.verify_zip(obb, entries, log)
    shutil.rmtree(stage, ignore_errors=True)
    return obb


def main(argv):
    if len(argv) == 3 and argv[0] == 'new':
        print('\n'.join(new(argv[1], argv[2])))
    elif len(argv) == 3 and argv[0] == 'ggm':
        ggm(argv[1], argv[2])
    elif len(argv) == 3 and argv[0] == 'pack':
        pack(argv[1], argv[2], log=lambda m: print(m, file=sys.stderr))
    else:
        sys.exit(__doc__.split('\n\n')[0] + '\n' + __doc__.split('\n\n')[1])
