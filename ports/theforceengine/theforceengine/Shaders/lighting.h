#ifndef TFE_LIGHTING_INCLUDED
#define TFE_LIGHTING_INCLUDED

#ifndef TFE_FTOI
#define TFE_FTOI(x) int(x)
#define TFE_FTOI2(v) ivec2(v)
#endif

float tfe_readLightRampG(int depthIndex)
{
#ifdef TFE_GLES_SMOOTH_LIGHTRAMP
	return texelFetch(Colormap, ivec2(depthIndex, 0), 0).g * 255.0 / 8.23;
#else
	return texelFetch(Colormap, ivec2(depthIndex, 0), 0).g * 255.0;
#endif
}

float getDepthAttenuation(float z, float ambient, float baseLight, float lightOffset)
{
#ifdef OPT_COLORMAP_INTERP // Smooth out the attenuation.
	float depthAtten = z * 0.09375;
#else
	float depthAtten = floor(z / 16.0) + floor(z / 32.0);
#endif

	float minAmbient = ambient * 0.875;
	float light = max(baseLight - depthAtten, minAmbient) + lightOffset;
	return clamp(light, 0.0, 31.0);
}

float getLightRampValue(float z, float worldAmbient)
{
#ifdef OPT_SMOOTH_LIGHTRAMP // Smooth out light ramp.
	float depthScaled = min(z * 4.0, 127.0);
	float base = floor(depthScaled);

	float d0 = base;
	float d1 = min(127.0, base + 1.0);
	float blendFactor = fract(depthScaled);
	float ramp0 = tfe_readLightRampG(TFE_FTOI(d0));
	float ramp1 = tfe_readLightRampG(TFE_FTOI(d1));
	float lightSource = 31.0 - (mix(ramp0, ramp1, blendFactor) + worldAmbient);
#else // Vanilla style light ramp.
	float depthScaledF = min(z * 4.0, 127.0);
	float depthScaled = floor(depthScaledF);
#ifdef TFE_GLES_SMOOTH_LIGHTRAMP
	float d1 = min(127.0, depthScaled + 1.0);
	float blendFactor = fract(depthScaledF);
	float ramp0 = tfe_readLightRampG(TFE_FTOI(depthScaled));
	float ramp1 = tfe_readLightRampG(TFE_FTOI(d1));
	float lightSource = 31.0 - (mix(ramp0, ramp1, blendFactor) + worldAmbient);
#else
	float ramp = tfe_readLightRampG(TFE_FTOI(depthScaled));
	float lightSource = 31.0 - (ramp + worldAmbient);
#endif
#endif
	return lightSource;
}

#endif // TFE_LIGHTING_INCLUDED
