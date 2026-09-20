#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform bool iR, iG, iB, iA;
uniform float fCoeff;

void main()
{
    vec4 col = texture2D(texture, texture_coordinate);
    vec4 texT = texture2D(texture, vec2(texture_coordinate.x,texture_coordinate.y-fCoeff));
    vec4 texTL = texture2D(texture, vec2(texture_coordinate.x-fCoeff,texture_coordinate.y-fCoeff));
    vec4 texL = texture2D(texture, vec2(texture_coordinate.x-fCoeff,texture_coordinate.y));
    vec4 texBL = texture2D(texture, vec2(texture_coordinate.x-fCoeff,texture_coordinate.y+fCoeff));
    vec4 texB = texture2D(texture, vec2(texture_coordinate.x,texture_coordinate.y+fCoeff));
    vec4 texBR = texture2D(texture, vec2(texture_coordinate.x+fCoeff,texture_coordinate.y+fCoeff));
    vec4 texR = texture2D(texture, vec2(texture_coordinate.x+fCoeff,texture_coordinate.y));
    vec4 texTR = texture2D(texture, vec2(texture_coordinate.x+fCoeff,texture_coordinate.y-fCoeff));
    if (iR)
        col.r = (col.r+texT.r+texTL.r+texL.r+texBL.r+texB.r+texBR.r+texR.r+texTR.r)/9.0;
    if(iG)
        col.g = (col.g+texT.g+texTL.g+texL.g+texBL.g+texB.g+texBR.g+texR.g+texTR.g)/9.0;
    if(iB)
        col.b = (col.b+texT.b+texTL.b+texL.b+texBL.b+texB.b+texBR.b+texR.b+texTR.b)/9.0;
    if(iA)
        col.a = (col.a+texT.a+texTL.a+texL.a+texBL.a+texB.a+texBR.a+texR.a+texTR.a)/9.0;
    gl_FragColor = col * gl_Color;
}