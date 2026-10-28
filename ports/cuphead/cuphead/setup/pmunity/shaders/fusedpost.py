"""Opt-in (`shaders.fused_post`): a chain of full-screen post-processing passes drawn as one pass.

A built-in-pipeline post chain is a row of OnRenderImage components, each a full-screen blit of
the previous one's output into a texture of its own: Hollow Knight's bloom composite (`_MainTex +
_Bloom`), colour curves (`_RgbTex`) and brightness/contrast are three 720x450 passes a frame, each
a store of the whole picture, a load of it by the next, a pass's submission and start-up on the
Mali, and a job chain of driver time on the render thread (docs/profiling.md, "GPU, pass by
pass"). Where each later pass reads the previous one's output only at its own pixel, the three are
one function of the first pass's inputs, so one pass can draw them: this module writes that pass's
program from the game's own programs and appends it to the chain's last shader, named for
`Material.FindPass` (asmpatch's hk-post makes the game's components draw it).

What qualifies (else the chain is left as it is, with the reason). Every pass's GLES3 program is
one vertex + fragment program (no keyword variants): the vertex stages the same text in every
pass (one blit quad); each fragment stage declares loose uniforms, samplers, one `in` varying
block and one output, no uniform blocks; every pass but the first reads `_MainTex` only as
`texture(_MainTex, vs_TEXCOORD0.xy)` (its own pixel: the varying the shared vertex stage passes
through from the quad, and the textures of a chain are one size) and nothing else of it (no
`_MainTex_TexelSize`, no other sampling function), and uses no screen position or derivative of
its own (`gl_FragCoord`, `dFdx`, ...) nor `discard`; a uniform or sampler name (other than
`_MainTex`) belongs to one pass only (the fused material holds one value per name).

The fused fragment stage: the union of the passes' declarations (samplers renumbered), each pass's
main() as a function (its globals local to it, its output a local, the `_MainTex` read of a later
pass its argument), and a main() that chains them. Between the passes, where the game stored to an
8-bit target and read it back, `quantize: "rgba8"` (the default) rounds each component to the
nearest of 255 steps after clamping to 0 - 1, as the store does, so the chain computes the same
values the game's does (a float rounding tie apart: not promised exact, measured on the device);
`"none"` carries the full-precision value on.

The data edit (as fusedblur's): the last shader's chain pass is copied and appended to its
SubShader, named `name` (`m_State.m_Name`), with only its GLES3 subprograms, each pointing to a new
blob entry (the pass's vertex stage, the fused fragment stage) and a new parameter entry with the
binding info Unity's GL compiler would give the fused program (dxbc.gl_bindings; first checked to
reproduce the last pass's own parameter entry, else the layout is not understood and nothing
changes). Nothing else changes: the game draws as before until something asks for the new pass.

Config: `"fused_post": [{"name": "PMUNITY_FUSED_POST", "chain": ["Hidden/FastBloom",
"Hidden/ColorCorrectionCurvesSimple", "Custom/Brightness Effect"], "quantize": "rgba8"}]` (a chain
item `"Shader/Name"` or `"Shader/Name:<pass>"`, pass 0 of SubShader 0 by default; all of a chain's
shaders must be in one assets file, the file of the last).
"""
import copy
import re

from . import blob as B
from . import convert as C
from . import dxbc
from . import glsl
from .grabfetch import GLES3_TYPES, _gles_only

MARK = '// pmunity fused_post:'
DEFAULT_NAME = 'PMUNITY_FUSED_POST'
QUANTIZE = ('rgba8', 'none')
MAIN_TEX = '_MainTex'
STORE_FN = 'pmunity_store'


class NotFusable(Exception):
    pass


