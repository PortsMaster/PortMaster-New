"""Metal programs (MSL text) of Unity Shader assets -> GLSL ES: a translator for the MSL Unity writes.

Prototype (docs/shaders.md, "macOS builds: Metal programs"). There is no MSL front end to reuse
(Apple's compiler is closed, and no open tool reads MSL), but Unity's MSL is HLSLcc's: the same
DXBC instruction stream it turns into its GL programs, written with Metal's syntax (HLSLcc's
toMetal backend: one statement per DXBC instruction, u_xlat temporaries, the same names). So this
reads that subset of MSL and writes HLSLcc's GL form of it:

  * the constant buffer structs (VGlobals_Type, FGlobals_Type, ...) given as `constant T& name
    [[ buffer(n) ]]` -> plain uniforms (members by their names; matrices are already hlslcc_mtx
    vec4 arrays), named cbuffers (UnityPerDraw, UnityPerMaterial, ...) likewise, as up to 2018;
  * Mtl_VertexIn members (POSITION0 [[ attribute(n) ]]) -> in_POSITION0; Mtl_VertexOut and
    Mtl_FragmentIn members ([[ user(TEXCOORD0) ]]) -> vs_TEXCOORD0; [[ position ]] -> gl_Position /
    gl_FragCoord; Mtl_FragmentOut members ([[ color(n) ]]) -> layout(location = n) outputs;
  * textures (texture2d<float, access::sample> X [[ texture(n) ]] and its sampler) -> one GLSL
    sampler named X (depth2d: X compared, hlslcc_zcmpX); .sample / .sample_compare / .read /
    .gather -> texture / textureLod / texelFetch / textureGather;
  * Metal's types and functions -> GLSL's (fma, rsqrt, rint, select, saturate, as_type, ...), with
    the types the expressions have: vector comparisons (lessThan, ...), scalar conversions MSL
    makes implicitly;
  * function constants at their defaults (no base vertex, no variable rasterization rate, the
    identity render target remap), `#if __METAL_VERSION__ >= n` blocks left out.

translate_stage() takes one stage's MSL; translate_program() a vertex and a fragment stage, as
one GL program (#ifdef VERTEX / #ifdef FRAGMENT). Raises Unsupported for what this subset does
not cover (device buffers, writable textures, tessellation, ...).
"""
import re

from . import glsl
from . import vulkan as VK


class Unsupported(Exception):
    pass


# ---------------------------------------------------------------- tokens

_TOKEN = re.compile(r'''
    (?P<ws>\s+) |
    (?P<num>0[xX][0-9a-fA-F]+[uU]? | (?:\d+\.\d*|\.\d+|\d+)(?:[eE][-+]?\d+)?[fFhHuU]?) |
    (?P<id>[A-Za-z_][A-Za-z_0-9]*(?:::[A-Za-z_][A-Za-z_0-9]*)*) |
    (?P<op>\[\[|\]\]|<<=|>>=|<<|>>|<=|>=|==|!=|&&|\|\||\+\+|--|\+=|-=|\*=|/=|%=|&=|\|=|\^=|->|[-+*/%&|^~!<>=?:;,.(){}\[\]#])
''', re.X)


def tokenize(src):
    out = []
    pos = 0
    while pos < len(src):
        m = _TOKEN.match(src, pos)
        if not m:
            raise Unsupported(f'MSL: cannot read {src[pos:pos + 20]!r}')
        pos = m.end()
        if m.lastgroup != 'ws':
            out.append(m.group(m.lastgroup))
    return out


def preprocess(src):
    """Comments out, `#if __METAL_VERSION__ >= n` blocks dropped (VRR: Unity's variable rasterization
    rate, off on a GL device), other preprocessor lines dropped (XLT_REMAP_O defines)."""
    src = re.sub(r'//[^\n]*|/\*.*?\*/', ' ', src, flags=re.S)
    out, skip = [], []
    for line in src.split('\n'):
        s = line.strip()
        if s.startswith('#'):
            if re.match(r'#\s*if\b', s):
                skip.append('__METAL_VERSION__' in s)
            elif re.match(r'#\s*ifn?def\b', s):
                skip.append(False)
            elif re.match(r'#\s*else\b', s):
                if skip:
                    skip[-1] = not skip[-1] if '__METAL' in s or skip[-1] else skip[-1]
            elif re.match(r'#\s*endif\b', s):
                if skip:
                    skip.pop()
            continue
        if any(skip):
            continue
        out.append(line)
    return '\n'.join(out)


# ---------------------------------------------------------------- types

class T:
    """A value type: base float | int | uint | bool (n components 1-4), mat (cols x rows), array
    (elem, length), struct (name), texture (kind), sampler."""
    __slots__ = ('kind', 'base', 'n', 'rows', 'elem', 'length', 'name')

    def __init__(self, kind, base=None, n=1, rows=None, elem=None, length=None, name=None):
        self.kind, self.base, self.n, self.rows, self.elem, self.length, self.name = kind, base, n, rows, elem, length, name

    def __eq__(self, o):
        return isinstance(o, T) and (self.kind, self.base, self.n, self.rows, self.name, self.length) == \
            (o.kind, o.base, o.n, o.rows, o.name, o.length) and self.elem == o.elem

    def __repr__(self):
        return self.glsl()

    def glsl(self):
        if self.kind == 'vec':
            if self.n == 1:
                return self.base
            return {'float': '', 'int': 'i', 'uint': 'u', 'bool': 'b'}[self.base] + f'vec{self.n}'
        if self.kind == 'mat':
            return f'mat{self.n}' if self.n == self.rows else f'mat{self.n}x{self.rows}'
        if self.kind == 'array':
            return self.elem.glsl()
        return self.name or self.kind


def vec(base, n=1):
    return T('vec', base, n)


FLOAT, INT, UINT, BOOL = vec('float'), vec('int'), vec('uint'), vec('bool')
_BASES = {'float': 'float', 'half': 'float', 'int': 'int', 'uint': 'uint', 'bool': 'bool', 'short': 'int',
          'ushort': 'uint', 'uint32_t': 'uint', 'int32_t': 'int', 'char': 'int', 'uchar': 'uint'}
_TYPE_RE = re.compile(r'^(float|half|int|uint|bool|short|ushort|uint32_t|int32_t|char|uchar)([234])?(?:x([234]))?$')
_TEX = {'texture2d': 'sampler2D', 'texture3d': 'sampler3D', 'texturecube': 'samplerCube', 'texture2d_array': 'sampler2DArray',
        'depth2d': 'sampler2DShadow', 'depthcube': 'samplerCubeShadow', 'depth2d_array': 'sampler2DArrayShadow',
        'texture2d_ms': 'sampler2DMS'}


def parse_type(name):
    """A scalar / vector / matrix type name -> T (None if it is not one)."""
    name = name.replace('metal::', '')
    m = _TYPE_RE.match(name)
    if not m:
        return None
    base = _BASES[m.group(1)]
    if m.group(3):
        return T('mat', 'float', int(m.group(2)), int(m.group(3)))
    return vec(base, int(m.group(2) or 1))


# ---------------------------------------------------------------- expressions

class E:
    """An expression: GLSL text, type, precedence (higher binds tighter)."""
    __slots__ = ('s', 't', 'p')

    def __init__(self, s, t, p=100):
        self.s, self.t, self.p = s, t, p

    def wrap(self, p):
        return self.s if self.p >= p else f'({self.s})'


