#version 120

//varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform vec2 texture_size;
uniform sampler2D texture;
uniform sampler2D background_texture;
uniform float radius, exponent, coeff;

#define iterations 12

//Thanks to
//http://www.klopfenstein.net/lorenz.aspx/gamecomponents-the-bloom-post-processing-filter
// const vec2 offsets[iterations] = vec2[iterations](
//    vec2(-0.326212, -0.405805),
//    vec2(-0.840144, -0.073580),
//    vec2(-0.695914,  0.457137),
//    vec2(-0.203345,  0.620716),
//    vec2( 0.962340, -0.194983),
//    vec2( 0.473434, -0.480026),
//    vec2( 0.519456,  0.767022),
//    vec2( 0.185461, -0.893124),
//    vec2( 0.507431,  0.064425),
//    vec2( 0.896420,  0.412458),
//    vec2(-0.321940, -0.932615),
//    vec2(-0.791559, -0.597705)
// );

vec4 highlight(vec4 i)
{
    return pow(i, vec4(exponent))*coeff;
}

vec4 get_highlight(vec2 offset)
{
    vec2 coord = texture_coordinate1 + radius * offset * texture_size;
    return highlight(texture2D(background_texture, coord));
}

void main()
{
    vec4 s = texture2D(background_texture, texture_coordinate1);
    vec4 o = highlight(s);

    // for (int i=0; i < iterations; i++) {
    //     o += highlight(texture2D(background_texture, texture_coordinate1 + radius*offsets[i]*texture_size));
    // }

    o += get_highlight(vec2(-0.326212, -0.405805));
    o += get_highlight(vec2(-0.840144, -0.073580));
    o += get_highlight(vec2(-0.695914,  0.457137));
    o += get_highlight(vec2(-0.203345,  0.620716));
    o += get_highlight(vec2( 0.962340, -0.194983));
    o += get_highlight(vec2( 0.473434, -0.480026));
    o += get_highlight(vec2( 0.519456,  0.767022));
    o += get_highlight(vec2( 0.185461, -0.893124));
    o += get_highlight(vec2( 0.507431,  0.064425));
    o += get_highlight(vec2( 0.896420,  0.412458));
    o += get_highlight(vec2(-0.321940, -0.932615));
    o += get_highlight(vec2(-0.791559, -0.597705));

    o /= 13.0;

    gl_FragColor = (s+highlight(o));
}