"""Direct3D 11 programs (DXBC) of Unity Shader assets -> GL programs, with Unity's HLSLcc.

A Windows build's shaders carry only Direct3D 11 programs (platform blob 4). One D3D11 blob
entry (blob.Entry) holds one stage:

  code   Unity's header, then the DXBC container (fxc's output). The header is 6 bytes up to Unity
         2019.3 (1, then counts of the slots Unity's D3D11 renderer binds: textures, constant
         buffers, samplers, 2 more) and 38 from 2019.4 (2, then the same counts and more); kept
         as it is, not needed for GL.
  rest   Unity's binding info. Unity strips the container's reflection chunk (RDEF: constant
         buffer layouts, resource names) in builds and keeps what it needs here instead:

           int32 source map                       vertex channels read (bit per ShaderChannel)
           int32 n; n x (int32 source, int32 target)                 vertex inputs
           int32 n; n x constant buffer           the first one (name '', size 0) holds the
                                                  globals outside any cbuffer (none in D3D11)
               string name; int32 size
               int32 n; n x (string name, int32 type (0 float, 1 int, 5 uint), int32 rows,
                             int32 columns, int32 is matrix, int32 array size, int32 offset)
               int32 n; n x struct (GPU instancing data): string name, int32 offset, int32
                             array size, int32 size, int32 n; n x member as above
           int32 n; n x binding: string name, int32 kind, int32 index, then by kind:
               kind 0 texture:          up to 2018.1 int32 dimension (2 2D, 3 3D, 4 cube, 5 2D
                                        array, 6 cube array), int32 sampler index; from 2018.2
                                        int32 sampler index (-1: an inline sampler state),
                                        int32 dimension << 1 | multisampled
               kind 1 constant buffer:  int32 (0 in all data seen)
               kind 4 inline sampler:   int32 the sampler state (filter and wrap bits from its
                                        name, e.g. sampler_PointClamp), named '', index its register
               other kinds (buffers, UAVs) are refused
         (strings: int32 length, bytes, padded to 4). From Unity 2021.2 (serializer 202012090) the
         entry ends after the vertex inputs and the rest is a parameter entry of its own
         (blob.ParamEntry, named by the program's m_ParameterBlobIndices); from 2020.1 what all
         the subprograms of a program share is stored once, in the parsed form's
         m_CommonParameters, and left out of the entries (with_common() puts it back). Checked by
         writing every entry back byte for byte (Bindings.serialize) and against the
         SerializedSubProgram that uses the entry (check_parsed_form: Unity writes both from the
         same compile).

         Unity 6000.6 (serializer 202605290) writes the parameter entry otherwise (Bindings.parse
         with typed=True reads it; only the Vulkan path asks for it so far): each binding is
         Unity's Binding struct, (int32 encoded data, int32 slot), the slot what the index was
         (0 encoded data in all data seen), and the lists are by kind:
           int32 n; n x constant buffer: string name, int32 size,
               int32 n; n x vector (string name, int32 dimension | type << 16, int32 array size,
                                    int32 offset)
               int32 n; n x matrix (string name, int32 rows | type << 16, int32 array size,
                                    int32 offset; 4 columns)
               int32 n; n x struct: string name, int32 offset, int32 array size, int32 size,
                                    its vectors and matrices as above
           int32 n; n x texture: string name, binding, sampler binding (slot -1: an inline
                                 sampler state), int32 dimension << 1 | multisampled
           int32 n; n x UAV: string name, binding, original binding
           int32 n; n x constant buffer binding: string name, binding
           int32 n; n x buffer: string name, binding, 2 x int32 (1, 1 in all data seen)
           int32 n; n x inline sampler: binding, int32 the sampler state
         Read into the same Bindings (a binding's extra ints as the kind's before, its encoded
         data in enc) and written back in its own layout (Bindings.typed).

Only the names and constant buffer layouts are missing from the bytecode; registers, resource
types and sampler modes come from the declarations in the SHDR/SHEX chunk. with_reflection()
puts both back together as an RDEF chunk in the form HLSLcc reads (D3D11_SHADER_DESC tables:
resource bindings, constant buffers, variables, types, strings), so HLSLcc names every uniform,
texture and constant buffer as Unity's own GL programs do. It refuses what the binding info does
not describe (a register without a name, a constant buffer location an instruction reads that
no member covers) and resources GLSL ES 3.00 has no type for.

The stages are then translated by pmhlslcc (tools/hlslcc: HLSLcc with a small front end) the way
Unity's shader compiler does for OpenGL Core: GLSL 1.50, matrices as vec4 arrays
(hlslcc_mtx4x4<name>), vertex inputs in_<SEMANTIC><n>, varyings vs_<SEMANTIC><n>, outputs
SV_Target<n>, a GLSL sampler per texture named as the texture, every constant buffer member as a
plain uniform (Unity's GL backends bind uniforms by name). gl_program() joins the stages as
Unity stores a GL program (#ifdef VERTEX / #ifdef FRAGMENT blocks); glsl.py turns it into GLSL ES
3.00 as for a macOS/Linux build.

From Unity 2019.1 a GL program has binding info of its own: the loose uniforms of each stage as
a "$Globals" constant buffer with Unity's offsets, the uniform blocks, and the textures with their
units. gl_bindings() writes it from the GL program's text as Unity's GL compiler does (checked
byte for byte against every GLCore and GLES3 program of Unity's built-in resources 2019.4 -
2022.3 and of games of each line: tests/test_glcore_corpus.py, PMUNITY_GLCORE_BINDINGS).
"""
import os
import re
import shutil
import struct
import subprocess

from . import glsl


class Unsupported(Exception):
    """A program that this path cannot give a GL twin (the message says why)."""


# GPU program types (ShaderGpuProgramType, Unity 5.5 - 2022.3)
GPU_DX11_VS40, GPU_DX11_VS50, GPU_DX11_PS40, GPU_DX11_PS50 = 15, 16, 17, 18
GPU_DX11_GS40, GPU_DX11_GS50, GPU_DX11_HS50, GPU_DX11_DS50 = 19, 20, 21, 22
VERTEX_TYPES = (GPU_DX11_VS40, GPU_DX11_VS50)
PIXEL_TYPES = (GPU_DX11_PS40, GPU_DX11_PS50)
OTHER_STAGE_TYPES = (GPU_DX11_GS40, GPU_DX11_GS50, GPU_DX11_HS50, GPU_DX11_DS50)

HEADER_SIZE = 6                 # Unity's header before the DXBC container, up to 2019.3
HEADER_SIZES = (6, 38)          # 2019.4+: 38 bytes

# HLSLcc flags (include/hlslcc.h) for Unity's OpenGL Core style: constant buffer members as plain
# uniforms (no uniform blocks, no struct around $Globals), matrices as vec4 arrays; from Unity
# 2019.1 also explicit texture units in Unity's macro (UNITY_LOCATION(n), which the player turns
# off where the driver lacks explicit uniform locations)
HLSLCC_FLAG_DISABLE_GLOBALS_STRUCT = 0x800
HLSLCC_FLAG_TRANSLATE_MATRICES = 0x20000
HLSLCC_FLAG_FORCE_EXPLICIT_LOCATIONS = 0x8000000
FLAGS = HLSLCC_FLAG_TRANSLATE_MATRICES | HLSLCC_FLAG_DISABLE_GLOBALS_STRUCT
FLAGS_2019 = FLAGS | HLSLCC_FLAG_FORCE_EXPLICIT_LOCATIONS
LANG = '150'


def _pad4(n):
    return (n + 3) & ~3


# ---------------------------------------------------------------- Unity's binding info

class _Reader:
    def __init__(self, data):
        self.d, self.p = data, 0

    def i32(self):
        v, = struct.unpack_from('<i', self.d, self.p)
        self.p += 4
        return v

    def count(self, limit=4096):
        n = self.i32()
        if not 0 <= n <= limit:
            raise ValueError(f'count {n}')
        return n

    def string(self):
        n = self.count(1024)
        if self.p + n > len(self.d):
            raise ValueError('string past the end')
        s = bytes(self.d[self.p:self.p + n]).decode('ascii')
        self.p = _pad4(self.p + n)
        return s


def _wstr(s):
    b = s.encode('ascii')
    return struct.pack('<i', len(b)) + b + b'\0' * (_pad4(len(b)) - len(b))


class Param:
    __slots__ = ('name', 'type', 'rows', 'cols', 'is_matrix', 'array', 'offset')

    def __init__(self, name, type, rows, cols, is_matrix, array, offset):
        self.name, self.type, self.rows, self.cols = name, type, rows, cols
        self.is_matrix, self.array, self.offset = is_matrix, array, offset

    def key(self):
        return (self.name, self.type, self.rows, self.cols, self.is_matrix, self.array, self.offset)

    def __repr__(self):
        return f'{self.name}@{self.offset}'


