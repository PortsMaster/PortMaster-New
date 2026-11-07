#!/usr/bin/env python3
"""Memory-pressure eviction for lazy textures (port patch, needs apply_lazy.py first): with
rendering/lazy_textures/low_memory_mb > 0 the renderer reads MemAvailable (/proc/meminfo) every 250 ms and,
below that many MB, frees every lazy texture not drawn in the last second at once instead of after
evict_after_seconds. Scene changes (overworld -> battle) otherwise hold the old scene's textures for the
whole eviction time while the new ones upload: the kernel OOM killer ended a 1 GB handheld there.
usage: apply_lazy_pressure.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'LAZY-PRESSURE' in s:
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
    return once(s, '''		int failed = 0;
''', '''		int failed = 0;
		// LAZY-PRESSURE: evict early when MemAvailable is below low_memory_kb (0 = off)
		int64_t low_memory_kb = 0;
		uint64_t last_pressure_check = 0;
		int pressure_evictions = 0;
''')


def storage_cpp(s):
    s = once(s, '''// Once per frame: clock for texture_lazy_touch, eviction of textures not drawn for evict_msec.
void RasterizerStorageGLES3::_texture_lazy_update() {''', '''// LAZY-PRESSURE: MemAvailable in kB, -1 if unknown
static int64_t _lazy_mem_available_kb() {
	int64_t kb = -1;
#ifdef __linux__
	FILE *f = fopen("/proc/meminfo", "r");
	if (f) {
		char line[128];
		while (fgets(line, sizeof(line), f)) {
			long long v;
			if (sscanf(line, "MemAvailable: %lld kB", &v) == 1) {
				kb = v;
				break;
			}
		}
		fclose(f);
	}
#endif
	return kb;
}

// Once per frame: clock for texture_lazy_touch, eviction of textures not drawn for evict_msec.
void RasterizerStorageGLES3::_texture_lazy_update() {''')
    s = once(s, '''	lazy.now = OS::get_singleton()->get_ticks_msec();
''', '''	lazy.now = OS::get_singleton()->get_ticks_msec();
	// LAZY-PRESSURE: little memory left: free every texture not drawn in the last second now
	if (lazy.low_memory_kb && lazy.now - lazy.last_pressure_check >= 250) {
		lazy.last_pressure_check = lazy.now;
		int64_t avail = _lazy_mem_available_kb();
		if (avail >= 0 && avail < lazy.low_memory_kb) {
			int n = 0;
			uint64_t mem = info.texture_mem;
			Set<RID>::Element *E = lazy.resident.front();
			while (E) {
				Set<RID>::Element *N = E->next();
				Texture *t = texture_owner.getornull(E->get());
				if (t && !t->lazy_pending && lazy.now - t->lazy_last_used > 1000) {
					_texture_lazy_drop(t);
					n++;
				}
				E = N;
			}
			lazy.pressure_evictions += n;
			if (n && lazy.print_stats) {
				fprintf(stderr, "Lazy textures: %d MB available, evicted %d (%d MB)\\n", int(avail >> 10), n, int((mem - info.texture_mem) >> 20));
			}
		}
	}
''')
    s = once(s, '''	lazy.print_stats = GLOBAL_DEF("rendering/lazy_textures/print_stats", false);
''', '''	lazy.print_stats = GLOBAL_DEF("rendering/lazy_textures/print_stats", false);
	lazy.low_memory_kb = int64_t(MAX(0, int(GLOBAL_DEF("rendering/lazy_textures/low_memory_mb", 0)))) * 1024; // LAZY-PRESSURE
''')
    return s


edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
