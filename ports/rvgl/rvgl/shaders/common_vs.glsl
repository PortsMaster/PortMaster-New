#ifdef DEBUG
#line 3
#endif  // DEBUG

#ifdef GL_ES
precision highp float;
precision highp int;
#endif  // GL_ES

#ifdef USE_HIGHP
#define _mediump
#else
#define _mediump mediump
#endif  // USE_HIGHP

// modulus
#if (__VERSION__ >= 130) || defined(EXT_gpu_shader4)
#define Mod(x, y) ((x) % (y))
#else
#define Mod(x, y) int(mod(float(x), float(y)))
#endif  // __VERSION__

// redefinitions
#if (__VERSION__ < 130)
#define in attribute
#define out varying
#endif  // __VERSION__

#ifdef USE_SSO
#ifndef GL_ES
#if (__VERSION__ >= 150)
out gl_PerVertex {
  vec4 gl_Position;
};
#else
// #NOTE: The specs say we need to redeclare built-ins, but 
// Mesa GL 3.1 implementation doesn't like it.
//out vec4 gl_Position;
#endif  // __VERSION__
#endif  // GL_ES
#endif  // USE_SSO

#ifdef USE_UBO
#define BeginBlock(_b) layout(shared) uniform _b {
#define EndBlock };
#define _uniform
// #NOTE: Some drivers don't respect this (eg, Adreno 3xx).
//layout(shared) uniform;
#else
#define BeginBlock(_b)
#define EndBlock
#define _uniform uniform
#endif  // USE_UBO
