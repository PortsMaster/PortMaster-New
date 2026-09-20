#ifndef CHOWDREN_WINDOWCONTROL_H
#define CHOWDREN_WINDOWCONTROL_H

#include "frameobject.h"

class WindowControl : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(WindowControl)

    WindowControl(int x, int y, int type_id);

    static int get_x();
    static int get_y();
    static void set_x(int x);
    static void set_y(int y);
    static void set_position(int x, int y);
    static bool has_focus();
    static bool is_maximized();
    static void set_focus(bool value);
    static void set_width(int w);
    static void set_height(int w);
    static void maximize();
    static void restore();
    static int get_width();
    static int get_height();
    static int get_screen_width();
    static int get_screen_height();
    static void set_visible(bool value);
    static void minimize();
    static void set_placement(int value);
};

#endif // CHOWDREN_WINDOWCONTROL_H
