// ============================================================================
//
// This file contains the actions, conditions and expressions your object uses
// 
// ============================================================================

#include "common.h"
#include "func.h"
#include "parser.h"


CONDITION(
	/* ID */			0,
	/* Name */			"%o: On Contact Point Response",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			1,
	/* Name */			"%o: On Contact Point Response for Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	return rdPtr->collData.type1 == type;
}
CONDITION(
	/* ID */			2,
	/* Name */			"%o: On Contact Point Response Between Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	return rdPtr->collData.type1 == type1 && rdPtr->collData.type2 == type2;
}
CONDITION(
	/* ID */			3,
	/* Name */			"%o: On Body Leaving World",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			4,
	/* Name */			"%o: On Joint Destroyed",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			5,
	/* Name */			"%o: World - Sleeping is Allowed",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(0)
) {
	return rdPtr->allowSleep;
}
CONDITION(
	/* ID */			6,
	/* Name */			"%o: World - CCD is Enabled",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(0)
) {
	return rdPtr->CCD;
}
CONDITION(
	/* ID */			7,
	/* Name */			"%o: World - Warm Starting is Enabled",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(0)
) {
	return rdPtr->WarmStart;
}
CONDITION(
	/* ID */			8,
	/* Name */			"%o: World - Position Correction is Enabled",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(0)
) {
	return rdPtr->PosCorrection;
}
CONDITION(
	/* ID */			9,
	/* Name */			"%o: Body - Body (%0) is Sleeping",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsSleeping();
}
CONDITION(
	/* ID */			10,
	/* Name */			"%o: Body - Body (%0) is Frozen",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsFrozen();
}
CONDITION(
	/* ID */			11,
	/* Name */			"%o: On Shape Test",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			12,
	/* Name */			"%o: On Collision Begin",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			13,
	/* Name */			"%o: On Collision Begin for Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	return rdPtr->collData.type1 == type;
}
CONDITION(
	/* ID */			14,
	/* Name */			"%o: On Collision Begin Between Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	return rdPtr->collData.type1 == type1 && rdPtr->collData.type2 == type2;
}
CONDITION(
	/* ID */			15,
	/* Name */			"%o: On Collision End",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			16,
	/* Name */			"%o: On Collision End for Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	return rdPtr->collData.type1 == type;
}
CONDITION(
	/* ID */			17,
	/* Name */			"%o: On Collision End Between Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	return rdPtr->collData.type1 == type1 && rdPtr->collData.type2 == type2;
}
CONDITION(
	/* ID */			18,
	/* Name */			"%o: On Collision Evaluation",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			19,
	/* Name */			"%o: On Collision Evaluation for Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	return rdPtr->collData.type1 == type;
}
CONDITION(
	/* ID */			20,
	/* Name */			"%o: On Collision Evaluation Between Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	return rdPtr->collData.type1 == type1 && rdPtr->collData.type2 == type2;
}
CONDITION(
	/* ID */			21,
	/* Name */			"%o: On Contact Point Add",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			22,
	/* Name */			"%o: On Contact Point Add for Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	return rdPtr->collData.type1 == type;
}
CONDITION(
	/* ID */			23,
	/* Name */			"%o: On Contact Point Add Between Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	return rdPtr->collData.type1 == type1 && rdPtr->collData.type2 == type2;
}
CONDITION(
	/* ID */			24,
	/* Name */			"%o: On Contact Point Persist",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			25,
	/* Name */			"%o: On Contact Point Persist for Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	return rdPtr->collData.type1 == type;
}
CONDITION(
	/* ID */			26,
	/* Name */			"%o: On Contact Point Persist Between Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	return rdPtr->collData.type1 == type1 && rdPtr->collData.type2 == type2;
}
CONDITION(
	/* ID */			27,
	/* Name */			"%o: On Contact Point Remove",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			28,
	/* Name */			"%o: On Contact Point Remove for Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	return rdPtr->collData.type1 == type;
}
CONDITION(
	/* ID */			29,
	/* Name */			"%o: On Contact Point Remove Between Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	return rdPtr->collData.type1 == type1 && rdPtr->collData.type2 == type2;
}
CONDITION(
	/* ID */			30,
	/* Name */			"%o: Body (%0) is Touching Body (%1)",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(2,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID")
) {
	int n = lParam();
	int n2 = lParam();

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return false;

	return b->IsTouching(b2);
}
CONDITION(
	/* ID */			31,
	/* Name */			"%o: Shape (%1) of Body (%0) is Touching Shape (%3) of Body (%2)",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(4,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"First Shape ID",PARAM_NUMBER,"Second Body ID",PARAM_NUMBER,"Second Shape ID")
) {
	int n = lParam();
	int si = lParam();
	int n2 = lParam();
	int si2 = lParam();

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return false;

	b2Shape* s = getShape(b,si);
	b2Shape* s2 = getShape(b2,si2);

	if(!s || !s2) return false;

	return s->IsTouching(s2);
}
CONDITION(
	/* ID */			32,
	/* Name */			"%o: Body (%0) is Touching Type (%1)",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Collision Type")
) {
	int n = lParam();
	int ct = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsTouching(ct);
}
CONDITION(
	/* ID */			33,
	/* Name */			"%o: Shape (%1) of Body (%0) is Touching Type (%2)",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID",PARAM_NUMBER,"Collision Type")
) {
	int n = lParam();
	int si = lParam();
	int ct = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,si);

	if(!s) return false;

	return s->IsTouching(ct);
}

long cnd_body_touch_body_obj_id(LPRDATA rdPtr, LPHO obj, long n2)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return false;

	return b->IsTouching(b2);
}

CONDITION(
	/* ID */			34,
	/* Name */			"%o: Body of (%0) is Touching Body (%1)",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID")
) {
	return ProcessCondition(rdPtr,param1,param2,cnd_body_touch_body_obj_id);
}

long cnd_shape_touch_shape_obj_id(LPRDATA rdPtr, LPHO obj, long exp)
{
	extendedParam* x = (extendedParam*)exp;

	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(x->p1_long,rdPtr);

	if(!b || !b2) return false;

	b2Shape* s = getShape(b,x->p2_long);
	b2Shape* s2 = getShape(b2,x->p3_long);

	if(!s || !s2) return false;

	return s->IsTouching(s2);
}

CONDITION(
	/* ID */			35,
	/* Name */			"%o: Shape (%1) of Body of (%0) is Touching Shape (%3) of Body (%2)",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"First Shape ID",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Second Shape ID")
) {
	int obj = uParam();
	int si = lParam();
	int n2 = lParam();
	int si2 = lParam();

	extendedParam* x = new extendedParam;
	x->p1_long = n2;
	x->p2_long = si;
	x->p3_long = si2;

	bool ret = 1 == ProcessCondition(rdPtr,obj,(long)x,cnd_shape_touch_shape_obj_id);

	delete x;

	return ret;
}

long cnd_body_touch_type_obj_id(LPRDATA rdPtr, LPHO obj, long ct)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsTouching(ct);
}

CONDITION(
	/* ID */			36,
	/* Name */			"%o: Body of (%0) is Touching Type (%1)",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Collision Type")
) {
	return ProcessCondition(rdPtr,param1,param2,cnd_body_touch_type_obj_id);
}

long cnd_shape_touch_type_obj_id(LPRDATA rdPtr, LPHO obj, long exp)
{
	extendedParam* x = (extendedParam*)exp;

	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,x->p1_long);

	if(!s) return false;

	return s->IsTouching(x->p2_long);
}

CONDITION(
	/* ID */			37,
	/* Name */			"%o: Shape (%1) of Body of (%0) is Touching Type (%2)",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID",PARAM_NUMBER,"Collision Type")
) {
	int obj = uParam();
	int si = lParam();
	int ct = lParam();

	extendedParam* x = new extendedParam;
	x->p1_long = si;
	x->p2_long = ct;

	int ret = ProcessCondition(rdPtr,obj,(long)x,cnd_shape_touch_type_obj_id);

	delete x;

	return ret;
}

long cnd_body_sleeping(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsSleeping();
}

CONDITION(
	/* ID */			38,
	/* Name */			"%o: Body - Body (%0) is Sleeping",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	return ProcessCondition(rdPtr,param1,0,cnd_body_sleeping);
}

long cnd_body_frozen(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsFrozen();
}

CONDITION(
	/* ID */			39,
	/* Name */			"%o: Body - Body (%0) is Frozen",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	return ProcessCondition(rdPtr,param1,0,cnd_body_frozen);
}
CONDITION(
	/* ID */			40,
	/* Name */			"%o: On Body Fall Asleep",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			41,
	/* Name */			"%o: On Body Wake Up",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			42,
	/* Name */			"%o: Body - Body (%0) is Static",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsStatic();
}

long cnd_body_static(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsStatic();
}

CONDITION(
	/* ID */			43,
	/* Name */			"%o: Body - Body (%0) is Static",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	return ProcessCondition(rdPtr,param1,0,cnd_body_static);
}
CONDITION(
	/* ID */			44,
	/* Name */			"%o: Body - Body (%0) is a Bullet",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsBullet();
}

long cnd_body_bullet(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	return b->IsBullet();
}

CONDITION(
	/* ID */			45,
	/* Name */			"%o: Body - Body (%0) is a Bullet",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	return ProcessCondition(rdPtr,param1,0,cnd_body_bullet);
}
CONDITION(
	/* ID */			46,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is a Sensor",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID")
) {
	int n = lParam();
	int sn = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,sn);

	if(!s) return false;

	return s->IsSensor();
}

long cnd_shape_sensor(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,exp);

	if(!s) return false;

	return s->IsSensor();
}

CONDITION(
	/* ID */			47,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is a Sensor",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID")
) {
	return ProcessCondition(rdPtr,param1,param2,cnd_shape_sensor);
}
CONDITION(
	/* ID */			48,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is a Polygon",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID")
) {
	int n = lParam();
	int sn = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,sn);

	if(!s) return false;

	return s->GetType() == e_polygonShape;
}

long cnd_shape_polygon(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,exp);

	if(!s) return false;

	return s->GetType() == e_polygonShape;
}

CONDITION(
	/* ID */			49,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is a Polygon",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID")
) {
	return ProcessCondition(rdPtr,param1,param2,cnd_shape_polygon);
}
CONDITION(
	/* ID */			50,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is a Circle",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID")
) {
	int n = lParam();
	int sn = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,sn);

	if(!s) return false;

	return s->GetType() == e_circleShape;
}

long cnd_shape_circle(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,exp);

	if(!s) return false;

	return s->GetType() == e_circleShape;
}

CONDITION(
	/* ID */			51,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is a Circle",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID")
) {
	return ProcessCondition(rdPtr,param1,param2,cnd_shape_circle);
}
CONDITION(
	/* ID */			52,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is an Edge",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID")
) {
	int n = lParam();
	int sn = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,sn);

	if(!s) return false;

	return s->GetType() == e_edgeShape;
}

long cnd_shape_edge(LPRDATA rdPtr, LPHO obj, long exp)
{
	if(!obj) return false;

	if(!hasAttachment((LPRO)obj,rdPtr)) return false;

	int n = rdPtr->AttachedObjectIDs[obj->hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return false;

	b2Shape* s = getShape(b,exp);

	if(!s) return false;

	return s->GetType() == e_edgeShape;
}

CONDITION(
	/* ID */			53,
	/* Name */			"%o: Shape - Shape (%1) of Body (%0) is an Edge",
	/* Flags */			EVFLAGS_ALWAYS,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID")
) {
	return ProcessCondition(rdPtr,param1,param2,cnd_shape_edge);
}

CONDITION(
	/* ID */			54,
	/* Name */			"%o: Body - Body ID (%0) is Valid",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	return getBody(param1,rdPtr) != NULL;
}

CONDITION(
	/* ID */			55,
	/* Name */			"%o: Joint - Joint ID (%0) is Valid",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	return getJoint(param1,rdPtr) != NULL;
}

CONDITION(
	/* ID */			56,
	/* Name */			"%o: Controller - Controller ID (%0) is Valid",
	/* Flags */			EVFLAGS_ALWAYS | EVFLAGS_NOTABLE,
	/* Params */		(1,PARAM_NUMBER,"Controller ID")
) {
	return getController(param1,rdPtr) != NULL;
}

CONDITION(
	/* ID */			57,
	/* Name */			"%o: Enumertion - On Body",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			58,
	/* Name */			"%o: Enumertion - On Shape",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			59,
	/* Name */			"%o: Enumertion - On Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			60,
	/* Name */			"%o: <Not Used>",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			61,
	/* Name */			"%o: Enumertion - On Polygon Shape",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			62,
	/* Name */			"%o: Enumertion - On Circle Shape",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			63,
	/* Name */			"%o: Enumertion - On Edge Shape",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			64,
	/* Name */			"%o: Enumertion - On Revolute Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;	
}

CONDITION(
	/* ID */			65,
	/* Name */			"%o: Enumertion - On Prismatic Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			66,
	/* Name */			"%o: Enumertion - On Distance Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			67,
	/* Name */			"%o: Enumertion - On Pulley Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			68,
	/* Name */			"%o: Enumertion - On Line Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			69,
	/* Name */			"%o: Enumertion - On Gear Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}

CONDITION(
	/* ID */			70,
	/* Name */			"%o: Enumertion - On Mouse Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}
CONDITION(
	/* ID */			71,
	/* Name */			"%o: On Body Lost Attachment",
	/* Flags */			0,
	/* Params */		(0)
) {
	return true;
}



/*
// ============================================================================
//
// ACTIONS
// 
// ============================================================================
*/

ACTION(
	/* ID */			0,
	/* Name */			"World - Update",
	/* Flags */			0,
	/* Params */		(0)
) {

	rdPtr->world->Step(rdPtr->timestep, rdPtr->velIterations, rdPtr->posIterations);

	//Handle Attached Objects
	for(int i = 0; i < rdPtr->maxBodies; i++)
	{
		if(!rdPtr->bodies[i]) continue;

		b2Body* b = rdPtr->bodies[i];

		if(b->IsSleeping())
		{
			if(!b->GetUserData()->sleepflag)
			{
				b->GetUserData()->sleepflag = true;

				SleepCallback* c = new SleepCallback;
				c->bodyID = i;
				addCallback(c,rdPtr);
			}
		}
		else
		{
			if(b->GetUserData()->sleepflag)
			{
				b->GetUserData()->sleepflag = false;

				WakeCallback* c = new WakeCallback;
				c->bodyID = i;
				addCallback(c,rdPtr);
			}
		}

		bodyUserData* bud = b->GetUserData();
		Attachment* a = bud->attachment;
		while(a)
		{
			headerObject* roHo = rdPtr->rHo.hoAdRunHeader->rhObjectList[a->objectNum].oblOffset;
			if(!roHo)
			{
				if(a = bud->attachment)
				{
					bud->attachment = a->Next;
				}
				bud->RemAttachment(a);
				
				LostAttachmentCallback* c = new LostAttachmentCallback;
				c->bodyID = i;
				addCallback(c,rdPtr);
				continue;
			}
			else
			{
				DWORD flags = roHo->hoOEFlags;
				rCom* roc = NULL;				// Anim/movement structure
				rMvt* rom = NULL;				// Movement structure 
				rAni* roa = NULL;				// Animation structure 
				rSpr* ros = NULL;				// Sprite handling structure
				rVal* rov = NULL;				// Values structure

				char* p = (char*)roHo;
				p += sizeof(headerObject);

				if(flags & (OEFLAG_MOVEMENTS | OEFLAG_ANIMATIONS | OEFLAG_SPRITES))
				{
					roc = (rCom*)p;
					p += sizeof(rCom);
				}
				if(flags & OEFLAG_MOVEMENTS)
				{
					rom = (rMvt*)p;
					p += sizeof(rMvt);
				}
				if(flags & OEFLAG_ANIMATIONS)
				{
					roa = (rAni*)p;
					p += sizeof(rAni);
				}
				if(flags & OEFLAG_SPRITES)
				{
					ros = (rSpr*)p;
					p += sizeof(rSpr);
				}
				if(flags & OEFLAG_VALUES)
				{
					rov = (rVal*)p;
					p += sizeof(rVal);
				}
				
				roHo->hoAdRunHeader->rh4.rh4KpxFunctions[RFUNCTION_SETPOSITION].routine(roHo, 
					(int)round(rdPtr->bodies[i]->GetWorldPoint(a->offset).x*rdPtr->scale), 
					(int)round(rdPtr->bodies[i]->GetWorldPoint(a->offset).y*rdPtr->scale));

				if(roc)
				{
					roc->rcChanged = true;
				
					switch(a->rotation)
					{
						case 1:
						{
							roc->rcAngleF = (rdPtr->bodies[i]->GetAngle()-a->rotOff) * RAD_TO_DEG;
							if(ros)
								ros->rsFlags &= (~16);
							break;
						}
						case 2:
						{
							roc->rcAngleF = (rdPtr->bodies[i]->GetAngle()-a->rotOff) * RAD_TO_DEG;
							if(ros)
								ros->rsFlags |= 16;
							break;
						}
					}
				}
			}
			a = a->Next;
		}
	}

	//Handle Callbacks
	while(rdPtr->callbacks)
	{
		rdPtr->callbacks->Do(rdPtr);
		Callback* c = rdPtr->callbacks->Next;
		delete rdPtr->callbacks;
		rdPtr->callbacks = c;
	}
	rdPtr->lastcall = NULL;
}

ACTION(
	/* ID */			1,
	/* Name */			"Quick Create Body at (%0), offset (%1,%2), rotation (%3), destruction (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Rotation (-1: Disable, 0: Not Object, 1: Fast, 2: Quality)",PARAM_NUMBER,"Link Destruction")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int rotation = lParam();
	int dest = lParam();

	if(!obj) return;
	
	if(hasAttachment(obj,rdPtr)) removeAttachment(obj,rdPtr);

	int n = getNullBody(rdPtr);
	if(n == -1) return;

	b2BodyDef def;
	def.userData.ID = n;
	def.userData.rdPtr = rdPtr;
	def.userData.AddObject(obj->roHo.hoNumber,b2Vec2(-x/rdPtr->scale,-y/rdPtr->scale),rotation,dest,0);
	if(rdPtr->floatAngles)
		def.angle = obj->roc.rcAngleF * DEG_TO_RAD;
	else
		def.angle = obj->roc.rcAngleI * DEG_TO_RAD;
	def.position.Set(((float)obj->roHo.hoX + x)/rdPtr->scale, ((float)obj->roHo.hoY + y)/rdPtr->scale);
	def.fixedRotation = rotation == -1;
	

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(&def)) == NULL)
	{
		//Failed to create body
		def.userData.BodyDie();
		rdPtr->lastBody = -2;
		return;
	}

	rdPtr->lastBody = n;
}

ACTION(
	/* ID */			2,
	/* Name */			"Quick Add Box to Body (%0), size (%1,%2), offset (%3,%4), angle (%5), density (%6), friction (%7), elasticity (%8)",
	/* Flags */			0,
	/* Params */		(9,PARAM_OBJECT,"Object",PARAM_NUMBER,"Width",PARAM_NUMBER,"Height",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Angle",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	float width = fParam();
	float height = fParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2PolygonDef def(4);
	def.SetAsBox((width/2)/rdPtr->scale,(height/2)/rdPtr->scale,b2Vec2(x/rdPtr->scale,y/rdPtr->scale),angle*DEG_TO_RAD);
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		return;
	}

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			3,
	/* Name */			"Reset World",
	/* Flags */			0,
	/* Params */		(0)
) {
	for(int i = 0; i < rdPtr->maxBodyDefs; i++)
	{
		if(!rdPtr->bDefs[i]) continue;
		delete rdPtr->bDefs[i];
	}
	for(int i = 0; i < rdPtr->maxJointDefs; i++)
	{
		if(!rdPtr->jDefs[i]) continue;
		delete rdPtr->jDefs[i];
	}
	for(int i = 0; i < rdPtr->maxShapeDefs; i++)
	{
		if(!rdPtr->sDefs[i]) continue;
		delete rdPtr->sDefs[i];
	}

	if(rdPtr->world) delete rdPtr->world;

	rdPtr->world = new b2World(rdPtr->bounds,rdPtr->gravity,rdPtr->allowSleep, &rdPtr->settings);
	rdPtr->world->SetBoundaryListener(rdPtr->BL);
	rdPtr->world->SetContactListener(rdPtr->CL);
	rdPtr->world->SetDestructionListener(rdPtr->DL);
	rdPtr->world->SetContactFilter(rdPtr->CF);

	rdPtr->world->GetGroundBody()->GetUserData()->ID = -2;

	memset(rdPtr->bodies, 0, rdPtr->maxBodies*4);
	memset(rdPtr->joints, 0, rdPtr->maxJoints*4);
	memset(rdPtr->bDefs, 0, rdPtr->maxBodyDefs*4);
	memset(rdPtr->jDefs, 0, rdPtr->maxJointDefs*4);
	memset(rdPtr->sDefs, 0, rdPtr->maxShapeDefs*4);
	memset(rdPtr->controllers, 0, rdPtr->maxControllers*4);

	rdPtr->lastBody = -2;
	rdPtr->lastJoint = -2;
	rdPtr->lastController = -2;
	
	for(int i = 0; i < rdPtr->rHo.hoAdRunHeader->rhMaxObjects; i++) rdPtr->AttachedObjectIDs[i] = -1;

	rdPtr->eventBody = -2;
	rdPtr->eventJoint = -2;
	rdPtr->eventShape = -2;
	memset(&rdPtr->collData,0,sizeof(CollData));
	
	rdPtr->enumBody = -2;
	rdPtr->enumJoint = -2;
	rdPtr->enumShape = -2;
	rdPtr->enumController = -2;
}

ACTION(
	/* ID */			4,
	/* Name */			"World - Set Gravity to (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Gravity X",PARAM_NUMBER,"Gravity Y")
) {
	float x = fParam();
	float y = fParam();

	rdPtr->world->SetGravity(b2Vec2(x,y));
}

ACTION(
	/* ID */			5,
	/* Name */			"World - Set Timestep to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Timestep")
) {
	float ts = fParam();

	if(ts < 0.0f) ts = 0.0f;

	rdPtr->timestep = ts;
}

ACTION(
	/* ID */			6,
	/* Name */			"World - Set Position Iteration Count to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Iterations")
) {
	int i = lParam();

	if(i < 1) i = 1;

	rdPtr->posIterations = i;
}

ACTION(
	/* ID */			7,
	/* Name */			"World - Set Velocity Iteration Count to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Iterations")
) {
	int i = lParam();

	if(i < 1) i = 1;

	rdPtr->velIterations = i;
}

ACTION(
	/* ID */			8,
	/* Name */			"World - Enable CCD (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Enable, 0: Disable")
) {
	int flag = lParam();

	rdPtr->world->SetContinuousPhysics(flag != 0);
}

ACTION(
	/* ID */			9,
	/* Name */			"World - Enable Warm Starting (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Enable, 0: Disable")
) {
	int flag = lParam();

	rdPtr->world->SetWarmStarting(flag != 0);
}

ACTION(
	/* ID */			10,
	/* Name */			"World - Refilter",
	/* Flags */			0,
	/* Params */		(0)
) {
	for(int i = 0; i < rdPtr->maxBodies; i++)
	{
		if(!rdPtr->bodies[i]) continue;
		b2Shape* s = rdPtr->bodies[i]->GetShapeList();
		while(s)
		{
			rdPtr->world->Refilter(s);
			s = s->GetNext();
		}
	}
}

ACTION(
	/* ID */			11,
	/* Name */			"Quick Create Body at (%0,%1), angle (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"Angle")
) {
	float x = fParam();
	float y = fParam();
	float angle = fParam();

	int n = getNullBody(rdPtr);
	if(n == -1) return;

	b2BodyDef def;
	def.userData.ID = n;
	def.userData.rdPtr = rdPtr;
	def.position.Set(x/rdPtr->scale, y/rdPtr->scale);
	def.angle = angle*DEG_TO_RAD;

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(&def)) == NULL)
	{
		//Failed to create body
		rdPtr->lastBody = -2;
		return;
	}

	rdPtr->lastBody = n;
}

ACTION(
	/* ID */			12,
	/* Name */			"Begin Body",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curBodyDef) delete rdPtr->curBodyDef;

	rdPtr->curBodyDef = new b2BodyDef;
}

ACTION(
	/* ID */			13,
	/* Name */			"Load Body Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body Definition ID")
) {
	long def = lParam();

	copyDef(getBodyDef(def,rdPtr),rdPtr->curBodyDef);
}

ACTION(
	/* ID */			14,
	/* Name */			"Store Current Body Data in Body Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body Definition ID")
) {
	long def = lParam();

	if(!isBodyDef(def,rdPtr)) return;

	copyDef(rdPtr->curBodyDef,rdPtr->bDefs[def]);
}

