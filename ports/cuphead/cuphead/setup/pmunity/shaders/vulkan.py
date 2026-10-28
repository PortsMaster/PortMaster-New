"""Vulkan programs (SPIR-V) of Unity Shader assets -> GLSL ES programs, with Khronos' SPIRV-Cross.

A build made without OpenGL Core (HDRP's Linux builds; a Linux build whose graphics APIs list only
Vulkan) carries Vulkan programs (platform blob 18, gpu program type 25 "SPIRV"). Unity compiles
them as its GL programs, with its HLSLcc from the HLSL's DXBC (here to Vulkan GLSL, then SPIR-V
with glslang), so the SPIR-V keeps HLSLcc's shape: matrices as vec4 arrays, one uniform block
per constant buffer (the loose globals of each stage in one named <V|P|G>Globals<hash>), a
separate texture and sampler per texture. Unity strips the debug names but those of some
varyings.

The blob entries have the GL layout of the same Unity version (blob.Entry; one subprogram per
variant from 2020.1, before that a vertex and a fragment subprogram, the fragment one's entry
without code). An entry's code:

    int32 flags                                0 up to 2019.x; 2020.1+: 32 | requirements bits
                                               (2021.2+: and 1 << 24)
    n x (int32 offset, int32 size)             one per stage slot (5 slots in 2017.x, 6 in 2019.x,
                                               9 from 2020.1): vertex, fragment, hull, domain,
                                               geometry, ...; offsets from the code's start
    (2022.1+: int32 1 and two 16-byte hashes, zeros up to the first module)
    the stages' modules                        SPIR-V compressed with SMOL-V (Aras Pranckevicius'
                                               format, decoded by pmspirvcross)

and after the code Unity's binding info, laid out as for Direct3D 11 (dxbc.Bindings): the vertex
channel source map and channels (source ShaderChannel, target 13 + the input's location), the
constant buffers with the members the program uses (name, type, rows, columns, matrix, array,
offset), the bindings. A binding's index is stage bits << 24 | descriptor set << 16 | binding (stage
bits 4 vertex, 8 fragment, 64 geometry); a texture's first extra int is its sampler's index in the
same form, kind 4 an inline sampler state. From 2021.2 the constant buffers and bindings are a
parameter entry of their own, as for the other platforms. Unity 6000.6 (serializer 202605290)
writes that parameter entry in a layout of its own (dxbc's docstring: typed lists, each binding
an (encoded data, slot) pair, the slot the index above); it is read so (dxbc.Bindings typed), the
GLES3 twins get their GL binding info in it too (dxbc.gl_bindings typed: as Unity's 6000.6 GL
programs, the "$Globals" binding at slot -1), and so do the Vulkan entries the shared parameters
are put back into (m_CommonParameters: 6000.6's names, m_OffsetInConstantBuffer, m_Binding).

translate_program() turns one entry into a GL program the way Unity's GLES3 backend binds them,
as HLSLcc's GL programs of the same shader look:
  * vertex inputs named as Unity's GL backend finds its vertex channels (in_POSITION0, in_NORMAL0,
    in_TANGENT0, in_COLOR0, in_TEXCOORD0-7, in_BLENDWEIGHTS0, in_BLENDINDICES0: libunity's
    list), from the channels' locations, without locations;
  * varyings named by location (vs_LOCATION<n>), the same in both stages; a fragment input with
    fewer components than the vertex output (Vulkan allows it, GLSL ES does not) reads a swizzle
    of the full vector;
  * fragment outputs SV_Target<n> at their locations;
  * each stage's globals as plain uniforms (matrices hlslcc_mtx4x4<name> vec4 arrays), the other
    constant buffers (URP's UnityPerDraw, UnityPerMaterial, ...) as uniform blocks of their name
    with Unity's member names (members the program does not use: Xhlslcc_UnusedX_<block>_<offset>) - up
    to 2018 these too as plain uniforms, as Unity's GL programs of 2017 - 2018 have them;
  * every texture combined with its sampler as one GLSL sampler named as the texture
    (hlslcc_zcmp<name> for a comparison, as HLSLcc names it); from 2019.1 with its unit and each
    block its binding in Unity's macros (UNITY_LOCATION(n), UNITY_BINDING(n)), which the GL
    binding info (dxbc.gl_bindings) gives the backend;
  * the y flip Unity's Vulkan programs end their vertex stage with (gl_Position.y = -gl_Position.y,
    before every return: Vulkan's clip space has y down) is left out: the engine gives a GL device
    GL's matrices.
What Unity's Vulkan compile decided by platform stays as for Direct3D 11 (UNITY_REVERSED_Z,
UNITY_UV_STARTS_AT_TOP and UNITY_NEAR_CLIP_VALUE are Direct3D's on Vulkan): docs/shaders.md.
Programs that need GLSL ES 3.10 (texture gather, multisampled textures, ...) are written as
`#version 310 es` (GLES 3.1 programs); geometry and tessellation stages, storage buffers and
images, subpass inputs and what GLSL ES lacks are Unsupported.
"""
import os
import re
import shutil
import struct
import subprocess

from . import dxbc
from . import glsl
from . import spirv as S

GPU_SPIRV = 25
MAX_SLOTS = 9                   # stage slots of the code's table (2022.1+: other data follows them)
ATTRIB_BASE = 13                # a channel's target: 13 + the vertex input's location (before 2018.2: 12)
ATTRIB_BASE_2017 = 12
# vertex channels (ShaderChannel) -> the input names Unity's GL backend binds them by (libunity's list)
CHANNELS = ('in_POSITION0', 'in_NORMAL0', 'in_TANGENT0', 'in_COLOR0') + tuple(f'in_TEXCOORD{i}' for i in range(8)) + \
    ('in_BLENDWEIGHTS0', 'in_BLENDINDICES0')
CHANNELS_2017 = ('in_POSITION0', 'in_NORMAL0', 'in_COLOR0', 'in_TEXCOORD0', 'in_TEXCOORD1', 'in_TEXCOORD2',
                 'in_TEXCOORD3', 'in_TANGENT0')        # Unity 5.x - 2018.1 (serializers before 201802150)
NEW_CHANNELS_FROM = 201802150
_GLOBALS = re.compile(r'^(?:\$Globals|[A-Z]Globals\d*)$')   # a stage's loose globals: VGlobals<hash>, PGlobals<hash>
_DERIVATIVES = {S.OP_DPDX_FINE: S.OP_DPDX, S.OP_DPDX_COARSE: S.OP_DPDX, S.OP_DPDY_FINE: S.OP_DPDY,
                S.OP_DPDY_COARSE: S.OP_DPDY, S.OP_FWIDTH_FINE: S.OP_FWIDTH, S.OP_FWIDTH_COARSE: S.OP_FWIDTH}


