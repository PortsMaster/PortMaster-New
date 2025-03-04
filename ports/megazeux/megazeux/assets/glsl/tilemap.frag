/* MegaZeux
 *
 * Copyright (C) 2008 Joel Bouchard Lamontagne <logicow@gmail.com>
 * Copyright (C) 2009 Alistair John Strachan <alistair@devzero.co.uk>
 * Copyright (C) 2017 Dr Lancer-X <drlancer@megazeux.org>
 * Copyright (C) 2018 Alice Rowan <petrifiedrowan@gmail.com>
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

// Keep these the same as in render_glsl.c
#define CHARSET_COLS      64.0
#define TEX_DATA_WIDTH    512.0
#define TEX_DATA_HEIGHT   1024.0
#define TEX_DATA_PAL_Y    896.0
#define TEX_DATA_LAYER_X  0.0
#define TEX_DATA_LAYER_Y  901.0

// This has to be slightly less than 14.0 to avoid propagating error
// with some very old driver/video card combos.
#define CHAR_H            13.99999

uniform sampler2D baseMap;

varying vec2 vTexcoord;

float fract_(float v)
{
  return clamp(fract(v + 0.001) - 0.001, 0.000, 0.999);
}

float floor_(float v)
{
  return floor(v + 0.001);
}

int int_(float v)
{
  return int(v + 0.01);
}

// NOTE: Layer data packing scheme
// (highest two bits currently unused but included as part of the char)
// w        z        y        x
// 00000000 00000000 00000000 00000000
// CCCCCCCC CCCCCCBB BBBBBBBF FFFFFFFF

// Some older cards/drivers tend o be slightly off; slight variations
// in values here are intentional.

/**
 * Get the char number from packed layer data as (approx.) an int.
 */

float layer_get_char(vec4 layer_data)
{
  return floor_(layer_data.z * 63.75) + (layer_data.w * 255.0) * 64.0;
}

/**
 * Get the foreground color from layer data relative to the texture width.
 */

float layer_get_fg_color(vec4 layer_data)
{
  return
   (layer_data.x * 255.001)               / TEX_DATA_WIDTH +
   fract_(layer_data.y * 127.501) * 512.0 / TEX_DATA_WIDTH;
}

/**
 * Get the background color from layer data relative to the texture width.
 */

float layer_get_bg_color(vec4 layer_data)
{
  return
   floor_(layer_data.y * 127.5)           / TEX_DATA_WIDTH +
   fract_(layer_data.z * 63.751) * 512.0  / TEX_DATA_WIDTH;
}

void main(void)
{
  /**
   * Get the packed char/color data for this position from the current layer.
   * vTexcoord will be provided in the range of x=[0..layer.w), y=[0..layer.h).
   */
  float layer_x = (vTexcoord.x + TEX_DATA_LAYER_X) / TEX_DATA_WIDTH;
  float layer_y = (vTexcoord.y + TEX_DATA_LAYER_Y) / TEX_DATA_HEIGHT;
  vec4 layer_data = texture2D(baseMap, vec2(layer_x, layer_y));

  /**
   * Get the current char and its base position in the texture charset.
   * The x position will be normalized to the width of the texture,
   * but for the y position it's easier to get the pixel position and
   * normalize afterward.
   */
  float char_num = layer_get_char(layer_data);
  float char_x = fract_(char_num / CHARSET_COLS);
  float char_y = floor_(char_num / CHARSET_COLS);

  /**
   * Get the current pixel value of the current char from the texture.
   */
  float char_tex_x = char_x + fract_(vTexcoord.x) / CHARSET_COLS;
  float char_tex_y = (char_y + fract_(vTexcoord.y)) * CHAR_H / TEX_DATA_HEIGHT;
  vec4 char_pix = texture2D(baseMap, vec2(char_tex_x, char_tex_y));

  /**
   * Determine whether this is the foreground or background color of the char,
   * get that color from the texture, and output it.
   */
  float color;

  // We could actually check any component here.
  if(char_pix.x > 0.5)
  {
    color = layer_get_fg_color(layer_data);
  }
  else
  {
    color = layer_get_bg_color(layer_data);
  }

  gl_FragColor = texture2D(baseMap,
   vec2(color, TEX_DATA_PAL_Y / TEX_DATA_HEIGHT));
}
