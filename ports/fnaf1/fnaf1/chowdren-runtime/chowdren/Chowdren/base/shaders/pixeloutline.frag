#version 120

varying vec2 texture_coordinate;
uniform vec2 texture_size;
uniform sampler2D texture;

uniform vec4 color;

#define SET_SOLID(dir) \
            col.a = texture2D(texture, texture_coordinate + \
                              dir * texture_size).a; \
            if (col.a > 0.0) { \
                col.a *= gl_Color.a; \
                return col; \
            }

vec4 getter(vec4 src)
{
    if (src.a != 0.0)
        return src;
    vec4 col;
    col.rgb = color.rgb;
    SET_SOLID(vec2(1.0, 0.0))
    SET_SOLID(vec2(1.0, 1.0))
    SET_SOLID(vec2(0.0, 1.0))
    SET_SOLID(vec2(-1.0, 1.0))
    SET_SOLID(vec2(-1.0, 0.0))
    SET_SOLID(vec2(-1.0, -1.0))
    SET_SOLID(vec2(0.0, -1.0))
    SET_SOLID(vec2(1.0, -1.0))
    return src;
}

void main()
{
    vec4 src = texture2D(texture, texture_coordinate) * gl_Color;
    gl_FragColor = getter(src);
}
