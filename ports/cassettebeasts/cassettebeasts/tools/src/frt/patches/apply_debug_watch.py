#!/usr/bin/env python3
"""Debug output for memory spikes (port patch, needs apply_shader_evict.py first; only with
rendering/lazy_textures/print_stats): "Shaders: N compiled" for every second in which shader variants
were compiled, and glibc heap numbers once a second while MemAvailable is below low_memory_mb.
usage: apply_debug_watch.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'DEBUG-WATCH' in s:
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
    return once(s, '''	static uint64_t lazy_now;
''', '''	static uint64_t lazy_now;
	static int lazy_compiles; // DEBUG-WATCH: variants created since the last report
''')


def shader_cpp(s):
    s = once(s, '''uint64_t ShaderGLES3::lazy_now = 0;
''', '''uint64_t ShaderGLES3::lazy_now = 0;
int ShaderGLES3::lazy_compiles = 0; // DEBUG-WATCH
''')
    return once(s, '''	if (!_v) {
		_v = &version_map[effective_version];''', '''	if (!_v) {
		lazy_compiles++; // DEBUG-WATCH
		_v = &version_map[effective_version];''')


def storage_h(s):
    return once(s, '''		int shader_evictions = 0;
''', '''		int shader_evictions = 0;
		uint64_t last_watch = 0; // DEBUG-WATCH
		uint64_t last_heap_print = 0;
''')


def storage_cpp(s):
    s = once(s, '''		if (avail >= 0 && avail < lazy.low_memory_kb) {
''', '''		if (avail >= 0 && avail < lazy.low_memory_kb) {
			if (lazy.print_stats && lazy.now - lazy.last_heap_print >= 1000) { // DEBUG-WATCH
				lazy.last_heap_print = lazy.now;
				fprintf(stderr, "Low memory: %d MB available, texture memory %d MB, ", int(avail >> 10), int(info.texture_mem >> 20));
				_lazy_malloc_stats();
			}
''')
    return once(s, '''	if (lazy.print_stats && lazy.now - lazy.last_stats >= 10000) {''', '''	if (lazy.print_stats && lazy.now - lazy.last_watch >= 1000) { // DEBUG-WATCH
		lazy.last_watch = lazy.now;
		if (ShaderGLES3::lazy_compiles) {
			fprintf(stderr, "Shaders: %d compiled at %.1f s\\n", ShaderGLES3::lazy_compiles, lazy.now / 1000.0);
			ShaderGLES3::lazy_compiles = 0;
		}
	}
	if (lazy.print_stats && lazy.now - lazy.last_stats >= 10000) {''')


edit('drivers/gles3/shader_gles3.h', shader_h)
edit('drivers/gles3/shader_gles3.cpp', shader_cpp)
edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
