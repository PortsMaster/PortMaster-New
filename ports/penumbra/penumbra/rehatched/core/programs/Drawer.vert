// Based on HPL1 Rehatched by zenmumbler; changes copyright (C) 2026 -
// Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Vertex func for GraphicsDrawer objects
#version 410

layout(location = 0) in vec3 position;
layout(location = 2) in vec4 color;
layout(location = 3) in vec2 uv;

out vec4 oColor;
out vec2 oUV;

uniform mat4 projection;

void main() {
	gl_Position = projection * vec4(position.xy, 0, 1);
	oColor = color;
	oUV = uv;
}