class Unsupported(Exception):
    """A program that this path cannot give a GL twin (the message says why)."""


# ---------------------------------------------------------------- the entry's code

def split_code(code):
    """A Vulkan entry's code -> (flags, [(slot, module bytes)]) (see the module docstring)."""
    if len(code) < 12:
        raise Unsupported('Vulkan program code too short')
    flags, = struct.unpack_from('<i', code)
    first, p, mods = len(code), 4, []
    slot = 0
    while p + 8 <= first and slot < MAX_SLOTS:
        off, size = struct.unpack_from('<ii', code, p)
        if size:
            if size < 0 or off < p + 8 or off + size > len(code):
                raise Unsupported(f'Vulkan program code: stage table entry {slot} out of range')
            first = min(first, off)
            mods.append((slot, bytes(code[off:off + size])))
        p += 8
        slot += 1
    if not mods:
        raise Unsupported('Vulkan program without stages')
    return flags, mods


def is_globals(name):
    return bool(_GLOBALS.match(name or ''))


# ---------------------------------------------------------------- pmspirvcross

def find_spirv_cross():
    """$PMSPIRVCROSS, else tools/spirvcross/out/pmspirvcross of this repository, else pmspirvcross on PATH."""
    p = os.environ.get('PMSPIRVCROSS')
    if p:
        return p
    here = os.path.dirname(os.path.abspath(__file__))
    p = os.path.normpath(os.path.join(here, '..', '..', '..', 'tools', 'spirvcross', 'out', 'pmspirvcross'))
    if os.path.exists(p):
        return p
    return shutil.which('pmspirvcross')


