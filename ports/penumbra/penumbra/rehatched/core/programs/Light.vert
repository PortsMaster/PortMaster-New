// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Vertex func for one additive light pass over the scene
#version 410

layout(location = 0) in vec4 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec4 color;
layout(location = 3) in vec2 uv;
layout(location = 4) in vec4 tangent;

out vec3 oWorldPos;
out vec3 oLightVecTS;
out vec3 oEyeVecTS;
out vec4 oColor;
out vec2 oUV;

uniform mat4 worldViewProj;
uniform mat4 model;
uniform mat4 normalMatrix;
uniform vec3 lightPos;
uniform vec3 eyePos;

void main() {
	gl_Position = worldViewProj * position;

	vec3 worldPos = (model * position).xyz;
	oWorldPos = worldPos;

	// The light vector goes into tangent space here so the fragment can dot it
	// straight against the normal map, which is how the original did it
	// (Diffuse_Light_vp.cg). tangent.w carries the binormal's handedness.
	mat3 nm = mat3(normalMatrix);
	vec3 N = nm * normal;
	vec3 T = nm * tangent.xyz;
	vec3 B = cross(N, T) * tangent.w;

	vec3 toLight = lightPos - worldPos;
	oLightVecTS = vec3(dot(toLight, T), dot(toLight, B), dot(toLight, N));

	// The eye vector rides along in the same space so the fragment can build
	// the half-angle vector the specular shaders want. The original carried it
	// per vertex too (oHalfVec in BumpSpec2D_Light_vp.cg); it is summed with
	// the light vector in the fragment rather than here, because both have to
	// be normalised first and the light vector must stay unnormalised for the
	// attenuation term.
	vec3 toEye = eyePos - worldPos;
	oEyeVecTS = vec3(dot(toEye, T), dot(toEye, B), dot(toEye, N));

	oColor = color;
	oUV = uv;
}
