#!/usr/bin/env python3
"""GLES3: GPU particle update workarounds for PowerVR drivers (port patch).

Godot 3's GLES3 particles move on the GPU with transform feedback (RasterizerStorageGLES3::_particles_process:
glBeginTransformFeedback + glDrawArrays(GL_POINTS, 0, amount)). On the TrimUI Smart Pro (PowerVR Rogue GE8300,
driver 1.19.6345021) that draw crashes inside libGLESv2.so (null read; core dump 2026-10-09: SDL's signal handler
re-raised, the kernel signal frame on the stack holds the driver pc and the engine frames above it), within a
minute or two of the start, wherever particles are drawn.
Modes (PORT_PVR_PARTICLES=<mode>; without it, renderers named PowerVR get DEFAULT_MODE, others "none"):
  none    the engine's code
  guard   skip systems with no particles or no buffers (Mali draws those as nothing)
  finish  guard + glFinish() after each particle update
  off     no particle updates at all (the particles stay where they are / invisible)
usage: apply_pvr_particles.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'PVR-PARTICLES-PATCH'
DEFAULT_MODE = 'none'  # 2026-10-10: the crash was the program binary cache (apply_feedback_nocache.py); was 'off'
# (guard and finish still crashed on the Smart Pro 2026-10-09 because the cached programs were still used)


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


def storage(s):
    s = once(s, '''void RasterizerStorageGLES3::_particles_process(Particles *p_particles, float p_delta) {
''', '''// PVR-PARTICLES-PATCH: 0 none, 1 guard, 2 finish, 3 off (PORT_PVR_PARTICLES; PowerVR renderers default to
// "''' + DEFAULT_MODE + '''")
static int pvr_particles_mode() {
	static int mode = -1;
	if (mode < 0) {
		String m = OS::get_singleton()->get_environment("PORT_PVR_PARTICLES");
		if (m == "") {
			const char *r = (const char *)glGetString(GL_RENDERER);
			m = (r && strstr(r, "PowerVR")) ? "''' + DEFAULT_MODE + '''" : "none";
		}
		mode = m == "guard" ? 1 : m == "finish" ? 2 : m == "off" ? 3 : 0;
		if (mode) {
			print_line("pvr particles: " + m);
		}
	}
	return mode;
}

void RasterizerStorageGLES3::_particles_process(Particles *p_particles, float p_delta) {
	const int pvr_mode = pvr_particles_mode();
	if (pvr_mode == 3 || (pvr_mode && (p_particles->amount <= 0 || !p_particles->particle_vaos[0] || !p_particles->particle_buffers[1]))) {
		return;
	}
''')
    s = once(s, '''	glBeginTransformFeedback(GL_POINTS);
	glDrawArrays(GL_POINTS, 0, p_particles->amount);
	glEndTransformFeedback();
''', '''	glBeginTransformFeedback(GL_POINTS);
	glDrawArrays(GL_POINTS, 0, p_particles->amount);
	glEndTransformFeedback();
	if (pvr_mode == 2) {
		glFinish();
	}
''')
    return s


edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage)