class Result:
    def __init__(self, chain):
        self.chain = chain
        self.name = chain.get('name') or DEFAULT_NAME
        self.file = None
        self.status = 'unchanged'       # 'changed' | 'skipped' | 'unchanged'
        self.why = ''
        self.shader = None              # the last shader's name
        self.pass_index = None          # the fused pass's index in its SubShader
        self.programs = 0
        self.code = None                # the fused program (for tests and logs)

    @property
    def changed(self):
        return self.status == 'changed'

    def __repr__(self):
        return f'{self.status}: {self.why}'


def chains_of(cfg):
    """The chains of a config's shaders.fused_post (checked), or []."""
    v = (cfg.get('shaders') or {}).get('fused_post') if cfg else None
    if not v:
        return []
    if not isinstance(v, list) or not all(isinstance(c, dict) for c in v):
        raise ValueError('shaders.fused_post: a list of {"name", "chain", "quantize"} objects')
    for c in v:
        chain = c.get('chain')
        if not isinstance(chain, list) or len(chain) < 2 or not all(isinstance(s, str) and s for s in chain):
            raise ValueError(f'shaders.fused_post: "chain" is a list of two or more shader names ({chain!r})')
        if c.get('quantize', 'rgba8') not in QUANTIZE:
            raise ValueError(f'shaders.fused_post: quantize {c.get("quantize")!r} (one of {", ".join(QUANTIZE)})')
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', c.get('name') or DEFAULT_NAME):
            raise ValueError(f'shaders.fused_post: name {c.get("name")!r} (a C identifier)')
    return v


def chain_items(chain):
    """[(shader name, pass index)] of a chain's items ("Name" or "Name:<pass>")."""
    out = []
    for s in chain['chain']:
        m = re.fullmatch(r'(.*?)(?::(\d+))?', s)
        out.append((m.group(1), int(m.group(2) or 0)))
    return out


def chain_names(chains):
    return {n for c in chains for n, _ in chain_items(c)}


# ---------------------------------------------------------------- reading a fragment stage

