#version 120

uniform sampler2D texture;

uniform float x_scale;
uniform float y_scale;
uniform float x_size, y_size;
varying vec2 texture_coordinate;

vec4 getter(vec2 tc)
{
    return texture2D(texture, tc);
}

void main()
{
    vec2 sz = vec2(x_size, y_size);
    vec3 step = vec3(1.0 / x_scale, 1.0 / y_scale, 0);
    vec2 pixel = sz * texture_coordinate + step.xy / 2.0;
    
    vec2 corner = floor(pixel) + 1.0;
    vec2 frac = min((corner - pixel) * vec2(x_scale, y_scale),
                    vec2(1.0, 1.0));

    vec4 c1 = texture2D(texture, (floor(pixel + step.zz) + vec2(0.5)) / sz);
    vec4 c2 = texture2D(texture, (floor(pixel + step.xz) + vec2(0.5)) / sz);
    vec4 c3 = texture2D(texture, (floor(pixel + step.zy) + vec2(0.5)) / sz);
    vec4 c4 = texture2D(texture, (floor(pixel + step.xy) + vec2(0.5)) / sz);
    
    c1 *=        frac.x  *        frac.y;
    c2 *= (1.0 - frac.x) *        frac.y;
    c3 *=        frac.x  * (1.0 - frac.y);
    c4 *= (1.0 - frac.x) * (1.0 - frac.y);
    
    gl_FragColor = gl_Color * (c1 + c2 + c3 + c4);
}
