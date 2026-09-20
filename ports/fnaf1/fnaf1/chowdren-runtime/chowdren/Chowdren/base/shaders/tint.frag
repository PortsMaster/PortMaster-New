#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform float fTintPower, fOriginalPower;
uniform vec4 fTintColor;

void main()
{
    vec4 col = texture2D(texture, texture_coordinate);
    col.rgb = col.rgb * (fOriginalPower + fTintColor.rgb*fTintPower);
    gl_FragColor = col * gl_Color;
}
