#ifndef CHOWDREN_COMBOBOX_H
#define CHOWDREN_COMBOBOX_H

#include "frameobject.h"
#include <string>
#include "datastream.h"
#include "types.h"

class ComboBox : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(ComboBox)

    ComboBox(int x, int y, int type_id);
};

#endif // CHOWDREN_COMBOBOX_H
