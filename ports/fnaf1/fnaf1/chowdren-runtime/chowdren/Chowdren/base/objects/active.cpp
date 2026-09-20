#include "objects/active.h"
#include "manager.h"
#include "render.h"

// Active

Active::Active(int x, int y, int type_id)
: FrameObject(x, y, type_id), forced_animation(-1),
  animation_frame(0), counter(0), angle(0.0f), forced_frame(-1),
  forced_speed(-1), forced_direction(-1), x_scale(1.0f), y_scale(1.0f),
  animation_direction(0), flash_interval(0.0f), animation_finished(-1),
  image(NULL), active_flags(0), direction_data(NULL), last_dir(-1),
  fade_time(0.0f), fade_duration(0.0f)
{
    sprite_col.instance = this;
    collision = &sprite_col;
}

void Active::initialize_active(bool collision_box)
{
    if (collision_box) {
        sprite_col.flags |= BOX_COLLISION;
        sprite_col.type = SPRITE_BOX;
    }
    update_direction();

    int n = 1;
    if (current_animation == APPEARING || current_animation == DISAPPEARING) {
        // XXX figure out why this is needed
#ifdef CHOWDREN_ACTIVE_LOOPING_APPEARING
        if (loop_count == -1 && current_animation == DISAPPEARING)
            loop_count = 1;
#else
        if (loop_count == -1)
            loop_count = 1;
#endif
        n++;
    }
    counter += int(direction_data->max_speed * manager.frame->timer_mul) * n;
}

Active::~Active()
{
}

void Active::set_animation(int value)
{
    if (value == animation)
        return;
    value = get_animation(value);
    if (value == animation)
        return;
    animation = value;
    if (forced_animation >= 0)
        return;
    animation_frame = 0;
    current_animation = animation;
    update_direction();
}

void Active::force_animation(int value)
{
    if (value == forced_animation)
        return;
    value = get_animation(value);
    if (value == forced_animation)
        return;
    if (flags & FADEOUT) {
        FrameObject::destroy();
        return;
    }
    forced_animation = value;
    if (value == current_animation)
        return;
    animation_frame = 0;
    current_animation = value;
    update_direction();
}

void Active::force_frame(int value)
{
    if (loop_count == 0)
        return;
    int frame_count = direction_data->frame_count;
    forced_frame = int_max(0, int_min(value, frame_count - 1));
    update_frame();
}

void Active::force_speed(int value)
{
    value = std::max(0, std::min(100, value));
    int delta = direction_data->max_speed - direction_data->min_speed;
    if (delta != 0) {
        value = (value * delta) / 100 + direction_data->min_speed;
        value = std::min(direction_data->max_speed, value);
    }
    forced_speed = value;

    // XXX taken from Active::update, generalize maybe?
    if (forced_animation == -1 && animation != current_animation) {
        current_animation = animation;
        animation_frame = 0;
        update_direction();
    }
}

void Active::force_direction(int value)
{
    value &= 31;
    if (forced_direction == value)
        return;
    forced_direction = value;
    update_direction();
}

void Active::restore_direction()
{
    forced_direction = -1;
    update_direction();
}

void Active::restore_animation()
{
    if (forced_animation == -1)
        return;
    forced_animation = -1;
    if (current_animation == animation)
        return;
    current_animation = animation;
    animation_frame = 0;
    update_direction();
}

void Active::restore_frame()
{
    if (forced_frame == -1)
        return;
    animation_frame = forced_frame;
    forced_frame = -1;
    update_frame();
}

void Active::restore_speed()
{
    forced_speed = -1;
}

void Active::update_frame()
{
    Image * new_image = direction_data->frames[get_frame()];
    if (new_image == image)
        return;
    image = new_image;
    image->load();

#ifdef CHOWDREN_ACTIVE_REPLACE_COLOR
    if (!replacer.empty())
        image = replacer.apply_direct(image, image);
#endif

    sprite_col.set_image(image, image->hotspot_x, image->hotspot_y);
    update_action_point();

#ifdef CHOWDREN_DEFER_COLLISIONS
    // make sure the old AABB is not out of bounds
    if (sprite_col.type == SPRITE_COLLISION) {
        old_aabb[2] = old_aabb[0] + image->width;
        old_aabb[3] = old_aabb[1] + image->height;
    }
#endif
}

void Active::update_direction(Direction * dir)
{
    if (dir == NULL)
        dir = get_direction_data();

    direction_data = dir;
    loop_count = direction_data->loop_count;

    // make sure frame is still in range
    int frame_count = direction_data->frame_count;
    if (forced_frame != -1 && forced_frame >= frame_count)
        forced_frame = -1;
    if (animation_frame >= frame_count)
        animation_frame = 0;

    if (active_flags & ANIMATION_STOPPED)
        return;
    update_frame();
}

void Active::update_action_point()
{
    sprite_col.get_transform(image->action_x, image->action_y,
                             action_x, action_y);
    action_x -= sprite_col.new_hotspot_x;
    action_y -= sprite_col.new_hotspot_y;
}

