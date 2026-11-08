#!/usr/bin/env python3
"""Godot 3.5 GLES3 port patch: alpha-scissor materials with depth_draw_alpha_prepass write depth in the opaque
pass when there is no depth prepass.

Such materials (Cassette Beasts: every 3D sprite shader, posters, signs, Aseprite-animated NPCs) go to the opaque
render list and _setup_material sets glDepthMask(p_depth_pass): their depth is meant to come from the depth
prepass. Godot skips that prepass for the GPU vendors in rendering/quality/depth_prepass/disable_for_vendors
(Mali, PowerVR, Adreno, Apple) and for NO_3D_EFFECTS render targets, so on a Mali handheld they were drawn
without writing depth and any opaque geometry sorted after them (the wall behind a poster, the floor under an
NPC) painted over them: sprites vanished depending on the camera position ("as you get closer"). Now, in the
opaque pass without a prepass, they write depth like DEPTH_DRAW_OPAQUE (alpha scissor already discards the
transparent pixels), which is what the prepass would have left in the depth buffer.

usage: apply_alpha_prepass_depth.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "ALPHA-PREPASS-DEPTH-PATCH"

p = godot / "drivers/gles3/rasterizer_scene_gles3.cpp"
s = p.read_text()
if MARK in s:
    print("already applied:", p)
    sys.exit(0)
old = """			case RasterizerStorageGLES3::Shader::Spatial::DEPTH_DRAW_ALPHA_PREPASS: {
				glDepthMask(p_depth_pass);
"""
assert s.count(old) == 1, s.count(old)
s = s.replace(old, """			case RasterizerStorageGLES3::Shader::Spatial::DEPTH_DRAW_ALPHA_PREPASS: {
				// %s: without a depth prepass (vendor list, NO_3D_EFFECTS) the opaque pass is the only
				// place these alpha-scissor materials can write depth; else later opaque geometry paints over them
				glDepthMask(p_depth_pass || (!p_alpha_pass && !state.used_depth_prepass));
""" % MARK)
p.write_text(s, newline="\n")
print("patched:", p)
