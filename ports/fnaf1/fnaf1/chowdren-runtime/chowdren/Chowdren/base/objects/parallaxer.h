#ifndef CHOWDREN_PARALLAXER_H
#define CHOWDREN_PARALLAXER_H

#include "frameobject.h"

class Parallaxer : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(Parallaxer)

    Parallaxer(int x, int y, int type_id);
};

#endif // CHOWDREN_PARALLAXER_H