_SWZ = re.compile(r'^[xyzw]{1,4}$|^[rgba]{1,4}$')
_FUNCS_SAME = {'abs', 'floor', 'ceil', 'fract', 'sqrt', 'exp2', 'log2', 'exp', 'log', 'sin', 'cos', 'tan', 'asin', 'acos',
               'trunc', 'sign', 'normalize', 'min', 'max', 'clamp', 'mix', 'step', 'smoothstep', 'pow', 'reflect',
               'refract', 'cross', 'atan', 'sinh', 'cosh', 'tanh', 'radians', 'degrees'}
_FUNCS_RENAMED = {'rsqrt': 'inversesqrt', 'rint': 'roundEven', 'round': 'round', 'dfdx': 'dFdx', 'dfdy': 'dFdy',
                  'fwidth': 'fwidth', 'atan2': 'atan', 'isnan': 'isnan', 'isinf': 'isinf', 'all': 'all', 'any': 'any'}
_CMP = {'<': 'lessThan', '<=': 'lessThanEqual', '>': 'greaterThan', '>=': 'greaterThanEqual', '==': 'equal',
        '!=': 'notEqual'}
_BINARY = [('||',), ('&&',), ('|',), ('^',), ('&',), ('==', '!='), ('<', '<=', '>', '>='), ('<<', '>>'), ('+', '-'),
           ('*', '/', '%')]
_PREC = {op: 10 + i for i, ops in enumerate(_BINARY) for op in ops}


class Scope:
    def __init__(self, parent=None):
        self.parent, self.vars = parent, {}

    def get(self, name):
        s = self
        while s is not None:
            if name in s.vars:
                return s.vars[name]
            s = s.parent
        return None


class Stage:
    """One stage being translated: its declarations (GLSL lines), symbols and the body writer."""

    def __init__(self, stage):
        self.stage = stage
        self.uniforms = []              # GLSL declaration lines (uniforms and samplers)
        self.ins, self.outs = [], []
        self.consts = []
        self.helpers = set()
        self.structs = {}               # name -> [(name, T, attrs)]
        self.cbuffers = {}              # parameter name -> struct name
        self.textures = {}              # name -> (GLSL sampler type, MSL kind)
        self.globals = Scope()
        self.io = {}                    # ('input' | 'output', member) -> (GLSL name, T)
        self.fconst = {}                # function constants: name -> GLSL value text
        self.needs_es31 = None


