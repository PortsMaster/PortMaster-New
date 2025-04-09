varying vec3 vertexNormal_out; // given from the vertex shader
varying vec3 fragPos; // given from vertex shader
vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 texcolor = Texel(tex, vec2(texcoord.x, 1.0-texcoord.y));
    if (texcolor.a == 0.0) { discard; }
    return vec4(texcolor)*color;
}
