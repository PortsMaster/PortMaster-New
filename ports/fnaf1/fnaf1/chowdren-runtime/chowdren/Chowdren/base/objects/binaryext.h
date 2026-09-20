#ifndef CHOWDREN_BINARYEXT_H
#define CHOWDREN_BINARYEXT_H

#include "frameobject.h"
#include <string>

class BinaryObject : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(BinaryObject)

    char * data;
    size_t size;

    BinaryObject(int x, int y, int type_id);
    ~BinaryObject();
    void load_file(const std::string & filename);
    void save_file(const std::string & filename);
    void set_byte(unsigned char value, size_t addr);
    void resize(size_t size);
    int get_byte(size_t addr);
    int get_short(size_t addr);
};

#endif // CHOWDREN_BINARYEXT_H
