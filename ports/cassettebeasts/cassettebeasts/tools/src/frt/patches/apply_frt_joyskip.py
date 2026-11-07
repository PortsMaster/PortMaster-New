#!/usr/bin/env python3
"""FRT 2.1.0 port patch (after apply_frt_joyonly.py): FRT_JOY_SKIP=<text>[|<text>...] in the environment skips the
joysticks whose SDL name contains one of the texts and opens every other one. For local co-op: the launcher names
the handheld's own controller (the input device gptokeyb2 reads and turns into its virtual pad), so the virtual
pad is player 1 and an external USB/Bluetooth pad joins as player 2. With only FRT_JOY_ONLY (the earlier rule:
the virtual pad alone) external pads were skipped and the game's controller assignment screen had nothing to
assign (Cube XX / RG552, 2026-10-11). FRT_JOY_ONLY still works and is checked first.
usage: apply_frt_joyskip.py <frt dir>   (idempotent)
"""
import os, sys

p = os.path.join(sys.argv[1], 'sdl2_adapter.h')
s = open(p, encoding='utf-8').read()
if 'JOYSKIP-PATCH' in s:
    print('already patched: sdl2_adapter.h')
    sys.exit(0)
old = '''				fprintf(stderr, "frt: joystick %d \\"%s\\" %s\\n", index, name ? name : "", match ? "opened" : "skipped (FRT_JOY_ONLY)");
				if (!match)
					return;
			}'''
new = '''				fprintf(stderr, "frt: joystick %d \\"%s\\" %s\\n", index, name ? name : "", match ? "opened" : "skipped (FRT_JOY_ONLY)");
				if (!match)
					return;
			}
			// JOYSKIP-PATCH: FRT_JOY_SKIP=<text>|...: every joystick except those named with one of the texts (the
			// handheld's own controller, read by gptokeyb2): external pads join as further players
			const char *skip = getenv("FRT_JOY_SKIP");
			if (skip && *skip && !(only && *only)) {
				bool hit = false;
				const char *p = skip;
				while (name && *p && !hit) {
					const char *e = strchr(p, '|');
					size_t n = e ? (size_t)(e - p) : strlen(p);
					for (const char *q = name; *q && !hit; q++)
						hit = n > 0 && strncmp(q, p, n) == 0;
					p = e ? e + 1 : p + n;
				}
				fprintf(stderr, "frt: joystick %d \\"%s\\" %s\\n", index, name ? name : "", hit ? "skipped (FRT_JOY_SKIP)" : "opened");
				if (hit)
					return;
			}'''
assert s.count(old) == 1, s.count(old)
s = s.replace(old, new)
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched: sdl2_adapter.h')
