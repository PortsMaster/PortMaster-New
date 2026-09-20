#ifndef CHOWDREN_LAYEREXT_H
#define CHOWDREN_LAYEREXT_H

#include "frameobject.h"
#include "color.h"
#include <string>

class LayerObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(LayerObject)

    int current_layer;
    static int sort_index;
    static bool sort_reverse;
    static double def;

    LayerObject(int x, int y, int type_id);
    void set_layer(int value);
    void hide_layer(int index);
    void show_layer(int index);
    void set_x(int index, int x);
    void set_y(int index, int y);
    int get_x(int index);
    int get_y(int index);
    void set_position(int index, int x, int y);
    void set_alpha_coefficient(int index, int alpha);
    static double get_alterable(const FrameObject & instance);
    static bool sort_func(const FrameObject & a, const FrameObject & b);
    void sort_alt_decreasing(int index, double def);
    void set_rgb(int index, Color color);
};

#endif // CHOWDREN_LAYEREXT_H
