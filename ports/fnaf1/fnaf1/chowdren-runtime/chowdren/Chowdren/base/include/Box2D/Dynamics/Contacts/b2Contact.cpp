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

#include "b2Contact.h"
#include "b2CircleContact.h"
#include "b2PolyAndCircleContact.h"
#include "b2PolyContact.h"
#include "b2EdgeAndCircleContact.h"
#include "b2PolyAndEdgeContact.h"
#include "b2ContactSolver.h"
#include "../../Collision/b2Collision.h"
#include "../../Collision/Shapes/b2Shape.h"
#include "../../Common/b2BlockAllocator.h"
#include "../../Dynamics/b2World.h"
#include "../../Dynamics/b2Body.h"
#include <string.h>

b2ContactRegister b2Contact::s_registers[e_shapeTypeCount][e_shapeTypeCount];
bool b2Contact::s_initialized = false;

void b2Contact::InitializeRegisters()
{
	AddType(b2CircleContact::Create, b2CircleContact::Destroy, e_circleShape, e_circleShape);
	AddType(b2PolyAndCircleContact::Create, b2PolyAndCircleContact::Destroy, e_polygonShape, e_circleShape);
	AddType(b2PolygonContact::Create, b2PolygonContact::Destroy, e_polygonShape, e_polygonShape);

	AddType(b2EdgeAndCircleContact::Create, b2EdgeAndCircleContact::Destroy, e_edgeShape, e_circleShape);
	AddType(b2PolyAndEdgeContact::Create, b2PolyAndEdgeContact::Destroy, e_polygonShape, e_edgeShape);
}

void b2Contact::AddType(b2ContactCreateFcn* createFcn, b2ContactDestroyFcn* destoryFcn,
					  b2ShapeType type1, b2ShapeType type2)
{
	b2Assert(e_unknownShape < type1 && type1 < e_shapeTypeCount);
	b2Assert(e_unknownShape < type2 && type2 < e_shapeTypeCount);

	s_registers[type1][type2].createFcn = createFcn;
	s_registers[type1][type2].destroyFcn = destoryFcn;
	s_registers[type1][type2].primary = true;

	if (type1 != type2)
	{
		s_registers[type2][type1].createFcn = createFcn;
		s_registers[type2][type1].destroyFcn = destoryFcn;
		s_registers[type2][type1].primary = false;
	}
}

b2Contact* b2Contact::Create(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator)
{
	if (s_initialized == false)
	{
		InitializeRegisters();
		s_initialized = true;
	}

	b2ShapeType type1 = shape1->GetType();
	b2ShapeType type2 = shape2->GetType();

	b2Assert(e_unknownShape < type1 && type1 < e_shapeTypeCount);
	b2Assert(e_unknownShape < type2 && type2 < e_shapeTypeCount);

	b2ContactCreateFcn* createFcn = s_registers[type1][type2].createFcn;
	if (createFcn)
	{
		if (s_registers[type1][type2].primary)
		{
			return createFcn(shape1, shape2, allocator);
		}
		else
		{
			b2Contact* c = createFcn(shape2, shape1, allocator);
			for (int32 i = 0; i < c->GetManifoldCount(); ++i)
			{
				b2Manifold* m = c->GetManifolds() + i;
				m->normal = -m->normal;
			}
			return c;
		}
	}
	else
	{
		return NULL;
	}
}

void b2Contact::Destroy(b2Contact* contact, b2BlockAllocator* allocator)
{
	b2Assert(s_initialized == true);

	if (contact->GetManifoldCount() > 0)
	{
		contact->GetShape1()->GetBody()->WakeUp();
		contact->GetShape2()->GetBody()->WakeUp();
	}

	b2ShapeType type1 = contact->GetShape1()->GetType();
	b2ShapeType type2 = contact->GetShape2()->GetType();

	b2Assert(e_unknownShape < type1 && type1 < e_shapeTypeCount);
	b2Assert(e_unknownShape < type2 && type2 < e_shapeTypeCount);

	b2ContactDestroyFcn* destroyFcn = s_registers[type1][type2].destroyFcn;
	destroyFcn(contact, allocator);
}