void Active::update()
{
#ifdef CHOWDREN_DEFER_COLLISIONS
    flags |= DEFER_COLLISIONS;
    memcpy(old_aabb, sprite_col.aabb, sizeof(old_aabb));
#endif
    if (flags & FADEOUT) {
        if (fade_time > 0.0f) {
            fade_time -= manager.dt;
            if (fade_time <= 0.0f) {
                FrameObject::destroy();
            }
            float p = fade_time / fade_duration;
            blend_color.set_alpha(p * 255.0f);
            return;
        }
        if (animation_finished == DISAPPEARING) {
            FrameObject::destroy();
            return;
        }
    }

    update_flash(flash_interval, flash_time);

    animation_finished = -1;

    if (forced_animation == -1 && animation != current_animation) {
        current_animation = animation;
        animation_frame = 0;
        update_direction();
    }

    if (forced_frame != -1 || (active_flags & ANIMATION_STOPPED) ||
        loop_count == 0)
    {
        return;
    }

    int anim_speed;
    if (forced_speed != -1)
        anim_speed = forced_speed;
    else
        anim_speed = direction_data->max_speed;

    int counter = this->counter + int(anim_speed * frame->timer_mul);
    int old_frame = animation_frame;

    while (counter > 100) {
        counter -= 100;
        animation_frame++;
        if (animation_frame < direction_data->frame_count)
            continue;
        if (loop_count > 0)
            loop_count--;
        if (loop_count != 0) {
            animation_frame = direction_data->back_to;
            continue;
        }

        animation_finished = current_animation;
        animation_frame--;

        if (forced_animation != -1) {
            forced_animation = -1;
            forced_speed = -1;
            forced_direction = -1;
        }
        return;
    }
    this->counter = counter;

    if (animation_frame != old_frame)
        update_frame();
}

inline int get_active_load_point(int value, int max)
{
    if (value == 100000) {
        return max / 2;
    } else if (value == 110000) {
        return max;
    }
    return value;
}

void Active::load(const std::string & filename, int anim, int dir, int frame,
                  int hot_x, int hot_y, int action_x, int action_y,
                  TransparentColor transparent_color)
{
    if (anim >= animations->count)
        return;
    if (dir < 0 || dir >= 32)
        return;
    Animation * animation = animations->items[anim];
    Direction * direction = animation->dirs[dir];
    if (frame >= direction->frame_count)
        return;

    Image * new_image = get_image_cache(convert_path(filename), 0, 0, 0, 0,
                                        transparent_color);

    if (new_image == NULL) {
        std::cout << "Could not load image " << filename << std::endl;
        return;
    }

    new_image->hotspot_x = get_active_load_point(hot_x, new_image->width);
    new_image->hotspot_y = get_active_load_point(hot_y, new_image->height);
    new_image->action_x = get_active_load_point(action_x, new_image->width);
    new_image->action_y = get_active_load_point(action_y, new_image->height);

#ifdef CHOWDREN_ACTIVE_LOAD_SINGLE
    image = new_image;
    direction_data = direction;
    current_animation = forced_animation = anim;
    forced_frame = frame;
#else
    Image * old_image = direction->frames[frame];
    if (old_image == new_image)
        return;
    old_image->destroy();
    new_image->upload_texture();
    direction->frames[frame] = new_image;

    // update the frame for all actives of this type
    // this may break in the future, maybe
    ObjectList::iterator it;
    ObjectList & list = this->frame->instances.items[id];
    for (it = list.begin(); it != list.end(); ++it) {
        Active * obj = (Active*)it->obj;
        obj->image = NULL;
        obj->update_frame();
    }
#endif
}

void Active::draw()
{
    bool blend = (active_flags & TRANSPARENT) || blend_color.a < 255 ||
                 effect != Render::NONE;
    if (blend) {
        draw_image(image, x, y, blend_color, angle, x_scale, y_scale);
        return;
    }
    Render::disable_blend();
    draw_image(image, x, y, blend_color, angle, x_scale, y_scale);
    Render::enable_blend();
}

int Active::get_action_x()
{
    return get_x() + action_x;
}

int Active::get_action_y()
{
    return get_y() + action_y;
}

void Active::set_angle(float angle, int quality)
{
    angle = mod(angle, 360.0f);
    this->angle = angle;
    sprite_col.set_angle(angle);
    update_action_point();
}

int Active::get_frame()
{
    if (forced_frame != -1)
        return forced_frame;
    return animation_frame;
}

Direction * Active::get_direction_data()
{
    Animation * anim = animations->items[current_animation];

    if (anim == NULL) {
        std::cout << "Invalid animation: " << current_animation << std::endl;
        return NULL;
    }

    int dir = get_animation_direction();
    Direction * data = anim->dirs[dir];
    if (data != NULL) {
        if (data->index == dir)
            last_dir = dir;
        return data;
    }

    int search_dir = 1;
    if (last_dir != -1 && ((dir - last_dir) & 31) <= 15)
        search_dir = -1;

    while (true) {
        dir = (dir + search_dir) & 31;
        Direction * new_data = anim->dirs[dir];
        if (new_data)
            return new_data;
    }
    return NULL;
}

