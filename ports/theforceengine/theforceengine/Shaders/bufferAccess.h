#ifndef TFE_BUFFER_ACCESS_INCLUDED
#define TFE_BUFFER_ACCESS_INCLUDED

// Bifrost GLES (Mali-G31/G51/G52): scalar int(float) triggers llvm.bifrost.fptosi.tz and
// aborts the driver shader compiler. Use uint(floor()) for positive values instead.
#ifndef TFE_FTOI
#ifdef TFE_BUFFER_TEXTURE_BYTES
// Match GLSL int(float) / ivec2(vec2): truncate toward zero, without llvm.bifrost.fptosi.tz.
highp int tfe_ftoi(highp float x)
{
	if (x >= 0.0)
		return int(uint(floor(x + 0.0001)));
	return -int(uint(floor(-x + 0.0001)));
}

highp ivec2 tfe_ftoi2(highp vec2 v)
{
	return ivec2(tfe_ftoi(v.x), tfe_ftoi(v.y));
}
#else
#define tfe_ftoi(x) int(x)
#define tfe_ftoi2(v) ivec2(v)
#endif
#define TFE_FTOI(x) tfe_ftoi(x)
#define TFE_FTOI2(v) tfe_ftoi2(v)
#endif

// Desktop GL: samplerBuffer / isamplerBuffer / usamplerBuffer (unchanged).
// GLES Mali fallback (TFE_BUFFER_TEXTURE_2D): buffer data in a 2D texture.
// Integer and float buffers both use GL_RGBA8 byte layout (TFE_BUFFER_TEXTURE_BYTES)
// on Mali GLES — GL_*32* and float/half 2D allocations can SIGSEGV the driver.

#ifdef TFE_BUFFER_TEXTURE_2D

// Mali GLES requires explicit precision on sampler parameters (global precision does not apply).
#define TFE_DECLARE_FBUFFER(name) uniform highp sampler2D name
#define TFE_DECLARE_IBUFFER(name) uniform highp sampler2D name
#define TFE_DECLARE_UBUFFER(name) uniform highp sampler2D name

ivec2 tfe_bufCoord(int index)
{
	int x = index - (index / TFE_SHADER_BUFFER_WIDTH) * TFE_SHADER_BUFFER_WIDTH;
	return ivec2(x, index / TFE_SHADER_BUFFER_WIDTH);
}

#ifdef TFE_BUFFER_TEXTURE_BYTES

uint tfe_loadUint32(highp sampler2D buf, int byteOff)
{
	int texIdx = byteOff >> 2;
	vec4 t = texelFetch(buf, tfe_bufCoord(texIdx), 0);
	// Bifrost (Mali-G31 etc.): scalar int(float) triggers llvm.bifrost.fptosi.tz compiler crash.
	// Vector uvec4 cast avoids the broken intrinsic path.
	uvec4 b = uvec4(t * 255.0 + 0.5);
	return b.x | (b.y << 8u) | (b.z << 16u) | (b.w << 24u);
}

int tfe_loadInt32(highp sampler2D buf, int byteOff)
{
	return int(tfe_loadUint32(buf, byteOff));
}

float tfe_loadFloat32(highp sampler2D buf, int byteOff)
{
	return uintBitsToFloat(tfe_loadUint32(buf, byteOff));
}

vec4 tfe_fetchFBuffer(highp sampler2D buf, int index)
{
	int b = index << 4;
	return vec4(
		tfe_loadFloat32(buf, b),
		tfe_loadFloat32(buf, b + 4),
		tfe_loadFloat32(buf, b + 8),
		tfe_loadFloat32(buf, b + 12));
}

ivec4 tfe_fetchIBuffer16(highp sampler2D buf, int index)
{
	int b = index << 4;
	return ivec4(
		tfe_loadInt32(buf, b),
		tfe_loadInt32(buf, b + 4),
		tfe_loadInt32(buf, b + 8),
		tfe_loadInt32(buf, b + 12));
}

ivec4 tfe_fetchIBuffer8(highp sampler2D buf, int index)
{
	int b = index << 3;
	return ivec4(
		tfe_loadInt32(buf, b),
		tfe_loadInt32(buf, b + 4),
		0,
		0);
}

#define tfe_fetchIBuffer tfe_fetchIBuffer16

uvec4 tfe_fetchUBuffer(highp sampler2D buf, int index)
{
	return uvec4(tfe_fetchIBuffer16(buf, index));
}

#else

vec4 tfe_fetchFBuffer(highp sampler2D buf, int index)
{
	return texelFetch(buf, tfe_bufCoord(index), 0);
}

ivec4 tfe_fetchIBuffer(highp usampler2D buf, int index)
{
	return ivec4(texelFetch(buf, tfe_bufCoord(index), 0));
}

uvec4 tfe_fetchUBuffer(highp usampler2D buf, int index)
{
	return texelFetch(buf, tfe_bufCoord(index), 0);
}

#undef TFE_DECLARE_IBUFFER
#undef TFE_DECLARE_UBUFFER
#define TFE_DECLARE_IBUFFER(name) uniform highp usampler2D name
#define TFE_DECLARE_UBUFFER(name) uniform highp usampler2D name

#endif

#else

vec4 tfe_fetchFBuffer(samplerBuffer buf, int index)
{
	return texelFetch(buf, index);
}

ivec4 tfe_fetchIBuffer(isamplerBuffer buf, int index)
{
	return texelFetch(buf, index);
}

ivec4 tfe_fetchIBuffer8(isamplerBuffer buf, int index)
{
	return texelFetch(buf, index);
}

uvec4 tfe_fetchUBuffer(usamplerBuffer buf, int index)
{
	return texelFetch(buf, index);
}

#define TFE_DECLARE_FBUFFER(name) uniform samplerBuffer name
#define TFE_DECLARE_IBUFFER(name) uniform isamplerBuffer name
#define TFE_DECLARE_UBUFFER(name) uniform usamplerBuffer name

#endif

#endif
