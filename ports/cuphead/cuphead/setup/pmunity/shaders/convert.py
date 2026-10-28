"""GLES3 programs for Shader assets that only carry OpenGL Core (and Metal / Vulkan) programs.

Unity's Android player renders with GLES3 and only runs GPU programs of the GLES types. A game
built for macOS or Linux has OpenGL Core programs (GLSL 1.50) instead, which are close to GLSL ES
3.00 (glsl.py). For every Shader:

  1. the GLCore platform blob is copied as a GLES3Plus blob (platform 9, the one Unity's GLES3
     renderer reads), each entry used by a GLCore subprogram translated to GLSL ES 3.00 and
     retyped GLES3 (gpu program type 4), or to 3.10 and typed GLES 3.1 (3) where it needs that;
     entries nothing uses that way (and, from Unity 2021.2, the parameter entries) are copied
     unchanged so the blob indices stay the same;
  2. every GLCore subprogram in the parsed form gets a GLES3 twin: a copy with
     m_GpuProgramType 4 (or 3) and the same m_BlobIndex (2021.2+: the same parameter entry too).
     Parameters, bindings, keywords and channels are the GLCore ones, which the GL and GLES
     backends read the same way (both bind by name). This is what Unity's own builds hold: in
     the built-in resources of every LTS line 2017.4 - 2022.3, which carry both platforms, each
     GLES3 subprogram equals the GLCore one of the same variant but for the type, and the two
     blobs differ only in the code and type of the code entries;
  3. Unity 2020.1+: each pass with twins lists the GLES3 platform in m_Platforms; 2021.2+: the
     Shader's stageCounts gets the GLES3 platform's (as GLCore's, 1).

Where the subprograms are: up to Unity 2021.1 in each program's m_SubPrograms (a hardware tier
field each); from 2021.2 in m_PlayerSubPrograms, a list per hardware tier (desktop builds use the
last, tier-independent one) with the parallel m_ParameterBlobIndices (subprogram_lists()).

GLCore subprograms are GLCore32 (GLSL 1.50 / 3.30) or, for `#pragma target 4.5` and up, GLCore41
and GLCore43 (GLSL 4.x; glsl.py): every variant has one GLCore program, of the type of its
target. GLCore41/43 ones are translated too (glcore4x=True; step.py: Unity 2018.1+ data), into
GLES3 programs where the GLSL fits ES 3.00 and GLES 3.1 ones where it needs ES 3.10, so a shader
whose SubShaders are compiled for different targets gets programs for each, as an Android build
has them (Unity runs the first SubShader the device supports). A shader with a GLCore32 program
that cannot be translated (glsl.Unsupported) gets no GLES3 programs at all, so Unity does not mix
translated and missing variants; a SubShader with a GLCore41/43 program that cannot be
translated gets none for its GLCore41/43 variants (Unity uses the next SubShader). The report
names both. A shader whose variants were all stripped from the build (a GLCore blob without
entries) gets an empty GLES3 blob, as Unity's builds have.

A Windows build has Direct3D 11 programs instead (add_gles3_d3d11, dxbc.py): one blob entry per
stage, translated a variant (vertex + pixel shader) at a time with Unity's HLSLcc.
"""
import copy

from . import blob as B
from . import dxbc
from . import glsl

STAGES = ('progVertex', 'progFragment', 'progGeometry', 'progHull', 'progDomain')
GLES_TYPES = (B.GPU_GLES31AEP, B.GPU_GLES31, B.GPU_GLES3, B.GPU_GLES)
GLCORE4X = (B.GPU_GLCORE41, B.GPU_GLCORE43)    # GLSL 4.x programs (`#pragma target 4.5` and up)
# the GPU program types whose code and parameter entries are in a platform's blob
PLATFORM_TYPES = {
    B.PLATFORM_GLCORE: (B.GPU_GLCORE32, B.GPU_GLCORE41, B.GPU_GLCORE43),
    B.PLATFORM_GLES3PLUS: (B.GPU_GLES31AEP, B.GPU_GLES31, B.GPU_GLES3),
    B.PLATFORM_GLES20: (B.GPU_GLES,),
    B.PLATFORM_D3D11: tuple(range(15, 23)),
}


def subprogram_lists(tree):
    """Every list of subprograms of the shader: (pass, stage name, list, parameter blob indices).
    Up to 2021.1 a program's m_SubPrograms (parameter indices None); from 2021.2 each hardware
    tier's m_PlayerSubPrograms list and the m_ParameterBlobIndices list parallel to it."""
    for ss in tree['m_ParsedForm']['m_SubShaders']:
        for p in ss['m_Passes']:
            for st in STAGES:
                prog = p.get(st)
                if not prog:
                    continue
                if prog.get('m_SubPrograms') is not None:
                    yield p, st, prog['m_SubPrograms'], None
                players = prog.get('m_PlayerSubPrograms')
                if players:
                    pbi = prog['m_ParameterBlobIndices']
                    for tier, lst in enumerate(players):
                        yield p, st, lst, pbi[tier]


def subprograms(tree):
    """Every list of subprograms of the shader: (pass, stage name, list)."""
    for p, st, lst, _ in subprogram_lists(tree):
        yield p, st, lst


def param_indices(tree, platform):
    """The blob indices of a platform's parameter entries (2021.2+; empty before)."""
    types = PLATFORM_TYPES.get(platform, ())
    return {pi[i] for _, _, lst, pi in subprogram_lists(tree) if pi is not None
            for i, sp in enumerate(lst) if sp['m_GpuProgramType'] in types}


