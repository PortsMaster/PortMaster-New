#ifndef CHOWDREN_BOX2DEXT_H
#define CHOWDREN_BOX2DEXT_H

#include "../frameobject.h"

class Callback;
class BoundaryListener;
class ContactListener;
class DestructionListener;
class ContactFilter;
class DebugDraw;

#include "Box2D.h"
#include "callback.h"

#define round(x) floor(x+0.5)

#define RAD_TO_DEG -57.295779513082320876798154814105f
#define DEG_TO_RAD -0.017453292519943295769236907684886f
#define M_PI2 6.283185307179586476925286766559f
#define MAX_OBJECTS 2000

bool AssertFail(const char* expression, const char* file, int line);
bool AssertFail2(const char* message);
void Debug(const char* str, ...);
void Debug(int d);
void Debug(float d);

struct RayResult
{
    RayResult()
    : shapes(NULL)
    {
    }

    void Init(int n)
    {
        if (shapes)
            delete[] shapes;
        shapes = new b2Shape*[n];
        numShapes = n;
        hits = 0;
        normal.SetZero();
        point.SetZero();
    }

    ~RayResult()
    {
        if (shapes)
            delete[] shapes;
    }
    b2Shape** shapes;
    int numShapes;
    b2Vec2 point;
    b2Vec2 normal;
    rayUserData ud;
    int hits;
};

class Box2D : public FrameObject
{
public:
    FRAMEOBJECT_HEAD(Box2D)

    int maxBodies;
    int maxJoints;
    int maxBodyDefs;
    int maxShapeDefs;
    int maxJointDefs;
    int maxControllers;
    Callback* callbacks;
    Callback* lastcall;
    RayResult ray;
    int lastBody;
    int lastJoint;
    int lastController;
    b2Body** bodies;
    b2Joint** joints;
    b2BodyDef** bDefs;
    b2JointDef** jDefs;
    b2ShapeDef** sDefs;
    b2Controller** controllers;
    BoundaryListener* BL;
    ContactListener* CL;
    DestructionListener* DL;
    ContactFilter* CF;
    DebugDraw* DD;
    b2World* world;
    int eventBody;
    int eventJoint;
    int eventShape;
    int enumBody;
    int enumJoint;
    int enumShape;
    int enumController;
    CollData collData;
    b2Vec2 gravity;
    b2Vec2 lastConv;
    b2AABB bounds;
    float scale;
    b2BodyDef* curBodyDef;
    b2JointDef* curJointDef;
    b2ShapeDef* curShapeDef;
    bool allowSleep;
    int posIterations;
    int velIterations;
    float timestep;
    bool WarmStart;
    bool PosCorrection;
    bool CCD;
    bool floatAngles;
    bool autoUpdate;
    b2Settings settings;
    char collReg[32][32];
    char collMode;
    char* tempdata;

    Box2D(int x, int y, int type_id);
    ~Box2D();
    void initialize_box2d();
    void generate_event(int id);
    void update_world();
    void update();
    void create_body(float x, float y, float angle);
    void create_body(FrameObject * obj, float x, float y, int rot, int dest);
    void create_shape(FrameObject * obj, const std::string & value);
    void create_shape(FrameObject * obj, const std::string & value,
                      float x, float y, float density, float friction,
                      float elasticity);
    void create_mouse_joint(FrameObject * obj, float x, float y,
                            float max_force);
    void create_distance_joint(FrameObject * obj2, FrameObject * obj,
                               float x2, float y2, int local2,
                               float x, float y, int local,
                               int collide);
    void create_box(FrameObject * obj, float width, float height,
                    float x, float y, float angle, float density,
                    float friction, float elasticity);
    void create_edge_chain(int id, const std::string & v, int loop,
                           float x, float y, float friction, float elasticity);
    void set_auto_update(int v);
    void remove_joint(int id);
    void remove_joint(int body_id, int id);
    void remove_body(FrameObject * obj);
    void remove_shape(FrameObject * obj, int shape_id);
    void set_joint_target(int id, float x, float y);
    void set_linear_damping(FrameObject * obj, float damping);
    void reset_world();
    static void draw_debug();
};

#endif // CHOWDREN_BOX2DEXT_H
