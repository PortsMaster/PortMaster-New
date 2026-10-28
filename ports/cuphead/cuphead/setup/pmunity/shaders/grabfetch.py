"""Opt-in (`shaders.grab_fetch`): blend-mode passes that read the framebuffer instead of a GrabPass copy.

A pass after an unnamed `GrabPass {}` samples `_GrabTexture`, Unity's copy of the picture drawn so
far, taken again for every object (batch) that draws with the shader. On a tiler (the Mali-G31) each
copy costs a full-screen blit and makes the camera store and reload its attachments. Where a pass
only samples the copy at the fragment's own screen position (a blend mode: screen, overlay, vivid
light ... of the sprite against what is under it), the colour it reads is the framebuffer's own at
that pixel, which a fragment shader can read directly with framebuffer fetch
(`GL_EXT_shader_framebuffer_fetch`'s `inout` output or `GL_ARM_shader_framebuffer_fetch`'s
`gl_LastFragColorARM`). Not the same picture: sprites of one batch that overlap see each other's
output (with the copy, the picture before the batch), and ARM's fetched colour is mediump.

For each SubShader whose unnamed GrabPasses each come right before the one pass that samples
`_GrabTexture`, and whose every GLES3 program of that pass samples it at the fragment's screen
position (checked: screen_uv), a copy of the SubShader is put before it:

  * the GrabPasses left out (SerializedPass m_Type 2, m_TextureName empty: a data edit of the
    parsed form's pass list; named GrabPasses `GrabPass {"_Name"}`, copied once a frame, are not
    touched, nor their SubShader);
  * only the GLES subprograms of GLES3 / GLES 3.1 type kept (OpenGL Core, Vulkan, ... stay in the
    original SubShader), each pass listing only the GLES3 platform (2020.1+ m_Platforms);
  * the reading pass's programs as new entries of the GLES3 blob, their fragment stage reading the
    framebuffer: `texture(_GrabTexture, uv)` becomes the colour read at the start of main()
    (rewrite_program); everything else (vertex stage, parameters, keywords, blend state) as before.

mode True: the copy's reading subprograms require framebuffer fetch (Unity's ShaderRequirements bit
`framebufferfetch`, 0x80000, as `#pragma require framebufferfetch` gives), so Unity runs it only
where its GLES backend reports framebuffer fetch, and the original SubShader (GrabPass and all)
everywhere else. Unity 6000.0's backend reports it with GL_EXT_shader_framebuffer_fetch; it does not
know ARM's extension, which is what Mali's own drivers have.
mode 'always': no requirement: Unity takes the copy wherever its programs compile, i.e. where the
driver has GL_EXT_ or GL_ARM_shader_framebuffer_fetch (the RG34XX-SP's Mali-G31, r20p0: ARM's only).
On a driver with neither they stop at an `#error`; Unity 6000.0 then uses the original SubShader,
which stays after the copy (seen in the emulated rig; older players not tried).
"""
import copy
import re
from fractions import Fraction

from . import blob as B
from . import convert as C
from . import glsl

GRAB_PASS = 2                       # SerializedPass m_Type: 0 normal, 1 use, 2 grab
GRAB_TEXTURE = '_GrabTexture'
FBFETCH = 0x80000                   # ShaderRequirements: framebufferfetch (libunity's kShaderRequirementFlagNamePairs)
GLES3_TYPES = (B.GPU_GLES3, B.GPU_GLES31)
MARK = '// pmunity grab_fetch: reads the framebuffer instead of _GrabTexture'
FETCHED = 'ua_FramebufferColor'
MODES = (True, 'always')


class Result:
    def __init__(self, name):
        self.name = name
        self.status = 'unchanged'       # changed | unchanged | skipped (a GrabPass, but no SubShader qualifies)
        self.why = ''
        self.subshaders = 0             # SubShaders given a framebuffer-fetch copy
        self.grabs = 0                  # GrabPasses the copies leave out
        self.programs = 0               # programs rewritten (new GLES3 blob entries)
        self.left = []                  # (subshader, why) not converted

    @property
    def changed(self):
        return self.status == 'changed'

    def __repr__(self):
        return f'{self.name}: {self.status} {self.why}'.rstrip()


class NotScreenPosition(Exception):
    pass


# ---------------------------------------------------------------- symbolic values (polynomials)

MAX_TERMS = 512                     # a value with more terms becomes opaque (it is not a screen position)


class Poly:
    """A polynomial over named atoms with rational coefficients: {monomial (sorted atom tuple): Fraction}."""
    __slots__ = ('t',)

    def __init__(self, t=None):
        self.t = {k: v for k, v in (t or {}).items() if v}

    @staticmethod
    def const(c):
        return Poly({(): Fraction(c)})

    @staticmethod
    def atom(a):
        return Poly({(a,): Fraction(1)})

    def __add__(self, o):
        t = dict(self.t)
        for k, v in o.t.items():
            t[k] = t.get(k, 0) + v
        return Poly(t)

    def __neg__(self):
        return Poly({k: -v for k, v in self.t.items()})

    def __sub__(self, o):
        return self + (-o)

    def __mul__(self, o):
        t = {}
        for a, x in self.t.items():
            for b, y in o.t.items():
                k = tuple(sorted(a + b))
                t[k] = t.get(k, 0) + x * y
        return Poly(t)

    def scale(self, c):
        return Poly({k: v * c for k, v in self.t.items()})

    def is_const(self):
        return all(k == () for k in self.t)

    def value(self):
        return self.t.get((), Fraction(0))

    def key(self):
        return ' + '.join(f'{v}*{"*".join(k) or "1"}' for k, v in sorted(self.t.items())) or '0'


class _Opaque:
    """Fresh atoms for values the analysis does not follow (functions, comparisons, merged branches)."""

    def __init__(self):
        self.n = 0

    def new(self, what='?'):
        self.n += 1
        return Poly.atom(f'#{what}{self.n}')


