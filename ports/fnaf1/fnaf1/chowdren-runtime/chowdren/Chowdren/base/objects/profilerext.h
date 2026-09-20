#ifndef CHOWDREN_PROFILEREXT_H
#define CHOWDREN_PROFILEREXT_H

#include <string>
#include "profilerimpl.h"

class ProfilerObject
{
public:
    static Profiler profiler;

    static void start(const std::string & name);
    static void start_additive(const std::string & name);
    static void stop();
    static void save(const std::string & path);
};

#endif // CHOWDREN_PROFILEREXT_H
