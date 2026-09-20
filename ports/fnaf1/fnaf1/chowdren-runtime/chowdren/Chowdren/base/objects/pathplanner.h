#ifndef CHOWDREN_PATHPLANNER_H
#define CHOWDREN_PATHPLANNER_H

#include "frameobject.h"
#include "bitarray.h"

class PathPlanner : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(PathPlanner)

    int tile_size;
    int map_width, map_height;
    BitArray map;
    FlatObjectList agents;

    enum {
        GRID_UPSCALE = 3
    };

    PathPlanner(int x, int y, int type_id);
    ~PathPlanner();
    void create_map();
    void update();
    void add_agent(FrameObject * obj);
    void add_obstacle(FrameObject * obj);

    inline int to_grid(int v)
    {
        return (v * GRID_UPSCALE) / tile_size;
    }

    inline int to_pixels(int v)
    {
        return (v * tile_size) / GRID_UPSCALE;
    }

    inline int to_index(int x, int y)
    {
        return x + y * map_width;
    }

    static void set_destination(FrameObject * obj, int x, int y);
    static void orient(FrameObject * obj);
    static void plan_path(FrameObject * obj);
};

#endif // CHOWDREN_PATHPLANNER_H