# ---------------------------------------------------------------- GLSL (HLSLcc's subset) tokens

_TOKEN = re.compile(r'''
    (?P<pp>\#[^\n]*)
  | (?P<ws>\s+)
  | (?P<comment>//[^\n]*|/\*.*?\*/)
  | (?P<num>(?:\d+\.\d*|\.\d+)(?:[eE][-+]?\d+)?[fF]?|\d+[eE][-+]?\d+[fF]?|0[xX][0-9a-fA-F]+[uU]?|\d+[uU]?)
  | (?P<id>[A-Za-z_]\w*)
  | (?P<op><<=|>>=|\+\+|--|\+=|-=|\*=|/=|%=|&=|\|=|\^=|<<|>>|<=|>=|==|!=|&&|\|\||\^\^|[-+*/%<>=!&|^~?:;,.(){}\[\]])
''', re.X | re.M | re.S)


class Tok:
    __slots__ = ('kind', 'text', 'start', 'end')

    def __init__(self, kind, text, start, end):
        self.kind, self.text, self.start, self.end = kind, text, start, end

    def __repr__(self):
        return f'{self.kind}:{self.text}'


def tokens(src, start=0, end=None):
    end = len(src) if end is None else end
    out, p = [], start
    while p < end:
        m = _TOKEN.match(src, p, end)
        if not m:
            raise NotScreenPosition(f'cannot read the GLSL at {src[p:p + 20]!r}')
        k = m.lastgroup
        if k == 'pp':
            d = re.match(r'[ \t]*#\s*(\w*)', m.group(0)).group(1)
            kind = {'if': 'ppif', 'ifdef': 'ppif', 'ifndef': 'ppif', 'elif': 'ppelse', 'else': 'ppelse',
                    'endif': 'ppend'}.get(d, 'ppother')
            out.append(Tok(kind, m.group(0), m.start(), m.end()))
        elif k not in ('ws', 'comment'):
            out.append(Tok(k, m.group(0), m.start(), m.end()))
        p = m.end()
    return out


_SIZES = {'float': 1, 'int': 1, 'uint': 1, 'bool': 1}
for _n in (2, 3, 4):
    for _p in ('', 'i', 'u', 'b'):
        _SIZES[f'{_p}vec{_n}'] = _n
_MATRIX = re.compile(r'mat[234](x[234])?$')
_QUALIFIERS = {'highp', 'mediump', 'lowp', 'const', 'flat', 'smooth', 'centroid', 'uniform', 'in', 'out', 'inout',
               'precise', 'invariant', 'UNITY_UNIFORM'}
_BUILTINS = {'gl_Position': 4, 'gl_FragCoord': 4, 'gl_VertexID': 1, 'gl_InstanceID': 1, 'gl_FrontFacing': 1,
             'gl_PointCoord': 2, 'gl_PointSize': 1, 'gl_FragDepth': 1}
_SWIZZLE = {c: i for s in ('xyzw', 'rgba', 'stpq') for i, c in enumerate(s)}
_DECL = re.compile(r'\b(%s|mat[234](?:x[234])?)\s+(\w+)\s*(?:\[\s*(\d+)\s*\])?\s*[;=,)]' % '|'.join(_SIZES))
_SIZE_OF_RESULT = {'dot': 1, 'length': 1, 'distance': 1, 'determinant': 1, 'any': 1, 'all': 1}
_TEXTURE_FUNCS = {'texture', 'textureProj', 'textureLod', 'textureOffset', 'textureProjOffset', 'textureLodOffset',
                  'textureProjLod', 'textureProjLodOffset', 'textureGrad', 'textureGradOffset', 'textureProjGrad',
                  'textureProjGradOffset', 'texelFetch', 'texelFetchOffset', 'textureSize', 'textureGather',
                  'textureGatherOffset', 'textureGatherOffsets', 'textureQueryLod'}


def declarations(src):
    """{name: (components, array length or None)} of a stage's declarations outside its functions."""
    out = {}
    for m in _DECL.finditer(glsl._strip_comments(src)):
        t, name, arr = m.groups()
        n = 4 if _MATRIX.match(t) else _SIZES[t]       # (a matrix: its columns as one vec4 each, opaque)
        out[name] = (n, int(arr) if arr else None)
    return out


