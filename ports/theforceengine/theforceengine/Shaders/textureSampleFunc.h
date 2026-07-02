#include "Shaders/bufferAccess.h"

uniform sampler2D Colormap;	// The color map has full RGB pre-backed in.
uniform sampler2D Palette;

#include "Shaders/lighting.h"

uniform sampler2DArray Textures;
TFE_DECLARE_IBUFFER(TextureTable);

uniform uint TextureSettings;

#ifdef OPT_TRUE_COLOR
uniform vec4 TexSamplingParam;
// TexSamplingParam.x = bilinear sharpness, TexSamplingParam.y = 1/atlasPageWidth

vec3 normalizeAtlasUv(vec3 uv3)
{
	float atlasRcp = TexSamplingParam.y;
	return uv3 * vec3(atlasRcp, atlasRcp, 1.0);
}

vec2 normalizeAtlasUvDeriv(vec2 uv)
{
	return uv * TexSamplingParam.y;
}
#endif

// Fragment-only: uses gl_FragCoord (must not live in lighting.h — vertex shaders include that too).
float ditherLightLevel(float light)
{
#ifdef TFE_GLES_LIGHT_DITHER
	if (light >= 31.0)
	{
		return light;
	}
	mat4 bayer = mat4(
		vec4(00.0, 12.0, 03.0, 15.0),
		vec4(08.0, 04.0, 11.0, 07.0),
		vec4(02.0, 14.0, 01.0, 13.0),
		vec4(10.0, 06.0, 09.0, 05.0)) / 16.0;
	ivec2 p = TFE_FTOI2(gl_FragCoord.xy) & 3;
	return floor(light + bayer[p.x][p.y]);
#endif
	return light;
}

vec3 fmod(vec3 x, vec3 y)
{
	return x - floor(x / y)*y;
}

vec2 fmod(vec2 x, vec2 y)
{
	return x - floor(x / y)*y;
}

float fmod(float x, float y)
{
	return x - floor(x / y)*y;
}

ivec2 imod(ivec2 x, ivec2 y)
{
	return x - (x / y)*y;
}

int wrapCoordScalar(int x, int edge)
{
	x = x - (x / edge)*edge;
	x += (x < 0) ? edge : 0;
	return x;
}

ivec2 wrapCoord(ivec2 uv, ivec2 edge)
{
	uv = imod(uv, edge);
	uv.x += (uv.x < 0) ? edge.x : 0;
	uv.y += (uv.y < 0) ? edge.y : 0;
	return uv;
}

// Approximate the distortion that happens in software when floor and ceiling textures are not 64x64.
ivec2 wrapCoordFlat(ivec2 uv, ivec2 edge)
{
	int coord = (uv.x & 63) * 64 + (uv.y & 63);
	uv = wrapCoord(ivec2(coord / edge.y, coord), edge);
	uv.x += (uv.x < 0) ? edge.x : 0;
	uv.y += (uv.y < 0) ? edge.y : 0;
	return uv;
}

vec2 wrapCoordF(vec2 uv, vec2 edge)
{
	uv += vec2(0.5,-0.5);

	uv = fmod(uv, edge);
	uv.x += (uv.x < 0.0) ? edge.x : 0.0;
	uv.y += (uv.y < 0.0) ? edge.y : 0.0;

	uv -= vec2(0.5,-0.5);
	return uv;
}

// Approximate the distortion that happens in software when floor and ceiling textures are not 64x64.
vec2 wrapCoordFlatF(vec2 uv, vec2 edge)
{
	float coord = fmod(uv.x, 64.0) * 64.0 + fmod(uv.y, 64.0);
	uv = wrapCoordF(vec2(coord / edge.y, coord), edge);
	uv.x += (uv.x < 0.0) ? edge.x : 0.0;
	uv.y += (uv.y < 0.0) ? edge.y : 0.0;
	return uv;
}

// Approximate a bilinear filter using a screenspace dither
// This technique was first seen in Unreal 1 (as far as I know).
vec2 bilinearDither(vec2 uv)
{
	vec2 bilinearOffset[4] = vec2[4](
		vec2(0.25, 0.00), vec2(0.50, 0.75),
		vec2(0.75, 0.50), vec2(0.00, 0.25));

	int ix = TFE_FTOI(gl_FragCoord.x) & 1;
	int iy = TFE_FTOI(gl_FragCoord.y) & 1;
	uv += bilinearOffset[iy * 2 + ix];

	return uv;
}

#ifdef OPT_TRUE_COLOR

