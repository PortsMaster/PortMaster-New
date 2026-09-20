#ifndef CHOWDREN_MATH_H
#define CHOWDREN_MATH_H

#include <math.h>
#include <stdlib.h>
#include "crossrand.h"
#include <iostream>
#include <stdarg.h>
#include <boost/type_traits/common_type.hpp>
#include "dynnum.h"
#include <algorithm>

#define CHOW_PI 3.14159265358979323846264338327950288
#define RAD2DEG 57.295779513082320876798154814105

// math helpers

inline float mod(float a, float b)
{
    return a - b * floor(a / b);
}

inline int mod(int a, int b)
{
    return a - b * (a / b);
}

template <class T>
inline T rad(T x)
{
    return x / RAD2DEG;
}

template <class T>
inline T deg(T x)
{
    return x * RAD2DEG;
}

template <class T>
inline int sign_int(T x)
{
    if (x > 0)
        return 1;
    else if (x < 0)
        return -1;
    return 0;
}

inline double sin_deg(double x)
{
    if (x == 180.0)
        return 0.0;
    return sin(rad(x));
}

inline double cos_deg(double x)
{
    if (x == 90.0 || x == 270.0)
        return 0.0;
    return cos(rad(x));
}

inline double atan_deg(double v)
{
    return deg(atan(v));
}

inline double atan2_deg(double a, double b)
{
    return deg(atan2(a, b));
}

inline double asin_deg(double v)
{
    return deg(asin(v));
}

inline float get_length(float x, float y)
{
    return sqrt(x * x + y * y);
}

inline float get_distance(float x1, float y1, float x2, float y2)
{
    float dx = x2 - x1;
    float dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
}

inline int get_distance_int(int x1, int y1, int x2, int y2)
{
    int dx = x2 - x1;
    int dy = y2 - y1;
    return int(sqrt(float(dx * dx + dy * dy)));
}

inline double get_angle(int x1, int y1, int x2, int y2)
{
    double v = atan2_deg(y1 - y2, x2 - x1);
    if (v < 0.0)
        v += 360.0;
    return v;
}

inline int get_angle_int(int x1, int y1, int x2, int y2)
{
    return int(get_angle(x1, y1, x2, y2));
}

inline float get_angle_rad(float x1, float y1, float x2, float y2)
{
    float v = atan2(y1 - y2, x2 - x1);
    if (v < 0.0f)
        v += rad(360.0f);
    return v;
}

inline int get_angle_int(int x, int y)
{
    return get_angle_int(0, 0, x, y);
}

inline double get_direction(int x1, int y1, int x2, int y2)
{
    return get_angle(x1, y1, x2, y2) / 11.25;
}

inline int get_direction_int(int x1, int y1, int x2, int y2)
{
    return int(get_direction(x1, y1, x2, y2));
}

inline int int_round(double d)
{
    int v = (int)floor(d + 0.5);
    if (d - v > 0.5)
        v++;
    return v;
}

inline int int_min(int value1, int value2)
{
    return std::min<int>(value1, value2);
}

inline int int_max(int value1, int value2)
{
    return std::max<int>(value1, value2);
}

template <class T, class U>
inline typename boost::common_type<T, U>::type get_min(T a, U b)
{
    return std::min<typename boost::common_type<T, U>::type>(a, b);
}

template <class T, class U>
inline typename boost::common_type<T, U>::type get_max(T a, U b)
{
    return std::max<typename boost::common_type<T, U>::type>(a, b);
}

template <class T>
inline T clamp(T value, T min, T max)
{
    T x = value > max ? max : value;
    return x < min ? min : x;
}

template <class T>
inline T clamp(T val)
{
    T x = val > 1 ? 1 : val;
    return x < 0 ? 0 : x;
}

inline double int_pow(double value, int ex)
{
    double result = 1.0;
    while (ex) {
        if (ex & 1)
            result *= value;
        ex >>= 1;
        value *= value;
    }
    return result;
}

inline int get_abs(int v)
{
    return abs(v);
}

inline float get_abs(float v)
{
    return fabs(v);
}

inline double get_abs(double v)
{
    return fabs(v);
}

inline int get_ceil(int v)
{
    return v;
}

inline float get_ceil(float v)
{
    return ceil(v);
}

