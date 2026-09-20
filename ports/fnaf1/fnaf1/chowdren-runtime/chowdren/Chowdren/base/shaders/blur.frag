#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform vec2 texture_size;
uniform float radius;

#define ACCUM(offset) o += texture2D(texture, texture_coordinate + coeff * offset)

void main()
{
    vec2 coeff = radius * texture_size;
    vec4 o = texture2D(texture, texture_coordinate);
    ACCUM(vec2(1, -0));
    ACCUM(vec2(0.489074, -0.103956));
    ACCUM(vec2(0.913545, -0.406737));
    ACCUM(vec2(0.404509, -0.293893));
    ACCUM(vec2(0.669131, -0.743145));
    ACCUM(vec2(0.25, -0.433013));
    ACCUM(vec2(0.309017, -0.951057));
    ACCUM(vec2(0.0522642, -0.497261));
    ACCUM(vec2(-0.104529, -0.994522));
    ACCUM(vec2(-0.154509, -0.475528));
    ACCUM(vec2(-0.5, -0.866025));
    ACCUM(vec2(-0.334565, -0.371572));
    ACCUM(vec2(-0.809017, -0.587785));
    ACCUM(vec2(-0.456773, -0.203368));
    ACCUM(vec2(-0.978148, -0.207912));
    ACCUM(vec2(-0.5, -0));
    ACCUM(vec2(-0.978148, 0.207912));
    ACCUM(vec2(-0.456773, 0.203368));
    ACCUM(vec2(-0.809017, 0.587786));
    ACCUM(vec2(-0.334565, 0.371572));
    ACCUM(vec2(-0.5, 0.866025));
    ACCUM(vec2(-0.154509, 0.475528));
    ACCUM(vec2(-0.104528, 0.994522));
    ACCUM(vec2(0.0522642, 0.497261));
    ACCUM(vec2(0.309017, 0.951056));
    ACCUM(vec2(0.25, 0.433013));
    ACCUM(vec2(0.669131, 0.743145));
    ACCUM(vec2(0.404508, 0.293893));
    ACCUM(vec2(0.913546, 0.406736));
    ACCUM(vec2(0.489074, 0.103956));
    o /= 31.0;
    o.a *= gl_Color.a;
    gl_FragColor = o;
}