#!/usr/bin/env python3
"""Release-build RID validation for chosen owners (port patch).

Debug builds keep a set of live ids per RID_Owner and refuse stale/foreign RIDs with an error; release
builds dereference them (use after free -> heap corruption). With `owner.validate = true` (set before the
first make_rid) an owner keeps that set in release builds too and checks get/getornull/owns against it.
Enabled for the GLES3 material owner and the VisualServerScene instance owner, which receive stale RIDs
from game scripts in Cassette Beasts' IN_RANGE level streaming (material_set_param,
instance_set_surface_material on freed objects). Owners used from several threads (physics) stay as they are.
usage: apply_rid_validate.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'VALIDATE-PATCH' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, (old[:70], s.count(old))
    return s.replace(old, new)


def rid_h(s):
    s = once(s, '''public:
#ifdef DEBUG_ENABLED
	mutable Set<RID_Data *> id_map;
#endif
public:
	_FORCE_INLINE_ RID make_rid(T *p_data) {
		RID rid;
		_set_data(rid, p_data);

#ifdef DEBUG_ENABLED
		id_map.insert(p_data);
#endif

		return rid;
	}

	_FORCE_INLINE_ T *get(const RID &p_rid) {
#ifdef DEBUG_ENABLED

		ERR_FAIL_COND_V(!p_rid.is_valid(), nullptr);
		ERR_FAIL_COND_V(!id_map.has(p_rid.get_data()), nullptr);
#endif
		return static_cast<T *>(p_rid.get_data());
	}

	_FORCE_INLINE_ T *getornull(const RID &p_rid) {
#ifdef DEBUG_ENABLED

		if (p_rid.get_data()) {
			ERR_FAIL_COND_V(!id_map.has(p_rid.get_data()), nullptr);
		}
#endif
		return static_cast<T *>(p_rid.get_data());
	}
''', '''public:
	// VALIDATE-PATCH: the live-id set exists in release builds too, used when `validate` is set
	// (before the first make_rid; only for owners used from one thread)
	mutable Set<RID_Data *> id_map;
	bool validate = false;
public:
	_FORCE_INLINE_ RID make_rid(T *p_data) {
		RID rid;
		_set_data(rid, p_data);

#ifdef DEBUG_ENABLED
		id_map.insert(p_data);
#else
		if (validate) {
			id_map.insert(p_data);
		}
#endif

		return rid;
	}

	_FORCE_INLINE_ T *get(const RID &p_rid) {
#ifdef DEBUG_ENABLED

		ERR_FAIL_COND_V(!p_rid.is_valid(), nullptr);
		ERR_FAIL_COND_V(!id_map.has(p_rid.get_data()), nullptr);
#else
		if (validate) {
			ERR_FAIL_COND_V(!p_rid.is_valid(), nullptr);
			ERR_FAIL_COND_V(!id_map.has(p_rid.get_data()), nullptr);
		}
#endif
		return static_cast<T *>(p_rid.get_data());
	}

	_FORCE_INLINE_ T *getornull(const RID &p_rid) {
#ifdef DEBUG_ENABLED

		if (p_rid.get_data()) {
			ERR_FAIL_COND_V(!id_map.has(p_rid.get_data()), nullptr);
		}
#else
		if (validate && p_rid.get_data()) {
			ERR_FAIL_COND_V(!id_map.has(p_rid.get_data()), nullptr);
		}
#endif
		return static_cast<T *>(p_rid.get_data());
	}
''')
    s = once(s, '''#ifdef DEBUG_ENABLED
		return id_map.has(p_rid.get_data());
#else
		return _is_owner(p_rid);
#endif
	}

	void free(RID p_rid) {
#ifdef DEBUG_ENABLED
		id_map.erase(p_rid.get_data());
#else
		_remove_owner(p_rid);
#endif
	}''', '''#ifdef DEBUG_ENABLED
		return id_map.has(p_rid.get_data());
#else
		return validate ? id_map.has(p_rid.get_data()) : _is_owner(p_rid);
#endif
	}

	void free(RID p_rid) {
#ifdef DEBUG_ENABLED
		id_map.erase(p_rid.get_data());
#else
		if (validate) {
			id_map.erase(p_rid.get_data());
		}
		_remove_owner(p_rid);
#endif
	}''')
    return s


def storage_cpp(s):
    return once(s, '''void RasterizerStorageGLES3::initialize() {
''', '''void RasterizerStorageGLES3::initialize() {
	material_owner.validate = true; // VALIDATE-PATCH: stale material RIDs from scripts become errors
''')


def scene_cpp(s):
    return once(s, '''VisualServerScene::VisualServerScene() {
''', '''VisualServerScene::VisualServerScene() {
	instance_owner.validate = true; // VALIDATE-PATCH: stale instance RIDs become errors
''')


edit('core/rid.h', rid_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
edit('servers/visual/visual_server_scene.cpp', scene_cpp)
