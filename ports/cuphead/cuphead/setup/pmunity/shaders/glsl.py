"""GLSL 1.50 as Unity's HLSLcc writes it for OpenGL Core -> GLSL ES 3.00 for Unity's GLES3 renderer.

A GL program's code holds every stage, each in its own block, and Unity's GL backends compile each
block as one shader (the block's first line is its #version):

    #ifdef VERTEX
    #version 150
    #extension GL_ARB_explicit_attrib_location : require
    ...
    #endif
    #ifdef FRAGMENT
    ...
    #endif

HLSLcc already writes the subset of GLSL that both languages share (explicit conversions, `texture`
and `textureLod`, `layout(location)` outputs, no fixed-function state), so a program needs only:

  * `#version 300 es` instead of `#version 150` / `#version 330`;
  * no desktop extensions that ES 3.00 has built in (explicit attribute locations, the float/int bit
    casts); any other extension is kept, so a program that needs one fails to compile on a driver
    without it, as Unity's own GLES3 build would;
  * default precisions, because ES has no default float precision in fragment shaders and gives
    samplers a default of lowp. The default here is highp for floats, ints and every sampler type
    the stage declares: desktop GL computes and samples in 32-bit floats, so highp gives the same
    numbers the game shows on a PC or Mac. `precision='default-samplers'` leaves samplers at ES's
    defaults (sampler2D and samplerCube lowp; the result of a lowp texture() is then only 10 bits
    precise) - not the game's own picture, for A/B tests only.

Two rewrites that keep every operation and its operands (so the results are the same), on by
default (`optimize`):

  * const-arrays: HLSLcc writes a constant table (blur weights, sample offsets) as a global array
    that main() fills element by element on every invocation (`ImmCB_0_0_0[0] = vec4(...);`). It
    becomes a `const` array with the same values, which the driver folds into the code.
  * unroll: a loop with literal bounds (`for(int i = 0 ; i<7 ; i++)`, at most UNROLL_MAX trips
    and UNROLL_STATEMENTS statements written out in all) whose body only computes (no break /
    continue / return / discard / declarations / nested loop, the counter only read) is written
    out once per trip with the counter as a literal.

On the RGSP's Mali-G31 both together make Cuphead's 7-tap blur passes ~4% cheaper (see
tools/shadercheck -t); the rest of a pass is texture fetches. A loop written out costs what the
loop costs until the driver runs out of registers, and then several times more: URP's Bokeh tap
(15 statements) written out 8 times costs the same as its loop, 12 times 4 times as much, 16
times 10 times; the Post-processing Stack's 16-sample depth of field (22 statements) 2.7 times.
Hence the statement limit (docs/shaders.md, "Exact rewrites for the Mali-G31's compiler"); a
loop over it stays a loop, as HLSLcc wrote it.

Programs that use what GLSL ES 3.10 has and 3.00 lacks (multisampled textures, texture gather,
bit-field functions) raise NeedsES31; translated with es='310' (`#version 310 es`) they become
GLES 3.1 programs, which Unity runs where the device has OpenGL ES 3.1 or later (the converter
types them so). Programs that use GLSL with no ES equivalent (fixed-function built-ins such as
gl_Vertex, gl_FragColor in a 300 es shader, rectangle and 1D samplers, `noperspective`, images,
atomics, storage buffers) raise Unsupported; the converter then gives that shader no GLES3
programs, and Unity treats it as not supported on the device, just as a shader without GLES3
programs in an Android build.

GLSL 4.x (GLCore41 / GLCore43 programs, `#version 410` - `450`: shaders of `#pragma target 4.5`
and up) is HLSLcc's output for OpenGL 4.1+, which uses what GLSL 4.20 has built in. The rules are
the same, plus:

  * the extensions `GL_ARB_shading_language_420pack`, `GL_ARB_shader_storage_buffer_object` and
    `GL_ARB_shader_image_load_store` are dropped (what HLSLcc uses of them is in ES 3.10);
  * the unused `precise <type> u_xlat_precise_<type>;` declarations HLSLcc writes at the top of
    each stage are dropped (any other `precise` is a GLSL ES 3.20 qualifier: Unsupported);
  * `layout(location = n)` on varyings (vertex outputs, fragment inputs) is removed for ES 3.00,
    which matches varyings by name only (HLSLcc gives a varying the same name and location in both
    stages); ES 3.10 programs keep them;
  * what ES 3.10 has besides the above raises NeedsES31: explicit binding points
    (`layout(binding = n)`) and uniform locations outside Unity's macro blocks, storage buffers
    (`buffer`, `std430`), images with a format qualifier (ES needs the format; an image without
    one is Unsupported), image load/store and buffer atomics, `early_fragment_tests`;
  * what only desktop GL 4.x or ES 3.20 has stays Unsupported: cube map array, buffer and 1D
    textures, image atomics, `textureQueryLevels`, interpolation functions, interface blocks
    (`out gl_PerVertex {...}`), layout qualifiers such as `component` or `index`.

Compute kernels (ComputeShader assets, kernel_to_es) are HLSLcc's GLSL 4.20 / 4.30 compute
shaders for OpenGL Core, one shader per kernel variant. They become GLSL ES 3.10 compute shaders
under the GLSL 4.x rules, plus what ES 3.10 has for compute: `barrier()`,
`memoryBarrierShared()`, `groupMemoryBarrier()`, `shared` variables and atomic counters
(`GL_ARB_compute_shader` and `GL_ARB_shader_atomic_counters` are dropped too). Image atomics get
`GL_OES_shader_image_atomic` (core in ES 3.20). Two image rules of ES 3.10 that desktop GL lacks:
every image has a format qualifier (HLSLcc leaves it out of write-only images for desktop GL: the
caller gives it, from the kernel's Vulkan SPIR-V, where HLSLcc wrote the format it would also
write for GLES), and an image of a format other than r32f, r32i and r32ui is readonly or
writeonly. Unity's own GLES3 kernels in its built-in resources (which hold GLCore and GLES3
kernels of the same compute shaders) differ from the GLCore ones in the header only (version,
the 420pack extension, the `precise` dummies) and in how HLSLcc writes the same operations
(`uint(...)` around a value that already is one, `for` loops for `while(true)` ones).
"""
import re


