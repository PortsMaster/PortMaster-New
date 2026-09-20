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

#include "b2Shape.h"
#include "b2CircleShape.h"
#include "b2PolygonShape.h"
#include "b2EdgeShape.h"
#include "../b2Collision.h"
#include "../b2BroadPhase.h"
#include "../../Common/b2BlockAllocator.h"
#include "../../Dynamics/b2Body.h"

#include <new>

b2Shape* b2Shape::Create(const b2ShapeDef* def, b2BlockAllocator* allocator, b2Settings* set)
{
	switch (def->type)
	{
	case e_circleShape:
		{
			void* mem = allocator->Allocate(sizeof(b2CircleShape));
			return new (mem) b2CircleShape(def, set);
		}

	case e_polygonShape:
		{
			void* mem = allocator->Allocate(sizeof(b2PolygonShape) + ((b2PolygonDef*)def)->vertexCount * sizeof(b2Vec2) * 3);
			return new (mem) b2PolygonShape(def, set);
		}

	default:
		b2Assert(false);
		return NULL;
	}
}

void b2Shape::Destroy(b2Shape* s, b2BlockAllocator* allocator)
{
	b2EdgeShape* edge;
	switch (s->GetType())
	{
	case e_circleShape:
		s->~b2Shape();
		allocator->Free(s, sizeof(b2CircleShape));
		break;

	case e_polygonShape:
		s->~b2Shape();
		allocator->Free(s, sizeof(b2PolygonShape) + ((b2PolygonShape*)s)->m_vertexCount * sizeof(b2Vec2) * 3);
		break;

	case e_edgeShape:
		edge = (b2EdgeShape*) s;
		if (edge->m_nextEdge != NULL) edge->m_nextEdge->m_prevEdge = NULL;
		if (edge->m_prevEdge != NULL) edge->m_prevEdge->m_nextEdge = NULL;
		s->~b2Shape();
		allocator->Free(s, sizeof(b2EdgeShape));
		break;

	default:
		b2Assert(false);
	}
}

b2Shape::b2Shape(const b2ShapeDef* def, b2Settings* set)
{
	settings = set;
	m_userData = def->userData;
	m_friction = def->friction;
	m_restitution = def->restitution;
	m_density = def->density;
	m_body = NULL;
	m_sweepRadius = 0.0f;

	m_next = NULL;

	m_proxyId = b2_nullProxy;

	m_filter = def->filter;

	m_isSensor = def->isSensor;
}

b2Shape::~b2Shape()
{
	b2Assert(m_proxyId == b2_nullProxy);
}

void b2Shape::CreateProxy(b2BroadPhase* broadPhase, const b2XForm& transform)
{
	b2Assert(m_proxyId == b2_nullProxy);

	b2AABB aabb;
	ComputeAABB(&aabb, transform);

	bool inRange = broadPhase->InRange(aabb);

	// You are creating a shape outside the world box.
	b2Assert(inRange);

	if (inRange)
	{
		m_proxyId = broadPhase->CreateProxy(aabb, this);
	}
	else
	{
		m_proxyId = b2_nullProxy;
	}
}

void b2Shape::DestroyProxy(b2BroadPhase* broadPhase)
{
	if (m_proxyId != b2_nullProxy)
	{
		broadPhase->DestroyProxy(m_proxyId);
		m_proxyId = b2_nullProxy;
	}
}

bool b2Shape::Synchronize(b2BroadPhase* broadPhase, const b2XForm& transform1, const b2XForm& transform2)
{
	if (m_proxyId == b2_nullProxy)
	{	
		return false;
	}

	// Compute an AABB that covers the swept shape (may miss some rotation effect).
	b2AABB aabb;
	ComputeSweptAABB(&aabb, transform1, transform2);

	if (broadPhase->InRange(aabb))
	{
		broadPhase->MoveProxy(m_proxyId, aabb);
		return true;
	}
	else
	{
		return false;
	}
}

void b2Shape::RefilterProxy(b2BroadPhase* broadPhase, const b2XForm& transform)
{
	if (m_proxyId == b2_nullProxy)
	{	
		return;
	}

	broadPhase->DestroyProxy(m_proxyId);

	b2AABB aabb;
	ComputeAABB(&aabb, transform);

	bool inRange = broadPhase->InRange(aabb);

	if (inRange)
	{
		m_proxyId = broadPhase->CreateProxy(aabb, this);
	}
	else
	{
		m_proxyId = b2_nullProxy;
	}
}

bool b2Shape::IsTouching(b2Body* other)
{
	return other->IsTouching(this);
}
bool b2Shape::IsTouching(b2Body* other, b2ContactResult* result)
{
	return other->IsTouching(this, result);
}

bool b2Shape::IsTouching(b2Shape* otherShape)
{
	b2Body* body = m_body;
	b2Body* other = otherShape->m_body;
	for(b2ContactEdge* edge = body->GetContactList();edge;edge=edge->next)
	{
		b2Contact* contact = edge->contact;
		if(edge->other==other && contact->GetManifoldCount()>0)
		if(		(contact->GetShape1()==this && contact->GetShape2()==otherShape)
			||	(contact->GetShape1()==otherShape && contact->GetShape2()==this)
		  )
		{
			return true;
		}
	}
	return false;
}
bool b2Shape::IsTouching(b2Shape* otherShape, b2ContactResult* result)
{
	b2Body* body = m_body;
	b2Body* other = otherShape->m_body;
	for(b2ContactEdge* edge = body->GetContactList();edge;edge=edge->next)
	{
		b2Contact* contact = edge->contact;
		b2Shape* shape1 = contact->GetShape1();
		b2Shape* shape2 = contact->GetShape2();
		if(edge->other==other && contact->GetManifoldCount()>0)
		if(		(shape1==this && shape2==otherShape)
			||	(shape1==otherShape && shape2==this)
		  )
		{
			b2Manifold* manifold = contact->GetManifolds();
			b2Assert(manifold->pointCount>0);
			b2ManifoldPoint* point = &manifold->points[0];
			result->shape1 = shape1;
			result->shape2 = shape2;
			result->position = shape1->GetBody()->GetWorldPoint(point->localPoint1);
			result->normal = manifold->normal;
			result->normalImpulse = point->normalImpulse;
			result->tangentImpulse = point->tangentImpulse;
			result->id = point->id;
			return true;
		}
	}
	return false;
}

bool b2Shape::IsTouching(int collType)
{
	b2Body* body = m_body;
	for(b2ContactEdge* edge = body->GetContactList();edge;edge=edge->next)
	{
		b2Contact* contact = edge->contact;
		if(contact->GetManifoldCount()>0)
		if(		(contact->GetShape1()==this && contact->GetShape2()->GetUserData()->collType == collType)
			||	(contact->GetShape1()->GetUserData()->collType == collType && contact->GetShape2()==this)
		  )
		{
			return true;
		}
	}
	return false;
}
