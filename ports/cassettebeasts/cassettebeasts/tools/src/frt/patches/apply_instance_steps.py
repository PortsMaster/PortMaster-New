#!/usr/bin/env python3
"""Resumable scene instancing (port patch, generic; nothing changes unless a script uses it).

PackedScene.instance() builds the whole node tree in one call: a scene with many nodes (Cassette Beasts' town
chunks: NPCs with sprite viewports, props, game script setters) costs ~100 ms on the RG Cube XX in one frame.
SceneState::instance is split into _instance_step (the per-node loop, resumable: stops when a time budget is used up
and continues where it was) and _instance_finish (local-to-scene resources, signal connections, strays, editable
instances); instance() runs both with no budget, as before. New for scripts:
  var st = packed_scene.instance_begin()     # PackedSceneStepper
  while not st.step(4000): yield(...)         # usec budget per call (0 = to the end); true when done
  var node = st.get_node()                    # as instance() would return it (filename, NOTIFICATION_INSTANCED)
  st.get_progress()                           # 0..1 (nodes created / nodes in the scene)
Sub-scenes (instanced nodes inside the scene) are built whole within a step. A stepper dropped before the end frees
what it built.
usage: apply_instance_steps.py <godot dir>   (idempotent)
"""
import os, re, sys

G = sys.argv[1]
MARK = 'INSTANCE-STEPS-PATCH'


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


HEAD = 'Node *SceneState::instance(GenEditState p_edit_state) const {\n'
LOOP = '\tfor (int i = 0; i < nc; i++) {\n\t\tconst NodeData &n = nd[i];\n'
FINISH = '\tfor (Map<Ref<Resource>, Ref<Resource>>::Element *E = resources_local_to_scene.front(); E; E = E->next()) {\n'
END = '\treturn ret_nodes[0];\n}\n'

NAMES = '''	const StringName *snames = nullptr;
	int sname_count = names.size();
	if (sname_count) {
		snames = &names[0];
	}

	const Variant *props = nullptr;
	int prop_count = variants.size();
	if (prop_count) {
		props = &variants[0];
	}
'''


def node_from_id(fail):
    return '''#define NODE_FROM_ID(p_name, p_id)                   \\
	Node *p_name;                                    \\
	if (p_id & FLAG_ID_IS_PATH) {                    \\
		NodePath np = node_paths[p_id & FLAG_MASK];  \\
		p_name = ret_nodes[0]->get_node_or_null(np); \\
	} else {                                         \\
		ERR_FAIL_INDEX_V(p_id &FLAG_MASK, nc, %s);   \\
		p_name = ret_nodes[p_id & FLAG_MASK];        \\
	}
''' % fail


