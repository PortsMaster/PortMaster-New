// Clip plane outputs for portal rendering.
// - Desktop GL: user-declared gl_ClipDistance array.
// - GLES + GL_EXT_clip_cull_distance: built-in gl_ClipDistance from the extension.
// - GLES without extension: varyings + fragment discard (TFE_CLIP_DISCARD_FALLBACK).
#ifdef TFE_HAS_CLIP_CULL_DISTANCE
#define TFE_CLIP_SET(i, val) gl_ClipDistance[i] = (val)
#elif defined(TFE_CLIP_DISCARD_FALLBACK)
out float v_TfeClipDistance[8];
#define TFE_CLIP_SET(i, val) v_TfeClipDistance[i] = (val)
#else
out float gl_ClipDistance[8];
#define TFE_CLIP_SET(i, val) gl_ClipDistance[i] = (val)
#endif