class Stage:
    """One stage's main() evaluated symbolically: every value a list of Poly, one per component.
    Atoms: the stage's globals and built-ins by name and component (`vs_TEXCOORD1.w`, array elements
    `hlslcc_mtx4x4unity_MatrixVP[1].x`), their inverses `1/(<poly>)`, and opaque `#...` values.
    grab_calls: [(function, [argument values], start, end, depth)] of the calls that sample
    _GrabTexture (offsets in the stage source; depth: inside how many conditional blocks);
    cond_return: whether main() may return before its end."""

    def __init__(self, src, sampler=GRAB_TEXTURE):
        self.src = src
        self.sampler = sampler
        self.decl = declarations(src)
        self.vars = {}                  # name -> list of Poly (arrays: name[i])
        self.local = {}                 # declared in main: name -> (components, array)
        self.op = _Opaque()
        self.inverses = {}              # atom name -> Poly (the denominator)
        self.grab_calls = []
        self.clobbered = set()          # arrays an element of which was written at an unknown index
        self.cond_return = False
        self.depth = 0                  # nesting of conditional blocks
        m = re.search(r'\bvoid\s+main\s*\(\s*(?:void\s*)?\)\s*\{', src)
        if not m:
            raise NotScreenPosition('no main()')
        self.body_start = m.end()
        toks = tokens(src, m.end())
        depth, end = 1, None
        for i, t in enumerate(toks):
            if t.text == '{':
                depth += 1
            elif t.text == '}':
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end is None:
            raise NotScreenPosition('main() has no end')
        self.toks, self.i = toks[:end], 0
        self.uses = [t for t in tokens(src) if t.kind == 'id' and t.text == sampler]

    # --- values
    def size_of(self, name):
        if name in self.local:
            return self.local[name]
        if name in self.decl:
            return self.decl[name]
        if name in _BUILTINS:
            return _BUILTINS[name], None
        return None

    def read(self, name, index=None):
        sz = self.size_of(name)
        if sz is None:
            return [self.op.new(name)]
        n, arr = sz
        key = name if index is None or arr is None else f'{name}[{index}]'
        if arr is not None and (index is None or name in self.clobbered and key not in self.vars):
            return [self.op.new(name) for _ in range(n)]     # (a whole array, or one written at unknown places)
        if key not in self.vars:
            self.vars[key] = self.default(key)
        return list(self.vars[key])

    def write(self, key, comps, vals):
        name = key.split('[')[0]
        sz = self.size_of(name)
        n = sz[0] if sz else max(comps) + 1
        cur = self.vars.get(key) or self.default(key)
        cur = list(cur) + [self.op.new(key) for _ in range(n - len(cur))]
        if len(vals) == 1 and len(comps) > 1:
            vals = vals * len(comps)
        if len(vals) < len(comps):
            raise NotScreenPosition(f'assignment to {key} of {len(vals)} components for {len(comps)}')
        for c, v in zip(comps, vals):
            if c >= len(cur):
                cur += [self.op.new(key) for _ in range(c + 1 - len(cur))]
            cur[c] = v
        self.vars[key] = cur

    def inv(self, p):
        if p.is_const():
            v = p.value()
            if not v:
                return self.op.new('div0')
            return Poly.const(1 / v)
        a = f'1/({p.key()})'
        self.inverses[a] = p
        return Poly.atom(a)

    def guard(self, p):
        return p if len(p.t) <= MAX_TERMS else self.op.new('big')

    # --- tokens
    def peek(self, k=0):
        j = self.i + k
        return self.toks[j] if j < len(self.toks) else None

    def next(self):
        t = self.peek()
        if t is None:
            raise NotScreenPosition('unexpected end of main()')
        self.i += 1
        return t

    def expect(self, text):
        t = self.next()
        if t.text != text:
            raise NotScreenPosition(f'expected {text!r}, found {t.text!r}')
        return t

    # --- statements
    def run(self):
        while self.peek() is not None:
            self.statement()
        return self

    def statement(self):
        t = self.peek()
        if t.kind == 'ppif':
            self.next()
            self.pp_block()
            return
        if t.kind in ('ppelse', 'ppend'):
            raise NotScreenPosition(f'unmatched {t.text.strip()!r}')
        if t.kind == 'ppother':
            self.next()
            return
        if t.text == '{':
            self.next()
            while self.peek() is not None and self.peek().text != '}':
                self.statement()
            if self.peek() is not None:                 # (else main() returned in this block)
                self.expect('}')
            return
        if t.text == ';':
            self.next()
            return
        if t.text == 'if':
            self.next()
            self.expect('(')
            self.expr()
            self.expect(')')
            before = dict(self.vars)
            self.depth += 1
            self.statement()
            results = [self.vars]
            self.vars = dict(before)
            if self.peek() is not None and self.peek().text == 'else':
                self.next()
                self.statement()
                results.append(self.vars)
            else:
                results.append(before)
            self.depth -= 1
            self.vars = self.merge(results)
            return
        if t.text in ('for', 'while', 'do'):
            self.loop()
            return
        if t.text in ('discard', 'break', 'continue'):
            self.next()
            self.expect(';')
            return
        if t.text == 'return':
            self.next()
            if self.peek().text != ';':
                self.expr()
            self.expect(';')
            if self.depth:
                self.cond_return = True
            else:
                self.toks = self.toks[:self.i]           # nothing after an unconditional return runs
            return
        if self.is_declaration():
            self.declaration()
            return
        self.assignment_or_expr()
        self.expect(';')

    def default(self, key):
        """A variable's value before main() writes it: its atoms."""
        name = key.split('[')[0]
        sz = self.size_of(name)
        n = sz[0] if sz else 4
        return [Poly.atom(f'{key}.{"xyzw"[c]}') for c in range(n)]

    def merge(self, results):
        """The state after alternatives the analysis does not decide between: a component that
        differs between them is opaque."""
        merged = {}
        for k in set().union(*results):
            vals = [r.get(k) or self.default(k) for r in results]
            n = max(len(v) for v in vals)
            merged[k] = [vals[0][c] if all(c < len(v) and v[c].key() == vals[0][c].key() for v in vals) else self.op.new(k)
                         for c in range(n)]
        return merged

    def pp_block(self):
        """#if ... [#elif ... | #else ...] #endif between statements (Unity's own GLES programs:
        UNITY_ADRENO_ES3): any branch possible."""
        def part():
            while self.peek() is not None and self.peek().kind not in ('ppelse', 'ppend'):
                self.statement()
        before = dict(self.vars)
        self.depth += 1
        part()
        results, has_else = [self.vars], False
        while self.peek() is not None and self.peek().kind == 'ppelse':
            has_else |= bool(re.match(r'[ \t]*#\s*else\b', self.next().text))
            self.vars = dict(before)
            part()
            results.append(self.vars)
        if not has_else:
            results.append(before)
        self.depth -= 1
        t = self.next()
        if t.kind != 'ppend':
            raise NotScreenPosition('#if without #endif in main()')
        self.vars = self.merge(results)

    def loop(self):
        """A loop: what its body assigns is opaque before, during and after it."""
        start = self.i
        t = self.next()
        if t.text == 'do':
            body = self.skip_statement()
            self.expect('while'); self.skip_parens(); self.expect(';')
            span = (start, self.i)
        else:
            self.skip_parens()
            body = self.skip_statement()
            span = (start, self.i)
        assigned = self.assigned_in(*span)
        self.forget(assigned)
        end = self.i
        self.i = body
        self.depth += 1
        saved = dict(self.vars)
        self.statement()
        self.vars = saved
        self.depth -= 1
        self.i = end

    def skip_parens(self):
        self.expect('(')
        depth = 1
        while depth:
            t = self.next()
            depth += {'(': 1, ')': -1}.get(t.text, 0)

    def skip_statement(self):
        """Skips one statement; returns its first token's index."""
        start = self.i
        t = self.next()
        if t.text == '{':
            depth = 1
            while depth:
                t = self.next()
                depth += {'{': 1, '}': -1}.get(t.text, 0)
        elif t.text in ('if', 'for', 'while'):
            self.skip_parens()
            self.skip_statement()
            if t.text == 'if' and self.peek() is not None and self.peek().text == 'else':
                self.next()
                self.skip_statement()
        else:
            while t.text != ';':
                t = self.next()
        return start

    def assigned_in(self, a, b):
        names = set()
        for j in range(a, b):
            t = self.toks[j]
            if t.kind != 'id':
                continue
            k = j + 1
            if k < b and self.toks[k].text == '[':
                depth = 0
                while k < b:
                    depth += {'[': 1, ']': -1}.get(self.toks[k].text, 0)
                    k += 1
                    if depth == 0:
                        break
            if k + 1 < b and self.toks[k].text == '.' and self.toks[k + 1].kind == 'id':
                k += 2
            if k < b and self.toks[k].text in ('=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<=', '>>=', '++', '--'):
                names.add(t.text)
            if j > a and self.toks[j - 1].text in ('++', '--'):
                names.add(t.text)
        return names

    def is_declaration(self):
        k = 0
        while self.peek(k) is not None and self.peek(k).text in _QUALIFIERS:
            k += 1
        t, u = self.peek(k), self.peek(k + 1)
        return t is not None and u is not None and (t.text in _SIZES or _MATRIX.match(t.text)) and u.kind == 'id'

    def declaration(self):
        while self.peek().text in _QUALIFIERS:
            self.next()
        t = self.next().text
        n = 4 if _MATRIX.match(t) else _SIZES[t]
        while True:
            name = self.next().text
            arr = None
            if self.peek().text == '[':
                self.next()
                arr = int(self.next().text.rstrip('uU'))
                self.expect(']')
            self.local[name] = (n, arr)
            self.vars = {k: v for k, v in self.vars.items() if k.split('[')[0] != name}
            if self.peek().text == '=':
                self.next()
                v = self.expr()
                if arr is None:
                    self.write(name, list(range(n)), v if len(v) > 1 else v * n)
            elif arr is None:
                self.vars[name] = [self.op.new(name) for _ in range(n)]
            if self.peek().text == ',':
                self.next()
                continue
            self.expect(';')
            return

    def lvalue(self):
        """(key, components) of an assignment's target, or None (not one)."""
        save = self.i
        t = self.peek()
        if t is None or t.kind != 'id' or self.size_of(t.text) is None:
            return None
        self.next()
        key = t.text
        n, arr = self.size_of(t.text)
        comps = list(range(n))
        if self.peek() is not None and self.peek().text == '[':
            self.next()
            idx = self.expr()
            self.expect(']')
            if arr is not None and idx[0].is_const():
                key = f'{t.text}[{int(idx[0].value())}]'
            elif arr is None and idx[0].is_const():
                comps = [int(idx[0].value())]
            else:
                key = None                  # (a dynamic index: the whole variable becomes opaque)
        if self.peek() is not None and self.peek().text == '.':
            self.next()
            sw = self.next().text
            if any(c not in _SWIZZLE for c in sw):
                self.i = save
                return None
            comps = [comps[_SWIZZLE[c]] if _SWIZZLE[c] < len(comps) else _SWIZZLE[c] for c in sw]
        if self.peek() is None or self.peek().text not in ('=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=',
                                                           '<<=', '>>=', '++', '--'):
            self.i = save
            return None
        return key, comps, t.text

    def assignment_or_expr(self):
        lv = self.lvalue()
        if lv is None:
            self.expr()
            return
        key, comps, name = lv
        op = self.next().text
        if op in ('++', '--'):
            v = [self.op.new(name) for _ in comps]
        else:
            v = self.expr()
            if op != '=':
                cur = self.read(*self._split(key)) if key else [self.op.new(name)] * 4
                old = [cur[c] if c < len(cur) else self.op.new(name) for c in comps]
                v = self.binop(op[:-1], old, v)
        if key is None:
            self.forget({name})
            return
        self.write(key, comps, v)

    def forget(self, names):
        """Variables written where the analysis does not know (a loop, a dynamic index): opaque."""
        for k in [k for k in self.vars if k.split('[')[0] in names]:
            del self.vars[k]
        for name in names:
            sz = self.size_of(name)
            if sz and sz[1] is None:
                self.vars[name] = [self.op.new(name) for _ in range(sz[0])]
            elif sz:
                self.clobbered.add(name)

    @staticmethod
    def _split(key):
        if '[' in key:
            name, idx = key[:-1].split('[')
            return name, int(idx)
        return key, None

    # --- expressions
    _BINARY = {'||': 1, '^^': 2, '&&': 3, '|': 4, '^': 5, '&': 6, '==': 7, '!=': 7, '<': 8, '>': 8, '<=': 8,
               '>=': 8, '<<': 9, '>>': 9, '+': 10, '-': 10, '*': 11, '/': 11, '%': 11}

    def expr(self):
        c = self.binary(1)
        if self.peek() is not None and self.peek().text == '?':
            self.next()
            a = self.expr()
            self.expect(':')
            b = self.expr()
            return [self.op.new('?') for _ in range(max(len(a), len(b)))]
        return c

    def binary(self, prec):
        left = self.unary()
        while True:
            t = self.peek()
            p = self._BINARY.get(t.text) if t is not None and t.kind == 'op' else None
            if p is None or p < prec:
                return left
            self.next()
            right = self.binary(p + 1)
            left = self.binop(t.text, left, right)

    def binop(self, op, a, b):
        n = max(len(a), len(b))
        if len(a) == 1:
            a = a * n
        if len(b) == 1:
            b = b * n
        if len(a) != len(b):
            return [self.op.new(op) for _ in range(n)]          # (matrix products: not followed)
        if op == '+':
            return [self.guard(x + y) for x, y in zip(a, b)]
        if op == '-':
            return [self.guard(x - y) for x, y in zip(a, b)]
        if op == '*':
            return [self.guard(x * y) for x, y in zip(a, b)]
        if op == '/':
            return [self.guard(x.scale(1 / y.value())) if y.is_const() and y.value() else self.guard(x * self.inv(y))
                    for x, y in zip(a, b)]
        return [self.op.new(op) for _ in range(n)]

    def unary(self):
        t = self.peek()
        if t.text == '-':
            self.next()
            return [-x for x in self.unary()]
        if t.text == '+':
            self.next()
            return self.unary()
        if t.text in ('!', '~', '++', '--'):
            self.next()
            return [self.op.new(t.text) for _ in self.unary()]
        return self.postfix(self.primary())

    def primary(self):
        t = self.next()
        if t.kind == 'num':
            s = t.text.rstrip('fF')
            if s[:2].lower() == '0x':
                return [Poly.const(int(s.rstrip('uU'), 16))]
            s = s.rstrip('uU')
            return [Poly.const(Fraction(s))]
        if t.text == '(':
            v = self.expr()
            while self.peek().text == ',':           # (the comma operator: the last value)
                self.next()
                v = self.expr()
            self.expect(')')
            return v
        if t.kind == 'id':
            if t.text in ('true', 'false'):
                return [Poly.const(1 if t.text == 'true' else 0)]
            if self.peek() is not None and self.peek().text == '(':
                return self.call(t)
            if self.peek() is not None and self.peek().text == '[':
                sz = self.size_of(t.text)
                if sz and sz[1] is not None:
                    self.next()
                    idx = self.expr()
                    self.expect(']')
                    if idx[0].is_const():
                        return self.read(t.text, int(idx[0].value()))
                    return [self.op.new(t.text) for _ in range(sz[0])]
            if t.text == self.sampler:
                raise NotScreenPosition(f'{self.sampler} used other than as a texture function\'s sampler')
            return self.read(t.text)
        raise NotScreenPosition(f'unexpected {t.text!r}')

    def postfix(self, v):
        while self.peek() is not None:
            t = self.peek()
            if t.text == '.':
                self.next()
                sw = self.next().text
                if any(c not in _SWIZZLE or _SWIZZLE[c] >= len(v) for c in sw):
                    return [self.op.new('.' + sw) for _ in sw]
                v = [v[_SWIZZLE[c]] for c in sw]
            elif t.text == '[':
                self.next()
                idx = self.expr()
                self.expect(']')
                v = [v[int(idx[0].value())]] if idx[0].is_const() and 0 <= idx[0].value() < len(v) else [self.op.new('[]')]
            elif t.text in ('++', '--'):
                self.next()
                v = [self.op.new(t.text) for _ in v]
            else:
                return v
        return v

    def args(self):
        out = []
        self.expect('(')
        if self.peek().text == ')':
            self.next()
            return out
        while True:
            out.append(self.expr())
            t = self.next()
            if t.text == ')':
                return out
            if t.text != ',':
                raise NotScreenPosition(f'expected , or ) in a call, found {t.text!r}')

    def call(self, name_tok):
        f = name_tok.text
        if f in _TEXTURE_FUNCS and self.peek(1) is not None and self.peek(1).text == self.sampler:
            self.expect('(')
            self.next()                                  # the sampler
            rest = []
            while self.peek().text == ',':
                self.next()
                rest.append(self.expr())
            end = self.expect(')')
            self.grab_calls.append((f, rest, name_tok.start, end.end, self.depth))
            return [self.op.new('grab') for _ in range(4)]
        a = self.args()
        if f in _SIZES:
            n = _SIZES[f]
            flat = [c for v in a for c in v]
            if len(flat) == 1:
                flat = flat * n
            if len(flat) < n:
                raise NotScreenPosition(f'{f} of {len(flat)} components')
            flat = flat[:n]
            if f in ('float',) or f.startswith('vec'):
                return flat
            return [self.op.new(f) for _ in flat]       # (ints, uints, bools: conversions not followed)
        if f == 'dot' and len(a) == 2 and len(a[0]) == len(a[1]):
            s = Poly()
            for x, y in zip(*a):
                s = s + x * y
            return [self.guard(s)]
        n = _SIZE_OF_RESULT.get(f, max((len(v) for v in a), default=1))
        if f in _TEXTURE_FUNCS:
            n = 4
        return [self.op.new(f) for _ in range(n)]


