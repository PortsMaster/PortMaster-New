#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform float fX, fY;
uniform float fZoomX, fZoomY;
uniform float fWidth, fHeight;

void main()
{
    vec2 In = texture_coordinate;
    In.x = In.x + fZoomX*(fWidth-1.0) + fX;
    In.y = In.y + fZoomY*(fHeight-1.0) + fY;
    vec4 color = texture2D(texture, vec2(In.x/fWidth,In.y/fHeight));
    gl_FragColor = color * gl_Color;
}
