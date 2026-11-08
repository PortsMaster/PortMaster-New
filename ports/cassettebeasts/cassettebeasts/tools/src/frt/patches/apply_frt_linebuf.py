#!/usr/bin/env python3
"""FRT 2.1.0 port patch: line-buffered stdout. PortMaster launchers pipe the game's output through tee into
log.txt; a pipe makes stdout block-buffered, so the engine's and the game's print() lines sat in a 4 KB buffer and
were lost when Select+Start killed the game (R36S log.txt, 2026-10-11: no engine lines at all; stderr, where
errors go, was unbuffered and arrived). Now every line is written out as it is printed.
usage: apply_frt_linebuf.py <frt dir>   (idempotent)
"""
import os, sys

p = os.path.join(sys.argv[1], 'frt_godot3.cc')
s = open(p, encoding='utf-8').read()
if 'LINEBUF-PATCH' in s:
    print('already patched: frt_godot3.cc')
    sys.exit(0)
old = '''extern "C" int frt_godot_main(int argc, char *argv[]) {
	frt::Godot3_OS os;'''
new = '''extern "C" int frt_godot_main(int argc, char *argv[]) {
	// LINEBUF-PATCH: stdout is usually a pipe to tee (log.txt): flush every line, not every 4 KB
	setvbuf(stdout, NULL, _IOLBF, 0);
	frt::Godot3_OS os;'''
assert s.count(old) == 1
s = s.replace(old, new)
if '#include <stdio.h>' not in s:
    s = s.replace('#include "frt.h"\n', '#include "frt.h"\n#include <stdio.h>\n', 1)
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched: frt_godot3.cc')
