#!/usr/bin/env python3
"""Evict compiled GLES3 shader variants that were not bound for a while (port patch, needs apply_lazy.py,
apply_lazy_pressure.py and apply_memstats.py first). Godot 3 keeps every compiled ShaderGLES3 version (one
per material shader x conditional combination: lights, shadows, fog, skinning...) for the whole session;
heaptrack on Cassette Beasts' Overworld: ShaderGLES3::_complete_compile was the biggest owner (PC/llvmpipe:
249 MB; on Mali the driver keeps binaries and program state). A deleted variant is compiled again when it
is bound next time (a hitch, like the first use).
- rendering/lazy_shaders/evict_after_seconds (0 = off): delete variants not bound for N s.
- under lazy texture memory pressure: also delete variants not bound for 5 s.
- the lazy stats line gets the number of live variants.
usage: apply_shader_evict.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'SHADER-EVICT' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, old
    return s.replace(old, new)


def shader_h(s):
    s = once(s, '''		bool uniforms_ready;
		uint64_t last_frame_processed;
''', '''		bool uniforms_ready;
		uint64_t last_frame_processed;
		uint64_t lazy_last_used; // SHADER-EVICT: msec of the last bind
''')
    s = once(s, '''				last_frame_processed(UINT64_MAX),
				compile_status(COMPILE_STATUS_PENDING),''', '''				last_frame_processed(UINT64_MAX),
				lazy_last_used(0),
				compile_status(COMPILE_STATUS_PENDING),''')
    s = once(s, '''	static ShaderGLES3 *active;
''', '''	static ShaderGLES3 *active;
	// SHADER-EVICT: every ShaderGLES3
	static Vector<ShaderGLES3 *> lazy_all;
	int _lazy_evict(uint64_t p_max_age);
''')
    s = once(s, '''	void free_custom_shader(uint32_t p_code_id);
''', '''	void free_custom_shader(uint32_t p_code_id);
	// SHADER-EVICT: clock for the last-bind stamps (msec, set once per frame); delete variants of all
	// shaders not bound for p_max_age msec, returns the count
	static uint64_t lazy_now;
	static int lazy_evict(uint64_t p_now, uint64_t p_max_age);
	static int lazy_version_count();
''')
    return s


def shader_cpp(s):
    s = once(s, '''ShaderGLES3 *ShaderGLES3::active = nullptr;
''', '''ShaderGLES3 *ShaderGLES3::active = nullptr;
Vector<ShaderGLES3 *> ShaderGLES3::lazy_all; // SHADER-EVICT
uint64_t ShaderGLES3::lazy_now = 0;
''')
    # stamp on every bind, also when the same version stays bound
    s = once(s, '''	if (active == this && version) {
		if (new_conditional_version.code_version == conditional_version.code_version) {''', '''	if (active == this && version) {
		version->lazy_last_used = lazy_now; // SHADER-EVICT
		if (new_conditional_version.code_version == conditional_version.code_version) {''')
    s = once(s, '''	if (ready) {
		glUseProgram(version->ids.main);''', '''	if (ready) {
		version->lazy_last_used = lazy_now; // SHADER-EVICT
		glUseProgram(version->ids.main);''')
    s = once(s, '''ShaderGLES3::ShaderGLES3() {
	version = nullptr;''', '''// SHADER-EVICT
int ShaderGLES3::_lazy_evict(uint64_t p_max_age) {
	Vector<VersionKey> old;
	const VersionKey *K = nullptr;
	while ((K = version_map.next(K))) {
		Version &v = version_map[*K];
		if (v.compile_status != Version::COMPILE_STATUS_OK || v.compiling_list.in_list() || &v == version) {
			continue;
		}
		if (lazy_now - v.lazy_last_used > p_max_age) {
			old.push_back(*K);
		}
	}
	for (int i = 0; i < old.size(); i++) {
		Version &v = version_map[old[i]];
		_dispose_program(&v);
		memdelete_arr(v.uniform_location);
		if (old[i].code_version != 0) {
			CustomCode *cc = custom_code_map.getptr(old[i].code_version);
			if (cc) {
				cc->versions.erase(old[i].version);
			}
		}
		version_map.erase(old[i]);
	}
	return old.size();
}

int ShaderGLES3::lazy_evict(uint64_t p_now, uint64_t p_max_age) {
	lazy_now = p_now;
	int n = 0;
	for (int i = 0; i < lazy_all.size(); i++) {
		n += lazy_all[i]->_lazy_evict(p_max_age);
	}
	return n;
}

int ShaderGLES3::lazy_version_count() {
	int n = 0;
	for (int i = 0; i < lazy_all.size(); i++) {
		n += lazy_all[i]->version_map.size();
	}
	return n;
}

ShaderGLES3::ShaderGLES3() {
	lazy_all.push_back(this); // SHADER-EVICT
	version = nullptr;''')
    s = once(s, '''ShaderGLES3::~ShaderGLES3() {
	finish();''', '''ShaderGLES3::~ShaderGLES3() {
	lazy_all.erase(this); // SHADER-EVICT
	finish();''')
    return s


def storage_h(s):
    return once(s, '''		bool trim_on_pressure = true;
''', '''		bool trim_on_pressure = true;
		// SHADER-EVICT: compiled shader variants not bound for shader_evict_msec are deleted (0 = off)
		uint64_t shader_evict_msec = 0;
		int shader_evictions = 0;
''')


def storage_cpp(s):
    s = once(s, '''	lazy.now = OS::get_singleton()->get_ticks_msec();
''', '''	lazy.now = OS::get_singleton()->get_ticks_msec();
	ShaderGLES3::lazy_now = lazy.now; // SHADER-EVICT
''')
    s = once(s, '''			if (lazy.trim_on_pressure) {
				_lazy_malloc_trim(); // MEMSTATS
			}
''', '''			int ns = ShaderGLES3::lazy_evict(lazy.now, 5000); // SHADER-EVICT
			lazy.shader_evictions += ns;
			if (ns && lazy.print_stats) {
				fprintf(stderr, "Lazy shaders: pressure, deleted %d variants\\n", ns);
			}
			if (lazy.trim_on_pressure) {
				_lazy_malloc_trim(); // MEMSTATS
			}
''')
    s = once(s, '''	if (lazy.evict_msec && lazy.now - lazy.last_evict_check >= 1000) {
		lazy.last_evict_check = lazy.now;
''', '''	if (lazy.evict_msec && lazy.now - lazy.last_evict_check >= 1000) {
		lazy.last_evict_check = lazy.now;
		if (lazy.shader_evict_msec) {
			lazy.shader_evictions += ShaderGLES3::lazy_evict(lazy.now, lazy.shader_evict_msec); // SHADER-EVICT
		}
''')
    s = once(s, '''		_lazy_malloc_stats(); // MEMSTATS
''', '''		_lazy_malloc_stats(); // MEMSTATS
		fprintf(stderr, "Lazy shaders: %d variants, %d deleted\\n", ShaderGLES3::lazy_version_count(), lazy.shader_evictions); // SHADER-EVICT
''')
    s = once(s, '''	lazy.trim_on_pressure = GLOBAL_DEF("memory/malloc_trim_on_pressure", true);
''', '''	lazy.trim_on_pressure = GLOBAL_DEF("memory/malloc_trim_on_pressure", true);
	lazy.shader_evict_msec = uint64_t(MAX(0, int(GLOBAL_DEF("rendering/lazy_shaders/evict_after_seconds", 0)))) * 1000; // SHADER-EVICT
''')
    return s


edit('drivers/gles3/shader_gles3.h', shader_h)
edit('drivers/gles3/shader_gles3.cpp', shader_cpp)
edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
