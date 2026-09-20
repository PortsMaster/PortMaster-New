#ifndef CHOWDREN_DYNNUM_H
#define CHOWDREN_DYNNUM_H

#include "chowconfig.h"
#include <iostream>

#ifdef CHOWDREN_USE_DYNAMIC_NUMBER

struct DynamicNumber
{
    double value;
    bool is_fp;

    DynamicNumber()
    : value(0), is_fp(false)
    {
    }

    DynamicNumber(int value)
    : value(double(value)), is_fp(false)
    {
    }

    DynamicNumber(double value)
    : value(value), is_fp(true)
    {
    }

    DynamicNumber(double value, bool is_fp)
    : value(value), is_fp(is_fp)
    {
    }

    DynamicNumber operator=(DynamicNumber rhs)
    {
        value = rhs.value;
        is_fp = rhs.is_fp;
        return *this;
    }

    // plus
    template <typename T>
    DynamicNumber operator+(T rhs)
    {
        return *this + DynamicNumber(rhs);
    }

    DynamicNumber operator+(DynamicNumber rhs)
    {
        return DynamicNumber(value + rhs.value, is_fp || rhs.is_fp);
    }

    // minus
    template <typename T>
    DynamicNumber operator-(T rhs)
    {
        return *this - DynamicNumber(rhs);
    }

    DynamicNumber operator-(DynamicNumber rhs)
    {
        return DynamicNumber(value - rhs.value, is_fp || rhs.is_fp);
    }

    // multiply
    template <typename T>
    DynamicNumber operator*(T rhs)
    {
        return *this * DynamicNumber(rhs);
    }

    DynamicNumber operator*(DynamicNumber rhs)
    {
        return DynamicNumber(value * rhs.value, is_fp || rhs.is_fp);
    }

    // divide
    template <typename T>
    DynamicNumber operator/(T rhs)
    {
        return *this / DynamicNumber(rhs);
    }

    DynamicNumber operator/(DynamicNumber rhs)
    {
        if (!is_fp && !rhs.is_fp)
            return DynamicNumber(int(value / rhs.value));
        return DynamicNumber(value / rhs.value);
    }

    operator double() const
    {
        return value;
    }

    operator double()
    {
        return value;
    }
};

// lhs type T as first argument

template <typename T>
DynamicNumber operator+(T lhs, DynamicNumber rhs)
{
    return DynamicNumber(lhs) + rhs;
}

template <typename T>
DynamicNumber operator-(T lhs, DynamicNumber rhs)
{
    return DynamicNumber(lhs) - rhs;
}

template <typename T>
DynamicNumber operator/(T lhs, DynamicNumber rhs)
{
    return DynamicNumber(lhs) / rhs;
}

template <typename T>
DynamicNumber operator*(T lhs, DynamicNumber rhs)
{
    return DynamicNumber(lhs) * rhs;
}

#include <boost/type_traits/common_type.hpp>

namespace boost
{
    template <class T>
    struct common_type<DynamicNumber, T>
    {
        typedef DynamicNumber type;
    };

    template <class T>
    struct common_type<T, DynamicNumber>
    {
        typedef DynamicNumber type;
    };

    template <>
    struct common_type<DynamicNumber, DynamicNumber>
    {
        typedef DynamicNumber type;
    };
}

#else

#define DynamicNumber double

#endif

#endif // CHOWDREN_DYNNUM_H
