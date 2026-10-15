// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Vertex func for a surface that reflects its surroundings from a cube map.
#version 410

layout(location = 0) in vec4 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec4 color;
layout(location = 3) in vec2 uv;

out vec4 oColor;
out vec2 oUV;
out vec3 oReflect;

uniform mat4 worldViewProj;
uniform mat4 model;
uniform mat4 normalMatrix;
uniform vec3 eyePos;

void main() {
	gl_Position = worldViewProj * position;

	// The reflection is worked out in world space, because that is the space
	// the cube map was rendered in. This is what Diffuse_EnvMap_Reflect_vp.cg
	// did: bounce the direction the eye is looking off the surface normal, and
	// let the fragment look that way in the cube.
	vec3 worldPos = (model * position).xyz;
	vec3 worldNormal = normalize(mat3(normalMatrix) * normal);

	oReflect = reflect(worldPos - eyePos, worldNormal);

	oColor = color;
	oUV = uv;
}
