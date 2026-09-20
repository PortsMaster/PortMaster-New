#ifndef CHOWDREN_PERSPECTIVE_H
#define CHOWDREN_PERSPECTIVE_H

#include "frameobject.h"

class PerspectiveObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(PerspectiveObject)

    PerspectiveObject(int x, int y, int type_id);
    ~PerspectiveObject();
    void draw();
    void set_waves(double value);
    void set_zoom(double value);
    void set_offset(double value);
    void set_width(int width);
};

#endif // CHOWDREN_PERSPECTIVE_H
