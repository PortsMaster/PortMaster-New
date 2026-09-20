#include "objects/windowcontrol.h"
#include "chowconfig.h"
#include "platform.h"
#include <iostream>
#include "manager.h"

#ifdef CHOWDREN_USE_SUBAPP
#include "subapp.h"
#endif

// WindowControl

WindowControl::WindowControl(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
}

bool WindowControl::has_focus()
{
    return platform_has_focus();
}

bool WindowControl::is_maximized()
{
    return false;
}

void WindowControl::set_focus(bool value)
{
    platform_set_focus(value);
}

int WindowControl::get_x()
{
    // std::cout << "Get window x" << std::endl;
    return 0;
}

int WindowControl::get_y()
{
    // std::cout << "Get window y" << std::endl;
    return 0;
}

void WindowControl::set_x(int x)
{
    // std::cout << "Set window x: " << x << std::endl;
}

void WindowControl::set_y(int y)
{
    // std::cout << "Set window y: " << y << std::endl;
}

void WindowControl::set_position(int x, int y)
{
    set_x(x);
    set_y(y);
}

void WindowControl::set_width(int w)
{
    float scale = w / float(WINDOW_WIDTH);
    manager.set_window_scale(scale);
    std::cout << "Set window width: " << w << std::endl;
}

void WindowControl::set_height(int h)
{
    std::cout << "Set window height: " << h << std::endl;
}

void WindowControl::maximize()
{
    std::cout << "Maximize window" << std::endl;
}

void WindowControl::restore()
{
    std::cout << "Restore window" << std::endl;
}

int WindowControl::get_width()
{
    int w, h;
    platform_get_size(&w, &h);
    return w;
}

int WindowControl::get_height()
{
    int w, h;
    platform_get_size(&w, &h);
    return h;
}

int WindowControl::get_screen_width()
{
    int w, h;
    platform_get_screen_size(&w, &h);
    return w;
}

int WindowControl::get_screen_height()
{
    int w, h;
    platform_get_screen_size(&w, &h);
    return h;
}

void WindowControl::set_visible(bool value)
{
#ifdef CHOWDREN_USE_SUBAPP
    if (SubApplication::current != NULL) {
        std::cout << "Set subapp visible" << std::endl;
        SubApplication::current->set_visible(value);
    }
#endif
    std::cout << "Set window visible: " << value << std::endl;
}

void WindowControl::minimize()
{
    std::cout << "Minimize window" << std::endl;
}

void WindowControl::set_placement(int value)
{
    // 0=top/left, 1=top/middle, 2=top/right, 3=middle/left, 4=middle/middle
    // 5=middle/right, 6=bottom/left, 7=bottom/middle, 8=bottom/right.
    std::cout << "Set window placement: " << value << std::endl;
}