class Unsupported(Exception):
    pass


class NeedsES31(Unsupported):
    """The program uses what GLSL ES 3.10 has and 3.00 lacks (multisampled textures, texture
    gather, bit-field functions): it can be translated as a GLES 3.1 program (`es='310'`)."""


VERSIONS = ('150', '330')                    # #version lines this translation handles
DROP_EXTENSIONS = {
    'GL_ARB_explicit_attrib_location',       # ES 3.00: layout(location) on vertex inputs and fragment outputs
    'GL_ARB_shader_bit_encoding',            # ES 3.00: floatBitsToInt & co.
}
SAMPLER_TYPES = ('sampler2D', 'sampler3D', 'samplerCube', 'sampler2DShadow', 'samplerCubeShadow',
                 'sampler2DArray', 'sampler2DArrayShadow', 'isampler2D', 'isampler3D', 'isamplerCube',
                 'isampler2DArray', 'usampler2D', 'usampler3D', 'usamplerCube', 'usampler2DArray',
                 'sampler2DMS', 'isampler2DMS', 'usampler2DMS')          # (the last three: ES 3.10)
_SAMPLER_RE = re.compile(r'\b(%s)\b' % '|'.join(SAMPLER_TYPES))
_WORD = re.compile(r'\w+')

# no ES 3.00 equivalent
_UNSUPPORTED = [
    (re.compile(r'\bgl_(Vertex|Normal|Color|SecondaryColor|MultiTexCoord\d|ModelView\w*|Projection\w*|NormalMatrix|TextureMatrix\w*|FragColor|FragData)\b'),
     'fixed-function built-in'),
    (re.compile(r'\b(sampler1D\w*|sampler2DRect\w*|samplerBuffer|[iu]?sampler2DMSArray|image\w+D\w*)\b'), 'sampler type'),
    (re.compile(r'\b(texture1D\w*|texture2D\w*|texture3D\w*|textureCube\w*|shadow2D\w*)\s*\('), 'GLSL 1.10 texture function'),
    (re.compile(r'\b(textureQueryLod|textureQueryLevels|fma|imageLoad|imageStore|atomic\w+|memoryBarrier\w*|barrier|'
                r'interpolateAt\w+)\s*\('),
     'ES 3.2+ / desktop function'),
    (re.compile(r'\b(noperspective|sample|patch|subroutine|precise)\b(?=\s+(in|out|uniform|centroid|flat|smooth|vec|float|int|uint|mat|bool))'),
     'qualifier'),
    (re.compile(r'layout\s*\([^)]*\b(binding|offset|std430|index)\b'), 'layout qualifier'),
    (re.compile(r'\bbuffer\s+\w+\s*\{'), 'storage buffer'),
    (re.compile(r'\b(gl_ClipDistance|gl_PrimitiveID|gl_Layer|gl_ViewportIndex|gl_SampleID|gl_SamplePosition|gl_SampleMask\w*)\b'),
     'built-in variable'),
    (re.compile(r'\b(double|dvec\d|dmat\d)\b'), 'double precision'),
]
# what GLSL ES 3.10 has (Unity's GLES 3.1 programs, gpu program type 3, run where the device has ES 3.1+)
_ES31 = [
    (re.compile(r'\b[iu]?sampler2DMS\b'), 'sampler type'),
    (re.compile(r'\b(textureGather\w*|bitfield\w+|bitCount|findLSB|findMSB|packUnorm4x8|packSnorm4x8|unpackUnorm4x8|'
                r'unpackSnorm4x8|uaddCarry|usubBorrow|umulExtended|imulExtended|frexp|ldexp)\s*\('), 'ES 3.1 function'),
]

