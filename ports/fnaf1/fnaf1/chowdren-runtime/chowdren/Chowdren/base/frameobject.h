#ifndef CHOWDREN_FRAMEOBJECT_H
#define CHOWDREN_FRAMEOBJECT_H

#include "chowconfig.h"
#include "alterables.h"
#include "color.h"
#include <string>
#include <string.h>
#include "types.h"
#include <algorithm>
#include <stdarg.h>
#undef max
#include "broadphase.h"
#include <assert.h>
#include <boost/intrusive/list.hpp>
#include "pool.h"
#include "stringcommon.h"
#include "shaderparam.h"

class InstanceCollision;
class Shader;
class Frame;
class Image;
class FrameObject;
class Movement;
class Layer;

class FixedValue
{
public:
    FrameObject * object;

    FixedValue(FrameObject * object);
    operator double() const;
    operator std::string() const;
    operator FrameObject*() const;
    unsigned int get_uint() const;
#ifdef CHOWDREN_USE_DYNAMIC_NUMBER
    operator DynamicNumber() const;
#endif
};

inline bool operator==(FixedValue a, FixedValue b)
{
    return a.object == b.object;
}

inline bool operator!=(FixedValue a, FixedValue b)
{
    return !(a == b);
}

inline bool double_equals_exact(double a, double b)
{
    return memcmp(&a, &b, sizeof(double)) == 0;
}

#define FIXED_SIGN_BIT (1ULL << 63ULL)
#define FIXED_EXP1 (1ULL << 62ULL)
#define FIXED_EXPMASK (0x7FF0000000000000ULL)
#define FIXED_FIRST (FIXED_SIGN_BIT | FIXED_EXP1)

inline FrameObject * get_object_from_fixed(double fixed)
{
    // -1 as a double is
    // 00 00 00 00 00 00 F0 BF
    // which is quite unlikely to be a memory address
    if (double_equals_exact(fixed, 0.0) || double_equals_exact(fixed, -1.0))
        return NULL;
    uint64_t value;
    memcpy(&value, &fixed, sizeof(uint64_t));
    value &= ~FIXED_FIRST;
    value |= (value & 3ULL) << 62ULL;
    value &= ~(3ULL);
    FrameObject * p;
    memcpy(&p, &value, sizeof(FrameObject*));
    return p;
}

inline FrameObject * get_object_from_fixed(FixedValue fixed)
{
    return fixed.object;
}

inline bool operator==(double a, FixedValue b)
{
    return get_object_from_fixed(a) == b.object;
}

inline bool operator!=(double a, FixedValue b)
{
    return !(a == b);
}   

#define BACKGROUND_TYPE 1

enum ObjectFlags
{
    VISIBLE = (1 << 0),
    DESTROYING = (1 << 1),
    SCROLL = (1 << 2),
    FADEOUT = (1 << 3),
    BACKGROUND = (1 << 4),
    BACKGROUND_COL = (1 << 5),
    GLOBAL = (1 << 6),
    INACTIVE = (1 << 7),
    HAS_COLLISION_CACHE = (1 << 8),
    HAS_COLLISION = (1 << 9),
    DEFER_COLLISIONS = (1 << 10),
    REPEAT_BACK_COLLISION = (1 << 11)
};

enum AnimationIndex
{
    STOPPED = 0,
    WALKING = 1,
    RUNNING = 2,
    APPEARING = 3,
    DISAPPEARING = 4,
    BOUNCING = 5,
    SHOOTING = 6,
    JUMPING = 7,
    FALLING = 8,
    CLIMBING = 9,
    CROUCH = 10,
    STAND = 11,
    USER_DEFINED_1 = 12,
    USER_DEFINED_2 = 13,
    USER_DEFINED_3 = 14,
    USER_DEFINED_4 = 15
};

#ifdef CHOWDREN_USE_VALUEADD

int hash_extra_key(const std::string & value);

class ExtraAlterables
{
public:
    int & flags;
    vector<double> values;
    vector<std::string> strings;
    unsigned char value_offsets[CHOWDREN_VALUEADD_COUNT];
    unsigned char string_offsets[CHOWDREN_VALUEADD_COUNT];

