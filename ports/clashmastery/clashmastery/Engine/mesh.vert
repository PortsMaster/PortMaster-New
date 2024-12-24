uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

attribute vec3 VertexNormal; // declared in the vertexFormat
varying vec3 vertexNormal_out; // sending to fragment shader
varying vec3 fragPos;
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    vertexNormal_out = VertexNormal;
    fragPos = vec3(modelMatrix * vertex_position);
    return projectionMatrix * viewMatrix * modelMatrix * vertex_position;
}