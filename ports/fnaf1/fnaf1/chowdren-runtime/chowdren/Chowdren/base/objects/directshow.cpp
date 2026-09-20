#include "objects/directshow.h"
#include "include_gl.h"
#include "collision.h"
#include <iostream>

DirectShow::DirectShow(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
    collision = new InstanceBox(this);
}

DirectShow::~DirectShow()
{
    delete collision;
}

void DirectShow::load(const std::string & filename)
{
    std::cout << "Load DirectShow file: " << filename << std::endl;
}

void DirectShow::play()
{
    std::cout << "Play DirectShow" << std::endl;
}

void DirectShow::set_width(int value)
{
    width = value;
}

void DirectShow::set_height(int value)
{
    height = value;
}

bool DirectShow::is_playing()
{
    return true;
}

int DirectShow::get_time()
{
    // XXX stupid hack to skip cutscenes
    return 99999;
}

int DirectShow::get_duration()
{
    return 0;
}