class StructParam:
    """A struct member of a constant buffer (Unity's GPU instancing data: an array of structs)."""
    __slots__ = ('name', 'offset', 'array', 'size', 'params')

    def __init__(self, name, offset, array, size, params):
        self.name, self.offset, self.array, self.size, self.params = name, offset, array, size, params


class ConstantBuffer:
    __slots__ = ('name', 'size', 'params', 'structs')

    def __init__(self, name, size, params, structs=()):
        self.name, self.size, self.params, self.structs = name, size, params, list(structs)

    def __repr__(self):
        return f'{self.name}[{self.size}]{self.params}'


# serializer from which a texture binding's two ints are (sampler index, dimension << 1 |
# multisampled) (Unity 2018.2+); before: (dimension, sampler index)
PACKED_TEXTURE_FROM = 201802150
# serializers this path reads: Unity 2017.3 - 2018.4 (201708220, 201802150), 2019.1 - 2021.1
# (201806140: from 2020.1 with m_CommonParameters), 2021.2 - 2022.3 (202012090: parameters as
# entries of their own)
SERIALIZERS = (201708220, 201802150, 201806140, 202012090)
SEPARATE_PARAMS_FROM = 202012090
# serializer of Unity 6000.6's binding info: typed lists, bindings as (encoded data, slot) (see above)
TYPED_FROM = 202605290


class Binding:
    KIND_TEXTURE, KIND_CBUFFER, KIND_BUFFER, KIND_UAV, KIND_SAMPLER = 0, 1, 2, 3, 4
    EXTRA = {KIND_TEXTURE: 2, KIND_CBUFFER: 1, KIND_SAMPLER: 1}     # ints after the index, by kind
    TYPED_ORDER = (KIND_TEXTURE, KIND_UAV, KIND_CBUFFER, KIND_BUFFER, KIND_SAMPLER)   # 6000.6's lists
    __slots__ = ('name', 'kind', 'index', 'extra', 'packed', 'enc')

    def __init__(self, name, kind, index, extra, packed=False, enc=None):
        self.name, self.kind, self.index, self.extra = name, kind, index, list(extra)
        self.packed = packed
        # 6000.6 (typed): the encoded data of the binding (textures: and of the sampler's; UAVs:
        # and of the original binding); extra then: texture [sampler slot, dimension << 1 |
        # multisampled], UAV [original slot], buffer [2 ints], inline sampler [state], none for a
        # constant buffer
        self.enc = None if enc is None else tuple(enc)

    @property
    def dim(self):
        """A texture's dimension (Unity's TextureDimension: 2 2D, 3 3D, 4 cube, 5 2D array)."""
        if self.kind != self.KIND_TEXTURE:
            return None
        return self.extra[1] >> 1 if self.packed else self.extra[0]

    @property
    def sampler(self):
        """A texture's sampler index (-1: it is sampled with an inline sampler state)."""
        if self.kind != self.KIND_TEXTURE:
            return None
        return self.extra[0] if self.packed else self.extra[1]

    def key(self):
        return (self.name, self.kind, self.index, tuple(self.extra)) + ((self.enc,) if self.enc is not None else ())

    def __repr__(self):
        return f'{self.name}:{self.kind}/{self.index}'


def _params(r):
    return [Param(r.string(), *(r.i32() for _ in range(6))) for _ in range(r.count())]


def _typed_members(r):
    """6000.6: a constant buffer's (or struct's) vectors and matrices -> [Param]."""
    out = []
    for matrix in (0, 1):
        for _ in range(r.count()):
            name, packed, array, offset = r.string(), r.i32(), r.i32(), r.i32()
            n, typ = packed & 0xffff, packed >> 16
            out.append(Param(name, typ, n, 4, 1, array, offset) if matrix else Param(name, typ, 1, n, 0, array, offset))
    return out


def _typed_members_bytes(params):
    out = bytearray()
    for matrix in (0, 1):
        ps = [p for p in params if bool(p.is_matrix) == bool(matrix)]
        out += struct.pack('<i', len(ps))
        for p in ps:
            if matrix and (p.cols != 4 or p.is_matrix != 1):
                raise Unsupported(f'matrix {p.name} of {p.rows}x{p.cols}: not in the 6000.6 layout')
            if not matrix and (p.rows != 1 or p.is_matrix != 0):
                raise Unsupported(f'vector {p.name} of {p.rows} rows: not in the 6000.6 layout')
            n = p.rows if matrix else p.cols
            if not 0 <= n <= 0xffff:
                raise Unsupported(f'parameter {p.name}: size {n} not in the 6000.6 layout')
            out += _wstr(p.name) + struct.pack('<3i', n | p.type << 16, p.array, p.offset)
    return bytes(out)


