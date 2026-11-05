#!/usr/bin/env python3
"""FRT 2.1.0 port patch: FRT_NO_JOYSTICK=1 in the environment keeps SDL's joystick subsystem off, so the
game sees no gamepad. For ports that turn the pad into keys with gptokeyb2: a game with its own joypad
bindings (PortMaster exports SDL_GAMECONTROLLERCONFIG, which Godot 3 reads) otherwise gets every D-pad
press twice, as a key and as a joypad button (two-item menus wrap back to the first item).
usage: apply_frt_nojoy.py <frt dir>   (idempotent)
"""
import os, sys

p = os.path.join(sys.argv[1], 'sdl2_adapter.h')
s = open(p, encoding='utf-8').read()
if 'NOJOY-PATCH' in s:
    print('already patched: sdl2_adapter.h')
    sys.exit(0)
old = '''		if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_JOYSTICK) < 0)'''
new = '''		// NOJOY-PATCH: FRT_NO_JOYSTICK=1: no gamepad for the game (the port maps the pad to keys)
		const char *nojoy = getenv("FRT_NO_JOYSTICK");
		Uint32 subsystems = SDL_INIT_VIDEO | SDL_INIT_AUDIO;
		if (!nojoy || strcmp(nojoy, "1") != 0)
			subsystems |= SDL_INIT_JOYSTICK;
		if (SDL_Init(subsystems) < 0)'''
assert s.count(old) == 1
s = s.replace(old, new)
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched: sdl2_adapter.h')
