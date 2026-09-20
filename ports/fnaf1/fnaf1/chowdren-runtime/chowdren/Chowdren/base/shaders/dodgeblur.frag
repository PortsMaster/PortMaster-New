#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform vec2 texture_size;
uniform sampler2D texture;
uniform sampler2D background_texture;
uniform bool vertical;
uniform float radius;

#define iterations 28

void main()
{
    vec4 b = vec4(0.0);
    vec4 b2 = texture2D(background_texture, texture_coordinate1);
    vec4 o = texture2D(texture, texture_coordinate0);
    vec2 coeff;
    if (vertical)
        coeff = vec2(0, texture_size.y*radius);
    else
        coeff = vec2(texture_size.x*radius, 0);
    vec4 temp;
    for (int i = 0; i < iterations; i++) {
        vec2 val = texture_coordinate1+coeff*2.0*(float(i)/(float(iterations)-1.0) - 0.5);
        temp = texture2D(background_texture, clamp(val, 0.0, 0.9999));
        b += max(temp, b2);
    }
    b /= float(iterations);
    if (o != vec4(1.0))
        o = clamp(b/(1.0-o), 0.0, 1.0);
    o.a = 1.0;
    gl_FragColor = o;
}