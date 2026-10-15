// Based on HPL1 Rehatched by zenmumbler; changes copyright (C) 2026 -
// Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Fragment func for all purpose 3D scene drawing
#version 410

in vec4 oColor;
in vec2 oUV;

layout(location = 0) out vec4 fragColor;

uniform sampler2D diffuseMap;
uniform vec3 ambientColor;

// Alpha below this is cut away. Blended materials pass 0 to switch the test
// off, so their soft edges are not chopped into a hard outline.
uniform float alphaCutoff;

void main() {
	vec4 diffuse = texture(diffuseMap, oUV);
	if (diffuse.a < alphaCutoff) discard;

	// This is the ambient term only - every light adds its own pass on top.
	fragColor = vec4(diffuse.rgb * oColor.rgb * ambientColor, diffuse.a * oColor.a);
}
