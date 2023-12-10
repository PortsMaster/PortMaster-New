# TODO

## Xenoveritas TODO

- [ ] Add joystick/gamepad support
- [ ] Find any dead code and remove it
- [ ] Rewrite event handling to allow multiple keybindings for the same actions
- [ ] Update configuration system to deal with joysticks/gamepads
- [ ] Strongly considering replacing the jFILE/bFILE stuff with SDL's SDL_RW API

## Original TODO

- [ ] Go through the old stuff below and figure out what's even still relevent:

----

This is a list of known bugs and features that need fixing/implementing:

FEATURES
--------
- Multiplayer support over the internet and local network using tcp/ip.
- Multiplayer support over a local network using IPX.
- Performance improvements.
- Add YUV overlay support.
- Convert all internal rendering to 24-bit.

SAM'S TODO
----------
 - replace `write_PCX` calls with `SDL_WriteSurfaceBMP`

ABUSE-TOOL
----------
 - allow to query ids by name rather than by number

DATA MERGE
----------
 - remove registration related code
   - server check in src/net/netdrv.cp
   - server check in src/innet.cpp
   - Lisp symbols server_not_reg and net_not_reg
 - ensure gamma.lsp, hardness.lsp, defaults.prp, edit.lsp etc. are always
   loaded and saved in the config directory, not in the datadir (use
   local_load instead of load?). Same for addon/deathmat/cur_lev.lsp
