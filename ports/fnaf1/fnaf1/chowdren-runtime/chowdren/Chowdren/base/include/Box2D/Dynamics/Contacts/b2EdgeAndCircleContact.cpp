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

#include "b2EdgeAndCircleContact.h"
#include "../b2Body.h"
#include "../b2WorldCallbacks.h"
#include "../../Common/b2BlockAllocator.h"
#include "../../Collision/Shapes/b2EdgeShape.h"

#include <new>
#include <string.h>

b2Contact* b2EdgeAndCircleContact::Create(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator)
{
	void* mem = allocator->Allocate(sizeof(b2EdgeAndCircleContact));
	return new (mem) b2EdgeAndCircleContact(shape1, shape2);
}

void b2EdgeAndCircleContact::Destroy(b2Contact* contact, b2BlockAllocator* allocator)
{
	((b2EdgeAndCircleContact*)contact)->~b2EdgeAndCircleContact();
	allocator->Free(contact, sizeof(b2EdgeAndCircleContact));
}

b2EdgeAndCircleContact::b2EdgeAndCircleContact(b2Shape* s1, b2Shape* s2)
: b2SinglePointContact(s1, s2)
{
	b2Assert(m_shape1->GetType() == e_edgeShape);
	b2Assert(m_shape2->GetType() == e_circleShape);
	m_manifold.pointCount = 0;
	m_manifold.points[0].normalImpulse = 0.0f;
	m_manifold.points[0].tangentImpulse = 0.0f;
}

void b2EdgeAndCircleContact::Collide()
{
	b2Body* b1 = m_shape1->GetBody();
	b2Body* b2 = m_shape2->GetBody();

	b2CollideEdgeAndCircle(&m_manifold, (b2EdgeShape*)m_shape1, b1->GetXForm(), (b2CircleShape*)m_shape2, b2->GetXForm());

}

void b2EdgeAndCircleContact::b2CollideEdgeAndCircle(b2Manifold* manifold,
																const b2EdgeShape* edge,
																const b2XForm& xf1,
																const b2CircleShape* circle,
																const b2XForm& xf2)
{
	manifold->pointCount = 0;
	b2Vec2 d;
	b2Vec2 c = b2Mul(xf2, circle->GetLocalPosition());
	b2Vec2 cLocal = b2MulT(xf1, c);
	b2Vec2 n = edge->GetNormalVector();
	b2Vec2 v1 = edge->GetVertex1();
	b2Vec2 v2 = edge->GetVertex2();
	float32 radius = circle->GetRadius();
	float32 separation;

	float32 dirDist = b2Dot((cLocal - v1), edge->GetDirectionVector());
	if (dirDist <= 0) {
		d = cLocal - v1;
		if (b2Dot(d, edge->GetCorner1Vector()) < 0) {
			return;
		}
		d = c - b2Mul(xf1, v1);
	} else if (dirDist >= edge->GetLength()) {
		d = cLocal - v2;
		if (b2Dot(d, edge->GetCorner2Vector()) > 0) {
			return;
		}
		d = c - b2Mul(xf1, v2);
	} else {
		separation = b2Dot(cLocal - v1, n);
		if (separation > radius || separation < -radius) {
			return;
		}
		separation -= radius;
		manifold->normal = b2Mul(xf1.R, n);
		manifold->pointCount = 1;
		manifold->points[0].id.key = 0;
		manifold->points[0].separation = separation;
		c = c - radius * manifold->normal;
		manifold->points[0].localPoint1 = b2MulT(xf1, c);
		manifold->points[0].localPoint2 = b2MulT(xf2, c);
		return;
	}

	float32 distSqr = b2Dot(d,d);
	if (distSqr > radius * radius)
	{
		return;
	}

	if (distSqr < B2_FLT_EPSILON)
	{
		separation = -radius;
		manifold->normal = b2Mul(xf1.R, n);
	}
	else
	{
		separation = d.Normalize() - radius;
		manifold->normal = d;
	}

	manifold->pointCount = 1;
	manifold->points[0].id.key = 0;
	manifold->points[0].separation = separation;
	c = c - radius * manifold->normal;
	manifold->points[0].localPoint1 = b2MulT(xf1, c);
	manifold->points[0].localPoint2 = b2MulT(xf2, c);
}
