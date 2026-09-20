#version 120

uniform sampler2D texture;
varying vec2 texture_coordinate;
uniform float fBlur;
uniform float fAmplitudeX;
uniform float fPeriodsX;
uniform float fFreqX;
uniform float fAmplitudeY;
uniform float fPeriodsY;
uniform float fFreqY;

void main()
{
    // DEBUG: distortion stubbed out to test if this shader is the culprit
    gl_FragColor = texture2D(texture, texture_coordinate) * gl_Color;
}