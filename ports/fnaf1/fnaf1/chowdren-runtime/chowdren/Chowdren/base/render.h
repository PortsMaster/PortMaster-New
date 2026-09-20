#ifndef CHOWDREN_RENDER_H
#define CHOWDREN_RENDER_H

#include "color.h"

typedef unsigned int Texture;

class FrameObject;

class Render
{
public:
    enum Effect
    {
        // application effects
        NONE = 0,
        MONOCHROME,
        ZOOMOFFSET,
        PIXELOUTLINE,
        FONTOUTLINE,
        COLDIRBLUR,
        CHANNELBLUR,
        CHANNELBLURADD,
        BLUR,
        BLURADD,
        ROTATESUB,
        SUBPX,
        SIMPLEMASK,
        MULTIPLY,
        BRIGHTSATBG,
        NINEPATCH,
        HARDLIGHT,
        UNDERWATER,
        LENS,
        SUBTRACT,
        INVERT,
        HUE,
        TINT,
        OVERLAYALPHA,
        GRAIN,
        GRADIENT,
        OFFSETSTATIONARY,
        DODGEBLUR,
        BGBLUR,
        PATTERNOVERLAY,
        BGBLOOM,
        ADDITIVE,
        OFFSET,
        MIXER,
        DISPLAY,
        LINEARBURN,
        LINEARDODGE,

        // internal effects
        SURFACESUBTRACT,
        LAYERCOLOR,
        PERSPECTIVE,
        PIXELSCALE,
        FONT
    };

    static int offset[2];

    static void init();

    static void set_view(int x, int y, int w, int h);
    static void set_offset(int x1, int y1);
    static void draw_quad(float * p, Color color);
    static void draw_quad(int x1, int y1, int x2, int y2, Color color);

    static void draw_horizontal_gradient(int x1, int y1, int x2, int y2,
                                         Color color1, Color color2);
    static void draw_vertical_gradient(int x1, int y1, int x2, int y2,
                                       Color color1, Color color2);

    static void draw_tex(int x1, int y1, int x2, int y2, Color color,
                         Texture tex);
    static void draw_tex(float * p, Color color, Texture tex);
    static void draw_tex(int x1, int y1, int x2, int y2, Color color,
                         Texture tex,
                         float tx1, float ty1, float tx2, float ty2);
    static void clear(Color color);

    static void enable_scissor(int x, int y, int w, int h);
    static void disable_scissor();

    static void clear(int r, int g, int b, int a)
    {
        clear(Color(r, g, b, a));
    }

    static void set_effect(int effect, FrameObject * obj,
                           int width, int height);
    static void set_effect(int effect);
    static void disable_effect();

    static void enable_blend();
    static void disable_blend();

    static Texture copy_rect(int x1, int y1, int x2, int y2);

    enum Format
    {
        RGBA,
        L
    };

    // textures
    static Texture create_tex(void * pixels, Format f, int width, int height);
    static void delete_tex(Texture tex);
    static void set_filter(Texture tex, bool linear);

#ifdef CHOWDREN_IS_3DS
    static void set_storage(bool vram);
    static bool is_vram_full();
    static void set_global_depth(float depth);
    static void set_depth(float depth);
#endif
};

#include "renderplatform.h"

#endif // CHOWDREN_RENDER_H
