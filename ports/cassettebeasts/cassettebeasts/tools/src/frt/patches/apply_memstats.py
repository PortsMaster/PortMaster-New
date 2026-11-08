#!/usr/bin/env python3
"""malloc statistics and trimming (port patch, needs apply_lazy.py + apply_lazy_pressure.py first):
- with rendering/lazy_textures/print_stats the 10 s stats line is followed by glibc's heap numbers
  (mallinfo2, looked up at run time: the build sysroot's glibc 2.31 lacks it): heap size, in use, free.
- memory/malloc_trim_seconds (0 = off): malloc_trim(0) every N s, gives free heap pages back to the system.
- memory/malloc_trim_on_pressure (true): malloc_trim(0) when the lazy texture pressure check fires.
Loading frees a lot of temporary memory on threads; glibc keeps it in the arenas, where the kernel counts
it as used (RssAnon) and the OOM killer sees it.
usage: apply_memstats.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'MEMSTATS' in s:
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
    return once(s, '''		int pressure_evictions = 0;
''', '''		int pressure_evictions = 0;
		// MEMSTATS: malloc_trim every trim_msec (0 = off) and on pressure
		uint64_t trim_msec = 0;
		uint64_t last_trim = 0;
		bool trim_on_pressure = true;
''')


def storage_cpp(s):
    s = once(s, '''// LAZY-PRESSURE: MemAvailable in kB, -1 if unknown
''', '''// MEMSTATS: glibc heap numbers and trimming (glibc only)
#if defined(__linux__) && defined(__GLIBC__)
#include <dlfcn.h>
#include <malloc.h>
struct _LazyMallinfo2 {
	size_t arena, ordblks, smblks, hblks, hblkhd, usmblks, fsmblks, uordblks, fordblks, keepcost;
};
static void _lazy_malloc_stats() {
	typedef _LazyMallinfo2 (*Fn)();
	static Fn fn = (Fn)dlsym(RTLD_DEFAULT, "mallinfo2");
	if (!fn) {
		return;
	}
	_LazyMallinfo2 m = fn();
	fprintf(stderr, "malloc: heap %d MB (in use %d MB, free %d MB, top %d MB), mmapped %d MB\\n", int(m.arena >> 20),
			int(m.uordblks >> 20), int(m.fordblks >> 20), int(m.keepcost >> 20), int(m.hblkhd >> 20));
}
static void _lazy_malloc_trim() {
	malloc_trim(0);
}
#else
static void _lazy_malloc_stats() {}
static void _lazy_malloc_trim() {}
#endif

// LAZY-PRESSURE: MemAvailable in kB, -1 if unknown
''')
    s = once(s, '''			lazy.pressure_evictions += n;
''', '''			lazy.pressure_evictions += n;
			if (lazy.trim_on_pressure) {
				_lazy_malloc_trim(); // MEMSTATS
			}
''')
    s = once(s, '''				lazy.resident.size(), int(info.texture_mem >> 20), lazy.uploads, lazy.evictions, lazy.failed);
''', '''				lazy.resident.size(), int(info.texture_mem >> 20), lazy.uploads, lazy.evictions, lazy.failed);
		_lazy_malloc_stats(); // MEMSTATS
''')
    s = once(s, '''	if (lazy.print_stats && lazy.now - lazy.last_stats >= 10000) {''', '''	if (lazy.trim_msec && lazy.now - lazy.last_trim >= lazy.trim_msec) { // MEMSTATS
		lazy.last_trim = lazy.now;
		_lazy_malloc_trim();
	}
	if (lazy.print_stats && lazy.now - lazy.last_stats >= 10000) {''')
    s = once(s, '''	lazy.low_memory_kb = int64_t(MAX(0, int(GLOBAL_DEF("rendering/lazy_textures/low_memory_mb", 0)))) * 1024; // LAZY-PRESSURE
''', '''	lazy.low_memory_kb = int64_t(MAX(0, int(GLOBAL_DEF("rendering/lazy_textures/low_memory_mb", 0)))) * 1024; // LAZY-PRESSURE
	lazy.trim_msec = uint64_t(MAX(0, int(GLOBAL_DEF("memory/malloc_trim_seconds", 0)))) * 1000; // MEMSTATS
	lazy.trim_on_pressure = GLOBAL_DEF("memory/malloc_trim_on_pressure", true);
''')
    return s


edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
