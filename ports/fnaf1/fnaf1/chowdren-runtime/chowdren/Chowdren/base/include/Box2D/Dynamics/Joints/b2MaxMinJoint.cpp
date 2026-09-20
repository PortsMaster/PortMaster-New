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

#include "b2MaxMinJoint.h"
#include "../b2Body.h"
#include "../b2World.h"

// 1-D constrained system
// m (v2 - v1) = lambda
// v2 + (beta/h) * x1 + gamma * lambda = 0, gamma has units of inverse mass.
// x2 = x1 + h * v2

// 1-D mass-damper-spring system
// m (v2 - v1) + h * d * v2 + h * k * 

// C = norm(p2 - p1) - L
// u = (p2 - p1) / norm(p2 - p1)
// Cdot = dot(u, v2 + cross(w2, r2) - v1 - cross(w1, r1))
// J = [-u -cross(r1, u) u cross(r2, u)]
// K = J * invM * JT
//   = invMass1 + invI1 * cross(r1, u)^2 + invMass2 + invI2 * cross(r2, u)^2

void b2MaxMinJointDef::Initialize(b2Body* b1, b2Body* b2,
									const b2Vec2& anchor1, const b2Vec2& anchor2,
									float32 minlen, float32 maxlen)
{
	body1 = b1;
	body2 = b2;
	localAnchor1 = body1->GetLocalPoint(anchor1);
	localAnchor2 = body2->GetLocalPoint(anchor2);
	b2Vec2 d = anchor2 - anchor1;
	minLength = minlen;
	maxLength = maxlen;
}


b2MaxMinJoint::b2MaxMinJoint(const b2MaxMinJointDef* def, b2Settings* set)
: b2Joint(def, set)
{
	m_localAnchor1 = def->localAnchor1;
	m_localAnchor2 = def->localAnchor2;
	m_minLength = def->minLength;
	m_maxLength = def->maxLength;
	m_impulse = 0.0f;
	m_limitImpulse = 0.0f;
}

void b2MaxMinJoint::InitVelocityConstraints(const b2TimeStep& step)
{
	b2Body* b1 = m_body1;
	b2Body* b2 = m_body2;

	// Compute the effective mass matrix.
	b2Vec2 r1 = b2Mul(b1->GetXForm().R, m_localAnchor1 - b1->GetLocalCenter());
	b2Vec2 r2 = b2Mul(b2->GetXForm().R, m_localAnchor2 - b2->GetLocalCenter());
	m_u = b2->m_sweep.c + r2 - b1->m_sweep.c - r1;

	b2Vec2 vDiff = b2->GetLinearVelocity()-b1->GetLinearVelocity();
	b2Vec2 pDiff = b2->GetWorldPoint(m_localAnchor2)-b1->GetWorldPoint(m_localAnchor1);
	float32 rVel = sinf(atan2f(vDiff.y,vDiff.x)-atan2f(pDiff.y,pDiff.x)+b2_pi/2) * settings->b2_linearSlop;
	if(vDiff.LengthSquared() < settings->b2_velocityThreshold) rVel = 0;
	//b2Clamp(rVel,-settings->b2_linearSlop,settings->b2_linearSlop);

	// Handle singularity.
	float32 length = m_u.Length();
	if (length > settings->b2_linearSlop)
	{
		m_u *= 1.0f / length;
	}
	else
	{
		m_u.Set(0.0f, 0.0f);
	}

	if(length > m_maxLength-b2Max(0.0f,rVel))
	{
		m_state = e_atUpperLimit;
		m_length = m_maxLength;
	}
	else if(length < m_minLength-b2Min(0.0f,rVel))
	{
		m_state = e_atLowerLimit;
		m_length = m_minLength;
	}
	else
	{
		m_state = e_inactiveLimit;
		m_impulse = 0.0f;
	}

	float32 cr1u = b2Cross(r1, m_u);
	float32 cr2u = b2Cross(r2, m_u);
	float32 invMass = b1->m_invMass + b1->m_invI * cr1u * cr1u + b2->m_invMass + b2->m_invI * cr2u * cr2u;
	b2Assert(invMass > B2_FLT_EPSILON);
	m_mass = 1.0f / invMass;

	if (step.warmStarting)
	{
		// Scale the impulse to support a variable time step.
		m_impulse *= step.dtRatio;

		b2Vec2 P = m_impulse * m_u;
		b1->m_linearVelocity -= b1->m_invMass * P;
		b1->m_angularVelocity -= b1->m_invI * b2Cross(r1, P);
		b2->m_linearVelocity += b2->m_invMass * P;
		b2->m_angularVelocity += b2->m_invI * b2Cross(r2, P);
	}
	else
	{
		m_impulse = 0.0f;
	}
}

