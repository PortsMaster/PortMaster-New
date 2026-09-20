#ifndef CHOWDREN_QUICKBACKDROP_H
#define CHOWDREN_QUICKBACKDROP_H

#include "frameobject.h"
#include "chowconfig.h"
#include "color.h"

class QuickBackdrop : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(QuickBackdrop)

    Color color;
    int gradient_type;
    Color color2;
    Color outline_color;
    int outline;
    Image * image;

    QuickBackdrop(int x, int y, int type_id);
    ~QuickBackdrop();
    void draw();

#ifdef CHOWDREN_LAYER_WRAP
    int x_offset, y_offset;
    void set_backdrop_offset(int dx, int dy);
#endif
};

#endif // CHOWDREN_QUICKBACKDROP_H
