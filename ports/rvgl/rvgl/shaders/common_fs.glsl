#ifdef DEBUG
#line 3
#endif  // DEBUG

#ifdef GL_ES
#ifdef USE_HIGHP
precision highp float;
precision highp int;
#else
precision mediump float;
precision mediump int;
#endif  // __VERSION__
#endif  // GL_ES

#ifdef USE_HIGHP
#define _mediump
#else
#define _mediump mediump
#endif  // USE_HIGHP

// redefinitions
#if (__VERSION__ < 130)
#define in varying
#define texture texture2D
#define outColor gl_FragColor
#endif  // __VERSION__

#ifdef USE_UBO
#define BeginBlock(_b) layout(shared) uniform _b {
#define EndBlock };
#define _uniform
#else
#define BeginBlock(_b)
#define EndBlock
#define _uniform uniform
#endif  // USE_UBO

// output
#if (__VERSION__ >= 130)
out vec4 outColor;
#endif  // __VERSION__