class Parser:
    def __init__(self, toks, st):
        self.t, self.i, self.st = toks, 0, st

    def peek(self, k=0):
        j = self.i + k
        return self.t[j] if j < len(self.t) else None

    def next(self):
        tok = self.peek()
        if tok is None:
            raise Unsupported('MSL: unexpected end')
        self.i += 1
        return tok

    def expect(self, tok):
        got = self.next()
        if got != tok:
            raise Unsupported(f'MSL: expected {tok!r}, got {got!r} near {" ".join(self.t[max(0, self.i - 8):self.i + 4])}')
        return got

    def accept(self, tok):
        if self.peek() == tok:
            self.i += 1
            return True
        return False

    # ---- expressions
    def unary(self, scope):
        if self.peek() in ('-', '!', '~', '+'):
            op = self.next()
            a = self.unary(scope)
            if op == '!' and a.t.kind == 'vec' and a.t.n > 1:
                return E(f'not({a.s})', a.t)
            if op == '!' and a.t.base != 'bool':
                return E(f'!{bool_of(a).wrap(90)}', BOOL, 90)
            if op == '+':
                return a
            return E(f'{op}{a.wrap(90)}', a.t, 90)
        return self.postfix(scope)

    def expr(self, scope, min_prec=0):
        a = self.unary(scope)
        while True:
            op = self.peek()
            if op == '?' and min_prec <= 5:
                self.next()
                b = self.expr(scope, 0)
                self.expect(':')
                c = self.expr(scope, 5)
                if a.t.kind == 'vec' and a.t.n > 1:
                    raise Unsupported('MSL: ?: with a vector condition')
                t = b.t if b.t == c.t else unify(b.t, c.t)
                a = E(f'{bool_of(a).wrap(6)} ? {convert(b, t).wrap(6)} : {convert(c, t).wrap(5)}', t, 5)
                continue
            p = _PREC.get(op)
            if p is None or p < min_prec or (op in ('<', '>') and self.peek(1) == '>'):
                return a
            self.next()
            b = self.expr(scope, p + 1)
            a = binary(op, a, b)

    def postfix(self, scope):
        a = self.primary(scope)
        while True:
            tok = self.peek()
            if tok == '.':
                self.next()
                name = self.next()
                if self.peek() == '(':
                    a = self.method(scope, a, name)
                    continue
                a = member(self.st, a, name)
            elif tok == '[':
                self.next()
                idx = self.expr(scope)
                self.expect(']')
                if idx.t.kind == 'vec' and idx.t.base == 'uint':
                    idx = E(f'int({idx.s})', INT)
                if a.t.kind == 'array':
                    a = E(f'{a.wrap(100)}[{idx.s}]', a.t.elem)
                elif a.t.kind == 'mat':
                    a = E(f'{a.wrap(100)}[{idx.s}]', vec('float', a.t.rows))
                elif a.t.kind == 'vec' and a.t.n > 1:
                    a = E(f'{a.wrap(100)}[{idx.s}]', vec(a.t.base))
                else:
                    raise Unsupported(f'MSL: indexing {a.t}')
            elif tok in ('++', '--'):
                self.next()
                a = E(f'{a.s}{tok}', a.t, 95)
            else:
                return a

    def args(self, scope):
        self.expect('(')
        out = []
        if self.accept(')'):
            return out
        while True:
            out.append(self.expr(scope))
            if self.accept(')'):
                return out
            self.expect(',')

    def primary(self, scope):
        tok = self.next()
        if tok == '(':
            e = self.expr(scope)
            self.expect(')')
            return E(e.s, e.t, e.p if e.p >= 100 else e.p)
        if re.match(r'^(0[xX][0-9a-fA-F]+|\d|\.\d)', tok):
            return literal(tok)
        if tok in ('true', 'false'):
            return E(tok, BOOL)
        if tok.startswith('component::') and tok[11:] in ('x', 'y', 'z', 'w'):
            return E('component:' + str('xyzw'.index(tok[11:])), T('opt'))
        if tok == 'as_type':
            self.expect('<')
            t = parse_type(self.next())
            self.expect('>')
            (x,) = self.args(scope)
            return bitcast(x, t)
        t = parse_type(tok)
        if t is not None and self.peek() == '(':
            return construct(t, self.args(scope))
        if tok in self.st.fconst and self.peek() != '(':
            return E(self.st.fconst[tok], BOOL if self.st.fconst[tok] in ('true', 'false') else UINT)
        if self.peek() == '(':
            return call(self.st, tok, self.args(scope))
        v = scope.get(tok)
        if v is None:
            raise Unsupported(f'MSL: unknown name {tok!r}')
        return E(v[0], v[1])

    def method(self, scope, obj, name):
        tex = self.st.textures.get(obj.s)
        if tex is None:
            raise Unsupported(f'MSL: method {name} on {obj.s}')
        args = self.args(scope)
        gl, kind = tex
        opts = [a for a in args if isinstance(a, E) and a.t.kind == 'opt']
        args = [a for a in args if a not in opts]
        shadow = 'Shadow' in gl
        ms = 'MS' in gl
        dims = {'sampler2D': 2, 'sampler3D': 3, 'samplerCube': 3, 'sampler2DArray': 3, 'sampler2DShadow': 2,
                'samplerCubeShadow': 3, 'sampler2DArrayShadow': 3, 'sampler2DMS': 2}[gl]
        rt = FLOAT if shadow and name != 'gather' else vec('float', 4)
        if name in ('sample', 'sample_compare'):
            if len(args) < 2:
                raise Unsupported('MSL: sample without coordinates')
            coord = args[1]
            if gl in ('sampler2DArray', 'sampler2DArrayShadow'):
                if len(args) < 3:
                    raise Unsupported('MSL: array sample without a layer')
                coord = E(f'vec3({convert(coord, vec("float", 2)).s}, {convert(args[2], FLOAT).s})', vec('float', 3))
                args = args[:2] + args[3:]
            coord = convert(coord, vec('float', dims))
            name_gl = ('hlslcc_zcmp' + obj.s) if shadow else obj.s
            if name == 'sample_compare':
                if not shadow:
                    raise Unsupported('MSL: sample_compare on a texture without depth')
                ref = convert(args[2], FLOAT)
                coord = E(f'vec{dims + 1}({coord.s}, {ref.s})', vec('float', dims + 1))
                if gl == 'samplerCubeShadow' or gl == 'sampler2DArrayShadow':
                    coord = E(coord.s, vec('float', 4))
            elif shadow:
                raise Unsupported('MSL: sample (not compare) of a depth texture')
            lod = next((o for o in opts if o.s.startswith('level:')), None)
            bias = next((o for o in opts if o.s.startswith('bias:')), None)
            grad = next((o for o in opts if o.s.startswith('gradient:')), None)
            if lod is not None:
                if gl == 'samplerCubeShadow' or gl == 'sampler2DArrayShadow':
                    return E(f'texture({name_gl}, {coord.s})', rt)       # (no textureLod on these in GLSL ES)
                return E(f'textureLod({name_gl}, {coord.s}, {lod.s[6:]})', rt)
            if grad is not None:
                return E(f'textureGrad({name_gl}, {coord.s}, {grad.s[9:]})', rt)
            if bias is not None:
                return E(f'texture({name_gl}, {coord.s}, {bias.s[5:]})', rt)
            return E(f'texture({name_gl}, {coord.s})', rt)
        if name == 'read':
            if not args:
                raise Unsupported('MSL: read without coordinates')
            n = {'sampler2D': 2, 'sampler3D': 3, 'sampler2DArray': 3, 'sampler2DMS': 2}.get(gl)
            if n is None:
                raise Unsupported(f'MSL: read of {gl}')
            c = convert(args[0], vec('int', 2 if gl != 'sampler3D' else 3))
            rest = args[1:]
            if gl == 'sampler2DArray':
                c = E(f'ivec3({c.s}, {convert(rest[0], INT).s})', vec('int', 3))
                rest = rest[1:]
            lod = convert(rest[0], INT).s if rest else '0'
            if ms:
                self.st.needs_es31 = 'multisampled texture'
            return E(f'texelFetch({obj.s}, {c.s}, {lod})', vec('float', 4))
        if name == 'gather':
            self.st.needs_es31 = 'textureGather'
            comp = next((o for o in opts if o.s.startswith('component:')), None)
            coord = convert(args[1], vec('float', dims))
            c = f', {comp.s[10:]}' if comp else ''
            off = args[2] if len(args) > 2 else None
            if off is not None and re.sub(r'\s', '', off.s) not in ('ivec2(0)', 'ivec2(0,0)'):
                return E(f'textureGatherOffset({obj.s}, {coord.s}, {convert(off, vec("int", 2)).s}{c})', vec('float', 4))
            return E(f'textureGather({obj.s}, {coord.s}{c})', vec('float', 4))
        if name in ('get_width', 'get_height', 'get_depth'):
            lod = convert(args[0], INT).s if args else '0'
            k = {'get_width': 'x', 'get_height': 'y', 'get_depth': 'z'}[name]
            return E(f'uint(textureSize({obj.s}, {lod}).{k})', UINT)
        raise Unsupported(f'MSL: texture method {name}')

    # ---- statements
    def block(self, scope, out, ind):
        self.expect('{')
        inner = Scope(scope)
        while not self.accept('}'):
            self.statement(inner, out, ind)

    def statement(self, scope, out, ind):
        tok = self.peek()
        pad = '    ' * ind
        if tok == '{':
            out.append(pad + '{')
            self.block(scope, out, ind + 1)
            out.append(pad + '}')
            return
        if tok == ';':
            self.next()
            return
        if tok == 'if':
            self.next()
            self.expect('(')
            c = self.expr(scope)
            self.expect(')')
            if c.s == 'false' and self.peek() != '{' or c.s == 'false' and not self._has_else():
                self.body(scope, [], ind)       # (a function constant off: base vertex, VRR)
                return
            out.append(f'{pad}if({bool_of(c).s}){{')
            self.body(scope, out, ind)
            while self.peek() == 'else':
                self.next()
                if self.peek() == 'if':
                    self.next()
                    self.expect('(')
                    c = self.expr(scope)
                    self.expect(')')
                    out.append(f'{pad}}} else if({bool_of(c).s}){{')
                    self.body(scope, out, ind)
                else:
                    out.append(f'{pad}}} else {{')
                    self.body(scope, out, ind)
            out.append(pad + '}')
            return
        if tok == 'while':
            self.next()
            self.expect('(')
            c = self.expr(scope)
            self.expect(')')
            out.append(f'{pad}while({bool_of(c).s}){{')
            self.body(scope, out, ind)
            out.append(pad + '}')
            return
        if tok == 'for':
            self.next()
            self.expect('(')
            inner = Scope(scope)
            init = []
            if not self.accept(';'):
                self.simple(inner, init, 0)
                self.expect(';')
            cond = '' if self.peek() == ';' else bool_of(self.expr(inner)).s
            self.expect(';')
            step = '' if self.peek() == ')' else self.assign_expr(inner)
            self.expect(')')
            out.append(f'{pad}for({(init[0].strip() if init else "")} ; {cond} ; {step}){{')
            self.body(inner, out, ind)
            out.append(pad + '}')
            return
        if tok == 'switch':
            self.next()
            self.expect('(')
            c = convert(self.expr(scope), INT)
            self.expect(')')
            out.append(f'{pad}switch({c.s}){{')
            self.expect('{')
            inner = Scope(scope)
            while not self.accept('}'):
                if self.accept('case'):
                    v = self.expr(inner)
                    self.expect(':')
                    out.append(f'{pad}    case {convert(v, INT).s}:')
                elif self.accept('default'):
                    self.expect(':')
                    out.append(f'{pad}    default:')
                else:
                    self.statement(inner, out, ind + 2)
            out.append(pad + '}')
            return
        if tok in ('break', 'continue'):
            self.next()
            self.expect(';')
            out.append(f'{pad}{tok};')
            return
        if tok == 'return':
            self.next()
            if not self.accept(';'):
                self.expr(scope)
                self.expect(';')
            out.append(f'{pad}return;')
            return
        if tok == 'discard_fragment':
            self.next()
            self.expect('(')
            self.expect(')')
            self.expect(';')
            out.append(f'{pad}discard;')
            return
        if tok == 'constexpr':
            # an inline sampler state (constexpr sampler s(...)): GL samples with the texture's own
            self.next()
            self.next()
            scope.vars[self.next()] = ('sampler', T('sampler'))
            while self.next() != ';':
                pass
            return
        line = []
        self.simple(scope, line, ind)
        self.expect(';')
        out += [l + ';' for l in line]

    def _has_else(self):
        """Whether the block at the parser's position is followed by else."""
        if self.peek() != '{':
            return False
        j, depth = self.i, 0
        while j < len(self.t):
            depth += self.t[j] == '{'
            depth -= self.t[j] == '}'
            j += 1
            if depth == 0:
                break
        return j < len(self.t) and self.t[j] == 'else'

    def body(self, scope, out, ind):
        if self.peek() == '{':
            self.block(scope, out, ind + 1)
        else:
            self.statement(Scope(scope), out, ind + 1)

    def simple(self, scope, out, ind):
        """A declaration or an expression statement (without its ';')."""
        pad = '    ' * ind
        tok = self.peek()
        quals = []
        while tok in ('const', 'thread', 'constant'):
            quals.append(self.next())
            tok = self.peek()
        if tok in self.st.structs and re.match(r'^[A-Za-z_]', self.peek(1) or ''):
            self.next()
            name = self.next()
            if name != 'output':
                raise Unsupported(f'MSL: local struct {tok} {name}')
            return
        t = parse_type(tok) if tok else None
        if t is not None and self.peek(1) not in ('(', None) and re.match(r'^[A-Za-z_]', self.peek(1) or ''):
            self.next()
            first = True
            while True:
                name = self.next()
                vt = t
                arr = ''
                if self.accept('['):
                    n = self.next()
                    self.expect(']')
                    vt = T('array', elem=t, length=int(n, 0))
                    arr = f'[{int(n, 0)}]'
                init = ''
                if self.accept('='):
                    if self.peek() == '{':
                        raise Unsupported('MSL: brace initializer in a function')
                    init = ' = ' + convert(self.expr(scope), t).s
                scope.vars[name] = (name, vt)
                q = 'const ' if 'const' in quals and init else ''
                out.append(f'{pad}{q}{t.glsl()} {name}{arr}{init}')
                if not self.accept(','):
                    break
                first = False
            return
        out.append(pad + self.assign_expr(scope))

    def assign_expr(self, scope):
        lhs = self.expr(scope, 90) if self.peek() not in ('++', '--') else None
        op = self.peek()
        if lhs is None:
            op = self.next()
            x = self.expr(scope, 90)
            return f'{op}{x.s}'
        if op in ('=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<=', '>>='):
            self.next()
            rhs = self.expr(scope)
            if op == '=':
                return f'{lhs.s} = {convert(rhs, lhs.t).s}'
            b = binary(op[:-1], lhs, rhs)
            return f'{lhs.s} = {convert(b, lhs.t).s}'
        if lhs.p == 95:                 # x++ already in the text
            return lhs.s
        return lhs.s


