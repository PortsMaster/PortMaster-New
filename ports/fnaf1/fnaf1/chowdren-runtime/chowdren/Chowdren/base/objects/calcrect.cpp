#include "objects/calcrect.h"
#include "font.h"
#include "common.h"
#include <iostream>

static std::string calc_text;
static FTSimpleLayout layout;
static bool layout_init = false;
static int calc_width, calc_height;
static int calc_max_width = 1000000;

void CalcRect::set_text(const std::string & text)
{
    if (calc_text == text)
        return;
    if (!layout_init)
        set_font(empty_string, 12, 0);
    calc_text = text;
    FTBBox bb = layout.BBox(text.c_str(), -1);
    calc_width = bb.Upper().X() - bb.Lower().X();
    calc_height = bb.Upper().Y() - bb.Lower().Y();
    // std::cout << "calc size: " << text << " " << calc_width << " "
    //     << calc_height << std::endl;
    // std::cout << "CalcRect: Set text: " << text << std::endl;
}

void CalcRect::set_font(const std::string & font_name, int size, int style)
{
    if (layout_init)
        return;
    layout_init = true;
    if (!init_font())
        return;
    FTTextureFont * font = get_font(size);
    layout.SetFont(font);
    layout.SetLineLength(calc_max_width);
    // std::cout << "CalcRect: Set font: " << font << " " << size << " "
    //     << style << std::endl;
}

void CalcRect::set_max_width(int width)
{
    calc_max_width = width;
    layout.SetLineLength(calc_max_width);
    // std::cout << "CalcRect: Set max width: " << width << std::endl;
}

int CalcRect::get_width()
{
    return calc_width + 2;
}

int CalcRect::get_height()
{
    return calc_height;
}
