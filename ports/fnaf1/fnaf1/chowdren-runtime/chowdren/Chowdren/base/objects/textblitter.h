#ifndef CHOWDREN_TEXTBLITTER_H
#define CHOWDREN_TEXTBLITTER_H

#include "frameobject.h"
#include "types.h"
#include <string>
#include "color.h"
#include "image.h"

enum BlitterAnimation
{
    BLITTER_ANIMATION_NONE = 0,
    BLITTER_ANIMATION_SINWAVE = 1
};

struct LineReference
{
    char * start;
    int size;

    LineReference(char * start, int size)
    : start(start), size(size)
    {
    }
};

class TextBlitter : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(TextBlitter)

    vector<LineReference> lines;
    std::string text;
    int char_width, char_height;
    int char_offset;
    Image * image;
    const std::string * charmap_str;
    int * charmap;
    float flash_time, flash_interval;
    int alignment;
    int x_spacing, y_spacing;
    int x_scroll, y_scroll;
    int x_off, y_off;
    bool charmap_ref;
    bool wrap;
    bool transparent;
    int image_width;

    int anim_type;
    int anim_speed;
    int anim_frame;
    int wave_freq, wave_height;

    TransparentColor transparent_color;

    bool has_callback;
    int callback_line_count;
    int callback_line;
    int callback_char;
    int callback_transparency;

    Image * draw_image;
    ReplacedImages replacer;

    TextBlitter(int x, int y, int type_id);
    ~TextBlitter();
    void initialize(const std::string & charmap);
    void load(const std::string & filename);
    void set_text(const std::string & text);
    void append_text(const std::string & text);
    void update_lines();
    void set_x_spacing(int spacing);
    void set_y_spacing(int spacing);
    void set_x_scroll(int value);
    void set_y_scroll(int value);
    int get_x_align();
    int get_y_align();
    void set_x_align(int value);
    void set_y_align(int value);
    void set_width(int width);
    void set_height(int height);
    void draw();
    void update();
    void flash(float value);
    std::string get_line(int index);
    int get_line_count();
    std::string get_map_char(int index);
    void replace_color(Color from, Color to);
    void set_transparent_color(int color);
    void set_animation_parameter(int index, int value);
    void set_animation_type(int value);
    void set_animation_speed(int value);
    void set_charmap(const std::string & charmap);
    const std::string & get_charmap();

    const std::string & get_text()
    {
        return text;
    }

    void set_char_width(int width)
    {
        char_width = std::min(image_width, width);
    }

    virtual void call_char_callback();
};

extern FrameObject * default_blitter_instance;

#endif // CHOWDREN_TEXTBLITTER_H
