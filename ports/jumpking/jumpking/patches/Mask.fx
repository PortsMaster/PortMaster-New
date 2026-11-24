// Replacement for Jump King's DirectX-only Mask effect (shaders/Mask.xnb).
// The original MGFX has a pixel shader only; SpriteBatch's own vertex shader
// (with the 480x360 orthographic projection) stays bound, so this file also
// defines no vertex shader and no MatrixTransform parameter.

sampler2D SpriteTexture : register(s0);
sampler2D MaskTexture : register(s1);

float2 tiling;
float wind;

float4 PixelShaderFunction(float2 uv : TEXCOORD0) : COLOR0
{
    float2 spriteUV = float2(uv.x * tiling.x + wind, uv.y * tiling.y);
    float4 sprite = tex2D(SpriteTexture, spriteUV);
    float4 mask = tex2D(MaskTexture, uv);
    return sprite * mask.w;
}

technique MaskDrawing
{
    pass P0
    {
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}
