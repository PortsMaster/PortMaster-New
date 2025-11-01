#pragma language glsl3

precision mediump float;

vec4 effect( vec4 color, Image t, vec2 uvs, vec2 screen_coords ){
    float base_shadow_texel = Texel(t, uvs).a;

    if(base_shadow_texel > 0.0) {
        return vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
}
