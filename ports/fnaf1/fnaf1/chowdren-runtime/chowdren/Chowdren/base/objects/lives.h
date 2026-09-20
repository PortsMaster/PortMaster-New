#ifndef CHOWDREN_LIVES_H
#define CHOWDREN_LIVES_H

#include "frameobject.h"
#include "chowconfig.h"
#include "image.h"

class Lives : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(Lives)

    Image * image;
    float flash_time;
    float flash_interval;

    Lives(int x, int y, int type_id);
    ~Lives();
    void update();
    void flash(float value);
    void draw();
};

#endif // CHOWDREN_LIVES_H
