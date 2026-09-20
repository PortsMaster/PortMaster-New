#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform sampler2D texture;
uniform sampler2D background_texture;
uniform float fBase, fCoeff;

void main()
{
    float height = fBase+texture2D(texture,texture_coordinate0).r*gl_Color.r*fCoeff;
    vec2 In = texture_coordinate1;
    In += (height-1.0)/2.0;
    gl_FragColor = texture2D(background_texture, mod(In / height, 1.0));
}
