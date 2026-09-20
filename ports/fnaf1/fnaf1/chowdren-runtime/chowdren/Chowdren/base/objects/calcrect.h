#ifndef CHOWDREN_CALCRECT_H
#define CHOWDREN_CALCRECT_H

#include <string>

class CalcRect
{
public:
    static void set_font(const std::string & text, int size, int style);
    static void set_text(const std::string & text);
    static void set_max_width(int width);
    static int get_width();
    static int get_height();
};

#endif // CHOWDREN_CALCRECT_H