class Fragment:
    """One pass's fragment stage, taken apart: version, precision statements, extensions, loose
    uniforms [(type, name, array)], samplers [(type, name)], ins [(type, name)], output (type,
    name), globals [(type, name)], body (main's statements)."""

    _UNIFORM = re.compile(r'^\s*(?:UNITY_LOCATION\(\s*\d+\s*\)\s+)?uniform\s+(?:(?:lowp|mediump|highp)\s+)?(\w+)\s+(\w+)\s*(\[\s*\d+\s*\])?\s*;\s*$')
    _IN = re.compile(r'^\s*(?:flat\s+|centroid\s+)?in\s+(?:(?:lowp|mediump|highp)\s+)?(\w+)\s+(\w+)\s*;\s*$')
    _OUT = re.compile(r'^\s*layout\s*\(\s*location\s*=\s*(\d+)\s*\)\s*out\s+(?:(?:lowp|mediump|highp)\s+)?(\w+)\s+(\w+)\s*;\s*$')
    _GLOBAL = re.compile(r'^\s*(?:(?:lowp|mediump|highp)\s+)?((?:[biud]?vec[234]|mat[234](?:x[234])?|float|int|uint|bool))\s+(\w+)\s*(\[\s*\d+\s*\])?\s*;\s*$')
    _PRECISION = re.compile(r'^\s*precision\s+(lowp|mediump|highp)\s+(\w+)\s*;\s*$')
    _TYPES = {'sampler2D', 'sampler3D', 'samplerCube', 'sampler2DArray', 'sampler2DShadow', 'samplerCubeShadow',
              'isampler2D', 'usampler2D', 'isampler3D', 'usampler3D', 'isampler2DArray', 'usampler2DArray'}

    def __init__(self, src, label):
        self.label = label
        self.version = None
        self.precision, self.extensions, self.macros = [], [], []
        self.uniforms, self.samplers, self.ins, self.globals = [], [], [], []
        self.output = None
        m = re.search(r'^\s*void\s+main\s*\(\s*\)\s*\{', src, re.M)
        if not m:
            raise NotFusable(f'{label}: no main()')
        head, rest = src[:m.start()], src[m.end():]
        end = rest.rstrip().rfind('}')
        if end < 0 or rest.rstrip()[end:].strip() != '}':
            raise NotFusable(f'{label}: main() does not end the stage')
        self.body = rest[:end]
        self._read_head(head)
        if self.output is None:
            raise NotFusable(f'{label}: no colour output')
        for bad in ('gl_FragCoord', 'gl_FragDepth', 'discard', 'gl_PointCoord', 'gl_FrontFacing', 'gl_SampleID'):
            if re.search(r'\b%s\b' % bad, self.body):
                raise NotFusable(f'{label}: uses {bad}')

    def _read_head(self, head):
        for line in head.splitlines():
            s = line.strip()
            if not s or s.startswith('//'):
                continue
            if s.startswith('#'):
                if s.startswith('#version'):
                    self.version = s
                elif s.startswith('#extension'):
                    self.extensions.append(s)
                else:
                    self.macros.append(s)                   # hlslcc's macro header (UNITY_LOCATION, UNITY_BINDING, ...)
                continue
            m = self._PRECISION.match(s)
            if m:
                self.precision.append(s)
                continue
            m = self._UNIFORM.match(s)
            if m:
                typ, name, arr = m.groups()
                if typ in self._TYPES:
                    if arr:
                        raise NotFusable(f'{self.label}: sampler array {name}')
                    self.samplers.append((typ, name))
                else:
                    self.uniforms.append((typ, name, (arr or '').replace(' ', '')))
                continue
            m = self._OUT.match(s)
            if m:
                if self.output is not None or m.group(1) != '0':
                    raise NotFusable(f'{self.label}: more than one output')
                self.output = (m.group(2), m.group(3))
                continue
            m = self._IN.match(s)
            if m:
                self.ins.append((m.group(1), m.group(2)))
                continue
            m = self._GLOBAL.match(s)
            if m:
                self.globals.append((m.group(1), m.group(2), (m.group(3) or '').replace(' ', '')))
                continue
            if 'uniform' in s and '{' in s or s.startswith('layout') and 'uniform' in s:
                raise NotFusable(f'{self.label}: uniform block ({s[:40]})')
            raise NotFusable(f'{self.label}: declaration not understood: {s[:60]}')

    def names(self):
        return [n for _, n, _ in self.uniforms] + [n for _, n in self.samplers]

    def function(self, index, store=False):
        """The stage's main() as `vec4 pmunity_pass<index>([vec4 pmunity_in])`: index 0 reads the
        source itself; a later pass's `texture(_MainTex, vs_TEXCOORD0.xy)` is pmunity_in."""
        body = self.body
        otype, oname = self.output
        body = re.sub(r'\b%s\b' % re.escape(oname), 'pmunity_out', body)
        if index > 0:
            own = r'texture\s*\(\s*%s\s*,\s*vs_TEXCOORD0(?:\.xy)?\s*\)' % MAIN_TEX
            body, n = re.subn(own, 'pmunity_in', body)
            if n == 0:
                raise NotFusable(f'{self.label}: does not read {MAIN_TEX} at its own pixel')
            if re.search(r'\b%s\b' % MAIN_TEX, body):
                raise NotFusable(f'{self.label}: reads {MAIN_TEX} other than at its own pixel')
            for bad in ('dFdx', 'dFdy', 'fwidth', 'dFdxFine', 'dFdyFine', 'dFdxCoarse', 'dFdyCoarse', 'fwidthFine', 'fwidthCoarse'):
                if re.search(r'\b%s\b' % bad, body):
                    raise NotFusable(f'{self.label}: uses {bad}')
        body, n = re.subn(r'\breturn\s*;', 'return pmunity_out;', body)
        lines = ['%s pmunity_pass%d(%s)' % (otype, index, 'vec4 pmunity_in' if index > 0 else ''), '{']
        lines += ['    %s %s%s;' % (t, nm, arr) for t, nm, arr in self.globals]
        lines.append('    %s pmunity_out;' % otype)
        lines.append(body.strip('\n'))
        if n == 0:
            lines.append('    return pmunity_out;')
        lines.append('}')
        return '\n'.join(lines) + '\n'