# GLSL 4.x: GLCore41 / GLCore43 programs (HLSLcc's output for OpenGL 4.1+)
VERSIONS_4X = ('400', '410', '420', '430', '440', '450')
DROP_EXTENSIONS_4X = DROP_EXTENSIONS | {
    'GL_ARB_shading_language_420pack',       # what HLSLcc uses of it (binding points) is ES 3.10's
    'GL_ARB_shader_storage_buffer_object',   # ES 3.10: storage buffers
    'GL_ARB_shader_image_load_store',        # ES 3.10: images (with a format qualifier)
}
IMAGE_TYPES = ('image2D', 'image3D', 'imageCube', 'image2DArray', 'iimage2D', 'iimage3D', 'iimageCube',
               'iimage2DArray', 'uimage2D', 'uimage3D', 'uimageCube', 'uimage2DArray')    # ES 3.10, no default precision
IMAGE_FORMATS = ('rgba32f', 'rgba16f', 'r32f', 'rgba8', 'rgba8_snorm', 'rgba32i', 'rgba16i', 'rgba8i', 'r32i',
                 'rgba32ui', 'rgba16ui', 'rgba8ui', 'r32ui')                               # what ES 3.10 has
_IMAGE_DECL = re.compile(r'^(.*)\b(%s)\s+(\w+)\s*[\[;]' % '|'.join(IMAGE_TYPES), re.M)
# HLSLcc's GL 4.x stages start with these, used or not
_PRECISE_DUMMY = re.compile(r'^precise ([biu]?vec4) (u_xlat_precise_\1);[ \t]*\n', re.M)
# location of a varying: vertex outputs, fragment inputs (ES 3.00 has none; it matches by name)
_VARYING_LOCATION = {
    st: re.compile(r'^([ \t]*)layout\s*\(\s*location\s*=\s*\d+\s*\)[ \t]*((?:(?:invariant|flat|smooth|centroid)\s+)*%s\s)' % io, re.M)
    for st, io in (('VERTEX', 'out'), ('FRAGMENT', 'in'))}
