#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform sampler2D texture;
uniform sampler2D background_texture;
uniform float bgA;

#define OVERLAY(B, L) (B<0.5?(2.0*B*L):(1.0-2.0*(1.0-B)*(1.0-L)))

void main()
{
    vec4 B = texture2D(background_texture, texture_coordinate1);
    vec4 L = texture2D(texture, texture_coordinate0) * gl_Color;
    B.a = bgA;
    vec4 blend;
    blend.r = OVERLAY(B.r, L.r);
    blend.g = OVERLAY(B.g, L.g);
    blend.b = OVERLAY(B.b, L.b);
    blend.a = OVERLAY(B.a, L.a);
    gl_FragColor = blend;
}