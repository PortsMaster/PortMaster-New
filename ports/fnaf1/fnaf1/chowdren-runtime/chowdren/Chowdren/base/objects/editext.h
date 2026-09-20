#ifndef CHOWDREN_EDITEXT_H
#define CHOWDREN_EDITEXT_H

#include "frameobject.h"

#ifdef CHOWDREN_USE_EDITOBJ
#include "collision.h"
#include "common.h"
#include "font.h"
#include <string>
#endif

class EditObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(EditObject)

    enum EditFlags
    {
        PASSWORD = 1 << 0,
        FOCUS = 1 << 1
    };

    EditObject(int x, int y, int type_id);
    void set_text(const std::string & value);
    const std::string & get_text();
    bool get_focus();
    void enable_focus();
    void disable_focus();
    void set_limit(int size);

#ifdef CHOWDREN_USE_EDITOBJ
    int edit_flags;
    InstanceBox edit_col;
    std::string text;
    FTTextureFont * font;

    void update();
    void draw();
#endif
};

#endif // CHOWDREN_EDITEXT_H