# ---------------------------------------------------------------- typed operations

def literal(tok):
    t = tok
    if re.match(r'^0[xX]', t):
        if t[-1] in 'uU':
            return E(t, UINT)
        v = int(t, 16)
        return E(str(v) if v < 2 ** 31 else f'{v}u', INT if v < 2 ** 31 else UINT)
    if t[-1] in 'uU':
        return E(t[:-1] + 'u', UINT)
    if t[-1] in 'fFhH':
        t = t[:-1]
    if re.match(r'^\d+$', t):
        return E(t, INT)
    if t.endswith('.'):
        t += '0'
    if t.startswith('.'):
        t = '0' + t
    return E(t, FLOAT)


def unify(a, b):
    if a.kind != 'vec' or b.kind != 'vec':
        return a
    n = max(a.n, b.n)
    order = ['bool', 'int', 'uint', 'float']
    base = a.base if order.index(a.base) >= order.index(b.base) else b.base
    return vec(base, n)


def convert(e, t):
    """e as type t, converting the base type (MSL converts scalars implicitly; GLSL does not) and
    widening a scalar to a vector."""
    if e.t == t or t.kind != 'vec' or e.t.kind != 'vec':
        return e
    if e.t.base == t.base and e.t.n == t.n:
        return e
    if e.t.n == 1 and t.n > 1:
        if e.t.base != t.base:
            e = E(f'{t.base}({e.s})', vec(t.base))
        return E(f'{t.glsl()}({e.s})', t)
    if e.t.n != t.n:
        if e.t.n > t.n:
            e = E(f'{e.wrap(100)}.{"xyzw"[:t.n]}', vec(e.t.base, t.n))
        else:
            raise Unsupported(f'MSL: {e.t} used as {t}')
    if e.t.base != t.base:
        return E(f'{t.glsl()}({e.s})', t)
    return e


def bool_of(e):
    if e.t.kind == 'vec' and e.t.base == 'bool':
        return e
    if e.t.kind == 'vec' and e.t.n == 1:
        zero = {'float': '0.0', 'int': '0', 'uint': '0u'}[e.t.base]
        return E(f'{e.wrap(12)} != {zero}', BOOL, 11)
    raise Unsupported(f'MSL: {e.t} as a condition')


def binary(op, a, b):
    p = _PREC[op]
    if a.t.kind == 'mat' or b.t.kind == 'mat':
        if op != '*':
            raise Unsupported(f'MSL: matrix {op}')
        if a.t.kind == 'mat' and b.t.kind == 'vec':
            t = vec('float', a.t.rows)
        elif b.t.kind == 'mat' and a.t.kind == 'vec':
            t = vec('float', b.t.n)
        else:
            t = a.t if a.t.kind == 'mat' else b.t
        return E(f'{a.wrap(p)} * {b.wrap(p + 1)}', t, p)
    if a.t.kind != 'vec' or b.t.kind != 'vec':
        raise Unsupported(f'MSL: {op} on {a.t} and {b.t}')
    if op in ('&&', '||'):
        if a.t.n > 1 or b.t.n > 1:
            n = max(a.t.n, b.t.n)
            a2, b2 = convert(a, vec('bool', n)), convert(b, vec('bool', n))
            return E(f'bvec{n}(' + ', '.join(f'{a2.wrap(100)}.{k} {op} {b2.wrap(100)}.{k}' for k in 'xyzw'[:n]) + ')',
                     vec('bool', n))
        return E(f'{bool_of(a).wrap(p)} {op} {bool_of(b).wrap(p + 1)}', BOOL, p)
    t = unify(a.t, b.t)
    if op in _CMP:
        a2, b2 = convert(a, t), convert(b, t)
        if t.n > 1:
            return E(f'{_CMP[op]}({a2.s}, {b2.s})', vec('bool', t.n))
        return E(f'{a2.wrap(p)} {op} {b2.wrap(p + 1)}', BOOL, p)
    if op in ('&', '|', '^') and t.base == 'bool':
        if t.n > 1:
            raise Unsupported(f'MSL: {op} on bool vectors')
        return E(f'{a.wrap(p)} {op * 2 if op != "^" else "^^"} {b.wrap(p + 1)}', BOOL, p)
    if op in ('<<', '>>'):
        # GLSL: shift by int/uint of matching size, result the left's type
        bb = b if b.t.n == a.t.n or b.t.n == 1 else convert(b, vec(b.t.base, a.t.n))
        return E(f'{a.wrap(p)} {op} {bb.wrap(p + 1)}', a.t, p)
    if op == '%' and t.base == 'float':
        a2, b2 = convert(a, t), convert(b, t)
        return E(f'({a2.wrap(100)} - {b2.wrap(100)} * trunc({a2.s} / {b2.wrap(15)}))', t)
    a2 = convert(a, vec(t.base, a.t.n))
    b2 = convert(b, vec(t.base, b.t.n))
    return E(f'{a2.wrap(p)} {op} {b2.wrap(p + 1)}', t, p)


