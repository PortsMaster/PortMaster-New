/*
   4xGLSLHqFilter shader

   Copyright (C) 2005 guest(r) - guest.r@gmail.com

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#version 110

attribute vec2 Position;
attribute vec2 Texcoord;

varying vec2 vTexcoord;

varying vec4 vT1;
varying vec4 vT2;
varying vec4 vT3;
varying vec4 vT4;
varying vec4 vT5;
varying vec4 vT6;

#define XS 1024.0
#define YS 512.0

void main(void)
{
    float x = 0.5 * (1.0 / XS);
    float y = 0.5 * (1.0 / YS);
    vec2 dg1 = vec2(x, y);
    vec2 dg2 = vec2(-x, y);
    vec2 sd1 = dg1*0.5;
    vec2 sd2 = dg2*0.5;
    vec2 ddx = vec2(x,0.0);
    vec2 ddy = vec2(0.0,y);

    gl_Position = vec4(Position.x, Position.y, 0.0, 1.0);
    vTexcoord = Texcoord;

    vT1 = vec4(vTexcoord-sd1,vTexcoord-ddy);
    vT2 = vec4(vTexcoord-sd2,vTexcoord+ddx);
    vT3 = vec4(vTexcoord+sd1,vTexcoord+ddy);
    vT4 = vec4(vTexcoord+sd2,vTexcoord-ddx);
    vT5 = vec4(vTexcoord-dg1,vTexcoord-dg2);
    vT6 = vec4(vTexcoord+dg1,vTexcoord+dg2);
}
