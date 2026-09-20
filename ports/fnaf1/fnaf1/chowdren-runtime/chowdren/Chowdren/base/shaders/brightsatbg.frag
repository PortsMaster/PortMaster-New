#version 120

varying vec2 texture_coordinate1;
uniform sampler2D texture;
uniform sampler2D background_texture;
uniform float Brightness, Saturation;

void main()
{
    vec4 color = texture2D(background_texture, texture_coordinate1);
    float f = (color.r+color.g+color.b)/3.0;
    color.rgb = Brightness+f*(1.0-Saturation)+color.rgb * Saturation;
    gl_FragColor = color;
}
