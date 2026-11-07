#!/usr/bin/env python3
"""Godot 3.5 GLES3 port patch: letterbox the 3D of the on-screen viewport to a reference aspect.

rendering/camera/letterbox_aspect (float, default 0 = off). When > 0 and the viewport attached to the screen is
narrower than that (Cassette Beasts on the 720x720 RG Cube XX: 1:1 < 16:9), its 3D renders into a companion
target of that aspect (times rendering/quality/3d_render_scale) and is blitted into a centred band; the bars are
cleared to black and the 2D canvas is drawn over the whole screen as before. The camera sees exactly what it
sees on a 16:9 screen (nothing cut off at the sides, nothing extra above/below, fewer pixels). The scene-side
Camera projection functions (unproject_position, project_position, project_ray_*, get_frustum,
get_near_plane_points) use the same band, so 2D markers the game places over 3D line up.
Needs apply_render_scale.py, apply_viewport_cap.py and apply_camera_fit.py first.

usage: apply_letterbox.py <godot dir>   (idempotent)
"""
import sys
from pathlib import Path

godot = Path(sys.argv[1])
MARK = "LETTERBOX-PATCH"


def once(s, old, new, count=1):
    assert s.count(old) == count, (s.count(old), old[:80])
    return s.replace(old, new)


def edit(rel, fn):
    p = godot / rel
    s = p.read_text()
    if MARK in s:
        print("already patched:", rel)
        return
    p.write_text(fn(s), newline="\n")
    print("patched:", rel)


def rasterizer_h(s):
    return once(s, """	virtual void render_target_blit_from(RID p_dst, RID p_src, bool p_nearest) {}
""", """	virtual void render_target_blit_from(RID p_dst, RID p_src, bool p_nearest) {}
	// %s: companion of a given size; blit into a rectangle of the destination, the rest cleared to black
	virtual RID render_target_get_scaled_3d_size(RID p_render_target, int p_width, int p_height) { return RID(); }
	virtual void render_target_blit_from_rect(RID p_dst, RID p_src, int p_x, int p_y, int p_width, int p_height, bool p_nearest) {}
""" % MARK)


def storage_h(s):
    return once(s, """	virtual void render_target_blit_from(RID p_dst, RID p_src, bool p_nearest);
""", """	virtual void render_target_blit_from(RID p_dst, RID p_src, bool p_nearest);
	virtual RID render_target_get_scaled_3d_size(RID p_render_target, int p_width, int p_height); // %s
	virtual void render_target_blit_from_rect(RID p_dst, RID p_src, int p_x, int p_y, int p_width, int p_height, bool p_nearest);
""" % MARK)


def storage_cpp(s):
    s = once(s, """	int w = MAX(1, int(rt->width * p_scale));
	int h = MAX(1, int(rt->height * p_scale));
	if (!rt->scaled_3d.is_valid()) {""", """	return render_target_get_scaled_3d_size(p_render_target, MAX(1, int(rt->width * p_scale)), MAX(1, int(rt->height * p_scale)));
}

// %s: the companion at an explicit size (any aspect)
RID RasterizerStorageGLES3::render_target_get_scaled_3d_size(RID p_render_target, int p_width, int p_height) {
	RenderTarget *rt = render_target_owner.getornull(p_render_target);
	ERR_FAIL_COND_V(!rt, RID());
	if (rt->width <= 0 || rt->height <= 0) {
		return RID();
	}
	int w = MAX(1, p_width);
	int h = MAX(1, p_height);
	if (!rt->scaled_3d.is_valid()) {""" % MARK)
    s = once(s, """	glBlitFramebuffer(0, 0, s->width, s->height, 0, 0, d->width, d->height, GL_COLOR_BUFFER_BIT, p_nearest ? GL_NEAREST : GL_LINEAR);
	glBindFramebuffer(GL_FRAMEBUFFER, d->fbo);
}
""", """	glBlitFramebuffer(0, 0, s->width, s->height, 0, 0, d->width, d->height, GL_COLOR_BUFFER_BIT, p_nearest ? GL_NEAREST : GL_LINEAR);
	glBindFramebuffer(GL_FRAMEBUFFER, d->fbo);
}

// %s: blit into a rectangle (GL coordinates, origin bottom left) of the destination, clear the rest to black
void RasterizerStorageGLES3::render_target_blit_from_rect(RID p_dst, RID p_src, int p_x, int p_y, int p_width, int p_height, bool p_nearest) {
	RenderTarget *d = render_target_owner.getornull(p_dst);
	RenderTarget *s = render_target_owner.getornull(p_src);
	ERR_FAIL_COND(!d || !s);
	glBindFramebuffer(GL_FRAMEBUFFER, d->fbo);
	glDisable(GL_SCISSOR_TEST);
	glColorMask(1, 1, 1, 1);
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	glBindFramebuffer(GL_READ_FRAMEBUFFER, s->fbo);
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, d->fbo);
	glBlitFramebuffer(0, 0, s->width, s->height, p_x, p_y, p_x + p_width, p_y + p_height, GL_COLOR_BUFFER_BIT, p_nearest ? GL_NEAREST : GL_LINEAR);
	glBindFramebuffer(GL_FRAMEBUFFER, d->fbo);
}
""" % MARK)
    return s


