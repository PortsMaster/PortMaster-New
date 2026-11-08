#!/usr/bin/env python3
"""Program binary cache without asynchronous compilation (port patch): rendering/gles3/shaders/shader_cache_sync.

Godot 3.5's GLES3 renderer can keep linked shader programs on disk (ShaderCacheGLES3, glGetProgramBinary /
glProgramBinary), but only together with asynchronous compilation (shader_compilation_mode 2), which needs
GL_KHR_parallel_shader_compile or a second GL context; frt offers neither, so the cache stays off and every
shader variant is compiled again in every session: a stall the first time each material is seen (walking into
a new area, a new monster in battle; tens to hundreds of ms on the handhelds' Mali GPUs).
The synchronous compile path of ShaderGLES3 already handles cached programs (COMPILE_STATUS_BINARY_READY_FROM_CACHE
-> glProgramBinary, a rejected binary is removed and compiled again) and saving freshly linked ones (the
retrievable hint, _complete_link with the binary out, stored on the cache's writer thread); this only creates the
cache and its write queue when the setting is true and asynchronous compilation is not in effect, and lets every
program version be cached (upstream caches only the ubershader versions, which the synchronous path never uses;
the cache key is a hash of the full sources plus GL vendor, renderer and version, so any version is safe). Folder:
OS::get_cache_path()/godot/shaders (XDG_CACHE_HOME), size cap shader_cache_size_mb (the engine's own setting).

usage: apply_shader_cache_sync.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'SHADER-CACHE-SYNC-PATCH'


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


OLD = '''	ShaderGLES3::compile_queue = shaders.compile_queue;
	ShaderGLES3::parallel_compile_supported = config.parallel_shader_compile_supported;
'''
NEW = '''	// SHADER-CACHE-SYNC-PATCH: rendering/gles3/shaders/shader_cache_sync: the program binary cache with synchronous
	// compilation (the async modes need a second GL context or parallel compile, which frt does not have)
	if (!shaders.cache && !effectively_on && config.program_binary_supported && !Engine::get_singleton()->is_editor_hint() && bool(GLOBAL_DEF("rendering/gles3/shaders/shader_cache_sync", false))) {
		print_line("Shader cache: ON (synchronous compilation)");
		ShaderGLES3::cache_all_versions = true;
		shaders.cache = memnew(ShaderCacheGLES3);
		shaders.cache_write_queue = memnew(ThreadedCallableQueue<GLuint>());
	}
	ShaderGLES3::compile_queue = shaders.compile_queue;
	ShaderGLES3::parallel_compile_supported = config.parallel_shader_compile_supported;
'''

H_OLD1 = '_FORCE_INLINE_ bool is_subject_to_caching() const { return (version & UBERSHADER_FLAG); }'
H_NEW1 = '_FORCE_INLINE_ bool is_subject_to_caching() const { return (version & UBERSHADER_FLAG) || cache_all_versions; } // SHADER-CACHE-SYNC-PATCH'
H_OLD2 = '''	static ShaderCacheGLES3 *shader_cache;
'''
H_NEW2 = '''	static ShaderCacheGLES3 *shader_cache;
	static bool cache_all_versions; // SHADER-CACHE-SYNC-PATCH
'''
C_OLD = '''ShaderCacheGLES3 *ShaderGLES3::shader_cache;
'''
C_NEW = '''ShaderCacheGLES3 *ShaderGLES3::shader_cache;
bool ShaderGLES3::cache_all_versions = false; // SHADER-CACHE-SYNC-PATCH
'''

edit('drivers/gles3/rasterizer_storage_gles3.cpp', lambda s: once(s, OLD, NEW))
edit('drivers/gles3/shader_gles3.h', lambda s: once(once(s, H_OLD1, H_NEW1), H_OLD2, H_NEW2))
edit('drivers/gles3/shader_gles3.cpp', lambda s: once(s, C_OLD, C_NEW))