_UNSUPPORTED_4X = [
    _UNSUPPORTED[0],                                                         # fixed-function built-ins
    (re.compile(r'\b([iu]?sampler1D\w*|[iu]?sampler2DRect\w*|[iu]?samplerBuffer|[iu]?sampler2DMSArray|[iu]?samplerCubeArray\w*|'
                r'[iu]?image(?:1D\w*|2DRect|Buffer|CubeArray|2DMS\w*))\b'), 'sampler type'),
    _UNSUPPORTED[2],                                                         # GLSL 1.10 texture functions
    (re.compile(r'\b(textureQueryLod|textureQueryLevels|textureSamples|imageSamples|fma|imageAtomic\w+|atomicCounter\w*|'
                r'barrier|groupMemoryBarrier|memoryBarrierShared|interpolateAt\w+)\s*\('), 'ES 3.2+ / desktop function'),
    (re.compile(r'\b(noperspective|sample|patch|subroutine|precise)\b(?=\s+(in|out|uniform|centroid|flat|smooth|[biud]?vec|'
                r'float|int|uint|mat|bool|highp|mediump|lowp))'), 'qualifier'),
    (re.compile(r'layout\s*\([^)]*\b(index|component|xfb_\w+|origin_upper_left|pixel_center_integer|depth_\w+|offset|align|'
                r'stream)\b'), 'layout qualifier'),
    (re.compile(r'^[ \t]*(?:layout\s*\([^)]*\)\s*)?(?:(?:flat|smooth|centroid)\s+)*(?:in|out)\s+\w+\s*\{', re.M), 'interface block'),
    (re.compile(r'\b(gl_ClipDistance|gl_CullDistance|gl_PrimitiveID|gl_Layer|gl_ViewportIndex|gl_SampleID|gl_SamplePosition|'
                r'gl_SampleMask\w*|gl_PerVertex)\b'), 'built-in variable'),
    _UNSUPPORTED[-1],                                                        # double precision
]
_ES31_4X = _ES31 + [
    (re.compile(r'layout\s*\([^)]*\b(binding|std430|early_fragment_tests)\b'), 'layout qualifier'),
    (re.compile(r'layout\s*\([^)]*\blocation\b[^)]*\)\s*(?:(?:highp|mediump|lowp)\s+)?uniform\b'), 'uniform location'),
    (re.compile(r'\bbuffer\s+\w+\s*\{'), 'storage buffer'),
    (re.compile(r'\b(%s)\b' % '|'.join(IMAGE_TYPES)), 'image'),
    (re.compile(r'\b(imageLoad|imageStore|imageSize|atomic(?:Add|Min|Max|And|Or|Xor|Exchange|CompSwap)|'
                r'memoryBarrier(?:Buffer|Image|AtomicCounter)?)\s*\('), 'ES 3.1 function'),
]


def _drop_precise_dummies(src):
    """HLSLcc's `precise vec4 u_xlat_precise_vec4;` (and ivec4, bvec4, uvec4) lines, where nothing
    else in the stage names them."""
    for m in list(_PRECISE_DUMMY.finditer(src)):
        rest = src.replace(m.group(0), '', 1)
        if not re.search(r'\b%s\b' % m.group(2), rest):
            src = rest
    return src


def _check_images(code, stage):
    """Unsupported for an image without a format qualifier (desktop GL can store to one, ES cannot)."""
    for m in _IMAGE_DECL.finditer(code):
        lay = re.findall(r'layout\s*\(([^)]*)\)', m.group(1))
        if not any(re.search(r'\b(%s)\b' % '|'.join(IMAGE_FORMATS), q) for q in lay):
            raise Unsupported(f'{stage}: image without a format qualifier {m.group(3)!r} (GLSL ES needs the format, '
                              f'the program does not give it)')


def stage_blocks(code):
    """[(stage, start, end)]: the text between '#ifdef <STAGE>' and its matching #endif (code[start:end])."""
    out = []
    lines = code.splitlines(keepends=True)
    pos = 0
    i = 0
    while i < len(lines):
        m = re.match(r'\s*#\s*ifdef\s+(VERTEX|FRAGMENT|GEOMETRY|HULL|DOMAIN)\b', lines[i])
        if not m:
            pos += len(lines[i]); i += 1
            continue
        stage = m.group(1)
        start = pos + len(lines[i])
        depth = 1
        pos = start; i += 1
        while i < len(lines) and depth:
            if re.match(r'\s*#\s*(if|ifdef|ifndef)\b', lines[i]):
                depth += 1
            elif re.match(r'\s*#\s*endif\b', lines[i]):
                depth -= 1
                if depth == 0:
                    out.append((stage, start, pos))
            pos += len(lines[i]); i += 1
    return out


def _strip_comments(s):
    return re.sub(r'//[^\n]*|/\*.*?\*/', ' ', s, flags=re.S)


