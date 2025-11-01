#pragma language glsl3
uniform vec2 L;

vec4 position(mat4 transform_projection, vec4 vertex)
{
    // The order of operations matters when doing matrix multiplication.
    vec4 point = vec4(vertex.xy - vertex.z*L, 0.0, 1.0 - vertex.z);
    return transform_projection * point;
}
