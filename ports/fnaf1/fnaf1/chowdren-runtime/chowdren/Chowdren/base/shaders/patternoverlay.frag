#version 120

varying vec2 texture_coordinate0;
uniform vec2 texture_size;
uniform sampler2D texture;
uniform sampler2D pattern;
uniform float x, y, alpha, width, height;

void main()
{
    vec2 In = texture_coordinate0;
    In /= texture_size;
    In += vec2(x, y);
    In /= vec2(width, height);
    vec4 p = texture2D(pattern, mod(In, 1.0)) * alpha;
    // XXX 100% undefined behaviour I think
    // gl_FragColor = p / vec4(0.0, 0.0, 0.0, 1.0);
}