ACTION(
	/* ID */			15,
	/* Name */			"Remove Body Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body Definition ID")
) {
	long def = lParam();

	b2BodyDef* bd = getBodyDef(def,rdPtr);
	if(!bd) return;

	delete bd;
	rdPtr->bDefs[def] = NULL;
}

ACTION(
	/* ID */			16,
	/* Name */			"Body - Set Mass Data to mass (%0), inertia (%1), center (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Mass",PARAM_NUMBER,"Interia",PARAM_NUMBER,"Center of Mass X",PARAM_NUMBER,"Center of Mass Y")
) {
	float mass = fParam();
	float inertia = fParam();
	float cx = fParam();
	float cy = fParam();

	b2BodyDef* bd = rdPtr->curBodyDef;
	if(!bd) return;

	bd->userData.customMass = true;
	bd->massData.mass = mass;
	bd->massData.I = inertia;
	bd->massData.center.Set(cx / rdPtr->scale,cy / rdPtr->scale);
}

ACTION(
	/* ID */			17,
	/* Name */			"Body - Set Linear Damping to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Damping")
) {
	float d = fParam();

	b2BodyDef* bd = rdPtr->curBodyDef;
	if(!bd) return;

	bd->linearDamping = d;
}

ACTION(
	/* ID */			18,
	/* Name */			"Body - Set Angular Damping to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Damping")
) {
	float d = fParam();

	b2BodyDef* bd = rdPtr->curBodyDef;
	if(!bd) return;

	bd->angularDamping = d;
}

ACTION(
	/* ID */			19,
	/* Name */			"Body - Set Sleepflag to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disable Sleeping, 1: Enable Sleeping, 2: Start Asleep")
) {
	int sf = lParam();

	b2BodyDef* bd = rdPtr->curBodyDef;
	if(!bd) return;

	bd->allowSleep = sf>0;
	bd->isSleeping = sf==2;
}

ACTION(
	/* ID */			20,
	/* Name */			"Body - Set Fixed Rotation to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Disable Rotation, 0: Enable Rotation")
) {
	int rf = lParam();

	b2BodyDef* bd = rdPtr->curBodyDef;
	if(!bd) return;

	bd->fixedRotation = rf!=0;
}

ACTION(
	/* ID */			21,
	/* Name */			"Body - Set Bullet to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disable Bullet, 1: Enable Bullet")
) {
	int bf = lParam();

	b2BodyDef* bd = rdPtr->curBodyDef;
	if(!bd) return;

	bd->isBullet = bf!=0;
}

ACTION(
	/* ID */			22,
	/* Name */			"Create Body at (%0), offset (%1,%2), rotation (%3), destruction (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Rotation (0: No Rotation, 1: Fast, 2: Quality",PARAM_NUMBER,"Link Destruction")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int rotation = lParam();
	int dest = lParam();

	if(!obj) return;

	if(!rdPtr->curBodyDef) return;

	b2BodyDef def = *rdPtr->curBodyDef;
	
	if(hasAttachment(obj,rdPtr)) removeAttachment(obj,rdPtr);

	int n = getNullBody(rdPtr);
	if(n == -1) return;

	def.userData.ID = n;
	def.userData.rdPtr = rdPtr;
	def.userData.AddObject(obj->roHo.hoNumber,b2Vec2(-x/rdPtr->scale,-y/rdPtr->scale),rotation,dest,0);
	if(rdPtr->floatAngles)
		def.angle = obj->roc.rcAngleF * DEG_TO_RAD;
	else
		def.angle = obj->roc.rcAngleI * DEG_TO_RAD;
	def.position.Set(((float)obj->roHo.hoX + x)/rdPtr->scale, ((float)obj->roHo.hoY + y)/rdPtr->scale);

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(&def)) == NULL)
	{
		//Failed to create body
		def.numShapes = 0;
		def.shapes = NULL;
		def.userData.BodyDie();
		rdPtr->lastBody = -2;
		return;
	}

	if(def.numShapes > 0)
	{
		for(int i = 0; i < def.numShapes; i++)
		{
			rdPtr->bodies[n]->CreateShape(def.shapes[i]);
		}

		updateShapes(rdPtr->bodies[n]);

		if(!rdPtr->bodies[n]->GetUserData()->customMass)
			rdPtr->bodies[n]->SetMassFromShapes();

		def.numShapes = 0;
		def.shapes = NULL;
	}

	rdPtr->lastBody = n;
}

ACTION(
	/* ID */			23,
	/* Name */			"Create Body at (%0,%1) , angle (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"Angle")
) {
	float x = fParam();
	float y = fParam();
	float angle = fParam();

	int n = getNullBody(rdPtr);
	if(n == -1) return;
	
	if(!rdPtr->curBodyDef) return;

	b2BodyDef def = *rdPtr->curBodyDef;

	def.userData.ID = n;
	def.userData.rdPtr = rdPtr;
	def.position.Set(x/rdPtr->scale, y/rdPtr->scale);
	def.angle = angle*DEG_TO_RAD;

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(&def)) == NULL)
	{
		//Failed to create body
		def.numShapes = 0;
		def.shapes = NULL;
		def.userData.BodyDie();
		rdPtr->lastBody = -2;
		return;
	}

	if(def.numShapes > 0)
	{
		for(int i = 0; i < def.numShapes; i++)
		{
			rdPtr->bodies[n]->CreateShape(def.shapes[i]);
		}

		updateShapes(rdPtr->bodies[n]);

		if(!rdPtr->bodies[n]->GetUserData()->customMass)
			rdPtr->bodies[n]->SetMassFromShapes();

		def.numShapes = 0;
		def.shapes = NULL;
	}

	rdPtr->lastBody = n;
}

ACTION(
	/* ID */			24,
	/* Name */			"Remove Body (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	rdPtr->world->DestroyBody(b);

	rdPtr->bodies[n] = NULL;
}

ACTION(
	/* ID */			25,
	/* Name */			"Remove Body of (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	LPRO obj = oParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	rdPtr->world->DestroyBody(b);

	rdPtr->bodies[n] = NULL;
}

ACTION(
	/* ID */			26,
	/* Name */			"Quick Add Circle to Body (%0), diameter (%1), offset (%2,%3), density (%4), friction (%5), elasticity (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_OBJECT,"Object",PARAM_NUMBER,"Diameter",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	float diam = fParam();
	float x = fParam();
	float y = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2CircleDef def;
	def.localPosition.Set(x/rdPtr->scale,y/rdPtr->scale);
	def.radius = diam / (2*rdPtr->scale);
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!rdPtr->bodies[n]->CreateShape(&def))
	{
		//Failed to add shape Error
		return;
	}
	
	updateShapes(rdPtr->bodies[n]);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		rdPtr->bodies[n]->SetMassFromShapes();
}

ACTION(
	/* ID */			27,
	/* Name */			"Quick Add Polygon to Body (%0), verices (%1), offset (%2,%3), density (%4), friction (%5), elasticity (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_OBJECT,"Object",PARAM_STRING,"Vertices (CSV String)",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	LPCSTR verts = sParam();
	float x = fParam();
	float y = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();
	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;

	b2PolygonDef def(num/2);
	def.vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def.vertices[i].Set((coord[i*2]+x)/rdPtr->scale,(coord[i*2+1]+y)/rdPtr->scale);
	}
	delete [] coord;
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!rdPtr->bodies[n]->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(rdPtr->bodies[n]);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		rdPtr->bodies[n]->SetMassFromShapes();
}

ACTION(
	/* ID */			28,
	/* Name */			"Quick Add Edge Chain to Body (%0), vertices (%1), closed (%2), offset (%3,%4), friction (%5), elasticity (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_OBJECT,"Object",PARAM_STRING,"Vertices (CSV String)",PARAM_NUMBER,"0: Open Edge, 1: Closed Edge",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	LPCSTR verts = sParam();
	int loop = lParam();
	float x = fParam();
	float y = fParam();
	float friction = fParam();
	float elasticity = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;

	b2EdgeChainDef def(num/2);
	def.vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def.vertices[i].Set((coord[i*2]+x)/rdPtr->scale,(coord[i*2+1]+y)/rdPtr->scale);
	}
	delete [] coord;
	def.isALoop = loop != 0;
	def.density = 0;
	def.friction = friction;
	def.restitution = elasticity;

	if(!rdPtr->bodies[n]->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(rdPtr->bodies[n]);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		rdPtr->bodies[n]->SetMassFromShapes();
}

ACTION(
	/* ID */			29,
	/* Name */			"Quick Add Box to Body (%0), size (%1,%2), offset (%3,%4), angle (%5), density (%6), friction (%7), elasticity (%8)",
	/* Flags */			0,
	/* Params */		(9,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Width",PARAM_NUMBER,"Height",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Angle",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	int n = lParam();
	float width = fParam();
	float height = fParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2PolygonDef def(4);
	def.SetAsBox((width/2)/rdPtr->scale,(height/2)/rdPtr->scale,b2Vec2(x/rdPtr->scale,y/rdPtr->scale),angle*DEG_TO_RAD);
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}
	
	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			30,
	/* Name */			"Quick Add Circle to Body (%0), diameter (%1), offset (%2,%3), density (%4), friction (%5), elasticity (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Diameter",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	int n = lParam();
	float diam = fParam();
	float x = fParam();
	float y = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2CircleDef def;
	def.localPosition.Set(x/rdPtr->scale,y/rdPtr->scale);
	def.radius = diam / (2*rdPtr->scale);
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			31,
	/* Name */			"Quick Add Polygon to Body (%0), verices (%1), offset (%2,%3), density (%4), friction (%5), elasticity (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_NUMBER,"Body ID",PARAM_STRING,"Vertices (CSV String)",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	int n = lParam();
	LPCSTR verts = sParam();
	float x = fParam();
	float y = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;

	b2PolygonDef def(num/2);
	def.vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def.vertices[i].Set((coord[i*2]+x)/rdPtr->scale,(coord[i*2+1]+y)/rdPtr->scale);
	}
	delete [] coord;
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			32,
	/* Name */			"Quick Add Edge Chain to Body (%0), verices (%1), closed (%2), offset (%3,%4), friction (%5), elasticity (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_NUMBER,"Body ID",PARAM_STRING,"Vertices (CSV String)",PARAM_NUMBER,"0: Open Edge, 1: Closed Edge",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	int n = lParam();
	LPCSTR verts = sParam();
	int loop = lParam();
	float x = fParam();
	float y = fParam();
	float friction = fParam();
	float elasticity = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;

	b2EdgeChainDef def(num/2);
	def.vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def.vertices[i].Set((coord[i*2]+x)/rdPtr->scale,(coord[i*2+1]+y)/rdPtr->scale);
	}
	delete [] coord;
	def.isALoop = loop != 0;
	def.density = 0;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			33,
	/* Name */			"Quick Add Object (%0) as Box to Body (%1), size (%2,%3), offset (%4,%5), angle (%6), density (%7), friction (%8), elasticity (%9)",
	/* Flags */			0,
	/* Params */		(10,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Width",PARAM_NUMBER,"Height",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Angle",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	int n = lParam();
	float width = fParam();
	float height = fParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	if(!obj) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2PolygonDef def(4);
	def.SetAsBox((width/2)/rdPtr->scale,(height/2)/rdPtr->scale,b->GetLocalPoint(b2Vec2(((float)obj->roHo.hoX+x)/rdPtr->scale,((float)obj->roHo.hoY+y)/rdPtr->scale)),angle*DEG_TO_RAD);
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}
	
	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}
ACTION(
	/* ID */			34,
	/* Name */			"Quick Add Object (%0) as Circle to Body (%1), diameter (%2), offset (%3,%4), density (%5), friction (%6), elasticity (%7)",
	/* Flags */			0,
	/* Params */		(8,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Diameter",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	int n = lParam();
	float diam = fParam();
	float x = fParam();
	float y = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	if(!obj) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2CircleDef def;
	def.localPosition = b->GetLocalPoint(b2Vec2(((float)obj->roHo.hoX+x)/rdPtr->scale,((float)obj->roHo.hoY+y)/rdPtr->scale));
	def.radius = diam / (2*rdPtr->scale);
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			35,
	/* Name */			"Quick Add Object (%0) as Polygon to Body (%1), verices (%2), offset (%3,%4), density (%5), friction (%6), elasticity (%7)",
	/* Flags */			0,
	/* Params */		(8,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_STRING,"Vertices (CSV String)",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Density (0 for all shapes = static body)",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	int n = lParam();
	LPCSTR verts = sParam();
	float x = fParam();
	float y = fParam();
	float density = fParam();
	float friction = fParam();
	float elasticity = fParam();

	if(!obj) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;

	b2Vec2 pos = b->GetLocalPoint(b2Vec2(((float)obj->roHo.hoX+x)/rdPtr->scale,((float)obj->roHo.hoY+y)/rdPtr->scale));

	b2PolygonDef def(num/2);
	def.vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def.vertices[i].Set((coord[i*2])/rdPtr->scale + pos.x,(coord[i*2+1])/rdPtr->scale + pos.y);
	}
	delete [] coord;
	def.density = density;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			36,
	/* Name */			"Quick Add Object (%0) as Edge Chain to Body (%1), verices (%2), closed (%3), offset (%4,%5), friction (%6), elasticity (%7)",
	/* Flags */			0,
	/* Params */		(8,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_STRING,"Vertices (CSV String)",PARAM_NUMBER,"0: Open Edge, 1: Closed Edge",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Friction",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	int n = lParam();
	LPCSTR verts = sParam();
	int loop = lParam();
	float x = fParam();
	float y = fParam();
	float friction = fParam();
	float elasticity = fParam();

	if(!obj) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;
	
	b2Vec2 pos = b->GetLocalPoint(b2Vec2(((float)obj->roHo.hoX+x)/rdPtr->scale,((float)obj->roHo.hoY+y)/rdPtr->scale));

	b2EdgeChainDef def(num/2);
	def.vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def.vertices[i].Set((coord[i*2])/rdPtr->scale + pos.x,(coord[i*2+1])/rdPtr->scale + pos.y);
	}
	delete [] coord;
	def.isALoop = loop != 0;
	def.density = 0;
	def.friction = friction;
	def.restitution = elasticity;

	if(!b->CreateShape(&def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}


ACTION(
	/* ID */			37,
	/* Name */			"Begin Polygon Shape",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curShapeDef) delete rdPtr->curShapeDef;

	rdPtr->curShapeDef = new b2PolygonDef;
}

ACTION(
	/* ID */			38,
	/* Name */			"Begin Circle Shape",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curShapeDef) delete rdPtr->curShapeDef;

	rdPtr->curShapeDef = new b2CircleDef;
}

ACTION(
	/* ID */			39,
	/* Name */			"Begin Edge Chain",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curShapeDef) delete rdPtr->curShapeDef;

	rdPtr->curShapeDef = new b2EdgeChainDef;
}

ACTION(
	/* ID */			40,
	/* Name */			"Load Shape Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Shape Definition ID")
) {
	long def = lParam();

	copyDef(getShapeDef(def,rdPtr),rdPtr->curShapeDef);
}

ACTION(
	/* ID */			41,
	/* Name */			"Store Current Shape Data in Shape Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Shape Definition ID")
) {
	long def = lParam();

	if(!isShapeDef(def,rdPtr)) return;

	copyDef(rdPtr->curShapeDef,rdPtr->sDefs[def]);
}

ACTION(
	/* ID */			42,
	/* Name */			"Remove Shape Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Shape Definition ID")
) {
	long def = lParam();

	b2ShapeDef* sd = getShapeDef(def,rdPtr);
	if(!sd) return;

	delete sd;
	rdPtr->sDefs[def] = NULL;
}

ACTION(
	/* ID */			43,
	/* Name */			"Shape - Set Density (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Density")
) {
	float density = fParam();

	if(!rdPtr->curShapeDef) return;

	rdPtr->curShapeDef->density = density;
}
ACTION(
	/* ID */			44,
	/* Name */			"Shape - Set Friction (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Friction")
) {
	float friction = fParam();

	if(!rdPtr->curShapeDef) return;

	rdPtr->curShapeDef->friction = friction;
}
ACTION(
	/* ID */			45,
	/* Name */			"Shape - Set Elasticity (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Elasticity")
) {
	float restitution = fParam();

	if(!rdPtr->curShapeDef) return;

	rdPtr->curShapeDef->restitution = restitution;
}
ACTION(
	/* ID */			46,
	/* Name */			"Shape - Set Collision Type (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type (0-31)")
) {
	int colltype = lParam();

	if(!rdPtr->curShapeDef) return;

	if(colltype < 0 || colltype >= 32) return;

	rdPtr->curShapeDef->userData.collType = (char)colltype;
}
ACTION(
	/* ID */			47,
	/* Name */			"Shape - Set Sensor (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Is solid, 1: Is sensor")
) {
	int sensor = lParam();

	if(!rdPtr->curShapeDef) return;

	rdPtr->curShapeDef->isSensor = sensor != 0;
}

ACTION(
	/* ID */			48,
	/* Name */			"Circle Shape - Set Diameter (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Diameter")
) {
	float diameter = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_circleShape) return;

	((b2CircleDef*)rdPtr->curShapeDef)->radius = diameter / (2*rdPtr->scale);
}

ACTION(
	/* ID */			49,
	/* Name */			"Add Shape to Body (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	LPRO obj = oParam();

	if(!rdPtr->curShapeDef) return;

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	switch(rdPtr->curShapeDef->type)
	{
	case e_polygonShape:
		if(((b2PolygonDef*)rdPtr->curShapeDef)->vertexCount < 3) return;
		break;
	case e_edgeShape:
		if(((b2EdgeChainDef*)rdPtr->curShapeDef)->vertexCount < 3) return;
		rdPtr->curShapeDef->density = 0;
		break;
	}
	
	if(!rdPtr->bodies[n]->CreateShape(rdPtr->curShapeDef))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(rdPtr->bodies[n]);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		rdPtr->bodies[n]->SetMassFromShapes();
}

ACTION(
	/* ID */			50,
	/* Name */			"Add Shape to Body (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	if(!rdPtr->curShapeDef) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	switch(rdPtr->curShapeDef->type)
	{
	case e_polygonShape:
		if(((b2PolygonDef*)rdPtr->curShapeDef)->vertexCount < 3) return;
		break;
	case e_edgeShape:
		if(((b2EdgeChainDef*)rdPtr->curShapeDef)->vertexCount < 3) return;
		rdPtr->curShapeDef->density = 0;
		break;
	}

	if(!b->CreateShape(rdPtr->curShapeDef))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			51,
	/* Name */			"Add Object (%0) as Shape to Body (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!rdPtr->curShapeDef) return;

	if(!obj) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2ShapeDef* sd;

	switch(rdPtr->curShapeDef->type)
	{
	case e_circleShape:
		{
			b2CircleDef* csd = new b2CircleDef;
			*csd = *((b2CircleDef*)rdPtr->curShapeDef);
			csd->localPosition += b->GetLocalPoint(b2Vec2(obj->roHo.hoX / rdPtr->scale, obj->roHo.hoY / rdPtr->scale));
			sd = csd;
		}
		break;
	case e_polygonShape:
		{
			if(((b2PolygonDef*)rdPtr->curShapeDef)->vertexCount < 3) return;
			b2PolygonDef* psd = new b2PolygonDef;
			*psd = *((b2PolygonDef*)rdPtr->curShapeDef);
			psd->vertices = new b2Vec2[psd->vertexMax];
			
			for(int i = 0; i < psd->vertexCount; i++)
			{
				psd->vertices[i] = ((b2PolygonDef*)rdPtr->curShapeDef)->vertices[i] +  b->GetLocalPoint(b2Vec2(obj->roHo.hoX / rdPtr->scale, obj->roHo.hoY / rdPtr->scale));
			}
			sd = psd;
		}
		break;
	case e_edgeShape:
		{
			if(((b2EdgeChainDef*)rdPtr->curShapeDef)->vertexCount < 3) return;
			b2EdgeChainDef* esd = new b2EdgeChainDef;
			*esd = *((b2EdgeChainDef*)rdPtr->curShapeDef);
			esd->density = 0;
			esd->vertices = new b2Vec2[esd->vertexMax];
			
			for(int i = 0; i < esd->vertexCount; i++)
			{
				esd->vertices[i] = ((b2EdgeChainDef*)rdPtr->curShapeDef)->vertices[i] +  b->GetLocalPoint(b2Vec2(obj->roHo.hoX / rdPtr->scale, obj->roHo.hoY / rdPtr->scale));
			}
			sd = esd;
		}
		break;
	default:
		return;
	}

	if(!rdPtr->bodies[n]->CreateShape(sd))
	{
		//Failed to add shape Error
		//delete ud;
		delete sd;
		return;
	}
	delete sd;

	updateShapes(rdPtr->bodies[n]);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		rdPtr->bodies[n]->SetMassFromShapes();
}

ACTION(
	/* ID */			52,
	/* Name */			"Circle Shape - Set Local Position to (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Local X Position",PARAM_NUMBER,"Local Y Position")
) {
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_circleShape) return;

	((b2CircleDef*)rdPtr->curShapeDef)->localPosition.Set(x/rdPtr->scale,y/rdPtr->scale);
}

ACTION(
	/* ID */			53,
	/* Name */			"Remove Shape (%1) from Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)")
) {
	int n = lParam();
	int s = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(s == -1)
	{
		while(b->GetShapeList())
		{
			b->DestroyShape(b->GetShapeList());
		}
		b->GetUserData()->numShapes = 0;
		return;
	}

	if(s < 0 || s >= b->GetUserData()->numShapes) return;

	b2Shape* sa = b->GetShapeList();
	for(int i = 0; i < s; i++)
		sa = sa->GetNext();
	b2Shape* sb = sa->GetNext();

	b->DestroyShape(sa);

	while(sb)
	{
		sb->GetUserData()->ID--;
		sb = sb->GetNext();
	}

	b->GetUserData()->numShapes--;
}

ACTION(
	/* ID */			54,
	/* Name */			"Polygon Shape - Set As Box, size (%0,%1), offset (%2,%3), angle (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"Width",PARAM_NUMBER,"Height",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Angle")
) {
	float width = fParam();
	float height = fParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;

	if(def->vertices)
		delete [] def->vertices;

	def->vertices = new b2Vec2[4];
	def->vertexMax = 4;

	def->SetAsBox(width/(2*rdPtr->scale),height/(2*rdPtr->scale),b2Vec2(x/rdPtr->scale,y/rdPtr->scale),angle*DEG_TO_RAD);
}

ACTION(
	/* ID */			55,
	/* Name */			"Polygon Shape - Precache (%0) vertices",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Number of Vertices")
) {
	int num = lParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	if(num < 3) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;

	b2Vec2* verts = new b2Vec2[num];

	if(def->vertexCount > num) def->vertexCount = num;

	memcpy(verts,def->vertices,def->vertexCount*sizeof(b2Vec2));
	
	delete [] def->vertices;
	def->vertices = verts;
	def->vertexMax = num;
}

ACTION(
	/* ID */			56,
	/* Name */			"Polygon Shape - Add Vertice (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Vertice X",PARAM_NUMBER,"Vertice Y")
) {
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;

	if(def->vertexCount >= def->vertexMax)
	{
		def->vertexMax++;
		b2Vec2* verts = new b2Vec2[def->vertexMax];
		memcpy(verts,def->vertices,def->vertexCount*sizeof(b2Vec2));
		delete [] def->vertices;
		def->vertices = verts;
	}

	def->vertices[def->vertexCount++].Set(x/rdPtr->scale,y/rdPtr->scale);
}

ACTION(
	/* ID */			57,
	/* Name */			"Polygon Shape - Remove Vertice (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Vertice ID")
) {
	int n = lParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;

	if(n < 0 || n >= def->vertexCount) return;

	memcpy(def->vertices+n, def->vertices+n+1, (def->vertexCount-n) * sizeof(b2Vec2));

	def->vertexCount--;
}

ACTION(
	/* ID */			58,
	/* Name */			"Polygon Shape - Set Vertice (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Vertice ID",PARAM_NUMBER,"Vertice X",PARAM_NUMBER,"Vertice Y")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;

	if(n < 0 || n >= def->vertexMax) return;

	if(n >= def->vertexCount) def->vertexCount = n+1;

	def->vertices[n].Set(x/rdPtr->scale,y/rdPtr->scale);
}

