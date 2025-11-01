#pragma language glsl3

#define resWidth 320.0
#define resHeight 180.0

uniform vec3 light_color;

struct Light {
    vec2 pos;
    vec3 color;
    float radius;
    float intensity;
};

#define MAX_LIGHTS 100

uniform int n_lights;
uniform Light lights[MAX_LIGHTS];

vec2 coord_to_uvs(vec2 coord) {
    return coord / vec2(resWidth, resHeight);
}

vec2 uvs_to_1to1(vec2 uvs) {
    vec2 centered_uvs = 2.0*(uvs - 0.5);

    return centered_uvs / vec2(1.0, resWidth / resHeight);
}

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 coord ){
    vec4 pixel = vec4(0.0);
    vec2 ruvs = uvs_to_1to1(coord_to_uvs(coord)); // rectangle doesnt provide uvs, should use a mesh or shend from vertex but meh

    vec4 new_pixel = vec4(0.0);
    float max_intensity = 0.0;

    for(int i = 0; i < n_lights; ++i) {
        vec2 light_uvs = uvs_to_1to1(coord_to_uvs(lights[i].pos));
        float d = (length(ruvs - light_uvs));
        d = 1.0 - smoothstep(0.0, lights[i].radius, d);
        max_intensity = max(d*max_intensity, d*lights[i].intensity);
        new_pixel += d*vec4(lights[i].color, max_intensity);
    }

    return new_pixel;
}