def construct(t, args):
    if t.kind == 'mat':
        return E(f'{t.glsl()}({", ".join(convert(a, FLOAT if a.t.n == 1 else a.t).s for a in args)})', t)
    if len(args) == 1:
        a = args[0]
        if a.t.kind == 'vec' and a.t.n == t.n and a.t.base == t.base:
            return E(a.s, t, a.p)
        if a.t.kind == 'vec' and a.t.n > t.n:
            a = E(f'{a.wrap(100)}.{"xyzw"[:t.n]}', vec(a.t.base, t.n))
        return E(f'{t.glsl()}({a.s})', t)
    parts = []
    for a in args:
        if a.t.kind != 'vec':
            raise Unsupported(f'MSL: {t} from {a.t}')
        parts.append(convert(a, vec(t.base, a.t.n)).s if a.t.base != t.base else a.s)
    return E(f'{t.glsl()}({", ".join(parts)})', t)


def bitcast(x, t):
    s, d = x.t.base, t.base
    if x.t.n != t.n:
        raise Unsupported(f'MSL: as_type<{t}> of {x.t}')
    if s == d:
        return x
    if s == 'float':
        return E(f'{"floatBitsToInt" if d == "int" else "floatBitsToUint"}({x.s})', t)
    if d == 'float':
        return E(f'{"intBitsToFloat" if s == "int" else "uintBitsToFloat"}({x.s})', t)
    return E(f'{t.glsl()}({x.s})', t)


def call(st, name, args):
    name = name.replace('metal::', '').replace('precise::', '').replace('fast::', '')
    if name == 'fma':
        a, b, c = args
        t = unify(unify(a.t, b.t), c.t)
        return E(f'{convert(a, t).wrap(30)} * {convert(b, t).wrap(30)} + {convert(c, t).wrap(28)}', t, 28)
    if name == 'saturate':
        (a,) = args
        return E(f'clamp({a.s}, 0.0, 1.0)', a.t)
    if name == 'select':
        a, b, c = args
        t = unify(a.t, b.t)
        a, b = convert(a, t), convert(b, t)
        if t.n == 1:
            return E(f'{bool_of(c).wrap(6)} ? {b.wrap(6)} : {a.wrap(5)}', t, 5)
        c = convert(c, vec('bool', t.n)) if c.t.base == 'bool' else E(f'bvec{t.n}({c.s})', vec('bool', t.n))
        if t.base == 'float':
            return E(f'mix({a.s}, {b.s}, {c.s})', t)
        comps = ', '.join(f'({c.wrap(100)}.{k} ? {b.wrap(100)}.{k} : {a.wrap(100)}.{k})' for k in 'xyzw'[:t.n])
        return E(f'{t.glsl()}({comps})', t)
    if name in ('level', 'bias', 'min_lod_clamp'):
        (a,) = args
        return E(f'{"level" if name == "level" else name}:{convert(a, FLOAT).s}', T('opt'))
    if name in ('gradient2d', 'gradient3d', 'gradientcube'):
        n = 2 if name == 'gradient2d' else 3
        return E('gradient:' + ', '.join(convert(a, vec('float', n)).s for a in args), T('opt'))
    if name == 'component::x' or name.startswith('component'):
        raise Unsupported('MSL: gather component')
    if name in ('dot', 'length', 'distance'):
        t = unify(args[0].t, args[-1].t)
        return E(f'{name}({", ".join(convert(a, t).s for a in args)})', vec(t.base))
    if name == 'bitFieldInsert':
        w, o, a, b = args
        t = unify(unify(w.t, o.t), unify(a.t, b.t))
        st.helpers.add(t.glsl())
        return E(f'pm_bitFieldInsert({", ".join(convert(x, t).s for x in (w, o, a, b))})', t)
    if name in ('popcount', 'reverse_bits', 'extract_bits', 'insert_bits', 'ctz', 'clz'):
        raise Unsupported(f'MSL: {name}')
    if name in _FUNCS_SAME or name in _FUNCS_RENAMED:
        gl = _FUNCS_RENAMED.get(name, name)
        if name in ('all', 'any'):
            return E(f'{gl}({args[0].s})', BOOL)
        if name in ('isnan', 'isinf'):
            return E(f'{gl}({args[0].s})', vec('bool', args[0].t.n))
        t = args[0].t
        for a in args[1:]:
            t = unify(t, a.t)
        if name in ('mix', 'clamp', 'min', 'max', 'step', 'smoothstep', 'pow', 'atan2'):
            cargs = []
            for a in args:
                cargs.append(convert(a, t if a.t.n == t.n or a.t.n > 1 else vec(t.base)).s)
            return E(f'{gl}({", ".join(cargs)})', t)
        return E(f'{gl}({", ".join(convert(a, t).s for a in args)})', t)
    raise Unsupported(f'MSL: function {name}')


def member(st, obj, name):
    t = obj.t
    if t.kind == 'struct':
        key = (obj.s, name)
        if key in st.io:
            n, mt = st.io[key]
            return E(n, mt)
        mem = st.structs.get(t.name)
        if mem is None:
            raise Unsupported(f'MSL: struct {t.name}')
        for mn, mt, _ in mem:
            if mn == name:
                if obj.s in st.cbuffers:
                    return E(name, mt)
                return E(f'{obj.wrap(100)}.{name}', mt)
        raise Unsupported(f'MSL: {t.name} has no {name}')
    if t.kind == 'vec':
        if not _SWZ.match(name) or t.n == 1 and name not in ('x', 'r'):
            if t.n == 1 and re.match(r'^[xr]+$', name):
                return E(f'{t.glsl()}({obj.s})' if len(name) == 1 else f'{vec(t.base, len(name)).glsl()}({obj.s})',
                         vec(t.base, len(name)))
            raise Unsupported(f'MSL: .{name} of {t}')
        if t.n == 1:
            return obj
        return E(f'{obj.wrap(100)}.{name}', vec(t.base, len(name)))
    raise Unsupported(f'MSL: .{name} of {t}')


# ---------------------------------------------------------------- top level

def _attrs(p):
    """[[ a, b(c) ]] at the parser's position -> list of attribute strings."""
    out = []
    while p.accept('[['):
        cur, depth = [], 0
        while True:
            tok = p.next()
            if tok == ']]' and depth == 0:
                break
            if tok == '(':
                depth += 1
            elif tok == ')':
                depth -= 1
            if tok == ',' and depth == 0:
                out.append(''.join(cur))
                cur = []
                continue
            cur.append(tok)
        if cur:
            out.append(''.join(cur))
    return out


def _skip_braces(p):
    p.expect('{')
    depth = 1
    while depth:
        tok = p.next()
        depth += tok == '{'
        depth -= tok == '}'


