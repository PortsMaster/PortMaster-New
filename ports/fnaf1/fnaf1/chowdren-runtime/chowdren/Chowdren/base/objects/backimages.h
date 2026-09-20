#ifndef CHOWDREN_BACKIMAGES_H
#define CHOWDREN_BACKIMAGES_H

#include "frameobject.h"

/*
This object is actually never rendered, but Heart Forth, Alicia depends on
the storage of some values.
*/

class BackImages : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(BackImages)

    int x_off, y_off;
    bool pattern;

    BackImages(int x, int y, int type_id);
    int get_width(int slot);
};

extern FrameObject * default_backimages_instance;

#endif // CHOWDREN_BACKIMAGES_H
