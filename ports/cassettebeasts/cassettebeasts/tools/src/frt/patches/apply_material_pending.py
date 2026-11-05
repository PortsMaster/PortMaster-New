#!/usr/bin/env python3
"""Godot 3.5 port patch: surface materials set before the mesh's surfaces exist are kept, not dropped.

With VisualServerWrapMT, mesh_add_surface calls from a loading thread wait in the command queue while
the main thread already instances the scene (Cassette Beasts with force_synchronous_loading on the
LevelStreamer): MeshInstance::_mesh_changed -> VS::instance_set_surface_material then hits
`ERR_FAIL_INDEX(p_surface, instance->materials.size())` because the server-side mesh still has 0
surfaces, prints "Index p_surface = 0 is out of bounds (instance->materials.size() = 0)" (560 times per
device run) and the material is lost for good: character puppets and props render with the default
material (flat dark silhouettes). Now the materials array grows to hold the entry and
_update_dirty_instance only trims it once the mesh really has surfaces.

usage: apply_material_pending.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "PENDING-MATERIAL-PATCH"


def once(s, old, new):
    assert s.count(old) == 1, old[:60]
    return s.replace(old, new)


p = godot / "servers/visual/visual_server_scene.cpp"
s = p.read_text()
if MARK in s:
    print("already applied:", p)
    sys.exit(0)

s = once(s, """	if (instance->base_type == VS::INSTANCE_MESH) {
		//may not have been updated yet
		instance->materials.resize(VSG::storage->mesh_get_surface_count(instance->base));
	}

	ERR_FAIL_INDEX(p_surface, instance->materials.size());

	if (instance->materials[p_surface].is_valid()) {
		VSG::storage->material_remove_instance_owner(instance->materials[p_surface], instance);
	}
	instance->materials.write[p_surface] = p_material;
	instance->base_changed(false, true);
""", """	if (instance->base_type == VS::INSTANCE_MESH) {
		//may not have been updated yet
		int surface_count = VSG::storage->mesh_get_surface_count(instance->base);
		if (surface_count > instance->materials.size()) {
			instance->materials.resize(surface_count);
		}
	}

	// %s: the mesh's surfaces may still be queued from a loading thread (VisualServerWrapMT);
	// keep the material, _update_dirty_instance trims the array once the surfaces exist
	ERR_FAIL_COND(p_surface < 0 || p_surface >= 256);
	if (p_surface >= instance->materials.size()) {
		instance->materials.resize(p_surface + 1);
	}

	if (instance->materials[p_surface].is_valid()) {
		VSG::storage->material_remove_instance_owner(instance->materials[p_surface], instance);
	}
	instance->materials.write[p_surface] = p_material;
	instance->base_changed(false, true);
""" % MARK)

s = once(s, """			int new_mat_count = VSG::storage->mesh_get_surface_count(p_instance->base);
			for (int i = p_instance->materials.size() - 1; i >= new_mat_count; i--) {
				if (p_instance->materials[i].is_valid()) {
					VSG::storage->material_remove_instance_owner(p_instance->materials[i], p_instance);
				}
			}
			p_instance->materials.resize(new_mat_count);
""", """			int new_mat_count = VSG::storage->mesh_get_surface_count(p_instance->base);
			// %s: a mesh without surfaces yet keeps the materials set for it
			if (new_mat_count > 0 || p_instance->materials.size() == 0) {
				for (int i = p_instance->materials.size() - 1; i >= new_mat_count; i--) {
					if (p_instance->materials[i].is_valid()) {
						VSG::storage->material_remove_instance_owner(p_instance->materials[i], p_instance);
					}
				}
				p_instance->materials.resize(new_mat_count);
			}
""" % MARK)
p.write_text(s)
print("patched:", p)
