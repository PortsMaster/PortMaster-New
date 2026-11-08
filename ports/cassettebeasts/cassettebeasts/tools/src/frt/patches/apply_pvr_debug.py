#!/usr/bin/env python3
"""GLES3 debug switches for the PowerVR colour investigation (port patch, test builds only).

env PORT_PVR_DEBUG = comma list of:  nofog (fog off in the scene UBO), nosun (directional light energy 0),
noambient (ambient energy 0 and no sky contribution), nobg (background energy 0), noadjust (nothing: reserved).
Prints the active list once. Off (no behaviour change) when the variable is empty, on every GPU.
usage: apply_pvr_debug.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'PVR-DEBUG-PATCH'


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


HELPER = '''
// PVR-DEBUG-PATCH (apply_pvr_debug.py): PORT_PVR_DEBUG=nofog,nosun,noambient,nobg (test builds)
static bool port_pvr_debug(const char *p_flag) {
	static String flags;
	static bool loaded = false;
	if (!loaded) {
		flags = OS::get_singleton()->get_environment("PORT_PVR_DEBUG");
		loaded = true;
		if (flags != "") {
			print_line("pvr debug: " + flags);
		}
	}
	return flags != "" && flags.split(",").find(p_flag) >= 0;
}
'''


def scene(s):
    s = once(s, '\nstatic const GLenum _cube_side_enum[6] = {', HELPER + '\nstatic const GLenum _cube_side_enum[6] = {')
    # scene UBO: just before the (ring) upload in _setup_environment
    s = once(s, '''	state.scene_ubo = port_ring_scene.upload(state.scene_ubo,''', '''	if (port_pvr_debug("nofog")) { // PVR-DEBUG-PATCH
		state.ubo_data.fog_color_enabled[3] = 0.0;
	}
	if (port_pvr_debug("noambient")) {
		state.ubo_data.ambient_energy = 0.0;
		state.env_radiance_data.ambient_contribution = 0.0;
	}
	if (port_pvr_debug("nobg")) {
		state.ubo_data.bg_energy = 0.0;
	}
	state.scene_ubo = port_ring_scene.upload(state.scene_ubo,''')
    s = once(s, '''	state.directional_ubo = port_ring_dir.upload(state.directional_ubo,''', '''	if (port_pvr_debug("nosun")) { // PVR-DEBUG-PATCH
		ubo_data.light_color_energy[0] = ubo_data.light_color_energy[1] = ubo_data.light_color_energy[2] = 0.0;
	}
	state.directional_ubo = port_ring_dir.upload(state.directional_ubo,''')
    return s


edit('drivers/gles3/rasterizer_scene_gles3.cpp', scene)
