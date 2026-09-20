#include "common.h"
#include "fileio.h"
#include <string>
#include "chowconfig.h"
#include "font.h"
#include <iterator>
#include <iomanip>
#include "md5.h"
#include "intern.cpp"
#include "overlap.cpp"
#include "collision.cpp"
#include "objects/active.h"
#include "fbo.h"

// XXX move this?
#include "staticlibs/utf16to8.cpp"

#ifdef CHOWDREN_USE_VALUEADD
#include "extra_keys.cpp"
#endif

#ifdef CHOWDREN_CACHE_INI
#include "objects/ini.h"
#endif

#ifdef BOOST_NO_EXCEPTIONS
namespace boost
{
    void throw_exception(std::exception const & e)
    {
        std::cout << "Exception thrown" << std::endl;
    }
}
#endif

std::string newline_character("\r\n");
std::string empty_string("");

static const char hex_characters[] = "0123456789abcdef";

std::string get_md5(const std::string & value)
{
    MD5_CTX ctx;
    MD5_Init(&ctx);
    MD5_Update(&ctx, &value[0], value.size());
    std::string res;
    res.resize(32);
    unsigned char digest[16];
    MD5_Final(digest, &ctx);

    for (int i = 0; i < 16; i++) {
        unsigned char b = digest[i];
        res[i*2] = hex_characters[(b >> 4) & 0xf];
        res[i*2+1] = hex_characters[b & 0xF];
    }

    return res;
}

void swap_position(const FlatObjectList & list)
{
    if (list.size() <= 1)
        return;
    int num1 = randrange(list.size());
    int num2;
    while (true) {
        num2 = randrange(list.size());
        if (num2 != num1)
            break;
    }

    FrameObject * a = list[num1];
    FrameObject * b = list[num2];

    int x1 = a->get_x();
    int y1 = a->get_y();
    int x2 = b->get_x();
    int y2 = b->get_y();

    a->set_global_position(x2, y2);
    b->set_global_position(x1, y1);
}

// Font

Font::Font(const std::string & name, int size, bool bold, bool italic,
           bool underline)
: name(name), size(size),  bold(bold), italic(italic), underline(underline)
{

}

// Background

Background::Background()
{
#ifdef CHOWDREN_PASTE_PRECEDENCE
    col_w = manager.frame->width;
    col_h = manager.frame->height;
    int size = col_w * col_h;
    size = GET_BITARRAY_SIZE(size);
    col.data = (BaseBitArray::word_t*)malloc(size);
    memset(col.data, 0, size);
#endif
}

#ifdef CHOWDREN_PASTE_BROADPHASE
void clear_back_vec(Broadphase & items)
{
    BackgroundItems::iterator it;
    for (it = items.begin(); it != items.end(); ++it) {
        BackgroundItem * item = *it;
        delete item;
    }
    items.clear();
}
#else
void clear_back_vec(BackgroundItems & items)
{
    BackgroundItems::iterator it;
    for (it = items.begin(); it != items.end(); ++it) {
        BackgroundItem * item = *it;
        delete item;
    }
    items.clear();
}
#endif

Background::~Background()
{
    clear_back_vec(col_items);
    clear_back_vec(items);

#ifdef CHOWDREN_PASTE_PRECEDENCE
    free(col.data);
    col.data = NULL;
#endif
}

void Background::reset(bool clear_items)
{
#ifdef CHOWDREN_PASTE_CACHE
    dirty = true;
#endif

    if (!clear_items)
        return;

    clear_back_vec(col_items);
    clear_back_vec(items);
}

struct RemoveBackgroundCallback
{
    int x, y;

    RemoveBackgroundCallback(int x, int y)
    : x(x), y(y)
    {
    }

    bool on_callback(void * data)
    {
        BackgroundItem * item = (BackgroundItem*)data;
        if (!collides(item->dest_x, item->dest_y,
                      item->dest_x + item->src_width,
                      item->dest_y + item->src_height,
                      x, y, x+1, y+1))
        {
            return true;
        }

        delete item;
        return false;
    }    
};

void Background::destroy_at(int x, int y)
{
#ifdef CHOWDREN_PASTE_BROADPHASE
    int v[4] = {x, y, x+1, y+1};
    RemoveBackgroundCallback callback(x, y);
    items.remove_query(v, callback);
    col_items.remove_query(v, callback);
#else
    BackgroundItems::iterator it = items.begin();
    while (it != items.end()) {
        BackgroundItem * item = *it;
        if (collides(item->dest_x, item->dest_y,
                     item->dest_x + item->src_width,
                     item->dest_y + item->src_height,
                     x, y, x+1, y+1)) {
#ifdef CHOWDREN_PASTE_CACHE
            if (collides(item->aabb, cache_pos))
                dirty = true;
#endif
            delete item;
            it = items.erase(it);
        } else {
            ++it;
        }
    }
    it = col_items.begin();
    while (it != col_items.end()) {
        BackgroundItem * item = *it;
        if (collides(item->dest_x, item->dest_y,
                     item->dest_x + item->src_width,
                     item->dest_y + item->src_height,
                     x, y, x+1, y+1)) {
            delete item;
            it = col_items.erase(it);
        } else
            ++it;
    }
#endif
}

inline bool compare_aabb(int a[4], int b[4])
{
    return memcmp(&a[0], &b[0], sizeof(int)*4) == 0;
}

#ifdef CHOWDREN_PASTE_BROADPHASE
struct RemoveExactCallback
{
    BackgroundItem * item;

    RemoveBackgroundExactCallback(BackgroundItem * item, bool check_image)
    : item(item)
    {
    }

    bool on_callback(void * data)
    {
        BackgroundItem * other = (BackgroundItem*)data;
        if (other == item)
            return true;
        if (!compare_aabb(item->aabb, other->aabb) ||
            (check_image && other->image != img))
            return true;
        delete other;
        return false;
    }    
};

inline void remove_paste_item(BackgroundItem * item, Broadphase & broadphase,
                              bool check_image)
{
    RemoveExactCallback callback(item, check_image);
    broadphase.remove_query(item->aabb, broadphase);
}
#else
inline void remove_paste_item(BackgroundItem * item, BackgroundItems & items,
                              bool check_image)
{
    BackgroundItems::iterator it = items.begin();
    while (it != items.end()) {
        BackgroundItem * other = *it;
        if (other == item) {
            ++it;
            continue;
        }
        if (!compare_aabb(item->aabb, other->aabb) ||
            (check_image && other->image != item->image))
        {
            ++it;
            continue;
        }
        it = items.erase(it);
    }
}

inline void remove_contained_item(BackgroundItem * item,
                                  BackgroundItems & items)
{
    BackgroundItems::iterator it = items.begin();
    while (it != items.end()) {
        BackgroundItem * other = *it;
        if (other == item) {
            ++it;
            continue;
        }
        if (!contains(item->aabb, other->aabb)) {
            ++it;
            continue;
        }
        it = items.erase(it);
    }
}
#endif


void Background::paste(Image * img, int dest_x, int dest_y,
                       int src_x, int src_y, int src_width, int src_height,
                       int collision_type, int effect, const Color & color)
{
    // collision types:
    // 0: not an obstacle
    // 1: obstacle
    // 3: ladder
    // 4: no effect on collisions
    src_width = std::min<int>(img->width, src_x + src_width) - src_x;
    src_height = std::min<int>(img->height, src_y + src_height) - src_y;

    if (src_width <= 0 || src_height <= 0)
        return;

    if (collision_type == 1 || collision_type == 3) {
        BackgroundItem * item = new BackgroundItem(img, dest_x, dest_y,
                                                   src_x, src_y,
                                                   src_width, src_height,
                                                   color);
        if (collision_type == 3)
            item->flags |= (LADDER_OBSTACLE | BOX_COLLISION);

#ifdef CHOWDREN_PASTE_BROADPHASE
        col_items.add(item, item->aabb);
#else
        col_items.push_back(item);
#endif

#ifndef CHOWDREN_OBSTACLE_IMAGE
        return;
#endif
    }

    if (color.a == 0 || color.a == 1)
        return;


    BackgroundItem * item = new BackgroundItem(img, dest_x, dest_y,
                                               src_x, src_y,
                                               src_width, src_height,
                                               color);
    item->effect = effect;

#ifdef CHOWDREN_PASTE_CACHE
    if (collides(cache_pos, item->aabb) && fbo.tex != 0)
        new_paste.push_back(item);
#endif

#ifdef CHOWDREN_PASTE_BROADPHASE
    items.add(item, item->aabb);
#else
    items.push_back(item);
#endif

#ifdef CHOWDREN_PASTE_PRECEDENCE
    int x1 = std::max(0, dest_x);
    int y1 = std::max(0, dest_y);
    int x2 = std::min(col_w, dest_x + src_width);
    int y2 = std::min(col_h, dest_y + src_height);
    if (collision_type == 0) {
        for (int y = y1; y < y2; ++y)
        for (int x = x1; x < x2; ++x) {
            col.set(y * col_w + x);
        }
    } else if (collision_type == 1) {
        for (int y = y1; y < y2; ++y)
        for (int x = x1; x < x2; ++x) {
            col.unset(y * col_w + x);
        }
    }
#endif

#ifdef CHOWDREN_PASTE_REMOVE
    if (collision_type == 0 || collision_type == 4) {
        remove_paste_item(item, col_items, false);
        remove_paste_item(item, items, true);
    }
#endif
}

