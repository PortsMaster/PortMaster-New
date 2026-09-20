#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform vec2 texture_size;
uniform float width;
uniform float height;
uniform sampler2D texture;
uniform sampler2D background_texture;

void main()
{
    vec4 shift = texture2D(texture, texture_coordinate0);
    vec2 off = vec2(width * texture_size.x, height * texture_size.y);
    off.x *= 2.0 * (shift.r-0.5);
    off.y *= 2.0 * (shift.g-0.5);
    gl_FragColor = texture2D(background_texture, texture_coordinate1+off);
}
