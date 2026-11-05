#!/usr/bin/env python3
"""Lazy textures (apply_lazy.py) for immediate geometry: Sprite3D/AnimatedSprite3D draw through VS immediates,
whose chunk texture RasterizerSceneGLES3::_render_geometry binds directly. That bind site had no
texture_lazy_touch, so a sprite texture was never marked as drawn: evict_after_seconds after its upload it was
freed while on screen and never uploaded again (posters, signs and Aseprite-animated NPCs vanished 30-90 s into
an area, "when I get close"). Now the immediate path touches (and if needed uploads) the texture like every other
bind site. Needs apply_lazy.py first.

usage: apply_lazy_immediate.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "LAZY-IMMEDIATE-PATCH"

p = godot / "drivers/gles3/rasterizer_scene_gles3.cpp"
s = p.read_text()
if MARK in s:
    print("already applied:", p)
    sys.exit(0)
assert "LAZY-PATCH" in s, "apply_lazy.py first"
old = """					RasterizerStorageGLES3::Texture *t = storage->texture_owner.get(c.texture);

					if (t->redraw_if_visible) {"""
assert s.count(old) == 1, s.count(old)
s = s.replace(old, """					RasterizerStorageGLES3::Texture *t = storage->texture_owner.get(c.texture);
					storage->texture_lazy_touch(t); // %s: Sprite3D textures count as drawn (upload if evicted)

					if (t->redraw_if_visible) {""" % MARK)
p.write_text(s, newline="\n")
print("patched:", p)
