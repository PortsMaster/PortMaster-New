#include "objects/backdrop.h"
#include "collision.h"
#include "image.h"

// Backdrop

Backdrop::Backdrop(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
#if defined(CHOWDREN_IS_WIIU) || defined(CHOWDREN_EMULATE_WIIU)
    remote = CHOWDREN_HYBRID_TARGET;
#endif
}

Backdrop::~Backdrop()
{
    delete collision;
}

void Backdrop::draw()
{
#if defined(CHOWDREN_IS_WIIU) || defined(CHOWDREN_EMULATE_WIIU)
    int current_remote = platform_get_remote_value();
    if (remote == CHOWDREN_REMOTE_TARGET &&
        current_remote != CHOWDREN_HYBRID_TARGET)
        return;
#endif
    draw_image(image, x + image->hotspot_x, y + image->hotspot_y, blend_color);
}
