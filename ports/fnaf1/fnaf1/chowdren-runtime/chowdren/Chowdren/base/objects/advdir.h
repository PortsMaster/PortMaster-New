#ifndef CHOWDREN_ADVDIR_H
#define CHOWDREN_ADVDIR_H

#include "frameobject.h"

class AdvancedDirection : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(AdvancedDirection)

    FrameObject * closest;

    AdvancedDirection(int x, int y, int type_id);
    void find_closest(ObjectList & instances, int x, int y);
    void find_closest(QualifierList & instances, int x, int y);
    FixedValue get_closest(int n);
    static float get_object_angle(FrameObject * a, FrameObject * b);
};

#endif // CHOWDREN_ADVDIR_H
