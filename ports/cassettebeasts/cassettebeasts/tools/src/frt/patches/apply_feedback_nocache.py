#!/usr/bin/env python3
"""GLES3: no program binary cache for transform feedback shaders (port patch; was PowerVR-only as
apply_pvr_feedback_nocache.py until the Mali check below).

The real cause of the GPU particle crash on the TrimUI Smart Pro (PowerVR Rogue GE8300, driver 1.19.6345021):
a transform feedback program created from a program binary (glGetProgramBinary -> glProgramBinary, i.e. the
port's shader cache, apply_shader_cache_sync.py) crashes the driver on its first feedback draw (null read in
libGLESv2.so); the same program linked from source runs. Found with a standalone repeat of the
engine's particle update (2026-10-10): "godot" and "dyn" (through a binary) died on the first update twice,
"linked" ran 75 s, 180760 feedback draws, no GL error.
The RG Cube XX's Mali-G31 driver has the same flaw without crashing: a feedback program from a binary writes
nothing, so GPU particles (the grass) were invisible there since the shader cache went in (title screen on the
device, 2026-10-10: no grass with the cache, grass with shader_cache_sync=false).
On every renderer, shaders with feedback varyings (particles, blend shapes) are neither looked up in nor saved to
the shader cache: they always link from source (a compile per variant per session instead of a cache load; a
handful of shaders). env PORT_FEEDBACK_CACHE=1 keeps the cache for them (to re-test a driver).
Run after apply_pvr_particles.py (whose PowerVR default is "none" again since this fix).
usage: apply_feedback_nocache.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'FEEDBACK-NOCACHE-PATCH'


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


def shader(s):
    s = once(s, '''ShaderCacheGLES3 *ShaderGLES3::shader_cache;
''', '''ShaderCacheGLES3 *ShaderGLES3::shader_cache;

// FEEDBACK-NOCACHE-PATCH: transform feedback programs created from a program binary crash the PowerVR GE8300
// driver and write nothing on the Mali-G31: they always link from source (PORT_FEEDBACK_CACHE=1: cache them)
static bool port_feedback_nocache() {
	static int v = -1;
	if (v < 0) {
		v = OS::get_singleton()->get_environment("PORT_FEEDBACK_CACHE") != "1" ? 1 : 0;
		if (v) {
			print_line("transform feedback shaders not cached");
		}
	}
	return v == 1;
}
''')
    old_save = 'bool must_save_to_cache = p_version->version_key.is_subject_to_caching() && p_version->program_binary.source != Version::ProgramBinary::SOURCE_CACHE && shader_cache;'
    new_save = 'bool must_save_to_cache = p_version->version_key.is_subject_to_caching() && p_version->program_binary.source != Version::ProgramBinary::SOURCE_CACHE && shader_cache && !(p_version->shader->feedback_count && port_feedback_nocache());'
    assert s.count(old_save) == 2, s.count(old_save)
    s = s.replace(old_save, new_save)
    s = once(s, '''	if (shader_cache && effective_version.is_subject_to_caching()) {
''', '''	if (shader_cache && effective_version.is_subject_to_caching() && !(feedback_count && port_feedback_nocache())) {
''')
    return s


edit('drivers/gles3/shader_gles3.cpp', shader)
