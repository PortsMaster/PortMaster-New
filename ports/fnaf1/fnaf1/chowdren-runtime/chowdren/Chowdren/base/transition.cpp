#include "transition.h"
#include "manager.h"
#include "render.h"

void Transition::draw()
{
    Color c = manager.fade_color;
    float value = manager.fade_value;
    switch (manager.fade_type) {
        case FADE:
            c.set_alpha(int(value * 255));
            Render::draw_quad(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, c);
            break;
        case DOOR:
            int w = (WINDOW_WIDTH / 2.0f) * value;
            Render::draw_quad(0, 0, w, WINDOW_HEIGHT, c);
            Render::draw_quad(WINDOW_WIDTH - w, 0,
                              WINDOW_WIDTH, WINDOW_HEIGHT, c);
            break;
    }
}