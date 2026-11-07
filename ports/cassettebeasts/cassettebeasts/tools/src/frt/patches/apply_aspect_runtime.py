#!/usr/bin/env python3
"""rendering/camera/letterbox_aspect and rendering/camera/fit_aspect take effect at run time: they were read
once; now every frame / projection reads them (ProjectSettings.set_setting from a script switches the view live,
e.g. an in-game option). Needs apply_camera_fit.py and apply_letterbox.py first.

usage: apply_aspect_runtime.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "ASPECT-RUNTIME-PATCH"


def edit(rel, old, new):
    p = godot / rel
    s = p.read_text()
    if MARK in s:
        print("already patched:", rel)
        return
    assert s.count(old) == 1, (rel, s.count(old))
    p.write_text(s.replace(old, new), newline="\n")
    print("patched:", rel)


edit("servers/visual/visual_server_viewport.cpp",
     '		static const float lb_aspect = MAX(0.0f, float(GLOBAL_DEF("rendering/camera/letterbox_aspect", 0.0)));\n',
     '		const float lb_aspect = MAX(0.0f, float(GLOBAL_DEF("rendering/camera/letterbox_aspect", 0.0))); // %s: read every frame\n' % MARK)
p = godot / "scene/3d/camera.cpp"
s = p.read_text()
if MARK not in s:
    old = '	static const real_t lb_aspect = ProjectSettings'
    assert s.count(old) == 1
    s = s.replace(old, '	// %s: read on every call\n	const real_t lb_aspect = ProjectSettings' % MARK)
    p.write_text(s, newline="\n")
    print("patched: scene/3d/camera.cpp")
edit("core/math/camera_matrix.cpp",
     '	static const real_t fit_aspect = _camera_fit_aspect_setting();\n',
     '	const real_t fit_aspect = _camera_fit_aspect_setting(); // %s: read on every call\n' % MARK)
