#include "func.h"

bool hasAttachment(FrameObject * obj, Box2D* rdPtr)
{
    return obj->body >= 0;
}

void removeAttachment(FrameObject * obj, Box2D* rdPtr)
{
	if(rdPtr->bodies[obj->body])
		rdPtr->bodies[obj->body]->GetUserData()->RemObject(obj);
    obj->body = -1;
}

int getNullBody(Box2D* rdPtr)
{
	for(int i = 0; i < rdPtr->maxBodies; i++) {
		if(!rdPtr->bodies[i])
            return i;
	}
	return -1;
}

int getNullJoint(Box2D* rdPtr)
{
	for(int i = 0; i < rdPtr->maxJoints; i++) {
		if(!rdPtr->joints[i])
            return i;
	}
	return -1;
}

int getNullController(Box2D* rdPtr)
{
	for(int i = 0; i < rdPtr->maxControllers; i++) {
		if(!rdPtr->controllers[i])
            return i;
	}
	return -1;
}

b2Body* getBody(int i, Box2D* rdPtr)
{
	if(i == -1) {
		if(rdPtr->lastBody < 0)
            return NULL;
		return rdPtr->bodies[rdPtr->lastBody];
	}
	if (i < 0 || i >= rdPtr->maxBodies)
        return NULL;
	return rdPtr->bodies[i];
}

b2Joint* getJoint(int i, Box2D* rdPtr)
{
	if(i == -1) {
		if(rdPtr->lastJoint < 0)
            return NULL;
		return rdPtr->joints[rdPtr->lastJoint];
	}
	if(i == -1)
        return rdPtr->joints[rdPtr->lastJoint];
	if(i < 0 || i >= rdPtr->maxJoints)
        return NULL;
	return rdPtr->joints[i];
}

b2BodyDef* getBodyDef(int i, Box2D* rdPtr)
{
	if(i < 0 || i >= rdPtr->maxBodyDefs)
        return NULL;
	return rdPtr->bDefs[i];
}

b2JointDef* getJointDef(int i, Box2D* rdPtr)
{
	if(i < 0 || i >= rdPtr->maxJointDefs)
        return NULL;
	return rdPtr->jDefs[i];
}

b2ShapeDef* getShapeDef(int i, Box2D* rdPtr)
{
	if(i < 0 || i >= rdPtr->maxShapeDefs)
        return NULL;
	return rdPtr->sDefs[i];
}

b2Controller* getController(int i, Box2D* rdPtr)
{
	if (i == -1) {
		if(rdPtr->lastController < 0)
            return NULL;
		return rdPtr->controllers[rdPtr->lastController];
	}
	if (i < 0 || i >= rdPtr->maxControllers)
        return NULL;
	return rdPtr->controllers[i];
}

bool isBody(int i, Box2D* rdPtr)
{
	return i >= 0 && i < rdPtr->maxBodies;
}

bool isJoint(int i, Box2D* rdPtr)
{
	return i >= 0 && i < rdPtr->maxJoints;
}

bool isBodyDef(int i, Box2D* rdPtr)
{
	return i >= 0 && i < rdPtr->maxBodyDefs;
}

bool isJointDef(int i, Box2D* rdPtr)
{
	return i >= 0 && i < rdPtr->maxJointDefs;
}

bool isShapeDef(int i, Box2D* rdPtr)
{
	return i >= 0 && i < rdPtr->maxShapeDefs;
}

bool isController(int i, Box2D* rdPtr)
{
	return i >= 0 && i < rdPtr->maxControllers;
}

b2Shape* getShape(b2Body* b, int n)
{
	if(n < 0 || n >= b->GetUserData()->numShapes)
        return NULL;

	b2Shape* s = b->GetShapeList();

	for(int i = 0; i < n; i++)
		s = s->GetNext();

	return s;
}