static int animation_alias[] = {
    APPEARING, WALKING, RUNNING,
    RUNNING, STOPPED, -1,
    WALKING, STOPPED, -1,
    STOPPED, WALKING, RUNNING,
    STOPPED, -1, -1,
    STOPPED, WALKING, RUNNING,
    STOPPED, WALKING, RUNNING,
    WALKING, RUNNING, STOPPED,
    STOPPED, WALKING, RUNNING,
    WALKING, RUNNING, STOPPED,
    STOPPED, WALKING, RUNNING,
    STOPPED, WALKING, RUNNING,
    -1, -1, -1,
    -1, -1, -1,
    -1, -1, -1,
    -1, -1, -1,
};

int Active::get_animation(int value)
{
    value = std::min(value, animations->count - 1);
    if (has_animation(value))
        return value;
    value = std::max(0, value);
    for (int i = 0; i < 3; i++) {
        int alias = animation_alias[i + value * 3];
        if (alias == -1 || !has_animation(alias))
            break;
        return alias;
    }
    for (value = 0; value < animations->count; value++) {
        if (has_animation(value))
            break;
    }
    return value;
}

void Active::set_direction(int value, bool set_movement)
{
    value &= 31;
    FrameObject::set_direction(value, set_movement);
    if (active_flags & AUTO_ROTATE) {
        set_angle((value * 360) / 32);
        value = 0;
    }
    if (value == animation_direction)
        return;
    animation_direction = value;
    Direction * old_dir = direction_data;
    Direction * new_dir = get_direction_data();
    if (old_dir == new_dir)
        return;
    update_direction(new_dir);
}

int Active::get_animation_direction()
{
    if (forced_direction != -1)
        return forced_direction;
    return animation_direction;
}

void Active::set_scale(float value)
{
    value = std::max(0.0f, value);
    x_scale = y_scale = value;
    sprite_col.set_scale(value);
    update_action_point();
}

void Active::set_x_scale(float value)
{
    x_scale = std::max(0.0f, value);
    sprite_col.set_x_scale(x_scale);
    update_action_point();
}

void Active::set_y_scale(float value)
{
    y_scale = std::max(0.0f, value);
    sprite_col.set_y_scale(y_scale);
    update_action_point();
}

void Active::paste(int collision_type)
{
#ifdef CHOWDREN_IS_TE
    // XXX hack, actually fix negated overlap check
    if (flags & DESTROYING)
        return;
#endif
    layer->paste(image, x-image->hotspot_x, y-image->hotspot_y, 0, 0,
                 image->width, image->height, collision_type, effect,
                 blend_color);
}

bool Active::test_animation(int value)
{
    value = std::min(value, animations->count - 1);
    if (value != current_animation)
        return false;
    if (loop_count == 0)
        return false;
    return true;
}

void Active::stop_animation()
{
    active_flags |= ANIMATION_STOPPED;
}

void Active::start_animation()
{
    active_flags &= ~ANIMATION_STOPPED;
}

void Active::flash(float value)
{
    flash_interval = value;
    flash_time = 0.0f;
}

bool Active::is_animation_finished(int anim)
{
    anim = std::min(anim, animations->count - 1);
    return current_animation == anim && loop_count == 0;
}

void Active::destroy()
{
    if (flags & FADEOUT)
        return;
    bool has_anim = has_animation(DISAPPEARING);
    if (!has_anim && fade_duration == 0.0f) {
        FrameObject::destroy();
        return;
    }
    clear_movements();

    if (has_anim) {    
        if (forced_animation != DISAPPEARING) {
            restore_animation();
            force_animation(DISAPPEARING);
        }
        if (loop_count == -1)
            loop_count = 1;
    } else {
        fade_time = fade_duration;
    }

    flags |= FADEOUT;
    collision->type = NONE_COLLISION;
}

bool Active::has_animation(int anim)
{
    if (anim >= animations->count || anim < 0)
        return false;
    if (animations->items[anim] == NULL)
        return false;
    return true;
}

void Active::replace_color(const Color & from, const Color & to)
{
#ifdef CHOWDREN_ACTIVE_REPLACE_COLOR
    // this is divergent from the normal behaviour, but is necessary for NaH
    // to prevent replace overflow
    for (int i = 0; i < replacer.index; ++i) {
        const Color & first = replacer.colors[i].first;
        if (first.r != from.r || first.g != from.g || first.b != from.b)
            continue;
        const Color & second = replacer.colors[i].second;
        if (second.r != to.r || second.g != to.g || second.b != to.b)
            continue;
        return;
    }
    replacer.replace(from, to);
    image = replacer.apply_direct(image, image);
#endif
}

class DefaultActive : public Active
{
public:
    DefaultActive()
    : Active(0, 0, 0)
    {
        collision = new InstanceBox(this);
        create_alterables();
        setup_default_instance(this);
    }
};

static DefaultActive default_active;
FrameObject * default_active_instance = &default_active;
