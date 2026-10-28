"""pmunity: converts a Unity game's desktop (macOS / Linux, or Windows: --from d3d11) data for Unity's
Android player on GLES handhelds.

    python -m pmunity convert <data> [<out>] --config game.json [--steps a,b] [--plugin steps.py] [--only REGEX]
    python -m pmunity shaders <data> [<out>] [--precision highp|default-samplers] [--replace] [--bundles REGEX]
                              [--from glcore|d3d11|vulkan|metal|glcore,d3d11] [--hlslcc PATH] [--spirv-cross PATH]
                              [--grab-fetch off|on|always]
    python -m pmunity shaders-export <data> <dir> [--bundles REGEX]
    python -m pmunity android-data --src <converted data> --pkg <Unity Android player> [...]   (--help)
    python -m pmunity plugins <data> [--map F] [--json F]    (native plugins: what the port gives each)
    python -m pmunity macpkg <root> <installer.pkg>...       (unpack macOS installers, e.g. GOG's)
    python -m pmunity unpack <data> [--out DIR] [--remove]   (a compressed build's data.unity3d -> files)
    python -m pmunity version <data>                          (the Unity version the data was built with)
    python -m pmunity player fetch <version> <dir>            (Unity's Android player of that version, from Unity)
    python -m pmunity winbcl <data> <dir> [--player PKG]      (Unity's class libraries a build lacks for it: winbcl.py)
    python -m pmunity port check|new|package ...              (a PortMaster port of a game: docs/porting.md)
    python -m pmunity apk <apk|xapk|apks|aab|obb...> <out>     (a game's own Android build, ready for ua_host)
    python -m pmunity il2cpp <data> <out> [--abi arm64-v8a]   (the game's assemblies compiled with IL2CPP; docs/il2cpp.md)
    python -m pmunity prefs show|copy ...                      (PlayerPrefs between a PC's Unity player and the handheld)

The data's Unity version is read from the data (unity_version.py); versions outside 5.6 - 6000.6
are refused unless --any-unity-version is given.

<data> is the Unity data folder (<Game>_Data, or <Game>.app/Contents/Resources/Data). With <out>
the converted files go there and <data> is only read (an overlay: later steps read a file from
<out> once an earlier step wrote it); without it the conversion runs in place and can be resumed.

The config file (JSON) holds one section per step (shaders, textures, settings, audio, quality) with the
step's settings; see each module's DEFAULTS. A plugin is a Python file with STEPS = {name:
function(job)} for a game's own steps, run in the order --steps names them.
"""
import argparse
import importlib.util
import json
import sys

from .job import Job

BUILTIN_STEPS = ('shaders', 'textures', 'settings', 'audio')
# steps a config names to run them (not in the default list): `quality`, the handheld quality
# profile (quality.py, docs/quality.md)
OPTIONAL_STEPS = ('quality',)


def _builtin(name):
    def run(job, a):
        if name == 'shaders':
            from .shaders import step
            c = job.cfg.get('shaders', {})
            src = c.get('from', ['glcore'])
            return step.run(job, c.get('precision', 'highp'), c.get('replace', False), c.get('bundles', '.'),
                            optimize=tuple(c.get('optimize', ('const-arrays', 'unroll'))),
                            sources=tuple(src.split(',') if isinstance(src, str) else src), hlslcc=c.get('hlslcc'),
                            spirv_cross=c.get('spirv_cross'))
        if name == 'textures':
            from . import textures
            return textures.run(job, a.only)
        if name == 'settings':
            from . import settings
            return settings.run(job)
        if name == 'audio':
            from . import audio
            return audio.run(job)
        if name == 'quality':
            from . import quality
            return quality.run(job)
    return run


