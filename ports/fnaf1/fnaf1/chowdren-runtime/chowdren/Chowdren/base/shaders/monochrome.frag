#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;

void main()
{
    vec4 col = texture2D(texture, texture_coordinate);
    col *= vec4(0.299, 0.587, 0.114, 1.0);
    col.rgb = vec3(col.r+col.g+col.b);
    gl_FragColor = col * gl_Color;
}