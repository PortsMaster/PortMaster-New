#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform sampler2D texture;
uniform sampler2D background_texture;

void main()
{
    vec4 b = texture2D(background_texture, texture_coordinate1);
    vec4 o = texture2D(texture, texture_coordinate0);
    gl_FragColor = b * o * gl_Color;
}