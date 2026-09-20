#ifndef CHOWDREN_PICTURE_H
#define CHOWDREN_PICTURE_H

#include "frameobject.h"
#include <string>
#include "image.h"
#include "collision.h"
#include "types.h"
#include "color.h"

class ActivePicture : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(ActivePicture)

    Image * image;
    bool horizontal_flip;
    std::string filename;
    TransparentColor transparent_color;
    float scale_x, scale_y;
    int angle;
    SpriteCollision sprite_col;

    ActivePicture(int x, int y, int type_id);
    ~ActivePicture();
    void load(const std::string & fn);
    void set_transparent_color(const Color & color);
    void set_hotspot(int x, int y);
    void set_hotspot_mul(float x, float y);
    void set_size(int w, int h);
    void flip_horizontal();
    void set_scale(float value);
    void set_zoom(float value);
    void set_angle(int value, int quality = 0);
    float get_zoom_x();
    int get_width();
    int get_height();
    void draw();
    void paste(int dest_x, int dest_y, int src_x, int src_y,
               int src_width, int src_height, int collision_type);
};

extern FrameObject * default_picture_instance;

#endif // CHOWDREN_PICTURE_H
