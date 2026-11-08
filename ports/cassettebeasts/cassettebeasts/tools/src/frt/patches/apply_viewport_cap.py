#!/usr/bin/env python3
"""3D pixel cap for every viewport (port patch): rendering/viewports/max_3d_pixels (int, 0 = off).

apply_render_scale.py gives the viewport drawn to screen a smaller companion render target for its 3D pass
(rendering/quality/3d_render_scale) and leaves off-screen viewports alone. Cassette Beasts renders the
archangel battles into own-world 3D Viewports of 800x800 up to 1500x1250 that the game reads back as
ViewportTexture (Sprite3D / TextureRect): on a 720x720 handheld those draw more 3D pixels than the screen.
With max_3d_pixels > 0 every 3D-rendering viewport (3D not disabled, usage 3D or 3D-no-effects) whose
size exceeds the cap renders its camera through the same per-render-target companion (rt->scaled_3d,
created on first use, resized by render_target_get_scaled_3d, freed with the render target when the
viewport is freed) at sqrt(max_3d_pixels / pixels) of its size and blits it up into the viewport's own
render target, so the ViewportTexture the game samples is unchanged in size and the canvas is drawn on top
at full size. The root viewport takes the smaller of 3d_render_scale and the cap scale.
Two guards the render-scale patch lacked, now applied to both paths:
- a scenario whose environment background is ENV_BG_CANVAS makes render_scene copy the canvas drawn so far
  out of the current render target's colour buffer; a companion does not hold it, so such viewports keep the
  full-size path;
- RasterizerGLES3::set_current_render_target drops the pending clear request, so the viewport's clear
  colour is re-requested on the companion (the companion's clear is what the blit brings back).
GLES3 only (render_target_get_scaled_3d returns RID() elsewhere, and the normal path is taken).

usage: apply_viewport_cap.py <godot dir>   (idempotent, after apply_render_scale.py)
"""
import os, sys

G = sys.argv[1]
MARK = 'VIEWPORT-CAP-PATCH'


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


OLD_DRAW_3D = '''		// RENDER-SCALE-PATCH: 3D of the on-screen viewport at a reduced size, UI at full size
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
}
'''

NEW_DRAW_3D = '''		// RENDER-SCALE-PATCH: 3D of the on-screen viewport at a reduced size, UI at full size
		static const float render_scale = CLAMP(float(GLOBAL_DEF("rendering/quality/3d_render_scale", 1.0)), 0.25f, 1.0f);
		static const bool render_scale_nearest = GLOBAL_DEF("rendering/quality/3d_render_scale_nearest", false);
		// VIEWPORT-CAP-PATCH: every 3D viewport (also the off-screen ones games read as ViewportTexture) with
		// more than rendering/viewports/max_3d_pixels pixels renders its 3D through the same companion target at
		// sqrt(max / pixels) of its size; the root viewport takes the smaller of the two scales.
		static const int max_3d_pixels = MAX(0, int(GLOBAL_DEF("rendering/viewports/max_3d_pixels", 0)));
		float scale = p_viewport->viewport_to_screen_rect != Rect2() ? render_scale : 1.0f;
		if (max_3d_pixels > 0) {
			float pixels = float(p_viewport->size.x) * float(p_viewport->size.y);
			if (pixels > float(max_3d_pixels)) {
				scale = MIN(scale, CLAMP(Math::sqrt(float(max_3d_pixels) / pixels), 0.01f, 1.0f));
			}
		}
		if (scale < 0.999f && !_viewport_cap_canvas_bg(p_viewport)) {
			RID srt = VSG::storage->render_target_get_scaled_3d(p_viewport->render_target, scale);
			if (srt.is_valid()) {
				Size2i ss(MAX(1, int(p_viewport->size.x * scale)), MAX(1, int(p_viewport->size.y * scale)));
				VSG::rasterizer->set_current_render_target(srt);
				if (viewport_cap_clear_pending) {
					// the target switch dropped the viewport's clear request: the companion's clear is what the
					// blit below brings back into the viewport
					VSG::rasterizer->clear_render_target(viewport_cap_clear_color);
					viewport_cap_clear_pending = false;
				}
				VSG::scene->render_camera(p_viewport->camera, p_viewport->scenario, ss, p_viewport->shadow_atlas);
				VSG::rasterizer->set_current_render_target(p_viewport->render_target);
				VSG::storage->render_target_blit_from(p_viewport->render_target, srt, render_scale_nearest);
				return;
			}
		}
		VSG::scene->render_camera(p_viewport->camera, p_viewport->scenario, p_viewport->size, p_viewport->shadow_atlas);
	}
}
'''

HELPERS = '''// VIEWPORT-CAP-PATCH: the viewport's clear request of this _draw_viewport pass, re-issued on a companion target
static bool viewport_cap_clear_pending = false;
static Color viewport_cap_clear_color;

// VIEWPORT-CAP-PATCH: with an ENV_BG_CANVAS environment render_scene copies the canvas drawn so far out of the
// current render target's colour buffer as the 3D background; a companion target does not hold it, so such
// viewports keep the full-size path (same test as _draw_viewport's scenario_draw_canvas_bg).
static bool _viewport_cap_canvas_bg(VisualServerViewport::Viewport *p_viewport) {
	if (p_viewport->hide_canvas || p_viewport->disable_environment || !VSG::scene->scenario_owner.owns(p_viewport->scenario)) {
		return false;
	}
	VisualServerScene::Scenario *scenario = VSG::scene->scenario_owner.get(p_viewport->scenario);
	if (!scenario || !VSG::scene_render->is_environment(scenario->environment)) {
		return false;
	}
	return VSG::scene_render->environment_get_background(scenario->environment) == VS::ENV_BG_CANVAS;
}

void VisualServerViewport::_draw_3d(Viewport *p_viewport, ARVRInterface::Eyes p_eye) {
'''


def viewport_cpp(s):
    s = once(s, 'void VisualServerViewport::_draw_3d(Viewport *p_viewport, ARVRInterface::Eyes p_eye) {\n', HELPERS)
    s = once(s, OLD_DRAW_3D, NEW_DRAW_3D)
    s = once(s, '''	if (p_viewport->clear_mode != VS::VIEWPORT_CLEAR_NEVER) {
		VSG::rasterizer->clear_render_target(p_viewport->transparent_bg ? Color(0, 0, 0, 0) : clear_color);
''', '''	viewport_cap_clear_pending = p_viewport->clear_mode != VS::VIEWPORT_CLEAR_NEVER; // VIEWPORT-CAP-PATCH
	viewport_cap_clear_color = p_viewport->transparent_bg ? Color(0, 0, 0, 0) : clear_color;
	if (p_viewport->clear_mode != VS::VIEWPORT_CLEAR_NEVER) {
		VSG::rasterizer->clear_render_target(p_viewport->transparent_bg ? Color(0, 0, 0, 0) : clear_color);
''')
    return s


edit('servers/visual/visual_server_viewport.cpp', viewport_cpp)
