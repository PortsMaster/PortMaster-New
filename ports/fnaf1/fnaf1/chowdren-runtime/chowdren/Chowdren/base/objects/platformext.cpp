#include "objects/platformext.h"
#include "mathcommon.h"

// PlatformObject

// XXX hack
static PlatformObject * last_instance = NULL;

PlatformObject::PlatformObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), instance(NULL), paused(false),
  add_x_vel(0), add_y_vel(0), x_move_count(0), y_move_count(0), x_vel(0),
  y_vel(0), left(false), right(false), obstacle_collision(false),
  platform_collision(false), on_ground(false), through_collision_top(false),
  jump_through(false)
{
}

void PlatformObject::update()
{
    bool l = left;
    bool r = right;
    left = right = false;

    if (instance == NULL || paused || instance->flags & DESTROYING)
        return;

    if (r && !l)
        x_vel += x_accel;
    if (l && !r)
        x_vel -= x_accel;
    if (x_vel != 0 && ((!l && !r) || (l && r))) {
        x_vel -= (x_vel / get_abs(x_vel)) * x_decel;
        if (x_vel <= x_decel && x_vel >= 0 - x_decel)
            x_vel = 0;
    }

    x_vel = std::min(std::max(x_vel, -max_x_vel), max_x_vel);
    y_vel = std::min(std::max(y_vel + gravity, -max_y_vel), max_y_vel);

    int x_vel_2 = x_vel + add_x_vel;
    int y_vel_2 = y_vel + add_y_vel;
    int x_vel_sign = sign_int(x_vel_2);
    int y_vel_sign = sign_int(y_vel_2);
    x_move_count += get_abs(x_vel_2);
    y_move_count += get_abs(y_vel_2);

    bool overlaps;

    while (x_move_count > 100) {
        overlaps = overlaps_obstacle();
        if (!overlaps) {
            instance->set_x(instance->x + x_vel_sign);
            overlaps = overlaps_obstacle();
        }
        if (overlaps) {
            for (int i = 0; i < step_up; i++) {
                instance->set_y(instance->y - 1);
                overlaps = overlaps_obstacle();
                if (!overlaps)
                    break;
            }
            if (overlaps) {
                instance->set_position(
                    instance->x - x_vel_sign,
                    instance->y + step_up);
                x_vel = x_move_count = 0;
            }
        }
        x_move_count -= 100;
    }

    while (y_move_count > 100) {
        overlaps = overlaps_obstacle();
        if (!overlaps) {
            instance->set_y(instance->y + y_vel_sign);
            on_ground = false;
            overlaps = overlaps_obstacle();
        }
        if (overlaps) {
            instance->set_y(instance->y - y_vel_sign);
            if (y_vel_2 > 0)
                on_ground = true;
            y_vel = y_move_count = 0;
        }
        if (overlaps_platform() && y_vel_2 > 0) {
            if (through_collision_top) {
                instance->set_y(instance->y - 1);
                if (!overlaps_platform()) {
                    instance->set_y(instance->y - y_vel_sign);
                    y_vel = y_move_count = 0;
                    on_ground = true;
                }
                instance->set_y(instance->y + 1);
            } else {
                instance->set_y(instance->y - y_vel_sign);
                y_vel = y_move_count = 0;
                on_ground = true;
            }
        }
        y_move_count -= 100;
    }

    if (slope_correction > 0 && y_vel_2 >= 0) {
        bool tmp = false;
        for (int i = 0; i < slope_correction; i++) {
            instance->set_y(instance->y + 1);
            if (overlaps_obstacle()) {
                instance->set_y(instance->y - 1);
                on_ground = true;
                tmp = true;
                break;
            }
        }
        if (!tmp)
            instance->set_y(instance->y - slope_correction);
    }
}

bool PlatformObject::overlaps_obstacle()
{
    obstacle_collision = false;
    call_overlaps_obstacle();
    return obstacle_collision;
}

bool PlatformObject::overlaps_platform()
{
    platform_collision = false;
    call_overlaps_platform();
    return platform_collision;
}

void PlatformObject::set_object(FrameObject * instance)
{
    this->instance = instance;
}

bool PlatformObject::is_falling()
{
    return !on_ground && y_vel > 0;
}

bool PlatformObject::is_jumping()
{
    return !on_ground && y_vel <= 0;
}

bool PlatformObject::is_moving()
{
    return get_abs(x_vel) > 0;
}

void PlatformObject::jump_in_air()
{
    y_vel -= jump_hold_height;
}

void PlatformObject::jump()
{
    y_vel = 0 - jump_strength;
}

void PlatformObject::set_y_vel(int value)
{
    y_vel = value;
}

void PlatformObject::set_add_y_vel(int value)
{
    add_y_vel = value;
}

// void PlatformObject::set_max_x_vel(int value)
// {
//     // if (value != max_x_vel)
//     //     std::cout << "set max x vel: " << value << std::endl;
//     max_x_vel = value;
// }

// void PlatformObject::set_x_accel(int value)
// {
//     // if (value != x_accel && value != 50 && value != 1000) {
//     //     std::cout << "set x accel: " << value << std::endl;
//     // }
//     x_accel = value;
// }

void PlatformObject::call_overlaps_obstacle()
{
}

void PlatformObject::call_overlaps_platform()
{
}

class DefaultPlatform : public PlatformObject
{
public:
    DefaultPlatform()
    : PlatformObject(0, 0, 0)
    {
        create_alterables();
        setup_default_instance(this);
    }
};

static DefaultPlatform default_platform;
FrameObject * default_platform_instance = &default_platform;
