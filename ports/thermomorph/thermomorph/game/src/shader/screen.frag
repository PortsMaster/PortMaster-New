varying vec2 numerator;
varying float denominator;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texcolor = Texel(texture, numerator / denominator);
    return texcolor * color;
}
