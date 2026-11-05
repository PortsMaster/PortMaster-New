#!/usr/bin/env python3
"""GLES3 fixes for handhelds (port patch):
- mesh readback: on GLES (not desktop GL) mesh_surface_get_array / _get_index_array map the GPU buffer
  for reading, which the Mali blob refuses (glMapBufferRange returns null: "Parameter data is null",
  scripts get empty arrays). Keep CPU copies of the vertex/index data (a few MB in Cassette Beasts)
  and return those; mesh_surface_update_region keeps the copy in sync.
- render target allocation failures report status, size and flags on stderr (games may turn stdout off).
usage: apply_mesh_copy.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'MESH-COPY-PATCH' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, (old[:70], s.count(old))
    return s.replace(old, new)


def storage_h(s):
    return once(s, '''		int array_byte_size;
		int index_array_byte_size;
''', '''		int array_byte_size;
		int index_array_byte_size;
		PoolVector<uint8_t> cpu_array, cpu_index_array; // MESH-COPY-PATCH: GLES cannot map buffers for reading on Mali
''')


def storage_cpp(s):
    s = once(s, '''	surface->array_byte_size = array.size();
	surface->index_array_byte_size = p_index_array.size();
''', '''	surface->array_byte_size = array.size();
	surface->index_array_byte_size = p_index_array.size();
#if !defined(GLES_OVER_GL) && !defined(__EMSCRIPTEN__)
	surface->cpu_array = array; // MESH-COPY-PATCH
	surface->cpu_index_array = p_index_array;
#endif
''')
    # vertex readback
    s = once(s, '''	PoolVector<uint8_t> ret;
	ret.resize(surface->array_byte_size);
	glBindBuffer(GL_ARRAY_BUFFER, surface->vertex_id);
''', '''#if !defined(GLES_OVER_GL) && !defined(__EMSCRIPTEN__)
	if (surface->cpu_array.size() == surface->array_byte_size) { // MESH-COPY-PATCH
		return surface->cpu_array;
	}
#endif
	PoolVector<uint8_t> ret;
	ret.resize(surface->array_byte_size);
	glBindBuffer(GL_ARRAY_BUFFER, surface->vertex_id);
''')
    # index readback
    s = once(s, '''	PoolVector<uint8_t> ret;
	ret.resize(surface->index_array_byte_size);

	if (surface->index_array_byte_size > 0) {''', '''#if !defined(GLES_OVER_GL) && !defined(__EMSCRIPTEN__)
	if (surface->cpu_index_array.size() == surface->index_array_byte_size) { // MESH-COPY-PATCH
		return surface->cpu_index_array;
	}
#endif
	PoolVector<uint8_t> ret;
	ret.resize(surface->index_array_byte_size);

	if (surface->index_array_byte_size > 0) {''')
    # region update keeps the copy in sync
    s = once(s, '''	glBindBuffer(GL_ARRAY_BUFFER, mesh->surfaces[p_surface]->vertex_id);
	glBufferSubData(GL_ARRAY_BUFFER, p_offset, total_size, r.ptr());
	glBindBuffer(GL_ARRAY_BUFFER, 0); //unbind
}''', '''	glBindBuffer(GL_ARRAY_BUFFER, mesh->surfaces[p_surface]->vertex_id);
	glBufferSubData(GL_ARRAY_BUFFER, p_offset, total_size, r.ptr());
	glBindBuffer(GL_ARRAY_BUFFER, 0); //unbind

	PoolVector<uint8_t> &copy = mesh->surfaces[p_surface]->cpu_array; // MESH-COPY-PATCH
	if (copy.size() == mesh->surfaces[p_surface]->array_byte_size) {
		PoolVector<uint8_t>::Write w = copy.write();
		memcpy(w.ptr() + p_offset, r.ptr(), total_size);
	}
}''')
    # render target failures: details on stderr
    old = '''		if (status != GL_FRAMEBUFFER_COMPLETE) {
			printf("framebuffer fail, status: %x\\n", status);
		}

		ERR_FAIL_COND(status != GL_FRAMEBUFFER_COMPLETE);

		Texture *tex = texture_owner.get(rt->texture);'''
    new = '''		if (status != GL_FRAMEBUFFER_COMPLETE) { // MESH-COPY-PATCH: details on stderr
			fprintf(stderr, "framebuffer fail, status: %x, render target %dx%d color fmt %x, flags hdr %d transparent %d no3d %d noeffects %d nosampling %d msaa %d\\n",
					status, rt->width, rt->height, color_internal_format, rt->flags[RENDER_TARGET_HDR], rt->flags[RENDER_TARGET_TRANSPARENT],
					rt->flags[RENDER_TARGET_NO_3D], rt->flags[RENDER_TARGET_NO_3D_EFFECTS], rt->flags[RENDER_TARGET_NO_SAMPLING], int(rt->msaa));
		}

		ERR_FAIL_COND(status != GL_FRAMEBUFFER_COMPLETE);

		Texture *tex = texture_owner.get(rt->texture);'''
    s = once(s, old, new)
    return s


edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
