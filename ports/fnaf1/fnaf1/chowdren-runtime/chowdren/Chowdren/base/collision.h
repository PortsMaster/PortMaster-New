#ifndef CHOWDREN_COLLISION_H
#define CHOWDREN_COLLISION_H

#include "frame.h"
#include <algorithm>
#include "mathcommon.h"
#include "broadphase.h"
#include "image.h"

bool collide(CollisionBase * a, CollisionBase * b);

enum CollisionType
{
    NONE_COLLISION,
    BACKDROP_COLLISION,
    BACKGROUND_ITEM,
    SPRITE_COLLISION,
    TRANSFORM_SPRITE_COLLISION,
    SPRITE_BOX,
    INSTANCE_BOX,
    BOUNDING_BOX,
};

enum CollisionFlags
{
    BOX_COLLISION = 1 << 0,
    LADDER_OBSTACLE = 1 << 1
};

class CollisionBase
{
public:
    int aabb[4];
    int flags;
    CollisionType type;

    CollisionBase(CollisionType type, int flags)
    : flags(flags), type(type)
    {
    }

    virtual ~CollisionBase()
    {
    }
};

inline bool collide_line(int x1, int y1, int x2, int y2,
                         int line_x1, int line_y1, int line_x2, int line_y2)
{
    float delta;
    if (line_x2 - line_x1 > line_y2 - line_y1) {
        delta = float(line_y2 - line_y1) / (line_x2 - line_x1);
        if (line_x2 > line_x1) {
            if (x2 < line_x1 || x1 >= line_x2)
                return false;
        } else {
            if (x2 < line_x2 || x1 >= line_x1)
                return false;
        }
        int y = int(delta * (x1 - line_x1) + line_y1);
        if (y >= y1 && y < y2)
            return true;
        y = int(delta * (x2 - line_x1) + line_y1);
        if (y >= y1 && y < y2)
            return true;
        return false;
    } else {
        delta = float(line_x2 - line_x1) / (line_y2 - line_y1);
        if (line_y2 > line_y1) {
            if (y2 < line_y1 || y2 >= line_y2)
                return false;
        } else {
            if (y2 < line_y2 || y1 >= line_y1)
                return false;
        }
        int x = int(delta * (y1 - line_y1) + x1);
        if (x >= x1 && x < x2)
            return true;
        x = int(delta * (y2 - line_y1) + x1);
        if (x >= x1 && x < x2)
            return true;
        return false;
    }
}

class InstanceCollision : public CollisionBase
{
public:
    FrameObject * instance;
    int proxy;

    InstanceCollision(FrameObject * instance, CollisionType type, int flags)
    : instance(instance), CollisionBase(type, flags), proxy(-1)
    {
    }

    ~InstanceCollision()
    {
        remove_proxy();
    }

    void remove_proxy()
    {
        if (proxy == -1)
            return;
        instance->layer->broadphase.remove(proxy);
        proxy = -1;
    }

    void create_proxy()
    {
        if (proxy != -1)
            return;
        proxy = instance->layer->broadphase.add(instance, aabb);
    }

    void create_static_proxy()
    {
        if (proxy != -1)
            return;
        proxy = instance->layer->broadphase.add_static(instance, aabb);
    }

    void update_proxy()
    {
        instance->flags &= ~(HAS_COLLISION_CACHE | HAS_COLLISION);
        if (proxy == -1)
            return;
        instance->layer->broadphase.move(proxy, aabb);
    }

    virtual void update_aabb()
    {
    }
};

class InstanceBox : public InstanceCollision
{
public:
    InstanceBox(FrameObject * instance)
    : InstanceCollision(instance, INSTANCE_BOX, BOX_COLLISION)
    {
    }

    void update_aabb()
    {
        aabb[0] = instance->x;
        aabb[1] = instance->y;
        aabb[2] = aabb[0] + instance->width;
        aabb[3] = aabb[1] + instance->height;
        update_proxy();
    }
};

class OffsetInstanceBox : public InstanceCollision
{
public:
    int off_x, off_y;

    OffsetInstanceBox(FrameObject * instance)
    : InstanceCollision(instance, INSTANCE_BOX, BOX_COLLISION),
      off_x(0), off_y(0)
    {
    }

    void update_aabb()
    {
        aabb[0] = instance->x + off_x;
        aabb[1] = instance->y + off_y;
        aabb[2] = aabb[0] + instance->width;
        aabb[3] = aabb[1] + instance->height;
        update_proxy();
    }

