#ifndef CHOWDREN_MOVEMENT_H
#define CHOWDREN_MOVEMENT_H

#include <string>
#include "types.h"
#include "frameobject.h"

int get_movement_direction(int v);
int get_movement_direction(bool up, bool down, bool left, bool right);

class Movement
{
public:
    int index;
    int speed, max_speed;
    int old_x, old_y;
    double add_x, add_y;
    FrameObject * instance;
    FlatObjectList collisions;
    bool back_col;
    unsigned int directions;
    int flags;

    enum MovementFlags
    {
        MOVE_AT_START = 1 << 0,
        MOVE_STOPPED = 1 << 1,
        IS_MOVE_IT = 1 << 2
    };

    Movement(FrameObject * instance);
    virtual ~Movement();
    virtual void init();
    virtual void update();
    virtual void set_max_speed(int speed);
    virtual void set_speed(int speed);
    virtual void set_acceleration(int value);
    virtual void set_deceleration(int value);
    virtual void set_gravity(int value);
    virtual void start();
    virtual void stop(bool collision);
    virtual void bounce(bool collision);
    virtual bool is_stopped();
    virtual void reverse();
    virtual int get_speed();
    virtual void set_node(const std::string & node);
    virtual bool is_path_finished();
    virtual bool is_node_reached();
    virtual void set_direction(int value);
    virtual void look_at(int x, int y);
    void set_directions(unsigned int directions);
    void move(double add_x, double add_y);
    bool test_direction(int dir, int displacement);
    bool test_offset(float x, float y);
    bool test_position(int x, int y);
    bool push_out();
    bool fix_position();
    void add_collision(FrameObject * obj);
    void set_background_collision();
    void clear_collisions();
};

class StaticMovement : public Movement
{
public:
    StaticMovement(FrameObject * instance);
};

class PathNode
{
public:
    int speed;
    int x, y;
    float dir_x, dir_y;
    int length;
    int direction;
    float pause;
};

class NamedNode
{
public:
    int index;
    std::string name;
};

typedef vector<PathNode> PathNodes;
typedef vector<NamedNode> NamedNodes;

class PathMovement : public Movement
{
public:
    bool loop, has_reverse;
    PathNodes nodes;
    NamedNodes named_nodes;
    int current_node;
    float distance_left;
    int dir;
    bool node_changed;
    int end_x, end_y;
    int start_x, start_y;

    PathMovement(FrameObject * instance);
    void set_path(bool loop, bool reverse, int end_x, int end_y);
    void add_node(int speed, int x, int y, float dir_x, float dir_y,
                  int length, int dir, float pause);
    void add_named_node(int i, const std::string & name);
    void set_current_node(int i);
    void set_node(const std::string & node);
    void update();
    void start();
    void stop(bool collision);
    bool is_path_finished();
    bool is_node_reached();
    void reverse();
};

class PinballMovement : public Movement
{
public:
    int deceleration;
    int gravity;
    float x_speed, y_speed;

    PinballMovement(FrameObject * instance);
    void start();
    void stop(bool collision);
    void update();
    void bounce(bool collision);
    void set_deceleration(int value);
    void set_gravity(int value);
    void set_speed(int value);
    void set_direction(int value);
};

class BallMovement : public Movement
{
public:
    int deceleration;
    double speed_change;
    int randomizer;
    bool has_back_col; // XXX hack
    int stop_speed;

    BallMovement(FrameObject * instance);
    void init();
    void update();
    void bounce(bool collision);
    void stop(bool collision);
    void start();
    void set_deceleration(int value);
    void set_speed(int speed);
};

class VectorMovement : public Movement
{
public:
    float angle;

    VectorMovement(FrameObject * instance);
    void update();
    void look_at(int x, int y);
};

class ShootMovement : public Movement
{
public:
    ShootMovement(FrameObject * instance);
    void update();
};

class EightDirections : public Movement
{
public:
    int last_move;
    int acceleration, deceleration;

    EightDirections(FrameObject * instance);
    void update();
    void set_deceleration(int value);
    void set_acceleration(int value);
    void start();
    void stop(bool collision);
};

class MoveItMovement : public Movement
{
public:
    int src_x, src_y;
    int dst_x, dst_y;
    int step;
    int cycles;
    Movement * old_movement;

    MoveItMovement(FrameObject * instance, int x, int y, int cycles,
                   Movement * old_movement);
    void update();
};

#endif // CHOWDREN_MOVEMENT_H