vec3 getHalfTint(ivec2 packedColor)
{
	int r = (packedColor.x >> 15) & 255;
	int g = (packedColor.x >> 23) & 255;
	int b = (packedColor.y >> 15) & 255;

	float scale = 1.0 / 255.0;
	vec3 tint;
	tint.x = float(r) * scale;
	tint.y = float(g) * scale;
	tint.z = float(b) * scale;
	return tint;
}

vec2 scaleUv(vec2 uv, int data)
{
	float scale = float(data >> 12);
	uv *= scale;
	return uv;
}

vec4 sampleTexture(int id, vec2 uv)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);

	uv = scaleUv(uv, sampleData.y);

	vec2 baseUv = uv;
	uv = bilinearSharpness(uv, TexSamplingParam.x);

	vec3 uv3;
	uv3.xy = wrapCoordF(uv.xy, vec2(sampleData.zw));
	uv3.xy += vec2(sampleData.xy & ivec2(4095));
	uv3.z = float(sampleData.x >> 12);

#ifdef OPT_MIPMAPPING
	baseUv = normalizeAtlasUvDeriv(baseUv);
	return textureGrad(Textures, normalizeAtlasUv(uv3), dFdx(baseUv), dFdy(baseUv));
#else
	return textureLod(Textures, normalizeAtlasUv(uv3), 0.0);
#endif
}

vec4 sampleTexture(int id, vec2 uv, bool sky, bool flip, bool applyFlatWarp, out vec3 tint)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	tint = TextureSettings == 0u ? vec3(1.0) : getHalfTint(sampleData.zw);
	sampleData.zw &= ivec2(32767);

	uv = scaleUv(uv, sampleData.y);

	vec2 baseUv = uv;
	uv = bilinearSharpness(uv, TexSamplingParam.x);
	
	vec3 uv3 = vec3(uv, 0.0);
	if (sky)
	{
		if (abs(uv3.y) >= 9999.0)
		{
			// TODO: Single sample for the whole area.
			uv3.xy = vec2(sampleData.zw) / 2.0;
		}
		else
		{
			uv3.xy = wrapCoordF(uv3.xy, vec2(sampleData.zw));
		}
	}
	else if (applyFlatWarp)
	{
		//uv3.xy = wrapCoordFlatF(uv3.xy, vec2(sampleData.zw));
		uv3.xy = wrapCoordF(uv3.xy, vec2(sampleData.zw));
		if (flip)
		{
			uv3.x = float(sampleData.z) - uv3.x;// -1.0;
		}
	}
	else
	{
		uv3.xy = wrapCoordF(uv3.xy, vec2(sampleData.zw));
		if (flip)
		{
			uv3.x = float(sampleData.z) - uv3.x;// -1.0;
		}
	}
	uv3.xy += vec2(sampleData.xy & ivec2(4095));
	uv3.z = float(sampleData.x >> 12);

#ifdef OPT_MIPMAPPING
	// The Sky should always sample mip 0.
	vec2 dfdx = vec2(0.0);
	vec2 dfdy = vec2(0.0);
	// Compute the pre-wrapped partial derivatives.
	if (!sky)
	{
		baseUv = normalizeAtlasUvDeriv(baseUv);
		dfdx = dFdx(baseUv);
		dfdy = dFdy(baseUv);
	}
	return textureGrad(Textures, normalizeAtlasUv(uv3), dfdx, dfdy);
#else
	return textureLod(Textures, normalizeAtlasUv(uv3), 0.0);
#endif
}

vec4 sampleTextureClamp(int id, vec2 uv)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);

	uv = scaleUv(uv, sampleData.y);
	uv = bilinearSharpness(uv, TexSamplingParam.x);

	vec3 uv3 = vec3(uv, 0.0);
	uv3.xy += vec2(sampleData.xy & ivec2(4095));
	uv3.z = float(sampleData.x >> 12);

	return textureLod(Textures, normalizeAtlasUv(uv3), 0.0);
}

vec4 sampleTextureClamp(int id, vec2 uv, bool opaque)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);

	uv = scaleUv(uv, sampleData.y);

	vec2 baseUv = uv;
	uv = bilinearSharpness(uv, TexSamplingParam.x);

	vec3 uv3 = vec3(uv, 0.0);
	vec2 thres = vec2(0.25);
	if (any(lessThan(uv3.xy, thres)) || any(greaterThan(uv3.xy, vec2(sampleData.zw) - thres)))
	{
		return vec4(0.0);
	}
	uv3.xy += vec2(sampleData.xy & ivec2(4095));
	uv3.z = float(sampleData.x >> 12);