def program_indices(tree, platform):
    """The blob indices of a platform's program entries (named by its subprograms' m_BlobIndex)."""
    types = PLATFORM_TYPES.get(platform, ())
    return {sp['m_BlobIndex'] for _, _, lst in subprograms(tree) for sp in lst if sp['m_GpuProgramType'] in types}


def platform_entries(tree, platform, blobs=None):
    """A platform's blob entries of a Shader typetree: Entry (programs), ParamEntry (2021.2+
    parameters), RawEntry (what no subprogram names and does not parse as a program) or None."""
    return (blobs or B.ShaderBlobs(tree)).entries(platform, param_indices(tree, platform), program_indices(tree, platform))


def add_platform(p, platform):
    """Lists a shader platform in a pass's m_Platforms (Unity 2020.1+), in ascending order."""
    plats = p.get('m_Platforms')
    if isinstance(plats, list) and platform not in plats:
        plats.append(platform)
        plats.sort()


class Result:
    def __init__(self, name):
        self.name = name
        self.status = 'unchanged'       # converted | unchanged | skipped (converted: the tree changed)
        self.changed = False            # skipped, but older GLES programs were removed (save the tree)
        self.why = ''
        self.programs = 0               # translated blob entries
        self.twins = 0                  # GLES3 subprograms added
        self.guessed_layout = False
        self.notes = []                 # rewrites applied (glsl.OPTIMIZE)
        self.source = 'glcore'          # the platform translated: glcore | d3d11
        self.dropped = 0                # VR-only variants left out (not translatable)
        self.dropped_instancing = 0     # D3D11: GPU instancing variants left out (not translatable)
        self.dropped_skinning = 0       # D3D11: GPU sprite skinning variants left out (not translatable)
        self.es31 = 0                   # programs that need GLSL ES 3.10 (GLES 3.1 programs, type 3)
        self.programs4x = 0             # of the translated entries: GLCore41/43 ones
        self.empty = False              # no programs at all: given an empty GLES3 blob
        self.failed = []                # (subshader, why) of SubShaders left without GLES3 programs (D3D11;
                                        # GLCore: their GLCore41/43 variants)

    def __repr__(self):
        return f'{self.name}: {self.status} {self.why}'.rstrip()


_ES = {}            # (code, precision, optimize, es) -> (GLSL ES or the Unsupported raised, the notes added)


def program_to_es_once(code, precision, optimize, notes, es='300'):
    """glsl.program_to_es of a program's bytes, each distinct program translated once (Unity repeats
    the same program across variants and shaders: half of Cuphead's 3038). The notes it adds, and
    the Unsupported it raises, come again on every use, as from a fresh translation."""
    key = (bytes(code), precision, tuple(optimize), es)
    hit = _ES.get(key)
    if hit is None:
        added = []
        try:
            res = glsl.program_to_es(code.decode('utf-8'), precision, optimize, added, es=es).encode('utf-8')
        except glsl.Unsupported as ex:
            res = ex
        hit = _ES[key] = (res, added)
    res, added = hit
    notes.extend(added)
    if isinstance(res, Exception):
        raise res
    return res


