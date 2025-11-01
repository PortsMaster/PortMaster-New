#pragma language glsl3

#define resWidth 320.0
#define resHeight 180.0

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    float mask = Texel(t, uvs).a;
    vec4 c = vec4(vec3(1.0), mask);

    return c;
}
