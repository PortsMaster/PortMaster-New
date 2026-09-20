#include "manager.h"
#include "subapp.h"

static bool has_ignore_controls = false;
static bool ignore_controls = false;

SubApplication::SubApplication(int x, int y, int id)
: FrameObject(x, y, id)
{
    current = this;
}

SubApplication::~SubApplication()
{
    Frame * old_frame = manager.frame;
    manager.frame = &subapp_frame;
    subapp_frame.data->on_app_end();
    manager.frame = old_frame;

	if (current == this)
		current = NULL;

    if (has_ignore_controls) {
        manager.ignore_controls = ignore_controls;
        has_ignore_controls = false; 
    }
}

void SubApplication::set_next_frame(int index)
{
    if (starting)
        return;
    subapp_frame.next_frame = index + frame_offset;
}

void SubApplication::restart(int index)
{
    done = false;
    starting = true;
    subapp_frame.next_frame = index + frame_offset;
}

void SubApplication::update()
{
    if (done)
        return;
    starting = false;
    Frame * old_frame = manager.frame;
    manager.frame = &subapp_frame;

    if (subapp_frame.next_frame != -1) {
        int next_frame = subapp_frame.next_frame;
        if (subapp_frame.index != -1)
            subapp_frame.on_end();
        set_frame(next_frame);
    }

    bool ret = subapp_frame.update();

    if (!ret)
        subapp_frame.on_end();

    manager.frame = old_frame;

    if (ret)
        return;
    done = true;
    manager.ignore_controls = old_ignore_controls;
    set_visible(false);
}

void SubApplication::set_frame(int index)
{
    done = false;
    subapp_frame.set_index(index);

    if (!has_ignore_controls) {
        ignore_controls = manager.ignore_controls;
        manager.ignore_controls = false;
        has_ignore_controls = true; 
    }
}

SubApplication * SubApplication::current = NULL;
