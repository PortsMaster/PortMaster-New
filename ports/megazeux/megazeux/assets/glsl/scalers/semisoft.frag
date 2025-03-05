/* MegaZeux
 *
 * Copyright (C) 2017 GreaseMonkey
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

#version 110

uniform sampler2D baseMap;

varying vec2 vTexcoord;

#define XS 1024.0
#define YS 512.0
#define AX 0.5/XS
#define AY 0.5/YS

void main(void)
{
  vec2 tcbase = (floor(vTexcoord*vec2(XS, YS) + 0.5) + 0.5)/vec2(XS, YS);
  vec2 tcdiff = vTexcoord-tcbase;
  vec2 sdiff = sign(tcdiff);
  vec2 adiff = pow(abs(tcdiff)*vec2(XS, YS), vec2(3.0));
  gl_FragColor = texture2D(baseMap, tcbase + sdiff*adiff/vec2(XS, YS));
}
