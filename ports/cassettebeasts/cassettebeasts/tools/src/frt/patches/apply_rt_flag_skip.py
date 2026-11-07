#!/usr/bin/env python3
"""GLES3: no render target re-allocation for a flag that does not change (port patch, always on; after
apply_viewport_clamp.py).

RasterizerStorageGLES3::render_target_set_flag frees and re-allocates the render target (textures, FBOs) for every
HDR / 32-bit depth / NO_3D / NO_SAMPLING / NO_3D_EFFECTS call, changed or not (render_target_set_size already skips
equal sizes). Instancing a scene with Viewports sets these through Viewport::set_usage / set_hdr several times per
viewport: Cassette Beasts draws every NPC's layered sprite into a small Viewport, and the town's chunk scenes
(Overworld_1_0, Overworld_0_0) took 164-184 ms to instance on a PC, 83 % of it in _render_target_allocate (gdb
samples, tools/t56.sh); on the RG Cube XX up to 225 ms of walking hitch. Here a call whose effective value (after
the viewport clamp's forced HDR off / effects off) equals the current one returns at once.
usage: apply_rt_flag_skip.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'RT-FLAG-SKIP-PATCH'


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


OLD = '''	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND(!rt);

	rt->flags[p_flag] = p_value;

	switch (p_flag) {
		case RENDER_TARGET_HDR:'''
NEW = '''	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND(!rt);

	// RT-FLAG-SKIP-PATCH: nothing to re-allocate when the effective value stays the same
	bool effective = p_value;
	if (p_flag == RENDER_TARGET_HDR && viewport_clamp.no_hdr) {
		effective = false;
	}
	if (p_flag == RENDER_TARGET_NO_3D_EFFECTS && viewport_clamp.no_3d_effects) {
		effective = true;
	}
	if (rt->flags[p_flag] == effective) {
		return;
	}

	rt->flags[p_flag] = p_value;

	switch (p_flag) {
		case RENDER_TARGET_HDR:'''

edit('drivers/gles3/rasterizer_storage_gles3.cpp', lambda s: once(s, OLD, NEW))
