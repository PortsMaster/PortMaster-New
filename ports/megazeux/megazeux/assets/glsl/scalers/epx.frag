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

// vim:syntax=c:sts=3:sw=3:et:

// EPX scaler by GreaseMonkey
uniform sampler2D baseMap;

varying vec2 vTexcoord;

#define XS 1024.0
#define YS 512.0

void main(void)
{
  vec2 tcstepx = vec2(1.0/XS, 0.0);
  vec2 tcstepy = vec2(0.0, 1.0/YS);
  vec2 tcbase = (floor(vTexcoord*vec2(XS, YS)) + vec2(0.5, 0.5))/vec2(XS, YS);
  vec4 c0 = texture2D(baseMap, tcbase);
  vec4 c1 = texture2D(baseMap, tcbase-tcstepy);
  vec4 c2 = texture2D(baseMap, tcbase-tcstepx);
  vec4 c3 = texture2D(baseMap, tcbase+tcstepy);
  vec4 c4 = texture2D(baseMap, tcbase+tcstepx);
  vec4 final = c0;
  ivec2 subpos = ivec2(mod(vTexcoord*vec2(XS, YS)*2.0, 2.0));
  int subpos_i = subpos.x + (subpos.y*2);

  if(subpos_i == 0)
  {
    if(c1 == c2 && c1 != c3 && c1 != c4)
      final = c1;
  }
  else

  if(subpos_i == 2)
  {
    if(c2 == c3 && c2 != c4 && c2 != c1)
      final = c2;
  }
  else

  if(subpos_i == 3)
  {
    if(c3 == c4 && c3 != c1 && c3 != c2)
      final = c3;
  }
  else

  if(subpos_i == 1)
  {
    if(c4 == c1 && c4 != c2 && c4 != c3)
      final = c4;
  }

  gl_FragColor = final;
}
