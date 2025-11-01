#pragma language glsl3

uniform float time;
uniform vec2 shockwave_origin;

#define resWidth 320.0
#define resHeight 180.0
#define shockwave_width 0.05
#define distortion_target_distance 2.0 // in pixels

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    vec2 stretchFactor = vec2(1.0, resHeight / resWidth);
    vec2 center = shockwave_origin / vec2(resWidth, resHeight);
    center = 2.0*(center - 0.5) * stretchFactor;
    vec2 center_uvs = 2.0*(uvs - 0.5) * stretchFactor;
    float dist = length(center_uvs - center);

    float shockwave_distance = time * 0.5;

    float inner_mask = step(shockwave_distance, dist);
    float outer_mask = 1.0 - step(shockwave_distance + shockwave_width, dist);
    float max_distance_mask = 1.0 - smoothstep(0.1, 0.6, dist);
    float shockwave_mask = inner_mask*outer_mask*max_distance_mask;

    vec2 center_coords = screen_coords - vec2(resWidth, resHeight)*0.5;
    vec2 normal = center_coords / length(center_coords);
    vec2 target_coords = center_coords - normal*distortion_target_distance;
    vec2 target_uvs = (target_coords + vec2(resWidth, resHeight)*0.5) / vec2(resWidth, resHeight);

    vec3 pixel = Texel(t, uvs).xyz;
    vec3 target_pixel = Texel(t, target_uvs).xyz;

    return vec4(pixel*(1.0 - shockwave_mask) + target_pixel*shockwave_mask, 1.0);
}