b2Contact::b2Contact(b2Shape* s1, b2Shape* s2)
{
	m_flags = 0;

	if (s1->IsSensor() || s2->IsSensor())
	{
		m_flags |= e_nonSolidFlag;
	}

	m_shape1 = s1;
	m_shape2 = s2;

	m_manifoldCount = 0;

	m_prev = NULL;
	m_next = NULL;

	m_node1.contact = NULL;
	m_node1.prev = NULL;
	m_node1.next = NULL;
	m_node1.other = NULL;

	m_node2.contact = NULL;
	m_node2.prev = NULL;
	m_node2.next = NULL;
	m_node2.other = NULL;

	m_userData = NULL;
}

void b2Contact::Update(b2ContactListener* listener)
{
	int32 oldCount = GetManifoldCount();

	Evaluate(listener);

	int32 newCount = GetManifoldCount();

	b2Body* body1 = m_shape1->GetBody();
	b2Body* body2 = m_shape2->GetBody();

	if (newCount == 0 && oldCount > 0)
	{
		body1->WakeUp();
		body2->WakeUp();
	}

	// Slow contacts don't generate TOI events.
	if (body1->IsStatic() || body1->IsBullet() || body2->IsStatic() || body2->IsBullet())
	{
		m_flags &= ~e_slowFlag;
	}
	else
	{
		m_flags |= e_slowFlag;
	}
}

void Debug(int d);

void b2SingleManifoldContact::Evaluate(b2ContactListener* listener)
{
	b2Body* b1 = m_shape1->GetBody();
	b2Body* b2 = m_shape2->GetBody();

	b2Manifold m0;
	memcpy(&m0, &m_manifold, sizeof(b2Manifold));

	Collide();

	bool persisted[b2_maxManifoldPoints] = {false, false};

	b2ContactPoint cp;
	cp.shape1 = m_shape1;
	cp.shape2 = m_shape2;
	cp.friction = b2MixFriction(m_shape1->GetFriction(), m_shape2->GetFriction());
	cp.restitution = b2MixRestitution(m_shape1->GetRestitution(), m_shape2->GetRestitution());


	// Match contact ids to facilitate warm starting.
	if (m_manifold.pointCount > 0)
	{

		// Report start of contact, and update solidity
		if (listener)
		{
			if (0 == m0.pointCount)
			{
				if(listener->ContactStart(this)){
					m_flags &= ~e_nonSolidFlag;
				}else{
					m_flags |= e_nonSolidFlag;
				}
			}
		}

		// Match old contact ids to new contact ids and copy the
		// stored impulses to warm start the solver.
		for (int32 i = 0; i < m_manifold.pointCount; ++i)
		{
			b2ManifoldPoint* mp = m_manifold.points + i;
			mp->normalImpulse = 0.0f;
			mp->tangentImpulse = 0.0f;
			bool found = false;
			b2ContactID id = mp->id;

			for (int32 j = 0; j < m0.pointCount; ++j)
			{
				if (persisted[j] == true)
				{
					continue;
				}

				b2ManifoldPoint* mp0 = m0.points + j;

				if (mp0->id.key == id.key)
				{
					persisted[j] = true;
					mp->normalImpulse = mp0->normalImpulse;
					mp->tangentImpulse = mp0->tangentImpulse;

					// A persistent point.
					found = true;

					// Report persistent point.
					if (listener)
					{
						cp.position = b1->GetWorldPoint(mp->localPoint1);
						b2Vec2 v1 = b1->GetLinearVelocityFromLocalPoint(mp->localPoint1);
						b2Vec2 v2 = b2->GetLinearVelocityFromLocalPoint(mp->localPoint2);
						cp.velocity = v2 - v1;
						cp.normal = m_manifold.normal;
						cp.separation = mp->separation;
						cp.id = id;
						listener->ContactPointPersist(this, &cp);
					}
					break;
				}
			}

			// Report added point.
			if (found == false && listener)
			{
				cp.position = b1->GetWorldPoint(mp->localPoint1);
				b2Vec2 v1 = b1->GetLinearVelocityFromLocalPoint(mp->localPoint1);
				b2Vec2 v2 = b2->GetLinearVelocityFromLocalPoint(mp->localPoint2);
				cp.velocity = v2 - v1;
				cp.normal = m_manifold.normal;
				cp.separation = mp->separation;
				cp.id = id;
				listener->ContactPointAdd(this, &cp);
			}
		}

		m_manifoldCount = 1;
	}
	else
	{
		m_manifoldCount = 0;
	}

	if (!listener)
	{
		return;
	}

	if (m0.pointCount > 0)
	{
		// Report removed points.
		for (int32 i = 0; i < m0.pointCount; ++i)
		{
			if (persisted[i])
			{
				continue;
			}

			b2ManifoldPoint* mp0 = m0.points + i;
			cp.position = b1->GetWorldPoint(mp0->localPoint1);
			b2Vec2 v1 = b1->GetLinearVelocityFromLocalPoint(mp0->localPoint1);
			b2Vec2 v2 = b2->GetLinearVelocityFromLocalPoint(mp0->localPoint2);
			cp.velocity = v2 - v1;
			cp.normal = m0.normal;
			cp.separation = mp0->separation;
			cp.id = mp0->id;
			listener->ContactPointRemove(this, &cp);
		}

		// Report end of contact
		if (0 == m_manifold.pointCount)
		{
			listener->ContactStop(this);
		}
	}
}

