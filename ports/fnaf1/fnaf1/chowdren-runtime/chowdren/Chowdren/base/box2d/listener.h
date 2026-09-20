#ifndef CHOWDREN_BOX2D_LISTENER_H
#define CHOWDREN_BOX2D_LISTENER_H

#include "Box2D.h"

class Box2D;

class DestructionListener : public b2DestructionListener
{
public:
	void SayGoodbye(b2Shape * shape);
	void SayGoodbye(b2Joint* joint);

	Box2D* rdPtr;
};

class BoundaryListener : public b2BoundaryListener	
{
public:
	void Violation(b2Body* body);

	Box2D* rdPtr;
};

class ContactListener : public b2ContactListener
{
public:
	bool ContactStart(b2Contact* contact);
	void ContactStop(b2Contact* contact);
	void ContactPointAdd(b2Contact* contact, const b2ContactPoint* point);
	void ContactPointPersist(b2Contact* contact, const b2ContactPoint* point);
	void ContactPointRemove(b2Contact* contact, const b2ContactPoint* point);
	void ContactPointResponse(b2Contact* contact, const b2ContactResult* point);

	Box2D* rdPtr;
};

class ContactFilter : public b2ContactFilter
{
public:
	bool ShouldCollide(b2Shape* shape1, b2Shape* shape2);
	bool RayCollide(rayUserData* userData, b2Shape* b2Shape);
	
	Box2D* rdPtr;
};

class DebugDraw : public b2DebugDraw
{
public:
    Box2D* rdPtr;
    
	DebugDraw() {}
	~DebugDraw() {}
	void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);
	void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);
	void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);
	void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);
	void DrawXForm(const b2XForm& xf);
};

#endif // CHOWDREN_BOX2D_LISTENER_H
