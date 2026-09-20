#ifndef CHOWDREN_SUBAPP_H
#define CHOWDREN_SUBAPP_H

#include "frameobject.h"
#include "events.h"

class SubApplication : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(SubApplication)

    static SubApplication * current;
    Frames subapp_frame;
    int frame_offset;
    bool done;
    bool starting;
    bool old_ignore_controls;

    SubApplication(int x, int y, int id);
    ~SubApplication();
    void restart(int index);
    void update();
    void set_next_frame(int index);
    void set_frame(int index);
};

#endif // CHOWDREN_SUBAPP_H