void b2MaxMinJoint::SolveVelocityConstraints(const b2TimeStep& step)
{
	B2_NOT_USED(step);
	
	if(m_state == e_inactiveLimit) return;

	b2Body* b1 = m_body1;
	b2Body* b2 = m_body2;

	b2Vec2 r1 = b2Mul(b1->GetXForm().R, m_localAnchor1 - b1->GetLocalCenter());
	b2Vec2 r2 = b2Mul(b2->GetXForm().R, m_localAnchor2 - b2->GetLocalCenter());

	// Cdot = dot(u, v + cross(w, r))
	b2Vec2 v1 = b1->m_linearVelocity + b2Cross(b1->m_angularVelocity, r1);
	b2Vec2 v2 = b2->m_linearVelocity + b2Cross(b2->m_angularVelocity, r2);
	float32 Cdot = b2Dot(m_u, v2 - v1);

	float32 impulse = -m_mass * Cdot;//(Cdot + m_bias + m_gamma * m_impulse);
	m_impulse += impulse;

	b2Vec2 P = impulse * m_u;
	b1->m_linearVelocity -= b1->m_invMass * P;
	b1->m_angularVelocity -= b1->m_invI * b2Cross(r1, P);
	b2->m_linearVelocity += b2->m_invMass * P;
	b2->m_angularVelocity += b2->m_invI * b2Cross(r2, P);
}

bool b2MaxMinJoint::SolvePositionConstraints(float32 baumgarte)
{
	B2_NOT_USED(baumgarte);

	if (m_state == e_inactiveLimit) return true;

	b2Body* b1 = m_body1;
	b2Body* b2 = m_body2;

	b2Vec2 r1 = b2Mul(b1->GetXForm().R, m_localAnchor1 - b1->GetLocalCenter());
	b2Vec2 r2 = b2Mul(b2->GetXForm().R, m_localAnchor2 - b2->GetLocalCenter());

	b2Vec2 d = b2->m_sweep.c + r2 - b1->m_sweep.c - r1;

	float32 length = d.Normalize();
	float32 C = length - m_length;
	C = b2Clamp(C, -(settings->b2_maxLinearCorrection), settings->b2_maxLinearCorrection);

	float32 impulse = -m_mass * C;
	m_u = d;
	b2Vec2 P = impulse * m_u;

	b1->m_sweep.c -= b1->m_invMass * P;
	b1->m_sweep.a -= b1->m_invI * b2Cross(r1, P);
	b2->m_sweep.c += b2->m_invMass * P;
	b2->m_sweep.a += b2->m_invI * b2Cross(r2, P);

	b1->SynchronizeTransform();
	b2->SynchronizeTransform();

	return b2Abs(C) < settings->b2_linearSlop;
}

b2Vec2 b2MaxMinJoint::GetAnchor1() const
{
	return m_body1->GetWorldPoint(m_localAnchor1);
}

b2Vec2 b2MaxMinJoint::GetAnchor2() const
{
	return m_body2->GetWorldPoint(m_localAnchor2);
}

b2Vec2 b2MaxMinJoint::GetReactionForce(float32 inv_dt) const
{
	b2Vec2 F = (inv_dt * m_impulse) * m_u;
	return F;
}

float32 b2MaxMinJoint::GetReactionTorque(float32 inv_dt) const
{
	B2_NOT_USED(inv_dt);
	return 0.0f;
}