class Translator:
    """A pmspirvcross server process (restarted if it dies on a module)."""

    def __init__(self, exe=None):
        self.exe = exe or find_spirv_cross()
        if not self.exe or not os.path.exists(self.exe):
            raise FileNotFoundError('pmspirvcross not found: build it with tools/spirvcross/build.sh or set PMSPIRVCROSS')
        self.proc = None
        self.crashes = 0

    def __enter__(self):
        return self

    def __exit__(self, *a):
        self.close()

    def close(self):
        if self.proc:
            try:
                self.proc.stdin.write(b'q 0 0\n')
                self.proc.stdin.close()
            except OSError:
                pass
            self.proc.wait()
            self.proc.stdout.close()
            self.proc = None

    def _request(self, op, arg, data):
        if self.proc is None:
            self.proc = subprocess.Popen([self.exe, '-s'], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        try:
            self.proc.stdin.write(f'{op} {arg} {len(data)}\n'.encode() + data)
            self.proc.stdin.flush()
            line = self.proc.stdout.readline().split()
            if not line:
                raise BrokenPipeError
            status, n, k = int(line[0]), int(line[1]), int(line[2])
            out = self.proc.stdout.read(n)
            log = self.proc.stdout.read(k).decode('utf-8', 'replace')
        except (BrokenPipeError, ValueError, IndexError):
            self.proc.kill()
            self.proc.wait()
            for f in (self.proc.stdin, self.proc.stdout):
                try:
                    f.close()
                except OSError:
                    pass
            self.proc = None
            self.crashes += 1
            raise Unsupported('SPIRV-Cross crashed on this module')
        if status:
            raise Unsupported('SPIRV-Cross: ' + ('; '.join(l[7:] if l.startswith('error: ') else l
                                                         for l in log.splitlines()) or 'failed'))
        return out

    def decode(self, module, older=False):
        """SMOL-V (or SPIR-V) -> SPIR-V bytes. older: data of Unity 2017 - 2019, whose SMOL-V
        streams are mostly of the format's older encoding (both are tried)."""
        return self._request('d', 1 if older else 0, module)

    def compile(self, spirv_bytes, es=300):
        """SPIR-V -> GLSL ES text (es 300 or 310)."""
        return self._request('c', es, spirv_bytes).decode('utf-8')


# ---------------------------------------------------------------- naming

class _Block:
    """One uniform block of a stage: its variable, struct type, Unity constant buffer, members."""

    def __init__(self, var, struct_id, cb, members, globals_):
        self.var, self.struct_id, self.cb, self.members, self.globals = var, struct_id, cb, members, globals_


def _vec_shape(m, tid):
    """(base kind, components, array length or 0) of a member type: scalars, vectors and arrays of them."""
    t = m.types[tid]
    n = 0
    if t.kind == 'array':
        n = m.array_length(t) or 0
        t = m.types[t.elem]
    if t.kind == 'vector':
        return m.types[t.elem].kind, t.count, n
    if t.kind in ('float', 'int', 'bool'):
        return t.kind, 1, n
    return t.kind, 0, n


def _member_name(m, block_struct, k, mt, p, where):
    """The GLSL name of a constant buffer member (Unity's param p), checked against the SPIR-V type."""
    kind, comps, n = _vec_shape(m, mt)
    if kind == 'matrix':
        raise Unsupported(f'{where}: matrix member {p.name if p else k} (SPIR-V not from HLSLcc, e.g. DXC)')
    if p is None:
        return None
    # (Unity's array size is the part the program reads: unity_WorldToShadow[4] of one cascade is 1)
    if p.is_matrix:
        want = p.cols * max(p.array, 1)
        if comps != 4 or n < want or n % p.cols:
            raise Unsupported(f'{where}: matrix {p.name}: SPIR-V member {m.describe(mt)}, expected vec4[{want}]')
        return f'hlslcc_mtx{p.rows}x{p.cols}{p.name}'
    if comps != p.cols or (p.array > 1 and n < p.array):
        raise Unsupported(f'{where}: {p.name}: SPIR-V member {m.describe(mt)}, Unity says {p.cols} components '
                          f'x {p.array or 1}')
    return p.name


class Plan:
    """What the program's stages are named by (one per program): textures' units, blocks' bindings."""

    def __init__(self, bindings, serializer):
        self.b = bindings
        self.serializer = serializer
        self.cb_at = {x.index & 0xffffff: x.name for x in bindings.bindings if x.kind == dxbc.Binding.KIND_CBUFFER}
        self.cbs = {cb.name: cb for cb in bindings.cbuffers}
        self.tex_at = {x.index & 0xffffff: x for x in bindings.bindings if x.kind == dxbc.Binding.KIND_TEXTURE}
        self.sampler_at = {}
        for x in bindings.bindings:
            if x.kind == dxbc.Binding.KIND_TEXTURE and x.sampler is not None and x.sampler >= 0:
                self.sampler_at.setdefault(x.sampler & 0xffffff, 'sampler' + x.name)
        for x in bindings.bindings:
            if x.kind == dxbc.Binding.KIND_SAMPLER:
                self.sampler_at.setdefault(x.index & 0xffffff, f'sampler_inline{x.index & 0xffff}')
        self.packed = serializer is None or serializer >= dxbc.PACKED_TEXTURE_FROM
        self.loc_channel = {}
        new = serializer is None or serializer >= NEW_CHANNELS_FROM
        names, base = (CHANNELS, ATTRIB_BASE) if new else (CHANNELS_2017, ATTRIB_BASE_2017)
        for src, target in bindings.channels:
            if 0 <= src < len(names):
                self.loc_channel[target - base] = names[src]

    def paired(self, x):
        """2017.x: a texture sampled with a comparison sampler and a plain one is two combined
        samplers at consecutive bindings, the binding info naming the first only."""
        return not self.packed


def name_stage(m, plan, stage):
    """Gives the stage's interface and resources their GL names (in the module). Returns
    {'blocks': [_Block], 'images': {name}, 'varyings': {location: (name, type)}}."""
    out = {'blocks': [], 'images': [], 'varyings': {}}
    where = stage
    # vertex inputs, varyings, fragment outputs
    if stage == 'VERTEX':
        for v in m.interface(S.SC_INPUT):
            loc = m.decoration(v, S.DEC_LOCATION)
            name = plan.loc_channel.get(loc)
            if name is None:
                raise Unsupported(f'{where}: vertex input at location {loc} has no vertex channel')
            m.set_name(v, name)
    for v in m.interface(S.SC_OUTPUT if stage == 'VERTEX' else S.SC_INPUT):
        loc = m.decoration(v, S.DEC_LOCATION)
        if loc is None:
            raise Unsupported(f'{where}: varying without a location')
        comp = m.decoration(v, S.DEC_COMPONENT)
        name = f'vs_LOCATION{loc}' + (f'_{comp}' if comp else '')
        m.set_name(v, name)
        t, _ = m.pointee(v)
        out['varyings'][(loc, comp or 0)] = (name, m.describe(t.id), _interp(m, v))
    if stage == 'FRAGMENT':
        for v in m.interface(S.SC_OUTPUT):
            loc = m.decoration(v, S.DEC_LOCATION, 0)
            if m.decoration(v, S.DEC_INDEX):
                raise Unsupported(f'{where}: dual-source blending output')
            m.set_name(v, f'SV_Target{loc}')
    # resources
    nblock = 0
    for v in m.globals(S.SC_UNIFORM, S.SC_UNIFORM_CONSTANT, S.SC_STORAGE_BUFFER, S.SC_PUSH_CONSTANT):
        t, sc = m.pointee(v)
        base = t
        while base.kind == 'array':
            base = m.types[base.elem]
        at = (m.decoration(v, S.DEC_DESCRIPTOR_SET, 0) << 16) | (m.decoration(v, S.DEC_BINDING, 0) or 0)
        if sc == S.SC_PUSH_CONSTANT:
            raise Unsupported(f'{where}: push constants')
        if sc == S.SC_STORAGE_BUFFER or (base.kind == 'struct' and m.decoration(base.id, S.DEC_BUFFER_BLOCK) is not None):
            raise Unsupported(f'{where}: storage buffer')
        if base.kind == 'struct':
            if base is not t:
                raise Unsupported(f'{where}: array of uniform blocks')
            cbname = plan.cb_at.get(at)
            cb = plan.cbs.get(cbname)
            if cb is None:
                raise Unsupported(f'{where}: uniform block at set {at >> 16} binding {at & 0xffff} not in the binding info')
            if cb.structs:
                raise Unsupported(f'{where}: constant buffer {cbname!r} has struct members (GPU instancing data)')
            by_off = {p.offset: p for p in cb.params}
            members = []
            for k, mt in enumerate(t.members):
                off = m.member_decoration(t.id, k, S.DEC_OFFSET)
                name = _member_name(m, t.id, k, mt, by_off.get(off), f'{where}: {cbname}')
                if name is None:
                    name = f'Xhlslcc_UnusedX_{cbname}_{off}'     # (block members share one namespace)
                m.set_member_name(t.id, k, name)
                members.append((k, off, name, mt))
            g = is_globals(cbname)
            m.set_name(t.id, f'PMUNITY_GLOBALS{nblock}' if g else cbname)
            m.set_name(v, f'PMUNITY_CB{nblock}')
            nblock += 1
            out['blocks'].append(_Block(v, t.id, cb, members, g))
        elif base.kind == 'image':
            if base.dim == 6:
                raise Unsupported(f'{where}: subpass input (framebuffer fetch)')
            if base.dim == 5:
                raise Unsupported(f'{where}: texel buffer')
            if base.sampled == 2:
                raise Unsupported(f'{where}: storage image (UAV)')
            x = plan.tex_at.get(at)
            if x is None:
                raise Unsupported(f'{where}: texture at set {at >> 16} binding {at & 0xffff} not in the binding info')
            if base is not t:
                raise Unsupported(f'{where}: texture array {x.name}')
            m.set_name(v, x.name)
            out['images'].append(x.name)
        elif base.kind == 'sampled_image':
            x = plan.tex_at.get(at)
            pair = plan.tex_at.get(at - 1)
            if x is None and pair is not None and plan.paired(pair):
                # 2017.x: a texture compared and sampled has its plain twin at the next binding
                m.set_name(v, pair.name + '_PMPAIR')
                continue
            if x is None:
                raise Unsupported(f'{where}: texture at set {at >> 16} binding {at & 0xffff} not in the binding info')
            m.set_name(v, x.name)
            out['images'].append(x.name)
        elif base.kind == 'sampler':
            m.set_name(v, plan.sampler_at.get(at, f'sampler_{at >> 16}_{at & 0xffff}'))
        else:
            raise Unsupported(f'{where}: uniform of type {base.kind}')
    return out


def _interp(m, v):
    return tuple(q for q, d in (('flat', S.DEC_FLAT), ('noperspective', S.DEC_NOPERSPECTIVE),
                                ('centroid', S.DEC_CENTROID), ('sample', S.DEC_SAMPLE))
                 if m.decoration(v, d) is not None)


# ---------------------------------------------------------------- SPIRV-Cross's GLSL -> Unity's GL form

_FLIP_Y = re.compile(r'^[ \t]*gl_Position\.y = -gl_Position\.y;[ \t]*\n', re.M)
_BLOCK_DECL = r'^(?:layout\([^)]*\)\s*)?uniform (\w+)\n\{\n(.*?)\n\} (PMUNITY_CB\d+);\n'
_MEMBER_LINE = re.compile(r'^\s*((?:(?:highp|mediump|lowp)\s+)?\w+)\s+(\w+)((?:\[\d+\])?);\s*$')
_SAMPLER_DECL = re.compile(r'^uniform\s+((?:(?:highp|mediump|lowp)\s+)?)(\w*sampler\w+)\s+(\w+);\n', re.M)
_HEADER_END = re.compile(r'\A(#version[^\n]*\n(?:#extension[^\n]*\n|#if[^\n]*\n|#endif[^\n]*\n|#define[^\n]*\n|#else[^\n]*\n|'
                         r'precision[^\n]*\n|\s*\n)*)')
UNIFORM_LOCATION_BLOCK = ('#define UNITY_SUPPORTS_UNIFORM_LOCATION 1\n#if UNITY_SUPPORTS_UNIFORM_LOCATION\n'
                          '#define UNITY_LOCATION(x) layout(location = x)\n#define UNITY_BINDING(x) layout(binding = x, std140)\n'
                          '#else\n#define UNITY_LOCATION(x)\n#define UNITY_BINDING(x) layout(std140)\n#endif\n')


def _flatten_blocks(src, flatten_named):
    """The PMUNITY_CB<n> blocks of a stage: globals (and up to 2018 all) as plain uniforms (only
    those the stage reads), the others as unnamed-instance blocks. Returns (src, [(block name,
    member lines)])."""
    named = []
    for mm in list(re.finditer(_BLOCK_DECL, src, re.M | re.S)):
        tname, body, inst = mm.group(1), mm.group(2), mm.group(3)
        lines = [l for l in body.split('\n') if l.strip()]
        rest = src.replace(mm.group(0), '')
        if tname.startswith('PMUNITY_GLOBALS') or flatten_named:
            decls = []
            for l in lines:
                ml = _MEMBER_LINE.match(l)
                if not ml:
                    raise Unsupported(f'uniform block member {l.strip()!r}')
                if re.search(r'\b%s\.%s\b' % (inst, ml.group(2)), rest):
                    if ml.group(2).startswith('Xhlslcc_UnusedX'):
                        raise Unsupported(f'a uniform the binding info does not name is read ({ml.group(2)[16:]})')
                    decls.append(f'uniform {ml.group(1)} {ml.group(2)}{ml.group(3)};\n')
            src = src.replace(mm.group(0), ''.join(decls))
        else:
            named.append((tname, lines))
            src = src.replace(mm.group(0), f'@@BLOCK {tname}@@\n')
        src = re.sub(r'\b%s\.' % inst, '', src)
    return src, named


def _write_blocks(src, named, binding_of, macros):
    for tname, lines in named:
        body = ''.join('\t' + l.strip() + '\n' for l in lines)
        head = f'UNITY_BINDING({binding_of[tname]}) uniform {tname} {{\n' if macros else f'layout(std140) uniform {tname} {{\n'
        src = src.replace(f'@@BLOCK {tname}@@\n', head + body + '};\n')
    return src


def _samplers(src, precision):
    """Combined samplers as Unity's GL programs name them: comparison ones hlslcc_zcmp<name>, after
    the texture's plain sampler (HLSLcc declares both; Unity's backend sets them to the texture's
    unit: one is added where the stage only compares), the second sampler of a texture
    (<name>_PMSAMPLER<n>) the texture's own, a 2017.x texture's second binding (<name>_PMPAIR,
    the plain or comparison twin of the texture) the texture. Returns (src, the sampler uniforms
    in declaration order)."""
    for mm in list(_SAMPLER_DECL.finditer(src)):
        prec, typ, name = mm.groups()
        base = re.sub(r'_PMSAMPLER\d+$', '', name)
        if base != name:
            # GL has one sampler state per texture: the texture's own (Unity binds no other)
            others = [m2 for m2 in _SAMPLER_DECL.finditer(src) if m2.group(3) == base]
            if not others or others[0].group(2) != typ:
                raise Unsupported(f'texture {base} sampled with two samplers of different kinds')
            src = src.replace(mm.group(0), '')
            src = re.sub(r'\b%s\b' % name, base, src)
    found = [mm.groups() for mm in _SAMPLER_DECL.finditer(src)]
    final = {}
    for prec, typ, name in found:
        base = name[:-len('_PMPAIR')] if name.endswith('_PMPAIR') else name
        final[name] = ('hlslcc_zcmp' if 'Shadow' in typ else '') + base
    if len(set(final.values())) != len(final):
        raise Unsupported('a texture declared twice with the same kind of sampler')
    plain = {final[n] for _, t, n in found if 'Shadow' not in t}
    decls, texts = [], []
    for k, (prec, typ, name) in enumerate(found):
        gl = final[name]
        p = '' if precision != 'highp' and typ in ('sampler2D', 'samplerCube') else prec
        decl = f'uniform {p}{typ} {gl};\n'
        if gl.startswith('hlslcc_zcmp') and gl[len('hlslcc_zcmp'):] not in plain:
            ptyp, pn = typ.replace('Shadow', ''), gl[len('hlslcc_zcmp'):]
            pp = '' if precision != 'highp' and ptyp in ('sampler2D', 'samplerCube') else prec
            decl = f'uniform {pp}{ptyp} {pn};\n' + decl
            decls.append(pn)
            plain.add(pn)
        decls.append(gl)
        texts.append(decl)
        src = re.sub(r'^uniform\s+(?:(?:highp|mediump|lowp)\s+)?%s\s+%s;\n' % (typ, name), f'@@SAMPLER{k}@@\n', src, count=1,
                     flags=re.M)
    renamed = [(k, name) for k, (_, _, name) in enumerate(found) if final[name] != name]
    for k, name in renamed:                 # (through placeholders: X -> hlslcc_zcmpX and X_PMPAIR -> X)
        src = re.sub(r'\b%s\b' % name, f'@@NAME{k}@@', src)
    for k, name in renamed:
        src = src.replace(f'@@NAME{k}@@', final[name])
    for k, decl in enumerate(texts):
        src = src.replace(f'@@SAMPLER{k}@@\n', decl)
    return src, decls


def _locations(src, units):
    """Each sampler uniform with its location in Unity's macro (UNITY_LOCATION(n)), from units."""
    def at(mm):
        return f'UNITY_LOCATION({units[mm.group(3)]}) ' + mm.group(0)
    return _SAMPLER_DECL.sub(at, src)


def _check_es(src, stage, es):
    """GLSL with no ES equivalent (glsl.py's rules); NeedsES31 where an ES 3.00 stage uses ES 3.10's."""
    code = glsl._code_lines(glsl._strip_comments(src))
    rules = glsl._UNSUPPORTED if es == 300 else [r for r in glsl._UNSUPPORTED_4X]
    for rx, what in rules:
        mm = rx.search(code)
        if mm and not (what == 'ES 3.2+ / desktop function' and es == 310 and mm.group(1) in ('imageLoad', 'imageStore')):
            raise Unsupported(f'{stage}: {what} {mm.group(0).strip()!r}')
    if '#extension GL_NV_shader_noperspective_interpolation' in src:
        raise Unsupported(f'{stage}: qualifier noperspective (GL_NV_shader_noperspective_interpolation)')
    if es == 300:
        for rx, what in glsl._ES31:
            mm = rx.search(code)
            if mm:
                raise glsl.NeedsES31(f'{stage}: {what} {mm.group(0).strip()!r} (GLSL ES 3.10)')


def translate_program(translator, code, bindings, serializer=None, unity=None, precision='highp', notes=None):
    """One Vulkan entry (code, its dxbc.Bindings with the parameter entry and shared parameters
    put back) -> (GL program text, GPU program type: GLES3 or GLES31). unity: (major, minor) of the
    data (2019.1+: Unity's macro blocks, texture units, uniform blocks; before: plain uniforms).
    The vertex stage's full-screen texture coordinates get GL's origin (uv_origin; notes, a list:
    'VERTEX uv-origin <n>' where it changed anything). Raises Unsupported."""
    unity = unity or dxbc.unity_line(serializer)
    macros = unity >= (2019, 1)
    _, mods = split_code(code)
    plan = Plan(bindings, serializer)
    stages = {}
    for slot, data in mods:
        try:
            m = S.Module(translator.decode(data, unity < (2020, 1)))
        except S.SpirvError as ex:
            raise Unsupported(f'stage {slot}: {ex}')
        st = m.stage
        if st not in ('VERTEX', 'FRAGMENT'):
            raise Unsupported(f'{st or "unknown"} stage (not in GLSL ES 3.00)')
        if st in stages:
            raise Unsupported(f'two {st} stages')
        if m.source_language == 5:
            raise Unsupported(f'{st}: SPIR-V compiled from HLSL (DXC): not translated')
        # HLSL's ddx_fine / ddy_coarse: GLSL ES has one kind of derivative (dFdx, as HLSLcc writes them for GL)
        if m.replace_opcodes(_DERIVATIVES):
            m.remove_capability(S.CAP_DERIVATIVE_CONTROL)
        stages[st] = m
    if set(stages) != {'VERTEX', 'FRAGMENT'}:
        raise Unsupported('expected a vertex and a fragment stage, got ' + ', '.join(sorted(stages)))
    named = {st: name_stage(m, plan, st) for st, m in stages.items()}
    # varyings: the fragment's inputs must be vertex outputs of the same type in GLSL ES
    vout, fin = named['VERTEX']['varyings'], named['FRAGMENT']['varyings']
    widen = {}
    for key, (name, typ, interp) in fin.items():
        if key not in vout:
            raise Unsupported(f'fragment input at location {key[0]} is not written by the vertex stage')
        vtyp, vinterp = vout[key][1], vout[key][2]
        if vinterp != interp:
            raise Unsupported(f'varying at location {key[0]}: interpolation {vinterp} / {interp}')
        if vtyp != typ:
            if not re.match(r'^(?:[iub]?vec[234]|float|int|uint|bool)$', vtyp) or _ncomp(typ) >= _ncomp(vtyp) or \
                    _base(typ) != _base(vtyp):
                raise Unsupported(f'varying at location {key[0]}: {vtyp} written, {typ} read')
            widen[name] = (vtyp, 'xyzw'[:_ncomp(typ)])
    # block bindings (program-wide, in order)
    blocks = []
    for st in ('VERTEX', 'FRAGMENT'):
        for bl in named[st]['blocks']:
            if not bl.globals and bl.cb.name not in blocks:
                blocks.append(bl.cb.name)
    binding_of = {n: i for i, n in enumerate(blocks)}
    flatten_named = not macros

    def compile_all(es):
        texts, decls = {}, {}
        for st, m in stages.items():
            src = translator.compile(m.serialize(), es)
            if st == 'VERTEX':
                # (Unity flips before every return of the vertex stage: one at the end, one per early return)
                src, n = _FLIP_Y.subn('', src)
                if not n:
                    raise Unsupported('VERTEX: no Vulkan clip-space y flip')
            src, named_blocks = _flatten_blocks(src, flatten_named)
            src = _write_blocks(src, named_blocks, binding_of, macros)
            src, decls[st] = _samplers(src, precision)
            if st == 'FRAGMENT':
                for name, (vtyp, swz) in widen.items():
                    decl = re.compile(r'^((?:(?:flat|centroid|smooth)\s+)*in\s+(?:(?:highp|mediump|lowp)\s+)?)\w+(\s+%s;)$' % name, re.M)
                    src, n = decl.subn(lambda mm: mm.group(1) + vtyp + mm.group(2), src)
                    if n != 1:
                        raise Unsupported(f'FRAGMENT: input {name} not found')
                    head, body = src.split('void main()', 1) if 'void main()' in src else (src, '')
                    body = re.sub(r'\b%s\b' % name, f'{name}.{swz}', body)
                    src = head + 'void main()' + body
            texts[st] = src
        # sampler locations: program-wide, the fragment stage's first (HLSLcc translates it first)
        units = {}
        for st in ('FRAGMENT', 'VERTEX'):
            for n in decls[st]:
                units.setdefault(n, len(units))
        for st, src in texts.items():
            if macros:
                src = _locations(src, units)
                hm = _HEADER_END.match(src)
                src = src[:hm.end()] + UNIFORM_LOCATION_BLOCK + src[hm.end():]
            _check_es(src, st, es)
            texts[st] = src
        return texts
    try:
        texts, typ = compile_all(300), 4
    except glsl.NeedsES31:
        texts, typ = compile_all(310), 3
    except Unsupported as ex:
        if 'ESSL 310' not in str(ex) and 'ES 3.1' not in str(ex) and '310' not in str(ex):
            raise
        texts, typ = compile_all(310), 3
    texts['VERTEX'], flips = uv_origin(texts['VERTEX'])
    if flips and notes is not None:
        notes.append(f'VERTEX uv-origin {flips}')
    return ''.join(f'#ifdef {st}\n{texts[st]}\n#endif\n' for st in ('VERTEX', 'FRAGMENT')), typ


def _ncomp(t):
    m = re.match(r'^[iub]?vec(\d)$', t)
    return int(m.group(1)) if m else 1


def _base(t):
    return {'i': 'int', 'u': 'uint', 'b': 'bool'}.get(t[0], 'float') if 'vec' in t else t


# ---------------------------------------------------------------- Shader assets

def _vk_lists(tree):
    """(pass, stage, subprogram list, parameter indices or None) of the shader's lists."""
    from .convert import subprogram_lists
    return list(subprogram_lists(tree))


def vulkan_indices(tree):
    """(program entry indices, parameter entry indices) the Vulkan subprograms name."""
    progs, params = set(), set()
    for _, _, lst, pbi in _vk_lists(tree):
        for i, sp in enumerate(lst):
            if sp['m_GpuProgramType'] == GPU_SPIRV:
                progs.add(sp['m_BlobIndex'])
                if pbi is not None:
                    params.add(pbi[i])
    return progs, params


def _vk_bindings(entry, param_entry, common, names):
    b = dxbc.entry_bindings(entry, param_entry, typed=True)        # (6000.6: its own layout)
    return dxbc.with_common(b, common, names)


def add_gles3_vulkan(tree, translator=None, precision='highp', replace=False, unity=None, translate=None):
    """Adds GLES3 programs translated from the shader's Vulkan ones (tree edited in place); a
    convert.Result (source 'vulkan').

    The GLES3 programs are stored as Unity stores GL programs of the data's version, which is also
    how its Vulkan programs are stored: up to 2019.x the GLES3 blob keeps the Vulkan blob's
    indices (vertex entries with the program, fragment entries without code; 2019.x the vertex
    entry and subprogram with the GL binding info, dxbc.gl_bindings), from 2020.1 one subprogram
    per variant with entries numbered anew (2021.2+ with parameter entries, shared where equal),
    the Vulkan program's m_CommonParameters put back into its Vulkan entries and cleared.

    A SubShader with a variant that cannot be translated gets no GLES3 programs (Unity uses the
    next SubShader or the Fallback); VR-only, GPU instancing and sprite skinning variants that
    cannot be translated are left out instead, as for Direct3D 11 (convert.add_gles3_d3d11).
    translate: function(code bytes, dxbc.Bindings) -> (GL program text, gpu type), default
    translate_program with translator."""
    from . import blob as B
    from . import convert as C
    name = tree['m_ParsedForm']['m_Name']
    r = C.Result(name)
    r.source = 'vulkan'
    plats = list(tree['platforms'])
    if B.PLATFORM_VULKAN not in plats:
        r.why = 'no Vulkan programs'
        return r
    if B.PLATFORM_GLES3PLUS in plats:
        if not replace:
            r.why = 'already has GLES3 programs'
            return r
        C._strip_gles(tree)
        r.status, r.why = 'converted', '(old GLES programs removed)'
    blobs = B.ShaderBlobs(tree)
    progs, params = vulkan_indices(tree)
    entries = blobs.entries(B.PLATFORM_VULKAN, params, progs)
    serializer = next((e.version for e in entries if isinstance(e, B.Entry)), None)
    line = C.unity_of(tree, unity)
    if serializer is not None and line < dxbc.unity_line(serializer):
        line = dxbc.unity_line(serializer)
    if not progs and line >= (2018, 1):
        stages = 1 if blobs.stage_counts is not None else None
        blobs.set_entries(B.PLATFORM_GLES3PLUS, [], [] if blobs.nested else None, stages)
        blobs.store()
        r.status, r.empty = 'converted', True
        r.why = ('no programs (every variant stripped): an empty GLES3 blob ' + r.why).strip()
        return r
    gl_info = line >= (2019, 1)
    compact = line >= (2020, 1)
    # parameters in entries of their own (2021.2+ m_PlayerSubPrograms; 2021.2's first patches still
    # list m_SubPrograms with the parameters in the program entries; 6000.6 in its own layout)
    separate = (serializer == dxbc.SEPARATE_PARAMS_FROM or (serializer or 0) >= dxbc.TYPED_FROM) and \
        any(pbi is not None for *_, pbi in _vk_lists(tree))
    if translate is None:
        if translator is None:
            raise ValueError('add_gles3_vulkan needs a translator or a translate function')

        def translate(code, b):
            return translate_program(translator, code, b, serializer, line, precision, r.notes)
    cache = {}

    def program(key, e, b):
        """(ES text, GL Bindings or None, gpu type) of a Vulkan entry, or the Unsupported."""
        if key not in cache:
            try:
                r.guessed_layout |= e.guessed
                es, typ = translate(e.code, b)
                info = dxbc.gl_bindings(es, line, b.source_map, typed=b.typed) if gl_info else None
                cache[key] = (es, info, B.GPU_GLES31 if typ == B.GPU_GLES31 else B.GPU_GLES3)
            except (Unsupported, dxbc.Unsupported, glsl.Unsupported) as ex:
                cache[key] = ex
        return cache[key]

    # plan: per SubShader the (pass, list, index, subprogram, program) to twin
    plan, no_instancing = [], set()
    for si, ss in enumerate(tree['m_ParsedForm']['m_SubShaders']):
        todo, why = [], None
        for pi_, p in enumerate(ss['m_Passes']):
            names = {i: n for n, i in p.get('m_NameIndices') or []}
            for st in ('progVertex', 'progFragment', 'progGeometry', 'progHull', 'progDomain'):
                prog = p.get(st)
                for lst, pbi in C._tier_lists(prog):
                    for j, sp in enumerate(lst):
                        if sp['m_GpuProgramType'] != GPU_SPIRV:
                            continue
                        e = entries[sp['m_BlobIndex']]
                        pidx = pbi[j] if pbi is not None else None
                        kws = (list(e.keywords) + list(e.local_keywords or [])) if isinstance(e, B.Entry) else []
                        res = None
                        if st in ('progGeometry', 'progHull', 'progDomain'):
                            err = 'geometry or tessellation stage (not in GLSL ES 3.00)'
                        elif not isinstance(e, B.Entry):
                            err = 'no program entry'
                        elif not e.code:
                            err = None if st == 'progFragment' and not compact else 'empty program entry'
                        else:
                            err = None
                            try:
                                pe = entries[pidx] if pidx is not None else None
                                if separate and not isinstance(pe, B.ParamEntry):
                                    raise dxbc.Unsupported('no parameter entry')
                                b = _vk_bindings(e, pe, prog.get('m_CommonParameters'), names)
                            except dxbc.Unsupported as ex:
                                err = str(ex)
                            if err is None:
                                res = program((sp['m_BlobIndex'], pidx), e, b)
                                err = str(res) if isinstance(res, Exception) else None
                        if err is None:
                            todo.append((p, st, lst, pbi, j, sp, res))
                        elif any(k in C.VR_KEYWORDS for k in kws):
                            r.dropped += 1
                        elif any(k in C.INSTANCING_KEYWORDS for k in kws):
                            r.dropped_instancing += 1
                            no_instancing.add(id(p))
                        elif any(k in C.SKINNING_KEYWORDS for k in kws):
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
                 else 'no Vulkan vertex/fragment programs')
        r.changed = bool(replace and B.PLATFORM_GLES3PLUS in plats)
        return r

    twins = []                              # (list, parameter index list or None, twin, parameter index)
    if not compact:
        # the GLES3 blob keeps the Vulkan blob's indices: entries without code where nothing GL uses them
        out = [None if not isinstance(e, B.Entry) else
               B.Entry(e.version, B.GPU_GLES3, [0] * len(e.stats), e.keywords, b'', dxbc.gl_rest(0), e.local_keywords)
               for e in entries]
        raised = {}                         # (pass, variant key) -> gpu type of the variant's vertex program
        for si, todo in plan:
            for p, st, lst, pbi, j, sp, res in todo:
                if res is not None:
                    es, info, typ = res
                    i = sp['m_BlobIndex']
                    e = entries[i]
                    if not out[i].code:
                        rest = info.serialize() if info is not None else dxbc.gl_rest(_source_map(e))
                        out[i] = B.Entry(e.version, typ, [0] * len(e.stats), e.keywords, es.encode('utf-8'), rest,
                                         e.local_keywords)
                        r.programs += 1
                        r.es31 += typ == B.GPU_GLES31
                    raised[(id(p), C._variant_key(sp))] = typ
        for si, todo in plan:
            for p, st, lst, pbi, j, sp, res in todo:
                typ = raised.get((id(p), C._variant_key(sp)), B.GPU_GLES3)
                if res is None and typ == B.GPU_GLES31:
                    out[sp['m_BlobIndex']].gpu_type = typ
                info = res[1] if res is not None and gl_info else None
                names = C._name_indices(p, C._gl_names(info)) if info is not None else None
                twins.append((lst, None, C.gl_twin(sp, sp['m_BlobIndex'], info, names, typ), None))
        segs = blobs.segments(B.PLATFORM_VULKAN) if blobs.nested else None
        blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs)
    else:
        out, segs = [], []
        vk_segs = blobs.segments(B.PLATFORM_VULKAN) if blobs.nested else [0] * len(entries)
        code_at, param_at = {}, {}
        for si, todo in plan:
            for p, st, lst, pbi, j, sp, (es, info, typ) in todo:
                i = sp['m_BlobIndex']
                pidx = pbi[j] if pbi is not None else None
                e = entries[i]
                key = (i, pidx)
                if key not in code_at:
                    code_at[key] = len(out)
                    out.append(B.Entry(e.version, typ, [0] * len(e.stats), e.keywords, es.encode('utf-8'),
                                       info.head() if separate else info.serialize(), e.local_keywords))
                    segs.append(vk_segs[i])
                    r.programs += 1
                    r.es31 += typ == B.GPU_GLES31
                gp = None
                if separate:
                    data = info.params_bytes()
                    if data not in param_at:
                        param_at[data] = len(out)
                        out.append(B.ParamEntry(e.version, data))
                        segs.append(vk_segs[i])
                    gp = param_at[data]
                twins.append((lst, pbi, C.gl_twin(sp, code_at[key], gpu_type=typ), gp))
        _restore_common(tree, plan, entries, blobs, separate)
        blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs if blobs.nested else None,
                          1 if blobs.stage_counts is not None else None)
    blobs.store()
    seen = set()
    for lst, pbi, tw, gp in twins:
        key = (id(lst), tw['m_BlobIndex'], C._variant_key(tw))
        if key in seen:
            continue
        seen.add(key)
        lst.append(tw)
        if pbi is not None:
            pbi.append(gp)
        r.twins += 1
    for si, todo in plan:
        for p, *_ in todo:
            C.add_platform(p, B.PLATFORM_GLES3PLUS)
            if id(p) in no_instancing:
                for f in ('m_HasInstancingVariant', 'm_HasProceduralInstancingVariant'):
                    if f in p:
                        p[f] = False
    r.status = 'converted'
    if r.failed:
        r.why = (r.why + ' ' if r.why else '') + '; '.join(f'SubShader {si} left out: {w}' for si, w in r.failed)
    return r


