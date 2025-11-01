#pragma language glsl3

#define resWidth 320.0
#define resHeight 180.0

struct LightRegion {
    vec2 pos;
    float radius;
    float alpha;
};

#define MAX_LIGHTS 10

uniform int n_lights;
uniform LightRegion lights[MAX_LIGHTS];

uniform float time;

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 coord ){
    vec3 new_pixel = vec3(0.0, 0.0, 0.0);

    for(int i = 0; i < n_lights; ++i) {
        vec2 pos = lights[i].pos;
        float radius = lights[i].radius;
        float alpha = lights[i].alpha;

        vec2 centered_pos = coord - pos;
        vec2 normalized_centered = centered_pos / resWidth;

        float flicker_speed = 2.0;
        float offset_factor = 0.005;
        float offset = radius + mix(0.0, offset_factor, sin(time*flicker_speed));
        float distance = 1.0 - floor(length(normalized_centered) + offset);

        vec3 light_color = vec3(1.0, 1.0, 1.0);
        vec3 result = light_color*distance*alpha;

        new_pixel += result;
    }

    return vec4(new_pixel, 1.0);
}
