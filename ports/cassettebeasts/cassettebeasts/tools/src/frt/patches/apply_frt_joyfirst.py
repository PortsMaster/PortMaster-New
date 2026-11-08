#!/usr/bin/env python3
"""FRT 2.1.0 port patch (after apply_frt_joyskip.py and apply_frt_joyname.py), local co-op polish:
1. FRT_JOY_FIRST=<text>|...: a joystick named with one of the texts (gptokeyb2's virtual pad: the handheld's own
   controls) gets game id 0 (player 1). Other joysticks start at id 1 while such a joystick is present, so a
   Bluetooth pad that SDL lists first no longer takes player 1 (Cube XX, 2026-10-11). The id it got is put in the
   environment as FRT_JOY_FIRST_ID (the port's controller assignment screen reads it: Godot's joy GUID for these
   pads is only "Default Joypad").
2. FRT_JOY_NAME_MATCH takes alternatives separated by | (was one text): Linux's hid-nintendo names a Switch Pro pad
   in Switch mode just "Pro Controller" (Joy-Cons "Joy-Con (L)/(R)"), which the game took for an Xbox pad.
usage: apply_frt_joyfirst.py <frt dir>   (idempotent)
"""
import os, sys

D = sys.argv[1]


def edit(rel, pairs, mark):
    p = os.path.join(D, rel)
    s = open(p, encoding='utf-8').read()
    if mark in s:
        print('already patched:', rel)
        return
    for old, new in pairs:
        assert s.count(old) == 1, (rel, old[:60], s.count(old))
        s = s.replace(old, new)
    open(p, 'w', encoding='utf-8', newline='\n').write(s)
    print('patched:', rel)


# 1. id 0 for the FRT_JOY_FIRST joystick
first_helper = '''			// JOYFIRST-PATCH: FRT_JOY_FIRST=<text>|...: that joystick (the handheld's own controls) is game id 0, the
			// others start at 1 while it is present; its id goes to FRT_JOY_FIRST_ID
			const char *first = getenv("FRT_JOY_FIRST");
			auto named = [](const char *nm, const char *list) -> bool {
				if (!nm || !list || !*list)
					return false;
				const char *p = list;
				while (*p) {
					const char *e = strchr(p, '|');
					size_t n = e ? (size_t)(e - p) : strlen(p);
					for (const char *q = nm; *q; q++)
						if (n > 0 && strncmp(q, p, n) == 0)
							return true;
					p = e ? e + 1 : p + n;
				}
				return false;
			};
			const bool is_first = named(name, first);
			int start = 0;
			if (first && *first && !is_first) {
				for (int k = 0; k < SDL_NumJoysticks(); k++)
					if (k != index && named(SDL_JoystickNameForIndex(k), first))
						start = 1;
			}
			for (id = start; id < MAX_JOYSTICKS && js_[id]; id++)
				;
			if (is_first) {
				char buf[16];
				snprintf(buf, sizeof(buf), "%d", id);
				setenv("FRT_JOY_FIRST_ID", buf, 1);
			}
'''
edit('sdl2_adapter.h', [('''			for (id = 0; id < MAX_JOYSTICKS && js_[id]; id++)
				;
''', first_helper)], 'JOYFIRST-PATCH')

# 2. FRT_JOY_NAME_MATCH alternatives
edit('frt_godot3.cc', [('''		if (new_name != "" && (match == "" || joy_name.find(match) >= 0)) {''',
                        '''		// JOYFIRST-PATCH: FRT_JOY_NAME_MATCH alternatives separated by |
		bool name_match = match == "";
		if (!name_match) {
			Vector<String> alts = match.split("|", false);
			for (int i = 0; i < alts.size() && !name_match; i++)
				name_match = joy_name.find(alts[i]) >= 0;
		}
		if (new_name != "" && name_match) {''')], 'JOYFIRST-PATCH')
