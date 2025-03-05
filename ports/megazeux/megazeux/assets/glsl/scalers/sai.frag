/* MegaZeux
 *
 * Copyright (C) 2019 Alice Rowan <petrifiedrowan@gmail.com>
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

// This is adapted fairly closely from the 2xSaI C++ source code.
// Specifically, this is based on the "Scale 2xSaI" mode designed for an
// arbitrary destination size.
//
// 2xSaI is Copyright (c) 1999-2001 by Derek Liauw Kie Fa.
// 2xSaI is free under GPL. I hope you'll give me appropriate credit.
// If you want another license for your (free) project, contact me.
//
// The author confirmed in October 2009 that this means specifically GPL 2+.
// https://www.redhat.com/archives/fedora-legal-list/2009-October/msg00025.html

#version 110

uniform sampler2D baseMap;

varying vec2 vTexcoord;

// The mix() wrapper used here utilizes a sigmoid function to weigh the
// interpolation towards the closer source color. This is done to make this
// scaling method look better with MegaZeux-style graphics.
//
// A higher MULTIPLIER value produces sharper edges, but too high of a value
// will make things blocky. Comment out the SHARPEN_EDGES line to disable this
// (making this shader blurry but fairly accurate to the original Scale 2xSaI).

#define SHARPEN_EDGES     1
#define MULTIPLIER        10.0

#define TEX_SCREEN_WIDTH  1024.0
#define TEX_SCREEN_HEIGHT 512.0
#define PIXEL_X           1.0 / TEX_SCREEN_WIDTH
#define PIXEL_Y           1.0 / TEX_SCREEN_HEIGHT
#define HALF_PIXEL_X      0.5 / TEX_SCREEN_WIDTH
#define HALF_PIXEL_Y      0.5 / TEX_SCREEN_HEIGHT

vec4 _mix(vec4 A, vec4 B, float x)
{
#ifdef SHARPEN_EDGES
  x = (x - 0.5) * MULTIPLIER;
  x = 1.0 / (exp(-x) + 1.0);
#endif

  return mix(A, B, x);
}

void main(void)
{
  /**
   *   E F
   * G A B I
   * H C D J
   *   K L
   */

  vec4 A, B, C, D, E, F, G, H, I, J, K, L;

  float x = floor(vTexcoord.x * TEX_SCREEN_WIDTH) / TEX_SCREEN_WIDTH + HALF_PIXEL_X;
  float y = floor(vTexcoord.y * TEX_SCREEN_HEIGHT) / TEX_SCREEN_HEIGHT + HALF_PIXEL_Y;

  float x_fr = fract(vTexcoord.x * TEX_SCREEN_WIDTH);
  float y_fr = fract(vTexcoord.y * TEX_SCREEN_HEIGHT);
  float x_fr2;
  float y_fr2;
  float f1;
  float f2;
  vec4 res;

  A = texture2D(baseMap, vec2(x,                  y));
  B = texture2D(baseMap, vec2(x + PIXEL_X,        y));
  C = texture2D(baseMap, vec2(x,                  y + PIXEL_Y));
  D = texture2D(baseMap, vec2(x + PIXEL_X,        y + PIXEL_Y));

  if(A == B && C == D && A == C)
  {
    res = A;
  }
  else

  if(A == D && B != C)
  {
    E = texture2D(baseMap, vec2(x,                  y - PIXEL_Y));
    G = texture2D(baseMap, vec2(x - PIXEL_X,        y));
    L = texture2D(baseMap, vec2(x + PIXEL_X,        y + PIXEL_Y * 2.0));
    J = texture2D(baseMap, vec2(x + PIXEL_X * 2.0,  y + PIXEL_Y));

    f1 = x_fr / 2.0 + 0.25;
    f2 = y_fr / 2.0 + 0.25;

    if(y_fr <= f1 && A == J && A != E) // Close to B
      res = _mix(A, B, f1 - y_fr);

    else
    if(y_fr >= f1 && A == G && A != L) // Close to C
      res = _mix(A, C, y_fr - f1);

    else
    if(x_fr >= f2 && A == E && A != J) // Close to B
      res = _mix(A, B, x_fr - f2);

    else
    if(x_fr <= f2 && A == L && A != G) // Close to C
      res = _mix(A, C, f2 - x_fr);

    else
    if(y_fr >= x_fr) // Close to C
      res = _mix(A, C, y_fr - x_fr);

    else
    //if(y_fr <= x_fr) // Close to B
      res = _mix(A, B, x_fr - y_fr);
  }
  else

  if(B == C && A != D)
  {
    F = texture2D(baseMap, vec2(x + PIXEL_X,        y - PIXEL_Y));
    H = texture2D(baseMap, vec2(x - PIXEL_X,        y + PIXEL_Y));
    I = texture2D(baseMap, vec2(x + PIXEL_X * 2.0,  y));
    K = texture2D(baseMap, vec2(x,                  y + PIXEL_Y * 2.0));

    f1 = x_fr / 2.0 + 0.25;
    f2 = y_fr / 2.0 + 0.25;
    x_fr2 = 1.0 - x_fr;
    y_fr2 = 1.0 - y_fr;

    if(y_fr2 >= f1 && B == H && B != F) // Close to A
      res = _mix(B, A, y_fr2 - f1);

    else
    if(y_fr2 <= f1 && B == I && B != K) // Close to D
      res = _mix(B, D, f1 - y_fr2);

    else
    if(x_fr2 >= f2 && B == F && B != H) // Close to A
      res = _mix(B, A, x_fr2 - f2);

    else
    if(x_fr2 <= f2 && B == K && B != I) // Close to D
      res = _mix(B, D, f2 - x_fr2);

    else
    if(y_fr2 >= x_fr) // Close to A
      res = _mix(B, A, y_fr2 - x_fr);

    else
    //if(y_fr2 <= x_fr) // Close to D
      res = _mix(B, D, x_fr - y_fr2);
  }

  else
  {
    res = _mix(_mix(A, B, x_fr), _mix(C, D, x_fr), y_fr);
  }

  gl_FragColor = res;
}