    ExtraAlterables(int & flags)
    : flags(flags), value_offsets(), string_offsets()
    {
    }

    double get_value(int key)
    {
        int offset = value_offsets[key];
        if (offset == 0)
            return 0.0;
        return values[offset - 1];
    }

    const std::string & get_string(int key)
    {
        int offset = string_offsets[key];
        if (offset == 0)
            return empty_string;
        return strings[offset - 1];
    }

    void set_value(int key, double value)
    {
        if (flags & (DESTROYING | FADEOUT))
            return;
        int offset = value_offsets[key];
        if (offset != 0) {
            values[offset - 1] = value;
            return;
        }
        values.push_back(value);
        value_offsets[key] = values.size();
    }

    void set_string(int key, const std::string & value)
    {
        if (flags & (DESTROYING | FADEOUT))
            return;
        int offset = string_offsets[key];
        if (offset != 0) {
            strings[offset - 1] = value;
            return;
        }
        strings.push_back(value);
        string_offsets[key] = strings.size();
    }

    // slow paths
    double get_value(const std::string & key)
    {
        int hash = hash_extra_key(key);
        if (hash == -1) {
#ifndef NDEBUG
            std::cout << "Invalid value key: " << key << std::endl;
#endif
            return 0.0;
        }
        return get_value(hash);
    }

    const std::string & get_string(const std::string & key)
    {
        int hash = hash_extra_key(key);
        if (hash == -1) {
#ifndef NDEBUG
            std::cout << "Invalid value key: " << key << std::endl;
#endif
            return empty_string;
        }
        return get_string(hash);
    }

    void set_value(const std::string & key, double value)
    {
        int hash = hash_extra_key(key);
        if (hash == -1) {
#ifndef NDEBUG
            std::cout << "Invalid value key: " << key << std::endl;
#endif
            return;
        }
        set_value(hash, value);
    }

    void set_string(const std::string & key, const std::string & value)
    {
        int hash = hash_extra_key(key);
        if (hash == -1) {
#ifndef NDEBUG
            std::cout << "Invalid value key: " << key << std::endl;
#endif
            return;
        }
        set_string(hash, value);
    }
};

#endif

typedef boost::intrusive::link_mode<boost::intrusive::normal_link> LinkMode;
typedef boost::intrusive::list_member_hook<LinkMode> LayerPos;

#define FRAMEOBJECT_HEAD(X) static ObjectPool<X> pool; \
                            void dealloc() \
                            { \
                                this->X::~X(); \
                                pool.destroy(this); \
                            };

#define FRAMEOBJECT_IMPL(X) ObjectPool<X> X::pool;


struct ShaderParameter
{
    int hash;
    double value;
};

typedef vector<ShaderParameter> ShaderParameters;

class FrameObject
{
public:
#ifndef NDEBUG
    std::string name;
#endif
    int x, y;
    Layer * layer;
    int flags;
    Alterables * alterables;
    InstanceCollision * collision;
    unsigned int depth;
    LayerPos layer_pos;
    int index;
    int width, height;
    int direction;
    int id;
    Color blend_color;
	int effect;
    Frame * frame;
    ShaderParameters * shader_parameters;
    int movement_count;
    Movement ** movements;
    Movement * movement;
    int collision_flags;

#ifdef CHOWDREN_USE_BOX2D
    int body;
#endif

#ifdef CHOWDREN_USE_VALUEADD
    ExtraAlterables * extra_alterables;
#endif

#ifdef CHOWDREN_USE_PATHPLANNER
    struct PathNode
    {
        int x, y;
    };

    struct PathAgent
    {
        int x, y, dest_x, dest_y;
        vector<PathNode> nodes;
        FrameObject * planner;
        FrameObject * obj;

        PathAgent();
        ~PathAgent();
        bool at_destination();
        bool not_at_destination();
        bool is_stopping();
    };

    PathAgent * agent;
#endif

#ifdef CHOWDREN_USE_MOVEIT
    struct MoveData
    {
        int src_x, src_y;
        int dst_x, dst_y;
        int step;
        int cycles;

