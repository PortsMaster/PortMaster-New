#ifndef CHOWDREN_VIEWPORT_H
#define CHOWDREN_VIEWPORT_H

#include "frameobject.h"
#include "render.h"

class Viewport : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(Viewport)

    int center_x, center_y;
    int src_width, src_height;
    Texture texture;
    static Viewport * instance;

    Viewport(int x, int y, int type_id);
    ~Viewport();
    void set_source(int center_x, int center_y, int width, int height);
    void set_width(int w);
    void set_height(int h);
    void draw();
};

#endif // CHOWDREN_VIEWPORT_H
