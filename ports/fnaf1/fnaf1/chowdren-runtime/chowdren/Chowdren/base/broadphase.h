#ifndef CHOWDREN_BROADPHASE_H
#define CHOWDREN_BROADPHASE_H

// #define USE_AABB_TREE

#ifdef USE_AABB_TREE
#include "broadphase/aabbtree.h"
typedef AABBTree Broadphase;
#else
#include "broadphase/grid.h"
typedef UniformGrid Broadphase;
#endif

#endif // CHOWDREN_BROADPHASE_H