        MoveData(int src_x, int src_y, int dst_x, int dst_y, int cycles);
        ~MoveData();
    };

    MoveData * move_data;
#endif

    static ObjectPool<FrameObject> pool;
    virtual ~FrameObject();
    virtual void dealloc()
    {
        this->FrameObject::~FrameObject();
        pool.destroy(this);
    }

    FrameObject(int x, int y, int type_id);
    void set_position(int x, int y);
    void set_global_position(int x, int y);
    int get_x();
    int get_y();
    void set_x(int x);
    void set_y(int y);
    virtual int get_action_x();
    virtual int get_action_y();
    virtual float get_angle();
    virtual void set_angle(float angle, int quality = 0);
    void create_alterables();
    void set_visible(bool value);
    void set_blend_color(int color);
    virtual void draw();
    void draw_image(Image * img, int x, int y, Color c);
    void draw_image(Image * img, int x, int y, Color c, float angle,
                    float x_scale, float y_scale);
    void draw_image(Image * img, int x, int y, Color c, float angle,
                    float x_scale, float y_scale, bool flip_x);
    void begin_draw(int width, int height);
    void begin_draw();
    void end_draw();
    virtual void set_direction(int value, bool set_movement = true);
    virtual int get_direction();
    bool mouse_over();
    bool overlaps(FrameObject * other);
    void set_layer(int layer);
    void set_shader(int effect);
    void set_shader_parameter(const std::string & name, double value);
    void set_shader_parameter(const std::string & name, Image & image);
    void set_shader_parameter(const std::string & name, const Color & color);
    void set_shader_parameter(const std::string & name,
                              const std::string & path);
    int get_level();
    void set_level(int index);
    void move_relative(FrameObject * other, int disp);
    void move_back();
    void move_back(FrameObject * other);
    void move_front();
    void move_front(FrameObject * other);
    virtual void destroy();
    FixedValue get_fixed();
    bool outside_playfield();
    int get_box_index(int index);
    int get_generic_width();
    int get_generic_height();
    bool overlaps_background();
    bool overlaps_background_save();
    void clear_movements();
    void set_movement(int i);
    void advance_movement(int dir);
    Movement * get_movement();
    void shoot(FrameObject * other, int speed, int direction);
    const std::string & get_name();
    void look_at(int x, int y);
    void wrap_pos();
    void rotate_toward(int dir);
    void update_flash(float interval, float & time);
    bool test_direction(int value);
    bool test_directions(int value);
    virtual void flash(float value);
    virtual void set_animation(int value);
    virtual void set_backdrop_offset(int dx, int dy);
    void get_screen_aabb(int box[4]);
    void update_inactive();
    void update_kill();
    bool is_near_border(int border);

    ShaderParameter * find_shader_parameter(unsigned int hash)
    {
        ShaderParameters::const_iterator it;
        for (it = shader_parameters->begin(); it != shader_parameters->end();
             ++it)
        {
            if (it->hash != hash)
                continue;
            return &(*it);
        }
        return NULL;
    }

    double get_shader_parameter(unsigned int hash)
    {
        if (shader_parameters == NULL)
            return 0.0;
        ShaderParameter * param = find_shader_parameter(hash);
        if (param == NULL)
            return 0.0;
        return param->value;
    }

    double get_shader_parameter(const std::string & name)
    {
        if (shader_parameters == NULL)
            return 0.0;
        unsigned int hash = hash_shader_parameter(&name[0], name.size());
        ShaderParameter * param = find_shader_parameter(hash);
        if (param == NULL)
            return 0.0;
        return param->value;
    }

#ifdef CHOWDREN_USE_VALUEADD
    ExtraAlterables & get_extra_alterables()
    {
        if (extra_alterables == NULL)
            extra_alterables = new ExtraAlterables(flags);
        return *extra_alterables;
    }
#endif
};

typedef vector<FrameObject*> FlatObjectList;

#define LAST_SELECTED 0

struct ObjectListItem
{
    FrameObject * obj;
    unsigned int next;

    ObjectListItem()
    {
    }
};

