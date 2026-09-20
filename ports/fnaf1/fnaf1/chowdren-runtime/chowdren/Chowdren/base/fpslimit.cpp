#include "platform.h"
#include <iostream>
#include "fpslimit.h"
#include <algorithm>

FPSLimiter::FPSLimiter()
: framerate(-1), dt(0.0), current_framerate(0.0)
{
}

void FPSLimiter::set(int value)
{
    framerate = value;
}

double FPSLimiter::normalize(double delta)
{
    if (delta > 1.0)
        return 1.0 / framerate;
    return delta;
}

void FPSLimiter::start()
{
    old_time = platform_get_time();
    next_update = old_time;
}

void FPSLimiter::finish()
{
    double current_time = platform_get_time();

#ifdef CHOWDREN_IS_DESKTOP
    if (framerate < 100) {
        double t = normalize(next_update - current_time);
        platform_sleep(t);
    }
    next_update = std::max(current_time, next_update) + 1.0 / framerate;
#endif

    dt = normalize(current_time - old_time);
    old_time = current_time;
    if (dt < 0.0)
        dt = 0.001;
    current_framerate = 1.0 / dt;
}
