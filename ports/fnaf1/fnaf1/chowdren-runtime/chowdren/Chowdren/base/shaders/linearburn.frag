#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform vec2 texture_size;
uniform sampler2D texture;
uniform sampler2D background_texture;

void main()
{
    vec4 c = clamp(texture2D(texture, texture_coordinate0) * gl_Color +
                   texture2D(background_texture, texture_coordinate1) -
                   vec4(1.0), 0.0, 1.0);
    gl_FragColor = c;
}