b2Joint* getJoint(b2Body* b, int n)
{
	if(n < 0 || n >= b->GetUserData()->numJoints) return NULL;

	b2JointEdge* j = b->GetJointList();

	for(int i = 0; i < n; i++)
		j = j->next;

	return j->joint;
}

b2Controller* getController(b2Body* b, int n)
{
	if(n < 0) return NULL;

	b2ControllerEdge* c = b->GetControllerList();

	for(int i = 0; i < n; i++)
	{
		if(!c) return NULL;
		c = c->nextController;
	}

	return c->controller;
}

b2Body* getBody(b2Controller* c, int n)
{
	if(n < 0)
        return NULL;

	b2ControllerEdge* e = c->GetBodyList();

	for(int i = 0; i < n; i++) {
		if(!e)
            return NULL;
		e = e->nextBody;
	}

	return e->body;
}

float* parseString(const char * string, int &num)
{
	int len = strlen(string);

	num = 1;

	for(int i = 0; i < len; i++) {
		if(string[i] < 0) continue;
		if(parseDelim[string[i]] == 1) num++;
	}
	if(num % 2 == 1)
        return NULL; //Invalid Vertice Count
	float* coord = new float[num];
	int c = 0;
	sscanf(string,"%f",coord + c++);
	for(int i = 0; i < len; i++) {
		if(string[i] < 0)
            continue;
		if(parseDelim[string[i]] == 1) {
			sscanf(string+i+1,"%f",coord + c++);
		}
	}
	return coord;
}

void updateShapes(b2Body* b)
{
	int c = 0;
	b2Shape* s = b->GetShapeList();
	while(s)
	{
		if(s->GetUserData()->rdPtr == NULL)
		{
			s->GetUserData()->body = b->GetUserData()->ID;
			s->GetUserData()->rdPtr = b->GetUserData()->rdPtr;
		}
		s->GetUserData()->ID = c++;
		s = s->GetNext();
	}
	b->GetUserData()->numShapes = c;
}

void copyDef(b2ShapeDef* src, b2ShapeDef* &dest)
{
	if(dest) delete dest;
	if(src == NULL)
	{
		dest = NULL;
		return;
	}

	dest = (b2ShapeDef*)(new char[src->defSize()]);
	memcpy(dest,src,src->defSize());

	switch(src->type)
	{
	case e_polygonShape:
		((b2PolygonDef*)dest)->vertices = new b2Vec2[((b2PolygonDef*)src)->vertexMax];
		memcpy(((b2PolygonDef*)dest)->vertices,((b2PolygonDef*)src)->vertices,((b2PolygonDef*)src)->vertexMax*sizeof(b2Vec2));
		break;
	case e_edgeShape:
		((b2EdgeChainDef*)dest)->vertices = new b2Vec2[((b2EdgeChainDef*)src)->vertexMax];
		memcpy(((b2EdgeChainDef*)dest)->vertices,((b2EdgeChainDef*)src)->vertices,((b2EdgeChainDef*)src)->vertexMax*sizeof(b2Vec2));
		break;
	}
}

void copyDef(b2BodyDef* src, b2BodyDef* &dest)
{
	if(dest) delete dest;
	if(src == NULL)
	{
		dest = NULL;
		return;
	}

	dest = new b2BodyDef;
	memcpy(dest,src,sizeof(b2BodyDef));

	dest->shapes = new b2ShapeDef*[dest->numShapes];

	for(int i = 0; i < dest->numShapes; i++)
	{
		copyDef(src->shapes[i],dest->shapes[i]);
	}
}

void copyDef(b2JointDef* src, b2JointDef* &dest)
{
	if(dest) delete dest;
	if(src == NULL)
	{
		dest = NULL;
		return;
	}

	dest = (b2JointDef*)(new char[src->defSize()]);
	memcpy(dest,src,src->defSize());
}


