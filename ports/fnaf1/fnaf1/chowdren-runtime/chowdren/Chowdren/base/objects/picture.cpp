#include "objects/picture.h"

// ActivePicture

ActivePicture::ActivePicture(int x, int y, int type_id)
: FrameObject(x, y, type_id), image(NULL), horizontal_flip(false),
  scale_x(1.0f), scale_y(1.0f), angle(0)
{
    sprite_col.instance = this;
    collision = &sprite_col;
}

ActivePicture::~ActivePicture()
{
    image = NULL;
}

void ActivePicture::load(const std::string & fn)
{
#if defined(CHOWDREN_IS_WIIU) || defined(CHOWDREN_EMULATE_WIIU)
    // small hack to load language-specific files for menu
    size_t dir_end = fn.find_last_of(PATH_SEP);
    size_t dir_start = fn.find_last_of(PATH_SEP, dir_end-1);
    std::string dir = fn.substr(dir_start+1, dir_end-dir_start-1);
    if (dir == "Menu") {
        std::string name = fn.substr(dir_end + 1);
        filename = convert_path(fn.substr(0, dir_end+1) +
                                platform_get_language() + "/" + name);

    } else
        filename = convert_path(fn);
#else
    filename = convert_path(fn);
#endif

#ifndef NDEBUG
    std::cout << "load picture: " << filename << std::endl;
#endif

    image = get_image_cache(filename, 0, 0, 0, 0, transparent_color);

    if (image == NULL)
        return;

    sprite_col.set_image(image, 0, 0);
}

void ActivePicture::set_transparent_color(const Color & color)
{
    transparent_color = color;
}

void ActivePicture::set_hotspot(int x, int y)
{
    if (image == NULL)
        return;
    SpriteCollision * col = (SpriteCollision*)collision;
    this->x += x - sprite_col.hotspot_x;
    this->y += y - sprite_col.hotspot_y;
    ((SpriteCollision*)collision)->set_hotspot(x, y);
}

void ActivePicture::set_hotspot_mul(float x, float y)
{
    if (image == NULL)
        return;
    set_hotspot(image->width * x, image->height * y);
}

void ActivePicture::flip_horizontal()
{
    horizontal_flip = !horizontal_flip;
}

void ActivePicture::set_scale(float value)
{
    ((SpriteCollision*)collision)->set_scale(value);
    scale_x = scale_y = value;
}

void ActivePicture::set_size(int w, int h)
{
    float sx = w / float(image->width);
    float sy = h / float(image->height);
    scale_x = sx;
    scale_y = sy;
    ((SpriteCollision*)collision)->set_scale(sx, sy);
}

void ActivePicture::set_zoom(float value)
{
    set_scale(value / 100.0);
}

void ActivePicture::set_angle(int value, int quality)
{
    ((SpriteCollision*)collision)->set_angle(value);
    angle = value;
}

float ActivePicture::get_zoom_x()
{
    return scale_x * 100.0f;
}

int ActivePicture::get_width()
{
    if (image == NULL)
        return 0;
    return image->width;
}

int ActivePicture::get_height()
{
    if (image == NULL)
        return 0;
    return image->height;
}

void ActivePicture::draw()
{
    if (image == NULL)
        return;
    image->hotspot_x = sprite_col.hotspot_x;
    image->hotspot_y = sprite_col.hotspot_y;
    draw_image(image, x, y, blend_color, angle, scale_x, scale_y,
               horizontal_flip);
}

void ActivePicture::paste(int dest_x, int dest_y, int src_x, int src_y,
                          int src_width, int src_height, int collision_type)
{
    if (image == NULL) {
        std::cout << "Invalid image paste: " << filename << std::endl;
        return;
    }
    image->hotspot_x = 0;
    image->hotspot_y = 0;
    layer->paste(image, dest_x, dest_y, src_x, src_y,
                 src_width, src_height, collision_type, effect, blend_color);
}

class DefaultPicture : public ActivePicture
{
public:
    DefaultPicture()
    : ActivePicture(0, 0, 0)
    {
        collision = new InstanceBox(this);
        create_alterables();
        setup_default_instance(this);
    }
};

static DefaultPicture default_picture;
FrameObject * default_picture_instance = &default_picture;
