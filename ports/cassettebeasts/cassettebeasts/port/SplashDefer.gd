extends "res://menus/title/SplashScreen.gd"
# Cassette Beasts port: the splash started the full game load at the second studio card, and on a slow handheld the
# load blocks the main thread, so that animation froze for the whole load. Here the order stays the same (boot
# splash key art, Bytten video, Raw Fury, Godot, title), but the load runs first, under a copy of the static boot
# splash image with a progress bar (the game's own load progress, LoadingUI, which the cover hides); then the studio
# cards play without stalls and the title follows at once.
# Installed by PortOptions.gd (set_script). License: 0BSD.

const BOOT_SPLASH = "application/boot_splash/image"
const LOG = "user://port_options.log"

var _loaded_early = false
var _cover = null
var _bar = null
var _shown = -1.0


func _log(msg):
	var f = File.new()
	if f.open(LOG, File.READ_WRITE) != OK:
		f.open(LOG, File.WRITE)
	f.seek_end()
	f.store_line("%.1f\t%s" % [OS.get_ticks_msec() / 1000.0, msg])
	f.close()


# runs after the base _ready (Godot 3 calls _ready on every script level), which already started the first card
func _ready():
	if mod_warning.visible:
		_log("splash: mod warning shown, original load order kept")
		return
	video_player.stop()
	finished = true # holds the base _process/_input while loading
	_show_cover()
	_log("splash: full load under the boot splash image")
	var lui = _frame_per_task_ui()
	load_promise = Promise.new()
	SceneManager.set_loading(true)
	SceneManager.start_preload("full_load", load_promise)
	if not load_promise.ready:
		yield(load_promise, "fulfilled")
	if lui:
		lui.frame_per_task = false
	_loaded_early = true
	_log("splash: load done, studio cards")
	if _cover:
		_cover.queue_free()
		_cover = null
		_bar = null
	finished = false
	card_index = 0
	setup_card()


# the game's LoadingUI with a frame between load steps (PortLoadingUI.gd), so the progress bar is drawn
func _frame_per_task_ui():
	var lui = SceneManager.preloader.loading_ui if SceneManager.preloader else null
	if not lui:
		return null
	if not "frame_per_task" in lui:
		var script = load(get_script().resource_path.get_base_dir() + "/PortLoadingUI.gd")
		if not script:
			return null
		# set_script resets the script's variables: keep the values the node has
		var vals = {}
		for p in lui.get_property_list():
			if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				vals[p.name] = lui.get(p.name)
		lui.set_script(script)
		for k in vals:
			lui.set(k, vals[k])
	lui.frame_per_task = true
	return lui


func _show_cover():
	var path = str(ProjectSettings.get_setting(BOOT_SPLASH)) if ProjectSettings.has_setting(BOOT_SPLASH) else ""
	var tex = load(path) if path != "" else null
	_cover = CanvasLayer.new()
	_cover.layer = 120
	var bg = ColorRect.new()
	bg.color = ProjectSettings.get_setting("application/boot_splash/bg_color") if ProjectSettings.has_setting("application/boot_splash/bg_color") else Color(0.14, 0.14, 0.14)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	_cover.add_child(bg)
	if tex:
		var rect = TextureRect.new()
		rect.texture = tex
		rect.expand = true
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.anchor_right = 1.0
		rect.anchor_bottom = 1.0
		_cover.add_child(rect)
	# at the bottom edge (under the logo on 16:9, under the key art band on taller screens): the game's menu teal on the letterbox purple
	_bar = ProgressBar.new()
	_bar.percent_visible = false
	_bar.min_value = 0.0
	_bar.max_value = 1.0
	_bar.anchor_left = 0.2
	_bar.anchor_right = 0.8
	_bar.anchor_top = 0.955
	_bar.anchor_bottom = 0.955
	_bar.margin_top = -14
	_bar.margin_bottom = 14
	var track = StyleBoxFlat.new()
	track.bg_color = Color(0.1686, 0.1098, 0.2235)
	track.border_color = Color(0.6706, 0.4588, 0.9098)
	track.set_border_width_all(4)
	var fg = StyleBoxFlat.new()
	fg.bg_color = Color(0.247, 0.733, 0.624)
	_bar.add_stylebox_override("bg", track)
	_bar.add_stylebox_override("fg", fg)
	if ProjectSettings.get_setting("application/boot_splash/progress_bar") == true:
		_bar.value = float(ProjectSettings.get_setting("application/boot_splash/progress_end"))
	_cover.add_child(_bar)
	add_child(_cover)


# the game's load progress: finished steps of LoadingUI plus the running step's own progress
func _process(delta):
	if not _bar:
		return
	var lui = SceneManager.preloader.loading_ui if SceneManager.preloader else null
	if not lui or lui.task_count <= 0:
		return
	var done = float(lui.progress_bar.value)
	var task = lui.current_task
	if task and task.progress_max > 0:
		done = max(done, lui.current_task_index + clamp(float(task.progress) / task.progress_max, 0.0, 1.0))
	# the engine's boot bar (apply_boot_progress.py) filled the first part
	var start = 0.0
	if ProjectSettings.get_setting("application/boot_splash/progress_bar") == true:
		start = float(ProjectSettings.get_setting("application/boot_splash/progress_end"))
	var target = start + (1.0 - start) * clamp(done / lui.task_count, 0.0, 1.0)
	if _shown < 0.0:
		_shown = target # take over the engine's bar where it stopped
	_shown = max(_shown, lerp(_shown, target, min(1.0, delta * 8.0)))
	_bar.value = _shown


func start_full_load():
	if _loaded_early:
		return # done before the cards
	.start_full_load()
