#!/usr/bin/env python3
"""GLES3: no uniform buffer is overwritten while the GPU may still read it, on PowerVR GPUs (port patch).

Godot 3's GLES3 renderer keeps one scene UBO, one environment UBO, one directional light UBO and one array UBO
each for omni lights, spot lights and reflection probes, and re-uploads them (glBufferData / glBufferSubData on
the same buffer object) for every 3D pass: several times a frame when Viewports render their own worlds
(Cassette Beasts draws every NPC sprite through one) or shadows are on. Material UBOs are re-uploaded in place
when a parameter changes. On a deferred tile renderer the fragment stage reads those buffers long after the draw
was issued; the PowerVR Rogue GE8300 driver (TrimUI Smart Pro, Knulli, 1.19.6345021) then reads old or freed
memory: positions right (vertex stage), lighting and material colours random from run to run (sun colour and
direction, ambient: beach black/red/white, sprites tinted, water in neon patches; 2026-10-09).
On PowerVR (renderer name; PORT_PVR_UBO_RING=0/1 overrides) every upload of the scene-level UBOs goes to the
next buffer object of a ring of 64 and the renderer binds that one, so no buffer is written again within a frame;
a material parameter change gets a new buffer object (the old one deleted: the driver keeps it until the GPU is
done). Other GPUs: unchanged code paths.
usage: apply_pvr_ubo_ring.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'PVR-UBO-RING-PATCH'


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
// PVR-UBO-RING-PATCH (apply_pvr_ubo_ring.py): on PowerVR every upload of a scene-level UBO goes to the next
// buffer of a ring, so a buffer still read by the GPU's fragment stage is never written again; the driver read
// old/freed memory otherwise (random lighting and material colours). PORT_PVR_UBO_RING=0/1 overrides.
#include "core/os/os.h"
static int port_pvr_ubo_ring() {
	static int on = -1;
	if (on < 0) {
		String m = OS::get_singleton()->get_environment("PORT_PVR_UBO_RING");
		if (m != "") {
			on = m != "0" ? 1 : 0;
		} else {
			const char *r = (const char *)glGetString(GL_RENDERER);
			on = (r && strstr(r, "PowerVR")) ? 1 : 0;
		}
		if (on) {
			print_line("pvr ubo ring: on");
		}
	}
	return on;
}

struct PortUboRing {
	enum { N = 64 };
	GLuint ids[N];
	int next;
	PortUboRing() :
			next(-1) {}
	// uploads p_data: on PowerVR into the next ring buffer, elsewhere into p_fallback as the engine did
	GLuint upload(GLuint p_fallback, GLsizeiptr p_size, const void *p_data, GLenum p_usage) {
		GLuint id = p_fallback;
		if (port_pvr_ubo_ring()) {
			if (next < 0) {
				glGenBuffers(N, ids);
				next = 0;
			}
			id = ids[next];
			next = (next + 1) % N;
		}
		glBindBuffer(GL_UNIFORM_BUFFER, id);
		glBufferData(GL_UNIFORM_BUFFER, p_size, p_data, p_usage);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
		return id;
	}
};
static PortUboRing port_ring_scene, port_ring_env, port_ring_dir, port_ring_omni, port_ring_spot, port_ring_refl;
'''


def scene(s):
    # helper before the first function of the file
    s = once(s, '\nstatic const GLenum _cube_side_enum[6] = {', HELPER + '\nstatic const GLenum _cube_side_enum[6] = {')
    s = once(s, '''	glBindBuffer(GL_UNIFORM_BUFFER, state.scene_ubo);
	glBufferData(GL_UNIFORM_BUFFER, sizeof(State::SceneDataUBO), &state.ubo_data, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
''', '''	state.scene_ubo = port_ring_scene.upload(state.scene_ubo, sizeof(State::SceneDataUBO), &state.ubo_data, GL_DYNAMIC_DRAW); // PVR-UBO-RING-PATCH
''')
    s = once(s, '''	glBindBuffer(GL_UNIFORM_BUFFER, state.env_radiance_ubo);
	glBufferData(GL_UNIFORM_BUFFER, sizeof(State::EnvironmentRadianceUBO), &state.env_radiance_data, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
''', '''	state.env_radiance_ubo = port_ring_env.upload(state.env_radiance_ubo, sizeof(State::EnvironmentRadianceUBO), &state.env_radiance_data, GL_DYNAMIC_DRAW); // PVR-UBO-RING-PATCH
''')
    s = once(s, '''	glBindBuffer(GL_UNIFORM_BUFFER, state.directional_ubo);
	glBufferData(GL_UNIFORM_BUFFER, sizeof(LightDataUBO), &ubo_data, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
''', '''	state.directional_ubo = port_ring_dir.upload(state.directional_ubo, sizeof(LightDataUBO), &ubo_data, GL_DYNAMIC_DRAW); // PVR-UBO-RING-PATCH
''')
    s = once(s, '''	if (state.omni_light_count) {
		glBindBuffer(GL_UNIFORM_BUFFER, state.omni_array_ubo);
		glBufferSubData(GL_UNIFORM_BUFFER, 0, state.omni_light_count * state.ubo_light_size, state.omni_array_tmp);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
	}
''', '''	if (state.omni_light_count && port_pvr_ubo_ring()) { // PVR-UBO-RING-PATCH: whole array into the next ring buffer
		state.omni_array_ubo = port_ring_omni.upload(state.omni_array_ubo, state.ubo_light_size * state.max_ubo_lights, state.omni_array_tmp, GL_DYNAMIC_DRAW);
	} else if (state.omni_light_count) {
		glBindBuffer(GL_UNIFORM_BUFFER, state.omni_array_ubo);
		glBufferSubData(GL_UNIFORM_BUFFER, 0, state.omni_light_count * state.ubo_light_size, state.omni_array_tmp);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
	}
''')
    s = once(s, '''	if (state.spot_light_count) {
		glBindBuffer(GL_UNIFORM_BUFFER, state.spot_array_ubo);
		glBufferSubData(GL_UNIFORM_BUFFER, 0, state.spot_light_count * state.ubo_light_size, state.spot_array_tmp);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
	}
''', '''	if (state.spot_light_count && port_pvr_ubo_ring()) { // PVR-UBO-RING-PATCH
		state.spot_array_ubo = port_ring_spot.upload(state.spot_array_ubo, state.ubo_light_size * state.max_ubo_lights, state.spot_array_tmp, GL_DYNAMIC_DRAW);
	} else if (state.spot_light_count) {
		glBindBuffer(GL_UNIFORM_BUFFER, state.spot_array_ubo);
		glBufferSubData(GL_UNIFORM_BUFFER, 0, state.spot_light_count * state.ubo_light_size, state.spot_array_tmp);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
	}
''')
    s = once(s, '''	if (state.reflection_probe_count) {
		glBindBuffer(GL_UNIFORM_BUFFER, state.reflection_array_ubo);
		glBufferSubData(GL_UNIFORM_BUFFER, 0, state.reflection_probe_count * sizeof(ReflectionProbeDataUBO), state.reflection_array_tmp);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
	}
''', '''	if (state.reflection_probe_count && port_pvr_ubo_ring()) { // PVR-UBO-RING-PATCH
		state.reflection_array_ubo = port_ring_refl.upload(state.reflection_array_ubo, sizeof(ReflectionProbeDataUBO) * state.max_ubo_reflections, state.reflection_array_tmp, GL_DYNAMIC_DRAW);
	} else if (state.reflection_probe_count) {
		glBindBuffer(GL_UNIFORM_BUFFER, state.reflection_array_ubo);
		glBufferSubData(GL_UNIFORM_BUFFER, 0, state.reflection_probe_count * sizeof(ReflectionProbeDataUBO), state.reflection_array_tmp);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
	}
''')
    return s


def storage(s):
    s = once(s, '''		glBindBuffer(GL_UNIFORM_BUFFER, material->ubo_id);
		glBufferData(GL_UNIFORM_BUFFER, material->ubo_size, local_ubo, GL_STATIC_DRAW);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
''', '''		// PVR-UBO-RING-PATCH: on PowerVR a changed material gets a new buffer object instead of an in-place
		// re-upload of one the GPU may still read (see apply_pvr_ubo_ring.py)
		{
			static int pvr = -1;
			if (pvr < 0) {
				String m = OS::get_singleton()->get_environment("PORT_PVR_UBO_RING");
				if (m != "") {
					pvr = m != "0" ? 1 : 0;
				} else {
					const char *r = (const char *)glGetString(GL_RENDERER);
					pvr = (r && strstr(r, "PowerVR")) ? 1 : 0;
				}
			}
			if (pvr) {
				glDeleteBuffers(1, &material->ubo_id);
				glGenBuffers(1, &material->ubo_id);
			}
		}
		glBindBuffer(GL_UNIFORM_BUFFER, material->ubo_id);
		glBufferData(GL_UNIFORM_BUFFER, material->ubo_size, local_ubo, GL_STATIC_DRAW);
		glBindBuffer(GL_UNIFORM_BUFFER, 0);
''')
    return s


edit('drivers/gles3/rasterizer_scene_gles3.cpp', scene)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage)