# ---------------------------------------------------------------- the screen-position check

def _linear(target, basis):
    """Rational coefficients c with target == sum(c[j] * basis[j]) (polynomial identity), or None."""
    monos = sorted({m for p in basis + [target] for m in p.t})
    rows = [[p.t.get(m, Fraction(0)) for p in basis] + [target.t.get(m, Fraction(0))] for m in monos]
    n = len(basis)
    piv, r = [], 0
    for c in range(n):
        k = next((i for i in range(r, len(rows)) if rows[i][c]), None)
        if k is None:
            continue
        rows[r], rows[k] = rows[k], rows[r]
        pv = rows[r][c]
        rows[r] = [x / pv for x in rows[r]]
        for i in range(len(rows)):
            if i != r and rows[i][c]:
                f = rows[i][c]
                rows[i] = [x - f * y for x, y in zip(rows[i], rows[r])]
        piv.append(c)
        r += 1
    if any(row[n] and not any(row[:n]) for row in rows):
        return None
    sol = [Fraction(0)] * n
    for i, c in enumerate(piv):
        sol[c] = rows[i][n]
    return sol


def _ratio(p, frag):
    """A fragment value as N / D + c: ({varying atom: coefficient} of N, D (a Poly), c), every term of
    N divided by the same D; or None."""
    inv_atom, num, c = None, {}, Fraction(0)
    for mono, coef in p.t.items():
        if mono == ():
            c += coef
            continue
        invs = [a for a in mono if a in frag.inverses]
        rest = [a for a in mono if a not in frag.inverses]
        if len(invs) != 1 or len(rest) != 1 or inv_atom not in (None, invs[0]):
            return None
        inv_atom = invs[0]
        num[rest[0]] = num.get(rest[0], 0) + coef
    if inv_atom is None:
        return None                                     # (no perspective division: not a screen position)
    return num, frag.inverses[inv_atom], c


