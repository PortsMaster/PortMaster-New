uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

attribute vec3 VertexNormal; // declared in the vertexFormat
attribute vec4 VertexJoint;
attribute vec4 VertexJointWeights;

uniform mat4 jointMatrices[24]; // we probably won't have more than 24 bones right?

varying vec3 vertexNormal_out; // sending to fragment shader
varying vec3 fragPos;
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    vertexNormal_out = VertexNormal;
    // https://github.khronos.org/glTF-Tutorials/gltfTutorial/gltfTutorial_020_Skins.html
    mat4 skinMat = 
        VertexJointWeights.x * jointMatrices[int(VertexJoint.x)] +
        VertexJointWeights.y * jointMatrices[int(VertexJoint.y)] +
        VertexJointWeights.z * jointMatrices[int(VertexJoint.z)] +
        VertexJointWeights.w * jointMatrices[int(VertexJoint.w)];

    vec4 transformedVertPosition = skinMat * vertex_position;
    // Our GLTF models appear flipped horizontally, so we can just unflip it here
    transformedVertPosition.z = -transformedVertPosition.z;

    fragPos = vec3(modelMatrix * transformedVertPosition);
    return projectionMatrix * viewMatrix * modelMatrix * transformedVertPosition;
}