#!/usr/bin/env python3
"""Apply the lazy texture upload patch to a Godot 3.5.2 tree (idempotent: skips files already patched).
usage: apply_lazy.py <godot dir>
"""
import re, sys, os

G = sys.argv[1]
MARK = 'lazy_texture'


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'LAZY-PATCH' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, (old, s.count(old))
    return s.replace(old, new)


# ---------------------------------------------------------------- storage header
def storage_h(s):
    s = once(s, '''		VisualServer::TextureDetectCallback detect_normal;
		void *detect_normal_ud;
''', '''		VisualServer::TextureDetectCallback detect_normal;
		void *detect_normal_ud;

		// LAZY-PATCH: lazy upload (servers/visual/lazy_texture.h)
		RID self;
		String lazy_source; // .stex file to decode on first bind; empty = normal texture
		int lazy_custom_width, lazy_custom_height;
		bool lazy_pending; // no GPU copy yet (or evicted)
		uint64_t lazy_last_used; // msec
''')
    s = once(s, '''				detect_normal(nullptr),
				detect_normal_ud(nullptr) {
		}''', '''				detect_normal(nullptr),
				detect_normal_ud(nullptr),
				lazy_custom_width(0),
				lazy_custom_height(0),
				lazy_pending(false),
				lazy_last_used(0) {
		}''')
    s = once(s, '''	mutable RID_Owner<Texture> texture_owner;
''', '''	mutable RID_Owner<Texture> texture_owner;

	// LAZY-PATCH: lazy texture upload, see servers/visual/lazy_texture.h
	struct LazyState {
		bool enabled = false;
		bool print_stats = false;
		uint64_t evict_msec = 0;
		uint64_t now = 0;
		uint64_t last_evict_check = 0;
		uint64_t last_stats = 0;
		Set<RID> resident;
		int uploads = 0;
		int evictions = 0;
		int failed = 0;
	} lazy;
	static RasterizerStorageGLES3 *lazy_singleton;
	static void _lazy_set_source(RID p_texture, const String &p_path, int p_custom_width, int p_custom_height);
	void _texture_lazy_drop(Texture *p_texture);
	void _texture_lazy_realize(Texture *p_texture);
	void _texture_lazy_update();
	// Call before binding a texture for drawing: uploads a lazy texture on first use.
	_FORCE_INLINE_ void texture_lazy_touch(Texture *p_texture) {
		if (!p_texture) {
			return;
		}
		Texture *t = p_texture->proxy ? p_texture->proxy : p_texture;
		if (t->lazy_source.empty()) {
			return;
		}
		t->lazy_last_used = lazy.now;
		if (t->lazy_pending) {
			_texture_lazy_realize(t);
		}
	}
''')
    return s


