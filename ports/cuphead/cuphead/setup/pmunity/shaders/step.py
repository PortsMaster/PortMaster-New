"""Conversion step `shaders`: GLES3 programs for every Shader in a game's data (convert.py).

Files searched: the serialized files (globalgamemanagers, level*, *.assets), Resources/
unity_builtin_extra, and asset bundles under StreamingAssets whose names match `bundles` (a
regular expression; bundles are opened only to look for shaders, and rewritten only when one
changes). The player's own "unity default resources" comes with the Android player and already
has GLES3 programs.

`sources` names the desktop platforms to translate, in order of preference: 'glcore' (OpenGL
Core, macOS / Linux builds; the default), 'd3d11' (Direct3D 11, Windows builds, with Unity's
HLSLcc: tools/hlslcc), 'vulkan' (Vulkan, Linux builds without OpenGL Core such as HDRP's, with
SPIRV-Cross: tools/spirvcross) and 'metal' (Metal, macOS builds without OpenGL Core: Unity 2020.3 and
later; metal.py). A shader is translated from the first one it has.

`glcore4x`: also translate the GLCore41 / GLCore43 programs (`#pragma target 4.5` and up) and
give shaders whose variants were all stripped an empty GLES3 blob (convert.add_gles3). On by
default, for data of every Unity version; config `"shaders": {"glcore4x": false}` (or `pmunity
convert --set shaders.glcore4x=false`) keeps a port on the output the converter wrote before
(Cuphead's port, which was checked on the device that way, sets it).

`compute`: ComputeShader assets with OpenGL Core kernels get a GLES3 variant, their kernels
translated to GLSL ES 3.10 (compute.py), so a game's own kernels run on the Android player as in
an Android build (OpenGL ES 3.1+). On by default; `"shaders": {"compute": false}` leaves them as
they are (FindKernel then fails on the device: "Kernel 'X' not found").

`grab_fetch` (off by default; it changes the picture slightly): shaders whose passes sample an
unnamed GrabPass's copy at the fragment's own screen position (blend modes) get a SubShader that
reads the framebuffer instead, without the GrabPass (grabfetch.py). true: Unity uses it where it
reports framebuffer fetch (6000.0: GL_EXT_shader_framebuffer_fetch), the original elsewhere;
"always": wherever its programs compile (GL_EXT_ or GL_ARM_shader_framebuffer_fetch: Mali's drivers
have ARM's), the original elsewhere (Unity 6000.0).
`grab_fetch_names`: a regex, only the shaders whose names match (default: every shader). Applied
to the GLES3 programs a shader has after the translation, also to ones it already had.

`fused_post` (config only, `shaders.fused_post`; none by default; the picture may differ by a
rounding step): chains of full-screen post-processing passes, each given one pass that draws the
whole chain, appended to the chain's last shader (fusedpost.py; Hollow Knight: the bloom composite,
colour curves and brightness, with asmpatch's hk-post and ASMPATCH_HK_POST=fused). A chain's
shaders must all be in one assets file; applied to their GLES3 programs after the translation.
"""
import os
import re
import shutil

from ..unity_io import Loaded, NotOneSerializedFile
from . import blob as B
from . import compute as CS
from . import convert as C
from . import dxbc
from . import fusedpost as FP
from . import grabfetch as GF
from . import metal as MT
from . import vulkan as VK

SOURCES = {'glcore': B.PLATFORM_GLCORE, 'd3d11': B.PLATFORM_D3D11, 'vulkan': B.PLATFORM_VULKAN, 'metal': B.PLATFORM_METAL}
SOURCE_NAMES = {'glcore': 'OpenGL Core', 'd3d11': 'Direct3D 11', 'vulkan': 'Vulkan', 'metal': 'Metal'}
# Shader.platforms values (Unity's ShaderCompilerPlatform) as names, for messages
PLATFORM_NAMES = {0: 'OpenGL (legacy)', 1: 'Direct3D 9', 4: 'Direct3D 11', 5: 'OpenGL ES 2', 8: 'Direct3D 11 9.x',
                  9: 'OpenGL ES 3', 14: 'Metal', 15: 'OpenGL Core', 18: 'Vulkan', 20: 'Direct3D 12 (Xbox)',
                  25: 'WebGPU'}
NO_SOURCE = ('no OpenGL Core programs', 'no Direct3D 11 programs', 'no Vulkan programs', 'no Metal programs')