def add_gles3(tree, precision='highp', replace=False, translate=None, optimize=glsl.OPTIMIZE, glcore4x=True):
    """Adds GLES3 programs to one Shader typetree in place. Returns a Result.
    replace: a shader that already has GLES programs gets them rebuilt from its GLCore ones
    (otherwise it is left alone). translate: function(code bytes) -> code bytes, default glsl.program_to_es with
    `precision` and the `optimize` rewrites. glcore4x: also translate GLCore41 / GLCore43 programs,
    and give a shader with no GLCore programs at all (every variant stripped) an empty GLES3 blob
    (False: GLCore32 programs only, the converter's behaviour before; a port's config can keep it).

    GLCore32 programs: a non-VR one that does not translate leaves the whole shader without GLES3
    programs (Unity then does not mix translated and missing variants). GLCore41/43 programs are
    taken a SubShader at a time: if a non-VR one does not translate, none of that SubShader's
    GLCore41/43 variants get twins (Result.failed) and Unity uses the next SubShader or the
    Fallback, as for a SubShader an Android build has no programs for; the shader keeps the rest."""
    name = tree['m_ParsedForm']['m_Name']
    r = Result(name)
    plats = list(tree['platforms'])
    if B.PLATFORM_GLCORE not in plats:
        r.why = 'no OpenGL Core programs'
        return r
    if B.PLATFORM_GLES3PLUS in plats:
        if not replace:
            r.why = 'already has GLES3 programs'
            return r
        _strip_gles(tree)          # rebuilt below, or (no translatable programs) left without any
        r.status, r.why = 'converted', '(old GLES programs removed)'
    blobs = B.ShaderBlobs(tree)
    entries = platform_entries(tree, B.PLATFORM_GLCORE, blobs)
    used = sorted({sp['m_BlobIndex'] for _, _, lst in subprograms(tree) for sp in lst
                   if sp['m_GpuProgramType'] == B.GPU_GLCORE32})
    # GLCore41/43 programs per SubShader (the SubShader of each pass: sub_of)
    sub_of, used4 = {}, {}
    for si, ss in enumerate(tree['m_ParsedForm']['m_SubShaders']):
        for p in ss['m_Passes']:
            sub_of[id(p)] = si
    if glcore4x:
        for p, _, lst in subprograms(tree):
            for sp in lst:
                if sp['m_GpuProgramType'] in GLCORE4X:
                    used4.setdefault(sub_of[id(p)], set()).add(sp['m_BlobIndex'])
    if not used and not used4:
        if glcore4x:
            # no GLCore program at all (every variant stripped): an empty GLES3 blob, as Unity's own
            # builds have a blob for each of their platforms
            stages = blobs.stage_counts.get(B.PLATFORM_GLCORE) if blobs.stage_counts else None
            blobs.set_entries(B.PLATFORM_GLES3PLUS, [e.copy() if e is not None else None for e in entries],
                              blobs.segments(B.PLATFORM_GLCORE), stages)
            blobs.store()
            r.status, r.empty = 'converted', True
            r.why = ('no programs (every variant stripped): an empty GLES3 blob ' + r.why).strip()
            return r
        r.why = ('no GLCore32 programs ' + r.why).strip()
        return r
    both = set(used) & {i for s in used4.values() for i in s}
    if both:
        raise ValueError(f'{name}: blob entry {min(both)} is both a GLCore32 and a GLCore41/43 program')
    tr = translate or (lambda code: program_to_es_once(code, precision, optimize, r.notes))
    tr31 = None if translate else (lambda code: program_to_es_once(code, precision, optimize, r.notes, es='310'))
    out = [e.copy() if e is not None else None for e in entries]
    dropped = set()                     # VR-only programs that do not translate: no twins
    es31 = set()                        # programs translated as GLES 3.1 ones

    def translate_entry(i):
        """None (translated in out[i], or no code), 'vr' (VR-only, left out) or the Unsupported."""
        e = out[i]
        if e is None:
            return None
        if not isinstance(e, B.Entry):
            raise ValueError(f'{name}: blob entry {i} is both a program and parameters')
        r.guessed_layout |= e.guessed
        if e.code:
            try:
                try:
                    e.code = tr(e.code)
                except glsl.NeedsES31:
                    if tr31 is None:
                        raise
                    e.code = tr31(e.code)
                    es31.add(i)
            except glsl.Unsupported as ex:
                out[i] = entries[i].copy()
                if any(k in VR_KEYWORDS for k in e.keywords + (e.local_keywords or [])):
                    dropped.add(i)      # e.g. STEREO_INSTANCING_ON writes gl_Layer (not in ES 3.00)
                    r.dropped += 1
                    return 'vr'
                return ex
            r.programs += 1
        e.gpu_type = B.GPU_GLES3
        return None

    for i in used:
        ex = translate_entry(i)
        if isinstance(ex, Exception):
            r.status, r.why = 'skipped', f'program {i}: {ex}'
            r.changed = bool(replace and B.PLATFORM_GLES3PLUS in plats)
            return r
    done4 = {}                          # GLCore41/43 entry -> None (translated, or no code) | 'vr' | Unsupported
    counted = set()                     # of those, the entries whose code was translated (r.programs)
    failed4 = set()                     # SubShaders whose GLCore41/43 variants get no twins
    for si in sorted(used4):
        for i in sorted(used4[si]):
            if i not in done4:
                n = r.programs
                done4[i] = translate_entry(i)
                if r.programs > n:
                    counted.add(i)
            if isinstance(done4[i], Exception):
                failed4.add(si)
                r.failed.append((si, f'GLCore41/43 program {i}: {done4[i]}'))
                break
    # what only the failed SubShaders use goes back as it was (no GLES subprogram names it)
    keep = set().union(*(s for si, s in used4.items() if si not in failed4))
    for i in set(done4) - keep:
        out[i] = entries[i].copy() if entries[i] is not None else None
        es31.discard(i)
        if i in counted:
            r.programs -= 1
    r.programs4x = len(counted & keep)

    def twinned(p, sp):
        t = sp['m_GpuProgramType']
        return t == B.GPU_GLCORE32 or t in GLCORE4X and glcore4x and sub_of[id(p)] not in failed4

    # the variants (per pass) whose program was left out: none of their subprograms get a twin;
    # those made GLES 3.1 programs: all their subprograms (and entries) are typed GLES 3.1
    skip = {(id(p), _variant_key(sp), sp['m_GpuProgramType']) for p, _, lst in subprograms(tree) for sp in lst
            if twinned(p, sp) and sp['m_BlobIndex'] in dropped}
    raised = {(id(p), _variant_key(sp), sp['m_GpuProgramType']) for p, _, lst in subprograms(tree) for sp in lst
              if twinned(p, sp) and sp['m_BlobIndex'] in es31}
    for p, _, lst in subprograms(tree):
        for sp in lst:
            if twinned(p, sp) and (id(p), _variant_key(sp), sp['m_GpuProgramType']) in raised:
                if out[sp['m_BlobIndex']] is not None:
                    out[sp['m_BlobIndex']].gpu_type = B.GPU_GLES31
    r.es31 = len(es31)
    # commit: the blob, then the twins
    stages = blobs.stage_counts.get(B.PLATFORM_GLCORE) if blobs.stage_counts else None
    twins_of = []
    for p, _, lst, pbi in subprogram_lists(tree):
        twins = []
        for i, sp in enumerate(lst):
            k = (id(p), _variant_key(sp), sp['m_GpuProgramType'])
            if twinned(p, sp) and k not in skip:
                t = copy.deepcopy(sp)
                t['m_GpuProgramType'] = B.GPU_GLES31 if k in raised else B.GPU_GLES3
                twins.append((t, None if pbi is None else pbi[i]))
        twins_of.append((p, lst, pbi, twins))
    if failed4 and not any(tw for _, _, _, tw in twins_of):
        r.status, r.why = 'skipped', '; '.join(f'SubShader {si}: {w}' for si, w in r.failed)
        r.changed = bool(replace and B.PLATFORM_GLES3PLUS in plats)
        return r
    blobs.set_entries(B.PLATFORM_GLES3PLUS, out, blobs.segments(B.PLATFORM_GLCORE), stages)
    blobs.store()
    for p, lst, pbi, twins in twins_of:
        for t, pi in twins:
            lst.append(t)
            if pbi is not None:
                pbi.append(pi)
        if twins:
            add_platform(p, B.PLATFORM_GLES3PLUS)
        r.twins += len(twins)
    r.status = 'converted'
    if r.failed:
        r.why = (r.why + ' ' if r.why else '') + '; '.join(f'SubShader {si} left out: {w}' for si, w in r.failed)
    return r


