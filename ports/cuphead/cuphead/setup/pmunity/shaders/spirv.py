"""SPIR-V modules: what the Vulkan path reads of them, and the names it gives their variables.

A module is a list of 32-bit words: a 5-word header, then instructions (word count << 16 | opcode,
then the operands). Module keeps the instructions and reads what the converter needs: names,
decorations, types, constants, global variables and the entry point. set_name() / set_member_name()
replace a target's OpName / OpMemberName (or add one in the debug section), so SPIRV-Cross writes
the GLSL with those names; serialize() gives the words back.
"""
import struct

MAGIC = 0x07230203

# opcodes
OP_SOURCE, OP_NAME, OP_MEMBER_NAME, OP_STRING = 3, 5, 6, 7
OP_ENTRY_POINT, OP_EXECUTION_MODE, OP_CAPABILITY = 15, 16, 17
OP_TYPE_VOID, OP_TYPE_BOOL, OP_TYPE_INT, OP_TYPE_FLOAT, OP_TYPE_VECTOR, OP_TYPE_MATRIX = 19, 20, 21, 22, 23, 24
OP_TYPE_IMAGE, OP_TYPE_SAMPLER, OP_TYPE_SAMPLED_IMAGE, OP_TYPE_ARRAY, OP_TYPE_RUNTIME_ARRAY = 25, 26, 27, 28, 29
OP_TYPE_STRUCT, OP_TYPE_POINTER = 30, 32
OP_CONSTANT = 43
OP_VARIABLE = 59
OP_DECORATE, OP_MEMBER_DECORATE = 71, 72
OP_DPDX, OP_DPDY, OP_FWIDTH = 207, 208, 209
OP_DPDX_FINE, OP_DPDY_FINE, OP_FWIDTH_FINE, OP_DPDX_COARSE, OP_DPDY_COARSE, OP_FWIDTH_COARSE = 210, 211, 212, 213, 214, 215
CAP_DERIVATIVE_CONTROL = 51
OP_MODULE_PROCESSED = 330
# the instructions before the debug names (sections 1 - 6 and 7a of the logical layout)
_BEFORE_NAMES = {17, 10, 11, 14, 15, 16, 331, 2, 3, 4, 7, 8, 317}

# decorations
DEC_RELAXED_PRECISION, DEC_BLOCK, DEC_BUFFER_BLOCK, DEC_ROW_MAJOR, DEC_COL_MAJOR = 0, 2, 3, 4, 5
DEC_ARRAY_STRIDE, DEC_MATRIX_STRIDE, DEC_BUILTIN = 6, 7, 11
DEC_NOPERSPECTIVE, DEC_FLAT, DEC_CENTROID, DEC_SAMPLE = 13, 14, 16, 17
DEC_LOCATION, DEC_COMPONENT, DEC_INDEX, DEC_BINDING, DEC_DESCRIPTOR_SET, DEC_OFFSET = 30, 31, 32, 33, 34, 35

# storage classes
SC_UNIFORM_CONSTANT, SC_INPUT, SC_UNIFORM, SC_OUTPUT, SC_PUSH_CONSTANT, SC_STORAGE_BUFFER = 0, 1, 2, 3, 9, 12

# execution models
EXEC_VERTEX, EXEC_TESS_CONTROL, EXEC_TESS_EVAL, EXEC_GEOMETRY, EXEC_FRAGMENT, EXEC_COMPUTE = 0, 1, 2, 3, 4, 5
STAGE_OF_MODEL = {EXEC_VERTEX: 'VERTEX', EXEC_TESS_CONTROL: 'HULL', EXEC_TESS_EVAL: 'DOMAIN',
                  EXEC_GEOMETRY: 'GEOMETRY', EXEC_FRAGMENT: 'FRAGMENT', EXEC_COMPUTE: 'COMPUTE'}

# OpSource languages
SOURCE_LANGUAGES = {0: 'unknown', 1: 'ESSL', 2: 'GLSL', 3: 'OpenCL C', 4: 'OpenCL C++', 5: 'HLSL'}


class SpirvError(ValueError):
    pass


def _string(words):
    """A literal string operand (nul-terminated, padded to words) -> (str, words used)."""
    b = struct.pack('<%dI' % len(words), *words)
    end = b.find(b'\0')
    if end < 0:
        raise SpirvError('unterminated string')
    return b[:end].decode('utf-8', 'replace'), end // 4 + 1


