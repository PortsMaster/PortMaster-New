#version 120

varying vec2 texture_coordinate;
uniform float fPeriods;
uniform float fOffset;
uniform float fAmplitude;
uniform sampler2D texture;

void main()
{
    // DEBUG: distortion stubbed out to test if this shader is the culprit
    gl_FragColor = texture2D(texture, texture_coordinate) * gl_Color;
}
