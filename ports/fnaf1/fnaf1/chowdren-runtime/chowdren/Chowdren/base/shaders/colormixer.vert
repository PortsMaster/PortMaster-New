#version 120

varying vec2 texture_coordinate;
varying float alpha;

void main()
{
    alpha = gl_Color.a;
    gl_Position = gl_Vertex;
    texture_coordinate = vec2(gl_MultiTexCoord0);
}