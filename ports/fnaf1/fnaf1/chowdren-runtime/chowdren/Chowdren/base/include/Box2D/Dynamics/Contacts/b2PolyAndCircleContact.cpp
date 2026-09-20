/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
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

#include "b2PolyAndCircleContact.h"
#include "../b2Body.h"
#include "../b2WorldCallbacks.h"
#include "../../Common/b2BlockAllocator.h"

#include <new>
#include <string.h>

b2Contact* b2PolyAndCircleContact::Create(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator)
{
	void* mem = allocator->Allocate(sizeof(b2PolyAndCircleContact));
	return new (mem) b2PolyAndCircleContact(shape1, shape2);
}

void b2PolyAndCircleContact::Destroy(b2Contact* contact, b2BlockAllocator* allocator)
{
	((b2PolyAndCircleContact*)contact)->~b2PolyAndCircleContact();
	allocator->Free(contact, sizeof(b2PolyAndCircleContact));
}

b2PolyAndCircleContact::b2PolyAndCircleContact(b2Shape* s1, b2Shape* s2)
: b2SinglePointContact(s1, s2)
{
	b2Assert(m_shape1->GetType() == e_polygonShape);
	b2Assert(m_shape2->GetType() == e_circleShape);
	m_manifold.pointCount = 0;
}

void b2PolyAndCircleContact::Collide()
{
	b2Body* b1 = m_shape1->GetBody();
	b2Body* b2 = m_shape2->GetBody();

	b2CollidePolygonAndCircle(&m_manifold, (b2PolygonShape*)m_shape1, b1->GetXForm(), (b2CircleShape*)m_shape2, b2->GetXForm());

}
