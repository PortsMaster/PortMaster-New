#ifndef CHOWDREN_MASKEDTEXT_H
#define CHOWDREN_MASKEDTEXT_H

#include "frameobject.h"

/*
This object is actually never rendered, but Heart Forth, Alicia depends on
the storage of some values.
*/

class MaskedText : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(MaskedText)

    std::string text;

    MaskedText(int x, int y, int type_id);
};

#endif // CHOWDREN_MASKEDTEXT_H
