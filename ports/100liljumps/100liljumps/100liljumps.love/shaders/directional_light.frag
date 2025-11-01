#pragma language glsl3

uniform float shadow_intensity;

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    return vec4(0.0, 0.0, 0.0, shadow_intensity);
}
