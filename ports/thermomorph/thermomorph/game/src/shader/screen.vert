attribute float ZPositionAttribute;

varying vec2 numerator;
varying float denominator;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
    numerator = VertexTexCoord.xy / ZPositionAttribute;
    denominator = 1.0 / ZPositionAttribute;
    return transform_projection * vertex_position;
}