UNROLL_MAX = 16
UNROLL_STATEMENTS = 120     # trips x statements of the body: as cheap as the loop up to here (Mali-G31)
OPTIMIZE = ('const-arrays', 'unroll')
_NUM = r'[-+]?(?:\d+\.?\d*(?:[eE][-+]?\d+)?|\.\d+(?:[eE][-+]?\d+)?)[uU]?'
_TYPES = r'(?:float|int|uint|bool|[biu]?vec[234]|mat[234](?:x[234])?)'


def const_arrays(src):
    """Global arrays that main() fills with literals before anything else -> const arrays."""
    done = 0
    for m in list(re.finditer(r'^(%s) (ImmCB_\w+)\[(\d+)\];\n' % _TYPES, src, re.M)):
        typ, name, n = m.group(1), m.group(2), int(m.group(3))
        # element assignments: '<name>[i] = <typ>(<literals>);' or '<name>[i] = <literal>;'
        rx = re.compile(r'^[ \t]*%s\[(\d+)\] = ((?:%s)\((?:\s*%s\s*,)*\s*%s\s*\)|%s);\n' % (name, _TYPES, _NUM, _NUM, _NUM), re.M)
        assigns = list(rx.finditer(src))
        vals = {}
        for a in assigns:
            vals.setdefault(int(a.group(1)), []).append(a.group(2))
        if sorted(vals) != list(range(n)) or any(len(v) != 1 for v in vals.values()):
            continue
        rest = rx.sub('', src)
        # any other write to the array (assignment, compound assignment, ++/--, out argument) -> leave it
        if re.search(r'\b%s\s*\[[^\]]*\](\.\w+)?\s*([-+*/%%&|^]?=(?!=)|\+\+|--)' % name, rest) or \
           re.search(r'\b%s\b(?!\s*\[)' % name, rest.replace(m.group(0), '')):
            continue
        # the assignments must come first in main(), before any statement that could read the array
        mm = re.search(r'void main\(\)\s*\{\n', src)
        if not mm or any(a.start() < mm.end() for a in assigns):
            continue
        head = src[mm.end():max(a.end() for a in assigns)]
        if rx.sub('', head).strip():
            continue
        ctor = '%s[%d](%s)' % (typ, n, ', '.join(vals[i][0] if '(' in vals[i][0] or typ in ('float', 'int', 'uint') else f'{typ}({vals[i][0]})' for i in range(n)))
        src = rest.replace(m.group(0), 'const %s %s[%d] = %s;\n' % (typ, name, n, ctor))
        done += 1
    return src, done


def unroll(src, limit=UNROLL_MAX, statements=UNROLL_STATEMENTS):
    """Loops with literal bounds and a plain body -> one copy of the body per trip (at most `limit`
    trips and `statements` statements written out)."""
    done = 0
    rx = re.compile(r'^([ \t]*)for\(int (\w+) = (?:int\()?(-?\d+)\)? ?; ?\2 ?(<|<=) ?(-?\d+) ?; ?\2\+\+\)\n\1\{\n', re.M)
    pos = 0
    while True:
        m = rx.search(src, pos)
        if not m:
            break
        ind, var, a, op, b = m.group(1), m.group(2), int(m.group(3)), m.group(4), int(m.group(5))
        end = re.compile(r'^%s\}\n' % re.escape(ind), re.M).search(src, m.end())
        if not end:
            pos = m.end(); continue
        body = src[m.end():end.start()]
        trips = list(range(a, b + 1 if op == '<=' else b))
        bad = (not 0 < len(trips) <= limit or len(trips) * body.count(';') > statements or
               '{' in body or '}' in body or
               re.search(r'\b(break|continue|return|discard|for|while|do)\b', body) or
               re.search(r'^\s*(const\s+)?(highp |mediump |lowp )?%s\s+\w+' % _TYPES, body, re.M) or
               re.search(r'\b%s\s*([-+*/%%&|^]?=(?!=)|\+\+|--)' % var, body) or
               re.search(r'(\+\+|--)\s*%s\b' % var, body))
        if bad:
            pos = m.end(); continue
        out = ''.join(re.sub(r'\b%s\b' % var, str(k), body) for k in trips)
        src = src[:m.start()] + out + src[end.end():]
        pos = m.start() + len(out)
        done += 1
    return src, done


_ANY = {}


