#include "include_gl.h"
#include "platform.h"
#include "frameobject.h"
#include "assetfile.h"
#include "render.h"

#include "shaderparam.cpp"
#include "shaderparam.h"

void convert_vec4(int val, float & a, float & b, float & c, float & d)
{
    a = (val & 0xFF) / 255.0f;
    b = ((val >> 8) & 0xFF) / 255.0f;
    c = ((val >> 16) & 0xFF) / 255.0f;
    d = ((val >> 24) & 0xFF) / 255.0f;
}

// shader implementations

#include "shaders.cpp"

#define DO_SHADER(S) S.begin(obj, width, height);\
                     S.set_parameters(obj);\
                     commit_parameters(obj);

#define HANDLE_SHADER(N, S) case Render::N:\
                                DO_SHADER(S);\
                                break

#define SET_BLEND_FUNC(a, b, c, d)\
                             blend_status = 1;\
                             set_blend_func(a, b, c, d)

#define SET_BLEND_FUNC_EQ(a, b, c, d, e, f)\
                             blend_status = 2;\
                             set_blend_func_eq(a, b, c, d, e, f)

static bool has_blend_eq = false;
static bool has_blend_func = false;
static int blend_status = 2;

void shader_reset_blend()
{
    has_blend_eq = false;
    has_blend_func = false;
    blend_status = 2;
}

void shader_set_texture()
{
    if (blend_status == 1) {
        set_blend_func(FUNC_SRC_ALPHA, FUNC_ONE_MINUS_SRC_ALPHA,
                       FUNC_ONE, FUNC_ONE_MINUS_SRC_ALPHA);
    } else if (blend_status == 2) {
        set_blend_func_eq(FUNC_SRC_ALPHA, FUNC_ONE_MINUS_SRC_ALPHA,
                          FUNC_ONE, FUNC_ONE_MINUS_SRC_ALPHA,
                          EQ_ADD, EQ_ADD);
    }
    blend_status = 0;
    
    texture_shader.begin(NULL, 0, 0);
}

void shader_set_effect(int effect, FrameObject * obj,
                       int width, int height)
{
    if (blend_status == 1) {
        set_blend_func(FUNC_SRC_ALPHA, FUNC_ONE_MINUS_SRC_ALPHA,
                       FUNC_ONE, FUNC_ONE_MINUS_SRC_ALPHA);
    } else if (blend_status == 2) {
        set_blend_func_eq(FUNC_SRC_ALPHA, FUNC_ONE_MINUS_SRC_ALPHA,
                          FUNC_ONE, FUNC_ONE_MINUS_SRC_ALPHA,
                          EQ_ADD, EQ_ADD);
    }
    blend_status = 0;

    switch (effect) {
        case Render::NONE:
            break;
        case Render::SUBTRACT:
            DO_SHADER(subtract_shader);
            SET_BLEND_FUNC_EQ(FUNC_DST_COLOR, FUNC_ONE,
                              FUNC_ZERO, FUNC_ONE,
                              EQ_REVERSE_SUBTRACT, EQ_ADD);
            break;
        case Render::ADDITIVE:
            texture_shader.begin(NULL, 0, 0);
            SET_BLEND_FUNC(FUNC_SRC_ALPHA, FUNC_ONE,
                           FUNC_ZERO, FUNC_ONE);
            break;
        case Render::SURFACESUBTRACT:
            texture_shader.begin(NULL, 0, 0);
            SET_BLEND_FUNC_EQ(FUNC_ONE, FUNC_ONE,
                              FUNC_ZERO, FUNC_ONE,
                              EQ_REVERSE_SUBTRACT, EQ_ADD);
            break;
        case Render::LAYERCOLOR:
            texture_shader.begin(NULL, 0, 0);
            SET_BLEND_FUNC(FUNC_ZERO, FUNC_SRC_COLOR,
                           FUNC_ZERO, FUNC_ONE);
            break;
        case Render::PIXELSCALE:
            pixelscale_shader.begin(NULL, 0, 0);
            break;
        case Render::FONT:
            font_shader.begin(NULL, 0, 0);
            break;
        case Render::CHANNELBLURADD:
            DO_SHADER(channelblur_shader);
            SET_BLEND_FUNC(FUNC_SRC_ALPHA, FUNC_ONE,
                           FUNC_ZERO, FUNC_ONE);
            break;
        case Render::BLURADD:
            DO_SHADER(blur_shader);
            SET_BLEND_FUNC(FUNC_SRC_ALPHA, FUNC_ONE,
                           FUNC_ZERO, FUNC_ONE);
            break;
        HANDLE_SHADER(FONTOUTLINE, fontoutline_shader);
        HANDLE_SHADER(BRIGHTSATBG, brightsatbg_shader);
        HANDLE_SHADER(PERSPECTIVE, perspective_shader);
        HANDLE_SHADER(MONOCHROME, monochrome_shader);
        HANDLE_SHADER(ZOOMOFFSET, zoomoffset_shader);
        HANDLE_SHADER(OFFSET, offset_shader);
        HANDLE_SHADER(PIXELOUTLINE, pixeloutline_shader);
        HANDLE_SHADER(COLDIRBLUR, coldirblur_shader);
        HANDLE_SHADER(CHANNELBLUR, channelblur_shader);
        HANDLE_SHADER(ROTATESUB, rotatesub_shader);
        HANDLE_SHADER(SUBPX, subpx_shader);
        HANDLE_SHADER(SIMPLEMASK, simplemask_shader);
        HANDLE_SHADER(MULTIPLY, multiply_shader);
        HANDLE_SHADER(NINEPATCH, ninepatch_shader);
        HANDLE_SHADER(HARDLIGHT, hardlight_shader);
        HANDLE_SHADER(UNDERWATER, underwater_shader);
        HANDLE_SHADER(LENS, lens_shader);
        HANDLE_SHADER(INVERT, invert_shader);
        HANDLE_SHADER(HUE, hue_shader);
        HANDLE_SHADER(TINT, tint_shader);
        HANDLE_SHADER(OVERLAYALPHA, overlayalpha_shader);
        HANDLE_SHADER(GRAIN, grain_shader);
        HANDLE_SHADER(GRADIENT, gradient_shader);
        HANDLE_SHADER(OFFSETSTATIONARY, offsetstationary_shader);
        HANDLE_SHADER(BGBLUR, bgblur_shader);
        HANDLE_SHADER(PATTERNOVERLAY, patternoverlay_shader);
        HANDLE_SHADER(BGBLOOM, bgbloom_shader);
        HANDLE_SHADER(MIXER, mixer_shader);
        HANDLE_SHADER(BLUR, blur_shader);
        HANDLE_SHADER(DISPLAY, display_shader);
        HANDLE_SHADER(LINEARBURN, linearburn_shader);
        HANDLE_SHADER(LINEARDODGE, lineardodge_shader);
    }
}
