#ifndef CHOWDREN_BITARRAY_H
#define CHOWDREN_BITARRAY_H

#ifdef _WIN32

#include <malloc.h>

#ifndef __GNUC__
#define alloca _alloca
#endif

#elif defined(CHOWDREN_IS_DESKTOP) || defined(CHOWDREN_IS_WIIU)
#include <alloca.h>
#else
#include <stdlib.h>
#endif

#include <string.h>

class BaseBitArray
{
public:
    typedef unsigned long word_t;
    enum {
        WORD_SIZE = sizeof(word_t) * 8
    };

    word_t * data;

    BaseBitArray(void * data)
    : data((word_t*)data)
    {
    }

    unsigned long get(int index)
    {
        return data[index / WORD_SIZE] & (1UL << (index % WORD_SIZE));
    }

    void set(int index)
    {
        data[index / WORD_SIZE] |= 1UL << (index % WORD_SIZE);
    }

    void unset(int index)
    {
        data[index / WORD_SIZE] &= ~(1UL << (index % WORD_SIZE));
    }
};

#define GET_BITARRAY_PAD(N) ((((N) % BaseBitArray::WORD_SIZE) == 0) ? 0 : 1)
#define GET_BITARRAY_ITEMS(N) ((N) / BaseBitArray::WORD_SIZE +\
                               GET_BITARRAY_PAD(N))
#define GET_BITARRAY_SIZE(N) (sizeof(BaseBitArray::word_t) *\
                              GET_BITARRAY_ITEMS(N))

class BitArray : public BaseBitArray
{
public:
    BitArray()
    : BaseBitArray(NULL)
    {
    }
};

class StackBitArray : public BaseBitArray
{
public:
    StackBitArray(void * data, int n)
    : BaseBitArray(data)
    {
        memset(data, 0, n);
    }
};

#define CREATE_BITARRAY_ZERO(N) StackBitArray(alloca(GET_BITARRAY_SIZE(N)),\
                                              GET_BITARRAY_SIZE(N))

#endif // CHOWDREN_BITARRAY_H
