#ifndef CHOWDREN_MOVEIT_H
#define CHOWDREN_MOVEIT_H

#include "frameobject.h"
#include "types.h"

class MoveIt : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(MoveIt)

    static FlatObjectList queue;
    static FlatObjectList instances;

    MoveIt(int x, int y, int type_id);

    static void add_queue(QualifierList & objs);
    static void move(int x, int y, int speed);
    static void clear_queue();
    static void stop(QualifierList & objs);
    void update();
};

#endif // CHOWDREN_MOVEIT_H
