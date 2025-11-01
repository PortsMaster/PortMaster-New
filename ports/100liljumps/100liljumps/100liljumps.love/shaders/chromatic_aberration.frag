#pragma language glsl3

uniform float total_time;
uniform float time;

#define resWidth 320.0
#define resHeight 180.0

#define peak_offset 3.0 // in pixels

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){

    // time : 0 -> total_time
    float normalized_time = time / total_time;
    float cliped_time = 2.0*(normalized_time - 0.5);
    float offset = -abs(cliped_time) + 1.0;

    vec2 res = vec2(resWidth, resHeight);
    vec2 left_offset_coords  = vec2(screen_coords.x - peak_offset*offset, screen_coords.y);
    vec2 right_offset_coords = vec2(screen_coords.x + peak_offset*offset, screen_coords.y);
    vec2 left_offset_uvs  = left_offset_coords / res;
    vec2 right_offset_uvs = right_offset_coords / res;

    vec3 left_offseted_pixel  = Texel(t, left_offset_uvs).rgb;
    vec3 right_offseted_pixel = Texel(t, right_offset_uvs).rgb;
    vec3 current_pixel = Texel(t, uvs).rgb;
    float red   = right_offseted_pixel.r;
    float green = current_pixel.g;
    float blue  = left_offseted_pixel.b;

    vec3 final_color = vec3(red, green, blue);

    return vec4(final_color, 1.0);
}