def _strip_gles(tree):
    """Removes a shader's GLES3Plus blob and every GLES subprogram (tree edited in place)."""
    blobs = B.ShaderBlobs(tree)
    blobs.remove(B.PLATFORM_GLES3PLUS)
    blobs.store()
    for p, _, lst, pbi in subprogram_lists(tree):
        keep = [i for i, sp in enumerate(lst) if sp['m_GpuProgramType'] not in GLES_TYPES]
        if pbi is not None:
            pbi[:] = [pbi[i] for i in keep]
        lst[:] = [lst[i] for i in keep]
        plats = p.get('m_Platforms')
        if isinstance(plats, list) and B.PLATFORM_GLES3PLUS in plats:
            plats.remove(B.PLATFORM_GLES3PLUS)


def gles3_programs(tree):
    """[(blob index, code str)] of the shader's GLES3 programs referenced by GLES3 subprograms."""
    if B.PLATFORM_GLES3PLUS not in tree['platforms']:
        return []
    entries = platform_entries(tree, B.PLATFORM_GLES3PLUS)
    idx = sorted({sp['m_BlobIndex'] for _, _, lst in subprograms(tree) for sp in lst
                  if sp['m_GpuProgramType'] in (B.GPU_GLES3, B.GPU_GLES31)})
    return [(i, entries[i].code.decode('utf-8')) for i in idx if entries[i] is not None and entries[i].code]


# ---------------------------------------------------------------- Direct3D 11 (Windows builds)

# variants only VR rendering asks for (stereo instancing writes gl_Layer, which ES 3.00 lacks):
# one of these that cannot be translated is left out; Unity never enables them on a handheld.
# Unity's own keywords, and the Post-processing Stack v2's (its Uber, FinalPass and other shaders
# have STEREO_INSTANCING_ENABLED variants that write gl_Layer: without them counted here the whole
# shader got no GLES3 programs, and its final pass drew nothing, a black picture)
VR_KEYWORDS = ('STEREO_INSTANCING_ON', 'STEREO_MULTIVIEW_ON', 'UNITY_SINGLE_PASS_STEREO', 'STEREO_CUBEMAP_RENDER_ON',
               'STEREO_INSTANCING_ENABLED', 'STEREO_DOUBLEWIDE_TARGET')
# variants only GPU instancing draws use (instance data in arrays of structs, procedural instancing's
# structured buffers): one of these that cannot be translated from Direct3D 11 is left out, and the
# pass's instancing flags (2021.2+) are cleared, so the player draws such objects one by one
INSTANCING_KEYWORDS = ('INSTANCING_ON', 'PROCEDURAL_INSTANCING_ON', 'DOTS_INSTANCING_ON')
# variants only GPU sprite skinning uses (URP 2D of Unity 2023+: the 2D Animation package's bone
# matrices in a StructuredBuffer, _SpriteBoneTransforms): one of these that cannot be translated is
# left out, as a build strips a variant nothing asks for; otherwise URP's Sprite-Lit-Default and
# Sprite-Unlit-Default got no GLES3 programs at all and every sprite drew with the error shader
SKINNING_KEYWORDS = ('SKINNED_SPRITE',)
# SerializedSubProgram fields a GL subprogram leaves empty (its backend finds everything by name)
_D3D_ONLY_LISTS = ('m_VectorParams', 'm_MatrixParams', 'm_TextureParams', 'm_BufferParams', 'm_ConstantBuffers',
                   'm_ConstantBufferBindings', 'm_UAVParams', 'm_Samplers')
_OTHER_STAGES = ('progGeometry', 'progHull', 'progDomain')


def _variant_key(sp):
    """Keywords (2019.1 - 2021.1: global and local) and hardware tier of a subprogram."""
    kws = tuple(tuple(sorted(sp[k])) for k in ('m_KeywordIndices', 'm_GlobalKeywordIndices', 'm_LocalKeywordIndices') if k in sp)
    return kws, sp.get('m_ShaderHardwareTier')


def gl_twin(sp, blob_index, gl_params=None, names=None, gpu_type=B.GPU_GLES3):
    """The GLES3 subprogram of a D3D11 one, as Unity's own GLES3 subprograms of the same shaders
    are (identical but for the type, blob index and parameters): up to 2018 no parameters,
    bindings or vertex channels (the GL backends find uniforms, textures and inputs by name), only
    the source map, keywords, tier and requirements; 2019.x the vertex subprogram lists the GL
    program's binding info (gl_params: dxbc.Bindings; names: the pass's {name: index}); 2020.1+
    the lists stay empty (m_Parameters), the entry has it all. gpu_type: GLES3, or GLES31 for a
    program that needs GLSL ES 3.10."""
    t = copy.deepcopy(sp)
    t['m_GpuProgramType'] = gpu_type
    t['m_BlobIndex'] = blob_index
    for k in _D3D_ONLY_LISTS:
        if isinstance(t.get(k), list):
            t[k] = []
    if isinstance(t.get('m_Parameters'), dict):
        for k, v in t['m_Parameters'].items():
            if isinstance(v, list):
                t['m_Parameters'][k] = []
    ch = t.get('m_Channels')
    if isinstance(ch, dict) and isinstance(ch.get('m_Channels'), list):
        ch['m_Channels'] = []
    if gl_params is not None and isinstance(t.get('m_ConstantBuffers'), list):
        _fill_parsed_form(t, gl_params, names)
    return t


