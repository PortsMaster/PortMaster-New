in vec3 normal;
in vec2 uv;
in vec2 uv_two;
in vec4 world_position;

layout(location = 0) out vec4 o_diffuse_color;
layout(location = 1) out vec4 o_normal_depth;

#stk_include "utils/encode_normal.frag"
#stk_include "utils/sp_texture_sampling.frag"

#define HIGH_RES_SAMPLER 1.0f
#define LOW_RES_SAMPLER 0.5f


float getMitigationFactor(void)
{
    float cam_dist = length(u_view_matrix * world_position);
    return clamp(pow(cam_dist * 0.01, 2.0) - 0., 0., 1.);
}

vec4 sampleMultiResTextureLayer2(float factor, vec2 uv)
{
    return mix(sampleTextureLayer2(uv * HIGH_RES_SAMPLER), sampleTextureLayer2(uv * LOW_RES_SAMPLER), factor);
}

vec4 sampleMultiResTextureLayer3(float factor, vec2 uv)
{
    return mix(sampleTextureLayer3(uv * HIGH_RES_SAMPLER), sampleTextureLayer3(uv * LOW_RES_SAMPLER), factor);
}

vec4 sampleMultiResTextureLayer4(float factor, vec2 uv)
{
    return mix(sampleTextureLayer4(uv * HIGH_RES_SAMPLER), sampleTextureLayer4(uv * LOW_RES_SAMPLER), factor);
}

vec4 sampleMultiResTextureLayer5(float factor, vec2 uv)
{
    return mix(sampleTextureLayer5(uv * HIGH_RES_SAMPLER), sampleTextureLayer5(uv * LOW_RES_SAMPLER), factor);
}

void main(void)
{
    // mitigate repetitive patterns
    float mitigation = getMitigationFactor();

    // Splatting part
    vec4 splatting = sampleTextureLayer1(uv_two);
    vec4 detail0 = sampleMultiResTextureLayer2(mitigation, uv);
    vec4 detail1 = sampleMultiResTextureLayer3(mitigation, uv);
    vec4 detail2 = sampleMultiResTextureLayer4(mitigation, uv);
    vec4 detail3 = sampleMultiResTextureLayer5(mitigation, uv);

    vec4 splatted = splatting.r * detail0 +
        splatting.g * detail1 +
        splatting.b * detail2 +
        max(0.0, (1.0 - splatting.r - splatting.g - splatting.b)) * detail3;

#if defined(Advanced_Lighting_Enabled)
    o_diffuse_color = vec4(splatted.xyz, 0.0);
    //o_diffuse_color = vec4(vec3(mitigation), 0.0);
    o_normal_depth.xy = 0.5 * EncodeNormal(normalize(normal)) + 0.5;
    o_normal_depth.zw = vec2(0.0);
#else
    o_diffuse_color = vec4(splatted.xyz, 1.0);
    //o_diffuse_color = vec4(vec3(mitigation), 0.0);
#endif
}