bool setJointDefAnchor(b2JointDef* d, Box2D* rdPtr)
{
	b2Body* b = d->body1;
	b2Body* b2 = d->body2;

	switch(d->type)
	{
		case e_revoluteJoint:
		{
			b2RevoluteJointDef* def = (b2RevoluteJointDef*)d;
			switch(def->local1)
			{
			case 0:
				def->localAnchor1 = b->GetLocalPoint(def->anchor1);
				break;
			case 2:
				def->localAnchor1 = b->GetLocalPoint(b2->GetWorldPoint(def->anchor1));
				break;
			default:
				def->localAnchor1 = def->anchor1;
				break;
			}
			switch(def->local2)
			{
			case 0:
				def->localAnchor2 = b2->GetLocalPoint(def->anchor2);
				break;
			case 2:
				def->localAnchor2 = b2->GetLocalPoint(b->GetWorldPoint(def->anchor2));
				break;
			default:
				def->localAnchor2 = def->anchor2;
				break;
			}
		}
		break;
		case e_prismaticJoint:
		{
			b2PrismaticJointDef* def = (b2PrismaticJointDef*)d;
			switch(def->local1)
			{
			case 0:
				def->localAnchor1 = b->GetLocalPoint(def->anchor1);
				break;
			case 2:
				def->localAnchor1 = b->GetLocalPoint(b2->GetWorldPoint(def->anchor1));
				break;
			default:
				def->localAnchor1 = def->anchor1;
				break;
			}
			switch(def->local2)
			{
			case 0:
				def->localAnchor2 = b2->GetLocalPoint(def->anchor2);
				break;
			case 2:
				def->localAnchor2 = b2->GetLocalPoint(b->GetWorldPoint(def->anchor2));
				break;
			default:
				def->localAnchor2 = def->anchor2;
				break;
			}
			switch(def->alocal)
			{
			case 1:
				def->localAxis1.Set(cos(def->angle-b->GetAngle()),sin(def->angle-b->GetAngle()));
				break;
			case 2:
				def->localAxis1.Set(cos(def->angle-b2->GetAngle()),sin(def->angle-b2->GetAngle()));
				break;
			default:
				def->localAxis1.Set(cos(def->angle),sin(def->angle));
				break;
			}
		}
		break;
		case e_lineJoint:
		{
			b2LineJointDef* def = (b2LineJointDef*)d;
			switch(def->local1)
			{
			case 0:
				def->localAnchor1 = b->GetLocalPoint(def->anchor1);
				break;
			case 2:
				def->localAnchor1 = b->GetLocalPoint(b2->GetWorldPoint(def->anchor1));
				break;
			default:
				def->localAnchor1 = def->anchor1;
				break;
			}
			switch(def->local2)
			{
			case 0:
				def->localAnchor2 = b2->GetLocalPoint(def->anchor2);
				break;
			case 2:
				def->localAnchor2 = b2->GetLocalPoint(b->GetWorldPoint(def->anchor2));
				break;
			default:
				def->localAnchor2 = def->anchor2;
				break;
			}
			switch(def->alocal)
			{
			case 1:
				def->localAxis1.Set(cos(def->angle-b->GetAngle()),sin(def->angle-b->GetAngle()));
				break;
			case 2:
				def->localAxis1.Set(cos(def->angle-b2->GetAngle()),sin(def->angle-b2->GetAngle()));
				break;
			default:
				def->localAxis1.Set(cos(def->angle),sin(def->angle));
				break;
			}
		}
		break;
		case e_distanceJoint:
		{
			b2DistanceJointDef* def = (b2DistanceJointDef*)d;
			switch(def->local1)
			{
			case 0:
				def->localAnchor1 = b->GetLocalPoint(def->anchor1);
				break;
			case 2:
				def->localAnchor1 = b->GetLocalPoint(b2->GetWorldPoint(def->anchor1));
				break;
			default:
				def->localAnchor1 = def->anchor1;
				break;
			}
			switch(def->local2)
			{
			case 0:
				def->localAnchor2 = b2->GetLocalPoint(def->anchor2);
				break;
			case 2:
				def->localAnchor2 = b2->GetLocalPoint(b->GetWorldPoint(def->anchor2));
				break;
			default:
				def->localAnchor2 = def->anchor2;
				break;
			}
			switch(def->abslen)
			{
			case 0:
				def->length = def->alength + (b->GetWorldPoint(def->localAnchor1) - b2->GetWorldPoint(def->localAnchor2)).Length();
				break;
			default:
				def->length = def->alength;
				break;
			}
		}
		break;
		case e_mouseJoint:
		{
			b2MouseJointDef* def = (b2MouseJointDef*)d;
			switch(def->local)
			{
			case 1:
				def->target = b2->GetWorldPoint(def->anchor);
				break;
			default:
				def->target = def->anchor;
				break;
			}
		}
		break;
		case e_gearJoint:
		{
			b2GearJointDef* def = (b2GearJointDef*)d;
			switch(def->local1)
			{
			case 1:
				{
					b2JointEdge* je = b->GetJointList();
					for(int i = 0; i < def->joint1n; i++)
					{
						if(!je) return false;
						je = je->next;
					}
					if(!je) return false;
					def->joint1 = je->joint;
				}
				break;
			default:
				def->joint1 = getJoint(def->joint1n,rdPtr);
				if(!def->joint1) return false;
				break;
			}
			switch(def->local2)
			{
			case 1:
				{
					b2JointEdge* je = b2->GetJointList();
					for(int i = 0; i < def->joint2n; i++)
					{
						if(!je) return false;
						je = je->next;
					}
					if(!je) return false;
					def->joint2 = je->joint;
				}
				break;
			default:
				def->joint2 = getJoint(def->joint2n,rdPtr);
				if(!def->joint2) return false;
				break;
			}
		}
		break;
		case e_pulleyJoint:
		{
			b2PulleyJointDef* def = (b2PulleyJointDef*)d;
			switch(def->local1)
			{
			case 0:
				def->localAnchor1 = b->GetLocalPoint(def->anchor1);
				break;
			case 2:
				def->localAnchor1 = b->GetLocalPoint(b2->GetWorldPoint(def->anchor1));
				break;
			default:
				def->localAnchor1 = def->anchor1;
				break;
			}
			switch(def->local2)
			{
			case 0:
				def->localAnchor2 = b2->GetLocalPoint(def->anchor2);
				break;
			case 2:
				def->localAnchor2 = b2->GetLocalPoint(b->GetWorldPoint(def->anchor2));
				break;
			default:
				def->localAnchor2 = def->anchor2;
				break;
			}
			switch(def->glocal1)
			{
			case 1:
				def->groundAnchor1 = b->GetWorldPoint(def->ganchor1);
				break;
			case 2:
				def->groundAnchor1 = b2->GetWorldPoint(def->ganchor1);
				break;
			default:
				def->groundAnchor1 = def->ganchor1;
				break;
			}
			switch(def->glocal2)
			{
			case 1:
				def->groundAnchor2 = b2->GetWorldPoint(def->ganchor2);
				break;
			case 2:
				def->groundAnchor2 = b->GetWorldPoint(def->ganchor2);
				break;
			default:
				def->groundAnchor2 = def->ganchor2;
				break;
			}
			switch(def->mlocal1)
			{
			case 0:
				def->maxLength1 = def->mlength1 + (b->GetWorldPoint(def->localAnchor1) - def->groundAnchor1).Length();
				break;
			default:
				def->maxLength1 = def->mlength1;
				break;
			}
			switch(def->mlocal2)
			{
			case 0:
				def->maxLength2 = def->mlength2 + (b2->GetWorldPoint(def->localAnchor2) - def->groundAnchor2).Length();
				break;
			default:
				def->maxLength2 = def->mlength2;
				break;
			}
		}
		break;
	}
	return true;
}

