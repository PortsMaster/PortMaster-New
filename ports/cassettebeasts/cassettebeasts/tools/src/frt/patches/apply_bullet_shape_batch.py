#!/usr/bin/env python3
"""Bullet: rebuild a body's compound shape once per batch of added shapes (port patch, always on).

Godot 3's Bullet backend rebuilds a body's whole btCompoundShape every time a shape is added
(RigidCollisionObjectBullet::add_shape -> reload_shapes): a body built from n shapes costs ~n^2/2 child
insertions. GridMap creates one static body per octant and adds a shape per cell, so a chunk's terrain entering the
tree cost 116-288 ms in one deferred _update_octants_callback on the RG Cube XX (Cassette Beasts walking hitches,
apply_slow_frame_log.py). Here add_shape only marks the body; dirty bodies rebuild their shape once, before the
physics server is next used: BulletPhysicsServer::flush_queries (start of each physics tick), step,
space_get_direct_state (script ray/shape queries) and body_test_motion / body_test_ray_separation
(move_and_slide outside the physics tick). Every other path that rebuilds (set_shape, remove_shape, transforms,
scale) still rebuilds at once and clears the mark; a freed body leaves the list.
usage: apply_bullet_shape_batch.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'BULLET-SHAPE-BATCH-PATCH'


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if MARK in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, (old[:70], s.count(old))
    return s.replace(old, new)


def header(s):
    return once(s, '''class RigidCollisionObjectBullet : public CollisionObjectBullet, public ShapeOwnerBullet {
protected:
	btCollisionShape *mainShape;
	Vector<ShapeWrapper> shapes;

public:
''', '''class RigidCollisionObjectBullet : public CollisionObjectBullet, public ShapeOwnerBullet {
protected:
	btCollisionShape *mainShape;
	Vector<ShapeWrapper> shapes;
	// BULLET-SHAPE-BATCH-PATCH: add_shape marks the body; the compound is rebuilt once before physics uses it
	bool shapes_dirty = false;
	static Set<RigidCollisionObjectBullet *> dirty_shape_objects;

public:
	static void flush_dirty_shapes();
''')


def source(s):
    s = once(s, '''RigidCollisionObjectBullet::~RigidCollisionObjectBullet() {
''', '''Set<RigidCollisionObjectBullet *> RigidCollisionObjectBullet::dirty_shape_objects; // BULLET-SHAPE-BATCH-PATCH

void RigidCollisionObjectBullet::flush_dirty_shapes() {
	while (dirty_shape_objects.size()) {
		RigidCollisionObjectBullet *o = dirty_shape_objects.front()->get();
		dirty_shape_objects.erase(dirty_shape_objects.front());
		o->shapes_dirty = false;
		o->reload_shapes();
	}
}

RigidCollisionObjectBullet::~RigidCollisionObjectBullet() {
	if (shapes_dirty) { // BULLET-SHAPE-BATCH-PATCH
		dirty_shape_objects.erase(this);
		shapes_dirty = false;
	}
''')
    s = once(s, '''	shapes.push_back(ShapeWrapper(p_shape, p_transform, !p_disabled));
	p_shape->add_owner(this);
	reload_shapes();
}''', '''	shapes.push_back(ShapeWrapper(p_shape, p_transform, !p_disabled));
	p_shape->add_owner(this);
	if (!shapes_dirty) { // BULLET-SHAPE-BATCH-PATCH: rebuilt once in flush_dirty_shapes()
		shapes_dirty = true;
		dirty_shape_objects.insert(this);
	}
}''')
    s = once(s, '''void RigidCollisionObjectBullet::reload_shapes() {
	if (mainShape && mainShape->isCompound()) {''', '''void RigidCollisionObjectBullet::reload_shapes() {
	if (shapes_dirty) { // BULLET-SHAPE-BATCH-PATCH: rebuilt now
		shapes_dirty = false;
		dirty_shape_objects.erase(this);
	}
	if (mainShape && mainShape->isCompound()) {''')
    return s


def server(s):
    s = once(s, '''PhysicsDirectSpaceState *BulletPhysicsServer::space_get_direct_state(RID p_space) {
	SpaceBullet *space = space_owner.get(p_space);''', '''PhysicsDirectSpaceState *BulletPhysicsServer::space_get_direct_state(RID p_space) {
	RigidCollisionObjectBullet::flush_dirty_shapes(); // BULLET-SHAPE-BATCH-PATCH
	SpaceBullet *space = space_owner.get(p_space);''')
    s = once(s, '''bool BulletPhysicsServer::body_test_motion(RID p_body, const Transform &p_from, const Vector3 &p_motion, bool p_infinite_inertia, MotionResult *r_result, bool p_exclude_raycast_shapes, const Set<RID> &p_exclude) {
''', '''bool BulletPhysicsServer::body_test_motion(RID p_body, const Transform &p_from, const Vector3 &p_motion, bool p_infinite_inertia, MotionResult *r_result, bool p_exclude_raycast_shapes, const Set<RID> &p_exclude) {
	RigidCollisionObjectBullet::flush_dirty_shapes(); // BULLET-SHAPE-BATCH-PATCH
''')
    s = once(s, '''int BulletPhysicsServer::body_test_ray_separation(RID p_body, const Transform &p_transform, bool p_infinite_inertia, Vector3 &r_recover_motion, SeparationResult *r_results, int p_result_max, float p_margin) {
''', '''int BulletPhysicsServer::body_test_ray_separation(RID p_body, const Transform &p_transform, bool p_infinite_inertia, Vector3 &r_recover_motion, SeparationResult *r_results, int p_result_max, float p_margin) {
	RigidCollisionObjectBullet::flush_dirty_shapes(); // BULLET-SHAPE-BATCH-PATCH
''')
    s = once(s, '''void BulletPhysicsServer::step(float p_deltaTime) {
	if (!active) {
		return;
	}
''', '''void BulletPhysicsServer::step(float p_deltaTime) {
	RigidCollisionObjectBullet::flush_dirty_shapes(); // BULLET-SHAPE-BATCH-PATCH
	if (!active) {
		return;
	}
''')
    s = once(s, '''void BulletPhysicsServer::flush_queries() {
}''', '''void BulletPhysicsServer::flush_queries() {
	RigidCollisionObjectBullet::flush_dirty_shapes(); // BULLET-SHAPE-BATCH-PATCH
}''')
    return s


edit('modules/bullet/collision_object_bullet.h', header)
edit('modules/bullet/collision_object_bullet.cpp', source)
edit('modules/bullet/bullet_physics_server.cpp', server)