class Bindings:
    """Unity's binding info of one entry (the bytes after its code; 2021.2+: and its parameter
    entry's). typed: in Unity 6000.6's layout (see the module docstring), written back so."""

    def __init__(self, source_map, channels, cbuffers, bindings, typed=False):
        self.source_map, self.channels = source_map, channels
        self.cbuffers, self.bindings = cbuffers, bindings
        self.typed = typed

    @classmethod
    def parse(cls, data, serializer=None, typed=False):
        """serializer: the entry's serializer version (texture bindings changed in 2018.2).
        typed: read Unity 6000.6's layout where the serializer is 6000.6's (TYPED_FROM; else the
        entry is read as before, and 6000.6's does not match it)."""
        if typed and serializer is not None and serializer >= TYPED_FROM:
            return cls._parse_typed(data)
        packed = serializer is not None and serializer >= PACKED_TEXTURE_FROM
        r = _Reader(data)
        try:
            source_map = r.i32()
            channels = [(r.i32(), r.i32()) for _ in range(r.count(64))]
            cbs = []
            for _ in range(r.count(256)):
                name, size = r.string(), r.i32()
                params = _params(r)
                structs = [StructParam(r.string(), r.i32(), r.i32(), r.i32(), _params(r)) for _ in range(r.count(64))]
                cbs.append(ConstantBuffer(name, size, params, structs))
            binds = []
            for _ in range(r.count(256)):
                name, kind, index = r.string(), r.i32(), r.i32()
                if kind not in Binding.EXTRA:
                    raise Unsupported(f'binding {name!r} of kind {kind} (buffer or UAV?): not supported')
                binds.append(Binding(name, kind, index, [r.i32() for _ in range(Binding.EXTRA[kind])], packed))
        except (struct.error, ValueError, UnicodeDecodeError) as ex:
            raise Unsupported(f'binding info does not match the known layout ({ex})')
        b = cls(source_map, channels, cbs, binds)
        if r.p != len(data) or b.serialize() != bytes(data):
            raise Unsupported('binding info does not match the known layout (round trip)')
        return b

    @classmethod
    def _parse_typed(cls, data):
        r = _Reader(data)
        K = Binding
        try:
            source_map = r.i32()
            channels = [(r.i32(), r.i32()) for _ in range(r.count(64))]
            cbs = []
            for _ in range(r.count(256)):
                name, size = r.string(), r.i32()
                params = _typed_members(r)
                structs = [StructParam(r.string(), r.i32(), r.i32(), r.i32(), _typed_members(r)) for _ in range(r.count(64))]
                cbs.append(ConstantBuffer(name, size, params, structs))
            binds = []
            for kind in K.TYPED_ORDER:
                for _ in range(r.count(256)):
                    name = r.string() if kind != K.KIND_SAMPLER else ''
                    enc, slot = r.i32(), r.i32()
                    if kind == K.KIND_TEXTURE:
                        senc, sslot, dim = r.i32(), r.i32(), r.i32()
                        binds.append(K(name, kind, slot, [sslot, dim], True, (enc, senc)))
                    elif kind == K.KIND_UAV:
                        oenc, oslot = r.i32(), r.i32()
                        binds.append(K(name, kind, slot, [oslot], True, (enc, oenc)))
                    elif kind == K.KIND_BUFFER:
                        binds.append(K(name, kind, slot, [r.i32(), r.i32()], True, (enc,)))
                    elif kind == K.KIND_SAMPLER:
                        binds.append(K(name, kind, slot, [r.i32()], True, (enc,)))
                    else:
                        binds.append(K(name, kind, slot, [], True, (enc,)))
        except (struct.error, ValueError, UnicodeDecodeError) as ex:
            raise Unsupported(f'binding info does not match the 6000.6 layout ({ex})')
        b = cls(source_map, channels, cbs, binds, typed=True)
        if r.p != len(data) or b.serialize() != bytes(data):
            raise Unsupported('binding info does not match the 6000.6 layout (round trip)')
        for x in binds:
            if x.kind in (K.KIND_BUFFER, K.KIND_UAV):
                raise Unsupported(f'binding {x.name!r} of kind {x.kind} ({"buffer" if x.kind == K.KIND_BUFFER else "UAV"}): '
                                  f'not supported')
            if any(x.enc):
                raise Unsupported(f'binding {x.name!r} with encoded data {x.enc} (6000.6): not understood')
        return b

    def head(self):
        """The source map and vertex inputs (2021.2+: all of the code entry's binding info)."""
        out = bytearray(struct.pack('<ii', self.source_map, len(self.channels)))
        for s, t in self.channels:
            out += struct.pack('<ii', s, t)
        return bytes(out)

    def params_bytes(self):
        """Constant buffers and bindings (2021.2+: a parameter entry's data)."""
        if self.typed:
            return self._params_bytes_typed()
        out = bytearray(struct.pack('<i', len(self.cbuffers)))
        for cb in self.cbuffers:
            out += _wstr(cb.name) + struct.pack('<ii', cb.size, len(cb.params))
            for p in cb.params:
                out += _wstr(p.name) + struct.pack('<6i', p.type, p.rows, p.cols, p.is_matrix, p.array, p.offset)
            out += struct.pack('<i', len(cb.structs))
            for st in cb.structs:
                out += _wstr(st.name) + struct.pack('<4i', st.offset, st.array, st.size, len(st.params))
                for p in st.params:
                    out += _wstr(p.name) + struct.pack('<6i', p.type, p.rows, p.cols, p.is_matrix, p.array, p.offset)
        out += struct.pack('<i', len(self.bindings))
        for b in self.bindings:
            out += _wstr(b.name) + struct.pack('<ii', b.kind, b.index) + struct.pack('<%di' % len(b.extra), *b.extra)
        return bytes(out)

    def _params_bytes_typed(self):
        K = Binding
        out = bytearray(struct.pack('<i', len(self.cbuffers)))
        for cb in self.cbuffers:
            out += _wstr(cb.name) + struct.pack('<i', cb.size) + _typed_members_bytes(cb.params)
            out += struct.pack('<i', len(cb.structs))
            for st in cb.structs:
                out += _wstr(st.name) + struct.pack('<3i', st.offset, st.array, st.size) + _typed_members_bytes(st.params)
        kinds = {b.kind for b in self.bindings}
        if kinds - set(K.TYPED_ORDER):
            raise Unsupported(f'binding kinds {sorted(kinds - set(K.TYPED_ORDER))} not in the 6000.6 layout')
        for kind in K.TYPED_ORDER:
            bs = [b for b in self.bindings if b.kind == kind]
            out += struct.pack('<i', len(bs))
            for b in bs:
                want = {K.KIND_TEXTURE: (2, 2), K.KIND_UAV: (2, 1), K.KIND_BUFFER: (1, 2), K.KIND_SAMPLER: (1, 1),
                        K.KIND_CBUFFER: (1, 0)}[kind]          # (encoded data ints, extra ints)
                enc = b.enc if b.enc is not None else (0,) * want[0]
                if len(enc) != want[0] or len(b.extra) != want[1]:
                    raise Unsupported(f'binding {b.name!r} (kind {kind}): {b.extra} not in the 6000.6 layout')
                if kind != K.KIND_SAMPLER:
                    out += _wstr(b.name)
                out += struct.pack('<ii', enc[0], b.index)
                if kind in (K.KIND_TEXTURE, K.KIND_UAV):
                    out += struct.pack('<ii', enc[1], b.extra[0]) + struct.pack('<%di' % (len(b.extra) - 1), *b.extra[1:])
                else:
                    out += struct.pack('<%di' % len(b.extra), *b.extra)
        return bytes(out)

    def serialize(self):
        return self.head() + self.params_bytes()


def entry_bindings(entry, param_entry=None, typed=False):
    """The Bindings of a blob entry (2021.2+: with its parameter entry). typed: read 6000.6's
    layout (Bindings.parse)."""
    data = entry.rest + (param_entry.data if param_entry is not None else b'')
    return Bindings.parse(data, entry.version, typed)


def _parameters(sp):
    """A subprogram's (or m_CommonParameters') parameter lists: 2020.1+ grouped in m_Parameters."""
    return sp.get('m_Parameters') if isinstance(sp.get('m_Parameters'), dict) else sp


def with_common(bindings, common, names):
    """The Bindings with a program's m_CommonParameters (2020.1+: what all its subprograms share,
    left out of their entries) put back: constant buffer members into the constant buffer of the
    same name (the entry keeps its name and size; m_IsPartialCB), constant buffers the entry
    lacks, bindings, textures and inline samplers. names: {name index: name} of the pass."""
    if not common or not any(common.get(k) for k in ('m_ConstantBuffers', 'm_ConstantBufferBindings',
                                                       'm_TextureParams', 'm_Samplers', 'm_VectorParams',
                                                       'm_MatrixParams', 'm_BufferParams', 'm_UAVParams')):
        return bindings
    if common.get('m_BufferParams') or common.get('m_UAVParams'):
        raise Unsupported('buffers or UAVs in the shared parameters')
    if common.get('m_VectorParams') or common.get('m_MatrixParams'):
        raise Unsupported('shared parameters outside constant buffers')
    cbs = [ConstantBuffer(cb.name, cb.size, list(cb.params), cb.structs) for cb in bindings.cbuffers]
    binds = list(bindings.bindings)
    packed = True                       # (2020.1+: textures as sampler index, dimension << 1 | multisampled)
    typed = bindings.typed              # (6000.6: offsets m_OffsetInConstantBuffer, bindings m_Binding structs)
    used = set()
    off = 'm_OffsetInConstantBuffer' if typed else 'm_Index'
    for c in common.get('m_ConstantBuffers') or []:
        name = names.get(c['m_NameIndex'])
        if name is None:
            raise Unsupported('shared constant buffer without a name')
        if c.get('m_StructParams'):
            raise Unsupported(f'constant buffer {name!r} has struct members (instancing data)')
        params = [Param(names[v['m_NameIndex']], v['m_Type'], 1, v['m_Dim'], 0, v['m_ArraySize'], v[off])
                  for v in c.get('m_VectorParams') or []]
        params += [Param(names[m['m_NameIndex']], m['m_Type'], m['m_RowCount'], 4, 1, m['m_ArraySize'], m[off])
                   for m in c.get('m_MatrixParams') or []]
        mine = next((i for i, cb in enumerate(cbs) if cb.name == name and i not in used), None)
        if mine is None:
            cbs.append(ConstantBuffer(name, c['m_Size'], params))
            used.add(len(cbs) - 1)
        else:
            used.add(mine)
            cbs[mine].params = sorted(cbs[mine].params + params, key=lambda p: p.offset)
    if typed:
        for b in common.get('m_ConstantBufferBindings') or []:
            enc, slot = _typed_binding(b['m_Binding'])
            if b.get('m_ArraySize', 1) != 1 or b.get('m_ResourceType', 1) != 1:
                raise Unsupported(f'shared constant buffer binding {names[b["m_NameIndex"]]!r}: array or resource type')
            binds.append(Binding(names[b['m_NameIndex']], Binding.KIND_CBUFFER, slot, [], packed, (enc,)))
        for t in common.get('m_TextureParams') or []:
            enc, slot = _typed_binding(t['m_Binding'])
            senc, sslot = _typed_binding(t['m_SamplerBinding'])
            binds.append(Binding(names[t['m_NameIndex']], Binding.KIND_TEXTURE, slot,
                                 [sslot, t['m_Dim'] << 1 | int(bool(t['m_MultiSampled']))], packed, (enc, senc)))
        for smp in common.get('m_Samplers') or []:
            enc, slot = _typed_binding(smp['m_Binding'])
            binds.append(Binding('', Binding.KIND_SAMPLER, slot, [smp['sampler']], packed, (enc,)))
        if any(x.enc and any(x.enc) for x in binds):
            raise Unsupported('shared parameters with encoded binding data (6000.6): not understood')
        return Bindings(bindings.source_map, bindings.channels, cbs, binds, typed=True)
    for b in common.get('m_ConstantBufferBindings') or []:
        binds.append(Binding(names[b['m_NameIndex']], Binding.KIND_CBUFFER, b['m_Index'], [0], packed))
    for t in common.get('m_TextureParams') or []:
        extra = [t['m_SamplerIndex'], t['m_Dim'] << 1 | int(bool(t['m_MultiSampled']))] if packed \
            else [t['m_Dim'], t['m_SamplerIndex']]
        binds.append(Binding(names[t['m_NameIndex']], Binding.KIND_TEXTURE, t['m_Index'], extra, packed))
    for smp in common.get('m_Samplers') or []:
        binds.append(Binding('', Binding.KIND_SAMPLER, smp['bindPoint'], [smp['sampler']], packed))
    return Bindings(bindings.source_map, bindings.channels, cbs, binds)