ACTION(
	/* ID */			59,
	/* Name */			"Polygon Shape - Insert Vertice (%1,%2) at (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Position",PARAM_NUMBER,"Vertice X",PARAM_NUMBER,"Vertice Y")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;
	
	if(n < 0 || n > def->vertexCount) return;

	if(def->vertexCount >= def->vertexMax)
	{
		def->vertexMax++;
		b2Vec2* verts = new b2Vec2[def->vertexMax];
		memcpy(verts,def->vertices,def->vertexCount*sizeof(b2Vec2));
		delete [] def->vertices;
		def->vertices = verts;
	}

	for(int i = def->vertexCount; i > n; i--)
	{
		def->vertices[i] = def->vertices[i-1];
	}
	def->vertices[n].Set(x/rdPtr->scale,y/rdPtr->scale);
	
	def->vertexCount++;
}

ACTION(
	/* ID */			60,
	/* Name */			"Polygon Shape - Clear Vertices",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;
	
	def->vertexCount = 0;
	def->vertexMax = 0;
	delete [] def->vertices;
	def->vertices = NULL;
}

ACTION(
	/* ID */			61,
	/* Name */			"Polygon Shape - Translate Vertices by (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"X Translation",PARAM_NUMBER,"Y Translation")
) {
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;

	b2Vec2 offset(x/rdPtr->scale,y/rdPtr->scale);

	for(int i = 0; i < def->vertexCount; i++)
	{
		def->vertices[i] += offset;
	}
}

ACTION(
	/* ID */			62,
	/* Name */			"Polygon Shape - Read Vertices from String (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_STRING,"Vertices (CSV String)")
) {
	LPCSTR verts = sParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_polygonShape) return;

	b2PolygonDef* def = (b2PolygonDef*)rdPtr->curShapeDef;

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;

	delete [] def->vertices;
	def->vertices = new b2Vec2[num/2];
	def->vertexMax = num/2;
	def->vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def->vertices[i].Set(coord[i*2]/rdPtr->scale,coord[i*2+1]/rdPtr->scale);
	}
	delete [] coord;
}

ACTION(
	/* ID */			63,
	/* Name */			"Edge Chain - Precache (%0) vertices",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Number of Vertices")
) {
	int num = lParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	if(num < 3) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;

	b2Vec2* verts = new b2Vec2[num];

	if(def->vertexCount > num) def->vertexCount = num;

	memcpy(verts,def->vertices,def->vertexCount*sizeof(b2Vec2));
	
	delete [] def->vertices;
	def->vertices = verts;
}

ACTION(
	/* ID */			64,
	/* Name */			"Edge Chain - Add Vertice (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Vertice X",PARAM_NUMBER,"Vertice Y")
) {
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;

	if(def->vertexCount >= def->vertexMax)
	{
		def->vertexMax++;
		b2Vec2* verts = new b2Vec2[def->vertexMax];
		memcpy(verts,def->vertices,def->vertexCount*sizeof(b2Vec2));
		delete [] def->vertices;
		def->vertices = verts;
	}

	def->vertices[def->vertexCount++].Set(x/rdPtr->scale,y/rdPtr->scale);
}

ACTION(
	/* ID */			65,
	/* Name */			"Edge Chain - Remove Vertice (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Vertice ID")
) {
	int n = lParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;

	if(n < 0 || n >= def->vertexCount) return;

	memcpy(def->vertices+n, def->vertices+n+1, (def->vertexCount-n) * sizeof(b2Vec2));

	def->vertexCount--;
}

ACTION(
	/* ID */			66,
	/* Name */			"Edge Chain - Set Vertice (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Vertice ID",PARAM_NUMBER,"Vertice X",PARAM_NUMBER,"Vertice Y")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;

	if(n < 0 || n >= def->vertexCount) return;

	def->vertices[n].Set(x/rdPtr->scale,y/rdPtr->scale);
}

ACTION(
	/* ID */			67,
	/* Name */			"Edge Chain - Insert Vertice (%1,%2) at (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Position",PARAM_NUMBER,"Vertice X",PARAM_NUMBER,"Vertice Y")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;
	
	if(n < 0 || n > def->vertexCount) return;

	if(def->vertexCount >= def->vertexMax)
	{
		def->vertexMax++;
		b2Vec2* verts = new b2Vec2[def->vertexMax];
		memcpy(verts,def->vertices,def->vertexCount*sizeof(b2Vec2));
		delete [] def->vertices;
		def->vertices = verts;
	}

	for(int i = def->vertexCount; i > n; i--)
	{
		def->vertices[i] = def->vertices[i-1];
	}
	def->vertices[n].Set(x/rdPtr->scale,y/rdPtr->scale);
	
	def->vertexCount++;
}

ACTION(
	/* ID */			68,
	/* Name */			"Edge Chain - Clear Vertices",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;
	
	def->vertexCount = 0;
	def->vertexMax = 0;
	delete [] def->vertices;
	def->vertices = NULL;
}

ACTION(
	/* ID */			69,
	/* Name */			"Edge Chain - Translate Vertices by (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"X Translation",PARAM_NUMBER,"Y Translation")
) {
	float x = fParam();
	float y = fParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;

	b2Vec2 offset(x/rdPtr->scale,y/rdPtr->scale);

	for(int i = 0; i < def->vertexCount; i++)
	{
		def->vertices[i] += offset;
	}
}

ACTION(
	/* ID */			70,
	/* Name */			"Edge Chain - Read Vertices from String (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_STRING,"Vertices (CSV String)")
) {
	LPCSTR verts = sParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;

	int num;
	float* coord = parseString(verts,num);
	if(!coord) return;

	delete [] def->vertices;
	def->vertices = new b2Vec2[num/2];
	def->vertexMax = num/2;
	def->vertexCount = num/2;
	for(int i = 0; i < num/2; i++)
	{
		def->vertices[i].Set(coord[i*2]/rdPtr->scale,coord[i*2+1]/rdPtr->scale);
	}
	delete [] coord;
}

ACTION(
	/* ID */			71,
	/* Name */			"Edge Chain - Set Loop (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Is Open, 1: Is Looped")
) {
	int loop = lParam();

	if(!rdPtr->curShapeDef) return;

	if(rdPtr->curShapeDef->type != e_edgeShape) return;

	b2EdgeChainDef* def = (b2EdgeChainDef*)rdPtr->curShapeDef;

	def->isALoop = loop != 0;
}



ACTION(
	/* ID */			72,
	/* Name */			"Remove Shape (%1) from Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)")
) {
	LPRO obj = oParam();
	int s = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(s == -1)
	{
		while(b->GetShapeList())
		{
			b->DestroyShape(b->GetShapeList());
		}
		b->GetUserData()->numShapes = 0;
		return;
	}

	if(s < 0 || s >= b->GetUserData()->numShapes) return;

	b2Shape* sa = b->GetShapeList();
	for(int i = 0; i < s; i++)
		sa = sa->GetNext();
	b2Shape* sb = sa->GetNext();

	b->DestroyShape(sa);

	while(sb)
	{
		sb->GetUserData()->ID--;
		sb = sb->GetNext();
	}
	b->GetUserData()->numShapes--;
}



