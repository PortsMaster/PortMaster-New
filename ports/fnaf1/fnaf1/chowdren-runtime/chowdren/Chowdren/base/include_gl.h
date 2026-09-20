#ifndef INCLUDE_GL_H
#define INCLUDE_GL_H

#ifdef CHOWDREN_IS_DESKTOP

#ifdef CHOWDREN_USE_D3D
#define NOMINMAX

#ifndef NDEBUG
#define D3D_DEBUG_INFO
#endif

#include <d3d9.h>

#elif CHOWDREN_USE_GL
// Make SDL's GL header expose the GL 2.0+ shader/uniform/buffer prototypes so
// we can call them directly without runtime function-pointer loading. On
// Linux libGL.so exports all of them; on Windows opengl32.dll only exports
// GL 1.1, so the original function-pointer indirection (still in this file
// for non-shader entry points) is still needed there.
#define GL_GLEXT_PROTOTYPES 1
#include <SDL_opengl.h>

extern PFNGLBLENDEQUATIONSEPARATEEXTPROC __glBlendEquationSeparateEXT;
extern PFNGLBLENDEQUATIONEXTPROC __glBlendEquationEXT;
extern PFNGLBLENDFUNCSEPARATEEXTPROC __glBlendFuncSeparateEXT;
extern PFNGLACTIVETEXTUREARBPROC __glActiveTextureARB;
extern PFNGLCLIENTACTIVETEXTUREARBPROC __glClientActiveTextureARB;
extern PFNGLGENFRAMEBUFFERSEXTPROC __glGenFramebuffersEXT;
extern PFNGLDELETEFRAMEBUFFERSEXTPROC __glDeleteFramebuffersEXT;
extern PFNGLFRAMEBUFFERTEXTURE2DEXTPROC __glFramebufferTexture2DEXT;
extern PFNGLBINDFRAMEBUFFEREXTPROC __glBindFramebufferEXT;

extern PFNGLUSEPROGRAMOBJECTARBPROC __glUseProgramObjectARB;
extern PFNGLDETACHOBJECTARBPROC __glDetachObjectARB;
extern PFNGLGETINFOLOGARBPROC __glGetInfoLogARB;
extern PFNGLGETOBJECTPARAMETERIVARBPROC __glGetObjectParameterivARB;
extern PFNGLLINKPROGRAMARBPROC __glLinkProgramARB;
extern PFNGLCREATEPROGRAMOBJECTARBPROC __glCreateProgramObjectARB;
extern PFNGLATTACHOBJECTARBPROC __glAttachObjectARB;
extern PFNGLCOMPILESHADERARBPROC __glCompileShaderARB;
extern PFNGLSHADERSOURCEARBPROC __glShaderSourceARB;
extern PFNGLCREATESHADEROBJECTARBPROC __glCreateShaderObjectARB;
extern PFNGLUNIFORM1IARBPROC __glUniform1iARB;
extern PFNGLUNIFORM2FARBPROC __glUniform2fARB;
extern PFNGLUNIFORM1FARBPROC __glUniform1fARB;
extern PFNGLUNIFORM4FARBPROC __glUniform4fARB;
extern PFNGLGETUNIFORMLOCATIONARBPROC __glGetUniformLocationARB;

#define glBlendEquation __glBlendEquationEXT
#define glBlendEquationSeparate __glBlendEquationSeparateEXT
#define glBlendFuncSeparate __glBlendFuncSeparateEXT
#define glActiveTexture __glActiveTextureARB
#define glClientActiveTexture __glClientActiveTextureARB
#define glGenFramebuffers __glGenFramebuffersEXT
#define glDeleteFramebuffers __glDeleteFramebuffersEXT
#define glBindFramebuffer __glBindFramebufferEXT
#define glFramebufferTexture2D __glFramebufferTexture2DEXT

// Route shader entry points through the standard GL 2.0+ symbols so tools like
// RenderDoc can hook them. Linux libGL.so exports all of these directly, so the
// ARB function-pointer loading in platform.cpp is no longer needed for them
// (those pointers still get loaded but go unused — harmless).
#define glUseProgramObject glUseProgram
#define glDetachObject glDetachShader
#define glCreateProgramObject glCreateProgram
#define glAttachObject glAttachShader
#define glCreateShaderObject glCreateShader
// glLinkProgram, glCompileShader, glShaderSource, glUniform*, glGetUniformLocation
// already match their standard names — no redirect needed.
// glGetObjectParameteriv and glGetInfoLog have no single-name standard
// equivalent (split into glGetProgramiv/glGetShaderiv and
// glGetProgramInfoLog/glGetShaderInfoLog) — call sites use the split forms.

#elif CHOWDREN_USE_GLES1
#include <SDL_opengles.h>

#elif CHOWDREN_USE_GLES2
#include <SDL_opengles2.h>

#endif // CHOWDREN_USE_GL

#undef TRANSPARENT

#endif // CHOWDREN_IS_DESKTOP

#endif // INCLUDE_GL_H
