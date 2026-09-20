#ifndef CHOWDREN_BACKDROP_H
#define CHOWDREN_BACKDROP_H

#include "frameobject.h"
#include "chowconfig.h"

class Backdrop : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(Backdrop)

    Image * image;
#if defined(CHOWDREN_IS_WIIU) || defined(CHOWDREN_EMULATE_WIIU)
    int remote;
#endif

    Backdrop(int x, int y, int type_id);
    ~Backdrop();
    void draw();

#ifdef CHOWDREN_USE_BACKMAGIC
    int orig_x, orig_y;

    int get_orig_x()
    {
        return orig_x + layer->off_x;
    }

    int get_orig_y()
    {
        return orig_y + layer->off_y;
    }
#endif

};

#endif // CHOWDREN_BACKDROP_H
