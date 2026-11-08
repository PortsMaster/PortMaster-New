#!/usr/bin/env python3
"""Boot splash progress bar (port patch, generic, off unless switched on).

Godot 3 draws the boot splash once, in Main::setup2, then loads every autoload (script parse + compile, scene
instancing) and the main scene in Main::start without drawing anything: a big game sits on a still image for many
seconds (Cassette Beasts on the RG Cube XX: ~13 s), and when that one draw is lost (the display still handed over
from the front end) the screen stays black for all of it. With application/boot_splash/progress_bar=true the
engine composes the boot image at screen size (laid out like a TextureRect with KEEP_ASPECT_CENTERED on
boot_splash/bg_color, the way set_boot_image fits it) and redraws it with a progress bar after each autoload load,
each autoload's add_child (_ready) and the main scene's load, at most every progress_interval_ms (and always the
first time). The bar's size and place are given like a Control's in a 2D project of base size
display/window/size (stretch "expand": one unit = min(screen w / base w, screen h / base h) pixels), so a game
script can take over with the same bar:
  application/boot_splash/progress_bar          bool   false
  application/boot_splash/progress_anchor_left  float  0.2    (fractions of the screen)
  application/boot_splash/progress_anchor_right float  0.8
  application/boot_splash/progress_anchor_y     float  0.955  (centre line)
  application/boot_splash/progress_height       float  28     (units)
  application/boot_splash/progress_border       float  4      (units)
  application/boot_splash/progress_color / progress_bg_color / progress_border_color   Color
  application/boot_splash/progress_end          float  1.0    (how full the bar is when the main scene is in:
                                                               leave room for the game's own loading)
  application/boot_splash/progress_interval_ms  int    250
usage: apply_boot_progress.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]
MARK = 'BOOT-PROGRESS-PATCH'


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


HELPER = '''
// BOOT-PROGRESS-PATCH: the boot splash redrawn with a progress bar while autoloads and the main scene load
static Ref<Image> boot_progress_canvas;
static Color boot_progress_bg;
static uint64_t boot_progress_last = 0;

static void _boot_progress_setup(const Ref<Image> &p_logo, const Color &p_bg, bool p_fullsize) {
	if (!GLOBAL_DEF("application/boot_splash/progress_bar", false) || p_logo.is_null() || p_logo->empty()) {
		return;
	}
	Size2 ws = OS::get_singleton()->get_window_size();
	int w = ws.width, h = ws.height;
	if (w <= 0 || h <= 0) {
		return;
	}
	Ref<Image> logo = p_logo->duplicate();
	if (logo->is_compressed()) {
		logo->decompress();
	}
	logo->convert(Image::FORMAT_RGBA8);
	int lw = logo->get_width(), lh = logo->get_height();
	if (p_fullsize) { // fit, keeping the aspect (as set_boot_image does)
		if ((float)w / h > (float)lw / lh) {
			lw = MAX(1, (int)((float)logo->get_width() * h / logo->get_height()));
			lh = h;
		} else {
			lh = MAX(1, (int)((float)logo->get_height() * w / logo->get_width()));
			lw = w;
		}
		logo->resize(lw, lh, Image::INTERPOLATE_BILINEAR);
	}
	boot_progress_bg = p_bg;
	boot_progress_canvas.instance();
	boot_progress_canvas->create(w, h, false, Image::FORMAT_RGBA8);
	boot_progress_canvas->fill(Color(p_bg.r, p_bg.g, p_bg.b, 1.0));
	Rect2 src(0, 0, MIN(lw, w), MIN(lh, h));
	boot_progress_canvas->blend_rect(logo, src, Point2((w - src.size.x) / 2, (h - src.size.y) / 2));
	GLOBAL_DEF("application/boot_splash/progress_anchor_left", 0.2);
	GLOBAL_DEF("application/boot_splash/progress_anchor_right", 0.8);
	GLOBAL_DEF("application/boot_splash/progress_anchor_y", 0.955);
	GLOBAL_DEF("application/boot_splash/progress_height", 28.0);
	GLOBAL_DEF("application/boot_splash/progress_border", 4.0);
	GLOBAL_DEF("application/boot_splash/progress_color", Color(0.247, 0.733, 0.624));
	GLOBAL_DEF("application/boot_splash/progress_bg_color", Color(0.1686, 0.1098, 0.2235));
	GLOBAL_DEF("application/boot_splash/progress_border_color", Color(0.6706, 0.4588, 0.9098));
	GLOBAL_DEF("application/boot_splash/progress_end", 1.0);
	GLOBAL_DEF("application/boot_splash/progress_interval_ms", 250);
}

static void _boot_progress_fill(Image *p_img, int x0, int y0, int x1, int y1, const Color &p_c) {
	x0 = CLAMP(x0, 0, p_img->get_width());
	x1 = CLAMP(x1, 0, p_img->get_width());
	y0 = CLAMP(y0, 0, p_img->get_height());
	y1 = CLAMP(y1, 0, p_img->get_height());
	for (int y = y0; y < y1; y++) {
		for (int x = x0; x < x1; x++) {
			p_img->set_pixel(x, y, p_c);
		}
	}
}

// p_ratio: 0..1 of the engine's part (scaled to progress_end); p_force: draw now whatever the interval
static void _boot_progress(float p_ratio, bool p_force = false) {
	if (boot_progress_canvas.is_null()) {
		return;
	}
	uint64_t now = OS::get_singleton()->get_ticks_msec();
	if (!p_force && now - boot_progress_last < (uint64_t)(int)GLOBAL_GET("application/boot_splash/progress_interval_ms")) {
		return;
	}
	boot_progress_last = now;
	int w = boot_progress_canvas->get_width(), h = boot_progress_canvas->get_height();
	Size2 base(GLOBAL_GET("display/window/size/width"), GLOBAL_GET("display/window/size/height"));
	float unit = (base.x > 0 && base.y > 0) ? MIN(w / base.x, h / base.y) : 1.0;
	float half = (float)GLOBAL_GET("application/boot_splash/progress_height") * unit * 0.5;
	int border = (int)Math::round((float)GLOBAL_GET("application/boot_splash/progress_border") * unit);
	int x0 = (int)(w * (float)GLOBAL_GET("application/boot_splash/progress_anchor_left"));
	int x1 = (int)(w * (float)GLOBAL_GET("application/boot_splash/progress_anchor_right"));
	float cy = h * (float)GLOBAL_GET("application/boot_splash/progress_anchor_y");
	int y0 = (int)Math::round(cy - half), y1 = (int)Math::round(cy + half);
	float r = CLAMP(p_ratio, 0.0f, 1.0f) * (float)GLOBAL_GET("application/boot_splash/progress_end");
	Ref<Image> img = boot_progress_canvas->duplicate();
	img->lock();
	_boot_progress_fill(img.ptr(), x0, y0, x1, y1, GLOBAL_GET("application/boot_splash/progress_border_color"));
	_boot_progress_fill(img.ptr(), x0 + border, y0 + border, x1 - border, y1 - border, GLOBAL_GET("application/boot_splash/progress_bg_color"));
	_boot_progress_fill(img.ptr(), x0, y0, x0 + (int)((x1 - x0) * r), y1, GLOBAL_GET("application/boot_splash/progress_color"));
	img->unlock();
	VisualServer::get_singleton()->set_boot_image(img, boot_progress_bg, false, false);
}

static void _boot_progress_done() {
	if (boot_progress_canvas.is_valid()) {
		_boot_progress(1.0, true);
		boot_progress_canvas.unref();
	}
}
'''


def main_cpp(s):
    s = once(s, '''static bool editor = false;
''', '''static bool editor = false;
''' + HELPER)
    s = once(s, '''			VisualServer::get_singleton()->set_boot_image(boot_logo, boot_bg_color, boot_logo_scale, boot_logo_filter);
''', '''			VisualServer::get_singleton()->set_boot_image(boot_logo, boot_bg_color, boot_logo_scale, boot_logo_filter);
			_boot_progress_setup(boot_logo, boot_bg_color, boot_logo_scale); // BOOT-PROGRESS-PATCH
			_boot_progress(0.0, true);
''')
    s = once(s, '''				//second pass, load into global constants
				List<Node *> to_add;
''', '''				//second pass, load into global constants
				List<Node *> to_add;
				int boot_steps = 1, boot_done = 0; // BOOT-PROGRESS-PATCH: each autoload loaded + added, the main scene
				for (List<PropertyInfo>::Element *E = props.front(); E; E = E->next()) {
					if (E->get().name.begins_with("autoload/")) {
						boot_steps += 2;
					}
				}
''')
    s = once(s, '''					RES res = ResourceLoader::load(path);
					ERR_CONTINUE_MSG(res.is_null(), "Can't autoload: " + path);''', '''					RES res = ResourceLoader::load(path);
					_boot_progress((float)++boot_done / boot_steps); // BOOT-PROGRESS-PATCH
					ERR_CONTINUE_MSG(res.is_null(), "Can't autoload: " + path);''')
    s = once(s, '''				for (List<Node *>::Element *E = to_add.front(); E; E = E->next()) {
					sml->get_root()->add_child(E->get());
				}''', '''				for (List<Node *>::Element *E = to_add.front(); E; E = E->next()) {
					sml->get_root()->add_child(E->get());
					_boot_progress((float)++boot_done / boot_steps); // BOOT-PROGRESS-PATCH
				}''')
    s = once(s, '''				ERR_FAIL_COND_V_MSG(!scene, false, "Failed loading scene: " + local_game_path);
				sml->add_current_scene(scene);''', '''				ERR_FAIL_COND_V_MSG(!scene, false, "Failed loading scene: " + local_game_path);
				_boot_progress_done(); // BOOT-PROGRESS-PATCH
				sml->add_current_scene(scene);''')
    return s


edit('main/main.cpp', main_cpp)