#ifdef OPT_MIPMAPPING
	// Compute the pre-wrapped partial derivatives.
	baseUv = normalizeAtlasUvDeriv(baseUv);
	return textureGrad(Textures, normalizeAtlasUv(uv3), dFdx(baseUv), dFdy(baseUv));
#else
	return textureLod(Textures, normalizeAtlasUv(uv3), 0.0);
#endif
}
#else
float sampleTexture(int id, vec2 uv)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);

	ivec3 iuv;

#ifdef OPT_BILINEAR_DITHER
	uv = bilinearDither(uv);
#endif

	iuv.xy = TFE_FTOI2(uv);
	iuv.z = 0;

	iuv.xy = wrapCoord(iuv.xy, sampleData.zw);
	iuv.xy += (sampleData.xy & ivec2(4095));
	iuv.z = sampleData.x >> 12;

	return texelFetch(Textures, iuv, 0).r * 255.0;
}

float sampleTexture(int id, vec2 uv, bool sky, bool flip, bool applyFlatWarp)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);

	ivec3 iuv;

#ifdef OPT_BILINEAR_DITHER
	uv = bilinearDither(uv);
#endif

	iuv.xy = TFE_FTOI2(floor(uv));
	iuv.z = 0;

	if (sky)
	{
		if (abs(iuv.y) >= 9999)
		{
			// TODO: Single sample for the whole area.
			iuv.xy = ivec2(sampleData.z / 2, sampleData.w / 2);
		}
		else
		{
			iuv.x = wrapCoordScalar(iuv.x, sampleData.z);
			iuv.y = wrapCoordScalar(iuv.y, sampleData.w);
		}
	}
	else if (applyFlatWarp)
	{
		iuv.xy = wrapCoordFlat(iuv.xy, sampleData.zw);
		if (flip)
		{
			iuv.x = sampleData.z - iuv.x - 1;
		}
	}
	else
	{
		iuv.xy = wrapCoord(iuv.xy, sampleData.zw);
		if (flip)
		{
			iuv.x = sampleData.z - iuv.x - 1;
		}
	}
	iuv.xy += (sampleData.xy & ivec2(4095));
	iuv.z = sampleData.x >> 12;

	return texelFetch(Textures, iuv, 0).r * 255.0;
}

float sampleTextureClamp(int id, vec2 uv)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);

	ivec3 iuv;

#ifdef OPT_BILINEAR_DITHER
	uv = bilinearDither(uv);
#endif

	iuv.xy = TFE_FTOI2(uv);
	iuv.z = 0;

	if (any(lessThan(iuv.xy, ivec2(0))) || any(greaterThan(iuv.xy, sampleData.zw - 1)))
	{
		return 0.0;
	}

	iuv.xy += (sampleData.xy & ivec2(4095));
	iuv.z = sampleData.x >> 12;

	return texelFetch(Textures, iuv, 0).r * 255.0;
}

float sampleTextureClamp(int id, vec2 uv, bool opaque)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);

	ivec3 iuv;

#ifdef OPT_BILINEAR_DITHER
	uv = bilinearDither(uv);
#endif

	iuv.xy = TFE_FTOI2(floor(uv));
	iuv.z = 0;

	if (any(lessThan(iuv.xy, ivec2(0))) || any(greaterThan(iuv.xy, sampleData.zw - 1)))
	{
		return 0.0;
	}
	iuv.xy += (sampleData.xy & ivec2(4095));
	iuv.z = sampleData.x >> 12;

	float value = texelFetch(Textures, iuv, 0).r * 255.0;
	if (opaque) { value = max(0.75, value); }	// avoid clipping if opaque.
	return value;
}
#endif

// Matches sampleTextureClamp() bounds so sign overlays can discard before lighting.
bool signSampleOutOfBounds(int id, vec2 uv, bool opaque)
{
	ivec4 sampleData = tfe_fetchIBuffer(TextureTable, id);
	sampleData.zw &= ivec2(32767);
#ifdef OPT_TRUE_COLOR
	uv = scaleUv(uv, sampleData.y);
	uv = bilinearSharpness(uv, TexSamplingParam.x);
	vec2 thres = vec2(0.25);
	return any(lessThan(uv, thres)) || any(greaterThan(uv, vec2(sampleData.zw) - thres));
#else
#ifdef OPT_BILINEAR_DITHER
	uv = bilinearDither(uv);
#endif
	ivec2 iuv = opaque ? TFE_FTOI2(floor(uv)) : TFE_FTOI2(uv);
	return any(lessThan(iuv, ivec2(0))) || any(greaterThan(iuv, sampleData.zw - 1));
#endif
}

