#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform vec4 fC;
uniform float fFade;

void main()
{
    vec4 col = texture2D(texture, texture_coordinate) * gl_Color;
    col.rgb = col.rgb + (fC.rgb-col.rgb)*fFade;
    gl_FragColor = col;
}