def screen_uv(vertex_src, fragment_src):
    """The fragment stage's uses of _GrabTexture if every one samples it at the fragment's own screen
    position, else NotScreenPosition (with the reason).

    Each use must be texture(_GrabTexture, uv), textureProj(_GrabTexture, p) or textureLod(..., uv,
    0.0), with uv = N / D + c per component, N and D linear in the stage's inputs (varyings), and,
    the varyings written by the vertex stage as linear combinations of its final gl_Position P (no
    constant term, so they interpolate as P does): D = k * P.w and u = 0.5 * P.x / P.w + 0.5,
    v = 0.5 * P.y / P.w + 0.5, the fragment's window position in [0, 1] (OpenGL's origin: the grab
    texture is the framebuffer's picture, row 0 at the bottom). This is what ComputeGrabScreenPos
    (and a clip position divided in the fragment stage) gives on OpenGL; other UVs (offsets,
    distortion, blur taps, flipped or scaled coordinates) are refused."""
    frag = Stage(fragment_src).run()
    if not frag.grab_calls:
        raise NotScreenPosition(f'the fragment stage does not sample {GRAB_TEXTURE}')
    if len(frag.uses) != len(frag.grab_calls) + 1:
        raise NotScreenPosition(f'{GRAB_TEXTURE} is used other than declared once and sampled')
    vert = Stage(vertex_src, sampler='\0').run()
    if vert.cond_return:
        raise NotScreenPosition('the vertex stage returns early')
    pos = vert.read('gl_Position')
    one = Poly.const(1)
    lin = {}

    def varying(atom):
        if atom not in lin:
            if atom.startswith('#'):
                raise NotScreenPosition('its coordinate depends on a value the check does not follow (a function, a '
                                        'comparison, a branch or a loop)')
            name, _, comp = atom.rpartition('.')
            if name not in vert.decl or vert.decl[name][1] is not None or comp not in 'xyzw' or name not in vert.vars:
                raise NotScreenPosition(f'{atom}: not a varying the vertex stage writes')
            v = vert.read(name)
            k = 'xyzw'.index(comp)
            if k >= len(v):
                raise NotScreenPosition(f'{atom}: no such component')
            sol = _linear(v[k], pos + [one])
            if sol is None:
                raise NotScreenPosition(f'varying {atom} is not a linear function of gl_Position')
            if sol[4]:
                raise NotScreenPosition(f'varying {atom} has a constant term (it does not interpolate as a position)')
            lin[atom] = sol[:4]
        return lin[atom]

    def in_p(coefs):
        out = [Fraction(0)] * 4
        for atom, c in coefs.items():
            for j, x in enumerate(varying(atom)):
                out[j] += c * x
        return out

    for f, args, a, b, depth in frag.grab_calls:
        if f == 'texture' and len(args) == 1 and len(args[0]) >= 2:
            uv = args[0][:2]
        elif f == 'textureLod' and len(args) == 2 and len(args[0]) >= 2 and args[1][0].is_const() and not args[1][0].value():
            uv = args[0][:2]
        elif f == 'textureProj' and len(args) == 1 and len(args[0]) in (3, 4):
            q = args[0][-1]
            uv = [args[0][0] * frag.inv(q), args[0][1] * frag.inv(q)]
        else:
            raise NotScreenPosition(f'{f}({GRAB_TEXTURE}, ...) with {len(args)} more arguments: not a plain sample')
        for axis, comp in ((0, uv[0]), (1, uv[1])):
            r = _ratio(comp, frag)
            if r is None:
                raise NotScreenPosition(f'{f}({GRAB_TEXTURE}): its {"uv"[axis]} is not the fragment\'s screen position '
                                        f'(a varying divided by another, plus a constant: an offset, a scale or another '
                                        f'coordinate)')
            num, den, c = r
            dsol = _ratio_den(den, frag)
            d = in_p(dsol)
            n = in_p(num)
            if d[0] or d[1] or d[2] or not d[3]:
                raise NotScreenPosition(f'{f}({GRAB_TEXTURE}): its {"uv"[axis]} is not divided by gl_Position.w')
            k = d[3]
            other = 1 - axis
            if n[other] or n[2] or n[axis] / k != Fraction(1, 2) or n[3] / k + c != Fraction(1, 2):
                raise NotScreenPosition(f'{f}({GRAB_TEXTURE}): its {"uv"[axis]} is not the fragment\'s screen position '
                                        f'(0.5 * P.{"xy"[axis]} / P.w + 0.5)')
    return frag


