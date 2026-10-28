"""GLES 3.1 kernels for ComputeShader assets that only carry OpenGL Core (and Vulkan, Metal, ...) ones.

A ComputeShader keeps one variant per graphics renderer (`variants`: `targetRenderer`, the
GfxDeviceRenderer; `targetLevel`; the kernels; the constant buffer layouts). A desktop build has
OpenGL Core kernels (renderer 17, GLSL 4.20 / 4.30 compute shaders written by HLSLcc), Vulkan's
(21, SPIR-V), Direct3D's or Metal's; Unity's Android player on GLES3 looks for the OpenGL ES 3
variant (renderer 11), and without one every FindKernel fails ("Kernel 'X' not found"), so a game
that dispatches its own kernels (particle and swarm simulations, GPU culling) draws nothing of
them or stops in an exception every frame.

add_gles3() gives such a ComputeShader the variant an Android build would have: a copy of the
GLCore variant with renderer 11 and the GLES level, every kernel's code translated to GLSL ES 3.10
(glsl.kernel_to_es). Everything else is the GLCore variant's: kernel names, keywords, constant
buffers, the textures, buffers and samplers with their bind points, thread group sizes,
requirements. That is what Unity's own builds hold: in the built-in resources of Linux and macOS
players of 2017.4 - 6000.5 (Internal-Skinning, Internal-BlendShape, ...), which carry both
renderers, the GLES3 variant equals the GLCore one but for the renderer, the level and the code.

The kernel code is where the layouts differ:

  * up to 2019.4 each kernel has its `code` (one variant per kernel);
  * 2020.1 - 2021.1: a kernel's `variantMap`, (keywords, kernel variant) pairs, each with `code`;
  * 2021.2+: a kernel's `uniqueVariants`, each with `code` (`variantIndices` maps keyword sets
    to them).

The GLES level is 3 up to 2022.3 and 2 from 2023.1 (the GLCore levels differ by version too: 8,
10, 11, 12; Unity's built-in resources of each line give the GLES level).

A kernel that does not translate (GLSL that ES 3.10 lacks, a write-only image whose format is
not known or not in ES) is left out of the GLES3 variant, with the others kept: FindKernel then
fails for that one only, as it did for all before. Write-only images: HLSLcc leaves their format
out in GLSL for desktop GL, which ES needs; the format comes from the Vulkan variant's SPIR-V of
the same kernel (HLSLcc chose it from the HLSL type there: float4 -> rgba32f, float -> r32f, ...,
as it does for GLES).
"""
import copy
import struct

from . import glsl

RENDERER_GLES3, RENDERER_GLCORE, RENDERER_VULKAN = 11, 17, 21


def _major_minor(unity):
    try:
        a, b = str(unity).split('.')[:2]
        return int(a), int(b)
    except (TypeError, ValueError):
        return 0, 0


def gles_level(unity=None):
    """The targetLevel Unity gives GLES3 compute variants: 3 up to 2022.3, 2 from 2023.1."""
    return 2 if _major_minor(unity) >= (2023, 1) else 3


def kernel_variants(kernel):
    """The dicts holding a kernel's code, in their list order (see the module docstring)."""
    if 'code' in kernel:
        return [kernel]
    if kernel.get('variantMap') is not None:
        return [kv for _, kv in kernel['variantMap']]
    if kernel.get('uniqueVariants') is not None:
        return list(kernel['uniqueVariants'])
    raise ValueError(f'kernel {kernel.get("name")!r}: unknown layout (keys {sorted(kernel)})')


def _code(kv):
    c = kv['code']
    return bytes(c) if not isinstance(c, (bytes, bytearray)) else bytes(c)


def _set_code(kv, data, like):
    kv['code'] = data if isinstance(like, (bytes, bytearray)) else list(data)