def fuse_fragment(frags, quantize='rgba8', comment=''):
    """The fused fragment stage of the passes' fragment stages (Fragment, in chain order)."""
    first = frags[0]
    for f in frags[1:]:
        if f.version != first.version:
            raise NotFusable(f'{f.label}: #version differs from {first.label}')
        if sorted(f.precision) != sorted(first.precision):
            raise NotFusable(f'{f.label}: precision statements differ from {first.label}')
        if f.output[0] != first.output[0]:
            raise NotFusable(f'{f.label}: output type differs from {first.label}')
    owners = {}
    uniforms, samplers, ins, exts = [], [], [], []
    for i, f in enumerate(frags):
        for name in f.names():
            if name == MAIN_TEX:
                if i > 0:
                    continue
            elif i > 0 and name.startswith(MAIN_TEX):
                raise NotFusable(f'{f.label}: reads {name} (of the pass before it)')
            elif name in owners:
                raise NotFusable(f'{f.label}: {name} is also {owners[name]}\'s')
            owners[name] = f.label
        uniforms += [u for u in f.uniforms if i == 0 or u[1] != MAIN_TEX]
        samplers += [s for s in f.samplers if i == 0 or s[1] != MAIN_TEX]
        ins += [v for v in f.ins if v not in ins]
        exts += [e for e in f.extensions if e not in exts]
    if MAIN_TEX not in {n for _, n in first.samplers}:
        raise NotFusable(f'{first.label}: no {MAIN_TEX} sampler')
    samplers.sort(key=lambda s: s[1] != MAIN_TEX)          # the source first (unit 0, as in every pass)
    out = [first.version] + first.precision + exts + first.macros          # hlslcc's header (UNITY_LOCATION, as Unity's programs have it)
    out.append('%s %s drawn as one pass%s' % (MARK, ', '.join(f.label for f in frags),
                                                ' (the stores between them rounded to 8 bits)' if quantize == 'rgba8' else ''))
    out += ['uniform %s %s%s;' % u for u in uniforms]
    out += ['UNITY_LOCATION(%d) uniform %s %s;' % (i, t, n) for i, (t, n) in enumerate(samplers)]
    out += ['in %s %s;' % v for v in ins]
    out.append('layout(location = 0) out %s %s;' % first.output)
    if quantize == 'rgba8':
        out.append('%s %s(%s c) { return floor(clamp(c, 0.0, 1.0) * 255.0 + 0.5) / 255.0; }' % (first.output[0], STORE_FN, first.output[0]))
    for i, f in enumerate(frags):
        out.append(f.function(i))
    out += ['void main()', '{', '    %s pmunity_c = pmunity_pass0();' % first.output[0]]
    for i in range(1, len(frags)):
        if quantize == 'rgba8':
            out.append('    pmunity_c = %s(pmunity_c);' % STORE_FN)
        out.append('    pmunity_c = pmunity_pass%d(pmunity_c);' % i)
    out += ['    %s = pmunity_c;' % first.output[1], '    return;', '}', '']
    return '\n'.join(out)