def translate_stage(src, precision='highp'):
    """One stage's MSL -> (stage 'VERTEX' | 'FRAGMENT', Stage with GLSL parts, body lines)."""
    toks = tokenize(preprocess(src))
    toks = [t for t in toks]
    st = Stage(None)
    p = Parser(toks, st)
    body = None
    while p.peek() is not None:
        tok = p.peek()
        if tok == 'using':
            while p.next() != ';':
                pass
        elif tok == 'struct':
            p.next()
            name = p.next()
            p.expect('{')
            mem = []
            while not p.accept('}'):
                ty = p.next()
                while ty in ('constant', 'const'):
                    ty = p.next()
                if p.peek() in ('*', '&'):
                    p.next()
                    mn = p.next()
                    p.expect(';')
                    mem.append((mn, T('ptr'), []))
                    continue
                t = parse_type(ty)
                if t is None:
                    t = T('struct', name=ty) if ty in st.structs else None
                if t is None:
                    raise Unsupported(f'MSL: struct member type {ty}')
                mn = p.next()
                if p.accept('['):
                    n = p.next()
                    p.expect(']')
                    t = T('array', elem=t, length=int(n, 0))
                at = _attrs(p)
                p.expect(';')
                mem.append((mn, t, at))
            p.expect(';')
            st.structs[name] = mem
        elif tok == 'template':
            # HLSLcc's helper templates (bitFieldInsert): their calls are written as GLSL helpers
            while p.next() != '{':
                pass
            p.i -= 1
            _skip_braces(p)
            p.accept(';')
        elif tok in ('constant', 'constexpr'):
            decl = []
            while p.peek() != ';':
                decl.append(p.next())
            p.next()
            text = ' '.join(decl)
            m = re.search(r'\b(\w+) \[\[ function_constant \( (\d+) \) \]\]$', text)
            if m:
                st.fconst[m.group(1)] = 'false' if decl[1] == 'bool' else '0x76543210u'
                continue
            m = re.match(r'^constant const uint (rp_output_remap_(\d+)) = ', text)
            if m:
                st.fconst[m.group(1)] = f'{m.group(2)}u'
                continue
            if 'xlt_remap_o' in text:
                continue
            m = re.match(r'^constexpr sampler (\w+) \(', text)
            if m:
                st.globals.vars[m.group(1)] = ('sampler', T('sampler'))
                continue
            m = re.match(r'^constant (\w+) (\w+) \[ (\d+) \] = \{ (.*) \}$', text)
            if m:
                t = parse_type(m.group(1))
                inner = Parser(tokenize(m.group(4)), st)
                vals = []
                while inner.peek() is not None:
                    vals.append(convert(inner.expr(st.globals), t).s)
                    inner.accept(',')
                n = int(m.group(3))
                st.consts.append(f'const {t.glsl()} {m.group(2)}[{n}] = {t.glsl()}[{n}]({", ".join(vals)});')
                st.globals.vars[m.group(2)] = (m.group(2), T('array', elem=t, length=n))
                continue
            raise Unsupported(f'MSL: global {text[:80]}')
        elif tok in ('vertex', 'fragment'):
            st.stage = 'VERTEX' if p.next() == 'vertex' else 'FRAGMENT'
            ret = p.next()
            p.expect('xlatMtlMain')
            p.expect('(')
            params = []
            while not p.accept(')'):
                ptoks = []
                depth = 0
                while True:
                    tk = p.peek()
                    if tk == '[[':
                        break
                    if tk == '<':
                        depth += 1
                    if tk == '>':
                        depth -= 1
                    if tk in (',', ')') and depth == 0:
                        break
                    ptoks.append(p.next())
                at = _attrs(p)
                params.append((ptoks, at))
                p.accept(',')
            _declare(st, ret, params)
            out = []
            p.expect('{')
            scope = Scope(st.globals)
            while not p.accept('}'):
                p.statement(scope, out, 1)
            body = out
        else:
            raise Unsupported(f'MSL: top level {tok!r}')
    if body is None:
        raise Unsupported('MSL: no entry point')
    return st, body


def _declare(st, ret, params):
    sc = st.globals
    if st.stage == 'VERTEX' and ret != 'Mtl_VertexOut' or st.stage == 'FRAGMENT' and ret != 'Mtl_FragmentOut':
        raise Unsupported(f'MSL: entry returns {ret}')
    for mn, mt, at in st.structs.get(ret, []):
        a = ','.join(at)
        if st.stage == 'VERTEX':
            if a.startswith('position'):
                st.io[('output', mn)] = ('gl_Position', mt)
            elif a.startswith('user('):
                sem = re.match(r'user\((\w+)\)', a).group(1)
                interp = 'flat ' if 'flat' in a else ''
                st.outs.append(f'{interp}out {mt.glsl()} vs_{sem};')
                st.io[('output', mn)] = (f'vs_{sem}', mt)
            elif a.startswith('point_size'):
                st.io[('output', mn)] = ('gl_PointSize', mt)
            else:
                raise Unsupported(f'MSL: vertex output [[ {a} ]]')
        else:
            m = re.match(r'color\(([\w\[\]]+)\)', a)
            if m:
                loc = m.group(1)
                loc = st.fconst.get(loc, loc).rstrip('u')
                if not loc.isdigit():
                    m2 = re.match(r'xlt_remap_o\[(\d+)\]', m.group(1))
                    loc = m2.group(1) if m2 else None
                if loc is None:
                    raise Unsupported(f'MSL: output [[ {a} ]]')
                st.outs.append(f'layout(location = {loc}) out {mt.glsl()} {mn};')
                st.io[('output', mn)] = (mn, mt)
            elif a.startswith('depth'):
                st.io[('output', mn)] = ('gl_FragDepth', mt)
            else:
                raise Unsupported(f'MSL: fragment output [[ {a} ]]')
    sc.vars['output'] = ('output', T('struct', name=ret))
    for ptoks, at in params:
        a = ','.join(at)
        if 'function_constant' in a:
            # (base vertex, VRR: function constants off; their code is left out)
            sc.vars[ptoks[-1]] = ('0u', UINT)
            continue
        name = ptoks[-1]
        if ptoks[0] == 'constant' and ptoks[-2] == '&':
            sname = ptoks[1]
            st.cbuffers[name] = sname
            sc.vars[name] = (name, T('struct', name=sname))
            for mn, mt, _ in st.structs[sname]:
                if mt.kind == 'struct' or mt.kind == 'array' and mt.elem.kind == 'struct':
                    raise Unsupported(f'MSL: constant buffer {sname} has struct members (GPU instancing data)')
                arr = f'[{mt.length}]' if mt.kind == 'array' else ''
                st.uniforms.append(f'uniform {mt.glsl()} {mn}{arr};')
            continue
        if ptoks[0] in ('device', 'const') or '*' in ptoks:
            raise Unsupported(f'MSL: device buffer {name}')
        kind = ptoks[0]
        if kind in _TEX:
            acc = ' '.join(ptoks)
            if 'access::write' in acc or 'access::read_write' in acc:
                raise Unsupported(f'MSL: writable texture {name}')
            gl = _TEX[kind]
            st.textures[name] = (gl, kind)
            sc.vars[name] = (name, T('texture', name=gl))
            if 'Shadow' in gl:
                st.uniforms.append(f'uniform {gl.replace("Shadow", "")} {name};')
                st.uniforms.append(f'uniform {gl} hlslcc_zcmp{name};')
            else:
                st.uniforms.append(f'uniform {gl} {name};')
            if gl == 'sampler2DMS':
                st.needs_es31 = 'multisampled texture'
            continue
        if kind == 'sampler':
            sc.vars[name] = (name, T('sampler'))
            continue
        if a == 'stage_in':
            sname = ptoks[0]
            for mn, mt, mat in st.structs[sname]:
                ma = ','.join(mat)
                if st.stage == 'VERTEX':
                    if not ma.startswith('attribute('):
                        raise Unsupported(f'MSL: vertex input [[ {ma} ]]')
                    st.ins.append(f'in {mt.glsl()} in_{mn};')
                    st.io[(name, mn)] = (f'in_{mn}', mt)
                else:
                    m = re.match(r'user\((\w+)\)', ma)
                    if m:
                        interp = 'flat ' if 'flat' in ma else ''
                        st.ins.append(f'{interp}in {mt.glsl()} vs_{m.group(1)};')
                        st.io[(name, mn)] = (f'vs_{m.group(1)}', mt)
                    elif ma.startswith('position'):
                        st.io[(name, mn)] = ('gl_FragCoord', mt)
                    else:
                        raise Unsupported(f'MSL: fragment input [[ {ma} ]]')
            sc.vars[name] = (name, T('struct', name=sname))
            continue
        builtin = {'vertex_id': ('gl_VertexID', INT), 'instance_id': ('gl_InstanceID', INT),
                   'position': ('gl_FragCoord', vec('float', 4)), 'front_facing': ('gl_FrontFacing', BOOL)}.get(a)
        if builtin:
            t = parse_type(ptoks[0]) or INT
            g, gt = builtin
            sc.vars[name] = (f'{t.glsl()}({g})' if gt != t else g, t)
            continue
        raise Unsupported(f'MSL: parameter {" ".join(ptoks)} [[ {a} ]]')


