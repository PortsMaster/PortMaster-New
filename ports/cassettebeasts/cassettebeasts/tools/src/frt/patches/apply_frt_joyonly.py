#!/usr/bin/env python3
"""FRT 2.1.0 port patch: FRT_JOY_ONLY=<text> in the environment opens only the joysticks whose SDL name contains
<text>. For ports that let gptokeyb2 -x turn the handheld's controller into one virtual "Microsoft X-Box 360
pad" (the same layout and name on every firmware, from PortMaster's own controller mapping): the game must not
also read the real controller, or every press arrives twice. The joysticks that are opened get the lowest free
game ids (0, 1, ...) instead of SDL's device index: games give player 1 to device 0 (Cassette Beasts: with the
real pad skipped, the virtual one was device 1 and nobody controlled the player). Without FRT_JOY_ONLY the ids are
the same as before (the device order).
usage: apply_frt_joyonly.py <frt dir>   (idempotent)
"""
import os, sys

p = os.path.join(sys.argv[1], 'sdl2_adapter.h')
s = open(p, encoding='utf-8').read()
if 'JOYONLY-PATCH' in s:
    print('already patched: sdl2_adapter.h')
    sys.exit(0)
old = '''			id = ev.jdevice.which;
			if (id >= MAX_JOYSTICKS)
				return;
			const char *name = SDL_JoystickNameForIndex(id);
			char guid[64];
			SDL_JoystickGetGUIDString(SDL_JoystickGetDeviceGUID(id), guid, sizeof(guid));
			handler_->handle_js_status_event(id, true, name, guid);
			js_[id] = SDL_JoystickOpen(id);'''
new = r'''			// JOYONLY-PATCH: FRT_JOY_ONLY=<text>: only joysticks named with it (gptokeyb2's virtual pad); game ids =
			// the lowest free slot, so the first joystick opened is device 0
			const int index = ev.jdevice.which;
			const char *name = SDL_JoystickNameForIndex(index);
			const char *only = getenv("FRT_JOY_ONLY"); // alternatives separated by |
			if (only && *only) {
				bool match = false;
				const char *p = only;
				while (name && *p && !match) {
					const char *e = strchr(p, '|');
					size_t n = e ? (size_t)(e - p) : strlen(p);
					for (const char *q = name; *q && !match; q++)
						match = n > 0 && strncmp(q, p, n) == 0;
					p = e ? e + 1 : p + n;
				}
				fprintf(stderr, "frt: joystick %d \"%s\" %s\n", index, name ? name : "", match ? "opened" : "skipped (FRT_JOY_ONLY)");
				if (!match)
					return;
			}
			for (id = 0; id < MAX_JOYSTICKS && js_[id]; id++)
				;
			if (id >= MAX_JOYSTICKS)
				return;
			char guid[64];
			SDL_JoystickGetGUIDString(SDL_JoystickGetDeviceGUID(index), guid, sizeof(guid));
			handler_->handle_js_status_event(id, true, name, guid);
			js_[id] = SDL_JoystickOpen(index);'''
assert s.count(old) == 1
s = s.replace(old, new)
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched: sdl2_adapter.h')