typedef vector<ObjectListItem> ObjectListItems;

/*
Layout of ObjectList:

ObjectListItems is a list of currently living instances.
This array also includes information about the currently selected instances.

Its layout is as such:

* First item, {NULL, start_of_list}
* First living instance
* Second living instance
* etc.

When the current selection is cleared, the first item points to the end of
the array, so the most recently added instance is always iterated first.
The next instance will be set to current_index-1, etc., until the first item
is met. The first item is then always the last item pointed to by another item.
*/

class ObjectList
{
public:
    FrameObject * back_obj;
    ObjectListItems items;
    typedef ObjectListItems::iterator iterator;
    unsigned int saved_start;
    vector<int> saved_items;

    ObjectList()
    : back_obj(NULL)
    {
        items.resize(1);
        ObjectListItem & item = items[0];
        item.obj = NULL;
        item.next = LAST_SELECTED;
    }

    iterator begin()
    {
        iterator it = items.begin();
        ++it;
        return it;
    }

    iterator end()
    {
        return items.end();
    }

    void add(FrameObject * obj)
    {
        int i = items.size();
        items.resize(i+1);
        ObjectListItem & item = items[i];
        item.obj = obj;
        obj->index = i;
        back_obj = obj;
    }

    void add_back()
    {
        int i = items.size() - 1;
        ObjectListItem & item = items[i];
        item.next = items[0].next;
        items[0].next = i;
    }

    ObjectList & clear_selection()
    {
        int size = items.size();
        items[0].next = size-1;
        for (int i = 1; i < size; i++)
            items[i].next = i-1;
        return *this;
    }

    int get_selection_size();

    void empty_selection()
    {
        items[0].next = LAST_SELECTED;
    }

    bool has_selection() const
    {
        return items[0].next != LAST_SELECTED;
    }

    FrameObject * get_wrapped_selection(int index);

    FrameObject * back_selection() const
    {
        if (!has_selection())
            return back_obj;
        return items[items[0].next].obj;
    }

    FrameObject * back() const
    {
        return back_obj;
    }

    int size() const
    {
        return items.size()-1;
    }

    int total_size() const
    {
        return items.size();
    }

    bool empty() const
    {
        return items.size() == 1;
    }

    FrameObject* operator[](int index)
    {
        return items[index+1].obj;
    }

    void clear()
    {
        back_obj = NULL;
        items.resize(1);
        items[0].next = LAST_SELECTED;
    }

    void remove(FrameObject * obj)
    {
        for (int i = obj->index+1; i < int(items.size()); i++) {
            items[i-1].obj = items[i].obj;
            items[i].obj->index = i-1;
        }

        items.resize(items.size()-1);
        back_obj = items.back().obj;
    }

    void select_single(FrameObject * obj)
    {
        items[0].next = obj->index;
        items[obj->index].next = LAST_SELECTED;
    }

    void save_selection();
    void restore_selection();
    void clear_saved_selection();
    void copy(FlatObjectList & other);
};

class ObjectIterator
{
public:
    ObjectListItem * items;
    int index;
    int last;
    bool selected;

#ifdef CHOWDREN_ITER_INDEX
    int current_index;
#endif

    ObjectIterator(ObjectList & list)
    : items(&list.items[0]), index(list.items[0].next), last(0), selected(true)
    {
#ifdef CHOWDREN_ITER_INDEX
        current_index = 0;
#endif
    }

    FrameObject* operator*() const
    {
        return items[index].obj;
    }

    void operator++()
    {
#ifdef CHOWDREN_ITER_INDEX
        current_index++;
#endif

        last = selected ? index : last;
        index = items[index].next;
        selected = true;
    }

    void operator++(int)
    {
        ++*this;
    }

    void deselect()
    {
        selected = false;
        items[last].next = items[index].next;
    }

    bool end() const
    {
        return index == LAST_SELECTED;
    }

    void select_single()
    {
        items[0].next = index;
        items[index].next = LAST_SELECTED;
    }
};

