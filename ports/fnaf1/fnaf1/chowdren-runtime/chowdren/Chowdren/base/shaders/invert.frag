#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;

void main()
{
    vec4 col = texture2D(texture, texture_coordinate);
    col.rgb = vec3(1.0 - col.r, 1.0 - col.g, 1.0 - col.b);
    gl_FragColor = col;// * gl_Color;
}