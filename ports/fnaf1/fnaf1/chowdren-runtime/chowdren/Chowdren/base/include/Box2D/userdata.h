#ifndef CHOWDREN_BOX2D_USERDATA_H
#define CHOWDREN_BOX2D_USERDATA_H

class Box2D;
class FrameObject;

struct Attachment
{
	Attachment();
	~Attachment();

	Box2D* rdPtr;
    FrameObject * obj;
	float rotOff;
	b2Vec2 offset;
	char rotation;
	char dest;
	Attachment* Next;
	Attachment* Prev;
};

struct bodyUserData
{
	bodyUserData();

	void AddObject(FrameObject * obj, b2Vec2 offset, int rot, int dest,
                   float roff);
	void RemObject(FrameObject * obj);
	Attachment* GetAttachment(FrameObject * obj);
	void RemAttachment(Attachment* &a);
	void BodyDie();

	Attachment* attachment;

	Box2D* rdPtr;
	int numJoints;
	int numShapes;
	int ID;
	bool customMass;
	bool sleepflag;
};

struct jointUserData
{
	jointUserData();

	int body1;
	int body2;
	int ID;
};

struct shapeUserData
{
	shapeUserData();

	Box2D* rdPtr;
	char collType;
	int body;
	int ID;
};

struct rayUserData
{
	rayUserData();

	bool solidShapes;
	int collType;
	short mask;
};

#endif // CHOWDREN_BOX2D_USERDATA_H
