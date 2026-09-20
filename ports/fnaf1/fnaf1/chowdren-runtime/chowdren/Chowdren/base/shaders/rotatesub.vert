#version 120

varying vec2 texture_coordinate;

void main()
{
    gl_Position = gl_Vertex;
    gl_FrontColor = gl_Color;
    texture_coordinate = vec2(gl_MultiTexCoord0);
}