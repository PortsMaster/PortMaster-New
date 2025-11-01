#pragma language glsl3

uniform float time;
uniform Image water_tiles_mask;

uniform float top_y;

#define resWidth 320.0
#define resHeight 180.0

#define dist_vel -4.0

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    float water_mask = Texel(water_tiles_mask, uvs).r;

    float dist_offset = sin(dist_vel*time + (screen_coords.y) / 4.0);

    vec2 target_coords = vec2(screen_coords.x + dist_offset, screen_coords.y);
    vec2 target_uvs = target_coords / vec2(resWidth, resHeight);

    vec3 target_pixel = Texel(t, target_uvs).xyz;
    target_pixel += vec3(0.05, 0.05, 0.10);

    float center_y = top_y + 1.0;
    float wvalue = sin(0.2*(screen_coords.x + 8.0*time)); // 0->1
    float diff_value = (-screen_coords.y + center_y);

    float in_wave = 0.0;
    if(top_y > 8.0) {
        in_wave = float(diff_value <= wvalue && diff_value >= wvalue - 1.0);
    }

    if (top_y > 8.0 && diff_value > wvalue) discard;
    target_pixel = target_pixel + in_wave*vec3(0.4, 0.6, 1.0);

    vec2 left_pixel_uvs = vec2(screen_coords.x - 1.0, screen_coords.y) / vec2(resWidth, resHeight);
    vec2 right_pixel_uvs = vec2(screen_coords.x + 1.0, screen_coords.y) / vec2(resWidth, resHeight);
    vec2 top_pixel_uvs = vec2(screen_coords.x, screen_coords.y + 1.0) / vec2(resWidth, resHeight);
    vec2 bottom_pixel_uvs = vec2(screen_coords.x, screen_coords.y - 1.0) / vec2(resWidth, resHeight);

    float left_pixel_mask = Texel(water_tiles_mask, left_pixel_uvs).r;
    float right_pixel_mask = Texel(water_tiles_mask, right_pixel_uvs).r;
    float top_pixel_mask = Texel(water_tiles_mask, top_pixel_uvs).r;
    float bottom_pixel_mask = Texel(water_tiles_mask, bottom_pixel_uvs).r;
    bool discard_condition = (water_mask + left_pixel_mask + right_pixel_mask + top_pixel_mask + bottom_pixel_mask) == 0.0;

    if(discard_condition) discard;


    return vec4(target_pixel, 1.0);
}

