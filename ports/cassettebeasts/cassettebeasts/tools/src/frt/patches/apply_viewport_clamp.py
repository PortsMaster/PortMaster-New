#!/usr/bin/env python3
"""Clamp the render targets games create (port patch). Godot 3's Viewport defaults to HDR and USAGE_3D
(colour, depth, effect buffers with mipmaps; GLES3 render targets even start with HDR set), and
rendering/quality/intended_usage/framebuffer_allocation only covers the root viewport. Cassette Beasts has
viewports up to 2000x1280 (archangel battles), many with the defaults.
- rendering/viewports/force_no_hdr: RGBA8 instead of RGBA16F colour buffers
- rendering/viewports/force_no_3d_effects: no effect buffers / mipmap chains (glow, SSR, DOF, SSAO off)
- rendering/viewports/force_no_msaa: no multisample buffers
Applied when a render target is (re)allocated, so they also cover the root viewport.
usage: apply_viewport_clamp.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'VIEWPORT-CLAMP' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, old
    return s.replace(old, new)


def storage_h(s):
    return once(s, '''	mutable RID_Owner<Texture> texture_owner;
''', '''	mutable RID_Owner<Texture> texture_owner;

	// VIEWPORT-CLAMP: rendering/viewports/force_* (render targets games create)
	struct ViewportClamp {
		bool no_hdr = false;
		bool no_3d_effects = false;
		bool no_msaa = false;
	} viewport_clamp;
''')


def storage_cpp(s):
    s = once(s, '''void RasterizerStorageGLES3::_render_target_allocate(RenderTarget *rt) {
''', '''void RasterizerStorageGLES3::_render_target_allocate(RenderTarget *rt) {
	// VIEWPORT-CLAMP
	if (viewport_clamp.no_hdr) {
		rt->flags[RENDER_TARGET_HDR] = false;
	}
	if (viewport_clamp.no_3d_effects) {
		rt->flags[RENDER_TARGET_NO_3D_EFFECTS] = true;
	}
	if (viewport_clamp.no_msaa) {
		rt->msaa = VS::VIEWPORT_MSAA_DISABLED;
	}
''')
    s = once(s, '''void RasterizerStorageGLES3::initialize() {
''', '''void RasterizerStorageGLES3::initialize() {
	viewport_clamp.no_hdr = GLOBAL_DEF("rendering/viewports/force_no_hdr", false); // VIEWPORT-CLAMP
	viewport_clamp.no_3d_effects = GLOBAL_DEF("rendering/viewports/force_no_3d_effects", false);
	viewport_clamp.no_msaa = GLOBAL_DEF("rendering/viewports/force_no_msaa", false);
''')
    return s


edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
