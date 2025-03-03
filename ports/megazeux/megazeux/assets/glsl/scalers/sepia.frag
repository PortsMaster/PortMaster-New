/* MegaZeux
 *
 * Copyright (C) 2008 Joel Bouchard Lamontagne <logicow@gmail.com>
 * Copyright (C) 2009 Alistair John Strachan <alistair@devzero.co.uk>
 * Copyright (C) 2017 Alice Rowan <petrifiedrowan@gmail.com>
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

/* Sepia scaling shader based on simple.frag */

uniform sampler2D baseMap;

varying vec2 vTexcoord;

void main(void)
{
  const vec4 r_weight = vec4(0.393, 0.769, 0.189, 0);
  const vec4 g_weight = vec4(0.349, 0.686, 0.168, 0);
  const vec4 b_weight = vec4(0.272, 0.534, 0.131, 0);

  vec4 color = texture2D(baseMap, vTexcoord);

  gl_FragColor = vec4(
    min(1.0, dot(color, r_weight)),
    min(1.0, dot(color, g_weight)),
    min(1.0, dot(color, b_weight)),
    1.0
  );
}