ACTION(
	/* ID */			73,
	/* Name */			"Shape - Set Category Bits (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Binary Representation of Categories")
) {
	int cat = lParam();

	if(!rdPtr->curShapeDef) return;

	rdPtr->curShapeDef->filter.categoryBits = (short)cat;
}
ACTION(
	/* ID */			74,
	/* Name */			"Shape - Set Mask Bits (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Binary Representation of Masks")
) {
	int mask = lParam();

	if(!rdPtr->curShapeDef) return;

	rdPtr->curShapeDef->filter.maskBits = (short)mask;
}
ACTION(
	/* ID */			75,
	/* Name */			"Shape - Set Group Index (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Group Index")
) {
	int gi = lParam();

	if(!rdPtr->curShapeDef) return;

	rdPtr->curShapeDef->filter.groupIndex = (short)gi;
}
ACTION(
	/* ID */			76,
	/* Name */			"Shape - Add Category (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Category (0-15)")
) {
	int cat = lParam();

	if(!rdPtr->curShapeDef) return;

	if(cat < 0 || cat >= 16) return;

	rdPtr->curShapeDef->filter.categoryBits |= (1<<cat);
}
ACTION(
	/* ID */			77,
	/* Name */			"Shape - Remove Category (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Category (0-15)")
) {
	int cat = lParam();

	if(!rdPtr->curShapeDef) return;

	if(cat < 0 || cat >= 16) return;

	rdPtr->curShapeDef->filter.categoryBits &= (~(1<<cat));
}
ACTION(
	/* ID */			78,
	/* Name */			"Shape - Add Mask (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Mask (0-15)")
) {
	int mask = lParam();

	if(!rdPtr->curShapeDef) return;

	if(mask < 0 || mask >= 16) return;

	rdPtr->curShapeDef->filter.maskBits |= (1<<mask);
}
ACTION(
	/* ID */			79,
	/* Name */			"Shape - Remove Mask (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Mask (0-15)")
) {
	int mask = lParam();

	if(!rdPtr->curShapeDef) return;

	if(mask < 0 || mask >= 16) return;

	rdPtr->curShapeDef->filter.maskBits &= (~(1<<mask));
}
ACTION(
	/* ID */			80,
	/* Name */			"Set Position and Angle of Body (%0) to (%1,%2), (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"Angle")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b2Vec2(x/rdPtr->scale,y/rdPtr->scale),angle*DEG_TO_RAD);
}
ACTION(
	/* ID */			81,
	/* Name */			"Set X Position of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Position")
) {
	LPRO obj = oParam();
	float x = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b2Vec2(x/rdPtr->scale,b->GetPosition().y),b->GetAngle());
}
ACTION(
	/* ID */			82,
	/* Name */			"Set Y Position of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Y Position")
) {
	LPRO obj = oParam();
	float y = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b2Vec2(b->GetPosition().x,y/rdPtr->scale),b->GetAngle());
}
ACTION(
	/* ID */			83,
	/* Name */			"Set Angle of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Angle")
) {
	LPRO obj = oParam();
	float angle = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b->GetPosition(),angle*DEG_TO_RAD);
}
ACTION(
	/* ID */			84,
	/* Name */			"Set Position and Angle of Body (%0) to (%1,%2), (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"Angle")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b2Vec2(x/rdPtr->scale,y/rdPtr->scale),angle*DEG_TO_RAD);
}
ACTION(
	/* ID */			85,
	/* Name */			"Set X Position of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"X Position")
) {
	int n = lParam();
	float x = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b2Vec2(x/rdPtr->scale,b->GetPosition().y),b->GetAngle());
}
ACTION(
	/* ID */			86,
	/* Name */			"Set Y Position of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Y Position")
) {
	int n = lParam();
	float y = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b2Vec2(b->GetPosition().x,y/rdPtr->scale),b->GetAngle());
}
ACTION(
	/* ID */			87,
	/* Name */			"Set Angle of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Angle")
) {
	int n = lParam();
	float angle = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetXForm(b->GetPosition(),angle*DEG_TO_RAD);
}
ACTION(
	/* ID */			88,
	/* Name */			"Set Linear Velocity of Body (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"X Velocity",PARAM_NUMBER,"Y Velocity")
) {
	int n = lParam();
	float xvel = fParam();
	float yvel = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearVelocity(b2Vec2(xvel,yvel));

	b->WakeUp();
}
ACTION(
	/* ID */			89,
	/* Name */			"Set Angular Velocity of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Angular Velocity")
) {
	int n = lParam();
	float avel = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetAngularVelocity(avel);

	b->WakeUp();
}
ACTION(
	/* ID */			90,
	/* Name */			"Set X Velocity of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"X Velocity")
) {
	int n = lParam();
	float xvel = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearVelocity(b2Vec2(xvel,b->GetLinearVelocity().y));

	b->WakeUp();
}
ACTION(
	/* ID */			91,
	/* Name */			"Set Y Velocity of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Y Velocity")
) {
	int n = lParam();
	float yvel = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearVelocity(b2Vec2(b->GetLinearVelocity().x,yvel));

	b->WakeUp();
}
ACTION(
	/* ID */			92,
	/* Name */			"Set Linear Velocity of Body (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Velocity",PARAM_NUMBER,"Y Velocity")
) {
	LPRO obj = oParam();
	float xvel = fParam();
	float yvel = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearVelocity(b2Vec2(xvel,yvel));

	b->WakeUp();
}
ACTION(
	/* ID */			93,
	/* Name */			"Set Angular Velocity of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Angular Velocity")
) {
	LPRO obj = oParam();
	float avel = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetAngularVelocity(avel);

	b->WakeUp();
}
ACTION(
	/* ID */			94,
	/* Name */			"Set X Velocity of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Velocity")
) {
	LPRO obj = oParam();
	float xvel = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearVelocity(b2Vec2(xvel,b->GetLinearVelocity().y));

	b->WakeUp();
}
ACTION(
	/* ID */			95,
	/* Name */			"Set Y Velocity of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Y Velocity")
) {
	LPRO obj = oParam();
	float yvel = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearVelocity(b2Vec2(b->GetLinearVelocity().x,yvel));

	b->WakeUp();
}
ACTION(
	/* ID */			96,
	/* Name */			"Apply Force to Body (%0), force (%1,%2), position (%3,%4), is local (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Force",PARAM_NUMBER,"Y Force",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"0: Is World Coordinate, 1: Is Local Coordinate")
) {
	LPRO obj = oParam();
	float fx = fParam();
	float fy = fParam();
	float x = fParam();
	float y = fParam();
	int loc = lParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2Vec2 coord(x/rdPtr->scale,y/rdPtr->scale);
	if(loc != 0)
		coord = b->GetWorldPoint(coord);

	b->ApplyForce(b2Vec2(fx,fy),coord);
}
ACTION(
	/* ID */			97,
	/* Name */			"Apply Impulse to Body (%0), impulse (%1,%2), position (%3,%4), is local (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Strength",PARAM_NUMBER,"Y Strength",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"0: Is World Coordinate, 1: Is Local Coordinate")
) {
	LPRO obj = oParam();
	float fx = fParam();
	float fy = fParam();
	float x = fParam();
	float y = fParam();
	int loc = lParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2Vec2 coord(x/rdPtr->scale,y/rdPtr->scale);
	if(loc != 0)
		coord = b->GetWorldPoint(coord);

	b->ApplyImpulse(b2Vec2(fx,fy),coord);
}
ACTION(
	/* ID */			98,
	/* Name */			"Apply Torque to Body (%0), torque (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Torque")
) {
	LPRO obj = oParam();
	float torq = fParam();
	
	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->ApplyTorque(torq);
}
ACTION(
	/* ID */			99,
	/* Name */			"Apply Force to Body (%0), force (%1,%2), position (%3,%4), is local (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"X Force",PARAM_NUMBER,"Y Force",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"0: Is World Coordinate, 1: Is Local Coordinate")
) {
	int n = lParam();
	float fx = fParam();
	float fy = fParam();
	float x = fParam();
	float y = fParam();
	int loc = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2Vec2 coord(x/rdPtr->scale,y/rdPtr->scale);
	if(loc != 0)
		coord = b->GetWorldPoint(coord);

	b->ApplyForce(b2Vec2(fx,fy),coord);
}
ACTION(
	/* ID */			100,
	/* Name */			"Apply Impulse to Body (%0), impulse (%1,%2), position (%3,%4), is local (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"X Strength",PARAM_NUMBER,"Y Strength",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"0: Is World Coordinate, 1: Is Local Coordinate")
) {
	int n = lParam();
	float fx = fParam();
	float fy = fParam();
	float x = fParam();
	float y = fParam();
	int loc = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2Vec2 coord(x/rdPtr->scale,y/rdPtr->scale);
	if(loc != 0)
		coord = b->GetWorldPoint(coord);

	b->ApplyImpulse(b2Vec2(fx,fy),coord);
}
ACTION(
	/* ID */			101,
	/* Name */			"Apply Torque to Body (%0), torque (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Torque")
) {
	int n = lParam();
	float torq = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->ApplyTorque(torq);
}
ACTION(
	/* ID */			102,
	/* Name */			"Enable Sleep for Body (%0), enable (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"0: Disable Sleep, 1: Enable Sleep")
) {
	int n = lParam();
	int sleep = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->AllowSleeping(sleep != 0);
}
ACTION(
	/* ID */			103,
	/* Name */			"Put Body (%0) to Sleep",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->PutToSleep();
}
ACTION(
	/* ID */			104,
	/* Name */			"Wake up Body (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->WakeUp();
}
ACTION(
	/* ID */			105,
	/* Name */			"Enable Sleep for Body (%0), enable (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"0: Disable Sleep, 1: Enable Sleep")
) {
	LPRO obj = oParam();
	int sleep = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->AllowSleeping(sleep != 0);
}
ACTION(
	/* ID */			106,
	/* Name */			"Put Body (%0) to Sleep",
	/* Flags */			0,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	LPRO obj = oParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->PutToSleep();
}
ACTION(
	/* ID */			107,
	/* Name */			"Wake up Body (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	LPRO obj = oParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->WakeUp();
}
ACTION(
	/* ID */			108,
	/* Name */			"Set Mass Data of Body (%0) to mass (%1), inertia (%2), center (%3,%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_OBJECT,"Object",PARAM_NUMBER,"Mass",PARAM_NUMBER,"Inertia",PARAM_NUMBER,"Center X",PARAM_NUMBER,"Center Y")
) {
	LPRO obj = oParam();
	float mass = fParam();
	float inertia = fParam();
	float x = fParam();
	float y = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = mass;
	massd.I = inertia;
	massd.center.Set(x/rdPtr->scale,y/rdPtr->scale);

	b->SetMass(&massd);
}
ACTION(
	/* ID */			109,
	/* Name */			"Set Mass of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Mass")
) {
	LPRO obj = oParam();
	float mass = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = mass;
	massd.I = b->GetInertia();
	massd.center = b->GetLocalCenter();

	b->SetMass(&massd);
}
ACTION(
	/* ID */			110,
	/* Name */			"Set Inertia of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Inertia")
) {
	LPRO obj = oParam();
	float inertia = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = b->GetMass();
	massd.I = inertia;
	massd.center = b->GetLocalCenter();

	b->SetMass(&massd);
}
ACTION(
	/* ID */			111,
	/* Name */			"Set Center of Mass of Body (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Center X",PARAM_NUMBER,"Center Y")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = b->GetMass();
	massd.I = b->GetInertia();
	massd.center = b2Vec2(x/rdPtr->scale,y/rdPtr->scale);

	b->SetMass(&massd);
}
ACTION(
	/* ID */			112,
	/* Name */			"Set Mass Data of Body (%0) to mass (%1), inertia (%2), center (%3,%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Mass",PARAM_NUMBER,"Inertia",PARAM_NUMBER,"Center X",PARAM_NUMBER,"Center Y")
) {
	int n = lParam();
	float mass = fParam();
	float inertia = fParam();
	float x = fParam();
	float y = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = mass;
	massd.I = inertia;
	massd.center.Set(x/rdPtr->scale,y/rdPtr->scale);

	b->SetMass(&massd);
}
ACTION(
	/* ID */			113,
	/* Name */			"Set Mass of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Mass")
) {
	int n = lParam();
	float mass = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = mass;
	massd.I = b->GetInertia();
	massd.center = b->GetLocalCenter();

	b->SetMass(&massd);
}
ACTION(
	/* ID */			114,
	/* Name */			"Set Inertia of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Inertia")
) {
	int n = lParam();
	float inertia = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = b->GetMass();
	massd.I = inertia;
	massd.center = b->GetLocalCenter();

	b->SetMass(&massd);
}
ACTION(
	/* ID */			115,
	/* Name */			"Set Center of Mass of Body (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Center X",PARAM_NUMBER,"Center Y")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = true;

	b2MassData massd;

	massd.mass = b->GetMass();
	massd.I = b->GetInertia();
	massd.center = b2Vec2(x/rdPtr->scale,y/rdPtr->scale);

	b->SetMass(&massd);
}
ACTION(
	/* ID */			116,
	/* Name */			"Set Mass Data of Body (%0) from Shapes",
	/* Flags */			0,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	LPRO obj = oParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = false;

	b->SetMassFromShapes();
}
ACTION(
	/* ID */			117,
	/* Name */			"Set Mass Data of Body (%0) from Shapes",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->GetUserData()->customMass = false;

	b->SetMassFromShapes();
}
ACTION(
	/* ID */			118,
	/* Name */			"Set Bullet of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"0: Disable Bullet, 1: Enable Bullet")
) {
	LPRO obj = oParam();
	int bullet = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetBullet(bullet != 0);
}
ACTION(
	/* ID */			119,
	/* Name */			"Set Bullet of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"0: Disable Bullet, 1: Enable Bullet")
) {
	int n = lParam();
	int bullet = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetBullet(bullet != 0);
}
ACTION(
	/* ID */			120,
	/* Name */			"Set Friction of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Friction")
) {
	LPRO obj = oParam();
	int shape = lParam();
	float friction = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetFriction(friction);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetFriction(friction);
}
ACTION(
	/* ID */			121,
	/* Name */			"Set Elasticity of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Elasticity")
) {
	LPRO obj = oParam();
	int shape = lParam();
	float restitution = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetRestitution(restitution);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetRestitution(restitution);
}
ACTION(
	/* ID */			122,
	/* Name */			"Set Collision Type of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Collision Type (0-31)")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int colltype = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->GetUserData()->collType = colltype;
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->GetUserData()->collType = colltype;
}
ACTION(
	/* ID */			123,
	/* Name */			"Set Friction of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Friction")
) {
	int n = lParam();
	int shape = lParam();
	float friction = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetFriction(friction);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetFriction(friction);
}
ACTION(
	/* ID */			124,
	/* Name */			"Set Elasticity of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Elasticity")
) {
	int n = lParam();
	int shape = lParam();
	float restitution = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetRestitution(restitution);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetRestitution(restitution);
}
ACTION(
	/* ID */			125,
	/* Name */			"Set Collision Type of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Collision Type (0-31)")
) {
	int n = lParam();
	int shape = lParam();
	int colltype = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->GetUserData()->collType = colltype;
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->GetUserData()->collType = colltype;
}
ACTION(
	/* ID */			126,
	/* Name */			"Set Group Index of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Group Index")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int gindex = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.groupIndex = (short)gindex;
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.groupIndex = (short)gindex;

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			127,
	/* Name */			"Set Category Bits of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Category Bits")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int category = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.categoryBits = (short)category;
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.categoryBits = (short)category;

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			128,
	/* Name */			"Set Mask Bits of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Mask Bits")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int mask = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.maskBits = (short)mask;
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.maskBits = (short)mask;

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			129,
	/* Name */			"Add Category (%2) to Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Category (0-15)")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int category = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(category < 0 || category >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.categoryBits |= (1<<category);
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.categoryBits |= (1<<category);

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			130,
	/* Name */			"Remove Category (%2) from Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Category (0-15)")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int category = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(category < 0 || category >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.categoryBits &= (~(1<<category));
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.categoryBits &= (~(1<<category));

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			131,
	/* Name */			"Add Mask (%2) to Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Mask (0-15)")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int mask = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(mask < 0 || mask >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.maskBits |= (1<<mask);
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.maskBits |= (1<<mask);

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			132,
	/* Name */			"Remove Mask (%2) from Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Mask (0-15)")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int mask = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(mask < 0 || mask >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.maskBits &= (~(1<<mask));
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.maskBits &= (~(1<<mask));

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			133,
	/* Name */			"Set Group Index of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Group Index")
) {
	int n = lParam();
	int shape = lParam();
	int gindex = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.groupIndex = (short)gindex;
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.groupIndex = (short)gindex;

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			134,
	/* Name */			"Set Category Bits of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Category Bits")
) {
	int n = lParam();
	int shape = lParam();
	int category = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.categoryBits = (short)category;
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.categoryBits = (short)category;

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			135,
	/* Name */			"Set Mask Bits of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Mask Bits")
) {
	int n = lParam();
	int shape = lParam();
	int mask = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.maskBits = (short)mask;
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.maskBits = (short)mask;

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			136,
	/* Name */			"Add Category (%2) to Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Category (0-15)")
) {
	int n = lParam();
	int shape = lParam();
	int category = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(category < 0 || category >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.categoryBits |= (1<<category);
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.categoryBits |= (1<<category);

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			137,
	/* Name */			"Remove Category (%2) from Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Category (0-15)")
) {
	int n = lParam();
	int shape = lParam();
	int category = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(category < 0 || category >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.categoryBits &= (~(1<<category));
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.categoryBits &= (~(1<<category));

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			138,
	/* Name */			"Add Mask (%2) to Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Mask (0-15)")
) {
	int n = lParam();
	int shape = lParam();
	int mask = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(mask < 0 || mask >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.maskBits |= (1<<mask);
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.maskBits |= (1<<mask);

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			139,
	/* Name */			"Remove Mask (%2) from Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Mask (0-15)")
) {
	int n = lParam();
	int shape = lParam();
	int mask = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(mask < 0 || mask >= 16) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			b2FilterData filter = s->GetFilterData();
			filter.maskBits &= (~(1<<mask));
			s->SetFilterData(filter);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	b2FilterData filter = s->GetFilterData();

	filter.maskBits &= (~(1<<mask));

	s->SetFilterData(filter);
}
ACTION(
	/* ID */			140,
	/* Name */			"Refilter Contacts for Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)")
) {
	LPRO obj = oParam();
	int shape = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			rdPtr->world->Refilter(s);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	rdPtr->world->Refilter(s);
}
ACTION(
	/* ID */			141,
	/* Name */			"Refilter Contacts for Shape (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)")
) {
	int n = lParam();
	int shape = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			rdPtr->world->Refilter(s);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	rdPtr->world->Refilter(s);
}
ACTION(
	/* ID */			142,
	/* Name */			"Quick Add Mouse Joint to Body (%0), Anchor (%1,%2), Max Force (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"Max Force")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	float maxforce = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2MouseJointDef def;
	def.target.Set(x/rdPtr->scale,y/rdPtr->scale);
	def.body1 = rdPtr->world->GetGroundBody();
	def.body2 = b;
	def.maxForce = maxforce;

	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			143,
	/* Name */			"Quick Add Mouse Joint to Body (%0), Anchor (%1,%2), Max Force (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"Max Force")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();
	float maxforce = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2MouseJointDef def;
	def.target.Set(x/rdPtr->scale,y/rdPtr->scale);
	def.body1 = rdPtr->world->GetGroundBody();
	def.body2 = b;
	def.maxForce = maxforce;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			144,
	/* Name */			"Remove Joint (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	int n = lParam();

	b2Joint* j = getJoint(n,rdPtr);

	if(!j) return;

	b2Body* b = getBody(j->GetUserData()->body1,rdPtr);
	b2Body* b2 = getBody(j->GetUserData()->body2,rdPtr);

	if(b) b->GetUserData()->numJoints--;
	if(b2) b2->GetUserData()->numJoints--;

	rdPtr->world->DestroyJoint(j);

	rdPtr->joints[n] = NULL;
}
ACTION(
	/* ID */			145,
	/* Name */			"Set Target of Mouse Joint (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Joint ID",PARAM_NUMBER,"Target X",PARAM_NUMBER,"Target Y")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();

	b2MouseJoint* j = (b2MouseJoint*)getJoint(n,rdPtr);

	if(!j) return;
	
	if(j->GetType() != e_mouseJoint) return;

	j->SetTarget(b2Vec2(x/rdPtr->scale,y/rdPtr->scale));
}
ACTION(
	/* ID */			146,
	/* Name */			"Quick Add Revolute Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Collide (%5), Reverse (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision",PARAM_NUMBER,"1: Reverse Body Order")
) {
	LPRO obj = oParam();
	int n2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	int collide = lParam();
	int reverse = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(reverse == 0)
	{
		local = 3-local;
		int temp = n;
		n = n2;
		n2 = temp;
	}

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2RevoluteJointDef def;
	def.Initialize(b,b2,anchor);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			147,
	/* Name */			"Quick Add Prismatic Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Angle (%5), Collide (%6), Reverse (%7)",
	/* Flags */			0,
	/* Params */		(8,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision",PARAM_NUMBER,"1: Reverse Body Order")
) {
	LPRO obj = oParam();
	int n2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float angle = fParam();
	int collide = lParam();
	int reverse = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(reverse == 0)
	{
		local = 3-local;
		int temp = n;
		n = n2;
		n2 = temp;
	}

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2PrismaticJointDef def;
	def.Initialize(b,b2,anchor,axis);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			148,
	/* Name */			"Quick Add Distance Joint Between Bodies (%0) and (%1), First Anchor (%2,%3), is Local (%4), Second Anchor (%5,%6), is Local (%7), Collide (%8), Reverse (%9)",
	/* Flags */			0,
	/* Params */		(10,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision",PARAM_NUMBER,"1: Reverse Body Order")
) {
	LPRO obj = oParam();
	int n2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();
	int collide = lParam();
	int reverse = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(reverse == 0)
	{
		int temp = n;
		n = n2;
		n2 = temp;
		temp = local;
		local = local2;
		local2 = temp;
	}

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b2->GetWorldPoint(anchor2);

	b2DistanceJointDef def;
	def.Initialize(b,b2,anchor,anchor2);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			149,
	/* Name */			"Quick Add Line Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Angle (%5), Collide (%6), Reverse (%7)",
	/* Flags */			0,
	/* Params */		(8,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision",PARAM_NUMBER,"1: Reverse Body Order")
) {
	LPRO obj = oParam();
	int n2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float angle = fParam();
	int collide = lParam();
	int reverse = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(reverse == 0)
	{
		local = 3-local;
		int temp = n;
		n = n2;
		n2 = temp;
	}

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2LineJointDef def;
	def.Initialize(b,b2,anchor,axis);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			150,
	/* Name */			"Quick Add Pulley Joint Between Bodies (%0) and (%1), First Anchor (%2,%3), is Local (%4), Second Anchor (%5,%6), is Local (%7), First Ground Anchor (%8,%9), Second Ground Anchor (%A,%B), Ratio (%C), Collide (%D), Reverse (%E)",
	/* Flags */			0,
	/* Params */		(15,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"First Ground Anchor X",PARAM_NUMBER,"First Ground Anchor Y",PARAM_NUMBER,"Second Ground Anchor X",PARAM_NUMBER,"Second Ground Anchor Y",PARAM_NUMBER,"Ratio",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision",PARAM_NUMBER,"1: Reverse Body Order")
) {
	LPRO obj = oParam();
	int n2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();
	float gx = fParam();
	float gy = fParam();
	float gx2 = fParam();
	float gy2 = fParam();
	float ratio = fParam();
	int collide = lParam();
	int reverse = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(reverse == 0)
	{
		int temp = n;
		n = n2;
		n2 = temp;
		temp = local;
		local = local2;
		local2 = temp;
	}

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b2->GetWorldPoint(anchor2);

	b2Vec2 ganchor(gx/rdPtr->scale,gy/rdPtr->scale);
	b2Vec2 ganchor2(gx2/rdPtr->scale,gy2/rdPtr->scale);

	b2PulleyJointDef def;
	def.Initialize(b,b2,ganchor,ganchor2,anchor,anchor2,ratio,0.0f);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			151,
	/* Name */			"Quick Add Revolute Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Collide (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	int n2 = lParam();
	int n = lParam();
	float x = fParam();
	float y = fParam();
	int local = 3-lParam();
	int collide = lParam();

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2RevoluteJointDef def;
	def.Initialize(b,b2,anchor);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			152,
	/* Name */			"Quick Add Prismatic Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Angle (%5), Collide (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	int n2 = lParam();
	int n = lParam();
	float x = fParam();
	float y = fParam();
	int local = 3-lParam();
	float angle = fParam();
	int collide = lParam();

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2PrismaticJointDef def;
	def.Initialize(b,b2,anchor,axis);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			153,
	/* Name */			"Quick Add Distance Joint Between Bodies (%0) and (%1), First Anchor (%2,%3), is Local (%4), Second Anchor (%5,%6), is Local (%7), Collide (%8)",
	/* Flags */			0,
	/* Params */		(9,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	int n = lParam();
	int n2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();
	int collide = lParam();

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b2->GetWorldPoint(anchor2);

	b2DistanceJointDef def;
	def.Initialize(b,b2,anchor,anchor2);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;

	//Debug("%d %d %f\n%d %d %f",n,b->GetUserData()->ID,b->GetMass(),n2,b2->GetUserData()->ID,b->GetMass());
}
ACTION(
	/* ID */			154,
	/* Name */			"Quick Add Line Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Angle (%5), Collide (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	int n2 = lParam();
	int n = lParam();
	float x = fParam();
	float y = fParam();
	int local = 3-lParam();
	float angle = fParam();
	int collide = lParam();

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2LineJointDef def;
	def.Initialize(b,b2,anchor,axis);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			155,
	/* Name */			"Quick Add Pulley Joint Between Bodies (%0) and (%1), First Anchor (%2,%3), is Local (%4), Second Anchor (%5,%6), is Local (%7), First Ground Anchor (%8,%9), Second Ground Anchor (%A,%B), Ratio (%C), Collide (%D)",
	/* Flags */			0,
	/* Params */		(14,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"First Ground Anchor X",PARAM_NUMBER,"First Ground Anchor Y",PARAM_NUMBER,"Second Ground Anchor X",PARAM_NUMBER,"Second Ground Anchor Y",PARAM_NUMBER,"Ratio",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	int n2 = lParam();
	int n = lParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float gx2 = fParam();
	float gy2 = fParam();
	float gx = fParam();
	float gy = fParam();
	float ratio = fParam();
	int collide = lParam();

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b2->GetWorldPoint(anchor2);

	b2Vec2 ganchor(gx/rdPtr->scale,gy/rdPtr->scale);
	b2Vec2 ganchor2(gx2/rdPtr->scale,gy2/rdPtr->scale);

	b2PulleyJointDef def;
	def.Initialize(b,b2,ganchor,ganchor2,anchor,anchor2,ratio,0.0f);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			156,
	/* Name */			"Quick Add Revolute Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Collide (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	LPRO obj2 = oParam();
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int local = 3-lParam();
	int collide = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(!obj2) return;

	if(!hasAttachment(obj2,rdPtr)) return;

	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2RevoluteJointDef def;
	def.Initialize(b,b2,anchor);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			157,
	/* Name */			"Quick Add Prismatic Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Angle (%5), Collide (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	LPRO obj2 = oParam();
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int local = 3-lParam();
	float angle = fParam();
	int collide = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(!obj2) return;

	if(!hasAttachment(obj2,rdPtr)) return;

	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2PrismaticJointDef def;
	def.Initialize(b,b2,anchor,axis);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			158,
	/* Name */			"Quick Add Distance Joint Between Bodies (%0) and (%1), First Anchor (%2,%3), is Local (%4), Second Anchor (%5,%6), is Local (%7), Collide (%8)",
	/* Flags */			0,
	/* Params */		(9,PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	LPRO obj2 = oParam();
	LPRO obj = oParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	int collide = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(!obj2) return;

	if(!hasAttachment(obj2,rdPtr)) return;

	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b2->GetWorldPoint(anchor2);

	b2DistanceJointDef def;
	def.Initialize(b,b2,anchor,anchor2);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			159,
	/* Name */			"Quick Add Line Joint Between Bodies (%0) and (%1), Anchor (%2,%3), Local to (%4), Angle (%5), Collide (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to First Body, 2: Local to Second Body",PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	LPRO obj2 = oParam();
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int local = 3-lParam();
	float angle = fParam();
	int collide = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(!obj2) return;

	if(!hasAttachment(obj2,rdPtr)) return;

	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	switch(local)
	{
	case 1:
		anchor = b->GetWorldPoint(anchor);
		break;
	case 2:
		anchor = b2->GetWorldPoint(anchor);
		break;
	}

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2LineJointDef def;
	def.Initialize(b,b2,anchor,axis);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			160,
	/* Name */			"Quick Add Pulley Joint Between Bodies (%0) and (%1), First Anchor (%2,%3), is Local (%4), Second Anchor (%5,%6), is Local (%7), First Ground Anchor (%8,%9), Second Ground Anchor (%A,%B), Ratio (%C), Collide (%D)",
	/* Flags */			0,
	/* Params */		(14,PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"First Ground Anchor X",PARAM_NUMBER,"First Ground Anchor Y",PARAM_NUMBER,"Second Ground Anchor X",PARAM_NUMBER,"Second Ground Anchor Y",PARAM_NUMBER,"Ratio",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	LPRO obj2 = oParam();
	LPRO obj = oParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float gx2 = fParam();
	float gy2 = fParam();
	float gx = fParam();
	float gy = fParam();
	float ratio = fParam();
	int collide = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(!obj2) return;

	if(!hasAttachment(obj2,rdPtr)) return;

	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b2->GetWorldPoint(anchor2);

	b2Vec2 ganchor(gx/rdPtr->scale,gy/rdPtr->scale);
	b2Vec2 ganchor2(gx2/rdPtr->scale,gy2/rdPtr->scale);

	b2PulleyJointDef def;
	def.Initialize(b,b2,ganchor,ganchor2,anchor,anchor2,ratio,0.0f);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			161,
	/* Name */			"Quick Add Gear Joint Between Body (%0), Joint (%1) and Body (%2), Joint (%3), Ratio (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"First Joint ID",PARAM_NUMBER,"Second Body ID",PARAM_NUMBER,"Second Joint ID",PARAM_NUMBER,"Ratio")
) {
	int n2 = lParam();
	int jn2 = lParam();
	int n = lParam();
	int jn = lParam();
	float ratio = fParam();

	b2Body* b1 = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);
	b2Joint* j1 = getJoint(jn,rdPtr);
	b2Joint* j2 = getJoint(jn2,rdPtr);

	if(!j1 || !j2 || !b1 || !b2) return;

	if((b1 != j1->GetBody1() && b1 != j1->GetBody2()) || (b2 != j2->GetBody1() && b2 != j2->GetBody2())) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2GearJointDef def;
	if(b1 != j1->GetBody1())
		def.body1 = j1->GetBody2();
	else
		def.body1 = j1->GetBody1();

	if(b2 != j2->GetBody1())
		def.body2 = j2->GetBody2();
	else
		def.body2 = j2->GetBody1();

	def.joint1 = j1;
	def.joint2 = j2;
	def.ratio = ratio;
	
	def.userData.body1 = def.body1->GetUserData()->ID;
	def.userData.body2 = def.body2->GetUserData()->ID;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	def.body1->GetUserData()->numJoints++;
	def.body2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			162,
	/* Name */			"Begin Revolute Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curJointDef) delete rdPtr->curJointDef;
	rdPtr->curJointDef = new b2RevoluteJointDef;
}
ACTION(
	/* ID */			163,
	/* Name */			"Begin Prismatic Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curJointDef) delete rdPtr->curJointDef;
	rdPtr->curJointDef = new b2PrismaticJointDef;
}
ACTION(
	/* ID */			164,
	/* Name */			"Begin Distance Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curJointDef) delete rdPtr->curJointDef;
	rdPtr->curJointDef = new b2DistanceJointDef;
}
ACTION(
	/* ID */			165,
	/* Name */			"Begin Line Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curJointDef) delete rdPtr->curJointDef;
	rdPtr->curJointDef = new b2LineJointDef;
}
ACTION(
	/* ID */			166,
	/* Name */			"Begin Pulley Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curJointDef) delete rdPtr->curJointDef;
	rdPtr->curJointDef = new b2PulleyJointDef;
}
ACTION(
	/* ID */			167,
	/* Name */			"Begin Mouse Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curJointDef) delete rdPtr->curJointDef;
	rdPtr->curJointDef = new b2MouseJointDef;
}
ACTION(
	/* ID */			168,
	/* Name */			"Begin Gear Joint",
	/* Flags */			0,
	/* Params */		(0)
) {
	if(rdPtr->curJointDef) delete rdPtr->curJointDef;
	rdPtr->curJointDef = new b2GearJointDef;
}
ACTION(
	/* ID */			169,
	/* Name */			"Load Joint Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Definition ID")
) {
	int n = lParam();

	copyDef(getJointDef(n,rdPtr),rdPtr->curJointDef);
}
ACTION(
	/* ID */			170,
	/* Name */			"Store Current Joint Data in Joint Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Definition ID")
) {
	int n = lParam();

	if(!isJointDef(n,rdPtr)) return;

	copyDef(rdPtr->curJointDef,rdPtr->jDefs[n]);
}
ACTION(
	/* ID */			171,
	/* Name */			"Remove Joint Definition (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Definition ID")
) {
	int n = lParam();

	if(!isJointDef(n,rdPtr)) return;

	if(!rdPtr->jDefs[n]) return;

	delete rdPtr->jDefs[n];

	rdPtr->jDefs[n] = NULL;
}
ACTION(
	/* ID */			172,
	/* Name */			"Create Joint at Body (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Body ID")
) {
	int n = lParam();

	if(!rdPtr->curJointDef) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	rdPtr->curJointDef->body1 = rdPtr->world->GetGroundBody();
	rdPtr->curJointDef->body2 = b;

	if(!setJointDefAnchor(rdPtr->curJointDef,rdPtr)) return;

	rdPtr->curJointDef->userData.body1 = -2;
	rdPtr->curJointDef->userData.body2 = n;
	rdPtr->curJointDef->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(rdPtr->curJointDef)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			173,
	/* Name */			"Create Joint at Body (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	LPRO obj = oParam();

	if(!rdPtr->curJointDef) return;

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];
	
	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	rdPtr->curJointDef->body1 = rdPtr->world->GetGroundBody();
	rdPtr->curJointDef->body2 = b;

	if(!setJointDefAnchor(rdPtr->curJointDef,rdPtr)) return;

	rdPtr->curJointDef->userData.body1 = -2;
	rdPtr->curJointDef->userData.body2 = n;
	rdPtr->curJointDef->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(rdPtr->curJointDef)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			174,
	/* Name */			"Create Joint Between Bodies (%0) ad (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID")
) {
	int n2 = lParam();
	int n = lParam();

	if(!rdPtr->curJointDef) return;

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	rdPtr->curJointDef->body1 = b;
	rdPtr->curJointDef->body2 = b2;

	if(!setJointDefAnchor(rdPtr->curJointDef,rdPtr)) return;

	rdPtr->curJointDef->userData.body1 = n;
	rdPtr->curJointDef->userData.body2 = n2;
	rdPtr->curJointDef->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(rdPtr->curJointDef)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			175,
	/* Name */			"Create Joint Between Bodies (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object")
) {
	LPRO obj2 = oParam();
	LPRO obj = oParam();

	if(!rdPtr->curJointDef) return;

	if(!obj || !obj2) return;

	if(!hasAttachment(obj,rdPtr) || !hasAttachment(obj2,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];
	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];
	
	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	rdPtr->curJointDef->body1 = b;
	rdPtr->curJointDef->body2 = b2;

	if(!setJointDefAnchor(rdPtr->curJointDef,rdPtr)) return;

	rdPtr->curJointDef->userData.body1 = n;
	rdPtr->curJointDef->userData.body2 = n2;
	rdPtr->curJointDef->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(rdPtr->curJointDef)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			176,
	/* Name */			"Joint - Enable Internal Collision (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision")
) {
	int coll = lParam();

	b2JointDef* j = rdPtr->curJointDef;

	if(!j) return;

	j->collideConnected = coll != 0;
}
ACTION(
	/* ID */			177,
	/* Name */			"Quick Add Gear Joint Between Body (%0), Joint (%1) and Body (%2), Joint (%3), Ratio (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_OBJECT,"First Object",PARAM_NUMBER,"First Joint ID",PARAM_OBJECT,"Second Object",PARAM_NUMBER,"Second Joint ID",PARAM_NUMBER,"Ratio")
) {
	LPRO obj2 = oParam();
	int jn2 = lParam();
	LPRO obj = oParam();
	int jn = lParam();
	float ratio = fParam();

	if(!obj || !obj2) return;

	if(!hasAttachment(obj,rdPtr) || !hasAttachment(obj2,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];
	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];

	b2Body* b1 = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);
	b2Joint* j1 = getJoint(jn,rdPtr);
	b2Joint* j2 = getJoint(jn2,rdPtr);

	if(!j1 || !j2 || !b1 || !b2) return;

	if((b1 != j1->GetBody1() && b1 != j1->GetBody2()) || (b2 != j2->GetBody1() && b2 != j2->GetBody2())) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2GearJointDef def;
	if(b1 != j1->GetBody1())
		def.body1 = j1->GetBody2();
	else
		def.body1 = j1->GetBody1();

	if(b2 != j2->GetBody1())
		def.body2 = j2->GetBody2();
	else
		def.body2 = j2->GetBody1();

	def.joint1 = j1;
	def.joint2 = j2;
	def.ratio = ratio;
	
	def.userData.body1 = def.body1->GetUserData()->ID;
	def.userData.body2 = def.body2->GetUserData()->ID;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	def.body1->GetUserData()->numJoints++;
	def.body2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}

ACTION(
	/* ID */			178,
	/* Name */			"Revolute Joint - Set First Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2RevoluteJointDef* j = (b2RevoluteJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_revoluteJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor2 = anchor;
	j->local2 = local;
}
ACTION(
	/* ID */			179,
	/* Name */			"Revolute Joint - Set Second Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2RevoluteJointDef* j = (b2RevoluteJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_revoluteJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor1 = anchor;
	j->local1 = local;
}
ACTION(
	/* ID */			180,
	/* Name */			"Revolute Joint - Set Reference Angle to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Reference Angle")
) {
	float angle = fParam();

	b2RevoluteJointDef* j = (b2RevoluteJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_revoluteJoint) return;

	j->referenceAngle = angle * DEG_TO_RAD;
}
ACTION(
	/* ID */			181,
	/* Name */			"Revolute Joint - Enable Limits (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disabe Limits, 1: Enable Limits")
) {
	int limit = lParam();

	b2RevoluteJointDef* j = (b2RevoluteJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_revoluteJoint) return;

	j->enableLimit = limit != 0;
}
ACTION(
	/* ID */			182,
	/* Name */			"Revolute Joint - Enable Motor (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disabe Motor, 1: Enable Motor")
) {
	int motor = lParam();

	b2RevoluteJointDef* j = (b2RevoluteJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_revoluteJoint) return;

	j->enableMotor = motor != 0;
}
ACTION(
	/* ID */			183,
	/* Name */			"Revolute Joint - Set Limits to (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	float lolimit = fParam();
	float hilimit = fParam();

	b2RevoluteJointDef* j = (b2RevoluteJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_revoluteJoint) return;

	j->upperAngle = -hilimit * DEG_TO_RAD;
	j->lowerAngle = -lolimit * DEG_TO_RAD;
}
ACTION(
	/* ID */			184,
	/* Name */			"Revolute Joint - Set Motor to Speed (%0), Max Torque (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Torque")
) {
	float speed = fParam();
	float torque = fParam();

	b2RevoluteJointDef* j = (b2RevoluteJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_revoluteJoint) return;

	j->motorSpeed = speed;
	j->maxMotorTorque = torque;
}
ACTION(
	/* ID */			185,
	/* Name */			"Create Joint Between Bodies (%0) and (%1), reverse (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"1: Reverse Body Order")
) {
	LPRO obj = oParam();
	int n2 = lParam();
	int reverse = lParam();

	if(!rdPtr->curJointDef) return;

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(reverse == 0)
	{
		int temp = n;
		n = n2;
		n2 = temp;
	}
	
	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	rdPtr->curJointDef->body1 = b;
	rdPtr->curJointDef->body2 = b2;

	if(!setJointDefAnchor(rdPtr->curJointDef,rdPtr)) return;

	rdPtr->curJointDef->userData.body1 = n;
	rdPtr->curJointDef->userData.body2 = n2;
	rdPtr->curJointDef->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(rdPtr->curJointDef)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			186,
	/* Name */			"Register Collision for Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	if(type1 < 0 || type1 >= 32 || type2 < 0 || type2 >= 32) return;

	if(type1 > type2)
		rdPtr->collReg[type2][type1] = 1;
	else
		rdPtr->collReg[type1][type2] = 1;
}
ACTION(
	/* ID */			187,
	/* Name */			"Disable Collision for Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	if(type1 < 0 || type1 >= 32 || type2 < 0 || type2 >= 32) return;

	if(type1 > type2)
		rdPtr->collReg[type2][type1] = -1;
	else
		rdPtr->collReg[type1][type2] = -1;
}
ACTION(
	/* ID */			188,
	/* Name */			"Reset Collision for Types (%0) and (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"First Collision Type",PARAM_NUMBER,"Second Collision Type")
) {
	int type1 = lParam();
	int type2 = lParam();

	if(type1 < 0 || type1 >= 32 || type2 < 0 || type2 >= 32) return;

	if(type1 > type2)
		rdPtr->collReg[type2][type1] = 0;
	else
		rdPtr->collReg[type1][type2] = 0;
}
ACTION(
	/* ID */			189,
	/* Name */			"Attach Object (%0) to Body (%1), Offset (%2,%3) Angle Offset (%4) is Local (%5), rotation (%6) destruction (%7)",
	/* Flags */			0,
	/* Params */		(8,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Angle Offset",PARAM_NUMBER,"0: Object Current Position, 1: Local Position",PARAM_NUMBER,"Rotation (0: None, 1: Fast, 2: Quality)",PARAM_NUMBER,"Link Destruction")
) {
	LPRO obj = oParam();
	int n = lParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();
	int local = lParam();
	int rot = lParam();
	int dest = lParam();

	if(!obj) return;

	if(hasAttachment(obj,rdPtr)) removeAttachment(obj,rdPtr);

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2Vec2 offset;
	float aoff;

	if(local == 1)
	{
		offset.Set(x/rdPtr->scale,y/rdPtr->scale);
		aoff = angle * DEG_TO_RAD;
	}
	else
	{
		offset = b->GetLocalPoint( b2Vec2( ((float)obj->roHo.hoX + x)/rdPtr->scale, ((float)obj->roHo.hoY + y)/rdPtr->scale) );
		if(rdPtr->floatAngles)
			aoff = (angle - obj->roc.rcAngleF) * DEG_TO_RAD;
		else
			aoff = (angle - obj->roc.rcAngleI) * DEG_TO_RAD;
	}

	b->GetUserData()->AddObject(obj->roHo.hoNumber,offset,rot,dest,aoff);

	rdPtr->AttachedObjectIDs[obj->roHo.hoNumber] = n;
}
ACTION(
	/* ID */			190,
	/* Name */			"Detach Object (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_OBJECT,"Object")
) {
	LPRO obj = oParam();

	if(!obj) return;

	if(hasAttachment(obj,rdPtr)) removeAttachment(obj,rdPtr);
}
ACTION(
	/* ID */			191,
	/* Name */			"Start Debug Draw in Overlay (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Overlay Adress")
) {
	rdPtr->world->SetDebugDraw(rdPtr->DD);
}
ACTION(
	/* ID */			192,
	/* Name */			"Stop Debug Draw",
	/* Flags */			0,
	/* Params */		(0)
) {
	rdPtr->world->SetDebugDraw(NULL);
}
ACTION(
	/* ID */			193,
	/* Name */			"Set Debug Draw Flags to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Debug Draw Flags")
) {
	int flags = lParam();

	rdPtr->DD->SetFlags(flags);
}