def _source_map(e):
    return struct.unpack_from('<i', e.rest)[0] if len(e.rest) >= 4 else 0


def _restore_common(tree, plan, entries, blobs, separate):
    """2020.1+: a program given GLES3 subprograms gets its m_CommonParameters (what its Vulkan
    subprograms share; the player adds them to every subprogram of the program, ours too) put back
    into its Vulkan entries (2021.2+: parameter entries), and cleared (as convert._restore_common
    for Direct3D 11)."""
    from . import blob as B
    from . import convert as C
    progs = {}
    for si, todo in plan:
        for p, st, *_ in todo:
            progs[(id(p), st)] = (p, p[st])
    changed = False
    for p, prog in progs.values():
        common = prog.get('m_CommonParameters')
        if not common or not any(isinstance(v, list) and v for v in common.values()):
            continue
        names = {i: n for n, i in p.get('m_NameIndices') or []}
        done = set()
        for lst, pbi in C._tier_lists(prog):
            for j, sp in enumerate(lst):
                if sp['m_GpuProgramType'] != GPU_SPIRV:
                    continue
                pi = pbi[j] if pbi is not None else None
                at = pi if separate else sp['m_BlobIndex']
                if at in done:
                    continue
                done.add(at)
                e = entries[sp['m_BlobIndex']]
                pe = entries[pi] if pi is not None else None
                try:
                    b = _vk_bindings(e, pe, common, names)
                except dxbc.Unsupported:
                    continue
                if separate:
                    entries[pi] = B.ParamEntry(pe.version, b.params_bytes())
                else:
                    entries[at] = B.Entry(e.version, e.gpu_type, e.stats, e.keywords, e.code, b.serialize(), e.local_keywords)
                changed = True
        C._clear_common(prog)
    if changed:
        blobs.set_entries(B.PLATFORM_VULKAN, entries, blobs.segments(B.PLATFORM_VULKAN) if blobs.nested else None)