def _fill_parsed_form(t, b, names):
    """A 2019.x subprogram's parameter lists from a GL binding info (as Unity's GLES3 ones)."""
    nid = lambda n: names[n]
    for cb in b.cbuffers:
        vec = [{'m_NameIndex': nid(p.name), 'm_Index': p.offset, 'm_ArraySize': p.array, 'm_Type': p.type,
                'm_Dim': p.cols} for p in cb.params if not p.is_matrix]
        mat = [{'m_NameIndex': nid(p.name), 'm_Index': p.offset, 'm_ArraySize': p.array, 'm_Type': p.type,
                'm_RowCount': p.rows} for p in cb.params if p.is_matrix]
        if not cb.name:
            t['m_VectorParams'] += vec
            t['m_MatrixParams'] += mat
            continue
        t['m_ConstantBuffers'].append({'m_NameIndex': nid(cb.name), 'm_MatrixParams': mat, 'm_VectorParams': vec,
                                       'm_StructParams': [], 'm_Size': cb.size})
    for x in b.bindings:
        if x.kind == dxbc.Binding.KIND_TEXTURE:
            t['m_TextureParams'].append({'m_NameIndex': nid(x.name), 'm_Index': x.index, 'm_SamplerIndex': x.sampler,
                                         'm_MultiSampled': bool(x.extra[1] & 1), 'm_Dim': x.dim})
        elif x.kind == dxbc.Binding.KIND_CBUFFER:
            t['m_ConstantBufferBindings'].append({'m_NameIndex': nid(x.name), 'm_Index': x.index})


_KEY_FIELDS = (('m_KeywordIndices', 'k'), ('m_GlobalKeywordIndices', 'g'), ('m_LocalKeywordIndices', 'l'))


def _keyset(sp):
    """A subprogram's keywords as one set of (list, index) (2019.1 - 2021.1: global and local lists)."""
    return frozenset((tag, i) for f, tag in _KEY_FIELDS for i in sp.get(f) or ())


def _variant_pairs(vss, pss):
    """The (vertex sp, its parameter index, pixel sp, its parameter index, keywords) of every variant
    of a pass's tier list: Unity runs, for the keywords K enabled, the vertex subprogram of K's
    keywords its stage uses and the pixel one likewise (from Unity 2019 each stage's variants leave
    out keywords it does not use, so one vertex program may go with several pixel ones and the other
    way round). A pair belongs together when each side has the other's keywords that its stage uses
    (a stage uses the keywords any of its subprograms has); the GL program's keywords are both
    sides'. A vertex subprogram with no pixel one gives (vsp, vpi, None, None, its keywords)."""
    vuse = set().union(*(_keyset(sp) for sp, _ in vss)) if vss else set()
    puse = set().union(*(_keyset(sp) for sp, _ in pss)) if pss else set()
    for vsp, vpi in vss:
        a, tier, found = _keyset(vsp), vsp.get('m_ShaderHardwareTier'), False
        for psp, ppi in pss:
            b = _keyset(psp)
            if psp.get('m_ShaderHardwareTier') == tier and (b & vuse) <= a and (a & puse) <= b:
                found = True
                yield vsp, vpi, psp, ppi, a | b
        if not found:
            yield vsp, vpi, None, None, a


def _set_keywords(t, keys):
    """A twin's keyword index lists from a keyword set (_keyset)."""
    for f, tag in _KEY_FIELDS:
        if f in t:
            t[f] = sorted(i for g, i in keys if g == tag)


def _entry_keywords(ve, pe):
    """(keywords, local keywords or None) of a GL program made of two D3D11 entries: the vertex
    entry's, then the pixel entry's it lacks."""
    def merged(a, b):
        return list(a) + [k for k in b if k not in a]
    vk = list(ve.keywords) if isinstance(ve, B.Entry) else []
    vl = ve.local_keywords if isinstance(ve, B.Entry) else None
    if isinstance(pe, B.Entry):
        vk = merged(vk, pe.keywords)
        if vl is not None and pe.local_keywords is not None:
            vl = merged(vl, pe.local_keywords)
    return vk, (list(vl) if vl is not None else None)


def _name_indices(p, needed):
    """The pass's {name: index}, with names it lacks added (new indices after the last)."""
    pairs = p.setdefault('m_NameIndices', [])
    have = {n: i for n, i in pairs}
    nxt = max(have.values(), default=-1) + 1
    for n in needed:
        if n not in have:
            pairs.append((n, nxt))
            have[n] = nxt
            nxt += 1
    return have


def unity_of(tree, version=None):
    """(major, minor) of the data: from its version string, else from the Shader's layout."""
    if version:
        try:
            a, b = version.split('.')[:2]
            return int(a), int(b)
        except ValueError:
            pass
    sub = tree['m_ParsedForm']['m_SubShaders']
    progs = [p.get(st) for ss in sub for p in ss['m_Passes'] for st in STAGES if p.get(st)]
    if any(pr.get('m_PlayerSubPrograms') for pr in progs):
        return (2022, 1) if any('m_SerializedKeywordStateMask' in p for ss in sub for p in ss['m_Passes']) else (2021, 2)
    if any('m_CommonParameters' in pr for pr in progs):
        return 2020, 1
    if any('m_GlobalKeywordIndices' in sp for pr in progs for sp in pr.get('m_SubPrograms') or []):
        return 2019, 1
    return 2018, 4


