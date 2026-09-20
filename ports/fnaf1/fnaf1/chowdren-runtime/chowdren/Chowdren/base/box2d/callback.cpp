#include "box2dext.h"

void Callback::Do(Box2D* rdPtr)
{

}

void BoundaryCallback::Do(Box2D* rdPtr)
{
	rdPtr->eventBody = bodyID;
	rdPtr->generate_event(3);
	rdPtr->eventBody = -1;
}

void LostAttachmentCallback::Do(Box2D* rdPtr)
{
	rdPtr->eventBody = bodyID;
	rdPtr->generate_event(71);
	rdPtr->eventBody = -1;
}


void SleepCallback::Do(Box2D* rdPtr)
{
	rdPtr->eventBody = bodyID;
	rdPtr->generate_event(40);
	rdPtr->eventBody = -1;
}

void WakeCallback::Do(Box2D* rdPtr)
{
	rdPtr->eventBody = bodyID;
	rdPtr->generate_event(41);
	rdPtr->eventBody = -1;
}

void JointDieCallback::Do(Box2D* rdPtr)
{
	rdPtr->eventJoint = jointID;
	rdPtr->generate_event(4);
	rdPtr->eventJoint = -1;
}

void CollideCallback::Do(Box2D* rdPtr)
{
	rdPtr->collData = data;

	rdPtr->generate_event(cndOffset);
	rdPtr->generate_event(cndOffset+1);
	rdPtr->generate_event(cndOffset+2);
	
	rdPtr->collData.body1 = data.body2;
	rdPtr->collData.body2 = data.body1;
	rdPtr->collData.shape1 = data.shape2;
	rdPtr->collData.shape2 = data.shape1;
	rdPtr->collData.type1 = data.type2;
	rdPtr->collData.type2 = data.type1;
	rdPtr->collData.angle = data.angle + 180;
	rdPtr->collData.impulse.x = data.impulse.x*-1;
	
	rdPtr->generate_event(cndOffset);
	rdPtr->generate_event(cndOffset+1);
	rdPtr->generate_event(cndOffset+2);
}

void addCallback(Callback* c, Box2D* rdPtr)
{
	if (rdPtr->lastcall)
		rdPtr->lastcall->Next = c;
	else
		rdPtr->callbacks = c;
	rdPtr->lastcall = c;
}
