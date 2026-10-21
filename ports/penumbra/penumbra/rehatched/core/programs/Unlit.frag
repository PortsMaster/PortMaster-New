// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Blended surfaces: halos, light shafts, smoke. These emit rather than receive,
// so the ambient term must not scale them (matches Diffuse_Color_fp.cg).
#version 410

in vec4 oColor;
in vec2 oUV;

layout(location = 0) out vec4 fragColor;

uniform sampler2D diffuseMap;
uniform float alphaCutoff;

void main() {
	vec4 diffuse = texture(diffuseMap, oUV);
	if (diffuse.a < alphaCutoff) discard;

	fragColor = diffuse * oColor;
}
