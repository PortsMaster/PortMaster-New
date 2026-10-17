// Based on HPL1 Rehatched by zenmumbler; changes copyright (C) 2026 -
// Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Vertex func for Pre-Z pass
#version 410

layout(location = 0) in vec4 position;

uniform mat4 worldViewProj;

void main() {
	gl_Position = worldViewProj * position;
}