def _any_of(rules):
    """One regex that matches where any of rules' does (each keeps its own flags): the rules are
    searched one by one only when it matches, to report the first that does."""
    if id(rules) not in _ANY:
        _ANY[id(rules)] = re.compile('|'.join(f'(?{"m" if rx.flags & re.M else ""}:{rx.pattern})' if rx.flags & re.M
                                              else f'(?:{rx.pattern})' for rx, _ in rules))
    return _ANY[id(rules)]


def _code_lines(body):
    """A stage's source without comments and preprocessor lines (the macro blocks of Unity 2019+
    define layout qualifiers the player switches by device: not code the stage necessarily uses)."""
    return re.sub(r'^[ \t]*#[^\n]*', '', body, flags=re.M)


def stage_to_es(src, stage, precision='highp', optimize=OPTIMIZE, notes=None, es='300'):
    """One stage's source (starting with its #version line) -> GLSL ES 3.00 (es='310': 3.10).
    GLSL 4.x stages (VERSIONS_4X: GLCore41 / GLCore43 programs) get the rules of the module
    docstring's last part as well."""
    head = re.match(r'\s*#\s*version\s+(\d+)', src)
    gl4 = bool(head) and head.group(1) in VERSIONS_4X
    if gl4:
        src = _drop_precise_dummies(src)
    body = _strip_comments(src)
    code = _code_lines(body)
    rules = _UNSUPPORTED_4X if gl4 else _UNSUPPORTED
    for rx, what in (rules if _any_of(rules).search(code) else ()):     # (one pass when none matches)
        m = rx.search(code)
        if m:
            raise Unsupported(f'{stage}: {what} {m.group(0).strip()!r}')
    if gl4:
        _check_images(code, stage)
    if es == '300':
        for rx, what in (_ES31_4X if gl4 else _ES31):
            m = rx.search(code)
            if m:
                raise NeedsES31(f'{stage}: {what} {m.group(0).strip()!r} (GLSL ES 3.10)')
    lines = src.splitlines(keepends=True)
    out = []
    i = 0
    while i < len(lines) and not lines[i].strip():
        i += 1
    m = re.match(r'\s*#\s*version\s+(\d+)\s*(\w*)', lines[i]) if i < len(lines) else None
    if not m:
        raise Unsupported(f'{stage}: no #version line')
    if not (m.group(1) in VERSIONS and not m.group(2) or gl4 and m.group(2) in ('', 'core')):
        raise Unsupported(f'{stage}: #version {m.group(1)} {m.group(2)}'.rstrip())
    drop = DROP_EXTENSIONS_4X if gl4 else DROP_EXTENSIONS
    out.append(f'#version {es} es\n')
    i += 1
    # the extension directives right after #version (they must precede any declaration); Unity
    # 2019+ wraps the optional ones: #ifdef GL_ARB_shader_bit_encoding / #extension ... / #endif
    while i < len(lines):
        s = lines[i].strip()
        e = re.match(r'#\s*extension\s+(\w+)\s*:\s*(\w+)', s)
        w = re.match(r'#\s*ifdef\s+(\w+)$', s)
        if e:
            if e.group(1) not in drop:
                out.append(lines[i])
            i += 1
        elif w and i + 2 < len(lines) and re.match(r'#\s*extension\s+%s\s*:' % w.group(1), lines[i + 1].strip()) \
                and re.match(r'#\s*endif\b', lines[i + 2].strip()):
            if w.group(1) not in drop:
                out += lines[i:i + 3]
            i += 3
        elif not s:
            i += 1
        else:
            break
    out.append(precision_block(body, precision, images=gl4))
    rest = ''.join(lines[i:])
    if gl4 and es == '300' and stage in _VARYING_LOCATION:
        rest = _VARYING_LOCATION[stage].sub(r'\1\2', rest)
    if 'const-arrays' in optimize:
        rest, n = const_arrays(rest)
        if n and notes is not None: notes.append(f'{stage} const-arrays {n}')
    if 'unroll' in optimize:
        rest, n = unroll(rest)
        if n and notes is not None: notes.append(f'{stage} unroll {n}')
    out.append(rest)
    return ''.join(out)


