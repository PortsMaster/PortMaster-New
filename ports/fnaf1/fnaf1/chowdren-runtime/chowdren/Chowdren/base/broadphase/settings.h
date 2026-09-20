/*
* Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef CHOWDREN_SETTINGS_H
#define CHOWDREN_SETTINGS_H

#include <assert.h>
#include <stdlib.h>

#define chowAssert(A) assert(A)

typedef signed char int8;
typedef signed short int16;
typedef signed int int32;
typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;

#define chow_maxInt32 0x7FFFFFFF
#define chow_aabbExtension 10 // pixels
#define chow_aabbMultiplier 2
#define chowAlloc malloc
#define chowFree free

#endif
