#!/usr/bin/env python3
"""Camera fit for narrow screens (port patch): rendering/camera/fit_aspect (float, 0 = off).

Camera.keep_aspect defaults to KEEP_HEIGHT and Cassette Beasts never changes it: every 3D camera keeps its
vertical field of view, so on the 720x720 RG Cube XX only 9/16 of the width a 16:9 screen shows is visible
(battle fighters at the left and right were off-screen). The 2D canvas is fine (stretch aspect expand).
With fit_aspect > 0, a KEEP_HEIGHT camera drawn into the viewport attached to the screen whose aspect
(width / height) is below fit_aspect is widened so its horizontal extent is what it shows at fit_aspect:
  perspective   tan(fovy' / 2) = tan(fovy / 2) * fit_aspect / aspect
  orthogonal    size' = size * fit_aspect / aspect   (frustum mode: the same for its size)
KEEP_WIDTH cameras, viewports at or above fit_aspect and viewports not attached to the screen (own-world
boss viewports, sprite containers, the party menu's orthogonal monster cameras: fixed-size targets the game
frames itself) are untouched.
The same factor is applied wherever Godot 3.5.2 builds a camera projection, so 2D markers placed over 3D stay
on the rendered image:
- server: VisualServerScene::render_camera (the main and the render-scale / viewport-cap companion paths
  both go through it with a size of the same aspect); culling, portals, directional shadow splits
  (built from the widened matrix) and the effects follow from that matrix; a sky's custom FOV
  (Environment.background_sky_custom_fov, 88 in the battle carriages / archangel arenas) is widened by the
  same factor in GLES3 and GLES2 _draw_sky;
- scene: Camera::project_local_ray_normal / project_ray_normal, project_ray_origin, get_near_plane_points
  (ClippedCamera), unproject_position, project_position, get_frustum (VisibilityNotifier, rooms);
  InterpolatedCamera and the game's BlendCamera set Camera.fov and go through these.
"Attached to the screen" is the same test on both sides: VisualServerViewport viewport_to_screen_rect
(set by Viewport::set_attach_to_screen_rect, i.e. the SceneTree root) and Viewport::get_attach_to_screen_rect.
The setting is read once (first projection built) from the project settings / override.cfg:
    [rendering]
    camera/fit_aspect=1.7778

usage: apply_camera_fit.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'CAMERA-FIT-PATCH'


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if MARK in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s and MARK in n, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def times(s, old, new, n):
    assert s.count(old) == n, (old[:70], s.count(old), n)
    return s.replace(old, new)


def once(s, old, new):
    return times(s, old, new, 1)


# --- core: the shared formula ---

def camera_matrix_h(s):
    old = '''	static real_t get_fovy(real_t p_fovx, real_t p_aspect) {
		return Math::rad2deg(Math::atan(p_aspect * Math::tan(Math::deg2rad(p_fovx) * 0.5)) * 2.0);
	}
'''
    return once(s, old, old + '''
	// CAMERA-FIT-PATCH: rendering/camera/fit_aspect (0 = off, read once). For a keep-height projection
	// (p_flip_fov false) into a viewport of aspect p_aspect below fit_aspect: fit_aspect / p_aspect, the factor
	// by which the vertical extent grows so the horizontal extent equals what it shows at fit_aspect; else 1.
	static real_t get_fit_aspect_scale(real_t p_aspect, bool p_flip_fov);
	// vertical FOV whose tan(fov / 2) is p_scale times that of p_fovy_degrees
	static real_t get_fit_fovy(real_t p_fovy_degrees, real_t p_scale);
	// factor of the camera VisualServerScene::render_camera is drawing (render thread only; 1 outside it):
	// the rasterizers widen a sky's custom FOV by it
	static real_t fit_render_scale;
''')


def camera_matrix_cpp(s):
    return once(s, '#include "core/print_string.h"\n', '''#include "core/print_string.h"
#include "core/project_settings.h"

// CAMERA-FIT-PATCH
real_t CameraMatrix::fit_render_scale = 1.0;

static real_t _camera_fit_aspect_setting() {
	ProjectSettings *ps = ProjectSettings::get_singleton();
	if (!ps || !ps->has_setting("rendering/camera/fit_aspect")) {
		return 0;
	}
	real_t fit = real_t(float(GLOBAL_GET("rendering/camera/fit_aspect")));
	return fit > 0 ? fit : 0;
}

real_t CameraMatrix::get_fit_aspect_scale(real_t p_aspect, bool p_flip_fov) {
	static const real_t fit_aspect = _camera_fit_aspect_setting();
	if (p_flip_fov || fit_aspect <= 0 || !(p_aspect > 0) || p_aspect >= fit_aspect) {
		return 1.0;
	}
	return fit_aspect / p_aspect;
}

real_t CameraMatrix::get_fit_fovy(real_t p_fovy_degrees, real_t p_scale) {
	if (p_scale == 1.0) {
		return p_fovy_degrees;
	}
	return Math::rad2deg(Math::atan(Math::tan(Math::deg2rad(p_fovy_degrees) * 0.5) * p_scale) * 2.0);
}
''')


# --- server ---

def vs_scene_h(s):
    old = '	void render_camera(RID p_camera, RID p_scenario, Size2 p_viewport_size, RID p_shadow_atlas);\n'
    return once(s, old, '''	// CAMERA-FIT-PATCH: set by VisualServerViewport::_draw_3d: the viewport drawn is attached to the screen
	bool camera_fit_screen = false;
''' + old)


def vs_scene_cpp(s):
    s = once(s, '''	/* STEP 1 - SETUP CAMERA */
	CameraMatrix camera_matrix;
	bool ortho = false;
''', '''	/* STEP 1 - SETUP CAMERA */
	CameraMatrix camera_matrix;
	bool ortho = false;
	// CAMERA-FIT-PATCH: a keep-height camera in a screen viewport narrower than rendering/camera/fit_aspect
	// shows the horizontal extent it has at fit_aspect (same factor as the Camera node's projections)
	const real_t fit_scale = camera_fit_screen ? CameraMatrix::get_fit_aspect_scale(p_viewport_size.width / (float)p_viewport_size.height, camera->vaspect) : 1.0;
''')
    # orthogonal and frustum
    s = times(s, '''					camera->size,
					p_viewport_size.width / (float)p_viewport_size.height,
''', '''					camera->size * fit_scale,
					p_viewport_size.width / (float)p_viewport_size.height,
''', 2)
    s = once(s, '''					camera->fov,
''', '''					CameraMatrix::get_fit_fovy(camera->fov, fit_scale),
''')
    old = '	_render_scene(camera_transform, camera_matrix, 0, ortho, camera->env, p_scenario, p_shadow_atlas, RID(), -1);\n'
    s = once(s, old, '''	CameraMatrix::fit_render_scale = fit_scale; // CAMERA-FIT-PATCH: for a sky's custom FOV
''' + old + '''	CameraMatrix::fit_render_scale = 1.0;
''')
    return s


def vs_viewport_cpp(s):
    old = 'void VisualServerViewport::_draw_3d(Viewport *p_viewport, ARVRInterface::Eyes p_eye) {\n'
    return once(s, old, old + '''	// CAMERA-FIT-PATCH: rendering/camera/fit_aspect applies to the viewport attached to the screen only
	VSG::scene->camera_fit_screen = p_viewport->viewport_to_screen_rect != Rect2();
''')


def sky_fov(s):
    return once(s, '		camera.set_perspective(p_custom_fov, aspect, near_plane, far_plane);\n',
                '		camera.set_perspective(CameraMatrix::get_fit_fovy(p_custom_fov, CameraMatrix::fit_render_scale), aspect, near_plane, far_plane); // CAMERA-FIT-PATCH\n')


# --- scene ---

def camera_cpp(s):
    old = 'void Camera::_update_audio_listener_state() {\n'
    s = once(s, old, '''
// CAMERA-FIT-PATCH: the widening VisualServerScene::render_camera applies (rendering/camera/fit_aspect), for
// a camera of a viewport attached to the screen; p_viewport_size has the aspect of the rendered viewport
static real_t _camera_fit_scale(const Camera *p_camera, const Size2 &p_viewport_size, bool p_keep_width) {
	const Viewport *vp = p_camera->get_viewport();
	if (!vp || vp->get_attach_to_screen_rect() == Rect2()) {
		return 1.0;
	}
	return CameraMatrix::get_fit_aspect_scale(p_viewport_size.aspect(), p_keep_width);
}

static real_t _camera_fit_fovy(const Camera *p_camera, real_t p_fovy_degrees, const Size2 &p_viewport_size, bool p_keep_width) {
	return CameraMatrix::get_fit_fovy(p_fovy_degrees, _camera_fit_scale(p_camera, p_viewport_size, p_keep_width));
}

''' + old)
    s = times(s, 'cm.set_perspective(fov, viewport_size.aspect(), ',
              'cm.set_perspective(_camera_fit_fovy(this, fov, viewport_size, keep_aspect == KEEP_WIDTH), viewport_size.aspect(), ', 5)
    s = times(s, 'cm.set_orthogonal(size, viewport_size.aspect(), ',
              'cm.set_orthogonal(size * _camera_fit_scale(this, viewport_size, keep_aspect == KEEP_WIDTH), viewport_size.aspect(), ', 4)
    s = once(s, '''		} else {
			hsize = size * viewport_size.aspect();
			vsize = size;
		}
''', '''		} else {
			vsize = size * _camera_fit_scale(this, viewport_size, false); // CAMERA-FIT-PATCH
			hsize = vsize * viewport_size.aspect();
		}
''')
    return s


edit('core/math/camera_matrix.h', camera_matrix_h)
edit('core/math/camera_matrix.cpp', camera_matrix_cpp)
edit('servers/visual/visual_server_scene.h', vs_scene_h)
edit('servers/visual/visual_server_scene.cpp', vs_scene_cpp)
edit('servers/visual/visual_server_viewport.cpp', vs_viewport_cpp)
edit('drivers/gles3/rasterizer_scene_gles3.cpp', sky_fov)
edit('drivers/gles2/rasterizer_scene_gles2.cpp', sky_fov)
edit('scene/3d/camera.cpp', camera_cpp)