void Background::draw(int v[4])
{
#ifdef CHOWDREN_PASTE_CACHE
    if (dirty || !contains(cache_pos, v)) {
        new_paste.clear();
        dirty = false;
        const int cache_off_x = (1024 - WINDOW_WIDTH) / 2;
        const int cache_off_y = (1024 - WINDOW_HEIGHT) / 2;

        cache_pos[0] = v[0] - cache_off_x;
        cache_pos[1] = v[1] - cache_off_y;
        cache_pos[2] = v[2] + cache_off_x;
        cache_pos[3] = v[3] + cache_off_y;
        
        if (fbo.tex == 0)
            fbo.init(cache_pos[2] - cache_pos[0], cache_pos[3] - cache_pos[1]);

        fbo.bind();
        Render::set_view(0, 0,
                         cache_pos[2] - cache_pos[0],
                         cache_pos[3] - cache_pos[1]);
		int old_offset[2] = {Render::offset[0], Render::offset[1]};
        Render::set_offset(-cache_pos[0], -cache_pos[1]);
        Render::clear(255, 255, 255, 0);

        BackgroundItems::const_iterator it;
        for (it = items.begin(); it != items.end(); ++it) {
            BackgroundItem * item = *it;
            if (!collides(item->aabb, cache_pos))
                continue;
            item->draw();
        }

        fbo.unbind();

        Render::set_view(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
        Render::set_offset(old_offset[0], old_offset[1]);
    } else if (!new_paste.empty()) {
        fbo.bind();
        Render::set_view(0, 0,
                         cache_pos[2] - cache_pos[0],
                         cache_pos[3] - cache_pos[1]);
        int old_offset[2] = {Render::offset[0], Render::offset[1]};
        Render::set_offset(-cache_pos[0], -cache_pos[1]);

        BackgroundItems::const_iterator it;
        for (it = new_paste.begin(); it != new_paste.end(); ++it) {
            BackgroundItem * item = *it;
            item->draw();
        }
        fbo.unbind();
        Render::set_view(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
        Render::set_offset(old_offset[0], old_offset[1]);

        new_paste.clear();
    }

    Texture t = fbo.get_tex();

    Render::draw_tex(cache_pos[0], cache_pos[1],
                     cache_pos[2], cache_pos[3],
                     Color(), t,
                     fbo_texcoords[0], fbo_texcoords[1],
                     fbo_texcoords[2], fbo_texcoords[3]);
#else

#ifdef CHOWDREN_PASTE_BROADPHASE
#else
    BackgroundItems::const_iterator it;
    for (it = items.begin(); it != items.end(); ++it) {
        BackgroundItem * item = *it;
        if (!collides(item->aabb, v))
            continue;
        item->draw();
    }
#endif

#endif
}

CollisionBase * Background::collide(CollisionBase * a)
{
#ifdef CHOWDREN_PASTE_BROADPHASE
#else
    BackgroundItems::iterator it;
    for (it = col_items.begin(); it != col_items.end(); ++it) {
        BackgroundItem * item = *it;
        if (::collide(a, item))
            return item;
    }

    return NULL;
#endif
}

CollisionBase * Background::overlaps(CollisionBase * a)
{
#ifdef CHOWDREN_PASTE_BROADPHASE
#else
    BackgroundItems::iterator it;
    for (it = col_items.begin(); it != col_items.end(); ++it) {
        BackgroundItem * item = *it;
        if (item->flags & LADDER_OBSTACLE)
            continue;
        if (::collide(a, item))
            return item;
    }
    return NULL;
#endif
}

// Layer

static Layer default_layer(0, 1.0, 1.0, false, false, false);

Layer::Layer()
{
    reset();
}

Layer::Layer(int index, double coeff_x, double coeff_y, bool visible,
             bool wrap_x, bool wrap_y)
{
    init(index, coeff_x, coeff_y, visible, wrap_x, wrap_y);
}

Layer::Layer(const Layer & layer)
{
    // this should never be called, but need to make vector::resize happy
    reset();
}

Layer & Layer::operator=(const Layer & other)
{
    // this should never be called, but need to make vector::resize happy
    return *this;
}

void Layer::reset()
{
    x = y = 0;
    off_x = off_y = 0;
    scroll_x = scroll_y = 0;
    back = NULL;

    update_position();
#ifdef CHOWDREN_IS_3DS
    depth = 0.0f;
#endif
}

void Layer::init(int index, double coeff_x, double coeff_y, bool visible,
                 bool wrap_x, bool wrap_y)
{
    reset();

#if defined(CHOWDREN_HAS_MRT)
    remote = CHOWDREN_TV_TARGET;
#endif

    this->index = index;
    this->coeff_x = coeff_x;
    this->coeff_y = coeff_y;
    this->visible = visible;
    this->wrap_x = wrap_x;
    this->wrap_y = wrap_y;

    scroll_active = coeff_x != 1.0 || coeff_y != 1.0;

    if (this == &default_layer)
        return;

    broadphase.init();
}

Layer::~Layer()
{
    delete back;

    // layers are in charge of deleting background instances
    FlatObjectList::const_iterator it;
    for (it = background_instances.begin(); it != background_instances.end();
         ++it) {
        FrameObject * obj = *it;
        obj->dealloc();
    }
}

void Layer::scroll(int scroll_x, int scroll_y, int dx, int dy)
{
    this->scroll_x = scroll_x;
    this->scroll_y = scroll_y;
    update_position();

    LayerInstances::iterator it;
    for (it = instances.begin(); it != instances.end(); ++it) {
        FrameObject * object = &*it;
        if (object->flags & SCROLL)
            continue;
        object->set_position(object->x + dx, object->y + dy);
    }

#ifdef CHOWDREN_LAYER_WRAP
    if (wrap_x) {
        dy = 0;
    } else if (wrap_y) {
        dx = 0;
    } else
        return;
    FlatObjectList::const_iterator it2;
    for (it2 = background_instances.begin(); it2 != background_instances.end();
         ++it2) {
        FrameObject * object = *it2;
        // XXX stupid
        object->set_position(object->x + dx, object->y + dy);
        object->set_backdrop_offset(-dx, -dy);
    }
#endif

}

void Layer::set_position(int x, int y)
{
    int dx = x - this->x;
    int dy = y - this->y;
    this->x = x;
    this->y = y;
    update_position();

    LayerInstances::iterator it;

#ifdef CHOWDREN_LAYER_WRAP
    // XXX this is stupid
    if (wrap_x || wrap_y) {
        FlatObjectList::const_iterator it2;
        for (it2 = background_instances.begin();
             it2 != background_instances.end(); ++it2)
        {
            FrameObject * item = *it2;
            if (wrap_x) {
                item->set_backdrop_offset(dx, 0);
                continue;
            }
            if (wrap_y) {
                item->set_backdrop_offset(0, dy);
                continue;
            }
        }
    }

    dx = -dx;
    dy = -dy;
#endif

    for (it = instances.begin(); it != instances.end(); ++it) {
        FrameObject * object = &*it;
        if (object->flags & SCROLL)
            continue;
        object->set_position(object->x - dx, object->y - dy);
    }
}

#define INACTIVE_X 64
#define INACTIVE_Y 16
#define KILL_X 480
#define KILL_Y 300

void Layer::update_position()
{
#ifdef CHOWDREN_LAYER_WRAP
    // XXX this is stupid
    off_x = scroll_x;
    off_y = scroll_y;
#else
    off_x = scroll_x + x;
    off_y = scroll_y + y;
#endif
    Frame * frame = manager.frame;
    if (frame == NULL) {
        for (int i = 0; i < 4; i++) {
            inactive_box[i] = 0;
        }
        return;
    }

    int frame_x = frame->off_x;
    int frame_y = frame->off_y;
    int w = frame->virtual_width;
    int h = frame->virtual_height;

    int x1 = frame_x - INACTIVE_X;
    if (x1 < 0)
        x1 = -KILL_X;

    int x2 = frame_x + WINDOW_WIDTH + INACTIVE_X;
    if (x2 > w)
        x2 = w + KILL_X;

    int y1 = frame_y - INACTIVE_Y;
    if (y1 < 0)
        y1 = -KILL_Y;

    int y2 = frame_y + WINDOW_HEIGHT + INACTIVE_Y;
    if (y2 > h)
        y2 = h + KILL_Y;

    inactive_box[0] = x1 - off_x;
    inactive_box[2] = x2 - off_x;
    inactive_box[1] = y1 - off_y;
    inactive_box[3] = y2 - off_y;

    kill_box[0] = -KILL_X - off_x;
    kill_box[2] = w + KILL_X - off_x;
    kill_box[1] = -KILL_Y - off_y;
    kill_box[3] = h + KILL_Y - off_y;
}

void Layer::add_background_object(FrameObject * instance)
{
    if (background_instances.empty())
        instance->depth = 0;
    else
        instance->depth = background_instances.back()->depth + 1;
    background_instances.push_back(instance);
}

void Layer::remove_background_object(FrameObject * instance)
{
    FlatObjectList::iterator it;
    for (it = background_instances.begin(); it != background_instances.end();
         ++it) {
        if (*it != instance)
            continue;
        background_instances.erase(it);
        break;
    }
}

// means we can store about 20,000 objects in both directions
#define LAYER_DEPTH_SPACING 100000
#define LAYER_DEPTH_START 0x7FFFFFFF

inline unsigned int add_depth(unsigned int start, unsigned int add,
                              bool * reset)
{
    if (0xFFFFFFFF - start < add) {
        *reset = true;
        return 0;
    }
    return start + add;
}

inline unsigned int sub_depth(unsigned int start, unsigned int sub,
                              bool * reset)
{
    if (start < sub) {
        *reset = true;
        return 0;
    }
    return start - sub;
}

void Layer::add_object(FrameObject * instance)
{
    bool reset = false;
    if (instances.empty())
        instance->depth = LAYER_DEPTH_START;
    else
        instance->depth = add_depth(instances.back().depth,
                                    LAYER_DEPTH_SPACING,
                                    &reset);

    instances.push_back(*instance);

    if (reset) {
#ifndef NDEBUG
        std::cout << "Flush in add_object" << std::endl;
#endif
        reset_depth();
    }
}

void Layer::insert_object(FrameObject * instance, int index)
{
    bool reset = false;

    if (index == 0) {
        if (instances.empty())
            instance->depth = LAYER_DEPTH_START;
        else
            instance->depth = sub_depth(instances.front().depth,
                                        LAYER_DEPTH_SPACING,
                                        &reset);

        instances.push_front(*instance);

        if (reset) {
#ifndef NDEBUG
            std::cout << "Flush in insert_object (1)" << std::endl;
#endif
            reset_depth();
        }
        return;
    }
    LayerInstances::iterator it = instances.begin();
    std::advance(it, index - 1);
    unsigned int prev = it->depth;
    ++it;
    unsigned int next = it->depth;
    unsigned int new_depth = prev + (next - prev) / 2;
    instance->depth = new_depth;
    instances.insert(it, *instance);

    if (new_depth == next || new_depth == prev) {
#ifndef NDEBUG
        std::cout << "Flush in insert_object (2)" << std::endl;
#endif
        reset_depth();
    }
}

void Layer::reset_depth()
{
    LayerInstances::iterator it;
    unsigned int i = LAYER_DEPTH_START;
    for (it = instances.begin(); it != instances.end(); ++it) {
        it->depth = i;
        i += LAYER_DEPTH_SPACING;
    }
}

void Layer::remove_object(FrameObject * instance)
{
    instances.erase(LayerInstances::s_iterator_to(*instance));
}

void Layer::set_level(FrameObject * instance, int new_index)
{
    if (instance->flags & BACKGROUND)
        return;
    remove_object(instance);
    if (new_index == -1 || new_index >= int(instances.size())) {
        add_object(instance);
    } else {
        insert_object(instance, new_index);
    }
}

int Layer::get_level(FrameObject * instance)
{
    LayerInstances::const_iterator it;
    int i = 0;
    for (it = instances.begin(); it != instances.end(); ++it) {
        if (&*it == instance)
            return i;
        i++;
    }
    return -1;
}

void Layer::destroy_backgrounds()
{
    if (back == NULL)
        return;
    back->reset();
}

void Layer::destroy_backgrounds(int x, int y, bool fine)
{
    if (fine)
        std::cout << "Destroy backgrounds at " << x << ", " << y <<
            " (" << fine << ") not implemented" << std::endl;
    back->destroy_at(x, y);
}

struct BackgroundCallback
{
    CollisionBase * col;
    CollisionBase * other;

    BackgroundCallback(CollisionBase * col)
    : col(col)
    {
    }

    bool on_callback(void * data)
    {
        FrameObject * obj = (FrameObject*)data;
        if (!(obj->flags & BACKGROUND_COL))
            return true;
        if (obj->collision == NULL)
            return true;
        other = obj->collision;
        return !collide(col, other);
    }
};

CollisionBase * Layer::test_background_collision(CollisionBase * a)
{
    if (back != NULL) {
        CollisionBase * ret = back->collide(a);
        if (ret)
            return ret;
    }
    BackgroundCallback callback(a);
    if (!broadphase.query_static(a->aabb, callback))
        return callback.other;
    return NULL;
}

CollisionBase * Layer::test_background_collision(int x, int y)
{
    x -= off_x;
    y -= off_y;
    PointCollision col(x, y);
    return test_background_collision(&col);
}

void Layer::paste(Image * img, int dest_x, int dest_y,
                  int src_x, int src_y, int src_width, int src_height,
                  int collision_type, int effect, const Color & color)
{
    if (collision_type != 0 && collision_type != 1 && collision_type != 3 &&
        collision_type != 4)
    {
        std::cout << "Collision type " << collision_type << " not supported"
            << std::endl;
    }
    if (back == NULL)
        back = new Background;
    back->paste(img, dest_x, dest_y, src_x, src_y,
                src_width, src_height, collision_type, effect, color);
}

struct DrawCallback
{
    FlatObjectList & list;
    int * aabb;

    DrawCallback(FlatObjectList & list, int v[4])
    : list(list), aabb(v)
    {
    }

    bool on_callback(void * data)
    {
        FrameObject * item = (FrameObject*)data;
        if (!(item->flags & VISIBLE) || item->flags & DESTROYING)
            return true;
        if (!collide_box(item, aabb))
            return true;
        list.push_back(item);
        return true;
    }
};

inline bool sort_depth_comp(FrameObject * obj1, FrameObject * obj2)
{
    if (obj1->flags & BACKGROUND && !(obj2->flags & BACKGROUND))
        return true;
    if (obj2->flags & BACKGROUND && !(obj1->flags & BACKGROUND))
        return false;
    return obj1->depth < obj2->depth;
}

inline void sort_depth(FlatObjectList & list)
{
    std::sort(list.begin(), list.end(), sort_depth_comp);
}

void Layer::draw(int display_x, int display_y)
{
    if (!visible)
        return;

#ifdef CHOWDREN_LAYER_WRAP
    int x, y;
    x = y = 0;
#endif

    Render::set_offset(-floor(display_x * coeff_x - x),
                       -floor(display_y * coeff_y - y));

#ifdef CHOWDREN_IS_3DS
    Render::set_global_depth(depth);
#endif

    // draw backgrounds
    int x1 = display_x * coeff_x - x;
    int y1 = display_y * coeff_y - y;
    int x2 = x1+WINDOW_WIDTH;
    int y2 = y1+WINDOW_HEIGHT;

    PROFILE_BEGIN(Layer_draw_instances);

#ifdef CHOWDREN_USE_VIEWPORT
    int v[4];
    Viewport * view = Viewport::instance;
    if (view != NULL && index <= view->layer->index) {
        v[0] = x1 + view->center_x - view->src_width / 2;
        v[1] = y1 + view->center_y - view->src_height / 2;
        v[2] = v[0] + view->src_width;
        v[3] = v[1] + view->src_height;
    } else {
        v[0] = x1;
        v[1] = y1;
        v[2] = x2;
        v[3] = y2;
    }
#else
    int v[4] = {x1, y1, x2, y2};
#endif

    static FlatObjectList draw_list;
    draw_list.clear();
    DrawCallback callback(draw_list, v);
    broadphase.query(v, callback);

    sort_depth(draw_list);

    FlatObjectList::const_iterator it;
    for (it = draw_list.begin(); it != draw_list.end(); ++it) {
        FrameObject * obj = *it;
        if (!(obj->flags & BACKGROUND))
            break;
        obj->draw();
    }

    PROFILE_BEGIN(Layer_draw_pasted);

    // draw pasted items
    if (back != NULL) {
        back->draw(v);
    }

    PROFILE_END();

    for (; it != draw_list.end(); ++it) {
        (*it)->draw();
    }

    if (blend_color.r != 255 || blend_color.g != 255 || blend_color.b != 255) {
        Render::set_effect(Render::LAYERCOLOR);
        Render::set_offset(0, 0);
        Render::draw_quad(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, blend_color);
        Render::disable_effect();
    }

    PROFILE_END();
}

#if defined(CHOWDREN_HAS_MRT)
void Layer::set_remote(int value)
{
    remote = value;
}
#endif

// FrameData

FrameData::FrameData()
{
}

void FrameData::event_callback(int id)
{
}

void FrameData::init()
{
}

void FrameData::on_start()
{
}

void FrameData::on_end()
{
}

void FrameData::on_app_end()
{
}

void FrameData::handle_events()
{
}

void FrameData::handle_pre_events()
{
}

// Frame

Frame::Frame()
: off_x(0), off_y(0), new_off_x(0), new_off_y(0), has_quit(false),
  last_key(-1), next_frame(-1), loop_count(0), frame_time(0.0),
  index(-1)
{
}

void Frame::pause()
{
}

void Frame::restart()
{
    next_frame = -2;
}

void Frame::set_timer(double value)
{
    frame_time = value;
}

void Frame::set_lives(int value)
{
    manager.lives = value;
    if (value != 0)
        return;
    manager.player_died = true;
}

void Frame::set_score(int value)
{
    manager.score = value;
}

void Frame::set_display_center(int x, int y)
{
    /* note: there is a bug in MMF where you can only set the center if it
       is not equivalent to the old one, even if a new position was set.
       we need to emulate that bug here. */
    if (x != -1) {
        x = int_max(0, x - WINDOW_WIDTH / 2);
        x = int_min(x, virtual_width - WINDOW_WIDTH);
        if (x != off_x)
            new_off_x = x;
    }
    if (y != -1) {
        y = int_max(0, y - WINDOW_HEIGHT / 2);
        y = int_min(y, virtual_height - WINDOW_HEIGHT);
        if (y != off_y)
            new_off_y = y;
    }
}

void Frame::update_display_center()
{
    if (off_x == new_off_x && off_y == new_off_y)
        return;

    int old_x = off_x;
    int old_y = off_y;
    off_x = new_off_x;
    off_y = new_off_y;

    vector<Layer>::iterator it;
    for (it = layers.begin(); it != layers.end(); ++it) {
        Layer & layer = *it;
        int x1 = old_x * layer.coeff_x;
        int y1 = old_y * layer.coeff_y;
        int x2 = off_x * layer.coeff_x;
        int y2 = off_y * layer.coeff_y;
        int layer_off_x = off_x - x2;
        int layer_off_y = off_y - y2;
        layer.scroll(layer_off_x, layer_off_y, x2 - x1, y2 - y1);
    }
}

void Frame::set_width(int w, bool adjust)
{
    virtual_width = width = w;
    std::cout << "Set frame width: " << width << " " << adjust << std::endl;
}

void Frame::set_height(int h, bool adjust)
{
    virtual_height = height = h;
    std::cout << "Set frame height: " << height << " " << adjust << std::endl;
}

void Frame::set_background_color(const Color & color)
{
    background_color = color;
}

void Frame::get_mouse_pos(int * x, int * y)
{
    *x = manager.mouse_x + off_x;
    *y = manager.mouse_y + off_y;
}

int Frame::get_mouse_x()
{
    int x, y;
    get_mouse_pos(&x, &y);
    return x;
}

int Frame::get_mouse_y()
{
    int x, y;
    get_mouse_pos(&x, &y);
    return y;
}

bool Frame::mouse_in_zone(int x1, int y1, int x2, int y2)
{
    int x, y;
    get_mouse_pos(&x, &y);
    return collides(x, y, x+1, y+1, x1, y1, x2, y2);
}

CollisionBase * Frame::test_background_collision(int x, int y)
{
    if (x < 0 || y < 0 || x > width || y > height)
        return NULL;
    vector<Layer>::iterator it;
    for (it = layers.begin(); it != layers.end(); ++it) {
        CollisionBase * ret = (*it).test_background_collision(x, y);
        if (ret == NULL)
            continue;
        return ret;
    }
    return NULL;
}

int Frame::get_background_mask(int x, int y)
{
    CollisionBase * other = test_background_collision(x, y);
    if (other == NULL)
        return 0;
    if (other->flags & LADDER_OBSTACLE)
        return 2;
    else
        return 1;
}

bool Frame::test_obstacle(int x, int y)
{
    return get_background_mask(x, y) == 1;
}

bool Frame::test_ladder(int x, int y)
{
    return get_background_mask(x, y) == 2;
}

bool Frame::compare_joystick_direction(int n, int test_dir)
{
    if (!is_joystick_attached(n))
        return false;
    return get_joystick_direction(n) == test_dir;
}

bool Frame::is_joystick_direction_changed(int n)
{
    if (!is_joystick_attached(n))
        return false;
    // hack for now
    static int last_dir = get_joystick_direction(n);
    int new_dir = get_joystick_direction(n);
    bool ret = last_dir != new_dir;
    last_dir = new_dir;
    return ret;
}

void Frame::set_vsync(bool value)
{
    platform_set_vsync(value);
}

#define INSTANCE_MAP instances

int Frame::get_instance_count()
{
    int size = 0;
    ObjectList::iterator it;
    for (unsigned int i = 0; i < MAX_OBJECT_ID; i++) {
        ObjectList & list = INSTANCE_MAP.items[i];
        size += list.size();
    }
    return size;
}

void Frame::clean_instances()
{
    FlatObjectList::const_iterator it;
    for (it = destroyed_instances.begin(); it != destroyed_instances.end();
         ++it) {
        FrameObject * instance = *it;
        INSTANCE_MAP.items[instance->id].remove(instance);
        if (instance->flags & BACKGROUND)
            instance->layer->remove_background_object(instance);
        else
            instance->layer->remove_object(instance);
        instance->dealloc();
    }
    destroyed_instances.clear();
}

void Frame::update_objects()
{
}

void Frame::load_static_images()
{
}

bool Frame::update()
{
    frame_time += manager.dt;

    if (timer_base == 0) {
        timer_mul = 1.0f;
    } else {
        // timer_mul = manager.dt * timer_base;
        timer_mul = (1.0f / FRAMERATE) * timer_base;
    }

    if (loop_count == 0) {
        data->init();
        update_objects();
        data->on_start();
    } else {
        PROFILE_BEGIN(handle_pre_events);
        data->handle_pre_events();
        PROFILE_END();

        PROFILE_BEGIN(frame_update_objects);
        update_objects();
        PROFILE_END();

        PROFILE_BEGIN(clean_instances);
        clean_instances();
        PROFILE_END();
    }

    PROFILE_BEGIN(handle_events);
    data->handle_events();
    update_display_center();
    PROFILE_END();

    manager.player_died = false;
    last_key = -1;
    loop_count++;

    return !has_quit;
}

void Frame::draw(int remote)
{
    PROFILE_BEGIN(frame_draw_start);
    // first, draw the actual window contents
    Render::set_view(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
#ifdef CHOWDREN_HAS_MRT
    if (remote == CHOWDREN_REMOTE_TARGET) {
        Render::clear(Color(0, 0, 0, 255));
    } else if (remote != CHOWDREN_REMOTE_ONLY)
#endif
    {
        Render::clear(background_color);
    }

    PROFILE_END();

    vector<Layer>::iterator it;
    for (it = layers.begin(); it != layers.end(); ++it) {
        Layer & layer = *it;

#ifdef CHOWDREN_HAS_MRT
        if (remote == CHOWDREN_HYBRID_TARGET) {
            if (layer.remote == CHOWDREN_REMOTE_TARGET)
                continue;
        } else if (remote == CHOWDREN_REMOTE_TARGET) {
            if (layer.remote == CHOWDREN_TV_TARGET)
                continue;
        } else if (remote == CHOWDREN_TV_TARGET) {
            if (layer.remote != CHOWDREN_TV_TARGET)
                continue;
        } else if (remote == CHOWDREN_REMOTE_ONLY) {
            if (layer.remote != CHOWDREN_REMOTE_TARGET)
                continue;
        }
#endif

#ifdef CHOWDREN_IS_TE
        static Framebuffer layer_fbo;
        if (layer.blend_color.a < 255) {
            if (layer_fbo.tex == 0)
                layer_fbo.init(WINDOW_WIDTH, WINDOW_HEIGHT);
            layer_fbo.bind();
            Render::clear(255, 255, 255, 0);
        }
#endif

        layer.draw(off_x, off_y);

#ifdef CHOWDREN_IS_TE
        if (layer.blend_color.a < 255) {
            Render::set_offset(0, 0);
            layer_fbo.unbind();

            Render::draw_tex(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT,
                             layer.blend_color, layer_fbo.get_tex(),
                             fbo_texcoords[0], fbo_texcoords[1],
                             fbo_texcoords[2], fbo_texcoords[3]);
        }
#endif
    }

#ifdef CHOWDREN_USE_CAPTURE
    if (remote != CHOWDREN_REMOTE_ONLY)
        CaptureObject::on_capture();
#endif

// #ifdef CHOWDREN_USE_BOX2D
//     Box2D::draw_debug();
// #endif
}

void setup_default_instance(FrameObject * obj)
{
    obj->layer = &default_layer;
    obj->width = obj->height = 0;
    if (obj->collision == NULL)
        return;
    for (int i = 0; i < 4; ++i)
        obj->collision->aabb[i] = 0;
}

FrameObject * Frame::add_object(FrameObject * instance, Layer * layer)
{
    instance->frame = this;
    instance->layer = layer;
    INSTANCE_MAP.items[instance->id].add(instance);
    layer->add_object(instance);
    if (instance->collision) {
        instance->collision->update_aabb();
        instance->collision->create_proxy();
    }
    return instance;
}

FrameObject * Frame::add_object(FrameObject * instance, int layer_index)
{
    layer_index = int_max(0, int_min(layer_index, layers.size() - 1));
    return add_object(instance, &layers[layer_index]);
}

void Frame::add_background_object(FrameObject * instance, int layer_index)
{
    instance->frame = this;
    Layer * layer = &layers[layer_index];
    instance->layer = layer;
    if (instance->id != BACKGROUND_TYPE)
        INSTANCE_MAP.items[instance->id].add(instance);
    layer->add_background_object(instance);
    if (instance->collision) {
        instance->collision->update_aabb();
        instance->collision->create_static_proxy();
    } else {
        int bb[4] = {instance->x,
                     instance->y,
                     instance->x + instance->width,
                     instance->y + instance->height};
        layer->broadphase.add(instance, bb);
    }
}

void Frame::set_object_layer(FrameObject * instance, int new_layer)
{
    if (instance->flags & BACKGROUND) {
        std::cout << "Cannot move background object layer" << std::endl;
        return;
    }
    new_layer = clamp(new_layer, 0, layers.size()-1);
    Layer * layer = &layers[new_layer];
    if (layer == instance->layer)
        return;
    instance->layer->remove_object(instance);
    if (instance->collision)
        instance->collision->remove_proxy();
    layer->add_object(instance);
    int x = instance->get_x();
    int y = instance->get_y();
    instance->layer = layer;
    instance->set_global_position(x, y);
    if (instance->collision)
        instance->collision->create_proxy();
}

int Frame::get_loop_index(const std::string & name)
{
    return *((*loops)[name].index);
}

void Frame::reset()
{
    ObjectList::iterator it;
    for (unsigned int i = 0; i < MAX_OBJECT_ID; i++) {
        ObjectList & list = INSTANCE_MAP.items[i];
        for (it = list.begin(); it != list.end(); ++it) {
            if (it->obj->flags & BACKGROUND)
                continue;
            it->obj->dealloc();
        }
    }

    layers.clear();
    INSTANCE_MAP.clear();
    destroyed_instances.clear();
    next_frame = -1;
    loop_count = 0;
    off_x = new_off_x = 0;
    off_y = new_off_y = 0;
    frame_time = 0.0;

#ifdef CHOWDREN_USE_BACKMAGIC
    for (unsigned int i = 0; i < MAX_BACK_ID; ++i) {
        back_instances[i].clear();
    }
#endif
}

// FrameObject

FrameObject::FrameObject(int x, int y, int type_id)
: x(x), y(y), id(type_id), flags(SCROLL | VISIBLE), effect(Render::NONE),
  alterables(NULL), shader_parameters(NULL), direction(0),
  movement(NULL), movements(NULL), movement_count(0), collision(NULL),
  collision_flags(0)
{
#ifdef CHOWDREN_USE_BOX2D
    body = -1;
#endif

#ifdef CHOWDREN_USE_VALUEADD
    extra_alterables = NULL;
#endif

#ifdef CHOWDREN_USE_PATHPLANNER
    agent = NULL;
#endif

#ifdef CHOWDREN_USE_MOVEIT
    move_data = NULL;
#endif
}

FrameObject::~FrameObject()
{
    delete movement;
    if (movements != NULL) {
        for (int i = 0; i < movement_count; i++) {
            if (movement == movements[i])
                continue;
            delete movements[i];
        }
        delete[] movements;
    }
    delete shader_parameters;
    if (!(flags & GLOBAL))
        Alterables::destroy(alterables);

#ifdef CHOWDREN_USE_VALUEADD
    delete extra_alterables;
#endif

#ifdef CHOWDREN_USE_PATHPLANNER
    delete agent;
#endif

#ifdef CHOWDREN_USE_MOVEIT
    delete move_data;
#endif
}

#ifndef CHOWDREN_USE_DIRECT_RENDERER
void FrameObject::draw_image(Image * img, int x, int y, Color c)
{
    img->upload_texture();
    int x1 = x - img->hotspot_x;
    int y1 = y - img->hotspot_y;
    int x2 = x1 + img->width;
    int y2 = y1 + img->height;
    if (effect == Render::NONE) {
        Render::draw_tex(x1, y1, x2, y2, c, img->tex);
        return;
    }
    Render::set_effect(effect, this, img->width, img->height);
    Render::draw_tex(x1, y1, x2, y2, c, img->tex);
    Render::disable_effect();
}

void FrameObject::draw_image(Image * img, int x, int y, Color c, float angle,
                             float x_scale, float y_scale)
{
    if (effect == Render::NONE) {
        img->draw(x, y, c, angle, x_scale, y_scale);
        return;
    }
    Render::set_effect(effect, this, img->width, img->height);
    img->draw(x, y, c, angle, x_scale, y_scale);
    Render::disable_effect();
}

void FrameObject::draw_image(Image * img, int x, int y, Color c, float angle,
                             float x_scale, float y_scale, bool flip_x)
{
    if (!flip_x) {
        draw_image(img, x, y, c, angle, x_scale, y_scale);
        return;
    }
    if (effect == Render::NONE) {
        img->draw_flip_x(x, y, c, angle, x_scale, y_scale);
        return;
    }
    Render::set_effect(effect, this, img->width, img->height);
    img->draw_flip_x(x, y, c, angle, x_scale, y_scale);
    Render::disable_effect();
}
#endif

void FrameObject::begin_draw(int width, int height)
{
    if (effect == Render::NONE)
        return;
	Render::set_effect(effect, this, width, height);
}

void FrameObject::begin_draw()
{
    if (effect == Render::NONE)
        return;
    Render::set_effect(effect, this, width, height);
}

void FrameObject::end_draw()
{
    if (effect == Render::NONE)
        return;
    Render::disable_effect();
}

void FrameObject::set_position(int new_x, int new_y)
{
    if (new_x == x && new_y == y)
        return;
    if (collision == NULL) {
        x = new_x;
        y = new_y;
        return;
    }
    int dx = new_x - x;
    int dy = new_y - y;
    x = new_x;
    y = new_y;
    collision->aabb[0] += dx;
    collision->aabb[1] += dy;
    collision->aabb[2] += dx;
    collision->aabb[3] += dy;
    collision->update_proxy();
}

void FrameObject::set_global_position(int x, int y)
{
    set_position(x - layer->off_x, y - layer->off_y);
}

void FrameObject::set_x(int new_x)
{
    new_x -= layer->off_x;
    if (x == new_x)
        return;
    if (collision == NULL) {
        x = new_x;
        return;
    }
    int d = new_x - x;
    x = new_x;
    collision->aabb[0] += d;
    collision->aabb[2] += d;
    collision->update_proxy();
}

void FrameObject::set_y(int new_y)
{
    new_y -= layer->off_y;
    if (y == new_y)
        return;
    if (collision == NULL) {
        y = new_y;
        return;
    }
    int d = new_y - y;
    y = new_y;
    collision->aabb[1] += d;
    collision->aabb[3] += d;
    collision->update_proxy();
}

void FrameObject::create_alterables()
{
    alterables = Alterables::create();
}

void FrameObject::set_visible(bool value)
{
    flash(0);

    if (value)
        flags |= VISIBLE;
    else
        flags &= ~VISIBLE;
}

void FrameObject::set_blend_color(int color)
{
    int a = blend_color.a;
    blend_color = Color(color);
    blend_color.a = a;
}

void FrameObject::set_layer(int index)
{
    frame->set_object_layer(this, index);
}

void FrameObject::flash(float value) {}
void FrameObject::draw() {}
void FrameObject::set_direction(int value, bool set_movement)
{
    direction = value & 31;
    if (set_movement && movement != NULL)
        movement->set_direction(value);
}

int FrameObject::get_direction()
{
    return direction;
}

bool FrameObject::mouse_over()
{
    if (flags & DESTROYING)
        return false;
    if (collision == NULL) {
        return false;
    }
    int x, y;
    frame->get_mouse_pos(&x, &y);
    x -= layer->off_x;
    y -= layer->off_y;
    PointCollision col1(x, y);
    bool result = collide(&col1, collision);
    return result;
}

bool FrameObject::overlaps(FrameObject * other)
{
    if (flags & INACTIVE || other->flags & INACTIVE)
        return false;
    if (other == this)
        return false;
    if (collision == NULL || other->collision == NULL)
        return false;
    if (collision->type == NONE_COLLISION)
        return false;
    CollisionBase * other_col = other->collision;
    if (other_col->type == NONE_COLLISION)
        return false;
    if (other->layer != layer)
        return false;
#ifdef CHOWDREN_DEFER_COLLISIONS
    int * other_aabb;
    if (other->flags & DEFER_COLLISIONS)
        other_aabb = ((Active*)other)->old_aabb;
    else
        other_aabb = other_col->aabb;
    return collide(collision, other_col, other_aabb);
#else
    return collide(collision, other_col);
#endif
}

struct BackgroundOverlapCallback
{
    CollisionBase * collision;

    BackgroundOverlapCallback(CollisionBase * collision)
    : collision(collision)
    {
    }

    inline bool on_callback(void * data)
    {
        FrameObject * obj = (FrameObject*)data;
        if (!(obj->flags & BACKGROUND_COL))
            return true;
        CollisionBase * other = (CollisionBase*)obj->collision;
        if (other == NULL)
            return true;
        if (other->flags & LADDER_OBSTACLE)
            return true;
        if (!collide(collision, other))
            return true;
        return false;
    }
};

bool FrameObject::overlaps_background()
{
    if (flags & DESTROYING || collision == NULL)
        return false;
    if (flags & HAS_COLLISION_CACHE)
        return (flags & HAS_COLLISION) != 0;
    // XXX also cache pasted collisions? will need ID to see if
    // pasted items were changed
    Background * b = layer->back;
    int * aabb = collision->aabb;
    if (b != NULL) {
        BackgroundItems::iterator it;
#ifdef CHOWDREN_PASTE_PRECEDENCE
		int col_w = b->col_w;
		BitArray & col = b->col;
        int test[4] = {std::max(0, aabb[0]), std::min(col_w, aabb[1]),
                       std::max(0, aabb[2]), std::min(b->col_h, aabb[3])};
        bool miss = false;
        for (int y = test[1]; y < test[3]; ++y)
        for (int x = test[0]; x < test[2]; ++x) {
            if (!col.get(y * col_w + x)) {
                miss = true;
                break;
            }
        }
        if (!miss)
            return false;
#endif
        for (it = b->col_items.begin(); it != b->col_items.end(); ++it) {
            BackgroundItem * item = *it;
            if (item->flags & LADDER_OBSTACLE)
                continue;
            if (::collide(collision, item))
                return true;
        }
    }
    flags |= HAS_COLLISION_CACHE;
    BackgroundOverlapCallback callback(collision);
    if (!layer->broadphase.query_static(collision->proxy, callback)) {
        flags |= HAS_COLLISION;
        return true;
    }
    return false;
}

bool FrameObject::overlaps_background_save()
{
    bool ret = overlaps_background();
    if (ret && movement != NULL) {
        movement->set_background_collision();
    }
    return ret;
}

bool FrameObject::outside_playfield()
{
    if (collision == NULL) return false;
    int * box = collision->aabb;
    int x1 = box[0] + layer->off_x;
    int y1 = box[1] + layer->off_y;
    int x2 = box[2] + layer->off_x;
    int y2 = box[3] + layer->off_y;
    return x1 > frame->width || y1 > frame->height || x2 < 0 || y2 < 0;
}

bool FrameObject::is_near_border(int border)
{
    if (collision == NULL) return false;
    int * box = collision->aabb;
    int off_x = layer->off_x;
    int off_y = layer->off_y;

    if (box[0] + off_x <= frame->frame_left() + border)
        return true;

    if (box[2] + off_x >= frame->frame_right() - border)
        return true;

    if (box[1] + off_y <= frame->frame_top() + border)
        return true;

    if (box[3] + off_y >= frame->frame_bottom() - border)
        return true;

    return false;
}

int FrameObject::get_box_index(int index)
{
    int ret;
    if (collision == NULL) {
        switch (index) {
            case 0:
                ret = x;
                break;
            case 1:
                ret = y;
                break;
            case 2:
                ret = x + width;
                break;
            case 3:
                ret = y + height;
                break;
        }
    } else
        ret = collision->aabb[index];
    if (index == 0 || index == 2)
        ret += layer->off_x;
    else
        ret += layer->off_y;
    return ret;
}

int FrameObject::get_generic_width()
{
    if (collision == NULL)
        return width;
    return collision->aabb[2] - collision->aabb[0];
}

int FrameObject::get_generic_height()
{
    if (collision == NULL)
        return height;
    return collision->aabb[3] - collision->aabb[1];
}

void FrameObject::set_shader(int value)
{
    if (shader_parameters == NULL)
        shader_parameters = new ShaderParameters;
    effect = value;
}

void FrameObject::set_shader_parameter(const std::string & name, double value)
{
    if (name.empty())
        return;
    if (shader_parameters == NULL)
        shader_parameters = new ShaderParameters;
    unsigned int hash = hash_shader_parameter(&name[0], name.size());
    ShaderParameter * param = find_shader_parameter(hash);
    if (param == NULL) {
        shader_parameters->emplace_back();
        param = &shader_parameters->back();
        param->hash = hash;
    }
    param->value = value;
}

void FrameObject::set_shader_parameter(const std::string & name, Image & img)
{
    if (name.empty())
        return;
    img.upload_texture();
    set_shader_parameter(name, (double)img.tex);
}

void FrameObject::set_shader_parameter(const std::string & name,
                                       const std::string & path)
{
    if (name.empty())
        return;
    Image * img = get_image_cache(path, 0, 0, 0, 0, TransparentColor());
    set_shader_parameter(name, *img);
}

void FrameObject::set_shader_parameter(const std::string & name,
                                       const Color & color)
{
    if (name.empty())
        return;
    set_shader_parameter(name, (double)color.get_int());
}

void FrameObject::destroy()
{
    if (flags & DESTROYING)
        return;
    flags |= DESTROYING;
    if (collision != NULL)
        collision->type = NONE_COLLISION;
    frame->destroyed_instances.push_back(this);
}

void FrameObject::set_level(int index)
{
#ifndef NDEBUG
    std::cout << "Using slow path set_level() for " << get_name() << std::endl;
#endif
    index = std::max(0, index - 1);
    layer->set_level(this, index);
}

int FrameObject::get_level()
{
#ifndef NDEBUG
    std::cout << "Using slow path get_level() for " << get_name() << std::endl;
#endif
    return layer->get_level(this) + 1;
}

void FrameObject::move_back()
{
    layer->set_level(this, 0);
}

void FrameObject::move_front()
{
    layer->set_level(this, -1);
}

inline unsigned int get_next_depth(unsigned int prev, unsigned int next,
                                   bool * reset)
{
    unsigned int d = next - prev;
    unsigned int v = LAYER_DEPTH_SPACING / 10;
    while (v >= d && v != 0)
        v /= 10;
    if (v == 0)
        *reset = true;
    return v;
}

void FrameObject::move_relative(FrameObject * other, int disp)
{
    // XXX not 100% correct behaviour, but good enough for our purposes
    if (other == NULL)
        return;
    if (other->layer != layer)
        return;
    LayerInstances::iterator it = LayerInstances::s_iterator_to(*other);
    if (disp < 0) {
        while (disp < 0 && it != layer->instances.begin()) {
            it--;
            disp++;
        }
        move_back(&*it);
    } else {
        while (disp > 0) {
            it++;
            disp--;
            if (it != layer->instances.end())
                continue;
            it--;
            break;
        }
        move_front(&*it);
    }
}

void FrameObject::move_back(FrameObject * other)
{
    if (other == NULL)
        return;
    if (other->layer != layer)
        return;
    if (depth <= other->depth)
        return;

    LayerInstances::iterator it = LayerInstances::s_iterator_to(*other);
    unsigned int next = it->depth;

    bool reset = false;
    if (it == layer->instances.begin()) {
        depth = sub_depth(next, LAYER_DEPTH_SPACING, &reset);
    } else {
        unsigned int prev = (--LayerInstances::s_iterator_to(*other))->depth;
        depth = prev + get_next_depth(prev, next, &reset);
    }

    layer->instances.erase(LayerInstances::s_iterator_to(*this));
    layer->instances.insert(it, *this);

    if (reset) {
#ifndef NDEBUG
        std::cout << "Flush in move_back" << std::endl;
#endif
        layer->reset_depth();
    }
}

void FrameObject::move_front(FrameObject * other)
{
    if (other == NULL)
        return;
    if (other->layer != layer)
        return;
    if (depth >= other->depth)
        return;

    LayerInstances::iterator it = LayerInstances::s_iterator_to(*other);
    unsigned int prev = it->depth;
    ++it;

    bool reset = false;
    if (it == layer->instances.end()) {
        depth = add_depth(prev, LAYER_DEPTH_SPACING, &reset);
    } else {
        unsigned int next = it->depth;
        depth = next - get_next_depth(prev, next, &reset);

        if (reset) {
            std::cout << "move_front flush: " << next << " " << prev << std::endl;
        }
    }

    layer->instances.erase(LayerInstances::s_iterator_to(*this));
    layer->instances.insert(it, *this);

    if (reset) {
#ifndef NDEBUG
        std::cout << "Flush in move_front: " << depth << std::endl;
#endif
        layer->reset_depth();
    }
}

FixedValue FrameObject::get_fixed()
{
    return FixedValue(this);
}

void FrameObject::clear_movements()
{
    if (movements != NULL) {
        for (int i = 0; i < movement_count; i++) {
            if (movement == movements[i])
                continue;
            delete movements[i];
        }
        movements = NULL;
        movement_count = 0;
    }
    delete movement;
    movement = NULL;
}

void FrameObject::advance_movement(int dir)
{
    set_movement(movement->index + dir);
}

void FrameObject::set_movement(int i)
{
    if (movement != NULL && (i < 0 || i >= movement_count))
        return;
    movement = movements[i];
    movement->init();
}

Movement * FrameObject::get_movement()
{
    if (movement == NULL) {
        movement = new StaticMovement(this);
        movement->index = 0;
    }
    return movement;
}

int FrameObject::get_action_x()
{
    return get_x();
}

int FrameObject::get_action_y()
{
    return get_y();
}

void FrameObject::shoot(FrameObject * other, int speed, int direction)
{
    if (direction == -1)
        direction = this->direction;
    other->set_global_position(get_action_x(), get_action_y());
    other->set_direction(direction);
    delete other->movement;
    other->movement = new ShootMovement(other);
    other->movement->set_max_speed(speed);
    other->movement->start();
}

float FrameObject::get_angle()
{
    return 0.0f;
}

void FrameObject::set_angle(float angle, int quality)
{
}

const std::string & FrameObject::get_name()
{
#ifdef NDEBUG
    static const std::string v("Unspecified");
    return v;
#else
    return name;
#endif
}

void FrameObject::look_at(int x, int y)
{
    set_direction(get_direction_int(this->x, this->y, x, y));
}

void FrameObject::wrap_pos()
{
    int * box = collision->aabb;
    int x1 = box[0] + layer->off_x;
    int y1 = box[1] + layer->off_y;
    int x2 = box[2] + layer->off_x;
    int y2 = box[3] + layer->off_y;
    if (x1 > frame->width)
        set_x(get_x() - frame->width);
    else if (x2 < 0)
        set_x(get_x() + frame->width);

    if (y1 > frame->height)
        set_x(get_y() - frame->height);
    else if (y2 < 0)
        set_x(get_y() + frame->height);
}

void FrameObject::rotate_toward(int dir)
{
    dir = dir % 32;
    int cc = dir - direction;
    if (cc < 0)
        cc += 32;
    int cl = direction - dir;
    if (cl < 0)
        cl += 32;
    int angle;
    if (cc < cl)
        angle = cc;
    else
        angle = cl;
    // angle to turn, default to 1
    if (angle > 1)
        angle = 1;
    if (cl < cc)
        angle = -angle;
    direction += angle;
    if (direction >= 32)
        direction -= 32;
    if (direction < 0)
        direction += 32;
    set_direction(direction);
}

bool FrameObject::test_direction(int value)
{
    return get_direction() == value;
}

bool FrameObject::test_directions(int value)
{
    int direction = get_direction();
    return ((value >> direction) & 1) != 0;
}

void FrameObject::update_flash(float interval, float & t)
{
    if (interval == 0.0f)
        return;
    t += manager.dt;
    if (t < interval)
        return;
    t = 0.0f;
    flags ^= VISIBLE;
}

void FrameObject::set_animation(int value)
{
}

void FrameObject::set_backdrop_offset(int dx, int dy)
{
}

void FrameObject::get_screen_aabb(int box[4])
{
    int off_x = layer->off_x - frame->off_x;
    int off_y = layer->off_y - frame->off_y;
    int * aabb = collision->aabb;
    box[0] = aabb[0] + off_x;
    box[1] = aabb[1] + off_y;
    box[2] = aabb[2] + off_x;
    box[3] = aabb[3] + off_y;
}

void FrameObject::update_inactive()
{
    int * aabb = collision->aabb;
    int * b = layer->inactive_box;

    if (aabb[0] > b[2] || aabb[1] > b[3] || aabb[2] < b[0] || aabb[3] < b[1])
        flags |= INACTIVE;
    else
        flags &= ~INACTIVE;
}

void FrameObject::update_kill()
{
    int * aabb = collision->aabb;
    int * b1 = layer->inactive_box;
    int * b2 = layer->kill_box;

    bool in = aabb[0] <= b1[2] && aabb[1] <= b1[3] &&
              aabb[2] >= b1[0] && aabb[3] >= b1[1];
    if (flags & INACTIVE) {
        if (in)
            flags &= ~INACTIVE;
        return;
    } else if (in) {
        return;
    }

    flags |= INACTIVE;
    if (aabb[0] <= b2[2] && aabb[1] <= b2[3] &&
        aabb[2] >= b2[0] && aabb[3] >= b2[1])
        return;
    destroy();
}

int SavedSelection::offset = 0;
FrameObject * SavedSelection::buffer[1024];

// FixedValue

FixedValue::FixedValue(FrameObject * object)
: object(object)
{

}

FixedValue::operator double() const
{
    uint64_t value = 0;
    memcpy(&value, &object, sizeof(FrameObject*));

#ifndef NDEBUG
    if (value & 3ULL) {
        std::cout << "Invalid alignment for fixed value: " << value
            << std::endl;
    }
#endif
    value |= (value & FIXED_FIRST) >> 62ULL;
    value &= ~FIXED_FIRST;
    value |= uint64_t((value & FIXED_EXPMASK) == 0) << 62ULL;
    double v2;
    memcpy(&v2, &value, sizeof(uint64_t));
    return v2;
}

FixedValue::operator std::string() const
{
#ifdef CHOWDREN_PERSISTENT_FIXED_STRING
    return number_to_string(object->x) + "&" + number_to_string(object->y);
#else
    intptr_t val = intptr_t(object);
    return number_to_string((long long)val);
#endif
}

FixedValue::operator FrameObject*() const
{
    return object;
}

unsigned int FixedValue::get_uint() const
{
    // return (object->id << 16) | (object->index & 0xFFFF);
    intptr_t val = intptr_t(object);
    return (unsigned int)val;
}

#ifdef CHOWDREN_USE_DYNAMIC_NUMBER
FixedValue::operator DynamicNumber() const
{
    double v = double(*this);
    return DynamicNumber(v);
}
#endif

// XXX move everything to 'objects' directory

// Text

FontList fonts;
static bool has_fonts = false;
static FTTextureFont * big_font = NULL;

bool init_font()
{
    static bool initialized = false;
    if (initialized)
        return has_fonts;

    // default font, could be set already
    has_fonts = load_fonts(fonts);

    FontList::const_iterator it;
    for (it = fonts.begin(); it != fonts.end(); ++it) {
        FTTextureFont * font = *it;
        if (big_font != NULL && big_font->size > font->size)
            continue;
        big_font = font;
    }

    initialized = true;
    return has_fonts;
}

FTTextureFont * get_font(int size, int flags)
{
    init_font();

    FTTextureFont * picked = NULL;
    int diff = 0;
    FontList::const_iterator it;

    for (it = fonts.begin(); it != fonts.end(); ++it) {
        FTTextureFont * font = *it;
        int new_diff = get_abs(font->size - size);
        if ((font->flags ^ flags) != 0)
            new_diff += 200;

        if (picked == NULL || new_diff < diff) {
            picked = font;
            diff = new_diff;
        }
    }

    return picked;
}

void draw_gradient(int x1, int y1, int x2, int y2, int gradient_type,
                   Color color, Color color2, int alpha)
{
    switch (gradient_type) {
        case NONE_GRADIENT:
            color.set_alpha(alpha);
            Render::draw_quad(x1, y1, x2, y2, color);
            break;
        case VERTICAL_GRADIENT:
            color.set_alpha(alpha);
            color2.set_alpha(alpha);
            Render::draw_vertical_gradient(x1, y1, x2, y2, color, color2);
            break;
        case HORIZONTAL_GRADIENT:
            color.set_alpha(alpha);
            color2.set_alpha(alpha);
            Render::draw_horizontal_gradient(x1, y1, x2, y2, color, color2);
            break;
    }
}

// File

const std::string & File::get_appdata_directory()
{
    return platform_get_appdata_dir();
}

#ifdef CHOWDREN_IS_DESKTOP

#ifdef _WIN32
#include <direct.h>
#define chdir _chdir
#else
#include <unistd.h>
#endif

#endif

void File::change_directory(const std::string & path)
{
// #ifdef CHOWDREN_IS_DESKTOP
//     chdir(convert_path(path).c_str());
// #endif
}

void File::create_directory(const std::string & path)
{
    platform_create_directories(path);
}

bool File::file_exists(const std::string & path)
{
    return platform_is_file(path);
}

bool File::file_readable(const std::string & path)
{
    FSFile fp(convert_path(path).c_str(), "r");
    return fp.is_open();
}

bool File::name_exists(const std::string & path)
{
    return platform_path_exists(path);
}

bool File::directory_exists(const std::string & path)
{
    return platform_is_directory(path);
}

void File::delete_file(const std::string & path)
{
    if (platform_remove_file(path))
        return;
}

void File::delete_folder(const std::string & path)
{
    std::cout << "Delete folder not implemented: " << path << std::endl;
}

bool File::copy_file(const std::string & src, const std::string & dst)
{
    std::string data;
    if (!read_file(src.c_str(), data))
        return false;
    FSFile fp(dst.c_str(), "w");
    if (!fp.is_open())
        return false;
    fp.write(&data[0], data.size());
    fp.close();

#ifdef CHOWDREN_CACHE_INI
    INI::reset_cache();
#endif
    return true;
}

int File::get_size(const std::string & path)
{
    return platform_get_file_size(path.c_str());
}

void File::rename_file(const std::string & src, const std::string & dst)
{
    copy_file(src, dst);
    delete_file(src);
}

void File::append_text(const std::string & text, const std::string & path)
{
    std::string data;
    if (!read_file(path.c_str(), data))
        return;
    data += text;
    FSFile fp(path.c_str(), "w");
    if (!fp.is_open())
        return;
    fp.write(&data[0], data.size());
    fp.close();
}

std::string File::get_ext(const std::string & path)
{
    std::string ext = get_path_ext(path);
    if (ext.empty())
        return ext;
    return "." + ext;
}

std::string File::get_title(const std::string & path)
{
    return get_path_basename(path);
}

// joystick

int remap_button(int n)
{
#if defined(CHOWDREN_SNES_CONTROLLER)
    switch (n) {
        case CHOWDREN_BUTTON_X:
            return CHOWDREN_BUTTON_A;
        case CHOWDREN_BUTTON_Y:
            return CHOWDREN_BUTTON_X;
        case CHOWDREN_BUTTON_GUIDE:
            return CHOWDREN_BUTTON_RIGHTSHOULDER;
        case CHOWDREN_BUTTON_BACK:
            return CHOWDREN_BUTTON_LEFTSHOULDER;
        case CHOWDREN_BUTTON_LEFTSHOULDER:
            return CHOWDREN_BUTTON_START;
        case CHOWDREN_BUTTON_B:
            return n;
    }
    return n;
#elif defined(CHOWDREN_JOYSTICK2_CONTROLLER)
    switch (n) {
        case 5:
            return CHOWDREN_BUTTON_LEFTSHOULDER; // 10
        case 6:
            return CHOWDREN_BUTTON_RIGHTSHOULDER; // 11
        case 7:
            return CHOWDREN_BUTTON_BACK; // 5
        case 8:
            return CHOWDREN_BUTTON_START; // 7
        case 9:
            return CHOWDREN_BUTTON_LEFTSTICK; // 8
        case 10:
            return CHOWDREN_BUTTON_RIGHTSTICK; // 9
        case 11:
            return CHOWDREN_BUTTON_GUIDE; // 6
        default:
            return n;
    }
#else
    return n;
#endif
}

int get_joystick_direction(int n)
{
    float x = get_joystick_axis(n, CHOWDREN_AXIS_LEFTX);
    float y = -get_joystick_axis(n, CHOWDREN_AXIS_LEFTY);
#ifdef CHOWDREN_IS_DESKTOP
    static const float threshold = 0.4f;
    int dir;
    // emulate Joystick 2 very closely
    if (get_abs(x) < threshold && get_abs(y) < threshold)
        dir = 8;
    else if (x > threshold) {
        if (y > threshold)
            dir = 1;
        else if (y < -threshold)
            dir = 7;
        else
            dir = 0;
    } else if (x < -threshold) {
        if (y > threshold)
            dir = 3;
        else if (y < -threshold)
            dir = 5;
        else
            dir = 4;
    } else {
        if (y > threshold)
            dir = 2;
        else
            dir = 6;
    }
    return dir;
#else
    static const float threshold = 0.35f;
    if (get_length(x, y) < threshold)
        return 8; // center
    else {
        return int_round(atan2_deg(y, x) / 45.0f) & 7;
    }
    return 8;
#endif
}

int get_joystick_direction_flags(int n)
{
    int dir = get_joystick_direction(n);
    switch (dir) {
        case 0:
            return 8; // 1000
        case 1:
            return 9; // 1001
        case 2:
            return 1; // 0001
        case 3:
            return 5; // 0101
        case 4:
            return 4; // 0100
        case 5:
            return 6; // 0110
        case 6:
            return 2; // 0010
        case 7:
            return 10; // 1010
        default:
            return 0;
    }
}

bool test_joystick_direction_flags(int n, int flags)
{
    int f = get_joystick_direction_flags(n);
    return (f & flags) == flags;
}

int get_joystick_dpad(int n)
{
    bool up = is_joystick_pressed(n, CHOWDREN_BUTTON_DPAD_UP);
    bool down = is_joystick_pressed(n, CHOWDREN_BUTTON_DPAD_DOWN);
    bool left = is_joystick_pressed(n, CHOWDREN_BUTTON_DPAD_LEFT);
    bool right = is_joystick_pressed(n, CHOWDREN_BUTTON_DPAD_RIGHT);
    int dir = get_movement_direction(up, down, left, right);
    if (dir == -1)
        dir = 8;
    else
        dir /= 4;
    return dir;
}

float get_joystick_dummy(int n)
{
    return 0.0f;
}

int get_joystick_dpad_degrees(int n)
{
    int dir = get_joystick_dpad(n);
    if (dir == 8)
        return -1;
    return dir * 45;
}

int get_joystick_degrees(int n)
{
    // XXX actually extract degrees
    int dir = get_joystick_direction(n);
    if (dir == 8)
        return -1;
    return dir * 45;
}

#define DEADZONE 0.15f
#define DEADZONE_MUL (1.0f / (1.0f - 0.15f))

float get_joystick_axis(int n, int axis)
{
    float v = get_joystick_axis_raw(n, axis);
    if (v > DEADZONE)
        return (v - DEADZONE) * DEADZONE_MUL;
    else if (v < -DEADZONE)
        return (v + DEADZONE) * DEADZONE_MUL;
    else
        return 0.0f;
}

int get_joystick_z(int n)
{
    return get_joystick_axis(n, CHOWDREN_AXIS_TRIGGERRIGHT) * -1000.0f;
}

int get_joystick_rt(int n)
{
    return get_joystick_axis(n, CHOWDREN_AXIS_TRIGGERRIGHT) * 100.0f;
}

int get_joystick_lt(int n)
{
    return get_joystick_axis(n, CHOWDREN_AXIS_TRIGGERLEFT) * 100.0f;
}

int get_joystick_x(int n)
{
    return get_joystick_axis(n, CHOWDREN_AXIS_LEFTX) * 1000.0f;
}

int get_joystick_y(int n)
{
    return get_joystick_axis(n, CHOWDREN_AXIS_LEFTY) * 1000.0f;
}

std::string get_joytokey_name(int id)
{
    std::ostringstream s;

    int directionToHat[4] = {1, 2, 4, 8};
    
    if (id >= UNIFIED_POV_0)
    {
        s << 'h';
        int localID = (id - UNIFIED_POV_0) / UNIFIED_POV_SIZE;
        int direction = (id - UNIFIED_AXIS_0) % UNIFIED_POV_SIZE;
        s << localID;
        s << '.';
        s << directionToHat[direction];
    }
    else if (id >= UNIFIED_AXIS_0)
    {
        s << 'a';
        int localID = (id - UNIFIED_AXIS_0) / UNIFIED_AXIS_SIZE;
        int direction = (id - UNIFIED_AXIS_0) % UNIFIED_AXIS_SIZE;
        s << localID;
        s << (char)(direction ? '-' : '+');
    }
    else
    {
        s << 'b';
        s << id;
    }

    return s.str();
}

struct RumbleEffect
{
    float delay, l, r;
    int duration;
};

static hash_map<std::string, RumbleEffect> rumble_effects;

void create_joystick_rumble(int n, float delay, float duration,
                            float l, float r, const std::string & name)
{
    RumbleEffect effect = {delay, l * 100.0f, r * 100.0f,
                           int(duration * 1000.0f)};
    rumble_effects[name] = effect;
}

void start_joystick_rumble(int n, const std::string & name, int times)
{
    RumbleEffect & effect = rumble_effects[name];
    joystick_vibrate(n, effect.l, effect.r, effect.duration);
}