def nothing_to_translate(results, sources):
    """The error for data whose shaders all lack the source platforms' programs (a Vulkan- or
    Metal-only build, HDRP), else None. Shaders already carrying GLES3 programs or none at all
    (stripped) do not count against it."""
    if not results or any(r.why not in NO_SOURCE for r in results):
        return None
    plats = sorted({p for r in results for p in getattr(r, 'platforms', ())})
    if not plats:                       # (no programs anywhere: nothing to say about the build)
        return None
    names = ', '.join(PLATFORM_NAMES.get(p, f'platform {p}') for p in plats)
    hint = ''
    if B.PLATFORM_VULKAN in plats and 'vulkan' not in sources:
        hint = ('. They have Vulkan programs: translate those with `"shaders": {"from": ["vulkan"]}` (or '
                '`--from vulkan`; tools/spirvcross/build.sh). HDRP does not run on OpenGL ES')
    elif B.PLATFORM_METAL in plats and 'metal' not in sources:
        hint = '. They have Metal programs: translate those with `"shaders": {"from": ["metal"]}` (or `--from metal`)'
    return (f'shaders: none of the {len(results)} shaders has {" or ".join(SOURCE_NAMES[s] for s in sources)} '
            f'programs (their programs: {names}), so the Android player would draw nothing{hint}. A build '
            f'made without OpenGL Core (Vulkan or Metal only: HDRP\'s Linux and macOS builds, recent macOS '
            f'builds) cannot be converted from it; another build of the game may have OpenGL Core or Direct3D 11 programs')


def bundle_version_fallback(job):
    """Asset bundles built with their Unity version stripped from the header (Addressables' option:
    Rhythm Quest's 46 bundles) do not open in UnityPy without a fallback version: the data's own,
    where UnityPy has none set."""
    import UnityPy
    from .. import unity_version as UV
    if getattr(UnityPy.config, 'FALLBACK_UNITY_VERSION', None):
        return
    try:
        UnityPy.config.FALLBACK_UNITY_VERSION = str(UV.of_data(job.src))
    except Exception:
        pass


def glcore4x_for(path, glcore4x=None):
    """Whether the GLCore41/43 programs of a serialized file or bundle are translated (None: yes)."""
    return True if glcore4x is None else bool(glcore4x)


def shader_files(job, bundles=r'.'):
    files = job.list('', lambda n: n.endswith('.assets') or n == 'globalgamemanagers' or re.match(r'level\d+$', n))
    files += job.list('Resources', lambda n: n == 'unity_builtin_extra')
    if bundles:
        rx = re.compile(bundles)
        for d, _, names in os.walk(os.path.join(job.src, 'StreamingAssets')):
            rel = os.path.relpath(d, job.src)
            files += sorted(os.path.join(rel, n) for n in names
                            if rx.search(n) and not n.endswith(('.manifest', '.meta')) and _is_bundle(os.path.join(d, n)))
    return files


def _is_bundle(path):
    try:
        with open(path, 'rb') as f:
            return f.read(8) == b'UnityFS\0'
    except OSError:
        return False


def grab_fetch_mode(value):
    """shaders.grab_fetch as False, True or 'always' (ValueError for anything else)."""
    if value in (None, False, 'off', 'false'):
        return False
    if value in (True, 'on', 'true'):
        return True
    if value == 'always':
        return 'always'
    raise ValueError(f'shaders.grab_fetch: {value!r} (false, true or "always")')


