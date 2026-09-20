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

#ifndef B2_MAXMIN_JOINT_H
#define B2_MAXMIN_JOINT_H

#include "b2Joint.h"

/// Distance joint definition. This requires defining an
/// anchor point on both bodies and the non-zero length of the
/// distance joint. The definition uses local anchor points
/// so that the initial configuration can violate the constraint
/// slightly. This helps when saving and loading a game.
/// @warning Do not use a zero or short length.
struct b2MaxMinJointDef : public b2JointDef
{
	b2MaxMinJointDef()
	{
		type = e_maxminJoint;
		localAnchor1.Set(0.0f, 0.0f);
		localAnchor2.Set(0.0f, 0.0f);
		minLength = 0.0f;
		maxLength = 1.0f;
		
		anchor1.SetZero();
		anchor2.SetZero();
		local1 = 0;
		local2 = 0;
		aminlength = 0.0f;
		absminlen = 0;
		amaxlength = 0.0f;
		absmaxlen = 0;
	}

	int defSize(){return sizeof(b2MaxMinJointDef);}

	b2Vec2 anchor1,anchor2;
	char local1,local2;
	float aminlength,amaxlength;
	char absminlen,absmaxlen;

	/// Initialize the bodies, anchors, and length using the world
	/// anchors.
	void Initialize(b2Body* body1, b2Body* body2,
					const b2Vec2& anchor1, const b2Vec2& anchor2,
					float32 minlen, float32 maxlen);

	/// The local anchor point relative to body1's origin.
	b2Vec2 localAnchor1;

	/// The local anchor point relative to body2's origin.
	b2Vec2 localAnchor2;

	/// The equilibrium length between the anchor points.
	float32 minLength;
	float32 maxLength;
};

/// A distance joint constrains two points on two bodies
/// to remain at a fixed distance from each other. You can view
/// this as a massless, rigid rod.
class b2MaxMinJoint : public b2Joint
{
public:

	b2Vec2 GetAnchor1() const;
	b2Vec2 GetAnchor2() const;

	b2Vec2 GetReactionForce(float32 inv_dt) const;
	float32 GetReactionTorque(float32 inv_dt) const;

	//--------------- Internals Below -------------------

	b2MaxMinJoint(const b2MaxMinJointDef* data, b2Settings* set);

	void InitVelocityConstraints(const b2TimeStep& step);
	void SolveVelocityConstraints(const b2TimeStep& step);
	bool SolvePositionConstraints(float32 baumgarte);

	b2Vec2 m_localAnchor1;
	b2Vec2 m_localAnchor2;
	b2Vec2 m_u;
	float32 m_impulse;
	float32 m_limitImpulse;
	float32 m_mass;		// effective mass for the constraint.
	float32 m_minLength;
	float32 m_maxLength;
	float32 m_length;
	
	b2LimitState m_state;
};

#endif