void b2SinglePointContact::Evaluate(b2ContactListener* listener)
{
	b2Body* b1 = m_shape1->GetBody();
	b2Body* b2 = m_shape2->GetBody();

	b2Manifold m0;
	memcpy(&m0, &m_manifold, sizeof(b2Manifold));

	Collide();

	b2ContactPoint cp;
	cp.shape1 = m_shape1;
	cp.shape2 = m_shape2;
	cp.friction = b2MixFriction(m_shape1->GetFriction(), m_shape2->GetFriction());
	cp.restitution = b2MixRestitution(m_shape1->GetRestitution(), m_shape2->GetRestitution());

	if (m_manifold.pointCount > 0)
	{
		m_manifoldCount = 1;
		b2ManifoldPoint* mp = m_manifold.points + 0;

		if (m0.pointCount == 0)
		{
			mp->normalImpulse = 0.0f;
			mp->tangentImpulse = 0.0f;

			if (listener)
			{
				// Report start of contact, and update solidity
				if (listener)
				{
					if (0 == m0.pointCount)
					{
						if(listener->ContactStart(this)){
							m_flags &= ~e_nonSolidFlag;
						}else{
							m_flags |= e_nonSolidFlag;
						}
					}
				}

				if (listener)
				{
					cp.position = b1->GetWorldPoint(mp->localPoint1);
					b2Vec2 v1 = b1->GetLinearVelocityFromLocalPoint(mp->localPoint1);
					b2Vec2 v2 = b2->GetLinearVelocityFromLocalPoint(mp->localPoint2);
					cp.velocity = v2 - v1;
					cp.normal = m_manifold.normal;
					cp.separation = mp->separation;
					cp.id = mp->id;
					listener->ContactPointAdd(this, &cp);
				}
			}
		}
		else
		{
			b2ManifoldPoint* mp0 = m0.points + 0;
			mp->normalImpulse = mp0->normalImpulse;
			mp->tangentImpulse = mp0->tangentImpulse;

			if (listener)
			{
				cp.position = b1->GetWorldPoint(mp->localPoint1);
				b2Vec2 v1 = b1->GetLinearVelocityFromLocalPoint(mp->localPoint1);
				b2Vec2 v2 = b2->GetLinearVelocityFromLocalPoint(mp->localPoint2);
				cp.velocity = v2 - v1;
				cp.normal = m_manifold.normal;
				cp.separation = mp->separation;
				cp.id = mp->id;
				listener->ContactPointPersist(this, &cp);
			}
		}
	}
	else
	{
		m_manifoldCount = 0;
		if (m0.pointCount > 0 && listener)
		{
			b2ManifoldPoint* mp0 = m0.points + 0;
			cp.position = b1->GetWorldPoint(mp0->localPoint1);
			b2Vec2 v1 = b1->GetLinearVelocityFromLocalPoint(mp0->localPoint1);
			b2Vec2 v2 = b2->GetLinearVelocityFromLocalPoint(mp0->localPoint2);
			cp.velocity = v2 - v1;
			cp.normal = m0.normal;
			cp.separation = mp0->separation;
			cp.id = mp0->id;
			listener->ContactPointRemove(this, &cp);

			// Report end of contact.
			listener->ContactStop(this);
		}
	}
}