def _check_data(data, force):
    """Stops with the reason for data the converter does not handle: a Unity version outside the
    supported range, a compressed build (data.unity3d) not unpacked yet."""
    import os
    from . import unity_version as UV
    try:
        if not os.path.isfile(os.path.join(data, 'globalgamemanagers')) and os.path.isfile(os.path.join(data, 'data.unity3d')):
            raise UV.Unsupported(f'{data}: a compressed build (data.unity3d): unpack it first with '
                                 f'`python -m pmunity unpack {data}`')
        v = UV.check(UV.of_data(data), force)
    except UV.Unsupported as ex:
        sys.exit(str(ex))
    print(f'data: Unity {v}', flush=True)
    return v


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if argv[:1] == ['android-data']:
        from . import android_data
        return android_data.main(argv[1:])
    if argv[:1] == ['plugins']:
        from . import plugins
        return plugins.main(argv[1:])
    if argv[:1] == ['macpkg']:
        from . import macpkg
        return macpkg.main(argv[1:])
    if argv[:1] == ['unpack']:
        from . import unpack
        return unpack.main(argv[1:])
    if argv[:1] == ['prefs']:
        from . import prefs
        return prefs.main(argv[1:])
    if argv[:1] == ['apk']:
        from . import apk
        return apk.main(argv[1:])
    if argv[:1] == ['patch-obb']:      # an add-on's bundles beside an installed game (patch_obb.py)
        from . import patch_obb
        return patch_obb.main(argv[1:])
    if argv[:1] == ['astc-guide']:     # per-block encoder effort chosen on a PC (astc_guide.py)
        from . import astc_guide
        return astc_guide.main(argv[1:])
    if argv[:1] == ['player']:
        from . import player
        return player.main(argv[1:])
    if argv[:1] == ['winbcl']:          # Windows 2021.2+ class libraries, missing facades (winbcl.py)
        from . import winbcl
        return sys.exit(winbcl.main(argv[1:]))
    if argv[:1] == ['route']: from . import route; return route.main(argv[1:])  # noqa: E701,E702 (docs/box64-route.md)
    if argv[:1] == ['port']:            # port check / new / package (port.py, docs/porting.md)
        from . import port
        return sys.exit(port.main(argv[1:]))
    if argv[:1] == ['il2cpp']:
        from . import il2cpp
        return il2cpp.main(argv[1:])
    if argv[:1] == ['version']:
        from . import unity_version as UV
        v = UV.of_data(argv[1])
        print(f'{v} ({"supported" if UV.FIRST <= v.line <= UV.LAST else "not supported"})')
        return
    ap = argparse.ArgumentParser(prog='pmunity')
    sub = ap.add_subparsers(dest='cmd', required=True)
    c = sub.add_parser('convert', help='run conversion steps with a game config')
    c.add_argument('data'); c.add_argument('out', nargs='?')
    c.add_argument('--config', required=True)
    c.add_argument('--steps', default=None, help='comma-separated (default: the config\'s "steps", else ' + ','.join(BUILTIN_STEPS) + ')')
    c.add_argument('--plugin', action='append', default=[], help="a Python file with STEPS = {name: function(job)}")
    c.add_argument('--only', help='regex: only convert matching files (tests)')
    c.add_argument('--set', action='append', default=[], metavar='SECTION.KEY=VALUE',
                   help='override a config value (VALUE as JSON, else a string), e.g. --set shaders.precision=highp')
    s = sub.add_parser('shaders', help='GLES3 programs from the OpenGL Core (--from d3d11: Direct3D 11) ones')
    s.add_argument('data'); s.add_argument('out', nargs='?')
    s.add_argument('--precision', default='highp', choices=['highp', 'default-samplers'])
    s.add_argument('--replace', action='store_true', help='rebuild GLES programs a shader already has')
    s.add_argument('--bundles', default='.', help='regex: asset bundles to search for shaders')
    s.add_argument('--log-each', action='store_true')
    s.add_argument('--optimize', default='const-arrays,unroll',
                   help="exact rewrites, comma-separated ('' = none): const-arrays, unroll")
    s.add_argument('--from', dest='sources', default='glcore',
                   help='desktop programs to translate, in order of preference: glcore (macOS/Linux builds), '
                        'd3d11 (Windows builds, needs tools/hlslcc), vulkan (Vulkan-only Linux builds, needs '
                        'tools/spirvcross), metal (Metal-only macOS builds), e.g. glcore,d3d11')
    s.add_argument('--hlslcc', help='the pmhlslcc binary (default: $PMHLSLCC, tools/hlslcc/out/pmhlslcc, PATH)')
    s.add_argument('--spirv-cross', help='the pmspirvcross binary (default: $PMSPIRVCROSS, '
                                         'tools/spirvcross/out/pmspirvcross, PATH)')
    s.add_argument('--grab-fetch', choices=['off', 'on', 'always'], default='off',
                   help='blend-mode passes read the framebuffer instead of an unnamed GrabPass copy (changes the '
                        'picture slightly): on = where Unity reports framebuffer fetch, always = wherever the '
                        'programs compile (docs/shaders.md)')
    s.add_argument('--grab-fetch-names', help='regex: only these shaders (with --grab-fetch)')
    for p in (c, s):
        p.add_argument('--any-unity-version', action='store_true',
                       help='convert data of a Unity version outside 5.6 - 6000.6 (untested; layouts guessed)')
    e = sub.add_parser('shaders-export', help='GLES3 programs as .vert/.frag files (compile checks)')
    e.add_argument('data'); e.add_argument('dir')
    e.add_argument('--bundles', default='.')
    sub.add_parser('android-data', help='package converted data for the Android player (see android-data --help)')
    a = ap.parse_args(argv)
    if a.cmd in ('convert', 'shaders'):
        _check_data(a.data, a.any_unity_version)
    if a.cmd == 'convert':
        cfg = json.load(open(a.config))
        cfg.setdefault('version', 1)
        for kv in a.set:
            k, _, v = kv.partition('=')
            sec, _, key = k.partition('.')
            try:
                v = json.loads(v)
            except ValueError:
                pass
            cfg.setdefault(sec, {})[key] = v
        steps = {n: _builtin(n) for n in BUILTIN_STEPS + OPTIONAL_STEPS}
        for i, p in enumerate(a.plugin):
            spec = importlib.util.spec_from_file_location(f'pmunity_plugin_{i}', p)
            mod = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(mod)
            for n, f in mod.STEPS.items():
                steps[n] = (lambda f: lambda job, a: f(job))(f)
        order = a.steps.split(',') if a.steps else cfg.get('steps', list(BUILTIN_STEPS))
        job = Job(a.data, a.out or a.data, cfg)
        for n in order:
            if n not in steps:
                sys.exit(f'unknown step {n}; steps: {", ".join(steps)}')
            job.log(f'== {n}')
            steps[n](job, a)
        job.log('done')
        return
    cfg = {'version': 1}
    if a.cmd == 'shaders':
        from .shaders import step
        job = Job(a.data, a.out or a.data, cfg)
        step.run(job, a.precision, a.replace, a.bundles, a.log_each, tuple(x for x in a.optimize.split(',') if x),
                 sources=tuple(x for x in a.sources.split(',') if x), hlslcc=a.hlslcc, spirv_cross=a.spirv_cross,
                 grab_fetch=step.grab_fetch_mode(a.grab_fetch), grab_fetch_names=a.grab_fetch_names)
    elif a.cmd == 'shaders-export':
        from .shaders import export
        export.export(Job.reader(a.data, cfg), a.dir, a.bundles)


if __name__ == '__main__':
    main()
