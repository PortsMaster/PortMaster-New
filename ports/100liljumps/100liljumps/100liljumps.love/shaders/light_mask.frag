#pragma language glsl3

uniform vec2 L;
uniform float light_intensity;
uniform float light_radius;
uniform vec3 light_color;
#define resWidth 320.0
#define resHeight 180.0

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    // if the light is below the screen, it will not be drawn
    vec2 distance = (screen_coords - L) / vec2(resWidth, resWidth);

    float playerLightMask = length(distance);
    playerLightMask = 1.0 - smoothstep(0.0, light_radius, playerLightMask);

    return vec4(playerLightMask*light_intensity*light_color, 1.0);
}
