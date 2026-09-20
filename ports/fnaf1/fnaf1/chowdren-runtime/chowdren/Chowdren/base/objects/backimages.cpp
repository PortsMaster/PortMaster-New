#include "objects/backimages.h"
#include "collision.h"

BackImages::BackImages(int x, int y, int type_id)
: FrameObject(x, y, type_id), x_off(0), y_off(0)
{
}

int BackImages::get_width(int slot)
{
    return width;
}

class DefaultInstance : public BackImages
{
public:
    DefaultInstance()
    : BackImages(0, 0, 0)
    {
        collision = new InstanceBox(this);
        create_alterables();
        setup_default_instance(this);
    }
};

static DefaultInstance default_backimages;
FrameObject * default_backimages_instance = &default_backimages;
