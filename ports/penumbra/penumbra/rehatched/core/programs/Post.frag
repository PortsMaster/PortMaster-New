// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Resolves the off-screen scene to the back buffer.
#version 410

in vec2 oUV;

layout(location = 0) out vec4 fragColor;

uniform sampler2D sceneMap;
uniform float invGamma;
uniform float bloomAmount;
uniform vec2 texelSize;

// Only what is already bright blooms, and it fades in rather than switching on
// at a hard threshold, which would crawl along moving edges.
vec3 BrightPass(vec3 c) {
	float l = max(max(c.r, c.g), c.b);
	return c * smoothstep(0.5, 1.1, l);
}

void main() {
	vec3 scene = texture(sceneMap, oUV).rgb;

	vec3 bloom = vec3(0.0);
	if (bloomAmount > 0.0) {
		// A spiral of taps rather than a separate downsample and blur: one pass,
		// no extra targets. Coarser than the original's two-pass blur, but it
		// spreads light the same way.
		//
		// Eight taps, not sixteen. Each one is a scattered read from a
		// half-float target, which is the most expensive thing this renderer
		// asks of a Mali-G31: sixteen taps held the cabin at 14.8 fps and eight
		// at 19.6, against 21.9 with no bloom at all. Gathering from a
		// mipmapped level instead was tried and came out slower, because
		// building the chain every frame costs more than the cache misses it
		// saves.
		const int TAPS = 8;
		const float GOLDEN = 2.39996;
		for (int i = 0; i < TAPS; ++i) {
			float a = GOLDEN * float(i);
			float r = sqrt(float(i + 1) / float(TAPS)) * 22.0;
			vec2 off = vec2(cos(a), sin(a)) * r * texelSize;
			bloom += BrightPass(texture(sceneMap, oUV + off).rgb);
		}
		bloom /= float(TAPS);
	}

	vec3 col = scene + bloom * bloomAmount;
	fragColor = vec4(pow(max(col, 0.0), vec3(invGamma)), 1.0);
}