def fuse_program(codes, labels, quantize='rgba8'):
    """The fused GLES3 program of the passes' programs (each '#ifdef VERTEX ... #ifdef FRAGMENT
    ...' text): the last pass's vertex stage, the fused fragment stage."""
    stages = []
    for code, label in zip(codes, labels):
        blocks = {stage: code[a:b] for stage, a, b in glsl.stage_blocks(code)}
        if set(blocks) != {'VERTEX', 'FRAGMENT'}:
            raise NotFusable(f'{label}: not a vertex + fragment program')
        stages.append(blocks)
    vert = _canon(stages[-1]['VERTEX'])
    for st, label in zip(stages, labels):
        if _canon(st['VERTEX']) != vert:
            raise NotFusable(f'{label}: its vertex stage differs from {labels[-1]}\'s')
    if not re.search(r'\bvs_TEXCOORD0(?:\.xy)?\s*=\s*in_TEXCOORD0(?:\.xy)?\s*;', vert):
        raise NotFusable(f'{labels[-1]}: the vertex stage does not pass the quad\'s texcoord through (vs_TEXCOORD0 = in_TEXCOORD0)')
    frags = [Fragment(st['FRAGMENT'], label) for st, label in zip(stages, labels)]
    last = codes[-1]
    fa, fb = next((a, b) for stage, a, b in glsl.stage_blocks(last) if stage == 'FRAGMENT')
    return last[:fa] + fuse_fragment(frags, quantize) + last[fb:]


def _canon(src):
    return re.sub(r'\s+', ' ', re.sub(r'//[^\n]*', '', src)).strip()


# ---------------------------------------------------------------- the data edit

def _gles_subprograms(p):
    """[(subprogram, its tier list's parameter indices or None, its index in that list)] of a pass's GLES3 subprograms."""
    out = []
    for st in C.STAGES:
        for lst, pbi in C._tier_lists(p.get(st)):
            for j, sp in enumerate(lst):
                if sp['m_GpuProgramType'] in GLES3_TYPES:
                    out.append((sp, pbi, j))
    return out


def _pass_program(tree, pass_index, label):
    """(pass, its one GLES3 program's code, [blob indices], parameter entry index or None, entries, blobs) of SubShader 0's pass."""
    pf = tree['m_ParsedForm']
    subs = pf['m_SubShaders']
    if not subs or pass_index >= len(subs[0]['m_Passes']):
        raise NotFusable(f'{label}: no such pass')
    p = subs[0]['m_Passes'][pass_index]
    if p.get('m_Type') != 0:
        raise NotFusable(f'{label}: not a normal pass (type {p.get("m_Type")})')
    if B.PLATFORM_GLES3PLUS not in tree['platforms']:
        raise NotFusable(f'{label}: no GLES3 programs')
    blobs = B.ShaderBlobs(tree)
    entries = C.platform_entries(tree, B.PLATFORM_GLES3PLUS, blobs)
    sps = _gles_subprograms(p)
    if not sps:
        raise NotFusable(f'{label}: no GLES3 subprogram')
    codes, params = set(), set()
    for sp, pbi, j in sps:
        if any(sp.get(k) for k in ('m_KeywordIndices', 'm_GlobalKeywordIndices', 'm_LocalKeywordIndices')):
            raise NotFusable(f'{label}: keyword variants')
        e = entries[sp['m_BlobIndex']] if sp['m_BlobIndex'] < len(entries) else None
        if not isinstance(e, B.Entry) or not e.code:
            raise NotFusable(f'{label}: empty program entry')
        codes.add(sp['m_BlobIndex'])
        params.add(pbi[j] if pbi is not None else None)
    texts = {entries[i].code.decode('utf-8') for i in codes}
    if len(texts) != 1 or len(params) != 1:
        raise NotFusable(f'{label}: more than one GLES3 program')
    return p, texts.pop(), sorted(codes), params.pop(), entries, blobs