inline FrameObject * ObjectList::get_wrapped_selection(int index)
{
    if (!has_selection()) {
        int size = items.size()-1;
        if (size == 0)
            return NULL;
        return items[(size - 1) - (index % size) + 1].obj;
    }
    while (true) {
        for (ObjectIterator it(*this); !it.end(); ++it) {
            if (index == 0)
                return *it;
            index--;
        }
    }
}

inline int ObjectList::get_selection_size()
{
    int size = 0;
    for (ObjectIterator it(*this); !it.end(); ++it)
        size++;
    return size;
}

class QualifierList
{
public:
    int count;
    ObjectList ** items;
    ObjectList * last;

    QualifierList()
    : count(0), items(NULL), last(NULL)
    {
        // for copies
    }

    void set(int count, ObjectList ** items)
    {
        this->items = items;
        this->count = count;
        last = items[count-1];
    }

    int size()
    {
        int size = 0;
        for (int i = 0; i < count; i++)
            size += items[i]->size();
        return size;
    }

    int get_selection_size()
    {
        int size = 0;
        for (int i = 0; i < count; i++)
            size += items[i]->get_selection_size();
        return size;
    }

    QualifierList & clear_selection()
    {
        for (int i = 0; i < count; i++) {
            items[i]->clear_selection();
        }
        return *this;
    }

    void empty_selection()
    {
        for (int i = 0; i < count; i++) {
            items[i]->empty_selection();
        }
    }

    bool has_selection()
    {
        for (int i = 0; i < count; i++) {
            if (items[i]->has_selection())
                return true;
        }
        return false;
    }

    bool empty()
    {
        for (int i = 0; i < count; i++) {
            if (!items[i]->empty())
                return false;
        }
        return true;
    }

    FrameObject * back()
    {
        for (int i = 0; i < count; i++) {
            FrameObject * back_obj = items[i]->back_obj;
            if (back_obj == NULL)
                continue;
            return back_obj;
        }
        return NULL;
    }

    FrameObject * back_selection() const
    {
        FrameObject * back_obj = NULL;
        for (int i = 0; i < count; i++) {
            ObjectList & list = *items[i];
            if (back_obj == NULL)
                back_obj = list.back_obj;
            if (!list.has_selection())
                continue;
            return list.items[list.items[0].next].obj;
        }
        return back_obj;
    }

    FrameObject * operator[](int index)
    {
        for (int i = 0; i < count; i++) {
            ObjectList & list = *items[i];
            int size = list.size();
            if (index < size)
                return list[index];
            index -= size;
        }
        return NULL;
    }

    void select_single(FrameObject * obj)
    {
        int i;
        for (i = 0; i < count; i++) {
            ObjectList & list = *items[i];
            if (list.empty()) {
                list.empty_selection();
                continue;
            }
            if (list[0]->id != obj->id) {
                list.empty_selection();
                continue;
            }
            list.select_single(obj);
            break;
        }

        while (i < count) {
            items[i]->empty_selection();
            i++;
        }
    }

    void clear_saved_selection()
    {
        for (int i = 0; i < count; i++) {
            items[i]->clear_saved_selection();
        }
    }

    void save_selection()
    {
        for (int i = 0; i < count; i++) {
            items[i]->save_selection();
        }
    }

    void restore_selection()
    {
        for (int i = 0; i < count; i++) {
            items[i]->restore_selection();
        }
    }

    FrameObject * get_wrapped_selection(int index);
    void copy(FlatObjectList & list);
};

class QualifierIterator
{
public:
    ObjectList ** lists;
    ObjectListItem * items;
    int list_index;
    int index;
    int last;
    bool selected;

#ifdef CHOWDREN_ITER_INDEX
    int current_index;
#endif

    QualifierIterator(QualifierList & in_list)
    : list_index(0), lists(in_list.items), last(0), selected(true)
    {
#ifdef CHOWDREN_ITER_INDEX
        current_index = 0;
#endif
        next_list();
    }

    FrameObject* operator*() const
    {
        return items[index].obj;
    }

    void next_list()
    {
        while (true) {
            ObjectList * list = lists[list_index];
            if (list == NULL) {
                items = NULL;
                break;
            }
            items = &list->items[0];
            index = items[0].next;
            if (index != LAST_SELECTED)
                break;
            list_index++;
        }
    }

