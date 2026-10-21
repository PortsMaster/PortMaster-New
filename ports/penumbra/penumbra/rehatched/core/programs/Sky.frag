// Copyright (C) 2026 - Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Sky colour, optionally from a cube map.
#version 410

in vec3 oDir;

layout(location = 0) out vec4 fragColor;

uniform samplerCube skyMap;
uniform vec3 skyColor;
uniform float useTexture;

void main() {
	vec3 col = skyColor;
	// Most maps set only a colour; a few also hand over a cube map.
	if (useTexture > 0.5) col *= texture(skyMap, normalize(oDir)).rgb;
	fragColor = vec4(col, 1.0);
}
