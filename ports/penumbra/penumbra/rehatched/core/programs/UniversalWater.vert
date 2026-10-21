// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Vertex func for the acid pools, which show the scene behind them distorted.
#version 410

layout(location = 0) in vec4 position;
layout(location = 3) in vec2 uv;

out vec2 oUV;

uniform mat4 worldViewProj;

void main() {
	gl_Position = worldViewProj * position;

	// refract_water_vp.cg also carried the normal, the direction to the eye and
	// the vertex colour. Its fragment program used none of the three - the
	// fresnel term that wanted them was commented out - so they are not carried
	// here either, and the pool is not tinted by vertex colour it never had.
	oUV = uv;
}
