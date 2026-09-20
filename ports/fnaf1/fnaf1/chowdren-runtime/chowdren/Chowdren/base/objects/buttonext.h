#ifndef CHOWDREN_BUTTONEXT_H
#define CHOWDREN_BUTTONEXT_H

#include "frameobject.h"

class ButtonObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(ButtonObject)

    ButtonObject(int x, int y, int type_id);
};

#endif // CHOWDREN_BUTTONEXT_H