def run(job, precision='highp', replace=False, bundles=r'.', log_each=False, optimize=None, sources=('glcore',),
        hlslcc=None, glcore4x=None, compute=None, spirv_cross=None, grab_fetch=None, grab_fetch_names=None):
    """Returns the per-shader results. hlslcc: the pmhlslcc binary (default dxbc.find_hlslcc());
    spirv_cross: the pmspirvcross binary (default vulkan.find_spirv_cross()); glcore4x, compute,
    grab_fetch, grab_fetch_names: see the module docstring."""
    if glcore4x is None:
        glcore4x = (job.cfg.get('shaders') or {}).get('glcore4x')
    if glcore4x not in (None, True, False):
        raise ValueError(f'shaders.glcore4x: {glcore4x!r} (true or false)')
    if compute is None:
        compute = (job.cfg.get('shaders') or {}).get('compute', True)
    if compute not in (True, False):
        raise ValueError(f'shaders.compute: {compute!r} (true or false)')
    if grab_fetch is None:
        grab_fetch = (job.cfg.get('shaders') or {}).get('grab_fetch')
    grab_fetch = grab_fetch_mode(grab_fetch)
    if grab_fetch_names is None:
        grab_fetch_names = (job.cfg.get('shaders') or {}).get('grab_fetch_names')
    fused_post = FP.chains_of(job.cfg)
    fused_names = FP.chain_names(fused_post)
    gresults = []
    presults = []
    for src in sources:
        if src not in SOURCES:
            raise ValueError(f'unknown shader source {src!r} (known: {", ".join(SOURCES)})')
    bundle_version_fallback(job)
    results = []
    cresults = []
    changed_files = 0
    translator = None
    vk_translator = None
    opt = C.glsl.OPTIMIZE if optimize is None else optimize
    for rel in shader_files(job, bundles):
        if job.is_done('shaders', rel):
            continue
        work = job.work_dir('shaders')
        try:
            lf = Loaded(job.path_in(rel), spill_dir=work)          # (a big bundle: from its nodes)
        except NotOneSerializedFile as ex:
            job.log(f'shaders: {rel}: left as it is ({ex})')
            shutil.rmtree(work, ignore_errors=True)
            job.mark_done('shaders', rel)
            continue
        gl4 = glcore4x_for(job.path_in(rel), glcore4x)
        n = 0
        chain_trees = {}                 # the file's shaders a fused_post chain names: name -> (object, tree)
        for pid, o in lf.objects('Shader'):
            t = o.read_typetree()
            if t['m_ParsedForm']['m_Name'] in fused_names:
                chain_trees[t['m_ParsedForm']['m_Name']] = (o, t)
            src = next((s for s in sources if SOURCES[s] in t['platforms']), sources[0])
            if src == 'd3d11':
                if translator is None:
                    translator = dxbc.Translator(hlslcc)
                r = C.add_gles3_d3d11(t, translator, precision=precision, replace=replace, optimize=opt,
                                      unity=getattr(lf.sf, 'unity_version', None))
            elif src == 'metal':
                r = MT.add_gles3_metal(t, precision=precision, replace=replace, unity=getattr(lf.sf, 'unity_version', None))
            elif src == 'vulkan':
                if vk_translator is None:
                    vk_translator = VK.Translator(spirv_cross)
                r = VK.add_gles3_vulkan(t, vk_translator, precision=precision, replace=replace,
                                        unity=getattr(lf.sf, 'unity_version', None))
            else:
                r = C.add_gles3(t, precision=precision, replace=replace, optimize=opt, glcore4x=gl4)
                r.glcore4x = gl4
            r.file = rel
            r.platforms = tuple(t['platforms'])
            results.append(r)
            changed = r.status == 'converted' or r.changed
            if grab_fetch:
                g = GF.apply(t, grab_fetch, grab_fetch_names)
                g.file = rel
                gresults.append(g)
                changed |= g.changed
                if g.status != 'unchanged' or log_each:
                    job.log(f'shaders: {rel}: grab_fetch: {g}')
            if changed:
                o.save_typetree(t)
                n += 1
            if r.status == 'skipped' or r.failed or log_each:
                job.log(f'shaders: {rel}: {r}')
            if r.guessed_layout:
                job.log(f'shaders: {rel}: {r.name}: program layout of an unverified Unity version (guessed, checked by round trip)')
        for pid, o in (lf.objects('ComputeShader') if compute else ()):
            t = o.read_typetree()
            r = CS.add_gles3(t, unity=getattr(lf.sf, 'unity_version', None), precision=precision, replace=replace,
                             optimize=opt)
            r.file = rel
            cresults.append(r)
            if r.status == 'converted':
                o.save_typetree(t)
                n += 1
            if r.status == 'skipped' or r.failed or log_each:
                job.log(f'shaders: {rel}: compute shader {r}')
        for chain in fused_post:
            # a chain is fused in the file of its last shader (the one the fused pass is appended to)
            last = FP.chain_items(chain)[-1][0]
            if last not in chain_trees:
                continue
            fr = FP.apply({k: v[1] for k, v in chain_trees.items()}, chain, getattr(lf.sf, 'unity_version', None))
            fr.file = rel
            presults.append(fr)
            job.log(f'shaders: {rel}: fused_post: {fr}')
            if fr.changed:
                chain_trees[last][0].save_typetree(chain_trees[last][1])
                n += 1
        if n:
            lf.write_to(job, rel)
            changed_files += 1
        lf.close()
        shutil.rmtree(work, ignore_errors=True)
        try:
            os.rmdir(os.path.dirname(work))
        except OSError:
            pass
        job.mark_done('shaders', rel)
    if translator is not None:
        translator.close()
    if vk_translator is not None:
        vk_translator.close()
    err = nothing_to_translate(results, sources)
    if err:
        raise SystemExit(err)
    conv = [r for r in results if r.status == 'converted']
    job.log(f'shaders: {len(conv)} shaders given GLES3 programs ({sum(r.programs for r in conv)} programs, '
            f'{sum(r.twins for r in conv)} subprograms) in {changed_files} files; '
            f'{sum(r.status == "skipped" for r in results)} not translatable; precision {precision}; '
            f'rewrites: {sum(len(r.notes) for r in conv)} stages ({", ".join(sorted({n.split(" ", 1)[1].rsplit(" ", 1)[0] for r in conv for n in r.notes})) or "none"})')
    es31 = sum(getattr(r, 'es31', 0) for r in conv)
    if es31:
        job.log(f'shaders: {es31} programs need GLSL ES 3.10 (multisampled textures, texture gather, bit-field functions, '
                f'storage buffers, binding points, images): GLES 3.1 programs, used where the device has OpenGL ES 3.1+')
    gl4 = [r for r in results if r.source == 'glcore' and getattr(r, 'glcore4x', False)]
    if gl4:
        sub = [w for r in gl4 if r.source == 'glcore' for w in r.failed]
        job.log(f'shaders: GLCore41/43 programs translated too: {sum(r.programs4x for r in gl4 if r.status == "converted")} '
                f'programs; {len(sub)} SubShaders left out (no ES equivalent); '
                f'{sum(r.empty for r in gl4)} shaders without programs (stripped) given an empty GLES3 blob')
    elif any(r.source == 'glcore' for r in results):
        job.log('shaders: GLCore41/43 programs not translated (glcore4x off)')
    vr = sum(r.dropped for r in conv if r.source == 'glcore')
    if vr:
        job.log(f'shaders: {vr} VR-only OpenGL Core variants not translatable (left out, never used on a handheld)')
    if cresults:
        cc = [r for r in cresults if r.status == 'converted']
        job.log(f'shaders: {len(cc)} of {len(cresults)} compute shaders given GLES3 kernels ({sum(r.kernels for r in cc)} '
                f'kernels, {sum(r.variants for r in cc)} kernel variants, GLSL ES 3.10: used where the device has OpenGL ES '
                f'3.1+); {sum(len(r.failed) for r in cresults)} kernels left out; '
                f'{sum(r.why.startswith("no OpenGL Core") for r in cresults)} without OpenGL Core kernels')
    mt = [r for r in results if r.source == 'metal']
    if mt:
        job.log(f'shaders: from Metal: {sum(r.status == "converted" for r in mt)} of {len(mt)} shaders '
                f'({sum(r.programs for r in mt if r.status == "converted")} programs); '
                f'{sum(len(r.failed) for r in mt)} SubShaders left out; {sum(r.dropped for r in mt)} VR-only and '
                f'{sum(r.dropped_instancing for r in mt)} GPU instancing variants left out')
    vk = [r for r in results if r.source == 'vulkan']
    if vk:
        job.log(f'shaders: from Vulkan: {sum(r.status == "converted" for r in vk)} of {len(vk)} shaders '
                f'({sum(r.programs for r in vk if r.status == "converted")} programs); '
                f'{sum(len(r.failed) for r in vk)} SubShaders left out; {sum(r.dropped for r in vk)} VR-only and '
                f'{sum(r.dropped_instancing for r in vk)} GPU instancing variants left out')
    if grab_fetch:
        gc = [g for g in gresults if g.changed]
        job.log(f'shaders: grab_fetch ({"always" if grab_fetch == "always" else "where Unity reports framebuffer fetch"}): '
                f'{len(gc)} shaders read the framebuffer instead of a GrabPass copy ({sum(g.subshaders for g in gc)} '
                f'SubShaders, {sum(g.grabs for g in gc)} GrabPasses left out, {sum(g.programs for g in gc)} programs); '
                f'{sum(g.status == "skipped" for g in gresults)} shaders with GrabPasses left as they are')
    if fused_post:
        pc = [p for p in presults if p.changed]
        job.log(f'shaders: fused_post: {len(pc)} of {len(fused_post)} chains given one pass that draws them'
                + (' (' + '; '.join(f'"{p.shader}" pass {p.pass_index}' for p in pc) + ')' if pc else '')
                + (f'; left as they are: ' + '; '.join(f'"{p.shader}": {p.why}' for p in presults if not p.changed)
                   if any(not p.changed for p in presults) else '')
                + (f'; {len(fused_post) - len(presults)} chains whose last shader no file has' if len(presults) < len(fused_post) else ''))
    d3d = [r for r in results if r.source == 'd3d11']
    if d3d:
        job.log(f'shaders: from Direct3D 11: {sum(r.status == "converted" for r in d3d)} of {len(d3d)} shaders '
                f'({sum(r.programs for r in d3d if r.status == "converted")} programs); '
                f'{sum(len(r.failed) for r in d3d)} SubShaders left out; {sum(r.dropped for r in d3d)} VR-only variants, '
                f'{sum(r.dropped_instancing for r in d3d)} GPU instancing and {sum(r.dropped_skinning for r in d3d)} '
                f'GPU sprite skinning variants left out')
    return results
