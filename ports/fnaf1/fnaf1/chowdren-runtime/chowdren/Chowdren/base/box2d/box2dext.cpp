#include "../frameobject.h"
#include "../mathcommon.h"

#include <iostream>
#include "listener.h"
#include "parser.h"
#include "listener.cpp"
#include "callback.cpp"
#include "userdata.cpp"
#include "func.cpp"
#include "parser.cpp"

static b2World * global_world = NULL;
static DebugDraw * global_debug_draw = NULL;

bool AssertFail(const char* expression, const char* file, int line)
{
    std::cout << "Assertion failed at: " << expression << ", file " << file
        << ", line " << line << std::endl;
    return true;
}

bool AssertFail2(const char* message)
{
    std::cout << message << std::endl;
    return true;
}

void Debug(const char* str, ...)
{
    char buffer[256];
    if (!str)
        return;

    va_list ptr;
    va_start(ptr, str);
    vsnprintf(buffer, 256, str, ptr);
    va_end(ptr);

    std::cout << buffer << std::endl;
}

void Debug(int d)
{
    Debug("%d",d);
}

void Debug(float d)
{
    Debug("%f",d);
}

// Box2D

Box2D::Box2D(int x, int y, int type_id)
: FrameObject(x, y, type_id)
{
}

Box2D::~Box2D()
{
  for(int i = 0; i < maxBodyDefs; i++)
    {
        if (!bDefs[i]) continue;
        delete bDefs[i];
    }
    for(int i = 0; i < maxJointDefs; i++)
    {
        if (!jDefs[i]) continue;
        delete jDefs[i];
    }
    for(int i = 0; i < maxShapeDefs; i++)
    {
        if (!sDefs[i]) continue;
        delete sDefs[i];
    }

    if (world) {
        delete world;
        global_world = NULL;
    }
    if (bodies)
        delete[] bodies;
    if (joints)
        delete[] joints;
    if (bDefs)
        delete[] bDefs;
    if (jDefs)
        delete[] jDefs;
    if (sDefs)
        delete[] sDefs;
    if (controllers)
        delete[] controllers;
    if (BL)
        delete BL;
    if (CL)
        delete CL;
    if (DL)
        delete DL;
    if (CF)
        delete CF;
    if (DD)
        delete DD;
    if (tempdata)
        delete[] tempdata;

    if (callbacks) {
        while(callbacks) {
            callbacks->Do(this);
            Callback* c = callbacks->Next;
            delete callbacks;
            callbacks = c;
        }
        lastcall = NULL;
    }
}

void Box2D::initialize_box2d()
{
    tempdata = NULL;
    ray.ud.collType = -1;
    ray.ud.mask = -1;

    callbacks = NULL;
    lastcall = NULL;

    bodies = new b2Body*[maxBodies];
    joints = new b2Joint*[maxJoints];
    bDefs = new b2BodyDef*[maxBodyDefs];
    jDefs = new b2JointDef*[maxJointDefs];
    sDefs = new b2ShapeDef*[maxShapeDefs];
    controllers = new b2Controller*[maxControllers];

    memset(bodies, 0, maxBodies*sizeof(void*));
    memset(joints, 0, maxJoints*sizeof(void*));
    memset(bDefs, 0, maxBodyDefs*sizeof(void*));
    memset(jDefs, 0, maxJointDefs*sizeof(void*));
    memset(sDefs, 0, maxShapeDefs*sizeof(void*));
    memset(controllers, 0, maxControllers*sizeof(void*));

    BL = new BoundaryListener;
    CL = new ContactListener;
    DL = new DestructionListener;
    CF = new ContactFilter;
    DD = new DebugDraw;
    global_debug_draw = DD;
    BL->rdPtr = this;
    CL->rdPtr = this;
    DL->rdPtr = this;
    CF->rdPtr = this;
    DD->rdPtr = this;

    memset(collReg,0,sizeof(char)*16*16);

    eventBody = -2;
    eventJoint = -2;
    eventShape = -2;
    memset(&collData,0,sizeof(CollData));

    world = new b2World(bounds,gravity,allowSleep, &settings);
    global_world = world;
    world->SetBoundaryListener(BL);
    world->SetContactListener(CL);
    world->SetDestructionListener(DL);
    world->SetContactFilter(CF);

    DD->SetFlags(b2DebugDraw::e_shapeBit | b2DebugDraw::e_jointBit |
                 b2DebugDraw::e_coreShapeBit | b2DebugDraw::e_aabbBit |
                 b2DebugDraw::e_obbBit | b2DebugDraw::e_pairBit |
                 b2DebugDraw::e_centerOfMassBit);
    world->SetDebugDraw(DD);

    world->GetGroundBody()->GetUserData()->ID = -2;

    curBodyDef = NULL;
    curJointDef = NULL;
    curShapeDef = NULL;

    lastBody = -2;
    lastJoint = -2;
    lastController = -2;
    enumBody = -2;
    enumJoint = -2;
    enumShape = -2;
    enumController = -2;
}

