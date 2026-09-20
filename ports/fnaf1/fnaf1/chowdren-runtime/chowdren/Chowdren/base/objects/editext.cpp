#include "objects/editext.h"

// EditObject

#ifndef CHOWDREN_USE_EDITOBJ

EditObject::EditObject(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
}

void EditObject::set_text(const std::string & value)
{

}

const std::string & EditObject::get_text()
{
    return empty_string;
}

bool EditObject::get_focus()
{
    return true;
}

void EditObject::set_limit(int size)
{
    std::cout << "Edit: set_limit not implemented" << std::endl;
}

void EditObject::disable_focus()
{
    std::cout << "Edit: disable_focus not implemented" << std::endl;
}


void EditObject::enable_focus()
{
    std::cout << "Edit: enable_focus not implemented" << std::endl;
}

#else

EditObject::EditObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), edit_flags(0), edit_col(this), font(get_font(14))
{
    collision = &edit_col;
}

void EditObject::update()
{
    if (is_mouse_pressed_once(SDL_BUTTON_LEFT)) {
        int mx, my;
        frame->get_mouse_pos(&mx, &my);
        PointCollision col(mx, my);
        if (collide(&col, &edit_col))
            edit_flags |= FOCUS;
        else
            edit_flags &= ~FOCUS;
    }

    if (!(edit_flags & FOCUS))
        return; 
    text += manager.input;

    if (is_key_pressed_once(SDLK_BACKSPACE))
        text = text.substr(0, text.size() - 1);
    if (is_key_pressed_once(SDLK_RETURN))
        edit_flags &= ~FOCUS;
}

void EditObject::draw()
{
    if (!init_font()) {
        set_visible(false);
        return;
    }

    // black background

    Render::draw_quad(x, y, x + width, y + height, Color(0, 0, 0, 255));

    // content box
    const float off = 1.0f;
    float x1 = x + off;
    float y1 = y + off;
    float x2 = x + width - off;
    float y2 = y + height - off;

    Color color;
    if (edit_flags & FOCUS)
        color.set(230, 230, 230, 255);
    else
        color.set(255, 255, 255, 255);

    Render::draw_quad(x1, y1, x2, y2, color);

    FTTextureFont::color.set(0, 0, 0, 255);
    float xx = x1 + 5.0f;
    int yy = y + font->Ascender() + height * 0.5 - font->LineHeight() * 0.5;
    font->Render(text.c_str(), -1, FTPoint(xx, yy), FTPoint());
}

void EditObject::set_text(const std::string & value)
{
    text = value;
}

const std::string & EditObject::get_text()
{
    return text;
}

bool EditObject::get_focus()
{
    return (edit_flags & FOCUS) != 0;
}

void EditObject::set_limit(int size)
{
    std::cout << "Edit: set_limit not implemented" << std::endl;
}

void EditObject::disable_focus()
{
    edit_flags &= ~FOCUS;
}


void EditObject::enable_focus()
{
    edit_flags |= FOCUS;
}

#endif