def precision_block(body, precision='highp', images=False):
    """Default precision statements for one stage (body: its source without comments); images:
    also for the image types it declares (GLSL 4.x stages)."""
    p = ['precision highp float;\n', 'precision highp int;\n']
    # (the types used: names that are a whole word of the source, as re.search(r'\b<type>\b') finds
    # them, from one pass over its words instead of one search per type)
    words = set(_WORD.findall(body))
    used = [t for t in SAMPLER_TYPES + (IMAGE_TYPES if images else ()) if t in words]
    for t in used:
        if precision == 'highp' or t not in ('sampler2D', 'samplerCube'):
            p.append(f'precision highp {t};\n')      # (types other than these two have no default in ES)
    return ''.join(p)


# ---- compute kernels (ComputeShader assets)
DROP_EXTENSIONS_COMPUTE = DROP_EXTENSIONS_4X | {
    'GL_ARB_compute_shader',                 # ES 3.10: compute shaders
    'GL_ARB_shader_atomic_counters',         # ES 3.10: atomic counters
}
ES_IMAGE_FORMATS = IMAGE_FORMATS
_RW_IMAGE_FORMATS = ('r32f', 'r32i', 'r32ui')    # ES 3.10: the only formats an image may be read and written in
_COMPUTE_ONLY = re.compile(r'\b(barrier|groupMemoryBarrier|memoryBarrierShared|atomicCounter\w*)\s*\(')
_UNSUPPORTED_COMPUTE = [
    _UNSUPPORTED_4X[0], _UNSUPPORTED_4X[1], _UNSUPPORTED_4X[2],
    (re.compile(r'\b(textureQueryLod|textureQueryLevels|textureSamples|imageSamples|fma|interpolateAt\w+)\s*\('),
     'ES 3.2+ / desktop function'),
    _UNSUPPORTED_4X[4],
    # `offset` only on atomic counters (ES 3.10 has them in compute shaders)
    (re.compile(r'layout\s*\([^)]*\b(index|component|xfb_\w+|origin_upper_left|pixel_center_integer|depth_\w+|align|'
                r'stream)\b|layout\s*\([^)]*\boffset\b[^)]*\)(?!\s*uniform\s+atomic_uint\b)'), 'layout qualifier'),
    _UNSUPPORTED_4X[6], _UNSUPPORTED_4X[7], _UNSUPPORTED_4X[8],
]
_IMAGE_DECL_LINE = re.compile(r'^(?P<pre>[^\n;{}]*?)\b(?P<type>%s)\s+(?P<name>\w+)\s*(?P<arr>\[[^\]]*\])?\s*;' % '|'.join(IMAGE_TYPES), re.M)


def _image_formats(src, formats):
    """Gives each image declared without a format qualifier the one formats names (ES 3.10 needs one)."""
    def fix(m):
        pre = m.group('pre')
        lay = re.search(r'layout\s*\(([^)]*)\)', pre)
        if lay and re.search(r'\b(%s)\b' % '|'.join(IMAGE_FORMATS), lay.group(1)):
            return m.group(0)
        fmt = (formats or {}).get(m.group('name'))
        if not fmt:
            return m.group(0)
        if fmt not in ES_IMAGE_FORMATS:
            raise Unsupported(f'COMPUTE: image {m.group("name")!r} of format {fmt} (GLSL ES has no such image format)')
        if lay:
            pre = pre[:lay.start()] + f'layout({lay.group(1).strip()}, {fmt})' + pre[lay.end():]
        else:
            pre = re.sub(r'\b(uniform)\b', rf'layout({fmt}) \1', pre, count=1)
        return pre + m.group(0)[len(m.group('pre')):]
    return _IMAGE_DECL_LINE.sub(fix, src)


def _check_image_access(code):
    """ES 3.10: an image of a format other than r32f, r32i and r32ui is readonly or writeonly."""
    for m in _IMAGE_DECL_LINE.finditer(code):
        pre = m.group('pre')
        fmt = re.search(r'\b(%s)\b' % '|'.join(IMAGE_FORMATS), pre)
        if fmt and fmt.group(1) not in _RW_IMAGE_FORMATS and not re.search(r'\b(readonly|writeonly)\b', pre):
            raise Unsupported(f'COMPUTE: image {m.group("name")!r} read and written ({fmt.group(1)}: GLSL ES reads and '
                              f'writes only r32f, r32i and r32ui images)')