    void set_offset(int x, int y)
    {
        off_x = x;
        off_y = y;
        update_aabb();
    }
};

inline void transform_rect(float xx, float yy, float co, float si,
                           int & x1, int & y1, int & x2, int & y2)
{
    if (co >= 0.0f) {
        if (si >= 0.0f) {
            x1 = 0;
            y1 = int(xx * -si);
            x2 = int(xx * co + yy * si);
            y2 = int(yy * co);
        } else {
            x1 = int(yy * si);
            y1 = 0;
            x2 = int(xx * co);
            y2 = int(yy * co - xx * si);
        }
    } else {
        if (si >= 0.0f) {
            x1 = int(xx * co);
            y1 = int(yy * co - xx * si);
            x2 = int(yy * si);
            y2 = 0;
        } else {
            x1 = int(xx * co + yy * si);
            y1 = int(yy * co);
            x2 = 0;
            y2 = int(-xx * si);
        }
    }
}

#define INTEGER_GET_BIT

#ifdef INTEGER_GET_BIT
#define CONVERT_SCALER(x) (int((x) * 0x8000))
#define GET_SCALER_RESULT(x) ((x) / 0x8000)
#else
#define CONVERT_SCALER(x) x
#define GET_SCALER_RESULT(x) (int(x))
#endif

class SpriteCollision : public InstanceCollision
{
public:
    Image * image;
    float angle;
    float x_scale, y_scale;
    int hotspot_x, hotspot_y;
    // transformed variables
    float co, si;
#ifdef INTEGER_GET_BIT
    int co_divx, si_divx, co_divy, si_divy;
#else
    float co_divx, si_divx, co_divy, si_divy;
#endif
    int x_t, y_t; // transformed offset
    int width, height;
    int new_hotspot_x, new_hotspot_y;

    SpriteCollision(FrameObject * instance = NULL)
    : InstanceCollision(instance, SPRITE_COLLISION, 0), image(NULL),
      angle(0.0f), x_scale(1.0f), y_scale(1.0f), co(1.0f),
      si(0.0f), hotspot_x(0), hotspot_y(0), width(0), height(0), x_t(0), y_t(0)
    {
    }

    void set_hotspot(int x, int y)
    {
        hotspot_x = x;
        hotspot_y = y;
        update_transform();
    }

    void set_image(Image * image, int hotspot_x, int hotspot_y)
    {
        this->image = image;
        this->hotspot_x = hotspot_x;
        this->hotspot_y = hotspot_y;
        update_transform();
    }

    void set_angle(float value)
    {
        angle = value;
        if (value == 0.0f) {
            co = 1.0f;
            si = 0.0;
        } else if (value == 90.0f) {
            co = 0.0f;
            si = 1.0f;
        } else if (value == 180.0f) {
            co = -1.0;
            si = 0.0f;
        } else if (value == 270.0f) {
            co = 0.0f;
            si = -1.0f;
        } else {
            float r = rad(angle);
            co = cos(r);
            si = sin(r);
        }
        update_transform();
    }

    void set_scale(float value)
    {
        x_scale = y_scale = value;
        update_transform();
    }

    void set_scale(float sx, float sy)
    {
        x_scale = sx;
        y_scale = sy;
        update_transform();
    }

    void set_x_scale(float x)
    {
        x_scale = x;
        update_transform();
    }

    void set_y_scale(float y)
    {
        y_scale = y;
        update_transform();
    }

    void update_transform()
    {
        bool no_scale = x_scale == 1.0f && y_scale == 1.0f;
        bool no_rotate = angle == 0.0f;
        if (no_scale && no_rotate) {
            width = image->width;
            height = image->height;
            new_hotspot_x = hotspot_x;
            new_hotspot_y = hotspot_y;
            x_t = y_t = 0;
            if (type != NONE_COLLISION) {            
                if (flags & BOX_COLLISION)
                    type = SPRITE_BOX;
                else
                    type = SPRITE_COLLISION;
            }
            update_aabb();
            return;
        }

        if (type != NONE_COLLISION)
            type = TRANSFORM_SPRITE_COLLISION;

        float xx = image->width * x_scale;
        float yy = image->height * y_scale;
        float x_scale_inv = 1.0f / x_scale;
        float y_scale_inv = 1.0f / y_scale;

        if (no_rotate) {
            co_divx = CONVERT_SCALER(x_scale_inv);
            co_divy = CONVERT_SCALER(y_scale_inv);
            si_divx = si_divy = 0.0f;
            width = int(xx);
            height = int(yy);
            x_t = y_t = 0;
            new_hotspot_x = int(hotspot_x * x_scale);
            new_hotspot_y = int(hotspot_y * y_scale);
            update_aabb();
            return;
        }

        co_divx = CONVERT_SCALER(co * x_scale_inv);
        co_divy = CONVERT_SCALER(co * y_scale_inv);
        si_divx = CONVERT_SCALER(si * x_scale_inv);
        si_divy = CONVERT_SCALER(si * y_scale_inv);

        int x2, y2;
        transform_rect(xx, yy, co, si, x_t, y_t, x2, y2);
        width = x2 - x_t;
        height = y2 - y_t;
        get_transform(hotspot_x, hotspot_y,
                      new_hotspot_x, new_hotspot_y);
        update_aabb();
    }

