#!/usr/bin/env python3
"""Debug aid (port patch): with GODOT_OBJECT_DUMP=<file> in the environment, Main::iteration checks every
2 s whether <file> exists; if so it prints a histogram of all live objects by class (top 40) and
the resource count by class to stderr and deletes the file. For finding what fills memory on a device.
usage: apply_objdump.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
p = os.path.join(G, 'main/main.cpp')
s = open(p, encoding='utf-8').read()
if 'OBJDUMP-PATCH' in s:
    print('already patched: main/main.cpp')
    sys.exit(0)

FUNC = '''
// OBJDUMP-PATCH: object histogram on request (GODOT_OBJECT_DUMP=<trigger file>)
static HashMap<String, int> *objdump_counts = nullptr;
static void _objdump_count(Object *p_obj) {
	String c = p_obj->get_class();
	if (Object::cast_to<Node>(p_obj) && !Object::cast_to<Node>(p_obj)->is_inside_tree()) {
		c += " (not in tree)";
	}
	int *v = objdump_counts->getptr(c);
	if (v) {
		(*v)++;
	} else {
		objdump_counts->set(c, 1);
	}
}

static void _objdump_check() {
	static String trigger = OS::get_singleton()->get_environment("GODOT_OBJECT_DUMP");
	static uint64_t last = 0;
	if (trigger.empty()) {
		return;
	}
	uint64_t now = OS::get_singleton()->get_ticks_msec();
	if (now - last < 2000) {
		return;
	}
	last = now;
	if (!FileAccess::exists(trigger)) {
		return;
	}
	DirAccess::remove_file_or_error(trigger);
	HashMap<String, int> counts;
	objdump_counts = &counts;
	ObjectDB::debug_objects(_objdump_count);
	objdump_counts = nullptr;
	fprintf(stderr, "=== objects: %d total, %d classes, static memory %d MB\\n", ObjectDB::get_object_count(), counts.size(), int(Memory::get_mem_usage() >> 20));
	for (int i = 0; i < 40; i++) { // top 40 by count
		const String *best = nullptr;
		int best_count = 0;
		const String *k = nullptr;
		while ((k = counts.next(k))) {
			if (counts[*k] > best_count) {
				best_count = counts[*k];
				best = k;
			}
		}
		if (!best) {
			break;
		}
		fprintf(stderr, "%8d %s\\n", best_count, best->utf8().get_data());
		counts[*best] = 0;
	}
}

bool Main::iteration() {'''

assert s.count('\nbool Main::iteration() {') == 1
s = s.replace('\nbool Main::iteration() {', FUNC, 1)
anchor = '\tframes++;\n\tEngine::get_singleton()->_idle_frames++;\n'
assert s.count(anchor) == 1
s = s.replace(anchor, anchor + '\t_objdump_check(); // OBJDUMP-PATCH\n', 1)
if '#include "core/os/dir_access.h"' not in s:
    s = s.replace('#include "main.h"\n', '#include "main.h"\n#include "core/os/dir_access.h"\n', 1)
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched: main/main.cpp')
