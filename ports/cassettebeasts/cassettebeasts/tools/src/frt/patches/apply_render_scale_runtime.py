#!/usr/bin/env python3
"""rendering/quality/3d_render_scale takes effect at run time: it was read once (a static in _draw_3d); now each
frame reads it through a cached key, so ProjectSettings.set_setting from a script (the port's "3D resolution"
setting) changes the 3D resolution at once. The scaled render target already follows a changed size
(render_target_get_scaled_3d). Needs apply_render_scale.py and apply_viewport_cap.py first.

usage: apply_render_scale_runtime.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "RENDER-SCALE-RUNTIME-PATCH"
p = godot / "servers/visual/visual_server_viewport.cpp"
s = p.read_text()
if MARK in s:
    print("already patched:", p)
    sys.exit(0)
old = 'static const float render_scale = CLAMP(float(GLOBAL_DEF("rendering/quality/3d_render_scale", 1.0)), 0.25f, 1.0f);'
assert s.count(old) == 1, s.count(old)
s = s.replace(old, "const float render_scale = port_render_scale(); // %s" % MARK)
inc = '#include "visual_server_scene.h"\n'
assert s.count(inc) == 1
s = s.replace(inc, inc + '''
// %s: the 3D render scale read every frame (default 1.0 defined once)
static float port_render_scale() {
	static const StringName key = "rendering/quality/3d_render_scale";
	static const bool defined = (GLOBAL_DEF("rendering/quality/3d_render_scale", 1.0), true);
	(void)defined;
	return CLAMP(float(ProjectSettings::get_singleton()->get(key)), 0.25f, 1.0f);
}
''' % MARK, 1)
p.write_text(s)
print("patched:", p)
