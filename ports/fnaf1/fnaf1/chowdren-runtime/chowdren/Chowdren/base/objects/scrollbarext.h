#ifndef CHOWDREN_SCROLLBAREXT_H
#define CHOWDREN_SCROLLBAREXT_H

#include "frameobject.h"
#include "common.h"

class ScrollbarObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(ScrollbarObject)

    static const int button_size = 16;
    static const int grip_min_size = 16;

    enum Button {
        NONE,
        LEFTARROW,
        RIGHTARROW,
        GRIP,
        TRACK,
    };

    bool vertical;
    int min_val;
    int max_val;
    int val;

    Button over; // Last hovered (or currently pressed) button
    bool pressing;
    int drag_click_pos;
    int drag_new_pos;

    ScrollbarObject(int x, int y, int type_id);
    ~ScrollbarObject();

    void set_width(int width);
    void set_height(int height);
    void set_scroll_range(int min, int max);
    int get_value();

    void update();
    void draw();

    // Helpers
    int get_total_size();
    int get_inner_size();
    int get_track_size();
    int pos_to_val(int pos);
    int get_grip_size();
    int get_grip_pos();
    void draw_box(int id, int pos, int size);
    void draw_arrow(int id, int pos);
};

#endif // CHOWDREN_SCROLLBAREXT_H