def image_names(src):
    """The names of the images a kernel declares without a format qualifier."""
    out = []
    for m in _IMAGE_DECL_LINE.finditer(_strip_comments(src)):
        lay = re.findall(r'layout\s*\(([^)]*)\)', m.group('pre'))
        if not any(re.search(r'\b(%s)\b' % '|'.join(IMAGE_FORMATS), q) for q in lay):
            out.append(m.group('name'))
    return out


def kernel_to_es(src, precision='highp', image_formats=None, optimize=OPTIMIZE, notes=None):
    """One compute kernel (HLSLcc's GLSL 4.20 / 4.30 for OpenGL Core: one compute shader, starting
    with its #version line) -> GLSL ES 3.10. image_formats: {image name: format qualifier} for the
    images the kernel declares without a format (image_names(); write-only images). Raises
    Unsupported for what ES 3.10 compute shaders do not have (the module docstring)."""
    m = re.match(r'\s*#\s*version\s+(\d+)\s*(\w*)', src)
    if not m or m.group(1) not in VERSIONS_4X or m.group(2) not in ('', 'core'):
        raise Unsupported('COMPUTE: ' + (f'#version {m.group(1)} {m.group(2)}'.rstrip() if m else 'no #version line'))
    if not re.search(r'layout\s*\([^)]*\blocal_size_x\b', src):
        raise Unsupported('COMPUTE: not a compute shader (no local_size layout)')
    src = _drop_precise_dummies(src)
    src = _image_formats(src, image_formats)
    body = _strip_comments(src)
    code = _code_lines(body)
    for rx, what in _UNSUPPORTED_COMPUTE:
        mm = rx.search(code)
        if mm:
            raise Unsupported(f'COMPUTE: {what} {mm.group(0).strip()!r}')
    _check_images(code, 'COMPUTE')
    _check_image_access(code)
    lines = src.splitlines(keepends=True)
    i = 0
    while i < len(lines) and not lines[i].strip():
        i += 1
    out = ['#version 310 es\n']
    i += 1
    while i < len(lines):
        s = lines[i].strip()
        e = re.match(r'#\s*extension\s+(\w+)\s*:\s*(\w+)', s)
        w = re.match(r'#\s*ifdef\s+(\w+)$', s)
        if e:
            if e.group(1) not in DROP_EXTENSIONS_COMPUTE:
                out.append(lines[i])
            i += 1
        elif w and i + 2 < len(lines) and re.match(r'#\s*extension\s+%s\s*:' % w.group(1), lines[i + 1].strip()) \
                and re.match(r'#\s*endif\b', lines[i + 2].strip()):
            if w.group(1) not in DROP_EXTENSIONS_COMPUTE:
                out += lines[i:i + 3]
            i += 3
        elif not s:
            i += 1
        else:
            break
    if re.search(r'\bimageAtomic\w+\s*\(', code):
        out.append('#extension GL_OES_shader_image_atomic : require\n')
    out.append(precision_block(body, precision, images=True))
    rest = ''.join(lines[i:])
    if 'const-arrays' in optimize:
        rest, n = const_arrays(rest)
        if n and notes is not None: notes.append(f'COMPUTE const-arrays {n}')
    if 'unroll' in optimize:
        rest, n = unroll(rest)
        if n and notes is not None: notes.append(f'COMPUTE unroll {n}')
    out.append(rest)
    return ''.join(out)


def program_to_es(code, precision='highp', optimize=OPTIMIZE, notes=None, es='300'):
    """A whole GL program (every stage block) -> its GLSL ES 3.00 twin (es='310': 3.10, for
    programs that raise NeedsES31). Text outside the stage blocks (none in HLSLcc output) is kept.
    notes: a list that gets the rewrites applied."""
    blocks = stage_blocks(code)
    if not blocks:
        raise Unsupported('no stage blocks')
    out = []
    last = 0
    for stage, a, b in blocks:
        if stage not in ('VERTEX', 'FRAGMENT'):
            raise Unsupported(f'{stage} stage')
        out.append(code[last:a])
        out.append(stage_to_es(code[a:b], stage, precision, optimize, notes, es))
        last = b
    out.append(code[last:])
    return ''.join(out)


def stage_sources(code):
    """{stage: source} as Unity hands each stage to the driver (for compile checks)."""
    return {stage: code[a:b] for stage, a, b in stage_blocks(code)}