vec3 getAttenuatedColor(int baseColor, int light)
{
	int color = baseColor;
	if (light < 31)
	{
		ivec2 uv = ivec2(color, light);
		color = TFE_FTOI(texelFetch(Colormap, uv, 0).r * 255.0);
	}
	return texelFetch(Palette, ivec2(color, 0), 0).rgb;
}

vec3 getAttenuatedColorBlend(float baseColor, float light)
{
	int color = TFE_FTOI(baseColor);
	if (light < 31.0)
	{
		int l0 = TFE_FTOI(light);
		int l1 = min(31, l0 + 1);
		float blendFactor = fract(light);

		ivec4 uv = ivec4(color, l0, color, l1);
		int color0 = TFE_FTOI(texelFetch(Colormap, uv.xy, 0).r * 255.0);
		int color1 = TFE_FTOI(texelFetch(Colormap, uv.zw, 0).r * 255.0);

		vec3 value0 = texelFetch(Palette, ivec2(color0, 0), 0).rgb;
		vec3 value1 = texelFetch(Palette, ivec2(color1, 0), 0).rgb;
		return mix(value0, value1, blendFactor);
	}
	return texelFetch(Palette, ivec2(color, 0), 0).rgb;
}

#ifdef OPT_TRUE_COLOR
float luminance(vec3 color)
{
	// Dark Forces uses (0.25, 0.5, 0.25) for luminance, so do the same here.
	vec3 lumScale = vec3(0.25, 0.5, 0.25);
	return dot(lumScale, color);
}

vec3 trueColorMapping(int lightLevel, vec3 baseColor)
{
	vec4 mulFactor = texelFetch(Palette, ivec2(lightLevel, 0), 0);
	vec4 fogFactor = texelFetch(Palette, ivec2(lightLevel + 32, 0), 0);

	float fogDensity = fogFactor.a;
	if (mulFactor.w > 0.5)  // Is this a color shift?
	{
		baseColor = mulFactor.rgb * luminance(baseColor);
	}
	else  // Or regular multiply?
	{
		baseColor *= mulFactor.rgb;
	}

	// Fog
	return mix(baseColor, fogFactor.rgb, fogDensity);
}

vec3 generateColor(vec3 baseColor, float lightLevel)
{
	int l0 = min(31, TFE_FTOI(lightLevel));
	int l1 = min(31, l0 + 1);
	float blendFactor = fract(lightLevel);

	// TODO: Reduce texture fetches.
	vec3 mapping0 = trueColorMapping(l0, baseColor);
	vec3 mapping1 = trueColorMapping(l1, baseColor);
		
	return mix(mapping0, mapping1, blendFactor);
}

vec3 getAttenuatedColor(vec3 baseColor, float light)
{
	if (light < 31.0)
	{
		return generateColor(baseColor, ditherLightLevel(light));
	}
	return baseColor;
}

vec4 getFinalColor(vec4 baseColor, float lightLevel, float emissive)
{
	vec4 color = baseColor;
	if (lightLevel < 31.0)
	{
		color.rgb = generateColor(baseColor.rgb, ditherLightLevel(lightLevel));
	}
	color.rgb = mix(color.rgb, baseColor.rgb, emissive);
	return color;
}
#else
vec4 getFinalColor(float baseColor, float lightLevel, float emissive)
{
	vec4 color;
	float lit = ditherLightLevel(lightLevel);
	#ifdef OPT_COLORMAP_INTERP
		color.rgb = getAttenuatedColorBlend(baseColor, lit);
	#else
		color.rgb = getAttenuatedColor(TFE_FTOI(baseColor), TFE_FTOI(lit));
	#endif
	color.a = 1.0;
	return color;
}
#endif

#ifdef OPT_TRUE_COLOR
vec4 getMaterialColor(float emissive)
{
	return vec4(emissive, 0.0, 0.0, 0.0);
}
#else
vec4 getMaterialColor(float baseColor)
{
	// TODO: Replace with emissive channel from textures.
	vec4 color = vec4(0.0);
	color.x = baseColor > 0.0 && baseColor < 32.0 ? 1.0 : 0.0;
	return color;
}
#endif

#ifdef OPT_TRUE_COLOR
bool discardPixel(vec4 color, float mask)
{
	return color.a < 0.48 && mask < 1.0;
}
#else
bool discardPixel(float color, float mask)
{
	return color < 0.5 && mask < 1.0;
}
#endif
