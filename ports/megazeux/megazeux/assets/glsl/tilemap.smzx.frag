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

uniform sampler2D baseMap;

varying vec2 vTexcoord;

// Keep these the same as in render_glsl.c
#define CHARSET_COLS      64.0
#define TEX_DATA_WIDTH    512.0
#define TEX_DATA_HEIGHT   1024.0
#define TEX_DATA_PAL_Y    896.0
#define TEX_DATA_IDX_Y    897.0
#define TEX_DATA_LAYER_X  0.0
#define TEX_DATA_LAYER_Y  901.0

#define COLOR_TRANSPARENT (272.0 - 0.001)
#define PIXEL_X           1.0 / TEX_DATA_WIDTH

// This has to be slightly less than 14.0 to avoid propagating error
// with some very old driver/video card combos.
#define CHAR_W            8.0
#define CHAR_H            13.99999
#define CHAR_W_I          8
#define CHAR_H_I          14

float fract_(float v)
{
  return clamp(fract(v + 0.001) - 0.001, 0.000, 0.999);
}

float floor_(float v)
{
  return floor(v + 0.001);
}

float mod_(float v, float r)
{
  return clamp(mod(v + 0.01, r) - 0.01, 0.0, r);
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

// Some older cards/drivers tend to be slightly off; slight variations
// in values here are intentional.

/**
 * Get the char number from packed layer data as (approx.) an int.
 */

float layer_get_char(vec4 layer_data)
{
  return floor_(layer_data.z * 63.75) + (layer_data.w * 255.0) * 64.0;
}

/**
 * Get the foreground color from layer data as (approx.) an int.
 */

float layer_get_fg_color(vec4 layer_data)
{
  return
   (layer_data.x * 255.001) +
   fract_(layer_data.y * 127.501) * 512.0;
}

/**
 * Get the background color from layer data as (approx.) an int.
 */

float layer_get_bg_color(vec4 layer_data)
{
  return
   floor_(layer_data.y * 127.5) +
   fract_(layer_data.z * 63.751) * 512.0;
}

void main( void )
{
  /**
   * Get the packed char/color data for this position from the current layer.
   * vTexcoord will be provided in the range of x=[0..layer.w), y=[0..layer.h).
   */
  float layer_x = (vTexcoord.x + TEX_DATA_LAYER_X) / TEX_DATA_WIDTH;
  float layer_y = (vTexcoord.y + TEX_DATA_LAYER_Y) / TEX_DATA_HEIGHT;
  vec4 layer_data = texture2D(baseMap, vec2(layer_x, layer_y));

  float fg_color = layer_get_fg_color(layer_data);
  float bg_color = layer_get_bg_color(layer_data);

  if(fg_color >= COLOR_TRANSPARENT || bg_color >= COLOR_TRANSPARENT)
  {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  }
  else
  {
    /**
     * The math in this shader is more complex than the math in the regular
     * shader, so it's handled partly in integers instead of floats. Older cards
     * seem less bad at calculating ints than floats (albeit slower too).
     *
     * Get the current char and:
     *
     * 1) determine the pixel position in the char we should be looking at.
     * We're considering pairs of two pixels horizontally adjacent, so get
     * the position of the left pixel in the pair specifically.
     *
     * 2) Calculate the position on the texture in pixel scale where the
     * current char is and add the offset from step 1.
     */
    float char_num = layer_get_char(layer_data);

    int px = int_(fract_(vTexcoord.x) * CHAR_W) / 2 * 2;
    int py = int_(fract_(vTexcoord.y) * CHAR_H);

    int char_x = int_(mod_(char_num, CHARSET_COLS) * CHAR_W) + px;
    int char_y = int_(char_num / CHARSET_COLS) * CHAR_H_I + py;

    /**
     * Get the current pixels of the current char from the texture.
     * Together, these determine which color of the current subpalette to use.
     */
    float char_tex_x = float(char_x) / TEX_DATA_WIDTH;
    float char_tex_y = float(char_y) / TEX_DATA_HEIGHT;

    vec4 char_pix_l = texture2D(baseMap, vec2(char_tex_x, char_tex_y));
    vec4 char_pix_r = texture2D(baseMap, vec2(char_tex_x + PIXEL_X, char_tex_y));

    /**
     * Determine the SMZX subpalette and SMZX index of the current pixel,
     * get that color from the texture, and output it.
     */

    int smzx_col;

    // We could actually check any component here.
    if(char_pix_l.x < 0.5)
    {
      if(char_pix_r.x < 0.5)
      {
        smzx_col = 0;
      }
      else
      {
        smzx_col = 1;
      }
    }
    else
    {
      if(char_pix_r.x < 0.5)
      {
        smzx_col = 2;
      }
      else
      {
        smzx_col = 3;
      }
    }

    float subpal = mod_(floor_(bg_color), 16.0) * 16.0 + mod_(fg_color, 16.0);

    float smzx_tex_x = subpal / TEX_DATA_WIDTH;
    float smzx_tex_y = (float(smzx_col) + TEX_DATA_IDX_Y) / TEX_DATA_HEIGHT;

    // NOTE: This must use the x component.
    float real_col = texture2D(baseMap, vec2(smzx_tex_x, smzx_tex_y)).x * 255.001;

    gl_FragColor = texture2D(baseMap,
     vec2(real_col / TEX_DATA_WIDTH, TEX_DATA_PAL_Y / TEX_DATA_HEIGHT));
  }
}
