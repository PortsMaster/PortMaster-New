#include "colorizer.h"

ColorizerObject::ColorizerObject(int x, int y, int id)
: FrameObject(x, y, id), r(1.0f), g(1.0f), b(1.0f)
{

}

inline float round_color(float v)
{
    return int(v * 256.0f) / 256.0f;
}

void ColorizerObject::set_red(float v)
{
    r = round_color(v);
}

void ColorizerObject::set_green(float v)
{
    g = round_color(v);
}

void ColorizerObject::set_blue(float v)
{
    b = round_color(v);
}