ACTION(
	/* ID */			194,
	/* Name */			"Quick Add Gear Joint Between Body (%0), Joint (%1) and Body (%2), Joint (%3), Ratio (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_OBJECT,"First Object",PARAM_NUMBER,"First Joint ID",PARAM_OBJECT,"Second Body ID",PARAM_NUMBER,"Second Joint ID",PARAM_NUMBER,"Ratio")
) {
	LPRO obj = oParam();
	int jn2 = lParam();
	int n = lParam();
	int jn = lParam();
	float ratio = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n2 = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b1 = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);
	b2Joint* j1 = getJoint(jn,rdPtr);
	b2Joint* j2 = getJoint(jn2,rdPtr);

	if(!j1 || !j2 || !b1 || !b2) return;

	if((b1 != j1->GetBody1() && b1 != j1->GetBody2()) || (b2 != j2->GetBody1() && b2 != j2->GetBody2())) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2GearJointDef def;
	if(b1 != j1->GetBody1())
		def.body1 = j1->GetBody2();
	else
		def.body1 = j1->GetBody1();

	if(b2 != j2->GetBody1())
		def.body2 = j2->GetBody2();
	else
		def.body2 = j2->GetBody1();

	def.joint1 = j1;
	def.joint2 = j2;
	def.ratio = ratio;
	
	def.userData.body1 = def.body1->GetUserData()->ID;
	def.userData.body2 = def.body2->GetUserData()->ID;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	def.body1->GetUserData()->numJoints++;
	def.body2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			195,
	/* Name */			"Prismatic Joint - Set First Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_prismaticJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor2 = anchor;
	j->local2 = local;
}
ACTION(
	/* ID */			196,
	/* Name */			"Prismatic Joint - Set Second Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_prismaticJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor1 = anchor;
	j->local1 = local;
}
ACTION(
	/* ID */			197,
	/* Name */			"Prismatic Joint - Set Reference Angle to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Reference Angle")
) {
	float angle = fParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_prismaticJoint) return;

	j->referenceAngle = angle * DEG_TO_RAD;
}
ACTION(
	/* ID */			198,
	/* Name */			"Prismatic Joint - Enable Limits (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disabe Limits, 1: Enable Limits")
) {
	int limit = lParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_prismaticJoint) return;

	j->enableLimit = limit != 0;
}
ACTION(
	/* ID */			199,
	/* Name */			"Prismatic Joint - Enable Motor (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disabe Motor, 1: Enable Motor")
) {
	int motor = lParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_prismaticJoint) return;

	j->enableMotor = motor != 0;
}
ACTION(
	/* ID */			200,
	/* Name */			"Prismatic Joint - Set Limits to (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	float lolimit = fParam();
	float hilimit = fParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_prismaticJoint) return;

	j->upperTranslation = hilimit / rdPtr->scale;
	j->lowerTranslation = lolimit / rdPtr->scale;
}
ACTION(
	/* ID */			201,
	/* Name */			"Prismatic Joint - Set Motor to Speed (%0), Max Force (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	float speed = fParam();
	float force = fParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;
 
	if(j->type != e_prismaticJoint) return;

	j->motorSpeed = speed;
	j->maxMotorForce = force;
}
ACTION(
	/* ID */			202,
	/* Name */			"Prismatic Joint - Set Transtation Angle to (%0), Local to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: World Angle, 1: Local to First Body, 2: Local to Second Body")
) {
	float angle = fParam();
	int local = lParam();

	b2PrismaticJointDef* j = (b2PrismaticJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_prismaticJoint) return;

	j->angle = angle * DEG_TO_RAD;
	j->alocal = local;
}
ACTION(
	/* ID */			203,
	/* Name */			"Line Joint - Set First Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2LineJointDef* j = (b2LineJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_lineJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor2 = anchor;
	j->local2 = local;
}
ACTION(
	/* ID */			204,
	/* Name */			"Line Joint - Set Second Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2LineJointDef* j = (b2LineJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_lineJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor1 = anchor;
	j->local1 = local;
}
ACTION(
	/* ID */			205,
	/* Name */			"World - Enable Automatic Update (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Enable, 0: Disable")
) {
	int flag = lParam();

	rdPtr->autoUpdate = flag != 0;
}
ACTION(
	/* ID */			206,
	/* Name */			"Line Joint - Enable Limits (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disabe Limits, 1: Enable Limits")
) {
	int limit = lParam();

	b2LineJointDef* j = (b2LineJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_lineJoint) return;

	j->enableLimit = limit != 0;
}
ACTION(
	/* ID */			207,
	/* Name */			"Line Joint - Enable Motor (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"0: Disabe Motor, 1: Enable Motor")
) {
	int motor = lParam();

	b2LineJointDef* j = (b2LineJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_lineJoint) return;

	j->enableMotor = motor != 0;
}
ACTION(
	/* ID */			208,
	/* Name */			"Line Joint - Set Limits to (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	float lolimit = fParam();
	float hilimit = fParam();

	b2LineJointDef* j = (b2LineJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_lineJoint) return;

	j->upperTranslation = hilimit / rdPtr->scale;
	j->lowerTranslation = lolimit / rdPtr->scale;
}
ACTION(
	/* ID */			209,
	/* Name */			"Line Joint - Set Motor to Speed (%0), Max Force (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	float speed = fParam();
	float force = fParam();

	b2LineJointDef* j = (b2LineJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_lineJoint) return;

	j->motorSpeed = speed;
	j->maxMotorForce = force;
}
ACTION(
	/* ID */			210,
	/* Name */			"Line Joint - Set Transtation Angle to (%0), Local to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Translation Angle",PARAM_NUMBER,"0: World Angle, 1: Local to First Body, 2: Local to Second Body")
) {
	float angle = fParam();
	int local = lParam();

	b2LineJointDef* j = (b2LineJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_lineJoint) return;

	j->angle = angle * DEG_TO_RAD;
	j->alocal = local;
}
ACTION(
	/* ID */			211,
	/* Name */			"Distance Joint - Set First Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2DistanceJointDef* j = (b2DistanceJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_distanceJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor2 = anchor;
	j->local2 = local;
}
ACTION(
	/* ID */			212,
	/* Name */			"Distance Joint - Set Second Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2DistanceJointDef* j = (b2DistanceJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_distanceJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor1 = anchor;
	j->local1 = local;
}
ACTION(
	/* ID */			213,
	/* Name */			"Distance Joint - Set Length to (%0), absolute (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Length",PARAM_NUMBER,"0: Additional Length, 1: Absolute Length")
) {
	float length = fParam();
	int absolute = lParam();

	b2DistanceJointDef* j = (b2DistanceJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_distanceJoint) return;
	
	j->alength = length / rdPtr->scale;
	j->abslen = absolute;
}
ACTION(
	/* ID */			214,
	/* Name */			"Distance Joint - Set Frequency to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Frequency")
) {
	float freq = fParam();

	b2DistanceJointDef* j = (b2DistanceJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_distanceJoint) return;
	
	j->frequencyHz = freq;
}
ACTION(
	/* ID */			215,
	/* Name */			"Distance Joint - Set Damping to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Damping")
) {
	float damp = fParam();

	b2DistanceJointDef* j = (b2DistanceJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_distanceJoint) return;
	
	j->dampingRatio = damp;
}


ACTION(
	/* ID */			216,
	/* Name */			"Mouse Joint - Set Anchor to (%0,%1), is Local (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2MouseJointDef* j = (b2MouseJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_mouseJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor = anchor;
	j->local = local;
}
ACTION(
	/* ID */			217,
	/* Name */			"Mouse Joint - Set Frequency to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Frequency")
) {
	float freq = fParam();

	b2MouseJointDef* j = (b2MouseJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_mouseJoint) return;
	
	j->frequencyHz = freq;
}
ACTION(
	/* ID */			218,
	/* Name */			"Mouse Joint - Set Damping to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Damping")
) {
	float damp = fParam();

	b2MouseJointDef* j = (b2MouseJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_mouseJoint) return;
	
	j->dampingRatio = damp;
}
ACTION(
	/* ID */			219,
	/* Name */			"Mouse Joint - Set Max Force to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Max Force")
) {
	float force = fParam();

	b2MouseJointDef* j = (b2MouseJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_mouseJoint) return;
	
	j->maxForce = force;
}
ACTION(
	/* ID */			220,
	/* Name */			"Gear Joint - Set First Joint to (%0), from Body (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Joint",PARAM_NUMBER,"0: Joint ID, 1: Body Joint Number")
) {
	int n = lParam();
	int local = lParam();

	b2GearJointDef* j = (b2GearJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_gearJoint) return;
	
	j->joint2n = n;
	j->local2 = local;
}
ACTION(
	/* ID */			221,
	/* Name */			"Gear Joint - Set Second Joint to (%0), from Body (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Joint",PARAM_NUMBER,"0: Joint ID, 1: Body Joint Number")
) {
	int n = lParam();
	int local = lParam();

	b2GearJointDef* j = (b2GearJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_gearJoint) return;
	
	j->joint1n = n;
	j->local1 = local;
}
ACTION(
	/* ID */			222,
	/* Name */			"Gear Joint - Set Ratio to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Ratio")
) {
	float ratio = fParam();

	b2GearJointDef* j = (b2GearJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_gearJoint) return;
	
	j->ratio = ratio;
}




ACTION(
	/* ID */			223,
	/* Name */			"Pulley Joint - Set First Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2PulleyJointDef* j = (b2PulleyJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_pulleyJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor2 = anchor;
	j->local2 = local;
}
ACTION(
	/* ID */			224,
	/* Name */			"Pulley Joint - Set Second Body Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2PulleyJointDef* j = (b2PulleyJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_pulleyJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->anchor1 = anchor;
	j->local1 = local;
}
ACTION(
	/* ID */			225,
	/* Name */			"Pulley Joint - Set First Ground Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2PulleyJointDef* j = (b2PulleyJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_pulleyJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->ganchor2 = anchor;
	j->glocal2 = local;
}
ACTION(
	/* ID */			226,
	/* Name */			"Pulley Joint - Set Second Ground Anchor to (%0,%1), Local to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local to Own Body, 2: Local to Other Body")
) {
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2PulleyJointDef* j = (b2PulleyJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_pulleyJoint) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);
	
	j->ganchor1 = anchor;
	j->glocal1 = local;
}
ACTION(
	/* ID */			227,
	/* Name */			"Pulley Joint - Set First Max Length to (%0), absolute (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Max Length",PARAM_NUMBER,"0: Additional Length, 1: Absolute Length")
) {
	float length = fParam();
	int absolute = lParam();

	b2PulleyJointDef* j = (b2PulleyJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_pulleyJoint) return;
	
	j->mlength2 = length / rdPtr->scale;
	j->mlocal2 = absolute;
}
ACTION(
	/* ID */			228,
	/* Name */			"Pulley Joint - Set Second Max Length to (%0), absolute (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Max Length",PARAM_NUMBER,"0: Additional Length, 1: Absolute Length")
) {
	float length = fParam();
	int absolute = lParam();

	b2PulleyJointDef* j = (b2PulleyJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_pulleyJoint) return;
	
	j->mlength1 = length / rdPtr->scale;
	j->mlocal1 = absolute;
}
ACTION(
	/* ID */			229,
	/* Name */			"Pulley Joint - Set Ratio to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Ratio")
) {
	float ratio = fParam();

	b2PulleyJointDef* j = (b2PulleyJointDef*)rdPtr->curJointDef;

	if(!j) return;

	if(j->type != e_pulleyJoint) return;
	
	j->ratio = ratio;
}
ACTION(
	/* ID */			230,
	/* Name */			"Revolute Joint - Set Motor of Joint (%0) to Speed (%1), Torque (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Joint ID",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Torque")
) {
	int n = lParam();
	float speed = fParam();
	float torque = fParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorTorque(torque);
}
ACTION(
	/* ID */			231,
	/* Name */			"Revolute Joint - Disable Motor for Joint (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	int n = lParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			232,
	/* Name */			"Revolute Joint - Set Limits of Joint (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Joint ID",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableLimit(true);
	j->SetLimits(-lower*DEG_TO_RAD,-upper*DEG_TO_RAD);
}
ACTION(
	/* ID */			233,
	/* Name */			"Revolute Joint - Disable Limits for Joint (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	int n = lParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableLimit(false);
}
ACTION(
	/* ID */			234,
	/* Name */			"Prismatic Joint - Set Motor of Joint (%0) to Speed (%1), Force (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Joint ID",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	int n = lParam();
	float speed = fParam();
	float force = fParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorForce(force);
}
ACTION(
	/* ID */			235,
	/* Name */			"Prismatic Joint - Disable Motor for Joint (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	int n = lParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			236,
	/* Name */			"Prismatic Joint - Set Limits of Joint (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Joint ID",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableLimit(true);
	j->SetLimits(lower/rdPtr->scale,upper/rdPtr->scale);
}
ACTION(
	/* ID */			237,
	/* Name */			"Prismatic Joint - Disable Limits for Joint (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	int n = lParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableLimit(false);
}
ACTION(
	/* ID */			238,
	/* Name */			"Line Joint - Set Motor of Joint (%0) to Speed (%1), Force (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Joint ID",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	int n = lParam();
	float speed = fParam();
	float force = fParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorForce(force);
}
ACTION(
	/* ID */			239,
	/* Name */			"Line Joint - Disable Motor for Joint (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	int n = lParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			240,
	/* Name */			"Line Joint - Set Limits of Joint (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Joint ID",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableLimit(true);
	j->SetLimits(lower/rdPtr->scale,upper/rdPtr->scale);
}
ACTION(
	/* ID */			241,
	/* Name */			"Line Joint - Disable Limits for Joint (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Joint ID")
) {
	int n = lParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableLimit(false);
}
ACTION(
	/* ID */			242,
	/* Name */			"Do Single Shape Ray Cast Between Points (%0,%1) and (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Start X",PARAM_NUMBER,"Start Y",PARAM_NUMBER,"End X",PARAM_NUMBER,"End Y")
) {
	float x1 = fParam();
	float y1 = fParam();
	float x2 = fParam();
	float y2 = fParam();

	if(abs(x1-x2) < B2_FLT_EPSILON && abs(y1-y2) < B2_FLT_EPSILON) return;

	b2Segment seg;
	seg.p1.x = x1 / rdPtr->scale;
	seg.p1.y = y1 / rdPtr->scale;
	seg.p2.x = x2 / rdPtr->scale;
	seg.p2.y = y2 / rdPtr->scale;

	rdPtr->ray.Init(1);

	float lambda;
	rdPtr->ray.shapes[0] = rdPtr->world->RaycastOne(seg, &lambda, &rdPtr->ray.normal, rdPtr->ray.ud.solidShapes, &rdPtr->ray.ud);
	rdPtr->ray.point = (1 - lambda) * seg.p1 + lambda * seg.p2;
	if(rdPtr->ray.shapes[0]) rdPtr->ray.hits = 1;
	else rdPtr->ray.hits = 0;
}
ACTION(
	/* ID */			243,
	/* Name */			"Do Multi-Shape Ray Cast Between Points (%0,%1) and (%2,%3)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"Start X",PARAM_NUMBER,"Start Y",PARAM_NUMBER,"End X",PARAM_NUMBER,"End Y",PARAM_NUMBER,"Max Shapes")
) {
	float x1 = fParam();
	float y1 = fParam();
	float x2 = fParam();
	float y2 = fParam();
	int max = lParam();

	if(max <= 0) return;

	if(x1 == x2 && y1 == y2) return;

	b2Segment seg;
	seg.p1.x = x1 / rdPtr->scale;
	seg.p1.y = y1 / rdPtr->scale;
	seg.p2.x = x2 / rdPtr->scale;
	seg.p2.y = y2 / rdPtr->scale;

	rdPtr->ray.Init(max);

	rdPtr->ray.hits = rdPtr->world->Raycast(seg, rdPtr->ray.shapes, rdPtr->ray.numShapes, rdPtr->ray.ud.solidShapes, &rdPtr->ray.ud);
}
ACTION(
	/* ID */			244,
	/* Name */			"Set Raycast Target Collision Type to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Collision Type")
) {
	int type = lParam();

	if(type < 0 || type >= 32) return;
	
	rdPtr->ray.ud.collType = type;
}
ACTION(
	/* ID */			245,
	/* Name */			"Remove Raycast Target Collision Type",
	/* Flags */			0,
	/* Params */		(0)
) {
	rdPtr->ray.ud.collType = -1;
}
ACTION(
	/* ID */			246,
	/* Name */			"Set Raycast Mask Bits to (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Mask Bits")
) {
	int mask = lParam();
	
	rdPtr->ray.ud.mask = mask;
}
ACTION(
	/* ID */			247,
	/* Name */			"Remove Raycast Mask",
	/* Flags */			0,
	/* Params */		(0)
) {
	rdPtr->ray.ud.mask = -1;
}

ACTION(
	/* ID */			248,
	/* Name */			"Body - Set Automatic Mass Data",
	/* Flags */			0,
	/* Params */		(0)
) {
	b2BodyDef* bd = rdPtr->curBodyDef;
	if(!bd) return;

	bd->userData.customMass = false;
}
ACTION(
	/* ID */			249,
	/* Name */			"Quick Add Revolute Joint To Body (%0), Anchor (%1,%2), is Local (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2RevoluteJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			250,
	/* Name */			"Quick Add Prismatic Joint To Body (%0), Anchor (%1,%2), is Local (%3), Angle (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_OBJECT,"Object",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Translation Angle")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float angle = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2PrismaticJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor,axis);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			251,
	/* Name */			"Quick Add Distance Joint To Body (%0), First Anchor (%1,%2), is Local (%3), Second Anchor (%4,%5), is Local (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_OBJECT,"Object",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b->GetWorldPoint(anchor2);

	b2DistanceJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor,anchor2);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			252,
	/* Name */			"Quick Add Line Joint To Body (%0), Anchor (%1,%2), is Local (%3), Angle (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_OBJECT,"Object",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Translation Angle")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float angle = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2LineJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor,axis);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			253,
	/* Name */			"Quick Add Revolute Joint To Body (%0), Anchor (%1,%2), is Local (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2RevoluteJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			254,
	/* Name */			"Quick Add Prismatic Joint To Body (%0), Anchor (%1,%2), is Local (%3), Angle (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Translation Angle")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float angle = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2PrismaticJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor,axis);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			255,
	/* Name */			"Quick Add Distance Joint To Body (%0), First Anchor (%1,%2), is Local (%3), Second Anchor (%4,%5), is Local (%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b->GetWorldPoint(anchor2);

	b2DistanceJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor,anchor2);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			256,
	/* Name */			"Quick Add Line Joint To Body (%0), Anchor (%1,%2), is Local (%3), Angle (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Anchor X",PARAM_NUMBER,"Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Translation Angle")
) {
	int n = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	float angle = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 axis(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));

	b2LineJointDef def;
	def.Initialize(rdPtr->world->GetGroundBody(),b,anchor,axis);
	def.collideConnected = false;
	
	def.userData.body1 = -2;
	def.userData.body2 = n;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			257,
	/* Name */			"Add Shape Definition (%1) to Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape Definition ID")
) {
	LPRO obj = oParam();
	int sn = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2ShapeDef* def = getShapeDef(sn,rdPtr);

	if(!def) return;

	if(!rdPtr->bodies[n]->CreateShape(def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(rdPtr->bodies[n]);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		rdPtr->bodies[n]->SetMassFromShapes();
}

ACTION(
	/* ID */			258,
	/* Name */			"Add Shape Definition (%1) to Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape Definition ID")
) {
	int n = lParam();
	int sn = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2ShapeDef* def = getShapeDef(sn,rdPtr);

	if(!def) return;

	if(!b->CreateShape(def))
	{
		//Failed to add shape Error
		//delete ud;
		return;
	}

	updateShapes(b);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			259,
	/* Name */			"Add Object (%0) as Shape Definition (%2) to Body (%1)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape Definition ID")
) {
	LPRO obj = oParam();
	int n = lParam();
	int sn = lParam();

	if(!obj) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2ShapeDef* def = getShapeDef(sn,rdPtr);

	if(!def) return;

	b2ShapeDef* sd;

	switch(def->type)
	{
	case e_circleShape:
		{
			b2CircleDef* csd = new b2CircleDef;
			*csd = *((b2CircleDef*)def);
			csd->localPosition += b->GetLocalPoint(b2Vec2(obj->roHo.hoX / rdPtr->scale, obj->roHo.hoY / rdPtr->scale));
			sd = csd;
		}
		break;
	case e_polygonShape:
		{
			b2PolygonDef* psd = new b2PolygonDef;
			*psd = *((b2PolygonDef*)def);
			psd->vertices = new b2Vec2[psd->vertexMax];
			
			for(int i = 0; i < psd->vertexCount; i++)
			{
				psd->vertices[i] = ((b2PolygonDef*)def)->vertices[i] +  b->GetLocalPoint(b2Vec2(obj->roHo.hoX / rdPtr->scale, obj->roHo.hoY / rdPtr->scale));
			}
			sd = psd;
		}
		break;
	case e_edgeShape:
		{
			b2EdgeChainDef* esd = new b2EdgeChainDef;
			*esd = *((b2EdgeChainDef*)def);
			esd->vertices = new b2Vec2[esd->vertexMax];
			
			for(int i = 0; i < esd->vertexCount; i++)
			{
				esd->vertices[i] = ((b2EdgeChainDef*)def)->vertices[i] +  b->GetLocalPoint(b2Vec2(obj->roHo.hoX / rdPtr->scale, obj->roHo.hoY / rdPtr->scale));
			}
			sd = esd;
		}
		break;
	default:
		return;
	}

	if(!rdPtr->bodies[n]->CreateShape(sd))
	{
		//Failed to add shape Error
		//delete ud;
		delete sd;
		return;
	}
	delete sd;

	updateShapes(rdPtr->bodies[n]);

	if(!rdPtr->bodies[n]->GetUserData()->customMass)
		rdPtr->bodies[n]->SetMassFromShapes();
}

