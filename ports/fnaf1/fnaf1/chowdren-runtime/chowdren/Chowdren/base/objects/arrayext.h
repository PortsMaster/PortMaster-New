#ifndef CHOWDREN_ARRAYEXT_H
#define CHOWDREN_ARRAYEXT_H

#include "frameobject.h"
#include <string>
#include "datastream.h"
#include "types.h"

#ifdef CHOWDREN_ARRAYEXT_DOUBLES
typedef double ArrayNumber;
#else
typedef int ArrayNumber;
#endif

class ArrayObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(ArrayObject)

    struct ArrayData
    {
        ArrayData()
        : offset(0), is_numeric(0), array(NULL), strings(NULL),
          x_size(0), y_size(0), z_size(0)
        {
        }

        int offset;
        bool is_numeric;
        ArrayNumber * array;
        std::string * strings;
        int x_size, y_size, z_size;
        int x_pos, y_pos, z_pos;
    };

    struct SavedArray
    {
        bool init;
        ArrayData value;
    };

    ArrayData data;
    SavedArray * global_data;

    ArrayObject(int x, int y, int type_id);
    ~ArrayObject();
    void initialize(bool is_numeric, int offset, int x, int y, int z);
    void clear();
    const std::string & get_string(int x=-1, int y=-1, int z=-1);
    ArrayNumber get_value(int x=-1, int y=-1, int z=-1);
    void set_value(ArrayNumber value, int x=-1, int y=-1, int z=-1);
    void set_string(const std::string & value, int x=-1, int y=-1, int z=-1);
    void load(const std::string & filename);
    void save(const std::string & filename);
    void expand(int x, int y, int z);

    inline void adjust_pos(int & x, int & y, int & z)
    {
        if (x == -1)
            x = data.x_pos;
        if (y == -1)
            y = data.y_pos;
        if (z == -1)
            z = data.z_pos;
        x -= data.offset;
        y -= data.offset;
        z -= data.offset;
    }

    inline int get_index(int x, int y, int z)
    {
        return x + y * data.x_size + z * data.x_size * data.y_size;
    }

    inline bool is_valid(int x, int y, int z)
    {
        return x >= 0 && y >= 0 && z >= 0 &&
               x < data.x_size && y < data.y_size && z < data.z_size;
    }
};

#endif // CHOWDREN_ARRAYEXT_H