def _tier_lists(prog):
    """A stage program's subprogram lists: [(list, parameter indices or None)] (2021.2+: one per tier)."""
    if not prog:
        return []
    if prog.get('m_PlayerSubPrograms'):
        return list(zip(prog['m_PlayerSubPrograms'], prog['m_ParameterBlobIndices']))
    return [(prog.get('m_SubPrograms') or [], None)]


def _clear_common(prog):
    for k, v in (prog.get('m_CommonParameters') or {}).items():
        if isinstance(v, list):
            v.clear()


def add_gles3_d3d11(tree, translator=None, precision='highp', replace=False, optimize=glsl.OPTIMIZE, translate=None,
                    unity=None):
    """Adds GLES3 programs translated from the shader's Direct3D 11 ones (tree edited in place).
    Returns a Result.

    Every pass's D3D11 vertex subprograms are paired with the pixel subprogram of the same
    variant (keywords and hardware tier); each pair becomes one GL program (dxbc.translate_program,
    then glsl.program_to_es as for a GLCore program), stored as Unity stores GL programs of the
    data's version (unity: its version string, e.g. '2021.3.16f1'; default from the Shader's
    layout):
      up to 2018: the program in the vertex subprogram's entry, an entry without code for the
          fragment one, both retyped GLES3 with gl_twin() subprograms; the GLES3 blob keeps the
          D3D11 blob's indices (a vertex entry shared by variants with different pixel shaders
          gets more), the entries' binding info only the source map;
      2019.x: the same, the vertex entry with Unity's GL binding info (dxbc.gl_bindings), which the
          vertex subprogram also lists;
      2020.1+: vertex subprograms only (Unity's GL programs have no fragment subprograms then),
          entries numbered anew, 2021.2+ with a parameter entry each (shared when equal); the
          vertex program's m_CommonParameters (what its D3D11 subprograms share) go back into the
          D3D11 entries, so the player does not add them to the GL programs.

    A SubShader with a variant that cannot be translated (a geometry or tessellation stage, UAVs,
    an untranslatable program) gets no GLES3 programs, so Unity uses the next SubShader or the
    Fallback, as for a SubShader an Android build has no programs for; VR-only variants
    (VR_KEYWORDS) that cannot be translated are left out instead (Result.dropped).
    translator: a dxbc.Translator; translate: function(vs Entry, ps Entry) -> GL program text
    (default dxbc.translate_program with translator)."""
    name = tree['m_ParsedForm']['m_Name']
    r = Result(name)
    r.source = 'd3d11'
    plats = list(tree['platforms'])
    if B.PLATFORM_D3D11 not in plats:
        r.why = 'no Direct3D 11 programs'
        return r
    if B.PLATFORM_GLES3PLUS in plats:
        if not replace:
            r.why = 'already has GLES3 programs'
            return r
        _strip_gles(tree)
        r.status, r.why = 'converted', '(old GLES programs removed)'
    blobs = B.ShaderBlobs(tree)
    entries = platform_entries(tree, B.PLATFORM_D3D11, blobs)
    newer = sorted({e.version for e in entries if isinstance(e, B.Entry) and e.version not in dxbc.SERIALIZERS})
    if newer:
        r.status = 'skipped'
        r.why = f'Direct3D 11 programs of serializer {newer[0]}: layout not known'
        r.changed = bool(replace and B.PLATFORM_GLES3PLUS in plats)
        return r
    serializer = next((e.version for e in entries if isinstance(e, B.Entry)), None)
    line = unity_of(tree, unity)
    if serializer is not None and line < dxbc.unity_line(serializer):
        line = dxbc.unity_line(serializer)
    if not entries and line >= (2018, 1):
        # every variant stripped from the build: an empty GLES3 blob, as Unity's builds have one per platform
        blobs.set_entries(B.PLATFORM_GLES3PLUS, [], [] if blobs.nested else None,
                          1 if blobs.stage_counts is not None else None)
        blobs.store()
        r.status, r.empty = 'converted', True
        r.why = ('no programs (every variant stripped): an empty GLES3 blob ' + r.why).strip()
        return r
    gl_info = line >= (2019, 1)             # GL programs have binding info of their own
    compact = line >= (2020, 1)             # GL: vertex subprograms only, entries numbered anew
    separate = serializer == dxbc.SEPARATE_PARAMS_FROM
    bind_of = {}                            # id(subprogram) -> dxbc.Bindings (with shared parameters)
    translate_notes = []                    # dxbc.translate_program's (uv-origin), for r.notes
    if translate is None:
        if translator is None:
            raise ValueError('add_gles3_d3d11 needs a translator or a translate function')

        def translate(vs, ps):
            return dxbc.translate_program(translator, (vs.code, bind_of[id(vs)]), (ps.code, bind_of[id(ps)]),
                                          vs.version, line, translate_notes)
    cache = {}                              # (vs index, vs params, ps index, ps params) -> (ES text, GL bindings) | Unsupported

    def program(vkey, vs, vb, pkey, ps, pb):
        k = (vkey, pkey)
        if k not in cache:
            try:
                if vs is None or ps is None or not vs.code or not ps.code:
                    raise dxbc.Unsupported('empty program entry')
                r.guessed_layout |= vs.guessed or ps.guessed
                notes = []
                bind_of[id(vs)], bind_of[id(ps)] = vb, pb
                del translate_notes[:]
                gl = translate(vs, ps)
                uv_notes = list(translate_notes)
                info = None
                if gl_info:
                    arrays = {p.name: p.array for b in (vb, pb) for cb in b.cbuffers for p in cb.params}
                    info = dxbc.gl_bindings(gl, line, vb.source_map, arrays)
                try:
                    es, typ = glsl.program_to_es(gl, precision, optimize, notes), B.GPU_GLES3
                except glsl.NeedsES31:
                    notes = []
                    es, typ = glsl.program_to_es(gl, precision, optimize, notes, es='310'), B.GPU_GLES31
                cache[k] = (es, info, typ)
                r.notes += notes + uv_notes
            except (dxbc.Unsupported, glsl.Unsupported) as ex:
                cache[k] = ex
        return cache[k]

    def stage_bindings(p, prog, sp, e, pi):
        """dxbc.Bindings of a subprogram (its entry, 2021.2+ parameter entry, shared parameters), or why not."""
        if e is None or not isinstance(e, B.Entry) or not e.code:
            return 'empty program entry'
        names = {i: n for n, i in p.get('m_NameIndices') or []}
        try:
            pe = entries[pi] if pi is not None else None
            if separate and not isinstance(pe, B.ParamEntry):
                return 'no parameter entry'
            b = dxbc.with_common(dxbc.entry_bindings(e, pe), prog.get('m_CommonParameters'), names)
            bad = dxbc.check_parsed_form(b, sp, names)
        except dxbc.Unsupported as ex:
            return str(ex)
        if bad:
            return 'binding info disagrees with the parsed form (' + ', '.join(bad[:3]) + ')'
        return b

    # plan: per SubShader, the (pass, tier list, vs, ps, program) variants to twin; any failure drops the SubShader
    plan = []
    no_instancing = set()               # passes whose GPU instancing variants were left out
    for si, ss in enumerate(tree['m_ParsedForm']['m_SubShaders']):
        todo, why = [], None
        for pi_, p in enumerate(ss['m_Passes']):
            vprog, fprog = p.get('progVertex') or {}, p.get('progFragment') or {}
            vlists, flists = _tier_lists(vprog), _tier_lists(fprog)
            others = {_variant_key(sp) for st in _OTHER_STAGES for lst, _ in _tier_lists(p.get(st))
                      for sp in lst if sp['m_GpuProgramType'] in dxbc.OTHER_STAGE_TYPES}
            for t, (vlist, vpbi) in enumerate(vlists):
                flist, fpbi = flists[t] if t < len(flists) else ([], None)
                vss = [(sp, vpbi[j] if vpbi is not None else None) for j, sp in enumerate(vlist)
                       if sp['m_GpuProgramType'] in dxbc.VERTEX_TYPES]
                pss = [(sp, fpbi[j] if fpbi is not None else None) for j, sp in enumerate(flist)
                       if sp['m_GpuProgramType'] in dxbc.PIXEL_TYPES]
                for vsp, vpi, psp, ppi, keys in _variant_pairs(vss, pss):
                    ve = entries[vsp['m_BlobIndex']]
                    pe = entries[psp['m_BlobIndex']] if psp is not None else None
                    kws = _entry_keywords(ve, pe)
                    kws = kws[0] + (kws[1] or [])
                    res = None
                    if psp is None:
                        err = 'no pixel shader for this variant'
                    elif _variant_key(vsp) in others:
                        err = 'geometry or tessellation stage (not in GLSL ES 3.00)'
                    else:
                        vb = stage_bindings(p, vprog, vsp, ve, vpi)
                        pb = stage_bindings(p, fprog, psp, pe, ppi)
                        err = vb if isinstance(vb, str) else pb if isinstance(pb, str) else None
                        if err is None:
                            res = program((vsp['m_BlobIndex'], vpi), ve, vb, (psp['m_BlobIndex'], ppi), pe, pb)
                            err = str(res) if isinstance(res, Exception) else None
                    if err is None:
                        todo.append((p, t, vsp, vpi, psp, res, keys))
                    elif any(kw in VR_KEYWORDS for kw in kws):
                        r.dropped += 1
                    elif any(kw in INSTANCING_KEYWORDS for kw in kws):
                        r.dropped_instancing += 1
                        no_instancing.add(id(p))
                    elif any(kw in SKINNING_KEYWORDS for kw in kws):
                        r.dropped_skinning += 1
                    elif why is None:
                        why = f'pass {pi_} variant {" ".join(kws) or "(no keywords)"}: {err}'
        if why is None and todo:
            plan.append((si, todo))
        elif why is not None:
            r.failed.append((si, why))
    if not plan:
        r.status = 'skipped'
        r.why = (r.failed[0][1] if r.failed else f'only VR-only variants, none translatable ({r.dropped})' if r.dropped
                 else 'no Direct3D 11 vertex/pixel programs')
        r.changed = bool(replace and B.PLATFORM_GLES3PLUS in plats)
        return r

    twins = []                          # (subprogram list, parameter index list or None, twin, parameter index)
    if not compact:
        # the GLES3 blob: D3D11 indices kept (entries without code where nothing GL uses them)
        out = [None if e is None else B.Entry(e.version, B.GPU_GLES3, [0] * len(e.stats), e.keywords, b'', dxbc.gl_rest(0),
                                             e.local_keywords)
               for e in entries]
        segs = blobs.segments(B.PLATFORM_D3D11) if blobs.nested else None
        vslot, used = {}, set()
        for si, todo in plan:
            for p, t, vsp, vpi, psp, (es, info, typ), keys in todo:
                vi, fi = vsp['m_BlobIndex'], psp['m_BlobIndex']
                if (vi, fi) not in vslot:
                    slot = vi if vi not in used else len(out)
                    if slot == len(out):
                        out.append(None)
                        if segs is not None:
                            segs.append(segs[vi])
                    used.add(slot)
                    vslot[(vi, fi)] = slot
                    e = entries[vi]
                    rest = info.serialize() if info is not None else dxbc.gl_rest(bind_of_source_map(e))
                    kw, lkw = _entry_keywords(e, entries[fi])
                    out[slot] = B.Entry(e.version, typ, [0] * len(e.stats), kw, es.encode('utf-8'), rest, lkw)
                    r.programs += 1
                    r.es31 += typ == B.GPU_GLES31
                used.add(fi)
                if typ == B.GPU_GLES31 and out[fi] is not None:
                    out[fi].gpu_type = typ
                names = _name_indices(p, _gl_names(info)) if info is not None else None
                tw = gl_twin(vsp, vslot[(vi, fi)], info, names, typ)
                _set_keywords(tw, keys)
                twins.append((p['progVertex']['m_SubPrograms'], None, tw, None))
                twins.append((p['progFragment']['m_SubPrograms'], None, gl_twin(psp, fi, gpu_type=typ), None))
        blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs)
    else:
        out, segs = [], []
        d3d_segs = blobs.segments(B.PLATFORM_D3D11) if blobs.nested else [0] * len(entries)
        code_at, param_at = {}, {}
        for si, todo in plan:
            for p, t, vsp, vpi, psp, (es, info, typ), keys in todo:
                vi = vsp['m_BlobIndex']
                key = (vi, vpi, psp['m_BlobIndex'])
                e = entries[vi]
                if key not in code_at:
                    rest = info.head() if separate else info.serialize()
                    code_at[key] = len(out)
                    kw, lkw = _entry_keywords(e, entries[psp['m_BlobIndex']])
                    out.append(B.Entry(e.version, typ, [0] * len(e.stats), kw, es.encode('utf-8'), rest, lkw))
                    segs.append(d3d_segs[vi])
                    r.programs += 1
                    r.es31 += typ == B.GPU_GLES31
                pidx = None
                if separate:
                    data = info.params_bytes()
                    if data not in param_at:
                        param_at[data] = len(out)
                        out.append(B.ParamEntry(e.version, data))
                        segs.append(d3d_segs[vi])
                    pidx = param_at[data]
                lst, pbi = _tier_lists(p['progVertex'])[t]
                tw = gl_twin(vsp, code_at[key], gpu_type=typ)
                _set_keywords(tw, keys)
                twins.append((lst, pbi, tw, pidx))
        _restore_common(tree, plan, entries, blobs, separate)
        blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs if blobs.nested else None, 1 if blobs.stage_counts is not None else None)
    blobs.store()
    # commit the twins (each fragment subprogram once, however many vertex ones share it)
    seen, passes = set(), set()
    for lst, pbi, tw, pidx in twins:
        key = (id(lst), tw['m_BlobIndex'], _variant_key(tw))
        if key in seen:
            continue
        seen.add(key)
        lst.append(tw)
        if pbi is not None:
            pbi.append(pidx)
        r.twins += 1
    for si, todo in plan:
        for p, *_ in todo:
            add_platform(p, B.PLATFORM_GLES3PLUS)
            if id(p) in no_instancing:
                for f in ('m_HasInstancingVariant', 'm_HasProceduralInstancingVariant'):
                    if f in p:
                        p[f] = False
    r.status = 'converted'
    if r.failed:
        r.why = (r.why + ' ' if r.why else '') + '; '.join(f'SubShader {si} left out: {w}' for si, w in r.failed)
    return r