# ---------------------------------------------------------------- full-screen texture coordinates

_DECL_TYPE = r'(?:(?:const\s+)?(?:(?:highp|mediump|lowp)\s+)?(?:float|int|uint|bool|[iub]?vec[234])\s+)?'
_STMT = re.compile(r'^(\s*)(' + _DECL_TYPE + r')(\w+)(?:\.([xyzw]+))?\s*([-+]?=)\s*(.+?);\s*$')
_OPER = re.compile(r'^(\w+)(?:\.([xyzw]+))?$')
_VERTEX_ID = re.compile(r'^(?:u?int\()?(?:uint\(gl_VertexID\)|gl_VertexID)\)?$')
_FLIP = re.compile(r'^\(?-(\w+(?:\.[xyzw]+)?)\)?\s*\+\s*(?:1\.0|vec[234]\((?:1\.0,\s*)*1\.0\))$')


def _strip_parens(s):
    s = s.strip()
    while s.startswith('(') and s.endswith(')') and _closing(s, 0) == len(s) - 1:
        s = s[1:-1].strip()
    return s


def _closing(s, i):
    depth = 0
    for j in range(i, len(s)):
        depth += s[j] == '('
        depth -= s[j] == ')'
        if depth == 0:
            return j
    return -1


def _top_split(s, sep):
    """s split at sep outside parentheses (sep: one character)."""
    out, depth, cur = [], 0, ''
    for ch in s:
        depth += ch == '('
        depth -= ch == ')'
        if ch == sep and depth == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    return out + [cur]


