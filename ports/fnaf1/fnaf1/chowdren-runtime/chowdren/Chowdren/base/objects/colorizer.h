#ifndef CHOWDREN_COLORIZER_H
#define CHOWDREN_COLORIZER_H

#include "frameobject.h"

class ColorizerObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(ColorizerObject)

    float r, g, b;

    ColorizerObject(int x, int y, int type_id);
    void set_red(float r);
    void set_green(float g);
    void set_blue(float b);
};

#endif // CHOWDREN_COLORIZER_H
