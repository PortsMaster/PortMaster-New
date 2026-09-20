#ifndef CHOWDREN_GRID_H
#define CHOWDREN_GRID_H

#include "../types.h"
#include <algorithm>

struct GridItem
{
    enum Flags
    {
        STATIC = 1 << 0
    };

    void * data;
    int unclamped[4];
    int box[4];
    int last_query_id;
    int flags;

    GridItem()
    {
    }
};

struct GridItemList
{
    int static_items;
    vector<int> items;

    GridItemList()
    : static_items(0)
    {
    }
};

#define GRID_INDEX(x, y) ((x) + (y) * width)
#define GRID_SIZE 256

class UniformGrid
{
public:
    int width, height;
    static vector<GridItem> store;
    static vector<int> free_list;
    GridItemList * grid;
    int query_id;

    UniformGrid();
    ~UniformGrid();
    void init();
    int add(void * data, int v[4]);
    int add_static(void * data, int v[4]);
    void move(int proxy, int v[4]);
    void remove(int proxy);
    void clear();

    template <typename T>
    bool query_static(int v[4], T & callback);

    template <typename T>
    bool query_static(int proxy, T & callback);

    template <typename T>
    bool query(int v[4], T & callback);

    template <typename T>
    bool remove_query(int v[4], T & callback);

    void get_pos(int in[4], int out[4]);
    void set_pos(int in[4], GridItem & item);
};

#undef max
#undef min

inline int clamp(int value, int min, int max)
{
    int x = value > max ? max : value;
    return x < min ? min : x;
}

inline void UniformGrid::get_pos(int in[4], int out[4])
{
    out[0] = clamp(in[0] / GRID_SIZE, 0, width-1);
    out[1] = clamp(in[1] / GRID_SIZE, 0, height-1);
    out[2] = clamp(in[2] / GRID_SIZE + 1, 1, width);
    out[3] = clamp(in[3] / GRID_SIZE + 1, 1, height);
}

inline void UniformGrid::set_pos(int in[4], GridItem & item)
{
    item.unclamped[0] = in[0] / GRID_SIZE;
    item.box[0] = clamp(item.unclamped[0], 0, width-1);
    item.unclamped[1] = in[1] / GRID_SIZE;
    item.box[1] = clamp(item.unclamped[1], 0, height-1);
    item.unclamped[2] = in[2] / GRID_SIZE;
    item.box[2] = clamp(item.unclamped[2] + 1, 1, width);
    item.unclamped[3] = in[3] / GRID_SIZE;
    item.box[3] = clamp(item.unclamped[3] + 1, 1, height);
}

template <typename T>
inline bool UniformGrid::query_static(int v[4], T & callback)
{
    int vv[4];
    get_pos(v, vv);
    query_id++;

    for (int y = vv[1]; y < vv[3]; y++)
    for (int x = vv[0]; x < vv[2]; x++) {
        GridItemList & list = grid[GRID_INDEX(x, y)];
        int count = list.static_items;

        for (int i = 0; i < count; ++i) {
            int index = list.items[i];
            GridItem & vv = store[index];
            if (vv.last_query_id == query_id)
                continue;
            vv.last_query_id = query_id;
            if (!callback.on_callback(vv.data))
                return false;
        }
    }
    return true;
}

template <typename T>
inline bool UniformGrid::query_static(int proxy, T & callback)
{
    GridItem & item = store[proxy];
    query_id++;

    for (int y = item.box[1]; y < item.box[3]; y++)
    for (int x = item.box[0]; x < item.box[2]; x++) {
        GridItemList & list = grid[GRID_INDEX(x, y)];
        int count = list.static_items;

        for (int i = 0; i < count; ++i) {
            int index = list.items[i];
            GridItem & vv = store[index];
            if (vv.last_query_id == query_id)
                continue;
            vv.last_query_id = query_id;
            if (!callback.on_callback(vv.data))
                return false;
        }
    }
    return true;
}

template <typename T>
inline bool UniformGrid::query(int v[4], T & callback)
{
    vector<int>::iterator it;
    int vv[4];
    get_pos(v, vv);

    query_id++;

    for (int y = vv[1]; y < vv[3]; y++)
    for (int x = vv[0]; x < vv[2]; x++) {
        GridItemList & list = grid[GRID_INDEX(x, y)];

        for (it = list.items.begin(); it != list.items.end(); ++it) {
            int index = *it;
            GridItem & vv = store[index];
            if (vv.last_query_id == query_id)
                continue;
            vv.last_query_id = query_id;
            if (!callback.on_callback(vv.data))
                return false;
        }
    }
    return true;
}

template <typename T>
inline bool UniformGrid::remove_query(int v[4], T & callback)
{
    vector<int>::iterator it;
    bool res = false;
    int vv[4];
    get_pos(v, vv);

    query_id++;

    for (int y = vv[1]; y < vv[3]; y++)
    for (int x = vv[0]; x < vv[2]; x++) {
        GridItemList & list = grid[GRID_INDEX(x, y)];

        it = list.items.begin();
        while (it != list.items.end()) {
            int index = *it;
            GridItem & vv = store[index];
            if (vv.last_query_id == query_id) {
                ++it;
                continue;
            }
            vv.last_query_id = query_id;
            if (callback.on_callback(vv.data)) {
                ++it;
                continue;
            }
            res = true;
            it = list.items.erase(it);
            remove(index);
        }
    }
    return res;
}

#endif // CHOWDREN_GRID_H
