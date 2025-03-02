/* MegaZeux
 *
 * Copyright (C) 2017 David (astral) Cravens (decravens@gmail.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * crt.frag - a fragment shader that generates scanlines, based on crt-pi from
 *            libretro and semisoft.frag
 */

#version 110

uniform sampler2D baseMap;

varying vec2 vTexcoord;

#define MASK_BRIGHTNESS 0.70
#define SCANLINE_WEIGHT 6.0
#define SCANLINE_GAP_BRIGHTNESS 0.12
#define BLOOM_FACTOR 1.5
#define INPUT_GAMMA 2.4
#define OUTPUT_GAMMA 2.2

#define XS 1024.0
#define YS 512.0
#define TS vec2(XS,YS)

float CalcScanLineWeight(float dist)
{
	return max(1.0-dist*dist*SCANLINE_WEIGHT, SCANLINE_GAP_BRIGHTNESS);
}

void main()
{
    vec2 texcoordInPixels = vTexcoord * TS;
    vec2 tempCoord = floor(texcoordInPixels) + 0.5;

    vec2 coord = tempCoord / TS;
    vec2 deltas = texcoordInPixels - tempCoord;
    float scanLineWeight = CalcScanLineWeight(deltas.y);

    vec2 tcbase = (tempCoord + 0.5)/TS;
    vec2 tcdiff = vTexcoord-tcbase;
    vec2 sdiff = sign(tcdiff);
    vec2 adiff = pow(abs(tcdiff)*TS, vec2(2.0));

    vec3 color = texture2D(baseMap, tcbase + sdiff*adiff/TS).rgb;

    color = pow(color, vec3(INPUT_GAMMA));

    scanLineWeight *= BLOOM_FACTOR;
    color *= scanLineWeight;

    color = pow(color, vec3(1.0/OUTPUT_GAMMA));

    float whichMask = fract(gl_FragCoord.x * 0.3333333);
    vec3 mask = vec3(MASK_BRIGHTNESS, MASK_BRIGHTNESS, MASK_BRIGHTNESS);
    if (whichMask < 0.3333333)
        mask.x = 1.0;
    else if (whichMask < 0.6666666)
        mask.y = 1.0;
    else
        mask.z = 1.0;

    gl_FragColor = vec4(color * mask, 1.0) * 1.75;
}
