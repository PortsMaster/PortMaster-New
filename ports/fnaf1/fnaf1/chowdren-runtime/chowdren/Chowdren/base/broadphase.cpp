#include "broadphase.h"

#ifdef USE_AABB_TREE
#include "broadphase/aabbtree.cpp"
#else
#include "broadphase/grid.cpp"
#endif
