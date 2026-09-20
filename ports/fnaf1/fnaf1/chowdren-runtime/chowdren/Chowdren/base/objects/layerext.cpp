#include "objects/layerext.h"
#include "chowconfig.h"

// LayerObject

int LayerObject::sort_index;
bool LayerObject::sort_reverse;
double LayerObject::def;

LayerObject::LayerObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), current_layer(0)
{

}

void LayerObject::set_layer(int value)
{
    current_layer = value;
}

void LayerObject::hide_layer(int index)
{
    frame->layers[index].visible = false;
}

void LayerObject::show_layer(int index)
{
    frame->layers[index].visible = true;
}

void LayerObject::set_position(int index, int x, int y)
{
    frame->layers[index].set_position(x, y);
}

void LayerObject::set_x(int index, int x)
{
    Layer & layer = frame->layers[index];
    layer.set_position(x, layer.y);
}

void LayerObject::set_y(int index, int y)
{
    Layer & layer = frame->layers[index];
    layer.set_position(layer.x, y);
}

int LayerObject::get_x(int index)
{
    return frame->layers[index].x;
}

int LayerObject::get_y(int index)
{
    return frame->layers[index].y;
}

void LayerObject::set_alpha_coefficient(int index, int alpha)
{
    Layer * layer = &frame->layers[index];
    FlatObjectList::const_iterator it;
    for (it = layer->background_instances.begin();
         it != layer->background_instances.end(); ++it) {
        FrameObject * obj = *it;
        obj->blend_color.set_alpha_coefficient(alpha);
    }
    layer->blend_color.set_alpha_coefficient(alpha);
}

double LayerObject::get_alterable(const FrameObject & instance)
{
    if (instance.alterables == NULL)
        return def;
    return instance.alterables->values.get(sort_index);
}

bool LayerObject::sort_func(const FrameObject & a, const FrameObject & b)
{
    double value1 = get_alterable(a);
    double value2 = get_alterable(b);
    if (sort_reverse)
        return value1 < value2;
    else
        return value1 > value2;
}

void LayerObject::sort_alt_decreasing(int index, double def)
{
    sort_index = index;
    sort_reverse = true;
    this->def = def;
    Layer * layer = &frame->layers[current_layer];
    layer->instances.sort(sort_func);
    layer->reset_depth();
}

void LayerObject::set_rgb(int index, Color color)
{
    frame->layers[index].blend_color = color;
}