def bind_of_source_map(e):
    return dxbc.Bindings.parse(e.rest, e.version).source_map


def _gl_names(info):
    return [n for cb in info.cbuffers if cb.name for n in [cb.name] + [p.name for p in cb.params]] + \
        [p.name for cb in info.cbuffers if not cb.name for p in cb.params] + \
        [x.name for x in info.bindings if x.name]


def _restore_common(tree, plan, entries, blobs, separate):
    """2020.1+: a vertex program given GLES3 subprograms gets its m_CommonParameters (what its
    D3D11 subprograms share, which the player adds to every subprogram of the program) put back
    into its D3D11 subprograms' binding info, and cleared. (Other desktop platforms' subprograms
    of such a program, e.g. Vulkan, and D3D11 ones whose binding info this path does not read
    then lack them; a handheld never uses those.)"""
    progs = {}
    for si, todo in plan:
        for p, *_ in todo:
            progs[id(p)] = p
    changed = False
    for p in progs.values():
        prog = p['progVertex']
        common = prog.get('m_CommonParameters')
        if not common or not any(isinstance(v, list) and v for v in common.values()):
            continue
        names = {i: n for n, i in p.get('m_NameIndices') or []}
        done = set()                    # entries shared by several subprograms get it once
        for lst, pbi in _tier_lists(prog):
            for j, sp in enumerate(lst):
                if sp['m_GpuProgramType'] not in dxbc.VERTEX_TYPES:
                    continue
                pi = pbi[j] if pbi is not None else None
                at = pi if separate else sp['m_BlobIndex']
                if at in done:
                    continue
                done.add(at)
                e = entries[sp['m_BlobIndex']]
                pe = entries[pi] if pi is not None else None
                try:
                    b = dxbc.with_common(dxbc.entry_bindings(e, pe), common, names)
                except dxbc.Unsupported:
                    continue            # (binding info this path does not read: kept as it is)
                if separate:
                    entries[pi] = B.ParamEntry(pe.version, b.params_bytes())
                else:
                    entries[at] = B.Entry(e.version, e.gpu_type, e.stats, e.keywords, e.code, b.serialize(), e.local_keywords)
                changed = True
        _clear_common(prog)
    if changed:
        blobs.set_entries(B.PLATFORM_D3D11, entries, blobs.segments(B.PLATFORM_D3D11) if blobs.nested else None)