def _ratio_den(den, frag):
    """{varying atom: coefficient} of a denominator linear in the varyings (no constant term)."""
    out = {}
    for mono, coef in den.t.items():
        if len(mono) != 1 or mono[0] in frag.inverses or mono[0].startswith('#'):
            raise NotScreenPosition(f'a division by {den.key()}: not linear in the varyings')
        out[mono[0]] = coef
    return out


# ---------------------------------------------------------------- the program rewrite

_OUT_DECL = re.compile(r'^(?P<pre>[ \t]*(?:layout\s*\(\s*location\s*=\s*0\s*\)\s*)?)out(?P<post>\s+(?:(?:highp|mediump|lowp)\s+)?'
                       r'vec4\s+(?P<name>\w+)\s*;)[ \t]*$', re.M)
_ANY_OUT = re.compile(r'^[ \t]*(?:layout\s*\([^)]*\)\s*)?(?:(?:flat|smooth|centroid|highp|mediump|lowp)\s+)*(?:in)?out\s', re.M)

EXTENSIONS = (
    '#ifdef GL_EXT_shader_framebuffer_fetch\n'
    '#extension GL_EXT_shader_framebuffer_fetch : enable\n'
    '#elif defined(GL_ARM_shader_framebuffer_fetch)\n'
    '#extension GL_ARM_shader_framebuffer_fetch : enable\n'
    '#else\n'
    '#error framebuffer fetch: the driver has neither GL_EXT_shader_framebuffer_fetch nor GL_ARM_shader_framebuffer_fetch\n'
    '#endif\n')                         # (no quotes: GLSL ES has no '"', and Mali's compiler refuses it in a skipped branch too)


