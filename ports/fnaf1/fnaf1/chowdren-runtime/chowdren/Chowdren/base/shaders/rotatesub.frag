#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform float fA;
uniform float fX;
uniform float fY;
uniform float fSx;
uniform float fSy;

void main()
{
    vec2 coord = texture_coordinate;
    coord.x -= fSx;
    coord.y -= fSy;
    float x = fX + 0.5;
    float y = fY + 0.5;
    float a = fA * 0.0174532925;
    float xx = coord.x - x;
    float yy = coord.y - y;
    float Ray = sqrt(xx*xx + yy*yy);
    float Angle;
    if(coord.y-y>0.0)
        Angle = acos((coord.x-x)/Ray);
    else
        Angle = 0.0-acos((coord.x-x)/Ray);

    coord.x = x + cos(Angle+a)*Ray;
    coord.y = y + sin(Angle+a)*Ray;

    vec4 col;
    if (coord.x >= 0.0 && coord.x <= 1.0 && coord.y >= 0.0 && coord.y <= 1.0)
        col = texture2D(texture, coord);
    else
        col = vec4(0.0);

    gl_FragColor = col * gl_Color;
}
