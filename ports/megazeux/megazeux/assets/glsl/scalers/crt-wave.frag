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
 * crt-wave.frag - a fragment shader that generates scanlines with a sine wave
 *                 based on semisoft.frag
 *
 * settings:
 *     DARKEN         - how dark the gaps get
 *     BOOST          - how bright the scanlines are
 *     SCAN_FREQUENCY - how rapidly down Y the wave oscillates
 */

#version 110

uniform sampler2D baseMap;
varying vec2 vTexcoord;

#define XS 1024.0
#define YS 512.0
#define AX 0.5/XS
#define AY 0.5/YS

#define TS vec2(XS, YS)

// -- settings ---------------
#define DARKEN 0.8
#define BOOST 1.4
#define SCAN_FREQUENCY 3.0
// ---------------------------

#define HALFERS ((BOOST - DARKEN) * 0.5)

float calc_scanline( float y )
{
    return DARKEN + HALFERS + sin(2.0*3.14*y/SCAN_FREQUENCY) * HALFERS;
}

void main( void )
{
    vec2 tcbase = (floor(vTexcoord * TS + 0.5) + 0.5) / TS;
    vec2 tcdiff = vTexcoord - tcbase;
    vec2 sdiff = sign(tcdiff);
    vec2 adiff = pow(abs(tcdiff) * TS, vec2(3.0));

    gl_FragColor = texture2D(baseMap, tcbase + sdiff * adiff / TS) * calc_scanline(gl_FragCoord.y);
}
