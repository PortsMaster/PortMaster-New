#include "objects/binaryext.h"
#include "chowconfig.h"
#include "fileio.h"
#include <iostream>
#include <string.h>

// BinaryObject

BinaryObject::BinaryObject(int x, int y, int type_id)
: FrameObject(x, y, type_id), data(NULL), size(0)
{

}

BinaryObject::~BinaryObject()
{
    free(data);
}

void BinaryObject::load_file(const std::string & filename)
{
    free(data);
    std::cout << "Load binary array: " << filename << std::endl;
    read_file_c(convert_path(filename).c_str(), &data, &size);
}

void BinaryObject::save_file(const std::string & filename)
{
    std::cout << "Save binary array: " << filename << std::endl;
    FSFile fp(convert_path(filename).c_str(), "w");
    fp.write(data, size);
    fp.close();
}

void BinaryObject::set_byte(unsigned char byte, size_t addr)
{
    ((unsigned char*)data)[addr] = byte;
}

void BinaryObject::resize(size_t v)
{
    size = v;
    char * new_data = (char*)realloc(data, v);
    data = new_data;
}

int BinaryObject::get_byte(size_t addr)
{
    return ((unsigned char*)data)[addr];
}

int BinaryObject::get_short(size_t addr)
{
    unsigned char a = ((unsigned char*)data)[addr];
    unsigned char b = ((unsigned char*)data)[addr+1];
    unsigned short v = a | (b << 8);
    return v;
}
