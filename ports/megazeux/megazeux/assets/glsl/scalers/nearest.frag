/* MegaZeux
 *
 * Copyright (C) 2008 Joel Bouchard Lamontagne <logicow@gmail.com>
 * Copyright (C) 2009 Alistair John Strachan <alistair@devzero.co.uk>
 * Copyright (C) 2017 Dr Lancer-X <drlancer@megazeux.org>
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

#define TEX_SCREEN_WIDTH  1024.0
#define TEX_SCREEN_HEIGHT 512.0
#define HALF_PIXEL_X      0.5 / TEX_SCREEN_WIDTH
#define HALF_PIXEL_Y      0.5 / TEX_SCREEN_HEIGHT

void main(void)
{
  vec2 src = vec2(
    floor(vTexcoord.x * TEX_SCREEN_WIDTH) / TEX_SCREEN_WIDTH + HALF_PIXEL_X,
    floor(vTexcoord.y * TEX_SCREEN_HEIGHT) / TEX_SCREEN_HEIGHT + HALF_PIXEL_Y
  );

  gl_FragColor = texture2D(baseMap, src);
}
