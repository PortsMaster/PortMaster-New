#pragma language glsl3

uniform Image shadow_mask;
uniform Image light_mask;
uniform Image point_lights_mask;
uniform Image light_receiver_mask;

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 coord ){
    float colored_shadow_mask = 1.0 - Texel(shadow_mask, uvs).a;
    vec3 light_mask = Texel(light_mask, uvs).rgb;
    vec4 point_lights = Texel(point_lights_mask, uvs);
    vec3 point_lights_mask = point_lights.xyz;
    float light_receiver_mask = Texel(light_receiver_mask, uvs).x;

    vec3 scene_light_mask = (colored_shadow_mask*light_mask)*light_receiver_mask;
    vec3 scene_point_light_mask = point_lights_mask*light_receiver_mask;
    float ambient_light = 0.6;

    vec3 scene_texel = Texel(t, uvs).xyz;

    vec3 reflected_point_light = scene_texel*scene_point_light_mask;

    vec3 final_color = scene_texel*ambient_light + scene_texel*(min(vec3(1.0), scene_light_mask)) + reflected_point_light;

    return vec4(final_color, 1.0);
}