def _typed_binding(b):
    """6000.6: (encoded data, slot) of a Binding struct of the parsed form (as int32s, as the blob has them)."""
    def i32(v):
        return v - (1 << 32) if v >= 1 << 31 else v
    return i32(b['m_EncodedData']), i32(b['m_Slot'])


def check_parsed_form(bindings, sp, names):
    """Differences between an entry's binding info and the SerializedSubProgram that points to it
    (m_ParsedForm: constant buffers, their bindings, textures; names: {name index: name} of the
    pass). The two are written by Unity from the same compile, so any difference means the
    binding info was misread (another Unity version's layout): [] when they agree. (From 2020.1
    player builds keep these lists empty and the entries hold everything.)"""
    out = []
    sp = _parameters(sp)
    cbs = {cb.name: cb for cb in bindings.cbuffers}
    have = {(b.name, b.index) for b in bindings.bindings if b.kind == Binding.KIND_CBUFFER}
    for b in sp.get('m_ConstantBufferBindings') or []:
        if (names.get(b['m_NameIndex']), b['m_Index']) not in have:
            out.append(f'constant buffer binding {names.get(b["m_NameIndex"])}/{b["m_Index"]}')
    for cb in sp.get('m_ConstantBuffers') or []:
        mine = cbs.get(names.get(cb['m_NameIndex']))
        if mine is None or mine.size != cb.get('m_Size', mine.size):
            out.append(f'constant buffer {names.get(cb["m_NameIndex"])}')
            continue
        offs = {p.name: p.offset for p in mine.params}
        for p in (cb.get('m_VectorParams') or []) + (cb.get('m_MatrixParams') or []):
            if offs.get(names.get(p['m_NameIndex'])) != p['m_Index']:
                out.append(f'constant {names.get(p["m_NameIndex"])} in {mine.name}')
    tex = {(b.name, b.index, b.dim) for b in bindings.bindings if b.kind == Binding.KIND_TEXTURE}
    for t in sp.get('m_TextureParams') or []:
        if (names.get(t['m_NameIndex']), t['m_Index'], t['m_Dim']) not in tex:
            out.append(f'texture {names.get(t["m_NameIndex"])}/{t["m_Index"]}')
    return out


def gl_rest(source_map):
    """The binding info of a GL entry up to Unity 2018: Unity's GL backends find uniforms,
    textures and vertex inputs by name in the linked program, so it is only the source map (the
    same in every one of the 5782 GLCore entries of Cuphead and the GLES3 ones of Unity's own
    Android resources). From 2019.1: gl_bindings()."""
    return struct.pack('<8i', source_map, 0, 1, 0, 0, 0, 0, 0)


# ---------------------------------------------------------------- GL binding info (2019.1+)

_PREC = r'(?:(?:highp|mediump|lowp)\s+)?'
_LOOSE = re.compile(r'^uniform\s+' + _PREC + r'(\w+)\s+(\w+)(?:\[(\d+)\])?\s*;', re.M)
_TEX = re.compile(r'^(?:UNITY_LOCATION\((\d+)\)\s*)?uniform\s+' + _PREC + r'(\w*sampler\w+)\s+(\w+)\s*;', re.M)
_BLOCK = re.compile(r'^(?:UNITY_BINDING\((\d+)\)\s*)?(?:layout\([^)]*\)\s*)?uniform\s+(\w+)\s*\{(.*?)^\s*'
                    r'(?:#endif\s*\n\s*)?(?:#if HLSLCC_ENABLE_UNIFORM_BUFFERS\s*\n)?\s*\}[^;]*;', re.M | re.S)
_MEMBER = re.compile(r'^\s*(?:UNITY_UNIFORM\s+)?' + _PREC + r'(\w+)\s+(\w+)(?:\[(\w+)\])?\s*;', re.M)
_MTX = re.compile(r'^hlslcc_mtx(\d)x(\d)(\w+)$')
_GL_TYPES = {'float': (0, 1), 'int': (5, 1), 'uint': (5, 1), 'bool': (5, 1)}
_GL_TYPES.update({f'{p}vec{n}': (0 if p == '' else 5, n) for p in ('', 'i', 'u', 'b') for n in (2, 3, 4)})
# GLSL sampler types -> Unity's TextureDimension
_GL_SAMPLERS = {'2D': 2, '3D': 3, 'Cube': 4, '2DArray': 5, 'CubeArray': 6, '2DShadow': 2, 'CubeShadow': 4,
                '2DArrayShadow': 5, '2DMS': 2, '2DMSArray': 5}
GL_STAGE_ORDER = ('FRAGMENT', 'HULL', 'DOMAIN', 'GEOMETRY', 'VERTEX')       # HLSLcc's translation order


def _gl_param(gltype, name, count):
    """A Param (offset 0) of a GL uniform declaration: matrices are HLSLcc's hlslcc_mtx<R>x<C>
    vec4 arrays, integer and bool types are reported as uint (5)."""
    m = _MTX.match(name)
    if m:
        r, c = int(m.group(1)), int(m.group(2))
        n = int(count or 1) // c
        return Param(m.group(3), 0, r, c, 1, n if n > 1 else 0, 0)
    if gltype not in _GL_TYPES:
        raise Unsupported(f'uniform {name} of type {gltype}')
    t, cols = _GL_TYPES[gltype]
    return Param(name, t, 1, cols, 0, int(count) if count else 0, 0)


def _gl_size(p):
    return 16 * p.rows * max(p.array, 1) if p.is_matrix else p.cols * 4 * max(p.array, 1)


def gl_globals_layout(params, unity):
    """Offsets of a stage's loose uniforms in Unity's GL "$Globals" (in declaration order) and its
    size. unity: (major, minor). 2020.1+: alignments 4 / 8 / 16 / 16 for 1 - 4 components, 16 for
    arrays and matrices, arrays packed by their element size (glUniform*v), the size the end of
    the last one. 2019: vec4s and matrices at 16; a smaller vector that would cross a 16-byte
    boundary is moved on by as many bytes as it would cross it by (Unity 2019's rule, as its own
    programs have it)."""
    off = 0
    for p in params:
        sz = _gl_size(p)
        if unity < (2020, 1):
            if p.is_matrix or p.cols == 4:
                off = (off + 15) & ~15
            elif not p.array and (off % 16) + sz > 16:
                off += (off % 16) + sz - 16
        else:
            al = 16 if (p.is_matrix or p.array) else {1: 4, 2: 8, 3: 16, 4: 16}[p.cols]
            off = (off + al - 1) & ~(al - 1)
        p.offset = off
        off += sz
    return params, off


def _vectors_then_matrices(params):
    return [p for p in params if not p.is_matrix] + [p for p in params if p.is_matrix]


def gl_declarations(src, arrays=None):
    """One stage's uniforms in declaration order: ('u', Param) loose uniforms, ('b', name,
    binding, [Param]) uniform blocks (Xhlslcc_UnusedX padding members left out), ('t', name, unit,
    dimension, multisampled) textures. arrays: {name: array size} where known (HLSLcc declares an
    array of one element as a plain variable; Unity lists it as an array of 1)."""
    items, spans = [], []
    arrays = arrays or {}

    def param(gltype, name, count):
        p = _gl_param(gltype, name, count)
        if not count and arrays.get(p.name) == 1:
            p.array = 1
        return p
    for m in _BLOCK.finditer(src):
        mem = []
        for mm in _MEMBER.finditer(m.group(3)):
            if mm.group(3) and not mm.group(3).isdigit():
                raise Unsupported(f'uniform block {m.group(2)}: array size {mm.group(3)} (instancing data)')
            mem.append(param(mm.group(1), mm.group(2), mm.group(3)))
        items.append((m.start(), ('b', m.group(2), int(m.group(1) or 0), mem)))
        spans.append((m.start(), m.end()))
    for m in _LOOSE.finditer(src):
        if 'sampler' not in m.group(1) and not any(a <= m.start() < b for a, b in spans):
            items.append((m.start(), ('u', param(m.group(1), m.group(2), m.group(3)))))
    for m in _TEX.finditer(src):
        st = re.sub(r'^[iu]?sampler', '', m.group(2))
        if st not in _GL_SAMPLERS:
            raise Unsupported(f'texture {m.group(3)} of type {m.group(2)}')
        items.append((m.start(), ('t', m.group(3), int(m.group(1) or 0), _GL_SAMPLERS[st], 'MS' in st)))
    if re.search(r'^\s*(?:layout\([^)]*\)\s*)?(?:(?:readonly|writeonly|coherent|restrict)\s+)*buffer\s', src, re.M):
        raise Unsupported('storage buffer')
    if re.search(r'^struct\s', src, re.M):
        raise Unsupported('struct uniforms (instancing data)')
    return [it for _, it in sorted(items, key=lambda x: x[0])]


