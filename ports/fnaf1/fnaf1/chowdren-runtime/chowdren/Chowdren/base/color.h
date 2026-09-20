#ifndef CHOWDREN_COLOR_H
#define CHOWDREN_COLOR_H

#include <iostream>
#include <algorithm>

inline unsigned char clamp_color_component(int v)
{
    return (unsigned char)std::min<int>(std::max<int>(v, 0), 255);
}

inline unsigned char clamp_color_component(float v)
{
    return (unsigned char)std::min<float>(std::max<float>(v, 0.0f), 1.0f);
}

inline int make_color_int(unsigned char r, unsigned char g, unsigned char b,
                          unsigned char a = 0)
{
    return r | (g << 8) | (b << 16) | (a << 24);
}

template <int def_r, int def_g, int def_b, int def_a>
struct BaseColor
{
    unsigned char r, g, b, a;

    BaseColor()
    {
        set(def_r, def_g, def_b, def_a);
    }

    BaseColor(int r, int g, int b, int a = 255)
    {
        set(r, g, b, a);
    }

    BaseColor(int color)
    {
        set(color);
    }

    BaseColor(double color)
    {
        set(int(color));
    }

    template <int a, int b, int c, int d>
    BaseColor(const BaseColor<a, b, c, d> & color)
    {
        set(color);
    }

    template <int a, int b, int c, int d>
    void operator=(const BaseColor<a, b, c, d> & color)
    {
        set(color);
    }

    void set(int r, int g, int b, int a = 255)
    {
        this->r = clamp_color_component(r);
        this->g = clamp_color_component(g);
        this->b = clamp_color_component(b);
        set_alpha(a);
    }

    void set_rgb(int r, int g, int b)
    {
        set(r, g, b, a);
    }

    void set_alpha(int a)
    {
        a = clamp_color_component(a);
        this->a = a;
    }

    void set(int color)
    {
        set(color & 0xFF, (color >> 8) & 0xFF, (color >> 16) & 0xFF);
    }

    template <int a, int b, int c, int d>
    void set(const BaseColor<a, b, c, d> & color)
    {
        set(color.r, color.g, color.b, color.a);
    }

    void set_alpha_coefficient(int a)
    {
        set_alpha(255 - a);
    }

    void set_semi_transparency(int a)
    {
        set_alpha((128 - a) * 2);
    }

    int get_alpha_coefficient()
    {
        return 255 - a;
    }

    int get_semi_transparency()
    {
        if (a >= 255)
            return 0;
        return 128 - a / 2;
    }

    int get_int() const
    {
        return make_color_int(r, g, b, a);
    }

    // for TransparentColor

    void enable()
    {
        set_alpha(255);
    }

    void disable()
    {
        set_alpha(0);
    }

    bool is_enabled()
    {
        return a == 255;
    }
};

typedef BaseColor<255, 255, 255, 255> Color;
typedef BaseColor<0, 0, 0, 0> TransparentColor;

#endif // CHOWDREN_COLOR_H
