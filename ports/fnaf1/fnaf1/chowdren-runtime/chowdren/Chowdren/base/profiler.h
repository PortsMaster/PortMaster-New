#ifndef CHOWDREN_PROFILER_H
#define CHOWDREN_PROFILER_H

#include "chowconfig.h"

#ifdef CHOWDREN_USE_PROFILER
#include "profiler/Shiny.h"
#else
#define PROFILE_BLOCK(x)
#define PROFILE_FUNC()
#define PROFILE_BEGIN(x)
#define PROFILE_END()
#endif

#endif