def _header_end(src):
    """Offset after a stage's #version line and the extension directives that follow it."""
    lines = src.splitlines(keepends=True)
    pos, i = 0, 0
    while i < len(lines) and not lines[i].strip():
        pos += len(lines[i]); i += 1
    if i >= len(lines) or not re.match(r'\s*#\s*version\b', lines[i]):
        raise NotScreenPosition('no #version line')
    pos += len(lines[i]); i += 1
    while i < len(lines):
        s = lines[i].strip()
        if re.match(r'#\s*extension\b', s):
            pos += len(lines[i]); i += 1
        elif re.match(r'#\s*ifdef\s+\w+$', s) and i + 2 < len(lines) and re.match(r'#\s*extension\b', lines[i + 1].strip()) \
                and re.match(r'#\s*endif\b', lines[i + 2].strip()):
            pos += sum(len(x) for x in lines[i:i + 3]); i += 3
        else:
            break
    return pos


def rewrite_fragment(fragment_src, frag):
    """The fragment stage reading the framebuffer: its one output `inout` where the driver has
    GL_EXT_shader_framebuffer_fetch (the colour under the fragment is its value at the start of
    main), else gl_LastFragColorARM; each _GrabTexture sample becomes that colour."""
    outs = _ANY_OUT.findall(glsl._strip_comments(fragment_src))
    m = list(_OUT_DECL.finditer(fragment_src))
    if len(outs) != 1 or len(m) != 1:
        raise NotScreenPosition('the fragment stage does not have exactly one vec4 output at location 0')
    m = m[0]
    if FETCHED in fragment_src:
        raise NotScreenPosition(f'the fragment stage already names {FETCHED}')
    out_name = m.group('name')
    edits = [(_header_end(fragment_src), _header_end(fragment_src), MARK + '\n' + EXTENSIONS),
             (m.start(), m.end(),
              '#ifdef GL_EXT_shader_framebuffer_fetch\n'
              f'{m.group("pre")}inout{m.group("post")}\n'
              '#else\n'
              f'{m.group(0)}\n'
              '#endif'),
             (frag.body_start, frag.body_start,
              '\n#ifdef GL_EXT_shader_framebuffer_fetch\n'
              f'    vec4 {FETCHED} = {out_name};\n'
              '#else\n'
              f'    vec4 {FETCHED} = gl_LastFragColorARM;\n'
              '#endif')]
    for f, args, a, b, depth in frag.grab_calls:
        edits.append((a, b, FETCHED))
    out = fragment_src
    for a, b, text in sorted(edits, key=lambda e: (e[0], e[1]), reverse=True):
        out = out[:a] + text + out[b:]
    return out


def rewrite_program(code):
    """A GLES3 program (every stage block) with its fragment stage reading the framebuffer instead
    of _GrabTexture; NotScreenPosition (why) where it does not sample it at its screen position."""
    blocks = {stage: (a, b) for stage, a, b in glsl.stage_blocks(code)}
    if set(blocks) != {'VERTEX', 'FRAGMENT'}:
        raise NotScreenPosition('not a vertex + fragment program')
    va, vb = blocks['VERTEX']
    fa, fb = blocks['FRAGMENT']
    frag = screen_uv(code[va:vb], code[fa:fb])
    return code[:fa] + rewrite_fragment(code[fa:fb], frag) + code[fb:]


# ---------------------------------------------------------------- the data edit

def _reads_grab(code):
    st = glsl.stage_sources(code)
    return bool(re.search(r'\b%s\b' % GRAB_TEXTURE, glsl._strip_comments(st.get('FRAGMENT', ''))))


def _gles_programs(p, entries):
    """{blob index: code} of a pass's GLES3 / GLES 3.1 subprograms' code entries."""
    out = {}
    for st in C.STAGES:
        for lst, _ in C._tier_lists(p.get(st)):
            for sp in lst:
                if sp['m_GpuProgramType'] in GLES3_TYPES:
                    e = entries[sp['m_BlobIndex']] if sp['m_BlobIndex'] < len(entries) else None
                    if isinstance(e, B.Entry) and e.code:
                        out[sp['m_BlobIndex']] = e.code.decode('utf-8')
    return out


def _has_gles(p):
    return any(sp['m_GpuProgramType'] in GLES3_TYPES for st in C.STAGES for lst, _ in C._tier_lists(p.get(st)) for sp in lst)


