#pragma language glsl3

uniform vec2 dir;

vec4 position(mat4 transform_projection, vec4 vertex)
{
    vec4 segment_point   = vec4(vertex.xy, 0.0, 1.0);
    vec4 projected_point = vec4(dir, 0.0, 0.0);

    vec4 current_point = segment_point*(vertex.z) + projected_point*(1.0 - vertex.z);

    return transform_projection * current_point;
}
