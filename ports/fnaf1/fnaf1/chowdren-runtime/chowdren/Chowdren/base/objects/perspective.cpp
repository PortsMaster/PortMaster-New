#include "objects/perspective.h"
#include "include_gl.h"
#include "collision.h"
#include <iostream>
#include "render.h"

PerspectiveObject::PerspectiveObject(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
    collision = new InstanceBox(this);

    set_shader(Render::PERSPECTIVE);

    // Match Clickteam Perspective.mfx runtime behavior: the wavy editor
    // preview values (e.g. zoom=300) are not auto-applied at runtime — the
    // object is hidden until the game's events explicitly show it. Without
    // this, FnaF (and similar) get the editor's preview distortion painted
    // over the entire frame on layer 1.
    flags &= ~VISIBLE;
}

PerspectiveObject::~PerspectiveObject()
{
    delete collision;
}

void PerspectiveObject::set_width(int width)
{
    this->width = width;
    collision->update_aabb();
}

void PerspectiveObject::draw()
{
    int box[4];
    get_screen_aabb(box);
    Texture t = Render::copy_rect(box[0], box[1], box[2], box[3]);
    begin_draw();
    Render::disable_blend();
    Render::draw_tex(x, y, x + width, y + height, Color(255, 255, 255, 255),
                     t,
                     back_texcoords[0], back_texcoords[1],
                     back_texcoords[2], back_texcoords[3]);
    Render::enable_blend();
    end_draw();
}

void PerspectiveObject::set_waves(double value)
{
    set_shader_parameter("sine_waves", value);
}

void PerspectiveObject::set_zoom(double value)
{
    set_shader_parameter("zoom", std::max(0.0, value));
}

void PerspectiveObject::set_offset(double value)
{
    set_shader_parameter("offset", value);
}
