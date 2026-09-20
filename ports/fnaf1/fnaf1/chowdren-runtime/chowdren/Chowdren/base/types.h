#ifndef CHOWDREN_TYPES_H
#define CHOWDREN_TYPES_H

#ifdef _MSC_VER
#include <stddef.h>
typedef signed __int64 int64_t;
typedef unsigned __int64 uint64_t;
#else
#include <stdint.h>
#endif

// because this isn't included automatically with ARMCC
#include <string.h>

#if defined(CHOWDREN_IS_PS4) || defined(CHOWDREN_IS_VITA)
#include <unordered_map>
#define hash_map std::unordered_map
#else
#include <boost/unordered_map.hpp>
#define hash_map boost::unordered_map
#endif

#include <boost/container/vector.hpp>
using boost::container::vector;

#endif // CHOWDREN_TYPES_H
