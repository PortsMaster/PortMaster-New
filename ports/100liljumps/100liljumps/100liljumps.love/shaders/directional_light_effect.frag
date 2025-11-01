#pragma language glsl3

uniform Image mask_1;
uniform Image mask_2;

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    vec3 pixel = Texel(t, uvs).xyz;
    float mask_1_value = Texel(mask_1, uvs).x;
    float mask_2_value = Texel(mask_2, uvs).x;

    float mask = min(mask_1_value + mask_2_value, 1.0);
    float light_intensity = 0.8;

    vec3 light_color = vec3(206.0/255.0, 255.0/255.0, 52.0/255.0);
    vec3 final_color = pixel + light_intensity*pixel*light_color*(min(1.0, mask));

    return vec4(final_color, 1.0);
}
