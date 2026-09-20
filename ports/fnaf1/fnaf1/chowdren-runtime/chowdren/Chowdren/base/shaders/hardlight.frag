#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform sampler2D texture;
uniform sampler2D background_texture;

#define HARD(B, L) (L<0.5?(2.0*B*L):(1.0-2.0*(1.0-L)*(1.0-B)))

void main()
{
    vec4 B = texture2D(background_texture, texture_coordinate1);
    vec4 L = texture2D(texture, texture_coordinate0);
    vec4 blend;
    blend.r = HARD(B.r, L.r);
    blend.g = HARD(B.g, L.g);
    blend.b = HARD(B.b, L.b);
    blend.a = HARD(B.a, L.a);
    gl_FragColor = blend * gl_Color;
}