#!/usr/bin/env python3
"""Godot 3.5 GLES3 port patch: do not allocate the cubemap ladders a project cannot use.

RasterizerSceneGLES3::initialize() always builds two cubemap ladders:
- five reflection cubemaps 512..32, RGBA16F colour + D24 depth (~17 MB), only ever rendered to through a
  reflection atlas, and reflection_probe_instance_begin_render() rejects an atlas whose size is 0;
- the omni shadow cubemaps cubemap_size..32 D24 (default 512, ~8 MB), only ever rendered to through a shadow
  atlas, and shadow_atlas_update_light() rejects an atlas whose size is 0.
With rendering/quality/reflections/atlas_size = 0 and rendering/quality/shadow_atlas/size = 0 (our override.cfg)
both ladders are dead weight on a 1 GB handheld whose GPU memory is main RAM. When the respective atlas size is 0
only the smallest (32) cubemap is allocated, so reflection_cubemaps / shadow_cubemaps stay non-empty and the
index math (cubemap_index loops) stays valid. Atlas sizes > 0: unchanged.
reflections/atlas_size is GLOBAL_DEF_RST'd in scene/main/scene_tree.cpp, which runs after the rasterizer
initialises, so the same GLOBAL_DEF_RST (same default) is used here; shadow_atlas/size is GLOBAL_DEF_RST'd in
the VisualServer constructor (servers/visual_server.cpp), which has run by then, so GLOBAL_GET is enough.

usage: apply_init_buffers.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "INIT-BUFFERS-PATCH"


def once(s, old, new):
    assert s.count(old) == 1, (s.count(old), old[:70])
    return s.replace(old, new)


p = godot / "drivers/gles3/rasterizer_scene_gles3.cpp"
s = p.read_text()
if MARK not in s:
    # omni shadow cubemap ladder
    s = once(s, """	int max_shadow_cubemap_sampler_size = MIN(int(GLOBAL_GET("rendering/quality/shadow_atlas/cubemap_size")), storage->config.max_cubemap_texture_size);
""", """	int max_shadow_cubemap_sampler_size = MIN(int(GLOBAL_GET("rendering/quality/shadow_atlas/cubemap_size")), storage->config.max_cubemap_texture_size);
	// %s: with rendering/quality/shadow_atlas/size 0 no omni shadow is ever rendered through this ladder
	// (shadow_atlas_update_light rejects a size-0 atlas): keep only the 32 cubemap the index math needs.
	if (int(GLOBAL_GET("rendering/quality/shadow_atlas/size")) <= 0) {
		max_shadow_cubemap_sampler_size = 32;
	}
""" % MARK)

    # reflection cubemap ladder
    s = once(s, """		int max_reflection_cubemap_sampler_size = 512;
""", """		int max_reflection_cubemap_sampler_size = 512;
		// %s: with rendering/quality/reflections/atlas_size 0 no reflection probe is ever rendered through
		// this ladder (reflection_probe_instance_begin_render rejects a size-0 atlas): keep only the 32 cubemap
		// the index math needs. Same macro and default as scene/main/scene_tree.cpp, which runs later.
		if (int(GLOBAL_DEF_RST("rendering/quality/reflections/atlas_size", 2048)) <= 0) {
			max_reflection_cubemap_sampler_size = 32;
		}
""" % MARK)
    p.write_text(s, newline="\n")
    print("patched:", p)
else:
    print("already patched:", p)
print("done")