# ---------------------------------------------------------------- storage cpp
LAZY_FUNCS = r'''
// LAZY-PATCH: lazy texture upload (servers/visual/lazy_texture.h)

RasterizerStorageGLES3 *RasterizerStorageGLES3::lazy_singleton = nullptr;

void RasterizerStorageGLES3::_lazy_set_source(RID p_texture, const String &p_path, int p_custom_width, int p_custom_height) {
	RasterizerStorageGLES3 *s = lazy_singleton;
	ERR_FAIL_COND(!s);
	Texture *t = s->texture_owner.getornull(p_texture);
	ERR_FAIL_COND(!t);
	s->_texture_lazy_drop(t);
	t->self = p_texture;
	t->lazy_source = p_path;
	t->lazy_custom_width = p_custom_width;
	t->lazy_custom_height = p_custom_height;
	t->lazy_pending = true;
}

// Frees the GPU copy (the texture object keeps its metadata and stays usable).
void RasterizerStorageGLES3::_texture_lazy_drop(Texture *t) {
	if (t->total_data_size) {
		glDeleteTextures(1, &t->tex_id);
		glGenTextures(1, &t->tex_id);
		info.texture_mem -= t->total_data_size;
		t->total_data_size = 0;
		t->data_size = 0;
	}
	lazy.resident.erase(t->self);
	t->lazy_pending = true;
}

void RasterizerStorageGLES3::_texture_lazy_realize(Texture *t) {
	t->lazy_pending = false; // also on failure: do not retry every frame
	Ref<Image> img;
	if (!LazyTexture::load || LazyTexture::load(t->lazy_source, img) != OK || img.is_null() || img->empty()) {
		lazy.failed++;
		ERR_PRINT("Lazy texture: cannot load " + t->lazy_source);
		return;
	}
	// may be called in the middle of binding textures: keep the active unit and unit 0 as they were
	GLint active_unit = GL_TEXTURE0;
	GLint bound = 0;
	glGetIntegerv(GL_ACTIVE_TEXTURE, &active_unit);
	glActiveTexture(GL_TEXTURE0);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &bound);
	texture_allocate(t->self, img->get_width(), img->get_height(), 0, img->get_format(), VS::TEXTURE_TYPE_2D, t->flags);
	texture_set_data(t->self, img);
	if (t->lazy_custom_width || t->lazy_custom_height) {
		texture_set_size_override(t->self, t->lazy_custom_width, t->lazy_custom_height, 0);
	}
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, bound);
	glActiveTexture(active_unit);
	lazy.resident.insert(t->self);
	lazy.uploads++;
}

// Once per frame: clock for texture_lazy_touch, eviction of textures not drawn for evict_msec.
void RasterizerStorageGLES3::_texture_lazy_update() {
	if (!lazy.enabled) {
		return;
	}
	lazy.now = OS::get_singleton()->get_ticks_msec();
	if (lazy.evict_msec && lazy.now - lazy.last_evict_check >= 1000) {
		lazy.last_evict_check = lazy.now;
		Set<RID>::Element *E = lazy.resident.front();
		while (E) {
			Set<RID>::Element *N = E->next();
			Texture *t = texture_owner.getornull(E->get());
			if (!t) {
				lazy.resident.erase(E);
			} else if (!t->lazy_pending && lazy.now - t->lazy_last_used > lazy.evict_msec) {
				_texture_lazy_drop(t);
				lazy.evictions++;
			}
			E = N;
		}
	}
	if (lazy.print_stats && lazy.now - lazy.last_stats >= 10000) {
		lazy.last_stats = lazy.now;
		// stderr: games may disable stdout (application/run/disable_stdout)
		fprintf(stderr, "Lazy textures: %d resident, texture memory %d MB, %d uploads, %d evictions, %d failed\n",
				lazy.resident.size(), int(info.texture_mem >> 20), lazy.uploads, lazy.evictions, lazy.failed);
	}
}
'''


