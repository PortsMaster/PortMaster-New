#version 120

varying vec2 texture_coordinate;
varying float alpha;
uniform vec4 r, g, b;
uniform sampler2D texture;

void main()
{
    vec4 i = texture2D(texture, texture_coordinate);
    vec4 col;
    col.a = i.a * alpha;
    col.rgb = r.rgb*i.r + g.rgb*i.g + b.rgb*i.b;
    gl_FragColor = col;
}