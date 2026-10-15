// Based on HPL1 Rehatched by zenmumbler; changes copyright (C) 2026 -
// Omka1337, written with the help of Claude Code
// SPDX-License-Identifier: GPL-3.0-or-later
// Fragment func for font glyphs
#version 410

in vec4 oColor;
in vec2 oUV;

layout(location = 0) out vec4 fragColor;

uniform sampler2D image;

void main() {
	fragColor = texture(image, oUV);
	fragColor.a = fragColor.r;
	fragColor *= oColor;
}