def gl_bindings(code, unity, source_map=0, arrays=None, typed=False):
    """The binding info Unity's GL compiler (2019.1+) gives a GL program (Bindings). code: the
    program (#ifdef VERTEX / FRAGMENT blocks); unity: (major, minor); arrays: {name: array size}
    of the uniforms where known (gl_declarations); typed: in 6000.6's layout (Bindings.typed:
    the same buffers and bindings, the "$Globals" binding at slot -1, as Unity's 6000.6 GL
    programs have it).

    Constant buffers: the empty one, then per stage in HLSLcc's order (fragment first) a
    "$Globals" of its loose uniforms (gl_globals_layout; vectors listed before matrices) and its
    uniform blocks (laid out alike, with 2020's rule; a block of the same name once). Bindings: the textures (each name
    once, hlslcc_zcmp<name> being <name>; index and sampler index the unit), then the blocks.
    2022.1+: one "$Globals" for all stages, its members keyed by offset (a later stage's member at
    an offset already taken is not listed: Unity's own programs have it so), listed by offset,
    vectors then matrices, first; the blocks after it in reverse order, and a binding for it."""
    stages = gl_stages(code)
    cbs, merged = [ConstantBuffer('', 0, [])], None
    texs, blocks = [], []
    seen_tex, seen_blocks = set(), set()
    for st in GL_STAGE_ORDER:
        if st not in stages:
            continue
        items = gl_declarations(stages[st], arrays)
        loose = [it[1] for it in items if it[0] == 'u']
        done_loose = False
        for it in items:
            if it[0] == 'u':
                if done_loose:
                    continue
                done_loose = True
                params, size = gl_globals_layout(loose, unity)
                if unity >= (2022, 1):
                    if merged is None:
                        merged = ConstantBuffer('$Globals', size, sorted(params, key=lambda p: p.offset))
                    else:
                        taken = {p.offset for p in merged.params}
                        merged.params = sorted(merged.params + [p for p in params if p.offset not in taken],
                                               key=lambda p: p.offset)
                else:
                    cbs.append(ConstantBuffer('$Globals', size, _vectors_then_matrices(params)))
            elif it[0] == 'b':
                _, name, binding, mem = it
                if name in seen_blocks:
                    continue
                seen_blocks.add(name)
                params, size = gl_globals_layout(mem, max(unity, (2020, 1)))
                params = [p for p in params if not p.name.startswith('Xhlslcc_UnusedX')]
                blocks.append((ConstantBuffer(name, size, _vectors_then_matrices(params)),
                               Binding(name, Binding.KIND_CBUFFER, binding, [] if typed else [0], True,
                                       (0,) if typed else None)))
                if unity < (2022, 1):
                    cbs.append(blocks[-1][0])
            else:
                _, name, unit, dim, ms = it
                if name.startswith('hlslcc_zcmp'):
                    name = name[len('hlslcc_zcmp'):]
                if name not in seen_tex:
                    seen_tex.add(name)
                    texs.append(Binding(name, Binding.KIND_TEXTURE, unit, [unit, dim << 1 | int(ms)], True,
                                        (0, 0) if typed else None))
    binds = texs
    if unity >= (2022, 1):
        if merged is not None:
            merged.params = _vectors_then_matrices(merged.params)
            cbs.append(merged)
            binds = binds + [Binding('$Globals', Binding.KIND_CBUFFER, -1, [], True, (0,)) if typed else
                             Binding('$Globals', Binding.KIND_CBUFFER, 0, [0], True)]
        cbs += [cb for cb, _ in blocks[::-1]]
        binds += [b for _, b in blocks[::-1]]
    else:
        binds = binds + [b for _, b in blocks]
    return Bindings(source_map, [], cbs, binds, typed=typed)


def gl_stages(code):
    """{'VERTEX': src, ...} of a GL program (#ifdef VERTEX ... #endif blocks)."""
    return glsl.stage_sources(code)


# ---------------------------------------------------------------- the DXBC container

def header_size(code):
    """The size of Unity's header before an entry's DXBC container (6 or 38), or None."""
    for n in HEADER_SIZES:
        if len(code) >= n + 32 and code[n:n + 4] == b'DXBC':
            return n
    return None


def split_code(code):
    """A D3D11 entry's code -> (Unity's header, the DXBC container)."""
    n = header_size(code)
    if n is None:
        raise Unsupported('not a D3D11 program (no DXBC container after the header)')
    size, = struct.unpack_from('<I', code, n + 24)
    if size != len(code) - n:
        raise Unsupported(f'DXBC container size {size} != {len(code) - n}')
    return bytes(code[:n]), bytes(code[n:])


def is_d3d11_code(code):
    return header_size(code) is not None


def chunks(dxbc):
    """[(fourcc, data)] of a DXBC container."""
    n, = struct.unpack_from('<I', dxbc, 28)
    out = []
    for i in range(n):
        off, = struct.unpack_from('<I', dxbc, 32 + 4 * i)
        fourcc = dxbc[off:off + 4].decode('ascii', 'replace')
        size, = struct.unpack_from('<I', dxbc, off + 4)
        out.append((fourcc, dxbc[off + 8:off + 8 + size]))
    return out


def build_container(chs):
    """[(fourcc, data)] -> DXBC container. The checksum is left zero (HLSLcc does not check it)."""
    head = 32 + 4 * len(chs)
    body = bytearray()
    offs = []
    for fourcc, data in chs:
        offs.append(head + len(body))
        body += fourcc.encode('ascii') + struct.pack('<I', len(data)) + data
        body += b'\0' * (_pad4(len(body)) - len(body))
    total = head + len(body)
    out = bytearray(b'DXBC' + b'\0' * 16 + struct.pack('<III', 1, total, len(chs)))
    for o in offs:
        out += struct.pack('<I', o)
    return bytes(out + body)


# ---------------------------------------------------------------- SHDR / SHEX declarations

STAGE_NAMES = {0: 'pixel', 1: 'vertex', 2: 'geometry', 3: 'hull', 4: 'domain', 5: 'compute'}
_OP_CUSTOMDATA, _OP_DCL_RESOURCE, _OP_DCL_CB, _OP_DCL_SAMPLER = 53, 88, 89, 90
_OP_BUFFERS = {156: 'UAV', 157: 'raw UAV', 158: 'structured UAV', 159: 'group shared memory',
               160: 'group shared memory', 161: 'raw buffer', 162: 'structured buffer'}
# RESOURCE_DIMENSION (bytecode) -> (D3D_SRV_DIMENSION for RDEF, Unity's TextureDimension or None)
_DIMS = {1: (1, None), 2: (2, None), 3: (4, 2), 4: (6, 2), 5: (8, 3), 6: (9, 4), 7: (3, None),
         8: (5, 5), 9: (7, 5), 10: (10, 6)}
_DIM_NAMES = {1: 'buffer', 2: '1D', 3: '2D', 4: '2D MS', 5: '3D', 6: 'cube', 7: '1D array', 8: '2D array',
              9: '2D MS array', 10: 'cube array'}
# 2D, 3D, cube, 2D array: the sampler types GLSL ES 3.00 has; 2D multisampled: GLSL ES 3.10 (GLES 3.1 programs)
_ES3_DIMS = (3, 4, 5, 6, 8)


def _is_declaration(op):
    return 88 <= op <= 106 or 143 <= op <= 162 or op == 206


