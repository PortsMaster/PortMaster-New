// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Fragment func for a surface that reflects its surroundings from a cube map.
#version 410

in vec4 oColor;
in vec2 oUV;
in vec3 oReflect;

layout(location = 0) out vec4 fragColor;

uniform sampler2D diffuseMap;
uniform samplerCube envMap;
uniform vec3 ambientColor;
uniform float alphaCutoff;

void main() {
	vec4 diffuse = texture(diffuseMap, oUV);
	if (diffuse.a < alphaCutoff) discard;

	vec3 reflection = texture(envMap, normalize(oReflect)).rgb;

	// Stronger where the surface is edge on, the way a real reflection behaves:
	// the ice shows the cave along a grazing line of sight and its own colour
	// when looked at straight down. The constants are a judgement, not data;
	// the original kept its reflection amount somewhere this port does not read.
	float fFacing = clamp(dot(normalize(oReflect), vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
	float fMix = mix(0.12, 0.45, 1.0 - fFacing);

	// Lit by the ambient term like everything else in this pass, or the ice
	// would glow in a cave with no light in it.
	vec3 lit = mix(diffuse.rgb, reflection, fMix) * oColor.rgb * ambientColor;

	fragColor = vec4(lit, diffuse.a * oColor.a);
}
