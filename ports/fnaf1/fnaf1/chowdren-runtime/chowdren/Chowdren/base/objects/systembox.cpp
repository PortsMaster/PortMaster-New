#include "objects/systembox.h"
#include "include_gl.h"
#include "collision.h"
#include <iostream>
#include "render.h"
#include "common.h"

SystemBox::SystemBox(int x, int y, int type_id)
: FrameObject(x, y, type_id), layout(NULL)
{
    collision = new InstanceBox(this);
}

SystemBox::~SystemBox()
{
    delete collision;
}

inline int align_pos(int a, int b)
{
    if (a <= 0)
        return 0;
    return (a / b) * b;
}

void SystemBox::draw()
{
    if (image == NULL) {
        int x1 = x;
        int y1 = y;
        int x2 = x1 + width;
        int y2 = y1 + height;
        Render::draw_quad(x1, y1, x2, y2, Color(0, 0, 0));
        x1++;
        y1++;
        x2--;
        y2--;
        Render::draw_quad(x1, y1, x2, y2, blend_color);

        FTTextureFont * font;
        if (layout == NULL) {
            if (!init_font())
                return;
            layout = new FTSimpleLayout();
            font = get_font(12);
            layout->SetFont(font);
            layout->SetAlignment(ALIGN_HCENTER);
            layout->SetLineLength(width);
        } else {
            font = get_font(12);
        }

        double off_y = y + font->Ascender();

        FTBBox bb = layout->BBox(text.c_str(), -1);
        double box_h = bb.Upper().Y() - bb.Lower().Y(); 
        off_y += (height - box_h) * 0.5;

        FTTextureFont::color = Color(0, 0, 0, 255);
        layout->Render(text.c_str(), -1, FTPoint(x, int(off_y) - 1));
        // std::cout << "Draw system text: " << text << " " << name << std::endl;
        return;
    }
    int xx, yy;
    switch (type) {
        case PATTERN_IMAGE: {
            // XXX use Render::offset for offset here?
            int screen_x1 = 0 - (layer->off_x - frame->off_x);
            int screen_y1 = 0 - (layer->off_y - frame->off_y);
            int screen_x2 = screen_x1 + WINDOW_WIDTH;
            int screen_y2 = screen_y1 + WINDOW_HEIGHT;

            int x1 = x;
            int y1 = y;
            int x2 = x + width;
            int y2 = y + height;

            int xx1, yy1, xx2, yy2;
            intersect(screen_x1, screen_y1, screen_x2, screen_y2,
                      x1, y1, x2, y2,
                      xx1, yy1, xx2, yy2);

            x1 += ((xx1 - x1) / image->width) * image->width;
            y1 += ((yy1 - y1) / image->height) * image->height;
            x2 += ((xx2 - x2) / image->width) * image->width;
            y2 += ((yy2 - y2) / image->height) * image->height;

            Render::enable_scissor(x, y, width, height);
            for (xx = x1; xx < x2; xx += image->width)
            for (yy = y1; yy < y2; yy += image->height) {
                draw_image(image, xx + image->hotspot_x,
                           yy + image->hotspot_y, Color());
            }
			Render::disable_scissor();
            break;
        }
        case CENTER_IMAGE:
            xx = x + width / 2 - image->width / 2;
            yy = y + height / 2 - image->height / 2;
            draw_image(image, xx + image->hotspot_x, yy + image->hotspot_y,
                       Color());
            break;
        case TOPLEFT_IMAGE:
            draw_image(image, x + image->hotspot_x, y + image->hotspot_y,
                       Color());
            break;
        default:
            break;
    }
}

void SystemBox::hide_border_1()
{
    // std::cout << "Hide System Box border 1 not implemented" << std::endl;
}

void SystemBox::hide_border_2()
{
    // std::cout << "Hide System Box border 1 not implemented" << std::endl;
}

void SystemBox::hide_fill()
{
    // std::cout << "Hide System Box fill not implemented" << std::endl;
}

void SystemBox::set_size(int w, int h)
{
    width = w;
    height = h;
    collision->update_aabb();
    if (layout == NULL)
        return;
    layout->SetLineLength(width);
}

void SystemBox::set_text(const std::string & text)
{
    this->text = text;
}

void SystemBox::set_border_1(Color color)
{

}

void SystemBox::set_border_2(Color color)
{

}

void SystemBox::set_fill(Color color)
{
    blend_color = color;
}

const std::string & SystemBox::get_font_name()
{
    return empty_string;
}

class DefaultInstance : public SystemBox
{
public:
    DefaultInstance()
    : SystemBox(0, 0, 0)
    {
        collision = new InstanceBox(this);
        create_alterables();
        setup_default_instance(this);
    }
};

static DefaultInstance default_systembox;
FrameObject * default_systembox_instance = &default_systembox;
