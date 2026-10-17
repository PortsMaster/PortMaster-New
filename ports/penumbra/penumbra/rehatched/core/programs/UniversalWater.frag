// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Fragment func for the acid pools, following refract_water_fp.cg.
#version 410

in vec2 oUV;

layout(location = 0) out vec4 fragColor;

uniform sampler2D diffuseMap;	// the colour of the liquid
uniform sampler2D refractMap;	// a wave map, read twice at different speeds
uniform sampler2D screenMap;	// a copy of the scene, taken before this pass

uniform vec2 screenSize;
uniform float scale;	// how far the surface pulls the scene sideways, in pixels
uniform float t;		// seconds, so the waves move

void main() {
	// Two wave maps crossing at different speeds and scales, one of them
	// reversed. One alone reads as a sheet of plastic sliding past; the two
	// together never quite repeat.
	vec2 uv1 = oUV;
	uv1.x += sin(t *  0.8 + oUV.y * 10.0) * 0.04;
	uv1.y += sin(t *  0.8 + uv1.x * 10.0) * 0.04;

	vec2 uv2 = oUV;
	uv2.x += sin(t * -2.6 + oUV.y * 12.0) * 0.03;
	uv2.y += sin(t * -2.6 + uv2.x * 12.0) * 0.03;

	vec3 offset1 = texture(refractMap, uv1).xyz * 2.0 - 1.0;
	vec3 offset2 = texture(refractMap, uv2).xyz * 2.0 - 1.0;
	offset2.xy = -offset2.xy;

	vec3 offset = offset1 * 0.7 + offset2 * 0.3;

	// A wave map that is flat exactly here sums to nothing, and normalising
	// that gives every channel a NaN, which comes out as a hole in the pool.
	// The original shader took the risk; one comparison is cheaper than the
	// bug report.
	float fLen = length(offset);
	offset = fLen > 0.0001 ? offset / fLen : vec3(0.0, 0.0, 1.0);

	// What the pool shows is the scene behind it, sampled a little to the side
	// of this fragment, tinted by the colour of the liquid.
	vec2 screenUV = (gl_FragCoord.xy - offset.xy * scale) / screenSize;
	vec3 scene = texture(screenMap, screenUV).rgb;

	vec3 color = scene * texture(diffuseMap, uv1).rgb;

	// The slope of the wave both shades the surface and, where it faces the
	// right way, glints. The eighth power keeps the glint to the crests, and
	// going over 1.0 is deliberate: the bloom pass turns it into a sparkle.
	float fSlope = clamp(dot(vec3(1.0 / 3.0), offset), 0.0, 1.0);
	color *= fSlope * 0.5 + 0.5;
	color += pow(fSlope, 8.0) * 5.0;

	fragColor = vec4(color, 1.0);
}
