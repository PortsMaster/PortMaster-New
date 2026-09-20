#include "box2dext.h"

bodyUserData::bodyUserData()
{
	attachment = NULL;
	rdPtr = NULL;
	numJoints = 0;
	numShapes = 0;
	ID = -1;
	customMass = false;
	sleepflag = false;
}

void bodyUserData::BodyDie()
{
	Attachment* a = attachment;
	while(a) {
		Attachment* b = a->Next;
		delete a;
		a = b;
	}
	attachment = NULL;
}

void bodyUserData::AddObject(FrameObject * obj, b2Vec2 offset, int rot,
                             int dest, float roff)
{
	Attachment* a = new Attachment();

	a->rdPtr = rdPtr;
	a->obj = obj;
	a->offset = offset;
	a->rotation = rot;
	a->dest = dest;
	a->rotOff = roff;

	a->Next = attachment;
	if(attachment)
		attachment->Prev = a;
	attachment = a;

    obj->body = ID;
}

void bodyUserData::RemObject(FrameObject * obj)
{
	Attachment* a = attachment;
	while(a) {
		if (a->obj == obj) {
			if(a->Next)
                a->Next->Prev = a->Prev;
			if(a->Prev)
                a->Prev->Next = a->Next;
			Attachment* c = a->Next;
			a->dest = 0;
			delete a;
			if(attachment == a)
                attachment = c;
			a = c;
		} else
			a = a->Next;
	}
}

Attachment* bodyUserData::GetAttachment(FrameObject * obj)
{
	for (Attachment* a = attachment; a != NULL; a = a->Next) {
		if(a->obj == obj) {
			return a;
		}
	}
	return NULL;
}

void bodyUserData::RemAttachment(Attachment* &a)
{
	if(a->Prev)
        a->Prev->Next = a->Next;
	if(a->Next)
        a->Next->Prev = a->Prev;

	Attachment* c = a;
	c->dest = 0;
	a = a->Next;
	delete c;
}

Attachment::Attachment()
{
	rdPtr = NULL;
    obj = NULL;
	rotOff = 0;
	offset.SetZero();
	rotation = 0;
	dest = 0;
	Prev = NULL;
	Next = NULL;
}

Attachment::~Attachment()
{
	if(dest == 1 && obj != NULL) {
        obj->destroy();
	}
}

shapeUserData::shapeUserData()
{
	rdPtr = NULL;
	collType = 0;
	body = -1;
	ID = -1;
}

jointUserData::jointUserData()
{
	body1 = -1;
	body2 = -1;
	ID = -1;
}

rayUserData::rayUserData()
{
	solidShapes = false;
	collType = -1;
	mask = -1;
}