def uv_origin(vs):
    """The vertex stage of a program from Vulkan (SPIRV-Cross's GLSL) or Metal (metal.py's) with the
    texture coordinate flips of the SRP core library's full-screen triangle and quad undone, as
    dxbc.gl_uv_origin does for Direct3D 11 (docs/shaders.md): Vulkan and Metal have Direct3D's
    top-left texture origin (UNITY_UV_STARTS_AT_TOP), GL does not, and URP's C# side asks the
    running API. GetFullScreenTriangleTexCoord's v = 1 - (id & 2) and GetQuadTexCoord's
    v = 1 - ((id >> 1) + (id & 1)) & 1 are traced from gl_VertexID through the stage's temporaries
    (declarations, swizzles, constructors, `+=`); `t = (-v) + 1.0;` becomes `t = v;`. Shader
    Graph's `_FlipY < 0.5` becomes false. Returns (text, flips undone)."""
    if 'gl_VertexID' not in vs:
        return vs, 0
    tags = {}

    def operand(s):
        m = _OPER.match(s.strip())
        if not m:
            return None
        var, swz = m.groups()
        if swz:
            return [tags.get((var, c)) for c in swz]
        return [tags.get((var, ''), tags.get((var, 'x')))]

    def value(rhs):
        r = _strip_parens(rhs)
        if _VERTEX_ID.match(r):
            return ['id']
        m = re.match(r'^(u?int|float|vec[234]|[iu]vec[234])\((.*)\)$', r)
        if m and _closing(r, len(m.group(1))) == len(r) - 1:
            args = [value(a) for a in _top_split(m.group(2), ',')]
            if any(a is None for a in args):
                return None
            flat = [x for a in args for x in a]
            if m.group(1) in ('int', 'uint') or m.group(1).startswith(('ivec', 'uvec')):
                return flat
            return [x if x in ('tri.f', 'quad.f') else {'tri': 'tri.f', 'quad': 'quad.f'}.get(x) for x in flat]
        parts = _top_split(r, '+')
        if len(parts) == 2:
            fm = _FLIP.match(r)
            if fm:
                t = operand(fm.group(1))
                if t and all(x in ('tri.f', 'quad.f') for x in t):
                    return ['flip'] * len(t)
            a, b = value(parts[0]), value(parts[1])
            if a and b and len(a) == len(b) == 1 and {a[0], b[0]} == {'top', 'bot'}:
                return ['sum']
            return None
        parts = _top_split(r, '&')
        if len(parts) == 2 and re.match(r'^\s*(?:0x)?[12]u?\s*$', parts[1]):
            a = value(parts[0])
            k = int(parts[1].strip().rstrip('u'), 0)
            if a and len(a) == 1:
                return [{('id', 2): 'tri', ('id', 1): 'bot', ('sum', 1): 'quad'}.get((a[0], k))]
            return None
        m = re.match(r'^(.*)>>\s*1u?$', r)
        if m:
            a = value(m.group(1))
            return ['top'] if a == ['id'] else None
        if re.match(r'^-?\d', r):
            return [None]
        return operand(r)

    n = 0
    out = []
    for line in vs.split('\n'):
        m = _STMT.match(line)
        if m and not line.lstrip().startswith('#'):
            ind, decl, var, swz, op, rhs = m.groups()
            v = value(f'{var}{"." + swz if swz else ""} + {rhs}' if op == '+=' else rhs) if op != '-=' else None
            if v and v[0] == 'flip':
                src = _FLIP.match(_strip_parens(rhs)).group(1)
                line = f'{ind}{decl}{var}{"." + swz if swz else ""} = {src};'
                v = operand(src)
                n += 1
            keys = [(var, c) for c in swz] if swz else None
            if keys is None:
                keys = [(var, '')] if not v or len(v) == 1 else [(var, c) for c in 'xyzw'[:len(v)]]
                for c in 'xyzw':
                    tags.pop((var, c), None)
                tags.pop((var, ''), None)
            if v is not None and len(v) == 1 and len(keys) > 1:
                v = v * len(keys)
            for i, k in enumerate(keys):
                tags[k] = v[i] if v is not None and i < len(v) else None
        out.append(line)
    text = '\n'.join(out)
    if re.search(r'^\s*uniform\s+(?:highp\s+|mediump\s+)?float\s+_FlipY\s*;', text, re.M):
        text, k = re.subn(r'\b_FlipY\s*<\s*0\.5\b', 'false', text)
        n += k
    return text, n
