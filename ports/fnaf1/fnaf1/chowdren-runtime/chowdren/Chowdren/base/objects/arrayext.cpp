#include "objects/arrayext.h"
#include "chowconfig.h"
#include "fileio.h"
#include "datastream.h"
#include <algorithm>
#include "stringcommon.h"

// ArrayObject

ArrayObject::ArrayObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), global_data(NULL)
{

}

void ArrayObject::initialize(bool numeric, int offset, int x, int y, int z)
{
    data.offset = offset;
    data.is_numeric = numeric;
    data.x_size = x;
    data.y_size = y;
    data.z_size = z;
    data.x_pos = data.y_pos = data.z_pos = offset;
    clear();
}

#define CT_ARRAY_MAGIC "CNC ARRAY"
#define ARRAY_MAJOR_VERSION 2
#define ARRAY_MINOR_VERSION 0

#define NUMERIC_FLAG 1
#define TEXT_FLAG 2
#define BASE1_FLAG 4

void ArrayObject::load(const std::string & filename)
{
    FSFile fp(convert_path(filename).c_str(), "r");
    if (!fp.is_open()) {
        std::cout << "Could not load data.array " << filename << std::endl;
        return;
    }

    FileStream stream(fp);

    std::string magic;
    stream.read_string(magic, sizeof(CT_ARRAY_MAGIC));

    if (magic.compare(0, sizeof(CT_ARRAY_MAGIC),
                      CT_ARRAY_MAGIC, sizeof(CT_ARRAY_MAGIC)) != 0) {
        std::cout << "Invalid CT_ARRAY_MAGIC: " << filename << std::endl;
        std::cout << magic << " " << CT_ARRAY_MAGIC << std::endl;
        return;
    }

    if (stream.read_int16() != ARRAY_MAJOR_VERSION) {
        std::cout << "Invalid ARRAY_MAJOR_VERSION" << std::endl;
        return;
    }

    if (stream.read_int16() != ARRAY_MINOR_VERSION) {
        std::cout << "Invalid ARRAY_MINOR_VERSION" << std::endl;
        return;
    }

    data.x_size = stream.read_int32();
    data.y_size = stream.read_int32();
    data.z_size = stream.read_int32();

    int flags = stream.read_int32();
    data.is_numeric = (flags & NUMERIC_FLAG) != 0;
    data.offset = int((flags & BASE1_FLAG) != 0);

    delete[] data.array;
    delete[] data.strings;
    data.array = NULL;
    data.strings = NULL;
    clear();

    for (int i = 0; i < data.x_size * data.y_size * data.z_size; i++) {
        if (data.is_numeric) {
            data.array[i] = ArrayNumber(stream.read_int32());
        } else {
            stream.read_string(data.strings[i], stream.read_int32());
        }
    }

    fp.close();
}

void ArrayObject::save(const std::string & filename)
{
    FSFile fp(convert_path(filename).c_str(), "w");
    if (!fp.is_open())
        return;
    WriteStream stream;

    stream.write(CT_ARRAY_MAGIC, sizeof(CT_ARRAY_MAGIC));
    stream.write_int16(ARRAY_MAJOR_VERSION);
    stream.write_int16(ARRAY_MINOR_VERSION);
    stream.write_int32(data.x_size);
    stream.write_int32(data.y_size);
    stream.write_int32(data.z_size);

    int flags = 0;
    if (data.is_numeric)
        flags |= NUMERIC_FLAG;
    if (data.offset != 0)
        flags |= BASE1_FLAG;
    stream.write_int32(flags);

    for (int i = 0; i < data.x_size * data.y_size * data.z_size; i++) {
        if (data.is_numeric) {
            stream.write_int32(int(data.array[i]));
        } else {
            stream.write_int32(data.strings[i].size());
            stream.write_string(data.strings[i]);
        }
    }

    stream.save(fp);
    fp.close();
}

ArrayNumber ArrayObject::get_value(int x, int y, int z)
{
    adjust_pos(x, y, z);
    if (!is_valid(x, y, z))
        return 0;
    return data.array[get_index(x, y, z)];
}

const std::string & ArrayObject::get_string(int x, int y, int z)
{
    adjust_pos(x, y, z);
    if (!is_valid(x, y, z))
        return empty_string;
    return data.strings[get_index(x, y, z)];
}

void ArrayObject::set_value(ArrayNumber value, int x, int y, int z)
{
    adjust_pos(x, y, z);
    expand(x, y, z);
    data.array[get_index(x, y, z)] = value;
}

void ArrayObject::set_string(const std::string & value, int x, int y, int z)
{
    adjust_pos(x, y, z);
    expand(x, y, z);
    data.strings[get_index(x, y, z)] = value;
}

void ArrayObject::expand(int x, int y, int z)
{
    x = std::max(x+1, data.x_size);
    y = std::max(y+1, data.y_size);
    z = std::max(z+1, data.z_size);
    if (x == data.x_size && y == data.y_size && z == data.z_size)
        return;

#ifndef NDEBUG
    // probably good to signify that something should be preallocated
    std::cout << "Expanding " << get_name() << "from " <<
        "(" << data.x_size << ", " << data.y_size << ", " << data.z_size << ")" <<
        " to" <<
        "(" << x << ", " << y << ", " << z << ")" << std::endl;
#endif

    int old_x = data.x_size;
    int old_y = data.y_size;
    int old_z = data.z_size;

    data.x_size = x;
    data.y_size = y;
    data.z_size = z;

    if (data.is_numeric) {
        ArrayNumber * old_array = data.array;
        data.array = NULL;
        clear();
        for (int x = 0; x < old_x; x++)
        for (int y = 0; y < old_y; y++)
        for (int z = 0; z < old_z; z++) {
            ArrayNumber value = old_array[x + y * old_x + z * old_x * old_y];
            data.array[get_index(x, y, z)] = value;
        }
        delete[] old_array;
    } else {
        std::string * old_array = data.strings;
        data.strings = NULL;
        clear();
        for (int x = 0; x < old_x; x++)
        for (int y = 0; y < old_y; y++)
        for (int z = 0; z < old_z; z++) {
            const std::string & value = old_array[x + y * old_x +
                                                  z * old_x * old_y];
            data.strings[get_index(x, y, z)] = value;
        }
        delete[] old_array;
    }
}

ArrayObject::~ArrayObject()
{
    if (global_data) {
        global_data->value = data;
        return;
    }
    if (data.is_numeric)
        delete[] data.array;
    else
        delete[] data.strings;
}

void ArrayObject::clear()
{
    if (data.is_numeric) {
        delete[] data.array;
        data.array = new ArrayNumber[data.x_size *
                                     data.y_size *
                                     data.z_size]();
    } else {
        delete[] data.strings;
        data.strings = new std::string[data.x_size *
                                       data.y_size *
                                       data.z_size];
    }
}
