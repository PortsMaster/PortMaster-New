
// Hyllian's xBRZ freescale multipass shader
//   - Adapted for use in Oxygen Engine
//  Copyright (C) 2018-2025 by Eukaryot
//
// This shader is derived from original "xbrz-freescale-pass1.glsl" from https://github.com/libretro/glsl-shaders/tree/master/xbrz/shaders/xbrz-freescale-multipass
// Used under GNU General Public License v2, see additional license info below.
//
// This file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with the this software.  If not, see <http://www.gnu.org/licenses/>.


// xBRZ freescale
// based on :

// 4xBRZ shader - Copyright (C) 2014-2016 DeSmuME team
//
// This file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with the this software.  If not, see <http://www.gnu.org/licenses/>.


/*
   Hyllian's xBR-vertex code and texel mapping

   Copyright (C) 2011/2016 Hyllian - sergiogdb@gmail.com
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:
   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
*/





## ----- Shared -------------------------------------------------------------------

#version 130

precision mediump float;
precision mediump int;



## ----- Vertex -------------------------------------------------------------------

in vec2 position;
out vec2 TEX0;

void main()
{
	gl_Position.x = position.x * 2.0 - 1.0;
	gl_Position.y = 1.0 - position.y * 2.0;
	gl_Position.z = 0.0;
	gl_Position.w = 1.0;
	TEX0.xy = position.xy * 1.0001;
}



## ----- Fragment -----------------------------------------------------------------

in vec2 TEX0;
out vec4 FragColor;

uniform vec2 GameResolution;
uniform vec2 OutputSize;
uniform sampler2D MainTexture;
uniform sampler2D OrigTexture;

#define SourceSize vec4(GameResolution, 1.0 / GameResolution)
#define OriginalSize vec4(GameResolution, 1.0 / GameResolution)
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

#define BLEND_NONE 0.
#define LUMINANCE_WEIGHT 1.0

float DistYCbCr(vec3 pixA, vec3 pixB)
{
	const vec3 w = vec3(0.2627, 0.6780, 0.0593);
	const float scaleB = 0.5 / (1.0 - w.b);
	const float scaleR = 0.5 / (1.0 - w.r);
	vec3 diff = pixA - pixB;
	float Y = dot(diff.rgb, w);
	float Cb = scaleB * (diff.b - Y);
	float Cr = scaleR * (diff.r - Y);
	return sqrt(((LUMINANCE_WEIGHT * Y) * (LUMINANCE_WEIGHT * Y)) + (Cb * Cb) + (Cr * Cr));
}

float get_left_ratio(vec2 center, vec2 origin, vec2 direction, vec2 scale)
{
	vec2 P0 = center - origin;
	vec2 proj = direction * (dot(P0, direction) / dot(direction, direction));
	vec2 distv = P0 - proj;
	vec2 orth = vec2(-direction.y, direction.x);
	float side = sign(dot(P0, orth));
	float v = side * length(distv * scale);
//	return step(0, v);
	return smoothstep(-sqrt(2.0)/2.0, sqrt(2.0)/2.0, v);
}

#define P(x,y) texture(OrigTexture, coord + OriginalSize.zw * vec2(x, y)).rgb

void main()
{
	//---------------------------------------
	// Input Pixel Mapping: -|B|-
	//                      D|E|F
	//                      -|H|-

	vec2 scale = OutputSize.xy * OriginalSize.zw;
	vec2 pos = fract(TEX0.xy * OriginalSize.xy) - vec2(0.5, 0.5);
	vec2 coord = TEX0.xy - pos * OriginalSize.zw;

	vec3 B = P( 0.,-1.);
	vec3 D = P(-1., 0.);
	vec3 E = P( 0., 0.);
	vec3 F = P( 1., 0.);
	vec3 H = P( 0., 1.);

	vec4 info = floor(texture(MainTexture, coord) * 255.0 + 0.5);

	// info Mapping: x|y|
	//               w|z|

	vec4 blendResult = floor(mod(info, 4.0));
	vec4 doLineBlend = floor(mod(info / 4.0, 4.0));
	vec4 haveShallowLine = floor(mod(info / 16.0, 4.0));
	vec4 haveSteepLine = floor(mod(info / 64.0, 4.0));

	vec3 res = E;

	// Pixel Tap Mapping: -|-|-
	//                    -|E|F
	//                    -|H|-
	if (blendResult.z > BLEND_NONE)
	{
		vec2 origin = vec2(0.0, 1.0 / sqrt(2.0));
		vec2 direction = vec2(1.0, -1.0);
		if (doLineBlend.z > 0.0)
		{
			origin = haveShallowLine.z > 0.0? vec2(0.0, 0.25) : vec2(0.0, 0.5);
			direction.x += haveShallowLine.z;
			direction.y -= haveSteepLine.z;
		}

		vec3 blendPix = mix(H,F, step(DistYCbCr(E, F), DistYCbCr(E, H)));
		res = mix(res, blendPix, get_left_ratio(pos, origin, direction, scale));
	}

	// Pixel Tap Mapping: -|-|-
	//                    D|E|-
	//                    -|H|-
	if (blendResult.w > BLEND_NONE)
	{
		vec2 origin = vec2(-1.0 / sqrt(2.0), 0.0);
		vec2 direction = vec2(1.0, 1.0);
		if (doLineBlend.w > 0.0)
		{
			origin = haveShallowLine.w > 0.0? vec2(-0.25, 0.0) : vec2(-0.5, 0.0);
			direction.y += haveShallowLine.w;
			direction.x += haveSteepLine.w;
		}

		vec3 blendPix = mix(H,D, step(DistYCbCr(E, D), DistYCbCr(E, H)));
		res = mix(res, blendPix, get_left_ratio(pos, origin, direction, scale));
	}

	// Pixel Tap Mapping: -|B|-
	//                    -|E|F
	//                    -|-|-
	if (blendResult.y > BLEND_NONE)
	{
		vec2 origin = vec2(1.0 / sqrt(2.0), 0.0);
		vec2 direction = vec2(-1.0, -1.0);

		if (doLineBlend.y > 0.0)
		{
			origin = haveShallowLine.y > 0.0? vec2(0.25, 0.0) : vec2(0.5, 0.0);
			direction.y -= haveShallowLine.y;
			direction.x -= haveSteepLine.y;
		}

		vec3 blendPix = mix(F,B, step(DistYCbCr(E, B), DistYCbCr(E, F)));
		res = mix(res, blendPix, get_left_ratio(pos, origin, direction, scale));
	}

	// Pixel Tap Mapping: -|B|-
	//                    D|E|-
	//                    -|-|-
	if (blendResult.x > BLEND_NONE)
	{
		vec2 origin = vec2(0.0, -1.0 / sqrt(2.0));
		vec2 direction = vec2(-1.0, 1.0);
		if (doLineBlend.x > 0.0)
		{
			origin = haveShallowLine.x > 0.0? vec2(0.0, -0.25) : vec2(0.0, -0.5);
			direction.x -= haveShallowLine.x;
			direction.y += haveSteepLine.x;
		}

		vec3 blendPix = mix(D,B, step(DistYCbCr(E, B), DistYCbCr(E, D)));
		res = mix(res, blendPix, get_left_ratio(pos, origin, direction, scale));
	}

	FragColor = vec4(res, 1.0);
}



## ----- TECH ---------------------------------------------------------------------

technique Standard
{
	blendfunc = opaque;
	vs = Shared + Vertex;
	fs = Shared + Fragment;
	vertexattrib[0] = position;
}