inline double get_ceil(double v)
{
    return ceil(v);
}

template <class T>
inline double get_exp(T v)
{
    return exp(double(v));
}

template <class T>
inline double get_ln(T v)
{
    return log(double(v));
}

template <class T>
inline double get_log10(T v)
{
    return log10(double(v));
}

inline double get_floor(int v)
{
    return double(v);
}

inline float get_floor(float v)
{
    return floor(v);
}

inline double get_floor(double v)
{
    return floor(v);
}

inline void intersect(int a_x1, int a_y1, int a_x2, int a_y2,
                      int b_x1, int b_y1, int b_x2, int b_y2,
                      int & r_x1, int & r_y1, int & r_x2, int & r_y2)
{
    r_x1 = std::max<int>(a_x1, b_x1);
    r_y1 = std::max<int>(a_y1, b_y1);
    r_x2 = std::min<int>(a_x2, b_x2);
    r_y2 = std::min<int>(a_y2, b_y2);
}

inline bool collides(int a_x1, int a_y1, int a_x2, int a_y2,
                     int b_x1, int b_y1, int b_x2, int b_y2)
{
    return a_x2 > b_x1 && a_y2 > b_y1 && a_x1 < b_x2 && a_y1 < b_y2;
}

inline bool collides(int a[4], int b[4])
{
    return a[2] > b[0] && a[3] > b[1] && a[0] < b[2] && a[1] < b[3];
}

inline bool contains(int b[4], int s[4])
{
    return s[0] >= b[0] && s[1] >= b[1] &&
           s[2] <= b[2] && s[3] <= b[3];
}

inline void rect_union(int a_x1, int a_y1, int a_x2, int a_y2,
                       int b_x1, int b_y1, int b_x2, int b_y2,
                       int & r_x1, int & r_y1, int & r_x2, int & r_y2)
{
    r_x1 = std::min<int>(a_x1, b_x1);
    r_y1 = std::min<int>(a_y1, b_y1);
    r_x2 = std::max<int>(a_x2, b_x2);
    r_y2 = std::max<int>(a_y2, b_y2);
}

inline void get_dir(int dir, double & x, double & y)
{
    switch (dir) {
        case 0:
            x = 1.0;
            y = 0.0;
            return;
        case 8:
            x = 0.0;
            y = -1.0;
            return;
        case 16:
            x = -1.0;
            y = 0.0;
            return;
        case 24:
            x = 0.0;
            y = 1.0;
            return;
        default:
            break;
    }
    double r = rad(dir * 11.25);
    x = cos(r);
    y = -sin(r);
}

inline void get_dir(int dir, float & x, float & y)
{
    switch (dir) {
        case 0:
            x = 1.0f;
            y = 0.0f;
            return;
        case 8:
            x = 0.0f;
            y = -1.0f;
            return;
        case 16:
            x = -1.0f;
            y = 0.0f;
            return;
        case 24:
            x = 0.0f;
            y = 1.0f;
            return;
        default:
            break;
    }
    float r = rad(dir * 11.25f);
    x = cos(r);
    y = -sin(r);
}

inline int get_dir_diff_abs(int d1, int d2)
{
    return get_min(get_abs(d1 - d2), get_min(get_abs(d1 - d2 - 360),
                                             get_abs(d1 - d2 + 360)));
}

// random

inline int randrange(int range)
{
    return (range * cross_rand()) / (CROSS_RAND_MAX + 1);
}

inline int randrange_event(int range)
{
    return randrange(range & 0xFFFF);
}

inline float randrange(float a, float b)
{
    return a + (cross_rand() * (b - a)) / (CROSS_RAND_MAX + 1.0f);
}

inline bool random_chance(int a, int b)
{
    return randrange(b) < a;
}

inline int pick_random(int count, ...)
{
    if (count == 0)
        std::cout << "Invalid pick_random count!" << std::endl;
    va_list ap;
    va_start(ap, count);
    int picked_index = randrange(count);
    int value;
    for(int i = 0; i < count; i++) {
        if (i != picked_index)
            va_arg(ap, int);
        else
            value = va_arg(ap, int);
    }
    va_end(ap);
    return value;
}

inline int round_pow2(int x)
{
    if (x < 0)
        return 0;
    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x+1;
}

#endif // CHOWDREN_MATH_H