def apply(shaders, chain, unity=None):
    """Appends a chain's fused pass to its last shader. shaders: {name: typetree} of the shaders at
    hand (the chain's must all be there; the last one's tree is edited in place); chain: one
    fused_post config item; unity: the data's version string or (major, minor). Returns a Result."""
    r = Result(chain)
    items = chain_items(chain)
    r.shader = items[-1][0]
    quantize = chain.get('quantize', 'rgba8')
    missing = [n for n, _ in items if n not in shaders]
    if missing:
        r.status, r.why = 'skipped', 'not in this file: ' + ', '.join(missing)
        return r
    last_tree = shaders[r.shader]
    labels = [f'"{n}" pass {i}' for n, i in items]
    try:
        codes = []
        for (n, i), label in zip(items, labels):
            codes.append(_pass_program(shaders[n], i, label)[1])
        p, _, blob_indices, param_index, entries, blobs = _pass_program(last_tree, items[-1][1], labels[-1])
        if any(isinstance(e, B.Entry) and e.code.startswith(MARK.encode()) or
               isinstance(e, B.Entry) and (MARK.encode() in e.code) for e in entries):
            r.why = 'already has a fused pass (fused_post done before)'
            return r
        if any(pp.get('m_State', {}).get('m_Name') == r.name for ss in last_tree['m_ParsedForm']['m_SubShaders'] for pp in ss['m_Passes']):
            r.why = f'already has a pass named {r.name}'
            return r
        fused = fuse_program(codes, labels, quantize)
        # the binding info: our writing of the last pass's own must match its parameter entry
        uv = C.unity_of(last_tree, unity) if not isinstance(unity, tuple) else unity
        e0 = entries[blob_indices[0]]
        separate = param_index is not None
        if separate:
            pe = entries[param_index]
            if not isinstance(pe, B.ParamEntry):
                raise NotFusable(f'{labels[-1]}: no parameter entry')
            own = dxbc.gl_bindings(e0.code.decode('utf-8'), uv)
            if own.params_bytes() != pe.data:
                raise NotFusable(f'{labels[-1]}: its binding info is not as this writes it (layout not understood)')
            info = dxbc.gl_bindings(fused, uv)
            new_param = B.ParamEntry(pe.version, info.params_bytes())
            rest = e0.rest
        else:
            own = dxbc.entry_bindings(e0)
            info = dxbc.gl_bindings(fused, uv, own.source_map)
            if own.serialize() != dxbc.gl_bindings(e0.code.decode('utf-8'), uv, own.source_map).serialize():
                raise NotFusable(f'{labels[-1]}: its binding info is not as this writes it (layout not understood)')
            new_param, rest = None, info.serialize()
    except (NotFusable, dxbc.Unsupported, ValueError) as ex:
        r.status, r.why = 'skipped', str(ex)
        return r
    out = [e.copy() if e is not None else None for e in entries]
    segs = blobs.segments(B.PLATFORM_GLES3PLUS)
    moved = {}
    for bi in blob_indices:
        e = out[bi].copy()
        e.code, e.rest = fused.encode('utf-8'), rest
        moved[bi] = len(out)
        out.append(e)
        segs.append(segs[bi])
        r.programs += 1
    new_pi = None
    if new_param is not None:
        new_pi = len(out)
        out.append(new_param)
        segs.append(segs[param_index])
    cp = copy.deepcopy(p)
    _gles_only(cp, moved)
    if new_pi is not None:
        for st in C.STAGES:
            prog = cp.get(st)
            if prog and prog.get('m_PlayerSubPrograms'):
                for tier, lst in enumerate(prog['m_PlayerSubPrograms']):
                    prog['m_ParameterBlobIndices'][tier] = [new_pi for _ in lst]
    if isinstance(cp.get('m_State'), dict):
        cp['m_State']['m_Name'] = r.name
    blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs if blobs.nested else None)
    blobs.store()
    passes = last_tree['m_ParsedForm']['m_SubShaders'][0]['m_Passes']
    passes.append(cp)
    r.pass_index = len(passes) - 1
    r.code = fused
    r.status = 'changed'
    r.why = (f'"{r.shader}" pass {r.pass_index} ({r.name}) draws {", ".join(labels)} as one'
             f' ({r.programs} program{"s" if r.programs != 1 else ""}; quantize {quantize})')
    return r