ACTION(
	/* ID */			260,
	/* Name */			"Create Body from Definition (%0) at (%1), offset (%2,%3), rotation (%4), destruction (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_NUMBER,"Definition ID",PARAM_OBJECT,"Object",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Rotation (0: No Rotation, 1: Fast, 2: Quality",PARAM_NUMBER,"Link Destruction")
) {
	int dn = lParam();
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int rotation = lParam();
	int dest = lParam();

	if(!obj) return;

	if(!getBodyDef(dn,rdPtr)) return;

	b2BodyDef def = *getBodyDef(dn,rdPtr);
	
	if(hasAttachment(obj,rdPtr)) removeAttachment(obj,rdPtr);

	int n = getNullBody(rdPtr);
	if(n == -1) return;

	def.userData.ID = n;
	def.userData.rdPtr = rdPtr;
	def.userData.AddObject(obj->roHo.hoNumber,b2Vec2(-x/rdPtr->scale,-y/rdPtr->scale),rotation,dest,0);

	if(rdPtr->floatAngles)
		def.angle = obj->roc.rcAngleF * DEG_TO_RAD;
	else
		def.angle = obj->roc.rcAngleI * DEG_TO_RAD;

	def.position.Set(((float)obj->roHo.hoX + x)/rdPtr->scale, ((float)obj->roHo.hoY + y)/rdPtr->scale);

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(&def)) == NULL)
	{
		//Failed to create body
		def.numShapes = 0;
		def.shapes = NULL;
		def.userData.BodyDie();
		rdPtr->lastBody = -2;
		return;
	}

	if(def.numShapes > 0)
	{
		for(int i = 0; i < def.numShapes; i++)
		{
			rdPtr->bodies[n]->CreateShape(def.shapes[i]);
		}

		updateShapes(rdPtr->bodies[n]);

		if(!rdPtr->bodies[n]->GetUserData()->customMass)
			rdPtr->bodies[n]->SetMassFromShapes();

		def.numShapes = 0;
		def.shapes = NULL;
	}
	
	rdPtr->lastBody = n;
	rdPtr->AttachedObjectIDs[obj->roHo.hoNumber] = n;
}

ACTION(
	/* ID */			261,
	/* Name */			"Create Body from Definition (%0) at (%1,%2) , angle (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Definition ID",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"Angle")
) {
	int dn = lParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();

	int n = getNullBody(rdPtr);
	if(n == -1) return;

	if(!getBodyDef(dn,rdPtr)) return;
	
	b2BodyDef def = *getBodyDef(dn,rdPtr);

	def.userData.ID = n;
	def.userData.rdPtr = rdPtr;

	def.position.Set(x/rdPtr->scale, y/rdPtr->scale);
	def.angle = angle*DEG_TO_RAD;

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(&def)) == NULL)
	{
		//Failed to create body
		def.numShapes = 0;
		def.shapes = NULL;
		rdPtr->lastBody = -2;
		return;
	}

	if(def.numShapes > 0)
	{
		for(int i = 0; i < def.numShapes; i++)
		{
			rdPtr->bodies[n]->CreateShape(def.shapes[i]);
		}

		updateShapes(rdPtr->bodies[n]);

		if(!rdPtr->bodies[n]->GetUserData()->customMass)
			rdPtr->bodies[n]->SetMassFromShapes();

		def.numShapes = 0;
		def.shapes = NULL;
	}

	rdPtr->lastBody = n;
}
ACTION(
	/* ID */			262,
	/* Name */			"Create Joint from Definition (%0) at Body (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Definition ID",PARAM_NUMBER,"Body ID")
) {
	int jn = lParam();
	int n = lParam();

	b2JointDef* def = getJointDef(jn,rdPtr);
	if(!def) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	def->body1 = rdPtr->world->GetGroundBody();
	def->body2 = b;

	if(!setJointDefAnchor(def,rdPtr)) return;

	def->userData.body1 = -2;
	def->userData.body2 = n;
	def->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			263,
	/* Name */			"Create Joint from Definition (%0) at Body (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Definition ID",PARAM_OBJECT,"Object")
) {
	int jn = lParam();
	LPRO obj = oParam();

	b2JointDef* def = getJointDef(jn,rdPtr);
	if(!def) return;

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];
	
	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	def->body1 = rdPtr->world->GetGroundBody();
	def->body2 = b;

	if(!setJointDefAnchor(def,rdPtr)) return;

	def->userData.body1 = -2;
	def->userData.body2 = n;
	def->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			264,
	/* Name */			"Create Joint from Definition (%0) Between Bodies (%1) ad (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Definition ID",PARAM_NUMBER,"First Body ID",PARAM_NUMBER,"Second Body ID")
) {
	int jn = lParam();
	int n2 = lParam();
	int n = lParam();

	b2JointDef* def = getJointDef(jn,rdPtr);
	if(!def) return;

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	def->body1 = b;
	def->body2 = b2;

	if(!setJointDefAnchor(def,rdPtr)) return;

	def->userData.body1 = n;
	def->userData.body2 = n2;
	def->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			265,
	/* Name */			"Create Joint from Definition (%0) Between Bodies (%1) and (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Definition ID",PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object")
) {
	int jn = lParam();
	LPRO obj2 = oParam();
	LPRO obj = oParam();

	b2JointDef* def = getJointDef(jn,rdPtr);
	if(!def) return;

	if(!obj || !obj2) return;

	if(!hasAttachment(obj,rdPtr) || !hasAttachment(obj2,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];
	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];
	
	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	def->body1 = b;
	def->body2 = b2;

	if(!setJointDefAnchor(def,rdPtr)) return;

	def->userData.body1 = n;
	def->userData.body2 = n2;
	def->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			266,
	/* Name */			"Create Joint from Definition (%0) Between Bodies (%1) and (%2), reverse (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Definition ID",PARAM_OBJECT,"Object",PARAM_NUMBER,"Body ID",PARAM_NUMBER,"1: Reverse Body Order")
) {
	int jn = lParam();
	LPRO obj = oParam();
	int n2 = lParam();
	int reverse = lParam();

	b2JointDef* def = getJointDef(jn,rdPtr);
	if(!def) return;

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(reverse == 0)
	{
		int temp = n;
		n = n2;
		n2 = temp;
	}
	
	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);

	if(j == -1) return;

	def->body1 = b;
	def->body2 = b2;

	if(!setJointDefAnchor(def,rdPtr)) return;

	def->userData.body1 = n;
	def->userData.body2 = n2;
	def->userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}
ACTION(
	/* ID */			267,
	/* Name */			"Debug Draw - Draw Shapes (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_shapeBit;
	else flags &= (~b2DebugDraw::e_shapeBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			268,
	/* Name */			"Debug Draw - Draw Joints (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_jointBit;
	else flags &= (~b2DebugDraw::e_jointBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			269,
	/* Name */			"Debug Draw - Draw Core Shapes (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_coreShapeBit;
	else flags &= (~b2DebugDraw::e_coreShapeBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			270,
	/* Name */			"Debug Draw - Draw Aligned Bounding Boxes (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_aabbBit;
	else flags &= (~b2DebugDraw::e_aabbBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			271,
	/* Name */			"Debug Draw - Draw Oriented Bounding Boxes (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_obbBit;
	else flags &= (~b2DebugDraw::e_obbBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			272,
	/* Name */			"Debug Draw - Draw Pairs (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_pairBit;
	else flags &= (~b2DebugDraw::e_pairBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			273,
	/* Name */			"Debug Draw - Draw Center of Mass (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_centerOfMassBit;
	else flags &= (~b2DebugDraw::e_centerOfMassBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			274,
	/* Name */			"Revolute Joint - Set Motor of Joint (%1) of Body (%0) to Speed (%2), Torque (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Torque")
) {
	LPRO obj = oParam();
	int n = lParam();
	float speed = fParam();
	float torque = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorTorque(torque);
}
ACTION(
	/* ID */			275,
	/* Name */			"Revolute Joint - Disable Motor for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			276,
	/* Name */			"Revolute Joint - Set Limits of Joint (%1) of Body (%0) to (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	LPRO obj = oParam();
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableLimit(true);
	j->SetLimits(-lower*DEG_TO_RAD,-upper*DEG_TO_RAD);
}
ACTION(
	/* ID */			277,
	/* Name */			"Revolute Joint - Disable Limits for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableLimit(false);
}
ACTION(
	/* ID */			278,
	/* Name */			"Prismatic Joint - Set Motor of Joint (%1) of Body (%0) to Speed (%2), Force (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	LPRO obj = oParam();
	int n = lParam();
	float speed = fParam();
	float force = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorForce(force);
}
ACTION(
	/* ID */			279,
	/* Name */			"Prismatic Joint - Disable Motor for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			280,
	/* Name */			"Prismatic Joint - Set Limits of Joint (%1) of Body (%0) to (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	LPRO obj = oParam();
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableLimit(true);
	j->SetLimits(lower/rdPtr->scale,upper/rdPtr->scale);
}
ACTION(
	/* ID */			281,
	/* Name */			"Prismatic Joint - Disable Limits for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableLimit(false);
}


ACTION(
	/* ID */			282,
	/* Name */			"Line Joint - Set Motor of Joint (%1) of Body (%0) to Speed (%2), Force (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	LPRO obj = oParam();
	int n = lParam();
	float speed = fParam();
	float force = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorForce(force);
}
ACTION(
	/* ID */			283,
	/* Name */			"Line Joint - Disable Motor for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			284,
	/* Name */			"Line Joint - Set Limits of Joint (%1) of Body (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	LPRO obj = oParam();
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableLimit(true);
	j->SetLimits(lower/rdPtr->scale,upper/rdPtr->scale);
}
ACTION(
	/* ID */			285,
	/* Name */			"Line Joint - Disable Limits for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableLimit(false);
}
ACTION(
	/* ID */			286,
	/* Name */			"Set Target of Mouse Joint (%1) of Body (%0) to (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Target X",PARAM_NUMBER,"Target Y")
) {
	LPRO obj = oParam();
	int n = lParam();
	float x = fParam();
	float y = fParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(bn,rdPtr);

	b2MouseJoint* j = (b2MouseJoint*)getJoint(b,n);

	if(!j) return;
	
	if(j->GetType() != e_mouseJoint) return;

	j->SetTarget(b2Vec2(x/rdPtr->scale,y/rdPtr->scale));
}
ACTION(
	/* ID */			287,
	/* Name */			"Revolute Joint - Set Motor of Joint (%1) of Body (%0) to Speed (%2), Torque (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Torque")
) {
	int bn = lParam();
	int n = lParam();
	float speed = fParam();
	float torque = fParam();

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorTorque(torque);
}
ACTION(
	/* ID */			288,
	/* Name */			"Revolute Joint - Disable Motor for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number")
) {
	int bn = lParam();
	int n = lParam();

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			289,
	/* Name */			"Revolute Joint - Set Limits of Joint (%1) of Body (%0) to (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	int bn = lParam();
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableLimit(true);
	j->SetLimits(-lower*DEG_TO_RAD,-upper*DEG_TO_RAD);
}
ACTION(
	/* ID */			290,
	/* Name */			"Revolute Joint - Disable Limits for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number")
) {
	int bn = lParam();
	int n = lParam();

	b2Body* b = getBody(bn,rdPtr);

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_revoluteJoint) return;

	j->EnableLimit(false);
}
ACTION(
	/* ID */			291,
	/* Name */			"Prismatic Joint - Set Motor of Joint (%1) of Body (%0) to Speed (%2), Force (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	int bn = lParam();
	int n = lParam();
	float speed = fParam();
	float force = fParam();

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorForce(force);
}
ACTION(
	/* ID */			292,
	/* Name */			"Prismatic Joint - Disable Motor for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number")
) {
	int bn = lParam();
	int n = lParam();

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			293,
	/* Name */			"Prismatic Joint - Set Limits of Joint (%1) of Body (%0) to (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	int bn = lParam();
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableLimit(true);
	j->SetLimits(lower/rdPtr->scale,upper/rdPtr->scale);
}
ACTION(
	/* ID */			294,
	/* Name */			"Prismatic Joint - Disable Limits for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number")
) {
	int bn = lParam();
	int n = lParam();

	b2Body* b = getBody(bn,rdPtr);

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_prismaticJoint) return;

	j->EnableLimit(false);
}


ACTION(
	/* ID */			295,
	/* Name */			"Line Joint - Set Motor of Joint (%1) of Body (%0) to Speed (%2), Force (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Speed",PARAM_NUMBER,"Max Force")
) {
	int bn = lParam();
	int n = lParam();
	float speed = fParam();
	float force = fParam();

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableMotor(true);
	j->SetMotorSpeed(speed);
	j->SetMaxMotorForce(force);
}
ACTION(
	/* ID */			296,
	/* Name */			"Line Joint - Disable Motor for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number")
) {
	int bn = lParam();
	int n = lParam();

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableMotor(false);
}
ACTION(
	/* ID */			297,
	/* Name */			"Line Joint - Set Limits of Joint (%1) of Body (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Lower Limit",PARAM_NUMBER,"Upper Limit")
) {
	int bn = lParam();
	int n = lParam();
	float lower = fParam();
	float upper = fParam();

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableLimit(true);
	j->SetLimits(lower/rdPtr->scale,upper/rdPtr->scale);
}
ACTION(
	/* ID */			298,
	/* Name */			"Line Joint - Disable Limits for Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number")
) {
	int bn = lParam();
	int n = lParam();

	b2Body* b = getBody(bn,rdPtr);

	b2LineJoint* j = (b2LineJoint*)getJoint(b,n);

	if(!j) return;

	if(j->GetType() != e_lineJoint) return;

	j->EnableLimit(false);
}
ACTION(
	/* ID */			299,
	/* Name */			"Set Target of Mouse Joint (%1) of Body (%0) to (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number",PARAM_NUMBER,"Target X",PARAM_NUMBER,"Target Y")
) {
	int bn = lParam();
	int n = lParam();
	float x = fParam();
	float y = fParam();

	b2Body* b = getBody(bn,rdPtr);

	b2MouseJoint* j = (b2MouseJoint*)getJoint(b,n);

	if(!j) return;
	
	if(j->GetType() != e_mouseJoint) return;

	j->SetTarget(b2Vec2(x/rdPtr->scale,y/rdPtr->scale));
}
ACTION(
	/* ID */			300,
	/* Name */			"Test For Shapes at Point (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Point X",PARAM_NUMBER,"Point Y")
) {
	float x = fParam();
	float y = fParam();
	x /= rdPtr->scale;
	y /= rdPtr->scale;

	if(x <= rdPtr->bounds.lowerBound.x || x >= rdPtr->bounds.upperBound.x 
	|| y <= rdPtr->bounds.lowerBound.y || y >= rdPtr->bounds.upperBound.y) return;

	b2Shape** shapes = new b2Shape*[rdPtr->settings.b2_maxProxies];

	b2AABB aabb;
	aabb.lowerBound.Set(x,y);
	aabb.upperBound.Set(x,y);

	int count = rdPtr->world->Query(aabb, shapes, rdPtr->settings.b2_maxProxies);

	for(int i = 0; i < count; i++)
	{
		if(shapes[i]->TestPoint(shapes[i]->GetBody()->GetXForm(),b2Vec2(x,y)))
		{
			rdPtr->eventShape = shapes[i]->GetUserData()->ID;
			rdPtr->eventBody = shapes[i]->GetBody()->GetUserData()->ID;
			rdPtr->rRd->GenerateEvent(11);
			rdPtr->eventShape = -2;
			rdPtr->eventBody = -2;
		}
	}

	delete [] shapes;
}
ACTION(
	/* ID */			301,
	/* Name */			"Test For Shapes in Zone (%0,%1) to (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Min X",PARAM_NUMBER,"Min Y",PARAM_NUMBER,"Max X",PARAM_NUMBER,"Max Y")
) {
	float x1 = fParam();
	float y1 = fParam();
	float x2 = fParam();
	float y2 = fParam();
	x1 /= rdPtr->scale;
	y1 /= rdPtr->scale;
	x2 /= rdPtr->scale;
	y2 /= rdPtr->scale;

	if(x1 <= rdPtr->bounds.lowerBound.x || x2 >= rdPtr->bounds.upperBound.x 
	|| y1 <= rdPtr->bounds.lowerBound.y || y2 >= rdPtr->bounds.upperBound.y) return;
	if(x1 > x2 || y1 > y2) return;

	b2Shape** shapes = new b2Shape*[rdPtr->settings.b2_maxProxies];

	b2AABB aabb;
	aabb.lowerBound.Set(x1,y1);
	aabb.upperBound.Set(x2,y2);

	int count = rdPtr->world->Query(aabb, shapes, rdPtr->settings.b2_maxProxies);

	for(int i = 0; i < count; i++)
	{
		rdPtr->eventShape = shapes[i]->GetUserData()->ID;
		rdPtr->eventBody = shapes[i]->GetBody()->GetUserData()->ID;
		rdPtr->rRd->GenerateEvent(11);
		rdPtr->eventShape = -2;
		rdPtr->eventBody = -2;
	}

	delete [] shapes;
}
ACTION(
	/* ID */			302,
	/* Name */			"Set Density of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Density")
) {
	LPRO obj = oParam();
	int shape = lParam();
	float density = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetDensity(density);
			s = s->GetNext();
		}
		if(!b->GetUserData()->customMass)
			b->SetMassFromShapes();
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetDensity(density);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}
ACTION(
	/* ID */			303,
	/* Name */			"Set Density of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"Density")
) {
	int n = lParam();
	int shape = lParam();
	float density = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetDensity(density);
			s = s->GetNext();
		}
		if(!b->GetUserData()->customMass)
			b->SetMassFromShapes();
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetDensity(density);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}
ACTION(
	/* ID */			304,
	/* Name */			"Sensor Current Collision",
	/* Flags */			0,
	/* Params */		(0)
) {
	rdPtr->collMode = 1;
}

ACTION(
	/* ID */			305,
	/* Name */			"Create Buoyancy Controller, Angle (%0), Height (%1), Density (%2), Velocity (%3,%4), Linear Drag (%5), Angular Drag(%6)",
	/* Flags */			0,
	/* Params */		(7,PARAM_NUMBER,"Surface Angle",PARAM_NUMBER,"Surface Height",PARAM_NUMBER,"Fluid Density",PARAM_NUMBER,"Fluid X Velocity",PARAM_NUMBER,"Fluid Y Velocity",PARAM_NUMBER,"Fluid Linear Drag",PARAM_NUMBER,"Fluid Angular Drag")
) {
	float angle = fParam();
	float height = fParam();
	float density = fParam();
	float velx = fParam();
	float vely = fParam();
	float lindrag = fParam();
	float angdrag = fParam();

	int n = getNullController(rdPtr);
	if(n == -1) return;

	b2BuoyancyControllerDef def;
	def.velocity.Set(velx,vely);
	def.normal.Set(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));
	def.offset = height / rdPtr->scale;
	def.density = density;
	def.linearDrag = lindrag;
	def.angularDrag = angdrag;
	def.useDensity = true;
	def.useWorldGravity = true;

	if((rdPtr->controllers[n] = rdPtr->world->CreateController(&def)) == NULL)
	{
		//Failed to create controller
		rdPtr->lastController = -2;
		return;
	}

	rdPtr->lastController = n;
}

ACTION(
	/* ID */			306,
	/* Name */			"Add Body (%0) to Controller (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Controller ID")
) {
	LPRO obj = oParam();
	int cn = lParam();

	b2Controller* c = getController(cn,rdPtr);

	if(!c) return;

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	bool find = false;
	for(b2ControllerEdge* e = b->GetControllerList(); e != NULL; e = e->nextController)
	{
		if(e->controller == c)
			find = true;
	}
	if(find) return;

	c->AddBody(b);
}

ACTION(
	/* ID */			307,
	/* Name */			"Add Body (%0) to Controller (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Controller ID")
) {
	int n = lParam();
	int cn = lParam();

	b2Controller* c = getController(cn,rdPtr);

	if(!c) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	bool find = false;
	for(b2ControllerEdge* e = b->GetControllerList(); e != NULL; e = e->nextController)
	{
		if(e->controller == c)
			find = true;
	}
	if(find) return;

	c->AddBody(b);
}

ACTION(
	/* ID */			308,
	/* Name */			"Remove Body (%0) from Controller (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Controller ID")
) {
	LPRO obj = oParam();
	int cn = lParam();

	b2Controller* c = getController(cn,rdPtr);

	if(!c) return;

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	bool find = false;
	for(b2ControllerEdge* e = b->GetControllerList(); e != NULL; e = e->nextController)
	{
		if(e->controller == c)
			find = true;
	}
	if(!find) return;

	c->RemoveBody(b);
}

ACTION(
	/* ID */			309,
	/* Name */			"Remove Body (%0) from Controller (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Controller ID")
) {
	int n = lParam();
	int cn = lParam();

	b2Controller* c = getController(cn,rdPtr);

	if(!c) return;

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	bool find = false;
	for(b2ControllerEdge* e = b->GetControllerList(); e != NULL; e = e->nextController)
	{
		if(e->controller == c)
			find = true;
	}
	if(!find) return;

	c->RemoveBody(b);
}

ACTION(
	/* ID */			310,
	/* Name */			"Clear Bodies for Controller (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Controller ID")
) {
	int cn = lParam();

	b2Controller* c = getController(cn,rdPtr);

	if(!c) return;

	c->Clear();
}

ACTION(
	/* ID */			311,
	/* Name */			"Remove Controller (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"Controller ID")
) {
	int cn = lParam();

	b2Controller* c = getController(cn,rdPtr);

	if(!c) return;

	rdPtr->world->DestroyController(c);

	rdPtr->controllers[cn] = NULL;
}
ACTION(
	/* ID */			312,
	/* Name */			"Set Sensor of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"0: is Solid, 1: is Sensor")
) {
	int n = lParam();
	int shape = lParam();
	int sensor = lParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetSensor(sensor != 0);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetSensor(sensor != 0);
}
ACTION(
	/* ID */			313,
	/* Name */			"Set Sensor of Shape (%1) of Body (%0) to (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_OBJECT,"Object",PARAM_NUMBER,"Shape ID (-1 = all)",PARAM_NUMBER,"0: is Solid, 1: is Sensor")
) {
	LPRO obj = oParam();
	int shape = lParam();
	int sensor = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	if(shape == -1)
	{
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			s->SetSensor(sensor != 0);
			s = s->GetNext();
		}
		return;
	}

	b2Shape* s = getShape(b,shape);

	if(!s) return;

	s->SetSensor(sensor != 0);
}

ACTION(
	/* ID */			314,
	/* Name */			"Create Constant Force Controller, Force (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"X Force",PARAM_NUMBER,"Y Force")
) {
	float fx = fParam();
	float fy = fParam();

	int n = getNullController(rdPtr);
	if(n == -1) return;

	b2ConstantForceControllerDef def;
	def.F.Set(fx,fy);

	if((rdPtr->controllers[n] = rdPtr->world->CreateController(&def)) == NULL)
	{
		//Failed to create controller
		rdPtr->lastController = -2;
		return;
	}

	rdPtr->lastController = n;
}

ACTION(
	/* ID */			315,
	/* Name */			"Create Constant Acceleration Controller, Force (%0,%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"X Force",PARAM_NUMBER,"Y Force")
) {
	float fx = fParam();
	float fy = fParam();

	int n = getNullController(rdPtr);
	if(n == -1) return;

	b2ConstantAccelControllerDef def;
	def.A.Set(fx,fy);

	if((rdPtr->controllers[n] = rdPtr->world->CreateController(&def)) == NULL)
	{
		//Failed to create controller
		rdPtr->lastController = -2;
		return;
	}

	rdPtr->lastController = n;
}

ACTION(
	/* ID */			316,
	/* Name */			"Create Tensor Damping Controller, Model (%0,%1,%2,%3), Max Timestep (%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"X1",PARAM_NUMBER,"Y1",PARAM_NUMBER,"X2",PARAM_NUMBER,"Y2",PARAM_NUMBER,"Max Timestep")
) {
	float x1 = fParam();
	float y1 = fParam();
	float x2 = fParam();
	float y2 = fParam();
	float maxtime = fParam();

	int n = getNullController(rdPtr);
	if(n == -1) return;

	b2TensorDampingControllerDef def;
	def.maxTimestep = maxtime;
	def.T.Set(b2Vec2(x1,y1),b2Vec2(x2,y2));

	if((rdPtr->controllers[n] = rdPtr->world->CreateController(&def)) == NULL)
	{
		//Failed to create controller
		rdPtr->lastController = -2;
		return;
	}

	rdPtr->lastController = n;
}

ACTION(
	/* ID */			317,
	/* Name */			"Create Gravity Controller, Strength (%0), Inverse Square (%1), Max Force (%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Gravity Strength",PARAM_NUMBER,"1: gravity is proportional to r^-2, otherwise r^-1",PARAM_NUMBER,"Max Force (0 = disable)")
) {
	float str = fParam();
	int invSqr = lParam();
	float maxf = fParam();

	int n = getNullController(rdPtr);
	if(n == -1) return;

	b2GravityControllerDef def;
	def.G = str;
	def.invSqr = invSqr == 1;
	def.maxForce = maxf;

	if((rdPtr->controllers[n] = rdPtr->world->CreateController(&def)) == NULL)
	{
		//Failed to create controller
		rdPtr->lastController = -2;
		return;
	}

	rdPtr->lastController = n;
}