def _string_words(s):
    b = s.encode('utf-8') + b'\0'
    b += b'\0' * (-len(b) % 4)
    return list(struct.unpack('<%dI' % (len(b) // 4), b))


class Type:
    """A SPIR-V type: kind ('void', 'bool', 'int', 'float', 'vector', 'matrix', 'image', 'sampler',
    'sampled_image', 'array', 'runtime_array', 'struct', 'pointer'), and by kind: width / signed,
    element type and count (vector, matrix columns, array length), members (struct), storage
    class and pointee (pointer), and for images dim / depth / arrayed / ms / sampled / format."""

    __slots__ = ('id', 'kind', 'width', 'signed', 'elem', 'count', 'members', 'storage', 'dim', 'depth',
                 'arrayed', 'ms', 'sampled', 'format')

    def __init__(self, id, kind, **kw):
        self.id, self.kind = id, kind
        for k in self.__slots__[2:]:
            setattr(self, k, kw.get(k))


class Module:
    def __init__(self, data):
        if isinstance(data, (bytes, bytearray, memoryview)):
            data = bytes(data)
            if len(data) < 20 or len(data) % 4:
                raise SpirvError('not a SPIR-V module (size)')
            words = list(struct.unpack('<%dI' % (len(data) // 4), data))
        else:
            words = list(data)
        if len(words) < 5 or words[0] != MAGIC:
            raise SpirvError('not a SPIR-V module (magic)')
        self.header = words[:5]
        self.insts = []                 # [(opcode, [operands])]
        i = 5
        while i < len(words):
            n, op = words[i] >> 16, words[i] & 0xffff
            if n == 0 or i + n > len(words):
                raise SpirvError(f'bad instruction length at word {i}')
            self.insts.append((op, words[i + 1:i + n]))
            i += n
        self._read()

    # ---- reading
    def _read(self):
        self.names, self.member_names = {}, {}
        self.decorations = {}           # id -> {decoration: [operands]}
        self.member_decorations = {}    # (struct id, member) -> {decoration: [operands]}
        self.types, self.constants, self.variables = {}, {}, {}   # variables: id -> (type id, storage class)
        self.entry = None               # (execution model, name, function id, interface ids)
        self.capabilities = []
        self.source_language = None
        for op, a in self.insts:
            if op == OP_NAME:
                self.names[a[0]] = _string(a[1:])[0]
            elif op == OP_MEMBER_NAME:
                self.member_names[(a[0], a[1])] = _string(a[2:])[0]
            elif op == OP_DECORATE:
                self.decorations.setdefault(a[0], {})[a[1]] = a[2:]
            elif op == OP_MEMBER_DECORATE:
                self.member_decorations.setdefault((a[0], a[1]), {})[a[2]] = a[3:]
            elif op == OP_ENTRY_POINT and self.entry is None:
                name, used = _string(a[2:])
                self.entry = (a[0], name, a[1], list(a[2 + used:]))
            elif op == OP_CAPABILITY:
                self.capabilities.append(a[0])
            elif op == OP_SOURCE:
                self.source_language = a[0]
            elif op == OP_TYPE_VOID:
                self.types[a[0]] = Type(a[0], 'void')
            elif op == OP_TYPE_BOOL:
                self.types[a[0]] = Type(a[0], 'bool')
            elif op == OP_TYPE_INT:
                self.types[a[0]] = Type(a[0], 'int', width=a[1], signed=bool(a[2]))
            elif op == OP_TYPE_FLOAT:
                self.types[a[0]] = Type(a[0], 'float', width=a[1])
            elif op == OP_TYPE_VECTOR:
                self.types[a[0]] = Type(a[0], 'vector', elem=a[1], count=a[2])
            elif op == OP_TYPE_MATRIX:
                self.types[a[0]] = Type(a[0], 'matrix', elem=a[1], count=a[2])
            elif op == OP_TYPE_IMAGE:
                self.types[a[0]] = Type(a[0], 'image', elem=a[1], dim=a[2], depth=a[3], arrayed=a[4], ms=a[5],
                                        sampled=a[6], format=a[7])
            elif op == OP_TYPE_SAMPLER:
                self.types[a[0]] = Type(a[0], 'sampler')
            elif op == OP_TYPE_SAMPLED_IMAGE:
                self.types[a[0]] = Type(a[0], 'sampled_image', elem=a[1])
            elif op == OP_TYPE_ARRAY:
                self.types[a[0]] = Type(a[0], 'array', elem=a[1], count=a[2])     # count: a constant's id
            elif op == OP_TYPE_RUNTIME_ARRAY:
                self.types[a[0]] = Type(a[0], 'runtime_array', elem=a[1])
            elif op == OP_TYPE_STRUCT:
                self.types[a[0]] = Type(a[0], 'struct', members=list(a[1:]))
            elif op == OP_TYPE_POINTER:
                self.types[a[0]] = Type(a[0], 'pointer', storage=a[1], elem=a[2])
            elif op == OP_CONSTANT and len(a) >= 3:
                self.constants[a[1]] = a[2]
            elif op == OP_VARIABLE:
                self.variables[a[1]] = (a[0], a[2])

    @property
    def stage(self):
        return STAGE_OF_MODEL.get(self.entry[0]) if self.entry else None

    def decoration(self, id, dec, default=None):
        v = self.decorations.get(id, {}).get(dec)
        if v is None:
            return default
        return v[0] if v else True

    def member_decoration(self, struct_id, member, dec, default=None):
        v = self.member_decorations.get((struct_id, member), {}).get(dec)
        if v is None:
            return default
        return v[0] if v else True

    def array_length(self, t):
        """The length of an array type (its count is a constant's id)."""
        return self.constants.get(t.count)

    def pointee(self, var_id):
        """The type a global variable points to (Type), and the variable's storage class."""
        tid, sc = self.variables[var_id]
        return self.types[self.types[tid].elem], sc

    def interface(self, storage):
        """The entry point's interface variables of a storage class (SC_INPUT, SC_OUTPUT), not built-ins."""
        out = []
        for v in self.entry[3] if self.entry else ():
            if v in self.variables and self.variables[v][1] == storage and self.decoration(v, DEC_BUILTIN) is None:
                t, _ = self.pointee(v)
                if t.kind == 'struct' and any(self.member_decoration(t.id, m, DEC_BUILTIN) is not None
                                              for m in range(len(t.members))):
                    continue            # a built-in block (gl_PerVertex)
                out.append(v)
        return out

    def globals(self, *storage):
        """Global variables of the storage classes, in declaration order."""
        return [v for v, (_, sc) in self.variables.items() if sc in storage]

    def describe(self, tid):
        """A short GLSL-like name of a type, for messages and comparisons."""
        t = self.types.get(tid)
        if t is None:
            return f'?{tid}'
        if t.kind in ('void', 'bool'):
            return t.kind
        if t.kind == 'int':
            return ('int' if t.signed else 'uint') + ('' if t.width == 32 else str(t.width))
        if t.kind == 'float':
            return 'float' if t.width == 32 else f'float{t.width}'
        if t.kind == 'vector':
            e = self.describe(t.elem)
            return {'float': '', 'int': 'i', 'uint': 'u', 'bool': 'b'}.get(e, e) + f'vec{t.count}'
        if t.kind == 'matrix':
            col = self.types[t.elem]
            return f'mat{t.count}' if col.count == t.count else f'mat{t.count}x{col.count}'
        if t.kind == 'array':
            return f'{self.describe(t.elem)}[{self.array_length(t)}]'
        return t.kind

    # ---- editing
    def set_name(self, id, name):
        self._replace_name(OP_NAME, [id], name)
        self.names[id] = name

    def set_member_name(self, struct_id, member, name):
        self._replace_name(OP_MEMBER_NAME, [struct_id, member], name)
        self.member_names[(struct_id, member)] = name

    def _replace_name(self, op, key, name):
        self.insts = [(o, a) for o, a in self.insts if not (o == op and a[:len(key)] == key)]
        at = next((i for i, (o, _) in enumerate(self.insts) if o not in _BEFORE_NAMES and o not in (OP_NAME, OP_MEMBER_NAME)),
                  len(self.insts))
        self.insts.insert(at, (op, key + _string_words(name)))

    def replace_opcodes(self, mapping):
        """Rewrites instructions of opcodes in mapping (old -> new; same operands). Returns how many."""
        n = 0
        for i, (op, a) in enumerate(self.insts):
            if op in mapping:
                self.insts[i] = (mapping[op], a)
                n += 1
        return n

    def remove_capability(self, cap):
        self.insts = [(o, a) for o, a in self.insts if not (o == OP_CAPABILITY and a[0] == cap)]
        self.capabilities = [c for c in self.capabilities if c != cap]

    def serialize(self):
        out = list(self.header)
        for op, a in self.insts:
            out.append((len(a) + 1) << 16 | op)
            out += a
        return struct.pack('<%dI' % len(out), *out)
