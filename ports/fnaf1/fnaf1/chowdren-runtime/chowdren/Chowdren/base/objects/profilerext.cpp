#include "objects/profilerext.h"

void ProfilerObject::start(const std::string & name)
{
    profiler.start(name);
}

void ProfilerObject::start_additive(const std::string & name)
{
    profiler.start_additive(name);
}

void ProfilerObject::stop()
{
    profiler.stop();
}

void ProfilerObject::save(const std::string & path)
{
    profiler.save(path);
}

Profiler ProfilerObject::profiler;