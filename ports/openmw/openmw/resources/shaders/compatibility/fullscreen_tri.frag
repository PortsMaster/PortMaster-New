#version 120

varying vec2 uv;

#include "lib/core/fragment.glsl"

void main()
{
    gl_FragColor = samplerLastShader(uv);
}