def _gles_only(p, rewritten=None, require=False):
    """A pass (a copy, edited in place) with only its GLES3 / GLES 3.1 subprograms; those whose entry
    was rewritten point to the new entry (rewritten: {old: new}) and, with require, ask for
    framebuffer fetch."""
    for st in C.STAGES:
        prog = p.get(st)
        if not prog:
            continue
        if prog.get('m_SubPrograms') is not None:
            prog['m_SubPrograms'] = [sp for sp in prog['m_SubPrograms'] if sp['m_GpuProgramType'] in GLES3_TYPES]
        if prog.get('m_PlayerSubPrograms'):
            for tier, lst in enumerate(prog['m_PlayerSubPrograms']):
                keep = [i for i, sp in enumerate(lst) if sp['m_GpuProgramType'] in GLES3_TYPES]
                pbi = prog['m_ParameterBlobIndices'][tier]
                prog['m_ParameterBlobIndices'][tier] = [pbi[i] for i in keep]
                prog['m_PlayerSubPrograms'][tier] = [lst[i] for i in keep]
        if rewritten is None:
            continue
        for lst, _ in C._tier_lists(prog):
            for sp in lst:
                if sp['m_BlobIndex'] in rewritten:
                    sp['m_BlobIndex'] = rewritten[sp['m_BlobIndex']]
                if require:
                    sp['m_ShaderRequirements'] = sp['m_ShaderRequirements'] | FBFETCH
    if isinstance(p.get('m_Platforms'), list):
        p['m_Platforms'] = [B.PLATFORM_GLES3PLUS]


def apply(tree, mode=True, names=None):
    """Gives each qualifying SubShader of one Shader typetree a framebuffer-fetch copy in front of it
    (module docstring; tree edited in place). mode: True (the copy requires framebuffer fetch) or
    'always'. names: a regex the shader's name must match (None: every shader). Returns a Result."""
    if mode not in MODES:
        raise ValueError(f'grab_fetch mode {mode!r} (true or "always")')
    pf = tree['m_ParsedForm']
    r = Result(pf['m_Name'])
    subs = pf['m_SubShaders']
    if not any(p.get('m_Type') == GRAB_PASS for ss in subs for p in ss['m_Passes']):
        r.why = 'no GrabPass'
        return r
    if names and not re.search(names, r.name):
        r.why = 'not in grab_fetch_names'
        return r
    if B.PLATFORM_GLES3PLUS not in tree['platforms']:
        r.status, r.why = 'skipped', 'no GLES3 programs'
        return r
    blobs = B.ShaderBlobs(tree)
    entries = C.platform_entries(tree, B.PLATFORM_GLES3PLUS, blobs)
    if any(isinstance(e, B.Entry) and MARK.encode() in e.code for e in entries):
        r.why = 'already reads the framebuffer (grab_fetch done before)'
        return r
    out = [e.copy() if e is not None else None for e in entries]
    segs = blobs.segments(B.PLATFORM_GLES3PLUS)
    done = {}                           # old entry -> new entry (one rewrite each)
    plan = []                           # (subshader index, its copy)
    for si, ss in enumerate(subs):
        passes = ss['m_Passes']
        grabs = [pi for pi, p in enumerate(passes) if p.get('m_Type') == GRAB_PASS]
        if not grabs:
            continue
        try:
            named = [passes[pi].get('m_TextureName') for pi in grabs if passes[pi].get('m_TextureName')]
            if named:
                raise NotScreenPosition(f'named GrabPass {named[0]!r} (copied once a frame: not converted)')
            readers = {}
            for pi, p in enumerate(passes):
                if p.get('m_Type') == GRAB_PASS:
                    continue
                if not _has_gles(p):
                    raise NotScreenPosition(f'pass {pi} has no GLES3 programs')
                progs = _gles_programs(p, entries)
                if any(_reads_grab(c) for c in progs.values()):
                    readers[pi] = progs
            # each reading pass right after an unnamed GrabPass (the picture it reads is the one under
            # its own fragments); a GrabPass no pass reads after it is left out as it is
            for pi in sorted(readers):
                if pi == 0 or passes[pi - 1].get('m_Type') != GRAB_PASS:
                    raise NotScreenPosition(f'pass {pi} samples {GRAB_TEXTURE} without a GrabPass right before it')
            if mode is True and any('m_ShaderRequirements' not in sp for pi in readers for st in C.STAGES
                                    for lst, _ in C._tier_lists(passes[pi].get(st)) for sp in lst):
                raise NotScreenPosition('subprograms without m_ShaderRequirements (this Unity version): use "always"')
            rewritten = {}
            for pi, progs in sorted(readers.items()):
                for i, code in sorted(progs.items()):
                    if not _reads_grab(code):
                        continue                # (a variant that does not sample it: as it is)
                    if i not in done:
                        try:
                            new = rewrite_program(code)
                        except NotScreenPosition as ex:
                            kws = ' '.join(entries[i].keywords) or '(no keywords)'
                            raise NotScreenPosition(f'pass {pi} program {i} ({kws}): {ex}')
                        e = out[i].copy()
                        e.code = new.encode('utf-8')
                        done[i] = len(out)
                        out.append(e)
                        segs.append(segs[i])
                        r.programs += 1
                    rewritten[i] = done[i]
        except NotScreenPosition as ex:
            r.left.append((si, str(ex)))
            continue
        cp = copy.deepcopy(ss)
        cp['m_Passes'] = []
        for pi, p in enumerate(copy.deepcopy(passes)):
            if pi in grabs:
                continue
            if pi in readers:
                _gles_only(p, rewritten, require=mode is True)
            else:
                _gles_only(p)
            cp['m_Passes'].append(p)
        plan.append((si, cp))
        r.grabs += len(grabs)
    if not plan:
        r.status = 'skipped'
        r.why = '; '.join(f'SubShader {si}: {w}' for si, w in r.left)
        return r
    blobs.set_entries(B.PLATFORM_GLES3PLUS, out, segs if blobs.nested else None)
    blobs.store()
    for si, cp in sorted(plan, key=lambda x: x[0], reverse=True):
        subs.insert(si, cp)
    r.status, r.subshaders = 'changed', len(plan)
    r.why = (f'{len(plan)} SubShader(s) given a copy without their {r.grabs} GrabPass(es), {r.programs} programs '
             f'reading the framebuffer' + ('; they require framebuffer fetch' if mode is True and r.programs else ''))
    if r.left:
        r.why += '; ' + '; '.join(f'SubShader {si} left as it is: {w}' for si, w in r.left)
    return r
