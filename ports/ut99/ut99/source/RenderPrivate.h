#pragma once

// The public 469e SDK exposes the renderer interfaces through Render.h.
// NOpenGLESDrv only needs those public types; the v400 tree called the same
// umbrella header RenderPrivate.h.
#include "Render.h"

// 469e defines DLL_EXPORT as extern "C" for exported entry points. The older
// renderer source placed it on the C++ class itself, where that spelling is not
// valid. ELF class visibility is already global by default.
#undef DLL_EXPORT
#define DLL_EXPORT
