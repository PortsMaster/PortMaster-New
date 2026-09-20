#ifndef CHOWDREN_SYSTEMBOX_H
#define CHOWDREN_SYSTEMBOX_H

#include "frameobject.h"
#include "color.h"
#include "font.h"
#include <string>

class SystemBox : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(SystemBox)

    enum DrawType
    {
        PATTERN_IMAGE,
        CENTER_IMAGE,
        TOPLEFT_IMAGE
    };

    Image * image;
    int type;
    std::string text;
    FTSimpleLayout * layout;

    SystemBox(int x, int y, int type_id);
    ~SystemBox();
    void set_text(const std::string & text);
    void set_size(int w, int h);
    void draw();
    void hide_border_1();
    void hide_border_2();
    void hide_fill();
    void set_border_1(Color color);
    void set_border_2(Color color);
    void set_fill(Color color);
    const std::string & get_font_name();
};

extern FrameObject * default_systembox_instance;

#endif // CHOWDREN_SYSTEMBOX_H