ACTION(
	/* ID */			318,
	/* Name */			"World - Set Boundaries to Min (%0,%1), Max (%2,%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_NUMBER,"Boundary Min X",PARAM_NUMBER,"Boundary Min Y",PARAM_NUMBER,"Boundary Max X",PARAM_NUMBER,"Boundary Max Y")
) {
	float minx = fParam();
	float miny = fParam();
	float maxx = fParam();
	float maxy = fParam();
	
	rdPtr->bounds.lowerBound.x = minx/rdPtr->scale;
	rdPtr->bounds.lowerBound.y = miny/rdPtr->scale;
	rdPtr->bounds.upperBound.x = maxx/rdPtr->scale;
	rdPtr->bounds.upperBound.y = maxy/rdPtr->scale;
}

ACTION(
	/* ID */			319,
	/* Name */			"Quick Add Limit Joint Between Bodies (%0) and (%1), First Anchor (%2,%3), is Local (%4), Second Anchor (%5,%6), is Local (%7), Collide (%8), Limits (%9,%A)",
	/* Flags */			0,
	/* Params */		(11,PARAM_OBJECT,"First Object",PARAM_OBJECT,"Second Object",PARAM_NUMBER,"First Anchor X",PARAM_NUMBER,"First Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"Second Anchor X",PARAM_NUMBER,"Second Anchor Y",PARAM_NUMBER,"0: World Coordinate, 1: Local Coordinate",PARAM_NUMBER,"0: Disable Collision, 1: Enable Collision",PARAM_NUMBER,"Min Limit",PARAM_NUMBER,"Max Limit")
) {
	LPRO obj2 = oParam();
	LPRO obj = oParam();
	float x2 = fParam();
	float y2 = fParam();
	int local2 = lParam();
	float x = fParam();
	float y = fParam();
	int local = lParam();
	int collide = lParam();
	float min = fParam();
	float max = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	if(!obj2) return;

	if(!hasAttachment(obj2,rdPtr)) return;

	int n2 = rdPtr->AttachedObjectIDs[obj2->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);
	b2Body* b2 = getBody(n2,rdPtr);

	if(!b || !b2) return;

	int j = getNullJoint(rdPtr);
	if(j == -1) return;

	b2Vec2 anchor(x/rdPtr->scale,y/rdPtr->scale);

	if(local == 1)
		anchor = b->GetWorldPoint(anchor);

	b2Vec2 anchor2(x2/rdPtr->scale,y2/rdPtr->scale);

	if(local2 == 1)
		anchor2 = b2->GetWorldPoint(anchor2);

	b2MaxMinJointDef def;
	def.Initialize(b,b2,anchor,anchor2,min/rdPtr->scale,max/rdPtr->scale);
	def.collideConnected = collide != 0;
	
	def.userData.body1 = n;
	def.userData.body2 = n2;
	def.userData.ID = j;

	if((rdPtr->joints[j] = rdPtr->world->CreateJoint(&def)) == NULL)
	{
		rdPtr->lastJoint = -2;
		return;
	}

	b->GetUserData()->numJoints++;
	b2->GetUserData()->numJoints++;
	
	rdPtr->lastJoint = j;
}

ACTION(
	/* ID */			320,
	/* Name */			"Raycast Collides with Starting Shapes",
	/* Flags */			0,
	/* Params */		(0)
) {
	rdPtr->ray.ud.solidShapes = true;
}

ACTION(
	/* ID */			321,
	/* Name */			"Debug Draw - Draw Controllers (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_NUMBER,"1: Draw, 0: Don't Draw")
) {
	int draw = lParam();

	int flags = rdPtr->DD->GetFlags();
	
	if(draw != 0) flags |= b2DebugDraw::e_controllerBit;
	else flags &= (~b2DebugDraw::e_controllerBit);

	rdPtr->DD->SetFlags(flags);
}
ACTION(
	/* ID */			322,
	/* Name */			"Load Shape Data from String (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_STRING,"Shape String")
) {
	char* str = (char*)sParam();

	if(rdPtr->curShapeDef) delete rdPtr->curShapeDef;

	rdPtr->curShapeDef = NULL;

	if(!Parser::parseShape(str, rdPtr->curShapeDef, rdPtr))
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
	}
}
ACTION(
	/* ID */			323,
	/* Name */			"Set Shape Definition (%0) from String (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Shape Definition ID",PARAM_STRING,"Shape String")
) {
	long def = lParam();
	char* str = (char*)sParam();

	if(!isShapeDef(def,rdPtr)) return;

	if(rdPtr->sDefs[def]) delete rdPtr->sDefs[def];

	rdPtr->sDefs[def] = NULL;

	if(!Parser::parseShape(str, rdPtr->sDefs[def], rdPtr)) 
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
	}
}
ACTION(
	/* ID */			324,
	/* Name */			"Load Body Data from String (%0)",
	/* Flags */			0,
	/* Params */		(1,PARAM_STRING,"Body String")
) {
	char* str = (char*)sParam();
#ifndef RUN_ONLY
	char* str2 = str;
#endif
	
	if(rdPtr->curBodyDef) delete rdPtr->curBodyDef;

	rdPtr->curBodyDef = NULL;

	if(!Parser::parseBody(str, rdPtr->curBodyDef, rdPtr)) 
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
	}
}
ACTION(
	/* ID */			325,
	/* Name */			"Set Body Definition (%0) from String (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body Definition ID",PARAM_STRING,"Body String")
) {
	long def = lParam();
	char* str = (char*)sParam();

	if(!isBodyDef(def,rdPtr)) return;

	if(rdPtr->bDefs[def]) delete rdPtr->bDefs[def];

	rdPtr->bDefs[def] = NULL;

	if(!Parser::parseBody(str, rdPtr->bDefs[def], rdPtr))
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
	}
}

ACTION(
	/* ID */			326,
	/* Name */			"Quick Create Body from String (%0) at (%1), offset (%2,%3), rotation (%4), destruction (%5)",
	/* Flags */			0,
	/* Params */		(6,PARAM_STRING,"Body String",PARAM_OBJECT,"Object",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Rotation (-1: Disable, 0: Not Object, 1: Fast, 2: Quality)",PARAM_NUMBER,"Link Destruction")
) {
	char* str = (char*)sParam();
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	int rotation = lParam();
	int dest = lParam();

	if(!obj) return;
	
	if(hasAttachment(obj,rdPtr)) removeAttachment(obj,rdPtr);

	int n = getNullBody(rdPtr);
	if(n == -1) return;

	b2BodyDef* def = NULL;

	if(!Parser::parseBody(str, def, rdPtr))
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
		rdPtr->lastBody = -2;
		return;
	}

	def->userData.ID = n;
	def->userData.rdPtr = rdPtr;
	def->userData.AddObject(obj->roHo.hoNumber,b2Vec2(-x/rdPtr->scale,-y/rdPtr->scale),rotation,dest,0);

	if(rdPtr->floatAngles)
		def->angle = obj->roc.rcAngleF * DEG_TO_RAD;
	else
		def->angle = obj->roc.rcAngleI * DEG_TO_RAD;

	def->position.Set(((float)obj->roHo.hoX + x)/rdPtr->scale, ((float)obj->roHo.hoY + y)/rdPtr->scale);
	def->fixedRotation = rotation == -1;
	

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(def)) == NULL)
	{
		//Failed to create body
		def->userData.BodyDie();
		rdPtr->lastBody = -2;
		delete def;
		return;
	}
	
	if(def->numShapes > 0)
	{
		for(int i = 0; i < def->numShapes; i++)
		{
			rdPtr->bodies[n]->CreateShape(def->shapes[i]);
		}

		updateShapes(rdPtr->bodies[n]);

		if(!rdPtr->bodies[n]->GetUserData()->customMass)
			rdPtr->bodies[n]->SetMassFromShapes();
	}
	
	delete def;

	rdPtr->lastBody = n;
}

ACTION(
	/* ID */			327,
	/* Name */			"Quick Create Body from String (%0) at (%1,%2), angle (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_STRING,"Body String",PARAM_NUMBER,"X Position",PARAM_NUMBER,"Y Position",PARAM_NUMBER,"Angle")
) {
	char* str = (char*)sParam();
	float x = fParam();
	float y = fParam();
	float angle = fParam();

	int n = getNullBody(rdPtr);
	if(n == -1) return;

	b2BodyDef* def = NULL;

	if(!Parser::parseBody(str, def, rdPtr))
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
		rdPtr->lastBody = -2;
		return;
	}

	def->userData.ID = n;
	def->userData.rdPtr = rdPtr;
	def->position.Set(x/rdPtr->scale, y/rdPtr->scale);
	def->angle = angle*DEG_TO_RAD;

	if((rdPtr->bodies[n] = rdPtr->world->CreateBody(def)) == NULL)
	{
		//Failed to create body
		rdPtr->lastBody = -2;
		delete def;
		return;
	}

	if(def->numShapes > 0)
	{
		for(int i = 0; i < def->numShapes; i++)
		{
			rdPtr->bodies[n]->CreateShape(def->shapes[i]);
		}

		updateShapes(rdPtr->bodies[n]);

		if(!rdPtr->bodies[n]->GetUserData()->customMass)
			rdPtr->bodies[n]->SetMassFromShapes();
	}

	delete def;

	rdPtr->lastBody = n;
}


ACTION(
	/* ID */			328,
	/* Name */			"Quick Add Shape to Body (%0) from String (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_STRING,"Shape String")
) {
	LPRO obj = oParam();
	char* str = (char*)sParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2ShapeDef* def;
	if(!Parser::parseShape(str, def, rdPtr)) 
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
		return;
	}

	if(!b->CreateShape(def))
	{
		//Failed to add shape Error
		delete def;
		return;
	}

	delete def;

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}

ACTION(
	/* ID */			329,
	/* Name */			"Quick Add Shape to Body (%0) from String (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_STRING,"Shape String")
) {
	int n = lParam();
	char* str = (char*)sParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b2ShapeDef* def;
	if(!Parser::parseShape(str, def, rdPtr)) 
	{
#ifndef RUN_ONLY
		Debug("Error when parsing string!\n\nError at: %s",str);
#endif
		return;
	}

	if(!b->CreateShape(def))
	{
		//Failed to add shape Error
		delete def;
		return;
	}

	delete def;

	updateShapes(b);

	if(!b->GetUserData()->customMass)
		b->SetMassFromShapes();
}
ACTION(
	/* ID */			330,
	/* Name */			"Set Linear Damping of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Linear Damping")
) {
	LPRO obj = oParam();
	float damping = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearDamping(damping);
}
ACTION(
	/* ID */			331,
	/* Name */			"Set Linear Damping of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Linear Damping")
) {
	int n = lParam();
	float damping = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetLinearDamping(damping);
}
ACTION(
	/* ID */			332,
	/* Name */			"Set Angular Damping of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Angular Damping")
) {
	LPRO obj = oParam();
	float damping = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetAngularDamping(damping);
}
ACTION(
	/* ID */			333,
	/* Name */			"Set Angular Damping of Body (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Angular Damping")
) {
	int n = lParam();
	float damping = fParam();

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	b->SetAngularDamping(damping);
}

ACTION(
	/* ID */			334,
	/* Name */			"Set Surface Angle of Buoyancy Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Surface Angle")
) {
	int cn = lParam();
	float angle = fParam();

	b2BuoyancyController* c = (b2BuoyancyController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_buoyancyController) return;

	c->normal.Set(cos(angle*DEG_TO_RAD),sin(angle*DEG_TO_RAD));
}

ACTION(
	/* ID */			335,
	/* Name */			"Set Surface Height of Buoyancy Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Surface Height")
) {
	int cn = lParam();
	float height = fParam();

	b2BuoyancyController* c = (b2BuoyancyController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_buoyancyController) return;

	c->offset = height/rdPtr->scale;
}

ACTION(
	/* ID */			336,
	/* Name */			"Set Fluid Density of Buoyancy Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Density")
) {
	int cn = lParam();
	float density = fParam();

	b2BuoyancyController* c = (b2BuoyancyController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_buoyancyController) return;

	c->density = density;
}

ACTION(
	/* ID */			337,
	/* Name */			"Set Fluid Velocity of Buoyancy Controller (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"X Velocity",PARAM_NUMBER,"Y Velocity")
) {
	int cn = lParam();
	float xv = fParam();
	float yv = fParam();

	b2BuoyancyController* c = (b2BuoyancyController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_buoyancyController) return;

	c->velocity.Set(xv,yv);
}

ACTION(
	/* ID */			338,
	/* Name */			"Set Linear Drag of Buoyancy Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Linear Drag")
) {
	int cn = lParam();
	float drag = fParam();

	b2BuoyancyController* c = (b2BuoyancyController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_buoyancyController) return;

	c->linearDrag = drag;
}

ACTION(
	/* ID */			339,
	/* Name */			"Set Angular Drag of Buoyancy Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Angular Drag")
) {
	int cn = lParam();
	float drag = fParam();

	b2BuoyancyController* c = (b2BuoyancyController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_buoyancyController) return;

	c->angularDrag = drag;
}

ACTION(
	/* ID */			340,
	/* Name */			"Set Acceleration of Constant Acceleration Controller (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"X Acceleration",PARAM_NUMBER,"Y Acceleration")
) {
	int cn = lParam();
	float fx = fParam();
	float fy = fParam();

	b2ConstantAccelController* c = (b2ConstantAccelController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_constantAccelController) return;

	c->A.Set(fx,fy);
}

ACTION(
	/* ID */			341,
	/* Name */			"Set Force of Constant Force Controller (%0) to (%1,%2)",
	/* Flags */			0,
	/* Params */		(3,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"X Force",PARAM_NUMBER,"Y Force")
) {
	int cn = lParam();
	float fx = fParam();
	float fy = fParam();

	b2ConstantForceController* c = (b2ConstantForceController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_constantForceController) return;

	c->F.Set(fx,fy);
}

ACTION(
	/* ID */			342,
	/* Name */			"Set Gravity of Gravity Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Gravity Strength")
) {
	int cn = lParam();
	float f = fParam();

	b2GravityController* c = (b2GravityController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_gravityController) return;

	c->G = f;
}

ACTION(
	/* ID */			343,
	/* Name */			"Set Max Force of Gravity Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Max Force")
) {
	int cn = lParam();
	float maxf = fParam();

	b2GravityController* c = (b2GravityController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_gravityController) return;

	c->maxForce = maxf;
}

ACTION(
	/* ID */			344,
	/* Name */			"Set Max Timestep of Tensor Damping Controller (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"Max Timestep")
) {
	int cn = lParam();
	float maxt = fParam();

	b2TensorDampingController* c = (b2TensorDampingController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_tensorDampingController) return;

	c->maxTimestep = maxt;
}

ACTION(
	/* ID */			345,
	/* Name */			"Set Model of Tensor Damping Controller (%0) to (%1,%2,%3,%4)",
	/* Flags */			0,
	/* Params */		(5,PARAM_NUMBER,"Controller ID",PARAM_NUMBER,"X1",PARAM_NUMBER,"Y1",PARAM_NUMBER,"X2",PARAM_NUMBER,"Y2")
) {
	int cn = lParam();
	float x1 = fParam();
	float y1 = fParam();
	float x2 = fParam();
	float y2 = fParam();

	b2TensorDampingController* c = (b2TensorDampingController*)getController(cn,rdPtr);

	if(!c) return;

	if(c->type != e_tensorDampingController) return;

	c->T.Set(b2Vec2(x1,y1),b2Vec2(x2,y2));
}
ACTION(
	/* ID */			346,
	/* Name */			"Set Offset of Attachment for (%0) to (%1,%2), (%3)",
	/* Flags */			0,
	/* Params */		(4,PARAM_OBJECT,"Object",PARAM_NUMBER,"X Offset",PARAM_NUMBER,"Y Offset",PARAM_NUMBER,"Angle Offset")
) {
	LPRO obj = oParam();
	float x = fParam();
	float y = fParam();
	float a = fParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	Attachment* att = b->GetUserData()->GetAttachment(n);

	att->offset.Set(x/rdPtr->scale,y/rdPtr->scale);
	att->rotOff = a * DEG_TO_RAD;
}
ACTION(
	/* ID */			347,
	/* Name */			"Set Rotation of Attachment for (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Rotation (0: None, 1: Fast, 2: Quality)")
) {
	LPRO obj = oParam();
	int r = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	Attachment* att = b->GetUserData()->GetAttachment(obj->roHo.hoNumber);

	att->rotation = r;
}
ACTION(
	/* ID */			348,
	/* Name */			"Set Killflag of Attachment for (%0) to (%1)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Link Destruction")
) {
	LPRO obj = oParam();
	int k = lParam();

	if(!obj) return;

	if(!hasAttachment(obj,rdPtr)) return;

	int n = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* b = getBody(n,rdPtr);

	if(!b) return;

	Attachment* att = b->GetUserData()->GetAttachment(n);

	att->dest = k;
}
ACTION(
	/* ID */			349,
	/* Name */			"Enumerate Bodies",
	/* Flags */			0,
	/* Params */		(0)
) {
	b2Body* b = rdPtr->world->GetBodyList();

	while(b)
	{
		if(b != rdPtr->world->GetGroundBody())
		{
			rdPtr->enumBody = b->GetUserData()->ID;
			rdPtr->rRd->GenerateEvent(57);
		}
		b = b->GetNext();
	}

	rdPtr->enumBody = -2;
}
ACTION(
	/* ID */			350,
	/* Name */			"Enumerate Shapes",
	/* Flags */			0,
	/* Params */		(0)
) {
	b2Body* b = rdPtr->world->GetBodyList();

	while(b)
	{
		rdPtr->enumBody = b->GetUserData()->ID;
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			rdPtr->enumShape = s->GetUserData()->ID;
			rdPtr->rRd->GenerateEvent(58);

			switch(s->GetType())
			{
			case e_polygonShape:
				rdPtr->rRd->GenerateEvent(61);
				break;
			case e_circleShape:
				rdPtr->rRd->GenerateEvent(62);
				break;
			case e_edgeShape:
				rdPtr->rRd->GenerateEvent(63);
				break;
			}

			s = s->GetNext();
		}
		b = b->GetNext();
	}
	rdPtr->enumBody = -1;
	rdPtr->enumShape = -1;
}
ACTION(
	/* ID */			351,
	/* Name */			"Enumerate Joints",
	/* Flags */			0,
	/* Params */		(0)
) {
	b2Joint* j = rdPtr->world->GetJointList();
	

	while(j)
	{
		rdPtr->enumJoint = j->GetUserData()->ID;
		rdPtr->rRd->GenerateEvent(59);

		switch(j->GetType())
		{
		case e_revoluteJoint:
			rdPtr->rRd->GenerateEvent(64);
			break;
		case e_prismaticJoint:
			rdPtr->rRd->GenerateEvent(65);
			break;
		case e_distanceJoint:
			rdPtr->rRd->GenerateEvent(66);
			break;
		case e_pulleyJoint:
			rdPtr->rRd->GenerateEvent(67);
			break;
		case e_lineJoint:
			rdPtr->rRd->GenerateEvent(68);
			break;
		case e_gearJoint:
			rdPtr->rRd->GenerateEvent(69);
			break;
		case e_mouseJoint:
			rdPtr->rRd->GenerateEvent(70);
			break;
		}

		j = j->GetNext();
	}

	rdPtr->enumJoint = -2;
}
ACTION(
	/* ID */			352,
	/* Name */			"<Not Used>",
	/* Flags */			0,
	/* Params */		(0)
) {
	
}
ACTION(
	/* ID */			353,
	/* Name */			"Enumerate All",
	/* Flags */			0,
	/* Params */		(0)
) {
	b2Body* b = rdPtr->world->GetBodyList();

	while(b)
	{
		if(b != rdPtr->world->GetGroundBody())
		{
			rdPtr->enumBody = b->GetUserData()->ID;
			rdPtr->rRd->GenerateEvent(57);
		}
		
		b2Shape* s = b->GetShapeList();
		while(s)
		{
			rdPtr->enumShape = s->GetUserData()->ID;
			rdPtr->rRd->GenerateEvent(58);

			switch(s->GetType())
			{
			case e_polygonShape:
				rdPtr->rRd->GenerateEvent(61);
				break;
			case e_circleShape:
				rdPtr->rRd->GenerateEvent(62);
				break;
			case e_edgeShape:
				rdPtr->rRd->GenerateEvent(63);
				break;
			}

			s = s->GetNext();
		}
		b = b->GetNext();
	}

	rdPtr->enumBody = -2;
	rdPtr->enumShape = -2;

	b2Joint* j = rdPtr->world->GetJointList();

	while(j)
	{
		rdPtr->enumJoint = j->GetUserData()->ID;
		rdPtr->rRd->GenerateEvent(59);

		switch(j->GetType())
		{
		case e_revoluteJoint:
			rdPtr->rRd->GenerateEvent(64);
			break;
		case e_prismaticJoint:
			rdPtr->rRd->GenerateEvent(65);
			break;
		case e_distanceJoint:
			rdPtr->rRd->GenerateEvent(66);
			break;
		case e_pulleyJoint:
			rdPtr->rRd->GenerateEvent(67);
			break;
		case e_lineJoint:
			rdPtr->rRd->GenerateEvent(68);
			break;
		case e_gearJoint:
			rdPtr->rRd->GenerateEvent(69);
			break;
		case e_mouseJoint:
			rdPtr->rRd->GenerateEvent(70);
			break;
		}

		j = j->GetNext();
	}
	
	rdPtr->enumJoint = -1;
}
ACTION(
	/* ID */			354,
	/* Name */			"Remove Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_NUMBER,"Body ID",PARAM_NUMBER,"Joint Number")
) {
	int bn = lParam();

	b2Body* jb = getBody(bn,rdPtr);

	b2Joint* j = getJoint(jb,bn);

	if(!j) return;

	int n = j->GetUserData()->ID;

	b2Body* b = getBody(j->GetUserData()->body1,rdPtr);
	b2Body* b2 = getBody(j->GetUserData()->body2,rdPtr);

	if(b) b->GetUserData()->numJoints--;
	if(b2) b2->GetUserData()->numJoints--;

	rdPtr->world->DestroyJoint(j);

	rdPtr->joints[n] = NULL;
}
ACTION(
	/* ID */			355,
	/* Name */			"Remove Joint (%1) of Body (%0)",
	/* Flags */			0,
	/* Params */		(2,PARAM_OBJECT,"Object",PARAM_NUMBER,"Joint Number")
) {
	LPRO obj = oParam();
	int n = lParam();

	if(!obj) return;
	
	if(!hasAttachment(obj,rdPtr)) return;

	int bn = rdPtr->AttachedObjectIDs[obj->roHo.hoNumber];

	b2Body* jb = getBody(bn,rdPtr);

	b2Joint* j = getJoint(jb,n);

	if(!j) return;

	b2Body* b = getBody(j->GetUserData()->body1,rdPtr);
	b2Body* b2 = getBody(j->GetUserData()->body2,rdPtr);

	if(b) b->GetUserData()->numJoints--;
	if(b2) b2->GetUserData()->numJoints--;

	rdPtr->world->DestroyJoint(j);

	rdPtr->joints[n] = NULL;
}

ACTION(
	/* ID */			356,
	/* Name */			"Raycast Does Not Collide with Starting Shapes",
	/* Flags */			0,
	/* Params */		(0)
) {
	rdPtr->ray.ud.solidShapes = false;
}

// ============================================================================
//
// EXPRESSIONS
// 
// ============================================================================

EXPRESSION(
	/* ID */			0,
	/* Name */			"LastBodyID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->lastBody;
}

EXPRESSION(
	/* ID */			1,
	/* Name */			"BodyVelocityY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLinearVelocity().y);
}

EXPRESSION(
	/* ID */			2,
	/* Name */			"LastJointID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->lastJoint;
}

EXPRESSION(
	/* ID */			3,
	/* Name */			"GravityX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->world->GetGravity().x);
}

EXPRESSION(
	/* ID */			4,
	/* Name */			"GravityY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->world->GetGravity().y);
}

EXPRESSION(
	/* ID */			5,
	/* Name */			"BoundaryMinX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->bounds.lowerBound.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			6,
	/* Name */			"BoundaryMinY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->bounds.lowerBound.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			7,
	/* Name */			"BoundaryMaxX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->bounds.upperBound.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			8,
	/* Name */			"BoundaryMaxY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->bounds.upperBound.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			9,
	/* Name */			"TimeStep(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->timestep);
}

EXPRESSION(
	/* ID */			10,
	/* Name */			"UnitScale(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->scale);
}

EXPRESSION(
	/* ID */			11,
	/* Name */			"PositionIterations(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->posIterations;
}

