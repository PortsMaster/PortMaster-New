#ifndef ALTERABLES_H
#define ALTERABLES_H

// for size_t
#include <stdlib.h>
#include <string.h>
#include <string>
#include <iostream>
#include "dynnum.h"
#include "pool.h"

#define ALT_VALUES 26
#define ALT_STRINGS 10

class AlterableValues
{
public:
    DynamicNumber values[ALT_VALUES];

    AlterableValues()
    {
        for (int i = 0; i < ALT_VALUES; i++) {
            values[i] = 0;
        }
    }

    DynamicNumber get(size_t index)
    {
        if (index >= ALT_VALUES)
            return 0;
        return values[index];
    }

    int get_int(size_t index)
    {
        return int(get(index));
    }

    void set(size_t index, DynamicNumber value)
    {
        if (index >= ALT_VALUES)
            return;
        values[index] = value;
    }

    void add(size_t index, DynamicNumber value)
    {
        set(index, get(index) + value);
    }

    void sub(size_t index, DynamicNumber value)
    {
        set(index, get(index) - value);
    }

    void set(const AlterableValues & v)
    {
        memcpy(values, v.values, ALT_VALUES*sizeof(DynamicNumber));
    }
};

class AlterableStrings
{
public:
    std::string values[ALT_STRINGS];

    AlterableStrings()
    {
    }

    const std::string & get(size_t index)
    {
        if (index >= ALT_STRINGS) {
            static std::string empty;
            return empty;
        }
        return values[index];
    }

    void set(size_t index, const std::string & value)
    {
        if (index >= ALT_STRINGS)
            return;
        values[index] = value;
    }

    void set(const AlterableStrings & v)
    {
        for (int i = 0; i < ALT_STRINGS; i++) {
            values[i] = v.values[i];
        }
    }
};

class AlterableFlags
{
public:
    unsigned int flags;

    AlterableFlags()
    : flags(0)
    {
    }

    void enable(int index)
    {
        index &= 31;
        flags |= 1 << index;
    }

    void disable(int index)
    {
        index &= 31;
        flags &= ~(1 << index);
    }

    void toggle(int index)
    {
        index &= 31;
        flags ^= 1 << index;
    }

    bool is_on(int index)
    {
        index &= 31;
        return (flags & (1 << index)) != 0;
    }

    bool is_off(int index)
    {
        index &= 31;
        return (flags & (1 << index)) == 0;
    }

    int get(int index)
    {
        index &= 31;
        return int(is_on(index));
    }

    void set(const AlterableFlags & other)
    {
        flags = other.flags;
    }
};

class Alterables
{
public:
    AlterableStrings strings;
    AlterableValues values;
    AlterableFlags flags;

    void set(const Alterables & other)
    {
        strings.set(other.strings);
        values.set(other.values);
        flags.set(other.flags);
    }

    static Alterables * create();
    static void destroy(Alterables * ptr);
};

struct SavedAlterables
{
    bool init;
    Alterables value;

    SavedAlterables()
    : init(false)
    {
    }
};

extern ObjectPool<Alterables> alterable_pool;

inline Alterables * Alterables::create()
{
    return new (alterable_pool.create()) Alterables();
}

inline void Alterables::destroy(Alterables * ptr)
{
    alterable_pool.destroy(ptr);
}

#endif // ALTERABLES_H