def storage_cpp(s):
    s = once(s, '#include "servers/visual_server.h"\n', '#include "servers/visual/lazy_texture.h"\n#include "servers/visual_server.h"\n')
    # functions before texture_create
    s = once(s, '\nRID RasterizerStorageGLES3::texture_create() {', LAZY_FUNCS + '\nRID RasterizerStorageGLES3::texture_create() {')
    # texture_bind
    s = once(s, '''	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND(!texture);

	glActiveTexture(GL_TEXTURE0 + p_texture_no);''', '''	Texture *texture = texture_owner.getornull(p_texture);

	ERR_FAIL_COND(!texture);
	texture_lazy_touch(texture);

	glActiveTexture(GL_TEXTURE0 + p_texture_no);''')
    # sky panorama
    s = once(s, '''	Texture *texture = texture_owner.getornull(sky->panorama);
	if (!texture) {''', '''	Texture *texture = texture_owner.getornull(sky->panorama);
	texture_lazy_touch(texture);
	if (!texture) {''')
    # particles material textures
    s = once(s, '''				RasterizerStorageGLES3::Texture *t = texture_owner.getornull(textures[i]);

				if (!t) {
					//check hints''', '''				RasterizerStorageGLES3::Texture *t = texture_owner.getornull(textures[i]);
				texture_lazy_touch(t);

				if (!t) {
					//check hints''')
    # texture_get_data / texture_set_data_partial: need the data
    m = re.search(r'Ref<Image> RasterizerStorageGLES3::texture_get_data\(RID p_texture, int p_layer\) const \{\n(\tTexture \*texture = texture_owner\.get\(p_texture\);\n)', s)
    assert m
    s = s[:m.end()] + '\tconst_cast<RasterizerStorageGLES3 *>(this)->texture_lazy_touch(texture);\n' + s[m.end():]
    m = re.search(r'void RasterizerStorageGLES3::texture_set_data_partial\([^)]*\) \{\n(\tTexture \*texture = texture_owner\.get\(p_texture\);\n)', s)
    assert m
    s = s[:m.end()] + '\ttexture_lazy_touch(texture);\n' + s[m.end():]
    # free: forget the RID
    s = once(s, '''	} else if (texture_owner.owns(p_rid)) {
''', '''	} else if (texture_owner.owns(p_rid)) {
		lazy.resident.erase(p_rid);
''')
    # settings
    s = once(s, 'void RasterizerStorageGLES3::initialize() {\n', '''void RasterizerStorageGLES3::initialize() {
	lazy.enabled = GLOBAL_DEF("rendering/lazy_textures/enabled", false);
	lazy.evict_msec = uint64_t(MAX(0, int(GLOBAL_DEF("rendering/lazy_textures/evict_after_seconds", 30)))) * 1000;
	lazy.print_stats = GLOBAL_DEF("rendering/lazy_textures/print_stats", false);
	lazy_singleton = this;
	LazyTexture::set_source = lazy.enabled ? _lazy_set_source : nullptr;

''')
    s = once(s, 'void RasterizerStorageGLES3::update_dirty_resources() {\n', 'void RasterizerStorageGLES3::update_dirty_resources() {\n\t_texture_lazy_update();\n')
    return s


# ---------------------------------------------------------------- bind sites in canvas/scene
def canvas_base(s):
    s = once(s, '''		RasterizerStorageGLES3::Texture *texture = storage->texture_owner.getornull(p_texture);

		if (!texture) {
			state.current_tex = RID();''', '''		RasterizerStorageGLES3::Texture *texture = storage->texture_owner.getornull(p_texture);
		storage->texture_lazy_touch(texture); // LAZY-PATCH

		if (!texture) {
			state.current_tex = RID();''')
    s = once(s, '''		RasterizerStorageGLES3::Texture *normal_map = storage->texture_owner.getornull(p_normal_map);
''', '''		RasterizerStorageGLES3::Texture *normal_map = storage->texture_owner.getornull(p_normal_map);
		storage->texture_lazy_touch(normal_map); // LAZY-PATCH
''')
    return s


def canvas(s):
    old = '''				RasterizerStorageGLES3::Texture *t = storage->texture_owner.getornull(textures[i]);
				if (!t) {'''
    assert s.count(old) == 2
    s = s.replace(old, '''				RasterizerStorageGLES3::Texture *t = storage->texture_owner.getornull(textures[i]);
				storage->texture_lazy_touch(t); // LAZY-PATCH
				if (!t) {''')
    old = '''				RasterizerStorageGLES3::Texture *t = storage->texture_owner.getornull(light->texture);
'''
    assert s.count(old) == 2
    s = s.replace(old, old + '				storage->texture_lazy_touch(t); // LAZY-PATCH\n')
    return s