def packed_scene_cpp(s):
    a = s.index(HEAD)
    b = s.index(END, a) + len(END)
    func = s[a:b]
    loop_at = func.index(LOOP)
    finish_at = func.index(FINISH)
    loop = func[loop_at:finish_at]
    finish = func[finish_at:]
    # the loop body: failures return -1 from the step function instead of a null node
    body = loop.replace(LOOP, '')
    body = body.rstrip()
    assert body.endswith('}'), 'loop end'
    body = body[:-1]  # the loop's closing brace
    body = re.sub(r'(ERR_FAIL_[A-Z_]*V(?:_MSG)?\((?:[^;]*?)), (?:nullptr|NULL)(\)|,)', r'\1, -1\2', body)
    assert 'nullptr);' not in body.replace('ERR_FAIL', ''), 'unconverted return'
    new = '''// INSTANCE-STEPS-PATCH: SceneState::instance in two parts, the per-node part resumable
int SceneState::_instance_step(InstanceProgress &p, uint64_t p_budget_usec) const {
	GenEditState p_edit_state = p.edit;
	List<Node *> &stray_instances = p.stray;
	int nc = nodes.size();
	ERR_FAIL_COND_V(nc == 0, -1);

''' + NAMES + '''
	const NodeData *nd = &nodes[0];
	if (p.nodes.size() != nc) {
		p.nodes.resize(nc);
	}
	Node **ret_nodes = p.nodes.ptrw();
	bool gen_node_path_cache = p_edit_state != GEN_EDIT_STATE_DISABLED && node_path_cache.empty();
	Map<Ref<Resource>, Ref<Resource>> &resources_local_to_scene = p.local;
	uint64_t t0 = OS::get_singleton()->get_ticks_usec();

''' + node_from_id('-1') + '''
	const int start = p.next;
	for (int i = start; i < nc; i++) {
		if (p_budget_usec && i > start && OS::get_singleton()->get_ticks_usec() - t0 >= p_budget_usec) {
			p.next = i;
			return 0;
		}
		p.next = i + 1;
		const NodeData &n = nd[i];
''' + body + '''	}
#undef NODE_FROM_ID
	return 1;
}

Node *SceneState::_instance_finish(InstanceProgress &p) const {
	List<Node *> &stray_instances = p.stray;
	int nc = nodes.size();
''' + NAMES + '''
	Node **ret_nodes = p.nodes.ptrw();
	Map<Ref<Resource>, Ref<Resource>> &resources_local_to_scene = p.local;

''' + node_from_id('NULL') + '''
''' + finish.replace(END, '#undef NODE_FROM_ID\n' + END) + '''
Node *SceneState::instance(GenEditState p_edit_state) const {
	InstanceProgress p;
	p.edit = p_edit_state;
	if (_instance_step(p, 0) != 1) {
		return nullptr;
	}
	return _instance_finish(p);
}

int SceneState::get_instance_node_count() const {
	return nodes.size();
}
'''
    s = s[:a] + new + s[b:]
    s = once(s, '#include "packed_scene.h"\n', '#include "packed_scene.h"\n\n#include "core/os/os.h" // INSTANCE-STEPS-PATCH\n')
    # PackedSceneStepper
    s = once(s, '''void PackedScene::replace_state(Ref<SceneState> p_by) {''', '''// INSTANCE-STEPS-PATCH
Ref<PackedSceneStepper> PackedScene::instance_begin() const {
	Ref<PackedSceneStepper> st;
	st.instance();
	st->scene = Ref<PackedScene>(const_cast<PackedScene *>(this));
	st->progress.edit = SceneState::GEN_EDIT_STATE_DISABLED;
	return st;
}

bool PackedSceneStepper::step(int p_budget_usec) {
	if (done || failed || scene.is_null()) {
		return done || failed;
	}
	Ref<SceneState> state = scene->get_state();
	int r = state->_instance_step(progress, p_budget_usec > 0 ? p_budget_usec : 0);
	if (r < 0) {
		failed = true;
		_free_partial();
		return true;
	}
	if (r == 0) {
		return false;
	}
	result = state->_instance_finish(progress);
	done = true;
	if (!result) {
		failed = true;
		return true;
	}
	if (scene->get_path() != "" && scene->get_path().find("::") == -1) {
		result->set_filename(scene->get_path());
	}
	result->notification(Node::NOTIFICATION_INSTANCED);
	return true;
}

Node *PackedSceneStepper::get_node() {
	if (!done) {
		step(0);
	}
	Node *n = result;
	result = nullptr; // handed over
	return n;
}

float PackedSceneStepper::get_progress() {
	if (done) {
		return 1.0;
	}
	int nc = scene.is_valid() ? scene->get_state()->get_instance_node_count() : 0;
	return nc > 0 ? (float)progress.next / nc : 0.0;
}

void PackedSceneStepper::_free_partial() {
	if (progress.nodes.size() && progress.nodes[0]) {
		memdelete(progress.nodes[0]);
	}
	progress.nodes.clear();
	while (progress.stray.size()) {
		memdelete(progress.stray.front()->get());
		progress.stray.pop_front();
	}
}

void PackedSceneStepper::_bind_methods() {
	ClassDB::bind_method(D_METHOD("step", "budget_usec"), &PackedSceneStepper::step);
	ClassDB::bind_method(D_METHOD("get_node"), &PackedSceneStepper::get_node);
	ClassDB::bind_method(D_METHOD("get_progress"), &PackedSceneStepper::get_progress);
}

PackedSceneStepper::~PackedSceneStepper() {
	if (!done) {
		_free_partial();
	} else if (result) {
		memdelete(result); // never collected
	}
}

void PackedScene::replace_state(Ref<SceneState> p_by) {''')
    s = once(s, '''	ClassDB::bind_method(D_METHOD("can_instance"), &PackedScene::can_instance);
''', '''	ClassDB::bind_method(D_METHOD("can_instance"), &PackedScene::can_instance);
	ClassDB::bind_method(D_METHOD("instance_begin"), &PackedScene::instance_begin); // INSTANCE-STEPS-PATCH
''')
    return s


def packed_scene_h(s):
    s = once(s, '''	bool can_instance() const;
	Node *instance(GenEditState p_edit_state) const;
''', '''	bool can_instance() const;
	Node *instance(GenEditState p_edit_state) const;

	// INSTANCE-STEPS-PATCH: instance() in a resumable per-node part and the rest
	struct InstanceProgress {
		Vector<Node *> nodes;
		int next = 0;
		Map<Ref<Resource>, Ref<Resource>> local;
		List<Node *> stray;
		GenEditState edit = GEN_EDIT_STATE_DISABLED;
	};
	int _instance_step(InstanceProgress &p, uint64_t p_budget_usec) const; // 1 done, 0 more to do, -1 failed
	Node *_instance_finish(InstanceProgress &p) const;
	int get_instance_node_count() const;
''')
    s = once(s, '''class PackedScene : public Resource {''', '''class PackedSceneStepper;

class PackedScene : public Resource {''')
    s = once(s, '''	Node *instance(GenEditState p_edit_state = GEN_EDIT_STATE_DISABLED) const;
''', '''	Node *instance(GenEditState p_edit_state = GEN_EDIT_STATE_DISABLED) const;
	Ref<PackedSceneStepper> instance_begin() const; // INSTANCE-STEPS-PATCH
''')
    s = once(s, '''VARIANT_ENUM_CAST(PackedScene::GenEditState)
''', '''VARIANT_ENUM_CAST(PackedScene::GenEditState)

// INSTANCE-STEPS-PATCH: PackedScene.instance() spread over calls with a time budget
class PackedSceneStepper : public Reference {
	GDCLASS(PackedSceneStepper, Reference);
	friend class PackedScene;

	Ref<PackedScene> scene;
	SceneState::InstanceProgress progress;
	Node *result = nullptr;
	bool done = false;
	bool failed = false;
	void _free_partial();

protected:
	static void _bind_methods();

public:
	bool step(int p_budget_usec);
	Node *get_node();
	float get_progress();
	~PackedSceneStepper();
};
''')
    return s


def register(s):
    return once(s, '''	ClassDB::register_class<PackedScene>();
''', '''	ClassDB::register_class<PackedScene>();
	ClassDB::register_class<PackedSceneStepper>(); // INSTANCE-STEPS-PATCH
''')


edit('scene/resources/packed_scene.h', packed_scene_h)
edit('scene/resources/packed_scene.cpp', packed_scene_cpp)
edit('scene/register_scene_types.cpp', register)