    void get_transform(int x, int y, int & r_x, int & r_y)
    {
        if (type == SPRITE_COLLISION) {
            r_x = x;
            r_y = y;
            return;
        }
        float xx = x * x_scale;
        float yy = y * y_scale;
        int new_x = int(xx * co + yy * si);
        int new_y = int(yy * co - xx * si);
        r_x = new_x - x_t;
        r_y = new_y - y_t;
    }

    void update_aabb()
    {
        aabb[0] = instance->x - new_hotspot_x;
        aabb[1] = instance->y - new_hotspot_y;
        aabb[2] = aabb[0] + width;
        aabb[3] = aabb[1] + height;
        update_proxy();
    }
};

class BackdropCollision : public InstanceCollision
{
public:
    Image * image;

    BackdropCollision(FrameObject * instance, Image * image)
    : InstanceCollision(instance, BACKDROP_COLLISION, 0), image(image)
    {
        this->image = image;
    }

    void update_aabb()
    {
        aabb[0] = instance->x;
        aabb[1] = instance->y;
        aabb[2] = aabb[0] + image->width;
        aabb[3] = aabb[1] + image->height;
        update_proxy();
    }
};

class PointCollision : public CollisionBase
{
public:
    PointCollision(int x, int y)
    : CollisionBase(BOUNDING_BOX, BOX_COLLISION)
    {
        aabb[0] = x;
        aabb[1] = y;
        aabb[2] = x + 1;
        aabb[3] = y + 1;
    }
};

class BoundingBox : public CollisionBase
{
public:
    BoundingBox(int x1, int y1, int x2, int y2)
    : CollisionBase(BOUNDING_BOX, BOX_COLLISION)
    {
        aabb[0] = x1;
        aabb[1] = y1;
        aabb[2] = x2;
        aabb[3] = y2;
    }
};

class BackgroundItem : public CollisionBase
{
public:
    int dest_x, dest_y, src_x, src_y, src_width, src_height;
    Color color;
    Image * image;
    int effect;

    BackgroundItem(Image * img, int dest_x, int dest_y, int src_x, int src_y,
                   int src_width, int src_height, const Color & color)
    : dest_x(dest_x), dest_y(dest_y), src_x(src_x), src_y(src_y),
      src_width(src_width), src_height(src_height), image(img), color(color),
      effect(Render::NONE), CollisionBase(BACKGROUND_ITEM, 0)
    {
        aabb[0] = dest_x;
        aabb[1] = dest_y;
        aabb[2] = dest_x + src_width;
        aabb[3] = dest_y + src_height;
    }

    void draw()
    {
        Render::set_effect(effect);
        image->draw(dest_x, dest_y, src_x, src_y, src_width, src_height,
                    color);
        Render::disable_effect();
    }

    void draw(int a)
    {
        Render::set_effect(effect);
        Color c = color;
        c.a = a;
        image->draw(dest_x, dest_y, src_x, src_y, src_width, src_height, c);
        Render::disable_effect();
    }
};

bool collide(CollisionBase * a, CollisionBase * b, int * aabb_2);
bool collide(CollisionBase * a, CollisionBase * b);

inline bool collide_box(FrameObject * a, int v[4])
{
    CollisionBase * col = a->collision;
    if (col == NULL) {
        int xx1 = a->x;
        int yy1 = a->y;
        int xx2 = xx1 + a->width;
        int yy2 = yy1 + a->height;
        return collides(xx1, yy1, xx2, yy2, v[0], v[1], v[2], v[3]);
    }
    return collides(col->aabb, v);
}

#endif // CHOWDREN_COLLISION_H