void Box2D::generate_event(int id)
{
    // std::cout << "Generate event " << id << std::endl;
}

void Box2D::create_body(FrameObject * obj, float x, float y, int rot, int dest)
{
    if (!obj)
        return;

    if (hasAttachment(obj, this))
        removeAttachment(obj, this);

    int n = getNullBody(this);
    if (n == -1)
        return;

    b2BodyDef def;
    def.userData.ID = n;
    def.userData.rdPtr = this;
    def.userData.AddObject(obj, b2Vec2(-x/scale,-y/scale), rot, dest, 0);
    if (floatAngles)
        def.angle = obj->get_angle() * DEG_TO_RAD;
    else
        def.angle = int(obj->get_angle()) * DEG_TO_RAD;
    def.position.Set((float(obj->x) + x)/scale,
                     (float(obj->y) + y)/scale);
    def.fixedRotation = rot == -1;


    if ((bodies[n] = world->CreateBody(&def)) == NULL) {
        def.userData.BodyDie();
        lastBody = -2;
        return;
    }

    lastBody = n;
}

void Box2D::create_body(float x, float y, float angle)
{
    int n = getNullBody(this);
    if(n == -1)
        return;

    b2BodyDef def;
    def.userData.ID = n;
    def.userData.rdPtr = this;
    def.position.Set(x/scale, y/scale);
    def.angle = angle*DEG_TO_RAD;

    if((bodies[n] = world->CreateBody(&def)) == NULL) {
        //Failed to create body
        lastBody = -2;
        return;
    }

    lastBody = n;
}

