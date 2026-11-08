#!/usr/bin/env python3
"""Debug aid (port patch): log slow resource loads on the main thread. With PORT_SLOW_LOAD_MS=<n> in the
environment, every ResourceLoader::load() on the main thread that takes n ms or more prints
"slow load <ms> ms at <seconds since start> s: <path>" to stdout when it returns (nested loads print first, the outer one last with the
total). For finding which files a game loads synchronously while playing (Cassette Beasts: walking hitches).
Off (one static int compare per load) without the variable.
usage: apply_slow_load_log.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'SLOW-LOAD-LOG-PATCH'


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


OLD = '''RES ResourceLoader::load(const String &p_path, const String &p_type_hint, bool p_no_cache, Error *r_error) {
	if (r_error) {
		*r_error = ERR_CANT_OPEN;
	}
'''
NEW = '''// SLOW-LOAD-LOG-PATCH: PORT_SLOW_LOAD_MS=<n>: print main-thread loads that take n ms or more
struct _SlowLoadLog {
	const String &path;
	uint64_t t0;
	int ms;
	_SlowLoadLog(const String &p_path, int p_ms) :
			path(p_path), t0(p_ms > 0 ? OS::get_singleton()->get_ticks_usec() : 0), ms(p_ms) {}
	~_SlowLoadLog() {
		if (ms > 0 && Thread::get_caller_id() == Thread::get_main_id()) {
			uint64_t d = (OS::get_singleton()->get_ticks_usec() - t0) / 1000;
			if (d >= (uint64_t)ms) {
				print_line("slow load " + itos(d) + " ms at " + rtos(OS::get_singleton()->get_ticks_msec() / 1000.0) + " s: " + path);
			}
		}
	}
};

RES ResourceLoader::load(const String &p_path, const String &p_type_hint, bool p_no_cache, Error *r_error) {
	static const int slow_load_ms = OS::get_singleton()->get_environment("PORT_SLOW_LOAD_MS").to_int();
	_SlowLoadLog slow_load_log(p_path, slow_load_ms);
	if (r_error) {
		*r_error = ERR_CANT_OPEN;
	}
'''

edit('core/io/resource_loader.cpp', lambda s: once(once(s, OLD, NEW), '#include "core/os/os.h"\n', '#include "core/os/os.h"\n#include "core/os/thread.h"\n'))
