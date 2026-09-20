#ifndef CHOWDREN_MATHHELPER_H
#define CHOWDREN_MATHHELPER_H

#include <boost/type_traits/common_type.hpp>
#include "dynnum.h"

struct MathHelper
{
};

template <class T>
class MathHelperValue
{
public:
    T value;

    MathHelperValue(T value)
    : value(value)
    {
    }
};

class MathHelperInt
{
public:
    int value;

    MathHelperInt(int value)
    : value(value)
    {
    }
};

class MathHelperDouble
{
public:
    double value;

    MathHelperDouble(double value)
    : value(value)
    {
    }
};

// safe divide

template <class T>
inline MathHelperValue<T> operator/(T lhs, MathHelper rhs)
{
    return MathHelperValue<T>(lhs);
}

template <class T, class U>
inline typename boost::common_type<T, U>::type
operator/(MathHelperValue<T> lhs, U rhs)
{
    if (rhs == 0)
        return 0;
    return lhs.value / rhs;
}

// power

inline MathHelperDouble operator*(double lhs, MathHelper rhs)
{
    return MathHelperDouble(lhs);
}

inline double operator*(MathHelperDouble lhs, int rhs)
{
    return int_pow(lhs.value, rhs);
}

inline double operator*(MathHelperDouble lhs, double rhs)
{
    return pow(lhs.value, rhs);
}

// float modulus

// safe divide

inline double get_mod(double a, double b)
{
    return fmod(a, b);
}

inline float get_mod(float a, float b)
{
    return fmod(a, b);
}

inline int get_mod(int a, int b)
{
    return a % b;
}

inline unsigned int get_mod(unsigned int a, unsigned int b)
{
    return a % b;
}

template <class T, class U>
inline typename boost::common_type<T, U>::type
operator%(const MathHelperValue<T> & lhs, U rhs)
{
    if (rhs == 0)
        return 0;
    return get_mod((typename boost::common_type<T, U>::type)(lhs.value),
                   (typename boost::common_type<T, U>::type)(rhs));
}

template <class T>
inline MathHelperValue<T> operator%(T lhs, MathHelper rhs)
{
    return MathHelperValue<T>(lhs);
}

// bitwise AND

inline MathHelperInt operator&(int lhs, MathHelper rhs)
{
    return MathHelperInt(lhs);
}

inline int operator&(MathHelperInt lhs, int rhs)
{
    return lhs.value & rhs;
}

// bitwise OR

inline MathHelperInt operator|(int lhs, MathHelper rhs)
{
    return MathHelperInt(lhs);
}

inline int operator|(MathHelperInt lhs, int rhs)
{
    return lhs.value | rhs;
}

// bitwise XOR

inline MathHelperInt operator^(int lhs, MathHelper rhs)
{
    return MathHelperInt(lhs);
}

inline int operator^(MathHelperInt lhs, int rhs)
{
    return lhs.value ^ rhs;
}

#endif // CHOWDREN_MATHHELPER_H
