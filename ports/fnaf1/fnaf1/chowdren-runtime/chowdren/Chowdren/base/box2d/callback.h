#ifndef _callback_h_
#define _callback_h_

class Box2D;

class Callback
{
public:
	virtual void Do(Box2D* rdPtr);
	Callback():Next(NULL){}
	virtual ~Callback(){}

	Callback* Next;
};

class BoundaryCallback : public Callback
{
public:
	void Do(Box2D* rdPtr);
	int bodyID;
};

class LostAttachmentCallback : public Callback
{
public:
	void Do(Box2D* rdPtr);
	int bodyID;
};

class SleepCallback : public Callback
{
public:
	void Do(Box2D* rdPtr);
	int bodyID;
};

class WakeCallback : public Callback
{
public:
	void Do(Box2D* rdPtr);
	int bodyID;
};

class JointDieCallback : public Callback
{
public:
	void Do(Box2D* rdPtr);
	int jointID;
};

struct CollData
{
	CollData()
	{
		collPoint.SetZero();
		angle = 0.0f;
		impulse.SetZero();
		velocity.SetZero();
		separation = 0.0f;
		friction = 0.0f;
		restitution = 0.0f;
	}
	//Generic
	int body1;
	int body2;
	int type1;
	int type2;
	int shape1;
	int shape2;
	b2Vec2 collPoint;
	float angle;

	//Result
	b2Vec2 impulse;

	//Point
	b2Vec2 velocity;
	float separation;
	float friction;
	float restitution;
};

class CollideCallback : public Callback
{
public:
	CollideCallback(int cnd){cndOffset = cnd;}
	void Do(Box2D* rdPtr);

	CollData data;
	int cndOffset;
};

void addCallback(Callback* c, Box2D* rdPtr);

#endif