_HELPERS = '''{t} pm_bitFieldInsert({t} width, {t} offset, {t} src2, {t} src3)
{{
    {t} bitmask = ((({t}(1u) << width) - {t}(1u)) << offset);
    return ((src2 << offset) & bitmask) | (src3 & ~bitmask);
}}
'''


def emit(st, body, precision='highp', es='300'):
    """GLSL ES text of a translated stage (Unity's 2017-2018 GL form: plain uniforms)."""
    head = [f'#version {es} es']
    text = '\n'.join(st.consts + body)
    # the constant buffers' members the stage reads (MSL's structs list them all, for their offsets)
    uniforms = [u for u in st.uniforms if re.search(r'\b%s\b' % re.search(r'(\w+)(?:\[\d+\])?;$', u).group(1), text)
                or re.search(r'\bsampler', u)]
    code = '\n'.join(uniforms + st.ins + st.outs + st.consts + body)
    head.append(glsl.precision_block(code, precision).rstrip('\n'))
    out = head + uniforms + st.consts + st.ins + st.outs
    for t in sorted(st.helpers):
        out.append(_HELPERS.format(t=t))
    out.append('void main()\n{')
    out += body
    out.append('}')
    return '\n'.join(out) + '\n'


def translate_program(vs_src, fs_src, precision='highp', unity=None, notes=None):
    """MSL of a vertex and a fragment stage -> (GL program text, gpu type 4 or 3: GLES 3.1). unity:
    (major, minor) of the data: from 2019.1 the samplers get their units in Unity's macro
    (UNITY_LOCATION(n), program-wide, the fragment stage's first), as Unity's GL programs have them.
    The vertex stage's full-screen texture coordinates get GL's origin (vulkan.uv_origin; notes: as
    there)."""
    v, vb = translate_stage(vs_src, precision)
    f, fb = translate_stage(fs_src, precision)
    if v.stage != 'VERTEX' or f.stage != 'FRAGMENT':
        raise Unsupported('MSL: expected a vertex and a fragment stage')
    # GLSL ES links varyings by name and type: the fragment's inputs must be vertex outputs
    vout = {re.search(r'(\w+);$', l).group(1): l for l in v.outs}
    for l in f.ins:
        name = re.search(r'(\w+);$', l).group(1)
        if name not in vout:
            raise Unsupported(f'MSL: fragment input {name} is not a vertex output')
        if vout[name].split()[-2] != l.split()[-2]:
            raise Unsupported(f'MSL: varying {name}: {vout[name].split()[-2]} written, {l.split()[-2]} read')
        # Metal gives the interpolation on the fragment input only; GLSL ES wants it on both
        if l.startswith('flat ') and not vout[name].startswith('flat '):
            v.outs[v.outs.index(vout[name])] = 'flat ' + vout[name]
    es = '310' if (v.needs_es31 or f.needs_es31) else '300'
    try:
        return _program(v, vb, f, fb, precision, unity, es, notes)
    except glsl.NeedsES31:
        return _program(v, vb, f, fb, precision, unity, '310', notes)


def _program(v, vb, f, fb, precision, unity, es, notes):
    texts = {'VERTEX': emit(v, vb, precision, es), 'FRAGMENT': emit(f, fb, precision, es)}
    texts['VERTEX'], flips = VK.uv_origin(texts['VERTEX'])
    if flips and notes is not None:
        notes.append(f'VERTEX uv-origin {flips}')
    if unity is not None and unity >= (2019, 1):
        units = {}
        for st in ('FRAGMENT', 'VERTEX'):
            for m in _SAMPLER_LINE.finditer(texts[st]):
                units.setdefault(m.group(1), len(units))
        for st in texts:
            t = _SAMPLER_LINE.sub(lambda m: f'UNITY_LOCATION({units[m.group(1)]}) ' + m.group(0), texts[st])
            hm = re.match(r'\A(#version[^\n]*\n(?:precision[^\n]*\n)*)', t)
            texts[st] = t[:hm.end()] + VK.UNIFORM_LOCATION_BLOCK + t[hm.end():]
    for st, t in texts.items():
        VK._check_es(t, st, int(es))
    text = f'#ifdef VERTEX\n{texts["VERTEX"]}#endif\n#ifdef FRAGMENT\n{texts["FRAGMENT"]}#endif\n'
    return text, 3 if es == '310' else 4


_SAMPLER_LINE = re.compile(r'^uniform\s+(?:(?:highp|mediump|lowp)\s+)?\w*sampler\w+\s+(\w+);', re.M)


def msl_of(code):
    """The MSL text of a Metal entry's code (after Unity's 0xf00dcafe header, which names the entry
    point: xlatMtlMain)."""
    i = code.find(b'#include')
    if i < 0:
        raise Unsupported('Metal program without MSL text')
    return code[i:].decode('utf-8')


# ---------------------------------------------------------------- Shader assets

