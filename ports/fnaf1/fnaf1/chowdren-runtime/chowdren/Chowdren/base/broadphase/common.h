/*
* Copyright (c) 2009 Erin Catto http://www.box2d.org
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

/*
This is a fork from Box2D, changed for use in Chowdren
*/

#ifndef CHOWDREN_COLLISION_COLLISION_H
#define CHOWDREN_COLLISION_COLLISION_H

#include "broadphase/settings.h"

struct chowVec2
{
    /// Default constructor does nothing (for performance).
    chowVec2() {}

    /// Construct using coordinates.
    chowVec2(int32 x, int32 y) : x(x), y(y) {}

    /// Set this vector to all zeros.
    void SetZero() { x = 0; y = 0; }

    /// Set this vector to some specified coordinates.
    void Set(int32 x_, int32 y_) { x = x_; y = y_; }

    /// Negate this vector.
    chowVec2 operator -() const
    {
        chowVec2 v;
        v.Set(-x, -y);
        return v;
    }

    /// Read from and indexed element.
    int32 operator () (int32 i) const
    {
        return (&x)[i];
    }

    /// Write to an indexed element.
    int32& operator () (int32 i)
    {
        return (&x)[i];
    }

    /// Add a vector to this vector.
    void operator += (const chowVec2& v)
    {
        x += v.x; y += v.y;
    }

    /// Subtract a vector from this vector.
    void operator -= (const chowVec2& v)
    {
        x -= v.x; y -= v.y;
    }

    void operator *= (int32 a)
    {
        x *= a; y *= a;
    }

    void operator /= (int32 a)
    {
        x /= a;
        y /= a;
    }

    int32 x, y;
};

/// Add two vectors component-wise.
inline chowVec2 operator + (const chowVec2& a, const chowVec2& b)
{
    return chowVec2(a.x + b.x, a.y + b.y);
}

/// Subtract two vectors component-wise.
inline chowVec2 operator - (const chowVec2& a, const chowVec2& b)
{
    return chowVec2(a.x - b.x, a.y - b.y);
}

inline chowVec2 operator * (int32 s, const chowVec2& a)
{
    return chowVec2(s * a.x, s * a.y);
}

inline chowVec2 operator / (const chowVec2& a, int32 s)
{
    return chowVec2(s / a.x, s / a.y);
}

inline bool operator == (const chowVec2& a, const chowVec2& b)
{
    return a.x == b.x && a.y == b.y;
}

template <typename T>
inline T chowAbs(T a)
{
    return a > T(0) ? a : -a;
}

inline chowVec2 chowAbs(const chowVec2& a)
{
    return chowVec2(chowAbs(a.x), chowAbs(a.y));
}

template <typename T>
inline T chowMin(T a, T b)
{
    return a < b ? a : b;
}

inline chowVec2 chowMin(const chowVec2& a, const chowVec2& b)
{
    return chowVec2(chowMin(a.x, b.x), chowMin(a.y, b.y));
}

template <typename T>
inline T chowMax(T a, T b)
{
    return a > b ? a : b;
}

inline chowVec2 chowMax(const chowVec2& a, const chowVec2& b)
{
    return chowVec2(chowMax(a.x, b.x), chowMax(a.y, b.y));
}

/// An axis aligned bounding box.
struct AABB
{
    /// Get the center of the AABB.
    chowVec2 GetCenter() const
    {
        return (lowerBound + upperBound) / 2;
    }

    /// Get the extents of the AABB (half-widths).
    chowVec2 GetExtents() const
    {
        return (upperBound - lowerBound) / 2;
    }

    /// Get the perimeter length
    int32 GetPerimeter() const
    {
        int32 wx = upperBound.x - lowerBound.x;
        int32 wy = upperBound.y - lowerBound.y;
        return 2 * (wx + wy);
    }

    /// Combine an AABB into this one.
    void Combine(const AABB& aabb)
    {
        lowerBound = chowMin(lowerBound, aabb.lowerBound);
        upperBound = chowMax(upperBound, aabb.upperBound);
    }

    /// Combine two AABBs into this one.
    void Combine(const AABB& aabb1, const AABB& aabb2)
    {
        lowerBound = chowMin(aabb1.lowerBound, aabb2.lowerBound);
        upperBound = chowMax(aabb1.upperBound, aabb2.upperBound);
    }

    /// Does this aabb contain the provided AABB.
    bool Contains(const AABB& aabb) const
    {
        bool result = true;
        result = result && lowerBound.x <= aabb.lowerBound.x;
        result = result && lowerBound.y <= aabb.lowerBound.y;
        result = result && aabb.upperBound.x <= upperBound.x;
        result = result && aabb.upperBound.y <= upperBound.y;
        return result;
    }

    chowVec2 lowerBound;  ///< the lower vertex
    chowVec2 upperBound;  ///< the upper vertex
};

inline bool chowTestOverlap(const AABB& a, const AABB& b)
{
    chowVec2 d1, d2;
    d1 = b.lowerBound - a.upperBound;
    d2 = a.lowerBound - b.upperBound;

    if (d1.x > 0 || d1.y > 0)
        return false;

    if (d2.x > 0 || d2.y > 0)
        return false;

    return true;
}

#endif // CHOWDREN_COLLISION_COLLISION_H
