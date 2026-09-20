#include "broadphase/grid.h"
#include "manager.h"
#include "frame.h"

inline int div_ceil(int x, int y)
{
    return (x + y - 1) / y;
}

UniformGrid::UniformGrid()
: query_id(0), grid(NULL), width(0), height(0)
{
}

void UniformGrid::init()
{
    width = div_ceil(manager.frame->width, GRID_SIZE);
    height = div_ceil(manager.frame->height, GRID_SIZE);
    grid = new GridItemList[width*height];
}

UniformGrid::~UniformGrid()
{
    vector<int>::iterator it;
    for (int i = 0; i < width*height; i++) {
        GridItemList & list = grid[i];
        for (it = list.items.begin(); it != list.items.end(); ++it) {
            GridItem & item = store[*it];
            if (item.data == NULL)
                continue;
            item.data = NULL;
            free_list.push_back(*it);
        }
    }
    delete[] grid;
}

void UniformGrid::clear()
{
    vector<int>::iterator it;
    for (int i = 0; i < width*height; i++) {
        GridItemList & list = grid[i];
        for (it = list.items.begin(); it != list.items.end(); ++it) {
            GridItem & item = store[*it];
            if (item.data == NULL)
                continue;
            item.data = NULL;
            free_list.push_back(*it);
        }
        list.items.clear();
    }
}

inline void remove_proxy(GridItemList & list, int proxy)
{
    vector<int>::iterator it;
    for (it = list.items.begin() + list.static_items; it != list.items.end();
         ++it) {
        if (*it != proxy)
            continue;
        *it = list.items.back();
        list.items.pop_back();
        break;
    }
}

inline void remove_static_proxy(GridItemList & list, int proxy)
{
    list.static_items--;
    vector<int>::iterator it;
    for (it = list.items.begin(); it != list.items.end(); ++it) {
        if (*it != proxy)
            continue;
        list.items.erase(it);
        break;
    }
}

inline void add_proxy(GridItemList & list, int proxy)
{
    list.items.push_back(proxy);
}

inline void add_static_proxy(GridItemList & list, int proxy)
{
    list.items.insert(list.items.begin() + list.static_items, proxy);
    list.static_items++;
}

int UniformGrid::add(void * data, int v[4])
{
    int index;
    if (free_list.empty()) {
        index = store.size();
        store.emplace_back();
    } else {
        index = free_list.back();
        free_list.pop_back();
    }

    GridItem & item = store[index];
    item.last_query_id = query_id;
    item.data = data;
    set_pos(v, item);
    item.flags = 0;

    for (int y = item.box[1]; y < item.box[3]; y++)
    for (int x = item.box[0]; x < item.box[2]; x++) {
        add_proxy(grid[GRID_INDEX(x, y)], index);
    }

    return index;
}

int UniformGrid::add_static(void * data, int v[4])
{
    int index;
    if (free_list.empty()) {
        index = store.size();
        store.emplace_back();
    } else {
        index = free_list.back();
        free_list.pop_back();
    }

    GridItem & item = store[index];
    item.last_query_id = query_id;
    item.data = data;
    set_pos(v, item);
    item.flags = GridItem::STATIC;

    for (int y = item.box[1]; y < item.box[3]; y++)
    for (int x = item.box[0]; x < item.box[2]; x++) {
        add_static_proxy(grid[GRID_INDEX(x, y)], index);
    }

    return index;
}

void UniformGrid::remove(int proxy)
{
    GridItem & item = store[proxy];

    if (item.flags & GridItem::STATIC) {
        for (int y = item.box[1]; y < item.box[3]; y++)
        for (int x = item.box[0]; x < item.box[2]; x++) {
            remove_static_proxy(grid[GRID_INDEX(x, y)], proxy);
        }
    } else {
        for (int y = item.box[1]; y < item.box[3]; y++)
        for (int x = item.box[0]; x < item.box[2]; x++) {
            remove_proxy(grid[GRID_INDEX(x, y)], proxy);
        }
    }

    item.data = NULL;
    free_list.push_back(proxy);
}

inline bool overlaps(int x, int y, int box[4])
{
    return x >= box[0] && x < box[2] && y >= box[1] && y < box[3];
}

void UniformGrid::move(int proxy, int v[4])
{
    GridItem & item = store[proxy];

    int box1[4] = {v[0] / GRID_SIZE, v[1] / GRID_SIZE,
                   v[2] / GRID_SIZE, v[3] / GRID_SIZE};

    if (box1[0] == item.unclamped[0] && box1[1] == item.unclamped[1] &&
        box1[2] == item.unclamped[2] && box1[3] == item.unclamped[3])
        return;

    item.unclamped[0] = box1[0];
    item.unclamped[1] = box1[1];
    item.unclamped[2] = box1[2];
    item.unclamped[3] = box1[3];

    int box[4] = {clamp(box1[0], 0, width-1),
                  clamp(box1[1], 0, height-1),
                  clamp(box1[2] + 1, 1, width),
                  clamp(box1[3] + 1, 1, height)};

    // remove this branch in the future?
    if (box[0] == item.box[0] && box[1] == item.box[1] &&
        box[2] == item.box[2] && box[3] == item.box[3])
        return;

    if (item.flags & GridItem::STATIC) {
        // remove from lists the proxy is leaving
        for (int y = item.box[1]; y < item.box[3]; y++)
        for (int x = item.box[0]; x < item.box[2]; x++) {
            if (overlaps(x, y, box))
                continue;
            remove_static_proxy(grid[GRID_INDEX(x, y)], proxy);
        }

        // add to lists the proxy is entering
        for (int y = box[1]; y < box[3]; y++)
        for (int x = box[0]; x < box[2]; x++) {
            if (overlaps(x, y, item.box))
                continue;
            add_static_proxy(grid[GRID_INDEX(x, y)], proxy);
        }
    } else {
        // remove from lists the proxy is leaving
        for (int y = item.box[1]; y < item.box[3]; y++)
        for (int x = item.box[0]; x < item.box[2]; x++) {
            if (overlaps(x, y, box))
                continue;
            remove_proxy(grid[GRID_INDEX(x, y)], proxy);
        }

        // add to lists the proxy is entering
        for (int y = box[1]; y < box[3]; y++)
        for (int x = box[0]; x < box[2]; x++) {
            if (overlaps(x, y, item.box))
                continue;
            add_proxy(grid[GRID_INDEX(x, y)], proxy);
        }
    }

    item.box[0] = box[0];
    item.box[1] = box[1];
    item.box[2] = box[2];
    item.box[3] = box[3];
}

vector<GridItem> UniformGrid::store;
vector<int> UniformGrid::free_list;