def add_gles3_metal(tree, precision='highp', replace=False, unity=None, translate=None):
    """Adds GLES3 programs translated from the shader's Metal ones (tree edited in place); a
    convert.Result (source 'metal').

    Metal programs are a vertex and a fragment subprogram per variant, as Direct3D 11's: they are
    paired as convert.add_gles3_d3d11 pairs those (keywords and tier), and each pair becomes one
    GL program stored as Unity stores GL programs of the data's version: up to 2019.x in the vertex
    subprogram's entry (the fragment entry without code; 2019.x with the GL binding info,
    dxbc.gl_bindings), from 2020.1 vertex subprograms only with entries numbered anew (2021.2+
    with parameter entries); the vertex program's m_CommonParameters go back into its Metal
    entries. VR-only, GPU instancing and sprite skinning variants that do not translate are left
    out, any other variant leaves its SubShader without GLES3 programs. translate: function(vs
    Entry, ps Entry) -> (GL program text, gpu type), default translate_program."""
    from . import blob as B
    from . import convert as C
    from . import dxbc
    name = tree['m_ParsedForm']['m_Name']
    r = C.Result(name)
    r.source = 'metal'
    plats = list(tree['platforms'])
    if B.PLATFORM_METAL not in plats:
        r.why = 'no Metal programs'
        return r
    if B.PLATFORM_GLES3PLUS in plats:
        if not replace:
            r.why = 'already has GLES3 programs'
            return r
        C._strip_gles(tree)
        r.status, r.why = 'converted', '(old GLES programs removed)'
    VS, FS = B.GPU_METAL_VS, B.GPU_METAL_FS
    blobs = B.ShaderBlobs(tree)
    lists = list(C.subprogram_lists(tree))
    progs = {sp['m_BlobIndex'] for _, _, lst, _ in lists for sp in lst if sp['m_GpuProgramType'] in (VS, FS)}
    params = {pbi[i] for _, _, lst, pbi in lists if pbi is not None for i, sp in enumerate(lst)
              if sp['m_GpuProgramType'] in (VS, FS)}
    entries = blobs.entries(B.PLATFORM_METAL, params, progs)
    serializer = next((e.version for e in entries if isinstance(e, B.Entry)), None)
    line = C.unity_of(tree, unity)
    if serializer is not None and line < dxbc.unity_line(serializer):
        line = dxbc.unity_line(serializer)
    if not progs and line >= (2018, 1):
        blobs.set_entries(B.PLATFORM_GLES3PLUS, [], [] if blobs.nested else None, 1 if blobs.stage_counts is not None else None)
        blobs.store()
        r.status, r.empty = 'converted', True
        r.why = ('no programs (every variant stripped): an empty GLES3 blob ' + r.why).strip()
        return r
    gl_info, compact = line >= (2019, 1), line >= (2020, 1)
    separate = serializer == dxbc.SEPARATE_PARAMS_FROM and any(pbi is not None for *_, pbi in lists)
    if translate is None:
        def translate(vs, ps):
            return translate_program(msl_of(vs.code), msl_of(ps.code), precision, line, r.notes)
    cache = {}

    def program(vi, fi):
        if (vi, fi) not in cache:
            try:
                ve, fe = entries[vi], entries[fi]
                if not isinstance(ve, B.Entry) or not isinstance(fe, B.Entry) or not ve.code or not fe.code:
                    raise Unsupported('empty program entry')
                r.guessed_layout |= ve.guessed or fe.guessed
                text, typ = translate(ve, fe)
                info = dxbc.gl_bindings(text, line, _source_map(ve)) if gl_info else None
                cache[(vi, fi)] = (text, info, B.GPU_GLES31 if typ == B.GPU_GLES31 else B.GPU_GLES3)
            except (Unsupported, dxbc.Unsupported, glsl.Unsupported, VK.Unsupported) as ex:
                cache[(vi, fi)] = ex
        return cache[(vi, fi)]

    plan, no_instancing = [], set()
    for si, ss in enumerate(tree['m_ParsedForm']['m_SubShaders']):
        todo, why = [], None
        for pi_, p in enumerate(ss['m_Passes']):
            vlists, flists = C._tier_lists(p.get('progVertex')), C._tier_lists(p.get('progFragment'))
            for t, (vlist, vpbi) in enumerate(vlists):
                flist = flists[t][0] if t < len(flists) else []
                vss = [(sp, vpbi[j] if vpbi is not None else None) for j, sp in enumerate(vlist) if sp['m_GpuProgramType'] == VS]
                pss = [(sp, None) for sp in flist if sp['m_GpuProgramType'] == FS]
                for vsp, vpi, psp, _, keys in C._variant_pairs(vss, pss):
                    ve = entries[vsp['m_BlobIndex']]
                    fe = entries[psp['m_BlobIndex']] if psp is not None else None
                    kws = C._entry_keywords(ve, fe)
                    kws = kws[0] + (kws[1] or [])
                    res = None
                    if psp is None:
                        err = 'no fragment shader for this variant'
                    else:
                        res = program(vsp['m_BlobIndex'], psp['m_BlobIndex'])
                        err = str(res) if isinstance(res, Exception) else None
                    if err is None:
                        todo.append((p, t, vsp, vpi, psp, res, keys))
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
                 else 'no Metal vertex/fragment programs')
        r.changed = bool(replace and B.PLATFORM_GLES3PLUS in plats)
        return r

    twins = []
    if not compact:
        out = [None if not isinstance(e, B.Entry) else
               B.Entry(e.version, B.GPU_GLES3, [0] * len(e.stats), e.keywords, b'', dxbc.gl_rest(0), e.local_keywords)
               for e in entries]
        segs = blobs.segments(B.PLATFORM_METAL) if blobs.nested else None
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
                    rest = info.serialize() if info is not None else dxbc.gl_rest(_source_map(e))
                    kw, lkw = C._entry_keywords(e, entries[fi])
                    out[slot] = B.Entry(e.version, typ, [0] * len(e.stats), kw, es.encode('utf-8'), rest, lkw)
                    r.programs += 1
                    r.es31 += typ == B.GPU_GLES31
                used.add(fi)
                if typ == B.GPU_GLES31 and out[fi] is not None:
                    out[fi].gpu_type = typ
                names = C._name_indices(p, C._gl_names(info)) if info is not None else None
                tw = C.gl_twin(vsp, vslot[(vi, fi)], info, names, typ)
                C._set_keywords(tw, keys)
                twins.append((p['progVertex']['m_SubPrograms'], None, tw, None))
                twins.append((p['progFragment']['m_SubPrograms'], None, C.gl_twin(psp, fi, gpu_type=typ), None))
        blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs)
    else:
        out, segs = [], []
        mt_segs = blobs.segments(B.PLATFORM_METAL) if blobs.nested else [0] * len(entries)
        code_at, param_at = {}, {}
        for si, todo in plan:
            for p, t, vsp, vpi, psp, (es, info, typ), keys in todo:
                vi = vsp['m_BlobIndex']
                key = (vi, vpi, psp['m_BlobIndex'])
                e = entries[vi]
                if key not in code_at:
                    code_at[key] = len(out)
                    kw, lkw = C._entry_keywords(e, entries[psp['m_BlobIndex']])
                    out.append(B.Entry(e.version, typ, [0] * len(e.stats), kw, es.encode('utf-8'),
                                       info.head() if separate else info.serialize(), lkw))
                    segs.append(mt_segs[vi])
                    r.programs += 1
                    r.es31 += typ == B.GPU_GLES31
                pidx = None
                if separate:
                    data = info.params_bytes()
                    if data not in param_at:
                        param_at[data] = len(out)
                        out.append(B.ParamEntry(e.version, data))
                        segs.append(mt_segs[vi])
                    pidx = param_at[data]
                lst, pbi = C._tier_lists(p['progVertex'])[t]
                tw = C.gl_twin(vsp, code_at[key], gpu_type=typ)
                C._set_keywords(tw, keys)
                twins.append((lst, pbi, tw, pidx))
        _restore_common(tree, plan, entries, blobs, separate)
        blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs if blobs.nested else None, 1 if blobs.stage_counts is not None else None)
    blobs.store()
    seen = set()
    for lst, pbi, tw, pidx in twins:
        key = (id(lst), tw['m_BlobIndex'], C._variant_key(tw))
        if key in seen:
            continue
        seen.add(key)
        lst.append(tw)
        if pbi is not None:
            pbi.append(pidx)
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
    import struct
    return struct.unpack_from('<i', e.rest)[0] if len(e.rest) >= 4 else 0


def _restore_common(tree, plan, entries, blobs, separate):
    """2020.1+: a vertex program given GLES3 subprograms gets its m_CommonParameters (what its Metal
    subprograms share, which the player adds to every subprogram of the program, ours too) put back
    into its Metal entries, and cleared (as convert._restore_common for Direct3D 11)."""
    from . import blob as B
    from . import convert as C
    from . import dxbc
    progs = {id(p): p for si, todo in plan for p, *_ in todo}
    changed = False
    for p in progs.values():
        prog = p['progVertex']
        common = prog.get('m_CommonParameters')
        if not common or not any(isinstance(v, list) and v for v in common.values()):
            continue
        names = {i: n for n, i in p.get('m_NameIndices') or []}
        done = set()
        for lst, pbi in C._tier_lists(prog):
            for j, sp in enumerate(lst):
                if sp['m_GpuProgramType'] != B.GPU_METAL_VS:
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
                    continue
                if separate:
                    entries[pi] = B.ParamEntry(pe.version, b.params_bytes())
                else:
                    entries[at] = B.Entry(e.version, e.gpu_type, e.stats, e.keywords, e.code, b.serialize(), e.local_keywords)
                changed = True
        C._clear_common(prog)
    if changed:
        blobs.set_entries(B.PLATFORM_METAL, entries, blobs.segments(B.PLATFORM_METAL) if blobs.nested else None)
