#version 120

varying vec2 texture_coordinate1;

void main()
{
    gl_Position = gl_Vertex;
    texture_coordinate1 = vec2(gl_MultiTexCoord1);
}