// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Full-screen sky pass; the view ray comes from the inverse view-projection.
#version 410

out vec3 oDir;

uniform mat4 invViewProj;

void main() {
	vec2 p = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
	vec2 ndc = p * 2.0 - 1.0;

	// z = 1 puts the sky on the far plane so everything else wins the depth test.
	gl_Position = vec4(ndc, 1.0, 1.0);

	vec4 far = invViewProj * vec4(ndc, 1.0, 1.0);
	vec4 near = invViewProj * vec4(ndc, -1.0, 1.0);
	oDir = far.xyz / far.w - near.xyz / near.w;
}
