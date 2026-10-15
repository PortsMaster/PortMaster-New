// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Full-screen triangle; the vertices come from gl_VertexID, no buffer needed.
#version 410

out vec2 oUV;

void main() {
	vec2 p = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
	oUV = p;
	gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}