    void operator++()
    {
#ifdef CHOWDREN_ITER_INDEX
        current_index++;
#endif
        last = selected ? index : last;
        index = items[index].next;
        selected = true;
        if (index != LAST_SELECTED)
            return;
        list_index++;
        last = 0;
        next_list();
    }

    void operator++(int)
    {
        ++*this;
    }

    void deselect()
    {
        selected = false;
        items[last].next = items[index].next;
    }

    bool end()
    {
        return items == NULL;
    }

    void select_single()
    {
        int n = 0;
        while (true) {
            ObjectList * iter = lists[n];
            if (iter == NULL)
                break;
            if (n != list_index)
                iter->empty_selection();
            n++;
        }
        items[0].next = index;
        items[index].next = LAST_SELECTED;
    }
};

inline FrameObject * QualifierList::get_wrapped_selection(int index)
{
    int size = 0;
    bool has_select = false;
    for (int i = 0; i < count; i++) {
        size += items[i]->size();
        if (!items[i]->has_selection())
            continue;
        has_select = true;
        break;
    }

    if (!has_select) {
        if (size == 0)
            return NULL;
        return (*this)[(size - 1) - (index % size)];
    }

    while (true) {
        for (QualifierIterator it(*this); !it.end(); ++it) {
            if (index == 0)
                return *it;
            index--;
        }
    }
}

inline void QualifierList::copy(FlatObjectList & list)
{
    list.resize(size());
    int index = 0;
    for (QualifierIterator it(*this); !it.end(); ++it) {
        list[index] = *it;
        index++;
    }
    list.resize(index);
}

// saving selection

inline void ObjectList::clear_saved_selection()
{
    saved_items.clear();
}

inline void ObjectList::save_selection()
{
    if (saved_items.size() == 0) {
        saved_items.resize(items.size(), 0);
        saved_start = items[0].next;
    } else
        saved_start = std::max(items[0].next, saved_start);
    for (ObjectIterator it(*this); !it.end(); ++it) {
        saved_items[it.index-1] = 1;
    }
}

inline void ObjectList::restore_selection()
{
    items[0].next = saved_start;
    int last = saved_start;
    for (int i = saved_start-1; i >= 1; i--) {
        if (!saved_items[i-1])
            continue;
        items[last].next = i;
        last = i;
    }
    items[last].next = LAST_SELECTED;
}

void setup_default_instance(FrameObject * obj);

#include "frame.h"

inline int FrameObject::get_x()
{
    return x + layer->off_x;
}

inline int FrameObject::get_y()
{
    return y + layer->off_y;
}

class SavedSelection
{
public:
    static int offset;
    static FrameObject * buffer[1024];

    int count;
    FrameObject ** items;

    SavedSelection(SavedSelection & list)
    : count(list.count), items(&buffer[offset])
    {
        for (int i = 0; i < count; ++i)
            items[i] = list.items[i];
        offset += count;
    }

    SavedSelection(ObjectList & list)
    : count(0), items(&buffer[offset])
    {
        for (ObjectIterator it(list); !it.end(); ++it) {
            items[count] = *it;
            count++;
        }
        offset += count;
        assert(offset <= 512);
    }

    SavedSelection(QualifierList & list)
    : count(0), items(&buffer[offset])
    {
        for (QualifierIterator it(list); !it.end(); ++it) {
            items[count] = *it;
            count++;
        }
        offset += count;
        assert(offset <= 512);
    }

    ~SavedSelection()
    {
        offset -= count;
        assert(offset >= 0);
    }
};

class SavedIterator
{
public:
    int current_index;
    SavedSelection & selection;

    SavedIterator(SavedSelection & selection)
    : selection(selection), current_index(0)
    {
    }

    bool end()
    {
        return current_index >= selection.count;
    }

    void operator++()
    {
        ++current_index;
    }

    void operator++(int)
    {
        ++*this;
    }

    FrameObject* operator*() const
    {
        return selection.items[current_index];
    }
};

#endif // CHOWDREN_FRAMEOBJECT_H