def scene(s):
    s = once(s, '''		RasterizerStorageGLES3::Texture *t = storage->texture_owner.getptr(textures[i]);
''', '''		RasterizerStorageGLES3::Texture *t = storage->texture_owner.getptr(textures[i]);
		storage->texture_lazy_touch(t); // LAZY-PATCH
''')
    s = once(s, '''		RasterizerStorageGLES3::Texture *lightmap = storage->texture_owner.getornull(e->instance->lightmap);
''', '''		RasterizerStorageGLES3::Texture *lightmap = storage->texture_owner.getornull(e->instance->lightmap);
		storage->texture_lazy_touch(lightmap); // LAZY-PATCH
''')
    s = once(s, '''	RasterizerStorageGLES3::Texture *tex = storage->texture_owner.getornull(p_sky->panorama);
''', '''	RasterizerStorageGLES3::Texture *tex = storage->texture_owner.getornull(p_sky->panorama);
	storage->texture_lazy_touch(tex); // LAZY-PATCH
''')
    s = once(s, '''		RasterizerStorageGLES3::Texture *tex = storage->texture_owner.getornull(env->color_correction);
''', '''		RasterizerStorageGLES3::Texture *tex = storage->texture_owner.getornull(env->color_correction);
		storage->texture_lazy_touch(tex); // LAZY-PATCH
''')
    return s


# ---------------------------------------------------------------- StreamTexture
def texture_cpp(s):
    s = once(s, '#include "core/os/os.h"\n', '#include "core/os/os.h"\n#include "servers/visual/lazy_texture.h"\n')
    s = once(s, '''Error StreamTexture::load(const String &p_path) {
	int lw, lh, lwc, lhc, lflags;
''', '''static StreamTexture *lazy_texture_loader = nullptr; // LAZY-PATCH

Error StreamTexture::load(const String &p_path) {
	// LAZY-PATCH: with rendering/lazy_textures/enabled the renderer sets LazyTexture::set_source; then
	// only the header is read here and the renderer decodes the file on first draw.
	if (LazyTexture::set_source) {
		if (!LazyTexture::load) {
			lazy_texture_loader = memnew(StreamTexture); // only used to decode, never freed
			// a lambda in a member function may call the private _load_data
			LazyTexture::load = [](const String &p_file, Ref<Image> &r_image) -> Error {
				int tw, th, twc, thc, tflags;
				r_image.instance();
				return lazy_texture_loader->_load_data(p_file, tw, th, twc, thc, tflags, r_image);
			};
		}
		FileAccess *f = FileAccess::open(p_path, FileAccess::READ);
		ERR_FAIL_COND_V_MSG(!f, ERR_CANT_OPEN, vformat("Unable to open file: %s.", p_path));
		uint8_t header[4];
		f->get_buffer(header, 4);
		int lw = f->get_16();
		int lwc = f->get_16();
		int lh = f->get_16();
		int lhc = f->get_16();
		int lflags = f->get_32();
		uint32_t df = f->get_32();
		memdelete(f);
		ERR_FAIL_COND_V(header[0] != 'G' || header[1] != 'D' || header[2] != 'S' || header[3] != 'T', ERR_FILE_CORRUPT);
		Image::Format lformat = (df & (FORMAT_BIT_PNG | FORMAT_BIT_WEBP)) ? Image::FORMAT_RGBA8 : Image::Format(df & FORMAT_MASK_IMAGE_FORMAT);

		alpha_cache.unref();
		if (get_path() == String()) {
			VisualServer::get_singleton()->texture_set_path(texture, p_path);
		}
		VS::get_singleton()->texture_allocate(texture, lw, lh, 0, lformat, VS::TEXTURE_TYPE_2D, lflags);
		if (lwc || lhc) {
			VS::get_singleton()->texture_set_size_override(texture, lwc, lhc, 0);
		}
		LazyTexture::set_source(texture, p_path, lwc, lhc);
		w = lwc ? lwc : lw;
		h = lhc ? lhc : lh;
		flags = lflags;
		path_to_file = p_path;
		format = lformat;
		_change_notify();
		emit_changed();
		return OK;
	}

	int lw, lh, lwc, lhc, lflags;
''')
    return s


edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
edit('drivers/gles3/rasterizer_canvas_base_gles3.cpp', canvas_base)
edit('drivers/gles3/rasterizer_canvas_gles3.cpp', canvas)
edit('drivers/gles3/rasterizer_scene_gles3.cpp', scene)
edit('scene/resources/texture.cpp', texture_cpp)
