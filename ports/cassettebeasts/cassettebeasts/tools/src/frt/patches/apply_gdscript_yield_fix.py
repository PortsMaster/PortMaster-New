#!/usr/bin/env python3
"""Godot 3.5 GDScript fix (port patch): no crash when a node is freed while one of its scripts is in a yield.

Godot issue #74695 (3.5.1 / 3.5.2): clearing the pending coroutine states of a freed script instance (or of a
script) could delete a GDScriptFunctionState indirectly during its own _clear_stack call, a use-after-free that
crashed rarely and without an error message. The fix holds a reference to each state while its stack is cleared.
By Tom Coxon of Bytten Studio (branch gh74695_3.x of github.com/tcoxon/godot), found while shipping Cassette Beasts;
upstream fixed the 3.x line only in 3.7 (#97464). MIT, like Godot.

usage: apply_gdscript_yield_fix.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "YIELD-FIX-PATCH"
p = godot / "modules/gdscript/gdscript.cpp"
s = p.read_text()
if MARK in s:
    print("already patched:", p)
    sys.exit(0)
old = """		// Order matters since clearing the stack may already cause
		// the GDSCriptFunctionState to be destroyed and thus removed from the list.
		pending_func_states.remove(E);
		E->self()->_clear_stack();"""
new = """		// %s (Godot #74695): hold a reference to the function state while we do this, so it
		// doesn't get indirectly deleted during the _clear_stack call.
		Ref<GDScriptFunctionState> gdfs = E->self();
		// Order matters since clearing the stack may already cause
		// the GDSCriptFunctionState to be destroyed and thus removed from the list.
		pending_func_states.remove(E);
		gdfs->_clear_stack();""" % MARK
assert s.count(old) == 2, s.count(old)  # GDScript::_clear_pending_func_states and ~GDScriptInstance
p.write_text(s.replace(old, new))
print("patched (2 places):", p)
