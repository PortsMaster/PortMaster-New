#include "objects/advdir.h"
#include "mathcommon.h"

// AdvancedDirection

AdvancedDirection::AdvancedDirection(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
}

void AdvancedDirection::find_closest(ObjectList & instances, int x, int y)
{
    float lowest_dist;
    closest = NULL;
    for (ObjectIterator it(instances); !it.end(); ++it) {
        FrameObject * instance = *it;
        float dist = get_distance(x, y, instance->x, instance->y);
        if (closest != NULL && dist > lowest_dist)
            continue;
        closest = instance;
        lowest_dist = dist;
    }
}

void AdvancedDirection::find_closest(QualifierList & instances, int x, int y)
{
    float lowest_dist;
    closest = NULL;
    for (QualifierIterator it(instances); !it.end(); ++it) {
        FrameObject * instance = *it;
        float dist = get_distance(x, y, instance->x, instance->y);
        if (closest != NULL && dist > lowest_dist)
            continue;
        closest = instance;
        lowest_dist = dist;
    }
}

FixedValue AdvancedDirection::get_closest(int n)
{
    return closest->get_fixed();
}

float AdvancedDirection::get_object_angle(FrameObject * a, FrameObject * b)
{
    return ::get_angle(a->x, a->y, b->x, b->y);
}
