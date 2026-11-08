#!/usr/bin/env python3
"""GLES3: buffers created with defined (zero) contents on PowerVR GPUs (port patch; renderer name contains "PowerVR").

The GLES3 renderer sizes several buffers with glBufferData(..., nullptr) and writes them later, partly or only for
some frames: the omni/spot/directional light and reflection probe UBOs, a material's UBO before its parameters,
multimesh data, the immediate-geometry vertex buffer. Reading a part that was never written is undefined: Mali
drivers hand out zeroed memory (harmless), the PowerVR GE8300 driver (TrimUI Smart Pro) old memory: 3D materials in
random colours that changed from run to run, water waves gone wild (2026-10-09). Here those allocations pass a
zeroed block instead of nullptr on PowerVR (same size and usage; once per allocation, not per frame); other GPUs
are unchanged.
usage: apply_zero_buffers.py <godot dir>   (idempotent)
"""
import os, re, sys

G = sys.argv[1]
MARK = 'ZERO-BUFFERS-PATCH'
HELPER = '''
// ZERO-BUFFERS-PATCH: on PowerVR, glBufferData with zeroed contents instead of undefined ones
// (apply_zero_buffers.py); other GPUs keep the engine's nullptr allocation
static inline void port_buffer_data_zero(GLenum p_target, GLsizeiptr p_size, GLenum p_usage) {
	static int powervr = -1;
	if (powervr < 0) {
		const char *r = (const char *)glGetString(GL_RENDERER);
		powervr = (r && strstr(r, "PowerVR")) ? 1 : 0;
	}
	void *zero = (powervr && p_size > 0) ? calloc(1, p_size) : nullptr;
	glBufferData(p_target, p_size, zero, p_usage);
	if (zero) {
		free(zero);
	}
}
'''


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if MARK in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def header(s):
    # after the includes of the storage header (included by the scene and canvas renderers)
    i = s.index('class RasterizerCanvasGLES3;')
    return s[:i] + HELPER + '\n' + s[i:]


PAT = re.compile(r'glBufferData\((GL_UNIFORM_BUFFER|GL_ARRAY_BUFFER), ([^;]*?), nullptr, (GL_[A-Z_]+)\);')


def calls(s):
    n = 0

    def sub(m):
        nonlocal n
        n += 1
        return 'port_buffer_data_zero(%s, %s, %s);' % (m.group(1), m.group(2), m.group(3))
    out = PAT.sub(sub, s)
    print('  %d allocations' % n)
    return out.replace('#include "rasterizer_scene_gles3.h"', '#include "rasterizer_scene_gles3.h" // ' + MARK, 1) \
        if '#include "rasterizer_scene_gles3.h"' in out else out + '\n// ' + MARK + '\n'


edit('drivers/gles3/rasterizer_storage_gles3.h', lambda s: header(s).replace('#define RASTERIZERSTORAGEGLES3_H', '#define RASTERIZERSTORAGEGLES3_H // ' + MARK, 1))
edit('drivers/gles3/rasterizer_scene_gles3.cpp', calls)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', calls)
