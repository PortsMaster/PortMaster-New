// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// As Universal.frag, for surfaces that carry an illumination map.
#version 410

in vec4 oColor;
in vec2 oUV;

layout(location = 0) out vec4 fragColor;

uniform sampler2D diffuseMap;
uniform sampler2D illuminationMap;
uniform vec3 ambientColor;
uniform float alphaCutoff;

void main() {
	vec4 diffuse = texture(diffuseMap, oUV);
	if (diffuse.a < alphaCutoff) discard;

	vec3 ambient = diffuse.rgb * oColor.rgb * ambientColor;

	// A glowing part is its own light source: it is not dimmed by the ambient
	// term and owes nothing to the light passes. Without this the lamp flame
	// is simply black.
	vec3 glow = texture(illuminationMap, oUV).rgb;

	fragColor = vec4(ambient + glow, diffuse.a * oColor.a);
}
