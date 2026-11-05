#!/usr/bin/env python3
"""3D render scale (port patch): with rendering/quality/3d_render_scale < 1 the viewport shown on screen
renders its 3D camera into a smaller companion render target and blits it up (linear, or nearest with
rendering/quality/3d_render_scale_nearest), then draws the 2D canvas at full resolution on top: GPU-bound
3D games get the frame rate of a lower resolution while their UI text stays sharp. GLES3 only (other
renderers keep the normal path).
usage: apply_render_scale.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'RENDER-SCALE-PATCH' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, (old[:70], s.count(old))
    return s.replace(old, new)


def rasterizer_h(s):
    return once(s, '''	virtual void render_target_set_flag(RID p_render_target, RenderTargetFlags p_flag, bool p_value) = 0;
''', '''	virtual void render_target_set_flag(RID p_render_target, RenderTargetFlags p_flag, bool p_value) = 0;
	// RENDER-SCALE-PATCH: companion render target for the 3D pass at p_scale of the size (RID() = unsupported)
	virtual RID render_target_get_scaled_3d(RID p_render_target, float p_scale) { return RID(); }
	virtual void render_target_blit_from(RID p_dst, RID p_src, bool p_nearest) {}
''')


def storage_h(s):
    s = once(s, '''		RID texture;

		RenderTarget() :''', '''		RID texture;
		RID scaled_3d; // RENDER-SCALE-PATCH

		RenderTarget() :''')
    s = once(s, '''	virtual void render_target_set_flag(RID p_render_target, RenderTargetFlags p_flag, bool p_value);
''', '''	virtual void render_target_set_flag(RID p_render_target, RenderTargetFlags p_flag, bool p_value);
	virtual RID render_target_get_scaled_3d(RID p_render_target, float p_scale); // RENDER-SCALE-PATCH
	virtual void render_target_blit_from(RID p_dst, RID p_src, bool p_nearest);
''')
    return s


FUNCS = '''
// RENDER-SCALE-PATCH: see servers/visual/visual_server_viewport.cpp (_draw_3d)
RID RasterizerStorageGLES3::render_target_get_scaled_3d(RID p_render_target, float p_scale) {
	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND_V(!rt, RID());
	if (rt->width <= 0 || rt->height <= 0) {
		return RID();
	}
	int w = MAX(1, int(rt->width * p_scale));
	int h = MAX(1, int(rt->height * p_scale));
	if (!rt->scaled_3d.is_valid()) {
		rt->scaled_3d = render_target_create();
	}
	RenderTarget *s = render_target_owner.getornull(rt->scaled_3d);
	ERR_FAIL_COND_V(!s, RID());
	for (int i = 0; i < RENDER_TARGET_FLAG_MAX; i++) {
		if (i != RENDER_TARGET_DIRECT_TO_SCREEN && s->flags[i] != rt->flags[i]) {
			render_target_set_flag(rt->scaled_3d, RenderTargetFlags(i), rt->flags[i]);
		}
	}
	if (s->msaa != rt->msaa) {
		render_target_set_msaa(rt->scaled_3d, rt->msaa);
	}
	if (s->width != w || s->height != h) {
		render_target_set_size(rt->scaled_3d, w, h);
	}
	return rt->scaled_3d;
}

void RasterizerStorageGLES3::render_target_blit_from(RID p_dst, RID p_src, bool p_nearest) {
	RenderTarget *d = render_target_owner.getornull(p_dst);
	RenderTarget *s = render_target_owner.getornull(p_src);
	ERR_FAIL_COND(!d || !s);
	glBindFramebuffer(GL_READ_FRAMEBUFFER, s->fbo);
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, d->fbo);
	glBlitFramebuffer(0, 0, s->width, s->height, 0, 0, d->width, d->height, GL_COLOR_BUFFER_BIT, p_nearest ? GL_NEAREST : GL_LINEAR);
	glBindFramebuffer(GL_FRAMEBUFFER, d->fbo);
}

RID RasterizerStorageGLES3::render_target_create() {'''


def storage_cpp(s):
    s = once(s, '\nRID RasterizerStorageGLES3::render_target_create() {', FUNCS)
    s = once(s, '''		RenderTarget *rt = render_target_owner.getornull(p_rid);
		_render_target_clear(rt);''', '''		RenderTarget *rt = render_target_owner.getornull(p_rid);
		if (rt->scaled_3d.is_valid()) { // RENDER-SCALE-PATCH
			free(rt->scaled_3d);
			rt->scaled_3d = RID();
		}
		_render_target_clear(rt);''')
    return s


def viewport_cpp(s):
    s = once(s, '''	} else {
		VSG::scene->render_camera(p_viewport->camera, p_viewport->scenario, p_viewport->size, p_viewport->shadow_atlas);
	}
}''', '''	} else {
		// RENDER-SCALE-PATCH: 3D of the on-screen viewport at a reduced size, UI at full size
		static const float render_scale = CLAMP(float(GLOBAL_DEF("rendering/quality/3d_render_scale", 1.0)), 0.25f, 1.0f);
		static const bool render_scale_nearest = GLOBAL_DEF("rendering/quality/3d_render_scale_nearest", false);
		if (render_scale < 0.999f && p_viewport->viewport_to_screen_rect != Rect2()) {
			RID srt = VSG::storage->render_target_get_scaled_3d(p_viewport->render_target, render_scale);
			if (srt.is_valid()) {
				Size2i ss(MAX(1, int(p_viewport->size.x * render_scale)), MAX(1, int(p_viewport->size.y * render_scale)));
				VSG::rasterizer->set_current_render_target(srt);
				VSG::scene->render_camera(p_viewport->camera, p_viewport->scenario, ss, p_viewport->shadow_atlas);
				VSG::rasterizer->set_current_render_target(p_viewport->render_target);
				VSG::storage->render_target_blit_from(p_viewport->render_target, srt, render_scale_nearest);
				return;
			}
		}
		VSG::scene->render_camera(p_viewport->camera, p_viewport->scenario, p_viewport->size, p_viewport->shadow_atlas);
	}
}''')
    if '#include "core/project_settings.h"' not in s:
        s = once(s, '#include "visual_server_viewport.h"\n', '#include "visual_server_viewport.h"\n#include "core/project_settings.h"\n')
    return s


edit('servers/visual/rasterizer.h', rasterizer_h)
edit('drivers/gles3/rasterizer_storage_gles3.h', storage_h)
edit('drivers/gles3/rasterizer_storage_gles3.cpp', storage_cpp)
edit('servers/visual/visual_server_viewport.cpp', viewport_cpp)
