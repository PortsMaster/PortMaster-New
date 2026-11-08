#!/usr/bin/env python3
"""GLES3: allocate a render target when it is first drawn, not on every size / flag change (port patch, always
on; after apply_rt_flag_skip.py and apply_render_scale.py).

render_target_set_size, render_target_set_flag (HDR, NO_3D, NO_SAMPLING, ...) and render_target_set_msaa each free
and re-create the render target's textures and FBOs. A Viewport coming out of PackedScene::instance() gets its size
and usage set one after the other, so it is allocated two or three times before it is ever drawn: Cassette Beasts'
town chunks (an NPC = a sprite Viewport) still spent 83 % of their 68-100 ms instancing on a PC in
_render_target_allocate after apply_rt_flag_skip.py (gdb samples, tools/t56.sh). Here those setters only free the
old buffers and mark the target; RasterizerGLES3::set_current_render_target (every viewport draw goes through it)
and render_target_get_scaled_3d_size (the render-scale / letterbox / viewport-cap companions) allocate a marked
target first. Until then the target's texture has no GL texture (a ViewportTexture shows nothing, as before the
viewport's first draw anyway); viewports that are never drawn never allocate.
usage: apply_rt_lazy_alloc.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'RT-LAZY-ALLOC-PATCH'


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


def once(s, old, new):
    assert s.count(old) == 1, (old[:70], s.count(old))
    return s.replace(old, new)


def header(s):
    s = once(s, '''	struct RenderTarget : public RID_Data {
		GLuint fbo;
		GLuint color;
		GLuint depth;
''', '''	struct RenderTarget : public RID_Data {
		GLuint fbo;
		GLuint color;
		GLuint depth;
		bool alloc_pending = false; // RT-LAZY-ALLOC-PATCH: buffers freed, allocated on the next draw
''')
    s = once(s, '''	void _render_target_allocate(RenderTarget *rt);
''', '''	void _render_target_allocate(RenderTarget *rt);
	void _render_target_ensure_allocated(RenderTarget *rt) { // RT-LAZY-ALLOC-PATCH
		if (rt->alloc_pending) {
			_render_target_allocate(rt);
		}
	}
''')
    return s


def source(s):
    s = once(s, '''void RasterizerStorageGLES3::_render_target_allocate(RenderTarget *rt) {
''', '''void RasterizerStorageGLES3::_render_target_allocate(RenderTarget *rt) {
	rt->alloc_pending = false; // RT-LAZY-ALLOC-PATCH
''')
    # size
    s = once(s, '''	_render_target_clear(rt);
	rt->width = p_width;
	rt->height = p_height;
	_render_target_allocate(rt);
}''', '''	_render_target_clear(rt);
	rt->width = p_width;
	rt->height = p_height;
	rt->alloc_pending = true; // RT-LAZY-ALLOC-PATCH: allocated on the next draw
}''')
    # flags
    s = once(s, '''			//must reset for these formats
			_render_target_clear(rt);
			_render_target_allocate(rt);
''', '''			//must reset for these formats
			_render_target_clear(rt);
			rt->alloc_pending = true; // RT-LAZY-ALLOC-PATCH: allocated on the next draw
''')
    # companions handed out for drawing must exist
    s = once(s, '''		render_target_set_size(rt->scaled_3d, w, h);
''', '''		render_target_set_size(rt->scaled_3d, w, h);
	}
	{
		RenderTarget *sc = render_target_owner.getornull(rt->scaled_3d); // RT-LAZY-ALLOC-PATCH
		if (sc) {
			_render_target_ensure_allocated(sc);
		}
		_render_target_ensure_allocated(rt);
''')
    return s


def rasterizer(s):
    return once(s, '''		RasterizerStorageGLES3::RenderTarget *rt = storage->render_target_owner.getornull(p_render_target);
		storage->frame.current_rt = rt;
		ERR_FAIL_COND(!rt);
''', '''		RasterizerStorageGLES3::RenderTarget *rt = storage->render_target_owner.getornull(p_render_target);
		storage->frame.current_rt = rt;
		ERR_FAIL_COND(!rt);
		storage->_render_target_ensure_allocated(rt); // RT-LAZY-ALLOC-PATCH
''')


edit('drivers/gles3/rasterizer_storage_gles3.h', header)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', source)
edit('drivers/gles3/rasterizer_gles3.cpp', rasterizer)