class Program:
    """What the bytecode declares: version, stage, registers of constant buffers (with their
    size in vec4s), textures (dimension, return type) and samplers (mode); and cb_reads, the
    constant buffer locations its instructions read with immediate indices: {(register, vec4,
    first component)} (None if an instruction could not be walked)."""

    def __init__(self, shdr):
        w = struct.unpack('<%dI' % (len(shdr) // 4), shdr[:len(shdr) // 4 * 4])
        if len(w) < 2:
            raise Unsupported('empty shader code chunk')
        self.minor, self.major, self.stage = w[0] & 0xf, (w[0] >> 4) & 0xf, w[0] >> 16
        self.cbuffers, self.textures, self.samplers = {}, {}, {}
        self.buffers = []               # other resource declarations (UAVs, buffers): their names
        self.cb_reads = set()
        end = min(w[1], len(w))
        i = 2
        while i < end:
            tok = w[i]
            op = tok & 0x7ff
            n = w[i + 1] if op == _OP_CUSTOMDATA else (tok >> 24) & 0x7f
            if n == 0 or i + n > end:
                raise Unsupported('shader code chunk: bad instruction length')
            if op != _OP_CUSTOMDATA and not _is_declaration(op) and self.cb_reads is not None:
                self._walk(w, i, i + n)
            if op == _OP_DCL_CB:
                idx, _ = self._operand(w, i + 1)
                self.cbuffers[idx[0]] = idx[1] if len(idx) > 1 else 0
            elif op == _OP_DCL_RESOURCE:
                idx, p = self._operand(w, i + 1)
                self.textures[idx[0]] = ((tok >> 11) & 0x1f, w[p] & 0xf)
            elif op == _OP_DCL_SAMPLER:
                idx, _ = self._operand(w, i + 1)
                self.samplers[idx[0]] = (tok >> 11) & 0xf          # 0 default, 1 comparison, 2 mono
            elif op in _OP_BUFFERS:
                self.buffers.append(_OP_BUFFERS[op])
            i += n

    def _walk(self, w, i, end):
        """Records the immediate constant buffer reads of the instruction at w[i:end]."""
        p = i + 1
        ext = w[i] >> 31
        while ext and p < end:                      # extended opcode tokens
            ext = w[p] >> 31
            p += 1
        try:
            while p < end:
                p = self._operand_reads(w, p, end)
        except (IndexError, ValueError):
            self.cb_reads = None
        if p != end:
            self.cb_reads = None

    def _operand_reads(self, w, p, end):
        tok = w[p]
        p += 1
        ext = tok >> 31
        while ext:                                  # extended operand tokens
            if p >= end:
                raise ValueError
            ext = w[p] >> 31
            p += 1
        ncomp, otype, dim = tok & 3, (tok >> 12) & 0xff, (tok >> 20) & 3
        if otype in (4, 5):                         # immediate 32 / 64-bit values
            return p + (1 if ncomp == 1 else 4 if ncomp == 2 else 0) * (1 if otype == 4 else 2)
        idx = []
        for k in range(dim):
            rep = (tok >> (22 + 3 * k)) & 7
            if rep == 0:
                idx.append(w[p]); p += 1
            elif rep == 1:
                idx.append(None); p += 2
            elif rep in (2, 3, 4):
                p += (0, 1, 2)[rep - 2]
                idx.append(None)
                p = self._operand_reads(w, p, end)  # relative index: an operand of its own
            else:
                raise ValueError
        if otype == 8 and dim == 2 and None not in idx and ncomp == 2:
            mode = (tok >> 2) & 3                   # 0 mask, 1 swizzle, 2 one component
            comp = (tok >> 4) & 3 if mode else next((c for c in range(4) if tok >> (4 + c) & 1), 0)
            self.cb_reads.add((idx[0], idx[1], comp))
        if p > end:
            raise ValueError
        return p

    def _operand(self, w, p):
        """Immediate register indices of a declaration's operand; position after it."""
        tok = w[p]
        p += 1
        if tok >> 31:                   # extended operand token
            p += 1
        idx = []
        for k in range((tok >> 20) & 3):
            rep = (tok >> (22 + 3 * k)) & 7
            if rep != 0:
                raise Unsupported('declaration with a relative register index')
            idx.append(w[p])
            p += 1
        if self.major == 5 and self.minor == 1:
            raise Unsupported('shader model 5.1 (register spaces)')
        return idx, p


_RDEF_PROGRAM_TYPES = {0: 0xffff, 1: 0xfffe, 2: 0x4753, 3: 0x4853, 4: 0x4453, 5: 0x4353}


def _var_layout(p):
    """(D3D_SHADER_VARIABLE_CLASS, D3D_SHADER_VARIABLE_TYPE, size in bytes) of a Unity param."""
    types = {0: 3, 1: 2, 2: 1, 5: 19}                # Unity float, int, bool, uint -> D3D_SVT_*
    if p.type not in types:
        raise Unsupported(f'constant {p.name!r} of Unity type {p.type}')
    if p.is_matrix:
        cls, regs, last = 3, p.cols, p.rows * 4      # column_major (HLSL's default): a register per column
    else:
        cls, regs, last = (0 if p.cols == 1 and p.rows == 1 else 1), p.rows, p.cols * 4
    one = (regs - 1) * 16 + last
    size = one if p.array <= 1 else (p.array - 1) * regs * 16 + one
    return cls, types[p.type], size


def _rdef(prog, cbs, textures, samplers, creator='pmunity'):
    """An RDEF chunk as HLSLcc reads it. cbs: [(register, ConstantBuffer)], textures:
    [(register, name)], samplers: [(register, name)]."""
    sm5 = prog.major >= 5
    var_words = 10 if sm5 else 6
    strings = bytearray()
    str_at = {}

    def s(text):
        if text not in str_at:
            str_at[text] = len(strings)
            strings.extend(text.encode('ascii') + b'\0')
        return str_at[text]

    binds = []          # (name, type, return type, dimension, samples, bind point, count, flags)
    for reg, name in samplers:
        binds.append((name, 3, 0, 0, 0, reg, 1, 2 if prog.samplers[reg] == 1 else 0))
    for reg, name in textures:
        dim, ret = prog.textures[reg]
        ms = dim in (4, 9)
        binds.append((name, 2, ret, _DIMS[dim][0], 0 if ms else 0xffffffff, reg, 1, 0xc))
    for reg, cb in cbs:
        binds.append((cb.name, 0, 0, 0, 0, reg, 1, 0))
    nvars = sum(len(cb.params) for _, cb in cbs)
    head = 7 * 4
    bind_off = head
    cb_off = bind_off + 32 * len(binds)
    var_off = cb_off + 24 * len(cbs)
    type_off = var_off + 4 * var_words * nvars
    str_base = type_off + 16 * nvars
    target = prog.minor | (prog.major << 8) | (_RDEF_PROGRAM_TYPES.get(prog.stage, 0) << 16)
    out = bytearray(struct.pack('<7I', len(cbs), cb_off, len(binds), bind_off, target, 0, str_base + s(creator)))
    for name, *rest in binds:
        out += struct.pack('<8I', str_base + s(name), *rest)
    v = 0
    for _, cb in cbs:
        out += struct.pack('<6I', str_base + s(cb.name), len(cb.params), var_off + 4 * var_words * v, cb.size, 0, 0)
        v += len(cb.params)
    types = bytearray()
    v = 0
    for _, cb in cbs:
        for p in cb.params:
            cls, typ, size = _var_layout(p)
            out += struct.pack('<6I', str_base + s(p.name), p.offset, size, 2, type_off + 16 * v, 0)
            if sm5:
                out += struct.pack('<4I', 0xffffffff, 0, 0xffffffff, 0)
            types += struct.pack('<6HI', cls, typ, p.rows, p.cols, p.array if p.array > 1 else 0, 0, 0)
            v += 1
    out += types
    assert len(out) == str_base
    return bytes(out + strings)


def with_reflection(dxbc, bindings):
    """The DXBC container with an RDEF chunk rebuilt from Unity's binding info (an existing one is
    replaced). Raises Unsupported when the bytecode declares something the binding info does not
    name, or what this path does not handle."""
    chs = [(f, d) for f, d in chunks(dxbc) if f != 'RDEF']
    code = [d for f, d in chs if f in ('SHDR', 'SHEX')]
    if not code:
        raise Unsupported('no shader code chunk')
    prog = Program(code[0])
    if prog.buffers:
        raise Unsupported(f'{STAGE_NAMES.get(prog.stage)} shader uses {", ".join(sorted(set(prog.buffers)))}')
    by_name = {cb.name: cb for cb in bindings.cbuffers}
    cb_regs = {b.index: b.name for b in bindings.bindings if b.kind == Binding.KIND_CBUFFER}
    tex_regs = {b.index: b for b in bindings.bindings if b.kind == Binding.KIND_TEXTURE}
    cbs = []
    for reg in sorted(prog.cbuffers):
        name = cb_regs.get(reg)
        if name is None or name not in by_name:
            raise Unsupported(f'constant buffer cb{reg} is not named in the binding info')
        if by_name[name].structs:
            raise Unsupported(f'constant buffer {name!r} has struct members (GPU instancing data): not translated')
        cbs.append((reg, by_name[name]))
    extents = {reg: [(p.offset, p.offset + _var_layout(p)[2]) for p in cb.params] for reg, cb in cbs}
    for reg, vec, comp in sorted(prog.cb_reads or ()):
        at = vec * 16 + comp * 4
        if not any(a <= at < b for a, b in extents.get(reg, ())):
            raise Unsupported(f'cb{reg}[{vec}].{"xyzw"[comp]} is read but the binding info has no constant there')
    textures = []
    for reg in sorted(prog.textures):
        b = tex_regs.get(reg)
        if b is None:
            raise Unsupported(f'texture t{reg} is not named in the binding info')
        dim, ret = prog.textures[reg]
        if dim not in _DIMS:
            raise Unsupported(f'texture {b.name!r}: resource dimension {dim}')
        if dim not in _ES3_DIMS:
            raise Unsupported(f'{_DIM_NAMES[dim]} texture {b.name!r} (not in GLSL ES 3.10)')
        if _DIMS[dim][1] is not None and b.dim != _DIMS[dim][1]:
            raise Unsupported(f'texture {b.name!r}: declared {_DIM_NAMES[dim]} but Unity says dimension {b.dim}')
        textures.append((reg, b.name))
    names = dict(textures)
    samplers = [(reg, 'sampler' + names[reg] if reg in names else f'sampler{reg}') for reg in sorted(prog.samplers)]
    rdef = _rdef(prog, cbs, textures, samplers)
    return build_container([('RDEF', rdef)] + chs), prog


# ---------------------------------------------------------------- HLSLcc (pmhlslcc)

def find_hlslcc():
    """$PMHLSLCC, else tools/hlslcc/out/pmhlslcc of this repository, else pmhlslcc on PATH."""
    p = os.environ.get('PMHLSLCC')
    if p:
        return p
    here = os.path.dirname(os.path.abspath(__file__))
    p = os.path.normpath(os.path.join(here, '..', '..', '..', 'tools', 'hlslcc', 'out', 'pmhlslcc'))
    if os.path.exists(p):
        return p
    return shutil.which('pmhlslcc')


class Translator:
    """A pmhlslcc server process (restarted if HLSLcc crashes on a program)."""

    def __init__(self, exe=None, lang=LANG, flags=FLAGS):
        self.exe = exe or find_hlslcc()
        if not self.exe or not os.path.exists(self.exe):
            raise FileNotFoundError('pmhlslcc not found: build it with tools/hlslcc/build.sh or set PMHLSLCC')
        self.lang, self.flags = lang, flags
        self.proc = None
        self.crashes = 0

    def __enter__(self):
        return self

    def __exit__(self, *a):
        self.close()

    def close(self):
        if self.proc:
            try:
                self.proc.stdin.write(b'0 0 x\n')
                self.proc.stdin.close()
            except OSError:
                pass
            self.proc.wait()
            self.proc.stdout.close()
            self.proc = None

    def translate(self, stages, flags=None):
        """[DXBC container] -> [GLSL text] (same order). flags: HLSLcc flags for this request
        (default the translator's). Raises Unsupported with HLSLcc's log."""
        if self.proc is None:
            self.proc = subprocess.Popen([self.exe, '-s'], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        flags = self.flags if flags is None else flags
        head = f'{len(stages)} {flags:#x} {self.lang}' + ''.join(f' {len(s)}' for s in stages) + '\n'
        try:
            self.proc.stdin.write(head.encode() + b''.join(stages))
            self.proc.stdin.flush()
            line = self.proc.stdout.readline().split()
            if not line:
                raise BrokenPipeError
            status, n = int(line[0]), int(line[1])
            lens = [int(x) for x in line[2:]]
            texts = [self.proc.stdout.read(k).decode('utf-8') for k in lens[:n]]
            log = self.proc.stdout.read(lens[n]).decode('utf-8', 'replace')
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
            raise Unsupported('HLSLcc crashed on this program')
        if status:
            raise Unsupported('HLSLcc: ' + ('; '.join(l for l in log.splitlines() if 'error' in l) or log.strip() or 'failed'))
        return texts


_DEFINE_BLOCKS = (
    '#define HLSLCC_ENABLE_UNIFORM_BUFFERS 1\n#if HLSLCC_ENABLE_UNIFORM_BUFFERS\n#define UNITY_UNIFORM\n'
    '#else\n#define UNITY_UNIFORM uniform\n#endif\n',
    '#define UNITY_SUPPORTS_UNIFORM_LOCATION 1\n#if UNITY_SUPPORTS_UNIFORM_LOCATION\n'
    '#define UNITY_LOCATION(x) layout(location = x)\n#define UNITY_BINDING(x) layout(binding = x, std140)\n'
    '#else\n#define UNITY_LOCATION(x)\n#define UNITY_BINDING(x) layout(std140)\n#endif\n',
)


def tidy(glsl):
    """HLSLcc's GLSL as Unity 2017-2018 stored it. Newer HLSLcc wraps each optional extension in
    `#ifdef GL_X` (written plainly here, as before: `enable` only warns on a driver without it) and
    writes two macro blocks that later Unity players switch off at load time (uniform buffers,
    explicit uniform locations); they are removed and any use of their macros written out as
    switched off, as those players do on a driver without the feature."""
    glsl = re.sub(r'^#ifdef (\w+)\n(#extension \1 : enable\n)#endif\n', r'\2', glsl, flags=re.M)
    for b in _DEFINE_BLOCKS:
        glsl = glsl.replace(b, '')
    glsl = re.sub(r'\bUNITY_LOCATION\(\s*\d+\s*\)\s*', '', glsl)
    glsl = re.sub(r'\bUNITY_BINDING\(\s*\d+\s*\)', 'layout(std140)', glsl)
    return re.sub(r'\bUNITY_UNIFORM\b', 'uniform', glsl)


def gl_program(stages, tidy_up=True):
    """{'VERTEX': glsl, 'FRAGMENT': glsl, ...} -> one GL program as Unity stores it. tidy_up: as
    Unity 2017-2018 stored it (tidy()); from 2019.1 Unity keeps HLSLcc's text as it is."""
    out = []
    for st in ('VERTEX', 'HULL', 'DOMAIN', 'GEOMETRY', 'FRAGMENT'):
        if st in stages:
            out.append(f'#ifdef {st}\n{tidy(stages[st]) if tidy_up else stages[st]}\n#endif\n')
    return ''.join(out)


def unity_line(serializer):
    """(major, minor) of the oldest Unity version that writes a serializer's entries."""
    return {201708220: (2017, 3), 201802150: (2018, 2), 201806140: (2019, 1), 202012090: (2021, 2)}.get(serializer, (2017, 3))


_UNIFORM_LINE = re.compile(r'^uniform\s+(?:(?:highp|mediump|lowp)\s+)?\w+\s+(\w+)(?:\[\d+\])?\s*;$')


def unity_uniform_order(glsl, bindings, prog):
    """The stage's loose uniforms in the order Unity's own GL compile declares them. There every
    built-in and material value is a member of one $Globals in the order of the HLSL source,
    where the D3D11 compile has the built-ins in Unity's named constant buffers (UnityPerDraw,
    UnityPerFrame, ...), declared before the shader's own values: HLSLcc declares the members of
    each constant buffer in the order of their registers ($Globals, cb0, first), so the named
    ones' members are moved before $Globals'. Only declarations move; it decides the offsets
    of Unity's GL $Globals (gl_bindings)."""
    regs = {b.index: b.name for b in bindings.bindings if b.kind == Binding.KIND_CBUFFER}
    by_name = {cb.name: cb for cb in bindings.cbuffers}
    rank = {}
    for n, reg in enumerate(sorted(prog.cbuffers)):
        cb = by_name.get(regs.get(reg))
        for p in (cb.params if cb else ()):
            gl = ('hlslcc_mtx%dx%d' % (p.rows, p.cols) + p.name) if p.is_matrix else p.name
            rank.setdefault(gl, (1 if cb.name == '$Globals' else 0, n))
    lines = glsl.split('\n')
    at = [i for i, l in enumerate(lines) if _UNIFORM_LINE.match(l) and 'sampler' not in l]
    if not at or at != list(range(at[0], at[0] + len(at))):
        return glsl
    block = [lines[i] for i in at]
    key = lambda l: rank.get(_UNIFORM_LINE.match(l).group(1), (1, len(rank)))
    lines[at[0]:at[0] + len(at)] = sorted(block, key=key)
    return '\n'.join(lines)


_NO_ES = re.compile(r'\b(textureSamples|imageSamples|textureQueryLevels|textureQueryLod)\s*\(')


def gl_fixups(glsl_text):
    """HLSLcc's GLSL 1.50 where GLSL ES has no such call, written as Unity's own GLES3 programs
    have it: a cube shadow map compared at level 0 (D3D's SampleCmpLevelZero, point-light shadows:
    textureLod on a samplerCubeShadow, which no GLSL ES has) becomes texture() on it (Unity's
    Android builds, and the same on a shadow map without mipmaps). Functions GLSL ES lacks
    (texture sample counts, LOD queries) raise Unsupported."""
    m = _NO_ES.search(glsl_text)
    if m:
        raise Unsupported(f'{m.group(1)}() (not in GLSL ES)')
    cubes = re.findall(r'^\s*(?:UNITY_LOCATION\(\d+\)\s*)?uniform\s+(?:(?:highp|mediump|lowp)\s+)?samplerCubeShadow\s+(\w+)\s*;',
                       glsl_text, re.M)
    for name in cubes:
        glsl_text = re.sub(r'\btextureLod\(\s*' + name + r'\s*,\s*([^;]*?),\s*0\.0\s*\)', r'texture(' + name + r', \1)', glsl_text)
    return glsl_text


# ---- UNITY_UV_STARTS_AT_TOP in the SRP core library's procedural full-screen geometry
_ASSIGN = re.compile(r'^(\s*)(\w+)(?:\.([xyzw]+))?\s*=\s*(.+?);\s*$')
_OPERAND = r'(\w+)(?:\.([xyzw]+))?'
_VID = r'(?:uint|int)\(gl_VertexID\)|gl_VertexID'


def gl_uv_origin(vs_glsl):
    """The vertex stage of a program translated from Direct3D 11 with the texture coordinate flips
    the HLSL made for Direct3D's top-left texture origin at compile time (UNITY_UV_STARTS_AT_TOP)
    taken out where they are the SRP core library's, so the program does what Unity's own GL
    compile of it does (the macro is 0 there): (text, number of flips undone).

    Unity's Core RP library (Common.hlsl) builds the full-screen triangle and quad of every SRP
    full-screen pass from SV_VertexID: GetFullScreenTriangleTexCoord's v = 1 - (id & 2) and
    GetQuadTexCoord's v = 1 - ((id >> 1) + (id & 1)) & 1 on Direct3D, against id & 2 and
    ((id >> 1) + (id & 1)) & 1 on GL. URP's C# side does not flip for GL (it asks the running API,
    SystemInfo.graphicsUVStartsAtTop), so with Direct3D's code every blit turns the picture upside
    down and the passes that compute values from the coordinate get them mirrored: the color
    grading LUT (LutBuilderLdr/Hdr) comes out upside down, and the final picture of a game with
    post-processing turns green. HLSLcc writes the flip as `<t> = (-<v>) + 1.0;` with <v> traced
    here through the integer operations on gl_VertexID; that line becomes `<t> = <v>;`. Shader
    Graph's full-screen target flips under the macro unless its global _FlipY is set (`if (_FlipY
    < 0.5) uv.y = 1 - uv.y`, URP never sets it): `_FlipY<0.5` becomes false in the vertex stage.
    Programs without gl_VertexID are returned unchanged."""
    if 'gl_VertexID' not in vs_glsl:
        return vs_glsl, 0
    tags = {}                               # (variable, component or '') -> what it holds

    def comps(var, swz, n=1):
        return [(var, c) for c in swz] if swz else [(var, '')] * n

    def operand_tags(text):
        m = re.fullmatch(_OPERAND, text.strip())
        return [tags.get(k) for k in comps(m.group(1), m.group(2))] if m else None

    def scalar(text):
        t = operand_tags(text)
        return t[0] if t and len(t) == 1 else None

    def value(rhs):
        """Per-component tags of a right-hand side (a list), or None."""
        r = rhs.strip()
        if re.fullmatch(r'(?:' + _VID + r')\s*&\s*2u?', r) or re.fullmatch(r'(?:u?int)\((?:' + _VID + r')\s*&\s*2u?\)', r):
            return ['tri']                  # id & 2
        if re.fullmatch(r'(?:u?int\()?(?:' + _VID + r')\s*&\s*1u?\)?', r):
            return ['bot']                  # id & 1
        if re.fullmatch(r'(?:u?int\()?(?:' + _VID + r')\s*>>\s*1u?\)?', r):
            return ['top']                  # id >> 1
        m = re.fullmatch(r'(?:u?int\()?(' + _OPERAND + r')\)?\s*\+\s*(?:u?int\()?(' + _OPERAND + r')\)?', r)
        if m and {scalar(m.group(1)), scalar(m.group(4))} == {'top', 'bot'}:
            return ['sum']                  # (id >> 1) + (id & 1)
        m = re.fullmatch(r'(?:u?int\()?(' + _OPERAND + r')\)?\s*&\s*1u?', r)
        if m and scalar(m.group(1)) == 'sum':
            return ['quad']                 # ((id >> 1) + (id & 1)) & 1
        m = re.fullmatch(r'(?:float|vec[234])\((' + _OPERAND + r')\)', r)
        if m:
            t = operand_tags(m.group(1))
            return [{'tri': 'tri.f', 'quad': 'quad.f'}.get(x) for x in t] if t else None
        if re.fullmatch(r'float\(1\.0\)', r):
            return [None]
        m = re.fullmatch(r'\(-(' + _OPERAND + r')\)\s*\+\s*(?:1\.0|vec[234]\((?:1\.0,\s*)*1\.0\))', r)
        if m:
            t = operand_tags(m.group(1))
            if t and all(x in ('tri.f', 'quad.f') for x in t):
                return ['flip:' + m.group(1)] * len(t)
        return None

    n = 0
    out = []
    for line in vs_glsl.split('\n'):
        m = _ASSIGN.match(line)
        if m and not line.lstrip().startswith(('//', '#')):
            ind, var, swz, rhs = m.groups()
            v = value(rhs)
            keys = comps(var, swz)
            if v and v[0] and v[0].startswith('flip:'):
                src = v[0][5:]
                line = f'{ind}{var}{"." + swz if swz else ""} = {src};'
                v = operand_tags(src)
                n += 1
            if v is not None and len(v) == 1 and len(keys) > 1:
                v = v * len(keys)
            for i, k in enumerate(keys):
                tags[k] = v[i] if v is not None and i < len(v) else None
            if not swz:                     # a whole vector assigned: its components too
                for c in 'xyzw':
                    tags.pop((var, c), None)
        out.append(line)
    text = '\n'.join(out)
    if re.search(r'^\s*uniform\s+(?:highp\s+|mediump\s+)?float\s+_FlipY\s*;', text, re.M):
        text, k = re.subn(r'\b_FlipY\s*<\s*0\.5\b', 'false', text)
        n += k
    return text, n


def translate_program(translator, vs, ps, serializer=None, unity=None, notes=None):
    """vs, ps: (code, binding info) of the D3D11 vertex and pixel entries (binding info: the
    entry's rest, or Bindings with the parameter entry and shared parameters put back) -> GL
    program text (GLSL 1.50, as Unity's GLCore programs). serializer: the entries' serializer
    version; unity: (major, minor) of the data (default: from the serializer). Up to 2018 the
    text is tidy()'d as Unity 2017-2018 stored it; from 2019.1 Unity's macro blocks stay and
    textures get their units (UNITY_LOCATION), and the uniforms are in Unity's order
    (unity_uniform_order). The vertex stage's full-screen texture coordinates get GL's origin
    (gl_uv_origin; notes, a list: 'VERTEX uv-origin <n>' added where it changed anything).
    Raises Unsupported."""
    unity = unity or unity_line(serializer)
    new = unity >= (2019, 1)
    stages = []
    for code, rest in (vs, ps):
        _, dxbc = split_code(code)
        b = rest if isinstance(rest, Bindings) else Bindings.parse(rest, serializer)
        cont, prog = with_reflection(dxbc, b)
        stages.append((prog, cont, b))
    if [p.stage for p, _, _ in stages] != [1, 0]:
        raise Unsupported('expected a vertex and a pixel shader, got ' + ', '.join(STAGE_NAMES.get(p.stage, '?') for p, _, _ in stages))
    vs_glsl, ps_glsl = translator.translate([c for _, c, _ in stages], flags=FLAGS_2019 if new else None)
    vs_glsl, ps_glsl = gl_fixups(vs_glsl), gl_fixups(ps_glsl)
    vs_glsl, flips = gl_uv_origin(vs_glsl)
    if flips and notes is not None:
        notes.append(f'VERTEX uv-origin {flips}')
    if new:
        vs_glsl = unity_uniform_order(vs_glsl, stages[0][2], stages[0][0])
        ps_glsl = unity_uniform_order(ps_glsl, stages[1][2], stages[1][0])
    return gl_program({'VERTEX': vs_glsl, 'FRAGMENT': ps_glsl}, tidy_up=not new)