void Box2D::create_shape(FrameObject * obj, const std::string & value)
{
    if (!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    b2Body* b = getBody(n, this);

    if (!b)
        return;

    b2ShapeDef* def;
    char * v = (char*)value.c_str();
    if (!Parser::parseShape(v, def, this)) {
        Debug("Error when parsing string!");
        return;
    }

    if(!b->CreateShape(def)) {
        delete def;
        return;
    }

    delete def;

    updateShapes(b);

    if(!b->GetUserData()->customMass)
        b->SetMassFromShapes();
}

void Box2D::create_shape(FrameObject * obj, const std::string & value,
                         float x, float y, float density, float friction,
                         float elasticity)
{
    char * verts = (char*)value.c_str();
    if (!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    int num;
    float* coord = parseString(verts, num);
    if (!coord)
        return;

    b2PolygonDef def(num/2);
    def.vertexCount = num/2;
    for (int i = 0; i < num/2; i++) {
        def.vertices[i].Set((coord[i*2]+x)/scale,
                            (coord[i*2+1]+y)/scale);
    }
    delete[] coord;
    def.density = density;
    def.friction = friction;
    def.restitution = elasticity;

    if (!bodies[n]->CreateShape(&def))
        return;

    updateShapes(bodies[n]);

    if (!bodies[n]->GetUserData()->customMass)
        bodies[n]->SetMassFromShapes();
}

void Box2D::set_joint_target(int id, float x, float y)
{
    b2MouseJoint* j = (b2MouseJoint*)getJoint(id, this);

    if(!j)
        return;

    if(j->GetType() != e_mouseJoint)
        return;

    j->SetTarget(b2Vec2(x/scale, y/scale));
}

void Box2D::create_mouse_joint(FrameObject * obj, float x, float y,
                               float max_force)
{
    if (!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    b2Body* b = getBody(n, this);

    if(!b)
        return;

    int j = getNullJoint(this);
    if(j == -1)
        return;

    b2MouseJointDef def;
    def.target.Set(x/scale, y/scale);
    def.body1 = world->GetGroundBody();
    def.body2 = b;
    def.maxForce = max_force;

    def.userData.body1 = -2;
    def.userData.body2 = n;
    def.userData.ID = j;

    if((joints[j] = world->CreateJoint(&def)) == NULL) {
        lastJoint = -2;
        return;
    }

    b->GetUserData()->numJoints++;
    lastJoint = j;
}

void Box2D::create_distance_joint(FrameObject * obj2, FrameObject * obj,
                                  float x2, float y2, int local2,
                                  float x, float y, int local,
                                  int collide)
{
    if(!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    if (!obj2)
        return;

    if (!hasAttachment(obj2, this))
        return;

    int n2 = obj2->body;

    b2Body* b = getBody(n, this);
    b2Body* b2 = getBody(n2, this);

    if(!b || !b2)
        return;

    int j = getNullJoint(this);
    if(j == -1)
        return;

    b2Vec2 anchor(x/scale, y/scale);

    if(local == 1)
        anchor = b->GetWorldPoint(anchor);

    b2Vec2 anchor2(x2/scale, y2/scale);

    if(local2 == 1)
        anchor2 = b2->GetWorldPoint(anchor2);

    b2DistanceJointDef def;
    def.Initialize(b, b2, anchor, anchor2);
    def.collideConnected = collide != 0;

    def.userData.body1 = n;
    def.userData.body2 = n2;
    def.userData.ID = j;

    if((joints[j] = world->CreateJoint(&def)) == NULL) {
        lastJoint = -2;
        return;
    }

    b->GetUserData()->numJoints++;
    b2->GetUserData()->numJoints++;

    lastJoint = j;
}

void Box2D::create_box(FrameObject * obj, float width, float height,
                       float x, float y, float angle, float density,
                       float friction, float elasticity)
{
    if(!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    b2Body* b = getBody(n, this);

    if (!b)
        return;

    b2PolygonDef def(4);
    def.SetAsBox((width/2)/scale, (height/2)/scale, b2Vec2(x/scale, y/scale),
                 angle*DEG_TO_RAD);
    def.density = density;
    def.friction = friction;
    def.restitution = elasticity;

    if (!b->CreateShape(&def)) {
        return;
    }

    updateShapes(b);

    if (!b->GetUserData()->customMass)
        b->SetMassFromShapes();
}

void Box2D::create_edge_chain(int id, const std::string & v, int loop,
                              float x, float y, float friction,
                              float elasticity)
{
    char * verts = (char*)v.c_str();

    b2Body* b = getBody(id, this);

    if(!b)
        return;

    int num;
    float* coord = parseString(verts, num);
    if(!coord)
        return;

    b2EdgeChainDef def(num/2);
    def.vertexCount = num/2;
    for(int i = 0; i < num/2; i++) {
        def.vertices[i].Set((coord[i*2]+x)/scale,
                            (coord[i*2+1]+y)/scale);
    }
    delete[] coord;
    def.isALoop = loop != 0;
    def.density = 0;
    def.friction = friction;
    def.restitution = elasticity;

    if(!b->CreateShape(&def)) {
        return;
    }

    updateShapes(b);

    if(!b->GetUserData()->customMass)
        b->SetMassFromShapes();
}

void Box2D::set_linear_damping(FrameObject * obj, float damping)
{
    if(!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    b2Body* b = getBody(n, this);

    if(!b)
        return;

    b->SetLinearDamping(damping);
}

void Box2D::set_auto_update(int v)
{
    autoUpdate = v == 1;
}

void Box2D::remove_body(FrameObject * obj)
{
    if (!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    b2Body* b = getBody(n, this);

    if(!b)
        return;

    world->DestroyBody(b);
    bodies[n] = NULL;
}

void Box2D::remove_shape(FrameObject * obj, int shape_id)
{
    if (!obj)
        return;

    if (!hasAttachment(obj, this))
        return;

    int n = obj->body;

    b2Body* b = getBody(n, this);

    if(!b)
        return;

    if(shape_id == -1) {
        while(b->GetShapeList()) {
            b->DestroyShape(b->GetShapeList());
        }
        b->GetUserData()->numShapes = 0;
        return;
    }

    if(shape_id < 0 || shape_id >= b->GetUserData()->numShapes)
        return;

    b2Shape* sa = b->GetShapeList();
    for(int i = 0; i < shape_id; i++)
        sa = sa->GetNext();
    b2Shape* sb = sa->GetNext();

    b->DestroyShape(sa);

    while(sb) {
        sb->GetUserData()->ID--;
        sb = sb->GetNext();
    }
    b->GetUserData()->numShapes--;
}

void Box2D::remove_joint(int id)
{
    b2Joint* j = getJoint(id, this);

    if(!j) return;

    b2Body* b = getBody(j->GetUserData()->body1, this);
    b2Body* b2 = getBody(j->GetUserData()->body2, this);

    if(b)
        b->GetUserData()->numJoints--;
    if(b2)
        b2->GetUserData()->numJoints--;

    world->DestroyJoint(j);
    joints[id] = NULL;
}

void Box2D::remove_joint(int body_id, int id)
{
    // is this a bug in the original Box2D code???
    b2Body* jb = getBody(body_id, this);
    b2Joint* j = getJoint(jb, body_id);

    if(!j)
        return;

    int n = j->GetUserData()->ID;

    b2Body* b = getBody(j->GetUserData()->body1, this);
    b2Body* b2 = getBody(j->GetUserData()->body2, this);

    if(b)
        b->GetUserData()->numJoints--;
    if(b2)
        b2->GetUserData()->numJoints--;

    world->DestroyJoint(j);

    joints[n] = NULL;
}

void Box2D::reset_world()
{
    for(int i = 0; i < maxBodyDefs; i++) {
        if(!bDefs[i])
            continue;
        delete bDefs[i];
    }

    for(int i = 0; i < maxJointDefs; i++) {
        if(!jDefs[i])
            continue;
        delete jDefs[i];
    }

    for(int i = 0; i < maxShapeDefs; i++) {
        if(!sDefs[i])
            continue;
        delete sDefs[i];
    }

    if(world)
        delete world;

    world = new b2World(bounds, gravity, allowSleep, &settings);
    world->SetBoundaryListener(BL);
    world->SetContactListener(CL);
    world->SetDestructionListener(DL);
    world->SetContactFilter(CF);
    world->SetDebugDraw(DD);
    world->GetGroundBody()->GetUserData()->ID = -2;

    memset(bodies, 0, maxBodies*sizeof(void*));
    memset(joints, 0, maxJoints*sizeof(void*));
    memset(bDefs, 0, maxBodyDefs*sizeof(void*));
    memset(jDefs, 0, maxJointDefs*sizeof(void*));
    memset(sDefs, 0, maxShapeDefs*sizeof(void*));
    memset(controllers, 0, maxControllers*sizeof(void*));

    lastBody = -2;
    lastJoint = -2;
    lastController = -2;

    eventBody = -2;
    eventJoint = -2;
    eventShape = -2;
    memset(&collData, 0, sizeof(CollData));

    enumBody = -2;
    enumJoint = -2;
    enumShape = -2;
    enumController = -2;
}

void Box2D::update_world()
{
    world->Step(timestep, velIterations, posIterations);

    for (int i = 0; i < maxBodies; i++) {
        if(!bodies[i])
            continue;

        b2Body* b = bodies[i];

        if (b->IsSleeping()) {
            if(!b->GetUserData()->sleepflag) {
                b->GetUserData()->sleepflag = true;
                SleepCallback* c = new SleepCallback;
                c->bodyID = i;
                addCallback(c, this);
            }
        } else {
            if(b->GetUserData()->sleepflag) {
                b->GetUserData()->sleepflag = false;
                WakeCallback* c = new WakeCallback;
                c->bodyID = i;
                addCallback(c, this);
            }
        }

        bodyUserData* bud = b->GetUserData();
        Attachment* a = bud->attachment;
        while (a) {
            if (a->obj->flags & DESTROYING) {
                if (a = bud->attachment) {
                    bud->attachment = a->Next;
                }
                bud->RemAttachment(a);

                LostAttachmentCallback* c = new LostAttachmentCallback;
                c->bodyID = i;
                addCallback(c, this);
                continue;
            } else {
                a->obj->set_position(
                    int_round(bodies[i]->GetWorldPoint(a->offset).x*scale),
                    int_round(bodies[i]->GetWorldPoint(a->offset).y*scale));

                switch (a->rotation) {
                    case 1:
                    case 2: {
                        // 1: non-antialised
                        // 2: antialised
                        int quality = a->rotation - 1;
                        float angle = -deg(bodies[i]->GetAngle()-a->rotOff);
                        a->obj->set_angle(angle, quality);
                        break;
                    }
                }
            }
            a = a->Next;
        }
    }

    //Handle Callbacks
    while (callbacks) {
        callbacks->Do(this);
        Callback* c = callbacks->Next;
        delete callbacks;
        callbacks = c;
    }
    lastcall = NULL;
}

void Box2D::update()
{
    if (autoUpdate) {
        update_world();
    } else if (callbacks) {
        while(callbacks) {
            callbacks->Do(this);
            Callback* c = callbacks->Next;
            delete callbacks;
            callbacks = c;
        }
        lastcall = NULL;
    }
}

void Box2D::draw_debug()
{
    if (global_world == NULL)
        return;
    global_world->DrawDebugData();
}
