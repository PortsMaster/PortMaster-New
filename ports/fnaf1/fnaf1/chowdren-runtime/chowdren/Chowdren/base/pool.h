#ifndef CHOWDREN_POOL_H
#define CHOWDREN_POOL_H

#include "types.h"
#include <stdlib.h>

/*
NOTE: This intentionally leaks the blocks used, as we intend to use them for
the duration of the application.
*/

template <class T>
class ObjectPool
{
public:
    void ** free_items;
    long available;
    long total;
    long buffer_size;

    ~ObjectPool()
    {
        delete[] free_items;
    }

    void * create()
    {
        if (available > 0)
            return free_items[--available];

        if (buffer_size == 0)
            buffer_size = 32;

        delete[] free_items;
        unsigned char * block = new unsigned char[sizeof(T)*buffer_size];
        total += buffer_size;
        free_items = new void*[total];
        for (int i = 0; i < buffer_size; i++) {
            free_items[available++] = block;
            block += sizeof(T);
        }
        buffer_size *= 2;
        return free_items[--available];
    }

    void destroy(void * ptr)
    {
        if (ptr == NULL)
            return;
        free_items[available++] = ptr;
    }
};

#endif // CHOWDREN_POOL_H