# ---- SPIR-V: the format of each image a Vulkan kernel declares
_SPV_FORMATS = {1: 'rgba32f', 2: 'rgba16f', 3: 'r32f', 4: 'rgba8', 5: 'rgba8_snorm', 6: 'rg32f', 7: 'rg16f',
                8: 'r11f_g11f_b10f', 9: 'r16f', 10: 'rgba16', 11: 'rgb10_a2', 12: 'rg16', 13: 'rg8', 14: 'r16',
                15: 'r8', 16: 'rgba16_snorm', 17: 'rg16_snorm', 18: 'rg8_snorm', 19: 'r16_snorm', 20: 'r8_snorm',
                21: 'rgba32i', 22: 'rgba16i', 23: 'rgba8i', 24: 'r32i', 25: 'rg32i', 26: 'rg16i', 27: 'rg8i',
                28: 'r16i', 29: 'r8i', 30: 'rgba32ui', 31: 'rgba16ui', 32: 'rgba8ui', 33: 'r32ui', 34: 'rgb10_a2ui',
                35: 'rg32ui', 36: 'rg16ui', 37: 'rg8ui', 38: 'r16ui', 39: 'r8ui'}


def spirv_image_formats(code):
    """{variable name: format} of the image variables in a SPIR-V module (formats given, not
    Unknown). Names as the module has them (Unity's: '<name>_origX0X')."""
    if len(code) < 20 or struct.unpack_from('<I', code)[0] != 0x07230203:
        return {}
    w = struct.unpack_from('<%dI' % (len(code) // 4), code)
    names, images, pointers, out = {}, {}, {}, {}
    variables = []
    i = 5
    while i < len(w):
        op, n = w[i] & 0xffff, w[i] >> 16
        if n == 0:
            break
        a = w[i + 1:i + n]
        if op == 5 and len(a) >= 2:                                   # OpName
            names[a[0]] = struct.pack('<%dI' % (len(a) - 1), *a[1:]).split(b'\0')[0].decode('utf-8', 'replace')
        elif op == 25 and len(a) >= 8:                                # OpTypeImage
            images[a[0]] = a[7]
        elif op == 32 and len(a) >= 3:                                # OpTypePointer
            pointers[a[0]] = a[2]
        elif op == 59 and len(a) >= 3:                                # OpVariable
            variables.append((a[1], a[0]))
        i += n
    for vid, tid in variables:
        fmt = images.get(pointers.get(tid))
        if fmt and vid in names:
            out[names[vid]] = _SPV_FORMATS.get(fmt, f'spirv-format-{fmt}')
    return out


def variant_keywords(kernel):
    """For each of kernel_variants(kernel): the keyword sets (strings) that select it."""
    if 'code' in kernel:
        return [{''}]
    if kernel.get('variantMap') is not None:
        return [{kw} for kw, _ in kernel['variantMap']]
    out = [set() for _ in kernel['uniqueVariants']]
    for kw, i in kernel.get('variantIndices') or []:
        if 0 <= i < len(out):
            out[i].add(kw)
    return out


def _vulkan_formats(vk_kernel, keywords, index):
    """Image formats of the Vulkan kernel's variant of the same keywords (else at the same index),
    by GLSL name ('_origX0X' dropped)."""
    if vk_kernel is None:
        return {}
    vs = kernel_variants(vk_kernel)
    vkw = variant_keywords(vk_kernel)
    match = next((i for i, kws in enumerate(vkw) if kws & keywords), index if index < len(vs) else None)
    if match is None:
        return {}
    out = {}
    for k, v in spirv_image_formats(_code(vs[match])).items():
        out[k[:-len('_origX0X')] if k.endswith('_origX0X') else k] = v
    return out


class Result:
    def __init__(self, name):
        self.name = name
        self.status = 'unchanged'       # converted | unchanged | skipped
        self.why = ''
        self.kernels = 0                # kernels in the GLES3 variant
        self.variants = 0               # kernel variants (codes) translated
        self.failed = []                # (kernel name, why) left out
        self.notes = []

    def __repr__(self):
        return f'{self.name}: {self.status} {self.why}'.rstrip()


def add_gles3(tree, unity=None, precision='highp', replace=False, optimize=glsl.OPTIMIZE, translate=None):
    """Adds a GLES3 variant to one ComputeShader typetree in place. Returns a Result.
    unity: the data's version string (for the GLES level). replace: rebuild a GLES3 variant the
    shader already has from its GLCore one. translate: function(code str, image formats) -> str,
    default glsl.kernel_to_es."""
    r = Result(tree.get('m_Name', '?'))
    variants = tree['variants']
    # a renderer can have several variants, by level (2018.x: GLCore level 10 with the kernels and
    # an empty level 8 one): the one with kernels, of the highest level
    gls = sorted((v for v in variants if v['targetRenderer'] == RENDERER_GLCORE),
                 key=lambda v: (bool(v['kernels']), v['targetLevel']), reverse=True)
    gl = gls[0] if gls else None
    if gl is None:
        r.why = 'no OpenGL Core kernels'
        return r
    old = [v for v in variants if v['targetRenderer'] == RENDERER_GLES3]
    if old:
        if not replace:
            r.why = 'already has GLES3 kernels'
            return r
        for v in old:
            variants.remove(v)
        r.status, r.why = 'converted', '(old GLES3 kernels removed)'
    vk = next((v for v in sorted((v for v in variants if v['targetRenderer'] == RENDERER_VULKAN),
                                 key=lambda v: (bool(v['kernels']), v['targetLevel']), reverse=True)), None)
    vk_kernels = {}
    if vk is not None:
        for k in vk['kernels']:
            vk_kernels.setdefault(k['name'], []).append(k)
    tr = translate or (lambda code, formats: glsl.kernel_to_es(code, precision, formats, optimize, r.notes))
    es = copy.deepcopy(gl)
    es['targetRenderer'] = RENDERER_GLES3
    es['targetLevel'] = gles_level(unity)
    kept = []
    seen = {}
    for k in es['kernels']:
        # the Vulkan kernel of the same name (and, for repeated names, the same position)
        nth = seen.get(k['name'], 0)
        seen[k['name']] = nth + 1
        same = vk_kernels.get(k['name'], [])
        vkk = same[nth] if nth < len(same) else None
        try:
            done = []
            kws = variant_keywords(k)
            for vi, kv in enumerate(kernel_variants(k)):
                code = _code(kv)
                text = code.rstrip(b'\0').decode('utf-8')
                formats = None
                if glsl.image_names(text):
                    formats = _vulkan_formats(vkk, kws[vi], vi)
                out = tr(text, formats).encode('utf-8') + (b'\0' if code.endswith(b'\0') else b'')
                done.append((kv, out, kv['code']))
        except (glsl.Unsupported, UnicodeDecodeError) as ex:
            r.failed.append((k['name'], str(ex)))
            continue
        for kv, out, like in done:
            _set_code(kv, out, like)
        r.variants += len(done)
        kept.append(k)
    if not kept:
        if r.status != 'converted':
            r.status = 'skipped' if r.failed else 'unchanged'
        r.why = ('no kernel translates: ' + '; '.join(f'{n}: {w}' for n, w in r.failed[:3]) if r.failed else
                 'no OpenGL Core kernels') + (' ' + r.why if r.why else '')
        return r
    es['kernels'] = kept
    r.kernels = len(kept)
    # where Unity puts it: up to 2021.x right after the GLCore variant (2, 18, 21, 17, 11, 4), from
    # 2022.1 in renderer order (2, 11, 17, 18, 21)
    if _major_minor(unity) >= (2022, 1):
        at = next((i for i, v in enumerate(variants) if v['targetRenderer'] > RENDERER_GLES3), len(variants))
    else:
        at = variants.index(gl) + 1
    variants.insert(at, es)
    r.status = 'converted'
    if r.failed:
        r.why = (f'{len(r.failed)} of {len(r.failed) + len(kept)} kernels left out: ' +
                 '; '.join(f'{n}: {w}' for n, w in r.failed[:3]) + ' ' + r.why).strip()
    return r
