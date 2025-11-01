#pragma language glsl3

#define resWidth 300 // From ui.lua symbol canvas
#define resHeight 300
#define peak_offset 4.0 // in pixels

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    vec2 res = vec2(resWidth, resHeight);
    vec2 left_offset_coords  = vec2(screen_coords.x - peak_offset, screen_coords.y);
    vec2 right_offset_coords = vec2(screen_coords.x + peak_offset, screen_coords.y);
    vec2 left_offset_uvs  = left_offset_coords / res;
    vec2 right_offset_uvs = right_offset_coords / res;

    vec4 left_offseted_pixel  = Texel(t, left_offset_uvs).rgba;
    vec4 right_offseted_pixel = Texel(t, right_offset_uvs).rgba;
    vec4 current_pixel = Texel(t, uvs).rgba;

    float mask = right_offseted_pixel.a + left_offseted_pixel.a + current_pixel.a;
    if(!bool(mask)) {
        discard;
    }
    float red   = right_offseted_pixel.r;
    float green = current_pixel.g;
    float blue  = left_offseted_pixel.b;

    vec3 final_color = vec3(red, green, blue);
    vec4 result = vec4(final_color, 1.0);

    return result;
}
