#include "objects/scrollbarext.h"
#include "chowconfig.h"

// ScrollbarObject

ScrollbarObject::ScrollbarObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), over(NONE), pressing(false)
{
    flags &= ~SCROLL;
    collision = new InstanceBox(this);
}

ScrollbarObject::~ScrollbarObject()
{
    delete collision;
}

// Helpers

int ScrollbarObject::get_total_size()
{
    return vertical ? height : width;
}

int ScrollbarObject::get_inner_size()
{
    return get_total_size() - 2 * button_size;
}

int ScrollbarObject::get_grip_size()
{
    // Dynamic grip size not worth it
    return 25;
}

int ScrollbarObject::get_track_size()
{
    return get_inner_size() - get_grip_size();
}

int ScrollbarObject::pos_to_val(int pos)
{
    float v = min_val + (max_val - min_val) * ((float)pos / get_track_size());
    return (int)floor(v + 0.5f);
}

int ScrollbarObject::get_grip_pos()
{
    float scroll_rate = (float)(val - min_val) / max_val;
    float pos = scroll_rate * get_track_size();
    return (int)floor(pos + 0.5f);
}

// ACE

void ScrollbarObject::set_width(int width)
{
    this->width = std::max(0, width);
    collision->update_aabb();
}

void ScrollbarObject::set_height(int height)
{
    this->height = std::max(0, height);
    collision->update_aabb();
}

void ScrollbarObject::set_scroll_range(int min, int max)
{
    min_val = min;
    max_val = max;
    val = std::max(min_val, std::min(max_val, val));
}

int ScrollbarObject::get_value()
{
    // While dragging, the new value isn't written yet
    if (over == GRIP && pressing)
        return pos_to_val(drag_new_pos);
    return val;
}


void ScrollbarObject::update()
{
    int mx, my;
    frame->get_mouse_pos(&mx, &my);

    int pos = vertical ? y : x;
    int mouse_pos = (vertical ? my : mx) - pos;
    int grip_total_pos = get_grip_pos() + button_size;
        
    if (!pressing) {
        over = NONE;

        PointCollision col(mx, my);
        if (!collide(&col, collision))
            return;

        if (mouse_pos < button_size)
            over = LEFTARROW;
        else if (mouse_pos >= get_total_size() - button_size)
            over = RIGHTARROW;
        else if (mouse_pos >= grip_total_pos
              && mouse_pos < grip_total_pos + get_grip_size())
            over = GRIP;
    }

    if (is_mouse_pressed_once(SDL_BUTTON_LEFT)) {
        switch (over) {
            case LEFTARROW:
                pressing = true;
                val = std::max(min_val, val - 1);
                break;
            case RIGHTARROW:
                pressing = true;
                val = std::min(max_val, val + 1);
                break;
            case GRIP:
                pressing = true;
                drag_click_pos = mouse_pos;
                break;
        }
    }

    // LMB down on one of the buttons
    if (pressing) {
        if (!is_mouse_pressed(SDL_BUTTON_LEFT)) {
            // Grip was released, apply new position
            if (over == GRIP)
                val = pos_to_val(drag_new_pos);
            pressing = false;
            return;
        }

        // The grip was clicked and is now being dragged
        if (over == GRIP) {
            int delta = mouse_pos - drag_click_pos;
            drag_new_pos = get_grip_pos() + delta;
            drag_new_pos = std::max(0,
                std::min(get_track_size(), drag_new_pos));
        }
    }
}


void ScrollbarObject::draw()
{
    draw_box(TRACK, 0, get_total_size());

    // Grip & arrow buttons overlap, so we need to sort them
    int grip_pos = ((pressing && over == GRIP) ? drag_new_pos : get_grip_pos())
        + button_size;
        
    if (over != GRIP) {
        draw_box(GRIP, grip_pos, get_grip_size());
    }

    draw_box(LEFTARROW, 0, button_size + 1);
    draw_box(RIGHTARROW, get_total_size() - button_size - 1, button_size + 1);

    // Grip is in foreground if hovered/pressed
    if (over == GRIP) {
        draw_box(GRIP, grip_pos, get_grip_size());
    }
}

void ScrollbarObject::draw_box(int id, int pos, int size)
{
    static const Color track_color(204, 206, 217, 255);
    static const Color border_color(106, 107, 110, 255);
    static const Color button_color(240, 240, 240, 255);
    static const Color over_color(136, 137, 140, 255);
    static const Color pressed_color(167, 187, 233, 255);

    float x1, y1, x2, y2;
    if (vertical) {
        x1 = x;
        y1 = y + pos;
        x2 = x + width;
        y2 = y + pos + size;
    } else {
        x1 = x + pos;
        y1 = y;
        x2 = x + pos + size;
        y2 = y + height;
    }

    Color fill = id == TRACK ? track_color : button_color;
    Color outline = over == id ?
        (pressing ? pressed_color : over_color) : border_color;

    Render::draw_quad(x1, y1, x2, y2, outline);
    Render::draw_quad(x1 + 1.f, y1 + 1.f, x2 - 1.f, y2 - 1.f, fill);
    if (id < GRIP) {
        draw_arrow(id, pos + button_size / 2);
    }
}

void ScrollbarObject::draw_arrow(int id, int pos)
{
    static const Color arrow_color(64, 64, 64, 255);

    int x = this->x + (vertical ? (width / 2) : pos);
    int y = this->y + (vertical ? pos : (height / 2));

    if (over == id && pressing) {
        x += 1;
        y += 1;
    }

    float points[] = {
        x - 4, y - 4,
        x + 4, y - 4,
        x + 4, y + 4,
        x - 4, y + 4,
    };
    
    int off;
    if (vertical) {
        off = id == LEFTARROW ? 0 : 4;
        points[off] = x;
        points[off + 2] = x;
    } else {
        off = id == LEFTARROW ? 7 : 3;
        points[off] = y;
        points[(off + 2) % 8] = y;
    }

    Render::draw_quad(&points[0], arrow_color);
}