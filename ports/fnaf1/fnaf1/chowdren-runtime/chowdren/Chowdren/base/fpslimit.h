#ifndef CHOWDREN_FPSLIMIT_H
#define CHOWDREN_FPSLIMIT_H

class FPSLimiter
{
public:
    int framerate;
    double current_framerate;
    double old_time;
    double next_update;
    double dt;

    FPSLimiter();
    void set(int value);
    void start();
    void finish();
    double normalize(double delta);
};

#endif // CHOWDREN_FPSLIMIT_H