def viewport_cpp(s):
    s = once(s, """		if (scale < 0.999f && !_viewport_cap_canvas_bg(p_viewport)) {
			RID srt = VSG::storage->render_target_get_scaled_3d(p_viewport->render_target, scale);
			if (srt.is_valid()) {
				Size2i ss(MAX(1, int(p_viewport->size.x * scale)), MAX(1, int(p_viewport->size.y * scale)));
""", """		// %s: the on-screen viewport narrower than rendering/camera/letterbox_aspect renders its 3D in a
		// centred band of that aspect (the bars black, the canvas over the whole screen)
		static const float lb_aspect = MAX(0.0f, float(GLOBAL_DEF("rendering/camera/letterbox_aspect", 0.0)));
		const bool letterbox = lb_aspect > 0.0f && p_viewport->viewport_to_screen_rect != Rect2() && p_viewport->size.y > 0 &&
				float(p_viewport->size.x) / float(p_viewport->size.y) < lb_aspect - 0.01f;
		const int band_h = letterbox ? MAX(1, int(p_viewport->size.x / lb_aspect + 0.5f)) : p_viewport->size.y;
		if ((scale < 0.999f || letterbox) && !_viewport_cap_canvas_bg(p_viewport)) {
			Size2i ss(MAX(1, int(p_viewport->size.x * scale)), MAX(1, int(band_h * scale)));
			RID srt = VSG::storage->render_target_get_scaled_3d_size(p_viewport->render_target, ss.width, ss.height);
			if (srt.is_valid()) {
""" % MARK)
    s = once(s, """				VSG::rasterizer->set_current_render_target(p_viewport->render_target);
				VSG::storage->render_target_blit_from(p_viewport->render_target, srt, render_scale_nearest);
				return;
""", """				VSG::rasterizer->set_current_render_target(p_viewport->render_target);
				if (letterbox) {
					VSG::storage->render_target_blit_from_rect(p_viewport->render_target, srt, 0, (p_viewport->size.y - band_h) / 2, p_viewport->size.x, band_h, render_scale_nearest);
				} else {
					VSG::storage->render_target_blit_from(p_viewport->render_target, srt, render_scale_nearest);
				}
				return;
""")
    return s


def camera_cpp(s):
    s = once(s, '#include "core/math/camera_matrix.h"\n', '''#include "core/math/camera_matrix.h"
#include "core/project_settings.h"
''')
    s = once(s, "static real_t _camera_fit_fovy(", """// %s: rendering/camera/letterbox_aspect: the 3D of the on-screen viewport is drawn in a centred band of that
// aspect (VisualServerViewport::_draw_3d); projections of a screen camera use the band's size, positions are offset
static Size2 _camera_letterbox(const Camera *p_camera, const Size2 &p_size, Vector2 *r_offset) {
	static const real_t lb_aspect = ProjectSettings::get_singleton() && ProjectSettings::get_singleton()->has_setting("rendering/camera/letterbox_aspect") ? MAX(real_t(0), real_t(float(GLOBAL_GET("rendering/camera/letterbox_aspect")))) : real_t(0);
	*r_offset = Vector2();
	const Viewport *vp = p_camera->get_viewport();
	if (lb_aspect <= 0 || !vp || vp->get_attach_to_screen_rect() == Rect2() || p_size.y <= 0 || p_size.aspect() >= lb_aspect - 0.01) {
		return p_size;
	}
	Size2 band(p_size.x, p_size.x / lb_aspect);
	r_offset->y = (p_size.y - band.y) * 0.5;
	return band;
}

static real_t _camera_fit_fovy(""" % MARK)
    s = once(s, """	Size2 viewport_size = get_viewport()->get_camera_rect_size();
	Vector2 cpos = get_viewport()->get_camera_coords(p_pos);
""", """	Size2 viewport_size = get_viewport()->get_camera_rect_size();
	Vector2 cpos = get_viewport()->get_camera_coords(p_pos);
	Vector2 lb_ofs; // LETTERBOX-PATCH
	viewport_size = _camera_letterbox(this, viewport_size, &lb_ofs);
	cpos -= lb_ofs;
""", count=2)
    s = once(s, """	Size2 viewport_size = get_viewport()->get_visible_rect().size;
""", """	Size2 viewport_size = get_viewport()->get_visible_rect().size;
	Vector2 lb_ofs; // LETTERBOX-PATCH
	viewport_size = _camera_letterbox(this, viewport_size, &lb_ofs);
""", count=4)
    s = once(s, """	res.y = (-p.normal.y * 0.5 + 0.5) * viewport_size.y;
""", """	res.y = (-p.normal.y * 0.5 + 0.5) * viewport_size.y;
	res += lb_ofs; // LETTERBOX-PATCH
""")
    s = once(s, """	point.x = (p_point.x / viewport_size.x) * 2.0 - 1.0;
	point.y = (1.0 - (p_point.y / viewport_size.y)) * 2.0 - 1.0;
""", """	point.x = ((p_point.x - lb_ofs.x) / viewport_size.x) * 2.0 - 1.0; // LETTERBOX-PATCH
	point.y = (1.0 - ((p_point.y - lb_ofs.y) / viewport_size.y)) * 2.0 - 1.0;
""")
    return s


edit("servers/visual/rasterizer.h", rasterizer_h)
edit("drivers/gles3/rasterizer_storage_gles3.h", storage_h)
edit("drivers/gles3/rasterizer_storage_gles3.cpp", storage_cpp)
edit("servers/visual/visual_server_viewport.cpp", viewport_cpp)
edit("scene/3d/camera.cpp", camera_cpp)
