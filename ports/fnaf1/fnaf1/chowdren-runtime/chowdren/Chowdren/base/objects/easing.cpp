#include "objects/easing.h"
#include "mathcommon.h"

struct EaseVars
{
    float overshoot;
    float amplitude;
    float period;
};

static double linear(double step, const EaseVars & vars)
{
    return step;
}

static double quad(double step, const EaseVars & vars)
{
    return pow(step, 2.0);
}

static double cubic(double step, const EaseVars & vars)
{
    return pow(step, 3.0);
}

static double quart(double step, const EaseVars & vars)
{
    return pow(step, 4.0);
}

static double quint(double step, const EaseVars & vars)
{
    return pow(step, 5.0);
}

static double sine(double step, const EaseVars & vars)
{
    return 1.0-sin((1-step)*90.0 * CHOW_PI/180.0);
}

static double expo(double step, const EaseVars & vars)
{
    return pow(2.0, step*10.0)/1024.0;
}

static double circ(double step, const EaseVars & vars)
{
    return 1.0f-sqrt(1.0-pow(step,2.0));
}

static double back(double step, const EaseVars & vars)
{
    return (vars.overshoot+1.0)* pow(step, 3.0) -
           vars.overshoot*pow(step, 2.0);
}

static double elastic(double step, const EaseVars & vars)
{
    step -= 1.0;
    float amp = (float)std::max(1.0f, vars.amplitude);
    float s = (float)(vars.period / (2.0 * CHOW_PI) * asin(1.0 / amp));
    return -(amp*pow(2.0,10*step) * sin((step-s)*(2*CHOW_PI)/vars.period));
}

static double bounce(double step, const EaseVars & vars)
{
    step = 1-step;
    if (step < (8/22.0))
        return 1 - 7.5625*step*step;
    else if (step < (16/22.0)) {
        step -= 12/22.0;
        return 1 - vars.amplitude*(7.5625*step*step + 0.75) -
               (1-vars.amplitude);
    } else if (step < (20/22.0)) {
        step -= 18/22.0;
        return 1 - vars.amplitude*(7.5625*step*step + 0.9375) -
               (1-vars.amplitude);
    } else {
        step -= 21/22.0;
        return 1 - vars.amplitude*(7.5625*step*step + 0.984375) -
               (1-vars.amplitude);
    }
}

static double ease_function(int number, double step, const EaseVars & vars)
{
    switch (number) {
        default:
        case 0:
            return linear(step, vars);
        case 1:
            return quad(step, vars);
        case 2:
            return cubic(step, vars);
        case 3:
            return quart(step, vars);
        case 4:
            return quint(step, vars);
        case 5:
            return sine(step, vars);
        case 6:
            return expo(step, vars);
        case 7:
            return circ(step, vars);
        case 8:
            return back(step, vars);
        case 9:
            return elastic(step, vars);
        case 10:
            return bounce(step, vars);
    }
}

static double ease_out(int function, double step, const EaseVars & vars)
{
    return 1.0-ease_function(function, 1.0-step, vars);
}

float EasingObject::ease_out(int a, int b, int function, double step)
{
    EaseVars vars = {1.5f, 1.05f, 0.4f}; // default
    float ease = ::ease_out(function, float(step), vars);
    if (ease <= 0.000001f)
        return a;
    return a + (b-a)*ease;
}
