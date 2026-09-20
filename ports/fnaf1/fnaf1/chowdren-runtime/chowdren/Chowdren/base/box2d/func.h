#ifndef CHOWDREN_BOX2D_FUNC_H
#define CHOWDREN_BOX2D_FUNC_H

inline FrameObject* oParam()
{
    return NULL;
}

inline int uParam()
{
    return 0;
}

inline int lParam()
{
    return 0;
}

inline float fParam()
{
    return 0.0f;
}

inline const std::string sParam()
{
    return "";
}

inline int xlParam()
{
    return 0;
}

inline std::string xsParam()
{
    return "";
}

inline float xfParam()
{
    return 0.0;
}

bool hasAttachment(FrameObject* obj, Box2D* rdPtr);
void removeAttachment(FrameObject* obj, Box2D* rdPtr);

int getNullBody(Box2D* rdPtr);
int getNullJoint(Box2D* rdPtr);
int getNullController(Box2D* rdPtr);

b2Body* getBody(int i, Box2D* rdPtr);
b2Joint* getJoint(int i, Box2D* rdPtr);
b2BodyDef* getBodyDef(int i, Box2D* rdPtr);
b2JointDef* getJointDef(int i, Box2D* rdPtr);
b2ShapeDef* getShapeDef(int i, Box2D* rdPtr);
b2Controller* getController(int i, Box2D* rdPtr);

bool isBody(int i, Box2D* rdPtr);
bool isJoint(int i, Box2D* rdPtr);
bool isBodyDef(int i, Box2D* rdPtr);
bool isJointDef(int i, Box2D* rdPtr);
bool isShapeDef(int i, Box2D* rdPtr);
bool isController(int i, Box2D* rdPtr);

b2Shape* getShape(b2Body* b, int n);
b2Joint* getJoint(b2Body* b, int n);
b2Controller* getController(b2Body* b, int n);
b2Body* getBody(b2Controller* c, int n);

bool setJointDefAnchor(b2JointDef* d, Box2D* rdPtr);

void updateShapes(b2Body* b);

void copyDef(b2ShapeDef* src, b2ShapeDef* &dest);
void copyDef(b2BodyDef* src, b2BodyDef* &dest);
void copyDef(b2JointDef* src, b2JointDef* &dest);

static bool parseDelim[128] = 
{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
};

#define delim parseDelim

float* parseString(const char * string, int &num);

struct extendedParam
{
	union
	{
		b2Body* p1_body;
		b2Shape* p1_shape;
		long p1_long;
	};
	union
	{
		b2Body* p2_body;
		b2Shape* p2_shape;
		long p2_long;
	};
	union
	{
		b2Body* p3_body;
		b2Shape* p3_shape;
		long p3_long;
	};
	union
	{
		b2Body* p4_body;
		b2Shape* p4_shape;
		long p4_long;
	};
};

#endif // CHOWDREN_BOX2D_FUNC_H
