#ifndef CHOWDREN_DIRECTSHOW_H
#define CHOWDREN_DIRECTSHOW_H

#include "frameobject.h"
#include "color.h"
#include <string>

class DirectShow : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(DirectShow)

    DirectShow(int x, int y, int type_id);
    void load(const std::string & filename);
    void play();
    void set_width(int width);
    void set_height(int height);
    bool is_playing();
    int get_duration();
    int get_time();
    ~DirectShow();
};

#endif // CHOWDREN_DIRECTSHOW_H
