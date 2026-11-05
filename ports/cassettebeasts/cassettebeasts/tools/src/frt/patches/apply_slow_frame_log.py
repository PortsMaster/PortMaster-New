#!/usr/bin/env python3
"""Debug aid (port patch): break slow frames down. With PORT_SLOW_FRAME_MS=<n> in the environment:
- Main::iteration prints "slow frame <ms> ms at <s> s: physics scripts <ms>, physics step <ms>, idle <ms>,
  deferred <ms>, draw <ms>" for every frame of n ms or more (physics scripts = _physics_process + navigation of all
  physics ticks in the frame, physics step = PhysicsServer::step, idle = SceneTree idle (_process, timers, tweens),
  deferred = visual server callbacks + the message queue after idle, draw = VisualServer sync + draw);
- MessageQueue prints "slow deferred <ms> ms at <s> s: <class> <node name> <method>" for each deferred call of
  n/2 ms or more (call_deferred work such as GridMap octant updates lands in "deferred" or in the physics flushes).
For finding what the Cassette Beasts walking hitches are once shaders are cached and file loads ruled out.
Off (one static int compare per frame / deferred call) without the variable.
usage: apply_slow_frame_log.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'SLOW-FRAME-LOG-PATCH'


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


def main_cpp(s):
    s = once(s, '''	uint64_t physics_process_ticks = 0;
	uint64_t idle_process_ticks = 0;
''', '''	uint64_t physics_process_ticks = 0;
	uint64_t idle_process_ticks = 0;
	// SLOW-FRAME-LOG-PATCH: PORT_SLOW_FRAME_MS=<n>: breakdown of frames of n ms or more
	static const int slow_frame_ms = OS::get_singleton()->get_environment("PORT_SLOW_FRAME_MS").to_int();
	uint64_t sf_phys_script = 0, sf_phys_step = 0, sf_idle = 0, sf_deferred = 0, sf_draw = 0;
''')
    s = once(s, '''		if (OS::get_singleton()->get_main_loop()->iteration(frame_slice * time_scale)) {
			exit = true;
			Engine::get_singleton()->_in_physics = false;
			break;
		}

		NavigationServer::get_singleton_mut()->process(frame_slice * time_scale);
''', '''		uint64_t sf_a = OS::get_singleton()->get_ticks_usec(); // SLOW-FRAME-LOG-PATCH
		if (OS::get_singleton()->get_main_loop()->iteration(frame_slice * time_scale)) {
			exit = true;
			Engine::get_singleton()->_in_physics = false;
			break;
		}

		NavigationServer::get_singleton_mut()->process(frame_slice * time_scale);
		sf_phys_script += OS::get_singleton()->get_ticks_usec() - sf_a;
''')
    s = once(s, '''		PhysicsServer::get_singleton()->step(frame_slice * time_scale);
''', '''		uint64_t sf_b = OS::get_singleton()->get_ticks_usec(); // SLOW-FRAME-LOG-PATCH
		PhysicsServer::get_singleton()->step(frame_slice * time_scale);
		sf_phys_step += OS::get_singleton()->get_ticks_usec() - sf_b;
''')
    s = once(s, '''	if (OS::get_singleton()->get_main_loop()->idle(step * time_scale)) {
		exit = true;
	}
	visual_server_callbacks->flush();
	message_queue->flush();

	VisualServer::get_singleton()->sync(); //sync if still drawing from previous frames.
''', '''	if (OS::get_singleton()->get_main_loop()->idle(step * time_scale)) {
		exit = true;
	}
	uint64_t sf_c = OS::get_singleton()->get_ticks_usec(); // SLOW-FRAME-LOG-PATCH
	sf_idle = sf_c - idle_begin;
	visual_server_callbacks->flush();
	message_queue->flush();
	uint64_t sf_d = OS::get_singleton()->get_ticks_usec();
	sf_deferred = sf_d - sf_c;

	VisualServer::get_singleton()->sync(); //sync if still drawing from previous frames.
''')
    s = once(s, '''#ifndef TOOLS_ENABLED
	// we can choose to sync delta from here, just after the draw
''', '''	sf_draw = OS::get_singleton()->get_ticks_usec() - sf_d; // SLOW-FRAME-LOG-PATCH

#ifndef TOOLS_ENABLED
	// we can choose to sync delta from here, just after the draw
''')
    s = once(s, '''	uint64_t frame_time = OS::get_singleton()->get_ticks_usec() - raw_ticks_at_start;
''', '''	uint64_t frame_time = OS::get_singleton()->get_ticks_usec() - raw_ticks_at_start;
	if (slow_frame_ms > 0 && frame_time >= uint64_t(slow_frame_ms) * 1000) { // SLOW-FRAME-LOG-PATCH
		print_line("slow frame " + itos(frame_time / 1000) + " ms at " + rtos(OS::get_singleton()->get_ticks_msec() / 1000.0) + " s: physics scripts " + itos(sf_phys_script / 1000) + ", physics step " + itos(sf_phys_step / 1000) + ", idle " + itos(sf_idle / 1000) + ", deferred " + itos(sf_deferred / 1000) + ", draw " + itos(sf_draw / 1000));
	}
''')
    return s


def mq_cpp(s):
    return once(s, '''	Variant::CallError ce;
	p_target->call(p_func, argptrs, p_argcount, ce);
	if (p_show_error && ce.error != Variant::CallError::CALL_OK) {''', '''	Variant::CallError ce;
	// SLOW-FRAME-LOG-PATCH: PORT_SLOW_FRAME_MS=<n>: deferred calls of n/2 ms or more
	static const int slow_deferred_ms = OS::get_singleton()->get_environment("PORT_SLOW_FRAME_MS").to_int() / 2;
	uint64_t sd_t0 = slow_deferred_ms > 0 ? OS::get_singleton()->get_ticks_usec() : 0;
	String sd_what; // taken before the call: the call may free the target (call_deferred("free"))
	if (slow_deferred_ms > 0) {
		Node *n = Object::cast_to<Node>(p_target);
		sd_what = p_target->get_class() + " " + (n ? String(n->get_name()) : String("-")) + " " + String(p_func);
	}
	p_target->call(p_func, argptrs, p_argcount, ce);
	if (slow_deferred_ms > 0) {
		uint64_t d = (OS::get_singleton()->get_ticks_usec() - sd_t0) / 1000;
		if (d >= uint64_t(slow_deferred_ms)) {
			print_line("slow deferred " + itos(d) + " ms at " + rtos(OS::get_singleton()->get_ticks_msec() / 1000.0) + " s: " + sd_what);
		}
	}
	if (p_show_error && ce.error != Variant::CallError::CALL_OK) {''')


edit('main/main.cpp', main_cpp)
edit('core/message_queue.cpp', lambda s: once(mq_cpp(s), '#include "core/project_settings.h"\n', '#include "core/project_settings.h"\n#include "core/os/os.h"\n#include "scene/main/node.h"\n') if '#include "core/project_settings.h"\n' in s else mq_cpp(s))