EXPRESSION(
	/* ID */			12,
	/* Name */			"VelocityIterations(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->velIterations;
}

EXPRESSION(
	/* ID */			13,
	/* Name */			"MaxBodies(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->maxBodies;
}

EXPRESSION(
	/* ID */			14,
	/* Name */			"MaxJoints(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->maxJoints;
}

EXPRESSION(
	/* ID */			15,
	/* Name */			"MaxBodyDefs(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->maxBodyDefs;
}

EXPRESSION(
	/* ID */			16,
	/* Name */			"MaxJointDefs(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->maxJointDefs;
}

EXPRESSION(
	/* ID */			17,
	/* Name */			"MaxShapeDefs(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->maxShapeDefs;
}

EXPRESSION(
	/* ID */			18,
	/* Name */			"NumProxies(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->world->GetProxyCount();
}

EXPRESSION(
	/* ID */			19,
	/* Name */			"MaxProxies(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->settings.b2_maxProxies;
}

EXPRESSION(
	/* ID */			20,
	/* Name */			"NumPairs(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->world->GetPairCount();
}

EXPRESSION(
	/* ID */			21,
	/* Name */			"MaxPairs(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->settings.b2_maxPairs;
}

EXPRESSION(
	/* ID */			22,
	/* Name */			"NumBodies(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->world->GetBodyCount()-1; // - ground body
}

EXPRESSION(
	/* ID */			23,
	/* Name */			"NumJoints(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->world->GetJointCount();
}

EXPRESSION(
	/* ID */			24,
	/* Name */			"NumContacts(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->world->GetContactCount();
}

EXPRESSION(
	/* ID */			25,
	/* Name */			"BodyVelocityX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLinearVelocity().x);
}

EXPRESSION(
	/* ID */			26,
	/* Name */			"BodyAngularVelocity(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetAngularVelocity());
}

EXPRESSION(
	/* ID */			27,
	/* Name */			"EventBodyID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->eventBody;
}

EXPRESSION(
	/* ID */			28,
	/* Name */			"EventJointID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->eventJoint;
}

EXPRESSION(
	/* ID */			29,
	/* Name */			"BodyFixedID(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Fixed Value of Object")
) {
	short n = (short)xlParam();

	if(n < 0 || n >= rdPtr->rHo.hoAdRunHeader->rhMaxObjects) return -1;

	return rdPtr->AttachedObjectIDs[n];
}

EXPRESSION(
	/* ID */			30,
	/* Name */			"BodyIndexID(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Index")
) {
	int n = xlParam();

	int x = 0;
	for(int i = 0; i < rdPtr->maxBodies; i++)
	{
		if(rdPtr->bodies[i]) x++;
		if(x > n) return i;
	}
	return -1;
}

EXPRESSION(
	/* ID */			31,
	/* Name */			"CollBody1(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->collData.body1;
}

EXPRESSION(
	/* ID */			32,
	/* Name */			"CollBody2(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->collData.body2;
}

EXPRESSION(
	/* ID */			33,
	/* Name */			"CollShape1(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->collData.shape1;
}

EXPRESSION(
	/* ID */			34,
	/* Name */			"CollShape2(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->collData.shape2;
}

EXPRESSION(
	/* ID */			35,
	/* Name */			"CollAngle(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.angle);
}

EXPRESSION(
	/* ID */			36,
	/* Name */			"CollNormalImpulse(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.impulse.y);
}

EXPRESSION(
	/* ID */			37,
	/* Name */			"CollTangentImpulse(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.impulse.x);
}

EXPRESSION(
	/* ID */			38,
	/* Name */			"CollPointX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.collPoint.x);
}

EXPRESSION(
	/* ID */			39,
	/* Name */			"CollPointY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.collPoint.y);
}

EXPRESSION(
	/* ID */			40,
	/* Name */			"JointIndexID(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Index")
) {
	int n = xlParam();

	int x = 0;
	for(int i = 0; i < rdPtr->maxJoints; i++)
	{
		if(rdPtr->joints[i]) x++;
		if(x > n) return i;
	}
	return -1;
}

EXPRESSION(
	/* ID */			41,
	/* Name */			"LocalToWorldX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X",EXPPARAM_NUMBER,"Y")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);

	rdPtr->lastConv = b->GetWorldPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale));
	
	ReturnFloat(rdPtr->lastConv.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			42,
	/* Name */			"LocalToWorldY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X",EXPPARAM_NUMBER,"Y")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);

	rdPtr->lastConv = b->GetWorldPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale));
	
	ReturnFloat(rdPtr->lastConv.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			43,
	/* Name */			"WorldToLocalX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X",EXPPARAM_NUMBER,"Y")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);

	rdPtr->lastConv = b->GetLocalPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale));
	
	ReturnFloat(rdPtr->lastConv.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			44,
	/* Name */			"WorldToLocalY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X",EXPPARAM_NUMBER,"Y")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);

	rdPtr->lastConv = b->GetLocalPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale));
	
	ReturnFloat(rdPtr->lastConv.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			45,
	/* Name */			"LastConvX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->lastConv.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			46,
	/* Name */			"LastConvY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->lastConv.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			47,
	/* Name */			"BodyX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetPosition().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			48,
	/* Name */			"BodyY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetPosition().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			49,
	/* Name */			"BodyAngle(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetAngle() * RAD_TO_DEG);
}

EXPRESSION(
	/* ID */			50,
	/* Name */			"BodyMass(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetMass());
}

EXPRESSION(
	/* ID */			51,
	/* Name */			"BodyInertia(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetInertia());
}

EXPRESSION(
	/* ID */			52,
	/* Name */			"BodyCoMX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLocalCenter().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			53,
	/* Name */			"BodyCoMY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLocalCenter().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			54,
	/* Name */			"BodyNumShapes(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;
	
	return b->GetUserData()->numShapes;
}

EXPRESSION(
	/* ID */			55,
	/* Name */			"BodyNumJoints(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Body ID")
) {
	int n = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;
	
	return b->GetUserData()->numJoints;
}

EXPRESSION(
	/* ID */			56,
	/* Name */			"BodyJointID(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Joint Number")
) {
	int n = xlParam();
	int jn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return -1;

	b2Joint* j = getJoint(b,jn);

	if(!j) return -1;
	
	return j->GetUserData()->ID;
}

EXPRESSION(
	/* ID */			57,
	/* Name */			"RayNumHits(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->ray.hits;
}

EXPRESSION(
	/* ID */			58,
	/* Name */			"RayBodyID(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Hit Number")
) {
	int n = xlParam();

	if(n < 0 || n >= rdPtr->ray.hits) return -1;

	return rdPtr->ray.shapes[n]->GetBody()->GetUserData()->ID;
}

EXPRESSION(
	/* ID */			59,
	/* Name */			"RayShapeID(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Hit Number")
) {
	int n = xlParam();

	if(n < 0 || n >= rdPtr->ray.hits) return -1;

	return rdPtr->ray.shapes[n]->GetUserData()->ID;
}

EXPRESSION(
	/* ID */			60,
	/* Name */			"RayPointX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->ray.point.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			61,
	/* Name */			"RayPointY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->ray.point.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			62,
	/* Name */			"RayPointAngle(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(atan2(rdPtr->ray.normal.y,rdPtr->ray.normal.x) * RAD_TO_DEG);
}

EXPRESSION(
	/* ID */			63,
	/* Name */			"ShapeType(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;

	b2Shape* s = getShape(b,sn);

	if(!s) return 0;

	return s->GetType();
}

EXPRESSION(
	/* ID */			64,
	/* Name */			"ShapeFriction(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2Shape* s = getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	ReturnFloat(s->GetFriction());
}

EXPRESSION(
	/* ID */			65,
	/* Name */			"ShapeElasticity(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2Shape* s = getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	ReturnFloat(s->GetRestitution());
}

EXPRESSION(
	/* ID */			66,
	/* Name */			"ShapeDensity(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2Shape* s = getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	ReturnFloat(s->GetDensity());
}

EXPRESSION(
	/* ID */			67,
	/* Name */			"ShapeCollType(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;

	b2Shape* s = getShape(b,sn);

	if(!s) return 0;

	return s->GetUserData()->collType;
}

EXPRESSION(
	/* ID */			68,
	/* Name */			"ShapeGroupIndex(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;

	b2Shape* s = getShape(b,sn);

	if(!s) return 0;

	return s->GetFilterData().groupIndex;
}

EXPRESSION(
	/* ID */			69,
	/* Name */			"ShapeCategory(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;

	b2Shape* s = getShape(b,sn);

	if(!s) return 0;

	return s->GetFilterData().categoryBits;
}

EXPRESSION(
	/* ID */			70,
	/* Name */			"ShapeMask(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;

	b2Shape* s = getShape(b,sn);

	if(!s) return 0;

	return s->GetFilterData().maskBits;
}

EXPRESSION(
	/* ID */			71,
	/* Name */			"PolygonShapeNumVerts(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;

	b2PolygonShape* s = (b2PolygonShape*)getShape(b,sn);

	if(!s) return 0;

	if(s->GetType() != e_polygonShape) return 0;

	return s->GetVertexCount();
}

EXPRESSION(
	/* ID */			72,
	/* Name */			"PolygonShapeVertexX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number",EXPPARAM_NUMBER,"Vertex Number")
) {
	int n = xlParam();
	int sn = xlParam();
	int vn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2PolygonShape* s = (b2PolygonShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_polygonShape) ReturnFloat(0.0f);

	if(vn < 0 || vn >= s->GetVertexCount()) ReturnFloat(0.0f);

	ReturnFloat(b->GetWorldPoint(s->GetVertices()[vn]).x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			73,
	/* Name */			"PolygonShapeVertexY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number",EXPPARAM_NUMBER,"Vertex Number")
) {
	int n = xlParam();
	int sn = xlParam();
	int vn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2PolygonShape* s = (b2PolygonShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_polygonShape) ReturnFloat(0.0f);

	if(vn < 0 || vn >= s->GetVertexCount()) ReturnFloat(0.0f);

	ReturnFloat(b->GetWorldPoint(s->GetVertices()[vn]).y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			74,
	/* Name */			"PolygonShapeCentroidX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2PolygonShape* s = (b2PolygonShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_polygonShape) ReturnFloat(0.0f);

	ReturnFloat(b->GetWorldPoint(s->GetCentroid()).x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			75,
	/* Name */			"PolygonShapeCentroidY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2PolygonShape* s = (b2PolygonShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_polygonShape) ReturnFloat(0.0f);

	ReturnFloat(b->GetWorldPoint(s->GetCentroid()).y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			76,
	/* Name */			"JointBody1(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) return 0;

	return j->GetBody2()->GetUserData()->ID;
}

EXPRESSION(
	/* ID */			77,
	/* Name */			"JointBody2(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) return 0;

	return j->GetBody1()->GetUserData()->ID;
}

EXPRESSION(
	/* ID */			78,
	/* Name */			"JointType(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) return 0;

	return j->GetType();
}

EXPRESSION(
	/* ID */			79,
	/* Name */			"JointAnchor1X(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetAnchor2().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			80,
	/* Name */			"JointAnchor1Y(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetAnchor2().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			81,
	/* Name */			"JointAnchor2X(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetAnchor1().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			82,
	/* Name */			"JointAnchor2Y(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetAnchor1().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			83,
	/* Name */			"JointReactionForce(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetReactionForce(1.0f/rdPtr->timestep).Length());
}

EXPRESSION(
	/* ID */			84,
	/* Name */			"JointReactionForceX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetReactionForce(1.0f/rdPtr->timestep).x);
}

EXPRESSION(
	/* ID */			85,
	/* Name */			"JointReactionForceY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetReactionForce(1.0f/rdPtr->timestep).y);
}

EXPRESSION(
	/* ID */			86,
	/* Name */			"JointReactionTorque(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2Joint* j = getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	ReturnFloat(j->GetReactionTorque(1.0f/rdPtr->timestep));
}

EXPRESSION(
	/* ID */			87,
	/* Name */			"RevoluteJointAngle(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_revoluteJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetJointAngle() * RAD_TO_DEG);
}

EXPRESSION(
	/* ID */			88,
	/* Name */			"RevoluteJointSpeed(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_revoluteJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetJointSpeed());
}

EXPRESSION(
	/* ID */			89,
	/* Name */			"RevoluteJointUpperLimit(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_revoluteJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetUpperLimit() * RAD_TO_DEG);
}

EXPRESSION(
	/* ID */			90,
	/* Name */			"RevoluteJointLowerLimit(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_revoluteJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetLowerLimit() * RAD_TO_DEG);
}

EXPRESSION(
	/* ID */			91,
	/* Name */			"RevoluteJointMotorSpeed(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_revoluteJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetMotorSpeed());
}

EXPRESSION(
	/* ID */			92,
	/* Name */			"RevoluteJointMotorTorque(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2RevoluteJoint* j = (b2RevoluteJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_revoluteJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetMotorTorque());
}

EXPRESSION(
	/* ID */			93,
	/* Name */			"PrismaticJointTranslation(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_prismaticJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetJointTranslation() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			94,
	/* Name */			"PrismaticJointSpeed(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_prismaticJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetJointSpeed());
}

EXPRESSION(
	/* ID */			95,
	/* Name */			"PrismaticJointUpperLimit(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_prismaticJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetUpperLimit() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			96,
	/* Name */			"PrismaticJointLowerLimit(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_prismaticJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetLowerLimit() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			97,
	/* Name */			"PrismaticJointMotorSpeed(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_prismaticJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetMotorSpeed());
}

EXPRESSION(
	/* ID */			98,
	/* Name */			"PrismaticJointMotorForce(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PrismaticJoint* j = (b2PrismaticJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_prismaticJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetMotorForce());
}

EXPRESSION(
	/* ID */			99,
	/* Name */			"PulleyJointGround1X(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PulleyJoint* j = (b2PulleyJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_pulleyJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetGroundAnchor2().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			100,
	/* Name */			"PulleyJointGround1Y(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PulleyJoint* j = (b2PulleyJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_pulleyJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetGroundAnchor2().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			101,
	/* Name */			"PulleyJointGround2X(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PulleyJoint* j = (b2PulleyJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_pulleyJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetGroundAnchor1().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			102,
	/* Name */			"PulleyJointGround2Y(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PulleyJoint* j = (b2PulleyJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_pulleyJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetGroundAnchor1().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			103,
	/* Name */			"PulleyJointLength1(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PulleyJoint* j = (b2PulleyJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_pulleyJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetLength2() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			104,
	/* Name */			"PulleyJointLength2(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PulleyJoint* j = (b2PulleyJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_pulleyJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetLength1() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			105,
	/* Name */			"PulleyJointRatio(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2PulleyJoint* j = (b2PulleyJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_pulleyJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetRatio());
}

EXPRESSION(
	/* ID */			106,
	/* Name */			"GearJointRatio(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2GearJoint* j = (b2GearJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_gearJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetRatio());
}

EXPRESSION(
	/* ID */			107,
	/* Name */			"LineJointTranslation(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_lineJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetJointTranslation() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			108,
	/* Name */			"LineJointSpeed(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_lineJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetJointSpeed());
}

EXPRESSION(
	/* ID */			109,
	/* Name */			"LineJointUpperLimit(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_lineJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetUpperLimit() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			110,
	/* Name */			"LineJointLowerLimit(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_lineJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetLowerLimit() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			111,
	/* Name */			"LineJointMotorSpeed(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_lineJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetMotorSpeed());
}

EXPRESSION(
	/* ID */			112,
	/* Name */			"LineJointMotorForce(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(1,EXPPARAM_NUMBER,"Joint ID")
) {
	int n = xlParam();

	b2LineJoint* j = (b2LineJoint*)getJoint(n,rdPtr);
	
	if(!j) ReturnFloat(0.0f);

	if(j->GetType() != e_lineJoint) ReturnFloat(0.0f);

	ReturnFloat(j->GetMotorForce());
}

EXPRESSION(
	/* ID */			113,
	/* Name */			"CircleShapeRadius(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2CircleShape* s = (b2CircleShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_circleShape) ReturnFloat(0.0f);

	ReturnFloat(s->GetRadius() * rdPtr->scale);
}

EXPRESSION(
	/* ID */			114,
	/* Name */			"CircleShapeCenterX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2CircleShape* s = (b2CircleShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_circleShape) ReturnFloat(0.0f);

	ReturnFloat(b->GetWorldPoint(s->GetLocalPosition()).x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			115,
	/* Name */			"CircleShapeCenterY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2CircleShape* s = (b2CircleShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_circleShape) ReturnFloat(0.0f);

	ReturnFloat(b->GetWorldPoint(s->GetLocalPosition()).y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			116,
	/* Name */			"EdgeFirstX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2EdgeShape* s = (b2EdgeShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_edgeShape) ReturnFloat(0.0f);

	ReturnFloat(s->GetVertex1().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			117,
	/* Name */			"EdgeFirstY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2EdgeShape* s = (b2EdgeShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_edgeShape) ReturnFloat(0.0f);

	ReturnFloat(s->GetVertex1().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			118,
	/* Name */			"EdgeSecondX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2EdgeShape* s = (b2EdgeShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_edgeShape) ReturnFloat(0.0f);

	ReturnFloat(s->GetVertex2().x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			119,
	/* Name */			"EdgeSecondY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2EdgeShape* s = (b2EdgeShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_edgeShape) ReturnFloat(0.0f);

	ReturnFloat(s->GetVertex2().y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			120,
	/* Name */			"EventShapeID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->eventShape;
}

EXPRESSION(
	/* ID */			121,
	/* Name */			"CollType1(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->collData.type1;
}

EXPRESSION(
	/* ID */			122,
	/* Name */			"CollType2(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->collData.type2;
}

EXPRESSION(
	/* ID */			123,
	/* Name */			"ShapeBBMinX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2Shape* s = getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	b2AABB aabb;
	s->ComputeAABB(&aabb,s->GetBody()->GetXForm());

	ReturnFloat(aabb.lowerBound.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			124,
	/* Name */			"ShapeBBMinY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2Shape* s = getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	b2AABB aabb;
	s->ComputeAABB(&aabb,s->GetBody()->GetXForm());

	ReturnFloat(aabb.lowerBound.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			125,
	/* Name */			"ShapeBBMaxX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2Shape* s = getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	b2AABB aabb;
	s->ComputeAABB(&aabb,s->GetBody()->GetXForm());

	ReturnFloat(aabb.upperBound.x * rdPtr->scale);
}

EXPRESSION(
	/* ID */			126,
	/* Name */			"ShapeBBMaxY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2Shape* s = getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	b2AABB aabb;
	s->ComputeAABB(&aabb,s->GetBody()->GetXForm());

	ReturnFloat(aabb.upperBound.y * rdPtr->scale);
}

EXPRESSION(
	/* ID */			127,
	/* Name */			"LastControllerID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->lastController;
}

EXPRESSION(
	/* ID */			128,
	/* Name */			"ShapeSensor(",
	/* Flags */			0,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) return 0;

	b2Shape* s = getShape(b,sn);

	if(!s) return 0;

	ReturnFloat(s->IsSensor());
}

EXPRESSION(
	/* ID */			129,
	/* Name */			"NumControllers(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->world->GetControllerCount();
}

EXPRESSION(
	/* ID */			130,
	/* Name */			"ControllerIndexID(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Index")
) {
	int n = xlParam();

	int x = 0;
	for(int i = 0; i < rdPtr->maxControllers; i++)
	{
		if(rdPtr->controllers[i]) x++;
		if(x > n) return i;
	}
	return -1;
}

EXPRESSION(
	/* ID */			131,
	/* Name */			"ControllerNumBodies(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Controller ID")
) {
	int n = xlParam();

	b2Controller* c = getController(n,rdPtr);

	if(!c) return 0;

	b2ControllerEdge* b = c->GetBodyList();

	int num = 0;

	while(b)
	{
		num++;
		b = b->nextBody;
	}

	return num;
}

EXPRESSION(
	/* ID */			132,
	/* Name */			"ControllerBodyID(",
	/* Flags */			0,
	/* Params */		(1,EXPPARAM_NUMBER,"Controller ID")
) {
	int n = xlParam();

	b2Controller* c = getController(n,rdPtr);

	if(!c) return -1;

	b2Body* b = getBody(c,n);

	if(!b) return -1;

	return b->GetUserData()->ID;
}

EXPRESSION(
	/* ID */			133,
	/* Name */			"CollVelocityX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.velocity.x);
}

EXPRESSION(
	/* ID */			134,
	/* Name */			"CollVelocityY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.velocity.x);
}

EXPRESSION(
	/* ID */			135,
	/* Name */			"CollFriction(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.friction);
}

EXPRESSION(
	/* ID */			136,
	/* Name */			"CollElasticity(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.restitution);
}

EXPRESSION(
	/* ID */			137,
	/* Name */			"CollSeparation(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(0)
) {
	ReturnFloat(rdPtr->collData.separation * rdPtr->scale);
}

EXPRESSION(
	/* ID */			138,
	/* Name */			"PolygonShapeVertexAngle(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number",EXPPARAM_NUMBER,"Vertex Number")
) {
	int n = xlParam();
	int sn = xlParam();
	int vn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2PolygonShape* s = (b2PolygonShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_polygonShape) ReturnFloat(0.0f);

	if(vn < 0 || vn >= s->GetVertexCount()) ReturnFloat(0.0f);

	int vn2 = (vn + 1) % s->GetVertexCount();

	b2Vec2 diff = s->GetNormals()[vn] + s->GetNormals()[vn2];
	diff.Normalize();

	float angle = atan2(diff.y,diff.x) * RAD_TO_DEG;

	ReturnFloat(fmodf(450.0f - angle, 360.0f) - 180.0f);
}

EXPRESSION(
	/* ID */			139,
	/* Name */			"EdgeFirstAngle(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2EdgeShape* s = (b2EdgeShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_edgeShape) ReturnFloat(0.0f);

	b2Vec2 diff = s->GetCorner1Vector();

	float angle = atan2(diff.y,diff.x) * RAD_TO_DEG;

	ReturnFloat(fmodf(450.0f - angle, 360.0f) - 180.0f);
}

EXPRESSION(
	/* ID */			140,
	/* Name */			"EdgeSecondAngle(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(2,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"Shape Number")
) {
	int n = xlParam();
	int sn = xlParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0.0f);

	b2EdgeShape* s = (b2EdgeShape*)getShape(b,sn);

	if(!s) ReturnFloat(0.0f);

	if(s->GetType() != e_edgeShape) ReturnFloat(0.0f);

	b2Vec2 diff = s->GetCorner2Vector();

	float angle = atan2(diff.y,diff.x) * RAD_TO_DEG;

	ReturnFloat(fmodf(450.0f - angle, 360.0f) - 180.0f);
}

EXPRESSION(
	/* ID */			141,
	/* Name */			"EnumBodyID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->enumBody;
}

EXPRESSION(
	/* ID */			142,
	/* Name */			"EnumShapeID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->enumShape;
}

EXPRESSION(
	/* ID */			143,
	/* Name */			"EnumJointID(",
	/* Flags */			0,
	/* Params */		(0)
) {
	return rdPtr->enumJoint;
}

EXPRESSION(
	/* ID */			144,
	/* Name */			"BodyVelocityAtWorldPointX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X Coordinate",EXPPARAM_NUMBER,"Y Coordinate")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLinearVelocityFromWorldPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale)).x);
}

EXPRESSION(
	/* ID */			145,
	/* Name */			"BodyVelocityAtWorldPointY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X Coordinate",EXPPARAM_NUMBER,"Y Coordinate")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLinearVelocityFromWorldPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale)).y);
}

EXPRESSION(
	/* ID */			146,
	/* Name */			"BodyVelocityAtLocalPointX(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X Coordinate",EXPPARAM_NUMBER,"Y Coordinate")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLinearVelocityFromLocalPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale)).x);
}

EXPRESSION(
	/* ID */			147,
	/* Name */			"BodyVelocityAtLocalPointY(",
	/* Flags */			EXPFLAG_DOUBLE,
	/* Params */		(3,EXPPARAM_NUMBER,"Body ID",EXPPARAM_NUMBER,"X Coordinate",EXPPARAM_NUMBER,"Y Coordinate")
) {
	int n = xlParam();
	float x = xfParam();
	float y = xfParam();

	b2Body* b = getBody(n,rdPtr);
	
	if(!b) ReturnFloat(0);
	
	ReturnFloat(b->GetLinearVelocityFromLocalPoint(b2Vec2(x/rdPtr->scale,y/rdPtr->scale)).y);
}