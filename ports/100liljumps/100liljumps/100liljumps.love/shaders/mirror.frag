#pragma language glsl3

uniform float left_x;
uniform float width;
uniform float direction;
uniform Image scene;

#define resWidth 320.0
#define resHeight 180.0
#define deformation_width 8.0
#define deformation_in_mirror 16.0
#define PI 3.141596

vec4 effect( vec4 color, Image t, vec2 _, vec2 screen_coords ) {
    vec2 uvs = vec2(screen_coords.x / resWidth, screen_coords.y / resHeight);

    if(direction == 1.0) {
        float origin_x = screen_coords.x - left_x;
        float dx = width - origin_x + 1.0;

        float in_deform = float(dx <= deformation_in_mirror);
        float in_normal = float(dx > deformation_in_mirror);

        float deformation_scale = min(dx / deformation_in_mirror, 1.0);
        deformation_scale = sin((1.0 - deformation_scale) * PI/2.0);

        float target_x = (left_x + width) + in_normal*(dx - deformation_in_mirror + deformation_width) + in_deform*(deformation_width - deformation_scale*deformation_width);
        vec2 target_uvs = vec2(target_x / resWidth, uvs.y);

        vec3 target_pixel = vec3(0.85, 0.85, 1.0) * Texel(scene, target_uvs).rgb;

        return vec4(target_pixel, 1.0);
    } else {
        float origin_x = screen_coords.x - left_x;
        float dx = origin_x + 1.0;

        float in_deform = float(dx <= deformation_in_mirror);
        float in_normal = float(dx > deformation_in_mirror);

        float deformation_scale = min(dx / deformation_in_mirror, 1.0);
        deformation_scale = 1.0 - sin((1.0 - deformation_scale) * PI/2.0);

        float target_x = left_x + in_normal*(-dx - deformation_width + deformation_in_mirror) + in_deform*(-deformation_scale*deformation_width);
        vec2 target_uvs = vec2(target_x / resWidth, uvs.y);

        vec3 target_pixel = vec3(0.85, 0.85, 1.0) * Texel(scene, target_uvs).rgb;

        return vec4(target_pixel, 1.0);
    }
}

