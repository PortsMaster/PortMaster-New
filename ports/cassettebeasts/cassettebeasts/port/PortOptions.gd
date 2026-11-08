extends Node
# Cassette Beasts port glue (autoload via override.cfg; the other scripts of this folder are loaded from here):
# - an "Aspect ratio" row in the game's Graphics settings (custom frt with apply_letterbox.py, apply_camera_fit.py,
#   apply_aspect_runtime.py): Cropped = the game's default (the 3D keeps its height, the sides of the 16:9 view
#   are cut off on narrower screens), 16:9 letterbox = the full 16:9 view in a band, the bars drawn in the game's
#   menu checker, Expanded view (fill width) = the camera widened to the full 16:9 width (more map above/below, slower); applied
#   at once and kept in user://port_options.cfg; the title screen and splash always fill the screen;
# - a "UI size" row: the game lays its 2D out for 1920x1080 (0.375x on a 720x720 screen); Large / Larger lay it out
#   for 1440x810 / 1280x720 instead (everything 1.33x / 1.5x bigger; menus too wide for that are scaled to fit);
# - the splash loads the game under the static boot splash image (SplashDefer.gd);
# - level streaming spread over frames (PortLevelStreamer.gd, PortChunk.gd) and a guard for the player's ground;
# - an "Ultra Low Tweaks" row (on by default on RK3326: fewer physics steps, shorter streaming distances; a first-start
#   pop-up there explains it and offers to turn it off, keeping it on recommended);
# - an on-screen keyboard for text fields (PortDelegate.gd, PortKeyboard.gd);
# - no store buttons and no update pop-ups on the title screen, the pause menu centred on tall screens;
# - "Prepare shaders" in Graphics settings (PortShaderPrep.gd); readable battle button names (PortCassetteLabels.gd);
# - the owner's DLC packs from gamedata/dlc (the game looks next to the engine, which runs from a squashfs).
# License: 0BSD.

const CFG = "user://port_options.cfg"
const LOG = "user://port_options.log"
const MODES = ["PORT_ASPECT_CROP", "PORT_ASPECT_LETTERBOX", "PORT_ASPECT_FILL"] # PortText.gd
const ASPECT = 1.777778
const DEFAULT_MODE = 1
const UI_SIZES = [Vector2(1920, 1080), Vector2(1440, 810), Vector2(1280, 720)]
const UI_LABELS = ["PORT_UI_NORMAL", "PORT_UI_LARGE", "PORT_UI_LARGER"]
const DEFAULT_UI = 1 # Large on the small screens; Normal from 720 lines up on wide screens (TrimUI Smart Pro 1280x720), see _default_ui()
# "Ultra Low Tweaks" (on by default where override_lo.cfg sets port/low_tweaks: RK3326): fewer physics steps, and the
# level streamer fills less ahead of the camera: terrain to LOW_TERRAIN_FAR (game: 100 m), details (props, NPCs) to
# LOW_DETAIL_FAR. RG351P town walk: ~75 -> ~61 ms a frame (2026-10-09)
const LOW_PHYSICS_FPS = 15
const LOW_TERRAIN_FAR = 80.0
const LOW_DETAIL_FAR = 50.0

var mode = DEFAULT_MODE
var ui_size = _default_ui()
var low_tweaks = ProjectSettings.has_setting("port/low_tweaks") and ProjectSettings.get_setting("port/low_tweaks") == true
# "3D resolution" (Graphics): 0 = Auto (the launcher's screen-matched scale), else percent of the screen; the engine
# reads rendering/quality/3d_render_scale every frame (apply_render_scale_runtime.py), so a change applies at once
const RS_VALUES = [0, 40, 45, 50, 60, 75, 100]
var render_scale = 0
var _rs_auto = 1.0


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	load(get_script().resource_path.get_base_dir() + "/PortText.gd").install()
	# a fresh log every session
	var d = Directory.new()
	if d.file_exists(LOG):
		d.remove(LOG)
	var c = ConfigFile.new()
	if c.load(CFG) == OK:
		mode = int(c.get_value("graphics", "aspect_mode", DEFAULT_MODE))
		ui_size = clamp(int(c.get_value("graphics", "ui_size", _default_ui())), 0, UI_SIZES.size() - 1)
		low_tweaks = bool(c.get_value("graphics", "low_tweaks", low_tweaks))
		render_scale = int(c.get_value("graphics", "render_scale", 0))
		if not render_scale in RS_VALUES:
			render_scale = 0
	_rs_auto = float(ProjectSettings.get_setting("rendering/quality/3d_render_scale")) if ProjectSettings.has_setting("rendering/quality/3d_render_scale") else 1.0
	_apply_render_scale()
	_apply()
	_apply_ui_size()
	_log("rendering: 3D scale %s, 3D pixel cap %s, effect buffers %s, %s" % [ProjectSettings.get_setting("rendering/quality/3d_render_scale"), ProjectSettings.get_setting("rendering/viewports/max_3d_pixels"), "off" if ProjectSettings.get_setting("rendering/viewports/force_no_3d_effects") else "on", VisualServer.get_video_adapter_name()])
	_load_dlc()
	get_tree().connect("node_added", self, "_on_node_added")
	# a text field keeps the keyboard focus after its menu is done (character creation -> the intro's load), and the
	# game opens the on-screen keyboard on A while any text field has it: drop that focus when a load or scene change
	# starts (PortDelegate also refuses the keyboard while the game loads or transitions)
	var sm = get_tree().root.get_node_or_null("SceneManager")
	if sm:
		for sig in ["loading_started", "scene_change_starting", "transitioned_out"]:
			if sm.has_signal(sig):
				sm.connect(sig, self, "_drop_text_focus")

	_install_keyboard()
	_install_word_icons()
	_install_keyboard_player()
	# the main scene (the splash) entered the tree together with the autoloads, before this connect; autoloads get
	# _ready first, so it can still be handled here before its own _ready
	for n in get_tree().root.get_children():
		if n != self:
			_on_node_added(n)
	# the game's own autoloads (GlobalMessageDialog, GlobalMenuDialog) came before this one
	_find_message_boxes(get_tree().root)


func _drop_text_focus():
	var gui = get_tree().root.get_node_or_null("GlobalUI")
	var container = gui.get("container") if gui else null
	var fo = container.get_focus_owner() if container is Control else null
	if fo is LineEdit:
		fo.release_focus()
		_log("text field focus dropped at a load/scene change: %s" % fo.get_path())


# DLC: Steam puts a DLC's pack (dlc/01_pier.pck, ...) into the game's dlc folder only for its owners; the game loads
# the packs it finds next to its executable (DLC.load_dlc_pcks, during the load after the splash). The engine runs
# from the port's squashfs, so the packs the owner copied to gamedata/dlc are loaded here, before that.
func _load_dlc():
	var dir = get_script().resource_path.get_base_dir().get_base_dir().plus_file("gamedata/dlc")
	var d = Directory.new()
	if d.open(dir) != OK:
		return
	var packs = []
	d.list_dir_begin(true, true)
	var f = d.get_next()
	while f != "":
		if f.get_extension() == "pck":
			packs.append(f)
		f = d.get_next()
	d.list_dir_end()
	packs.sort()
	for pack in packs:
		var ok = ProjectSettings.load_resource_pack(dir.plus_file(pack))
		_log("dlc: %s %s" % [pack, "loaded" if ok else "FAILED"])


# the splash's studio cards are laid out for the game's size (cropped at a larger UI)
# message boxes: the panel has a fixed minimum width (1361) that, with the margins around it, needs 1705 units; at a
# larger UI size the canvas is narrower (1440 at Large on a square screen) and the box's right end with the "next"
# arrow went off the screen. The panel is capped to the width between the margins (the text wraps sooner).
var _message_boxes = []


func _fit_message_box(mb):
	if not is_instance_valid(mb) or not mb.is_inside_tree():
		return
	var panel = mb.get_node_or_null("PanelContainer")
	if not panel:
		return
	if not panel.has_meta("port_min_w"):
		panel.set_meta("port_min_w", panel.rect_min_size.x)
	var want = panel.get_meta("port_min_w")
	var parent = mb.get_parent()
	var margins = 0.0
	if parent is MarginContainer:
		margins = parent.get_constant("margin_left") + parent.get_constant("margin_right")
	var avail = mb.get_viewport().get_visible_rect().size.x - margins
	panel.rect_min_size.x = min(want, max(avail, 200.0))


# menus wider than the screen: at a larger UI size the canvas is narrower and some of the game's menus (save file
# list, character creation, party, map) have more fixed width than fits. Such a menu is laid out in a canvas that
# much wider and scaled down to the screen (only that menu gets smaller; nothing runs off the edge). Content that
# keeps its proportions (the save file list's cassettes) widens with the height: then only the width grows and the
# menu is centred vertically. The map menu's root is moved by the game: there only its content and bottom bar are
# scaled (content about its middle, bars about their bottom edge). The save file list slides by its own margins
# and is a Container (which resets its children's scale): its root is only scaled, about its bottom edge.
const FIT_PARTS_ONLY = ["MapMenu"]
const FIT_SCALE_ONLY = ["FileMenu"]
var _menus = []


func _menu_parts(m):
	var parts = []
	for c in m.get_children():
		if c is Control and (c.name == "Scroller" or c.name.ends_with("ButtonPanel")):
			parts.append(c)
	if parts.empty():
		for c in m.get_children():
			if c is Control:
				parts.append(c) # the save file list: its root is wider than its content (slide-out room)
	return parts


func _unfit_menu(m):
	for c in _menu_parts(m):
		c.rect_scale = Vector2.ONE
	if m.name in FIT_SCALE_ONLY:
		m.rect_scale = Vector2.ONE
	if m.has_meta("port_fit"):
		var f = m.get_meta("port_fit") # [grow, shift]
		m.rect_scale = Vector2.ONE
		m.margin_right -= f[0].x
		m.margin_bottom -= f[0].y + f[1]
		m.margin_top -= f[1]
		m.remove_meta("port_fit")


func _apply_fit(m, sc, grow, shift):
	m.set_meta("port_fit", [grow, shift])
	m.margin_right += grow.x
	m.margin_bottom += grow.y + shift
	m.margin_top += shift
	m.rect_scale = Vector2(sc, sc)


func _menu_excess(m, vs):
	# the menu's main content and its bottom button bar; side panels that slide in from off-screen (the bestiary's
	# list and counter) are wide on purpose
	var widest = 0.0
	for c in _menu_parts(m):
		widest = max(widest, _widest(c, false) * c.rect_scale.x)
	return widest * m.rect_scale.x - vs.x


func _fit_menu(m):
	_unfit_menu(m)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if not is_instance_valid(m) or not m.is_inside_tree():
		return
	var vs = m.get_viewport().get_visible_rect().size
	var excess = _menu_excess(m, vs)
	if excess <= 2.0:
		return
	var sc = vs.x / (vs.x + excess)
	if m.name in FIT_SCALE_ONLY:
		m.rect_pivot_offset = Vector2(0.0, m.rect_size.y)
		m.rect_scale = Vector2(sc, sc)
		_log("menu fit: %s %.0f units too wide, scaled %.2f" % [m.name, excess, sc])
		return
	if m.name in FIT_PARTS_ONLY:
		for c in _menu_parts(m):
			var bar = c.anchor_top >= 1.0
			c.rect_pivot_offset = Vector2(0.0, c.rect_size.y * (1.0 if bar else 0.5))
			c.rect_scale = Vector2(sc, sc)
		_log("menu fit: %s %.0f units too wide, parts scaled %.2f" % [m.name, excess, sc])
		return
	_apply_fit(m, sc, vs / sc - vs, 0.0)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if not is_instance_valid(m) or not m.is_inside_tree():
		return
	if _menu_excess(m, vs) > 2.0:
		# grew with the height: width only, centred vertically
		_unfit_menu(m)
		_apply_fit(m, sc, Vector2(vs.x / sc - vs.x, 0.0), (vs.y - vs.y * sc) * 0.5)
	_log("menu fit: %s %.0f units too wide, scale %.2f" % [m.name, excess, sc])


# widest visible control of a branch (controls inside clipping parents excepted)
func _widest(n, clipped):
	var w = 0.0
	if n is CanvasItem and not n.visible:
		return w
	if n is Control:
		if not clipped:
			w = n.rect_size.x
		clipped = clipped or n.rect_clip_content or n is ScrollContainer
	for c in n.get_children():
		w = max(w, _widest(c, clipped))
	return w


func _fit_menus():
	for i in range(_menus.size() - 1, -1, -1):
		var m = _menus[i].get_ref()
		if m and m.is_inside_tree():
			_fit_menu(m)
		elif not m:
			_menus.remove(i)


func _find_message_boxes(n):
	if n.name == "MessageBox" and n is VBoxContainer:
		_message_boxes.append(weakref(n))
		call_deferred("_fit_message_box", n)
		return
	for c in n.get_children():
		_find_message_boxes(c)


func _fit_message_boxes():
	for i in range(_message_boxes.size() - 1, -1, -1):
		var mb = _message_boxes[i].get_ref()
		if mb:
			_fit_message_box(mb)
		else:
			_message_boxes.remove(i)


# the UI size nobody has chosen yet: the game's own (Normal) once the screen has 720 lines or more, Large below
# Normal from 720 lines up on wide screens only (16:9, 16:10, 5:3); 4:3 and 5:4 screens keep Large at any resolution
# (the game lays out for 16:9: on a narrower screen the same lines leave its text smaller)
static func _default_ui():
	var s = OS.get_window_size()
	return 0 if s.y >= 720 and s.x > s.y * 1.4 else DEFAULT_UI


func _apply_ui_size():
	var cs = get_tree().current_scene
	var splash = cs == null or cs.filename == "res://menus/title/SplashScreen.tscn"
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, UI_SIZES[0 if splash else ui_size])
	call_deferred("_fit_message_boxes")
	call_deferred("_fit_menus")


func _apply():
	# the title screen's 3D background always fills the screen (it looks odd letterboxed)
	var m = 0 if _on_title() else mode
	ProjectSettings.set_setting("rendering/camera/letterbox_aspect", ASPECT if m == 1 else 0.0)
	ProjectSettings.set_setting("rendering/camera/fit_aspect", ASPECT if m == 2 else 0.0)


const FULL_SCREEN_SCENES = ["res://menus/title/TitleMenu.tscn", "res://menus/title/SplashScreen.tscn"]
var _scene = ""


func _on_title():
	var cs = get_tree().current_scene if get_tree() else null
	return cs != null and cs.filename in FULL_SCREEN_SCENES


# physics rate on slow devices (override_lo.cfg: port/physics_fps): the game sets it to the frame rate setting (30),
# and a CPU that renders ~12 frames a second then runs 2-3 physics steps per frame; kept lower here (the game sets
# it again whenever its graphics settings apply)
var _game_physics = 0 # the game's rate (its frame rate setting) before the tweak lowered it


func _apply_low_physics():
	if low_tweaks and Engine.iterations_per_second != LOW_PHYSICS_FPS:
		_game_physics = Engine.iterations_per_second
		Engine.iterations_per_second = LOW_PHYSICS_FPS
		_log("physics: %d steps per second" % LOW_PHYSICS_FPS)
	elif not low_tweaks and _game_physics > 0:
		Engine.iterations_per_second = _game_physics
		_game_physics = 0
		_log("physics: the game's rate again")


func _process(delta):
	_apply_low_physics()
	var cs = get_tree().current_scene
	var s = cs.filename if cs else ""
	if s != _scene:
		_scene = s
		_streamer = null
		_apply()
		_apply_ui_size()
		_release_cache_camera()
	_update_bars()
	_guard_t += delta
	if _guard_t >= GUARD_INTERVAL:
		_guard_t = 0.0
		_stream_guard(cs)


# The game's ShaderCache adds a camera at start-up, the first camera there is, so it is current; the start-up shader
# precompile ends with its clear_current(), which hands the screen to the scene's camera. That precompile is off on
# the port (the game's Switch setting), so the camera stayed current: the title drew from the ground (no camp, only
# the sky's green ground color). Handed over the same way whenever a scene with a camera starts while it idles.
func _release_cache_camera():
	var sc = get_node_or_null("/root/ShaderCache")
	if not sc or sc.is_processing():
		return
	var cam = sc.get("camera")
	if cam is Camera and is_instance_valid(cam) and cam.current:
		cam.clear_current(true)
		var now = get_viewport().get_camera()
		if now:
			_log("camera: the shader cache's idle camera handed over to " + str(now.get_path()))
		else:
			cam.make_current() # no scene camera yet (splash): as before, until a scene brings one


# Letterbox bars: instead of black, the game's own menu backdrop (the dark purple checker of menu_bg_fade, held
# still) with a thin teal edge (the pause menu's colour), on the lowest canvas layer: above the 3D, under all of the
# game's 2D. Shown only while a 3D camera draws in the 16:9 letterbox mode.
const BAR_SHADER = """
shader_type canvas_item;
uniform vec4 base_color : hint_color = vec4(0.1686, 0.1098, 0.2235, 1.0);
uniform vec4 hi_color : hint_color = vec4(0.6706, 0.4588, 0.9098, 0.0625);
uniform float cell = 12.0;
void fragment() {
	vec2 p = FRAGCOORD.xy / cell;
	p.x -= p.y * 0.333;
	vec2 m = mod(floor(p), 2.0);
	COLOR = vec4(mix(base_color.rgb, hi_color.rgb, hi_color.a * mod(m.x + m.y, 2.0)), 1.0);
}
"""
const EDGE_COLOR = Color(0.247, 0.733, 0.624)
const EDGE = 8.0 # canvas units (the UI is 1920 wide: 3 pixels on a 720 wide screen)
var _bars = null
var _bar_rects = []


func _make_bars():
	_bars = CanvasLayer.new()
	_bars.layer = -128
	var mat = ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = BAR_SHADER
	for i in 4:
		var r = ColorRect.new()
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i < 2:
			r.material = mat
		else:
			r.color = EDGE_COLOR
		_bars.add_child(r)
		_bar_rects.append(r)
	add_child(_bars)


func _update_bars():
	var vp = get_viewport()
	var cam = vp.get_camera()
	var on = mode == 1 and not _on_title() and cam != null and cam.is_inside_tree() and cam.current
	var size = vp.get_visible_rect().size
	var bar = (size.y - size.x / ASPECT) * 0.5
	on = on and bar > 1.0
	if not on:
		if _bars:
			_bars.visible = false
		return
	if not _bars:
		_make_bars()
	_bars.visible = true
	_bar_rects[0].rect_position = Vector2.ZERO
	_bar_rects[0].rect_size = Vector2(size.x, bar)
	_bar_rects[1].rect_position = Vector2(0, size.y - bar)
	_bar_rects[1].rect_size = Vector2(size.x, bar)
	_bar_rects[2].rect_position = Vector2(0, bar - EDGE)
	_bar_rects[2].rect_size = Vector2(size.x, EDGE)
	_bar_rects[3].rect_position = Vector2(0, size.y - bar)
	_bar_rects[3].rect_size = Vector2(size.x, EDGE)


# Level streaming: the game's LevelStreamer is replaced by PortLevelStreamer.gd (new chunks set up on the main
# thread one per frame, details filled nearest first within a time budget).
# The guard below makes sure the ground around the player is there: chunks within GUARD_RANGE that are missing are
# loaded, ones still waiting are set up, and ones left half filled for GUARD_STALE_S are completed at once.
const GUARD_INTERVAL = 0.2
const GUARD_RANGE = 12.0
const GUARD_STALE_S = 2.0
var _guard_t = 0.0
var _streamer = null
var _partial_since = {}


# the streamer's distances for the "Ultra Low Tweaks" setting (also on a switch in the settings, for the current map)
func _apply_low_stream(node):
	if not is_instance_valid(node) or not node.has_meta("game_far"):
		return
	node.camera_far_distance = LOW_TERRAIN_FAR if low_tweaks else node.get_meta("game_far")
	if "detail_far" in node:
		node.detail_far = LOW_DETAIL_FAR if low_tweaks else 0.0
	_log("stream: terrain within %d m, details within %s" % [node.camera_far_distance, "%d m" % node.detail_far if "detail_far" in node and node.detail_far > 0 else "the same"])


func _install_streamer(node):
	if "camera_far_distance" in node:
		node.set_meta("game_far", node.camera_far_distance)
	var script = load(get_script().resource_path.get_base_dir() + "/PortLevelStreamer.gd")
	if not script:
		node.force_synchronous_loading = true
		return
	# set_script resets the script's variables: keep the values the scene gave them
	var vals = {}
	for p in node.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			vals[p.name] = node.get(p.name)
	node.set_script(script)
	for k in vals:
		node.set(k, vals[k])
	node.force_synchronous_loading = false
	node.log_target = self
	_apply_low_stream(node)
	_log("stream: budgeted streamer installed")


func _is_streamer(node):
	return node != null and node.has_method("force_load_position") and "chunks" in node and "hot_chunks" in node


# the map's LevelStreamer is a direct child of the scene root (Overworld, dungeons): a cheap check every time
# (no permanent "none here" cache: on the device the scene can be current before its streamer is in place)
func _find_streamer(cs):
	var ls = cs.get_node_or_null("LevelStreamer")
	if _is_streamer(ls):
		return ls
	for c in cs.get_children():
		if _is_streamer(c):
			return c
	return null


func _stream_guard(cs):
	if not cs:
		return
	if _streamer == null or not is_instance_valid(_streamer) or not _streamer.is_inside_tree():
		_streamer = _find_streamer(cs)
		_partial_since.clear()
		if _streamer == null:
			return
		_log("stream guard: streamer %s in %s (chunks %d)" % [str(_streamer.get_path()), cs.filename, _streamer.chunks.size()])
	var ws = get_node_or_null("/root/WorldSystem")
	var pl = ws.get_player() if ws and ws.has_method("get_player") else null
	if not pl or not pl.is_inside_tree():
		return
	var p = pl.global_transform.origin
	var now = OS.get_ticks_msec() / 1000.0
	var done = {}
	for dx in [-GUARD_RANGE, 0.0, GUARD_RANGE]:
		for dz in [-GUARD_RANGE, 0.0, GUARD_RANGE]:
			var q = p + Vector3(dx, 0.0, dz)
			var idx = _streamer.chunk_for_pos_3d(q)
			if done.has(idx):
				continue
			done[idx] = true
			var ch = _streamer.chunks.get(idx)
			var t0 = OS.get_ticks_usec()
			if ch == null:
				_streamer.force_load_position(q)
				_log("stream guard: loaded chunk %s near %s (%d ms)" % [str(idx), str(p), (OS.get_ticks_usec() - t0) / 1000])
			elif "pending" in ch and ch.pending:
				ch.run_setup()
				_log("stream guard: set up chunk %s near %s (%d ms)" % [str(idx), str(p), (OS.get_ticks_usec() - t0) / 1000])
			elif ch.has_method("is_full") and ch.terrain and not ch.is_full():
				# with a shorter detail distance (Ultra Low Tweaks) a chunk outside the streamer's detail box is meant
				# to stay partial: completing it made the streamer remove its details again (flashing building)
				var keep = _streamer.get("detail_keep")
				if keep != null and not ch.aabb.intersects(keep):
					_partial_since.erase(idx)
					continue
				if not _partial_since.has(idx):
					_partial_since[idx] = now
				elif now - _partial_since[idx] >= GUARD_STALE_S:
					ch.insert_all()
					_partial_since.erase(idx)
					_log("stream guard: completed chunk %s near %s (%d ms)" % [str(idx), str(p), (OS.get_ticks_usec() - t0) / 1000])
			else:
				_partial_since.erase(idx)


# on-screen keyboard for text fields: only on the game's plain PC delegate (no Steam/NX/MS Store), replaced by a
# subclass that opens PortKeyboard.gd (GlobalUI calls Platform.show_virtual_keyboard on a pad press on a LineEdit)
# START / SELECT as words instead of the Switch + / - (the port presents the pad as a Switch Pro Controller, and
# these handhelds label the buttons with words): port/icons/<set>/10.png (Select) and 11.png (Start), drawn in the
# game's Switch icon style with its UI font (tools/make_startselect_icons.py). InputIcons loads every icon by path
# when it is shown, so each texture takes over the game's path in the resource cache.
const WORD_ICON_SETS = ["switch", "switch_black", "switch_white", "switch_outlined"]
var _word_icons = [] # keeps the textures (and so their cache entries) alive


func _install_word_icons():
	var base = get_script().resource_path.get_base_dir() + "/icons/"
	for s in WORD_ICON_SETS:
		for b in ["10", "11"]:
			var img = Image.new()
			if img.load(base + s + "/" + b + ".png") != OK:
				continue
			var tex = ImageTexture.new()
			tex.create_from_image(img, Texture.FLAG_FILTER | Texture.FLAG_MIPMAPS)
			var path = "res://addons/platform/input_icons/%s/%s.png" % [s, b]
			tex.take_over_path(path)
			_word_icons.append(tex)
	var ok = _word_icons.size() > 0 and load("res://addons/platform/input_icons/switch/11.png") == _word_icons[1]
	_log("word icons: %d START/SELECT textures in place%s" % [_word_icons.size(), "" if ok else " (NOT picked up by load)"])
	# player 1's picture on the controller assignment screen (PortJoypadSlot.gd)
	var himg = Image.new()
	if himg.load(base + "joypad/handheld.png") == OK:
		handheld_icon = ImageTexture.new()
		handheld_icon.create_from_image(himg, Texture.FLAG_FILTER | Texture.FLAG_MIPMAPS)


var handheld_icon = null


# replace a game node's script with a port subclass before its _ready, keeping the values the scene gave its
# script variables (set_script resets them)
func _swap_script(node, file):
	var script = load(get_script().resource_path.get_base_dir() + "/" + file)
	if not script:
		return
	var vals = {}
	for p in node.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			vals[p.name] = node.get(p.name)
	node.set_script(script)
	for k in vals:
		node.set(k, vals[k])


# The handheld as the keyboard player (player 1): gptokeyb2 (cassettebeasts.ini) sends one key per button, keys that
# write no text and that the game does not use. Each key is bound to the actions of the pad button in the same
# position (pad button -> key below), confirm and cancel the Nintendo way (A right, B bottom) like the game does for
# Switch pads, and the prompts use the Switch icons, which show the letter printed at each position. The game's
# KeyboardSettings.apply_settings() rebuilds every action's keys and then reloads the icons, so both are redone on
# InputIcons.icons_changed.
const KB_KEYS = {0: KEY_F5, 1: KEY_F7, 2: KEY_F8, 3: KEY_F10, 4: KEY_F12, 6: KEY_F12, 5: KEY_INSERT, 7: KEY_INSERT,
	10: KEY_ALT, 11: KEY_ENTER, 12: KEY_UP, 13: KEY_DOWN, 14: KEY_LEFT, 15: KEY_RIGHT}


func _install_keyboard_player():
	var mi = get_node_or_null("/root/MultiplayerInput")
	if mi and not mi.has_method("release_startup_pads"):
		_swap_script(mi, "PortMultiplayerInput.gd")
		if mi.has_method("release_startup_pads"):
			mi.release_startup_pads()
	var ii = get_node_or_null("/root/InputIcons")
	if ii and not ii.is_connected("icons_changed", self, "_on_icons_changed"):
		ii.connect("icons_changed", self, "_on_icons_changed")
	_on_icons_changed()
	# the game hides the mouse cursor only while a pad is in use, and the handheld is keys: hide it (a real mouse
	# moved shows it again, the game's MultiplayerInput does that)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_log("controls: the handheld is the keyboard player (player 1)")


func _on_icons_changed():
	_bind_handheld_keys()
	var ii = get_node_or_null("/root/InputIcons")
	var mi = get_node_or_null("/root/MultiplayerInput")
	if not ii or not mi:
		return
	# a pad that took player 1 (A pressed on it at the title) gets the game's own prompts
	if 0 in mi.joypad_players.values():
		return
	var changed = false
	for b in [["ui_accept", JOY_DS_A], ["ui_cancel", JOY_DS_B]]:
		var want = [2, b[1]] # InputIcons.InputType.INPUT_JOYPAD
		if ii.inputs_joypad.get(b[0]) != want:
			ii.inputs_joypad[b[0]] = want
			changed = true
	if ii.icon_set_override != "switch":
		ii.icon_set_override = "switch" # (emits icons_changed)
	elif changed:
		ii.emit_icons_changed()


# The game opens its on-screen keyboard only for a pad's confirm on a text field (GlobalUI._input skips InputEventKey:
# PC players type), and the handheld's A is a key here: open it the same way for that key, and keep the key from the
# text field (where confirm would mean "text entered").
func _input(event):
	if not (event is InputEventKey) or not event.pressed or event.echo or event.scancode != KB_KEYS[JOY_DS_A]:
		return
	var gui = get_node_or_null("/root/GlobalUI")
	if not gui or not gui.get("has_vk") or not gui.container:
		return
	var fo = gui.container.get_focus_owner()
	if not (fo is LineEdit):
		return
	var platform = get_node_or_null("/root/Platform")
	if not platform or platform.is_overlay_visible():
		return
	get_tree().set_input_as_handled()
	gui.focus_owner = weakref(fo)
	gui.vk_shown = true
	var max_length = fo.max_length if fo.max_length > 0 else 100
	platform.show_virtual_keyboard(fo.hint_tooltip, fo.text, max_length, Bind.new(fo, "set_text"))


func _bind_handheld_keys():
	for action in InputMap.get_actions():
		for e in InputMap.get_action_list(action):
			if e is InputEventJoypadButton and e.device == -1 and KB_KEYS.has(e.button_index):
				_bind_key(action, KB_KEYS[e.button_index])
	_bind_key("ui_accept", KB_KEYS[JOY_DS_A])
	_bind_key("ui_cancel", KB_KEYS[JOY_DS_B])


func _bind_key(action, scancode):
	for e in InputMap.get_action_list(action):
		if e is InputEventKey and e.scancode == scancode:
			return
	var k = InputEventKey.new()
	k.scancode = scancode
	InputMap.action_add_event(action, k)


func _install_keyboard():
	var platform = get_node_or_null("/root/Platform")
	if not platform or not platform.delegate:
		return
	var cur = platform.delegate.get_script()
	if not cur or cur.resource_path.get_basename() != "res://addons/platform/PlatformDelegate":
		_log("keyboard: platform delegate %s kept" % [str(cur.resource_path) if cur else "?"])
		return
	var d = load(get_script().resource_path.get_base_dir() + "/PortDelegate.gd").new()
	for s in ["friends_changed", "join_game_requested", "ugc_install_finished"]:
		d.connect(s, platform, "_on_" + s)
	platform.delegate = d
	var gui = get_node_or_null("/root/GlobalUI")
	if gui and "has_vk" in gui:
		gui.has_vk = true
	_log("keyboard: on-screen keyboard installed")


func _log(msg):
	var f = File.new()
	if f.open(LOG, File.READ_WRITE) != OK:
		f.open(LOG, File.WRITE)
	f.seek_end()
	f.store_line("%.1f	%s" % [OS.get_ticks_msec() / 1000.0, msg])
	f.close()


func _save():
	var c = ConfigFile.new()
	c.load(CFG)
	c.set_value("graphics", "aspect_mode", mode)
	c.set_value("graphics", "ui_size", ui_size)
	c.set_value("graphics", "low_tweaks", low_tweaks)
	c.set_value("graphics", "render_scale", render_scale)
	c.save(CFG)


func _apply_render_scale():
	var s = _rs_auto if render_scale == 0 else render_scale / 100.0
	ProjectSettings.set_setting("rendering/quality/3d_render_scale", s)


func _on_node_added(node):
	# splash: start the full load under the static logo, not at the end of the studio animation (SplashDefer.gd)
	if node.name == "LevelStreamer" and "force_synchronous_loading" in node:
		_install_streamer(node) # before its first update
		return
	if node.name == "SplashScreen":
		_log("SplashScreen node added, script %s" % [str(node.get_script().resource_path) if node.get_script() else "none"])
	# (the shipped scripts are compiled: the path ends in .gdc)
	if node.get_script() and node.get_script().resource_path.get_basename() == "res://menus/title/SplashScreen":
		var defer = load(get_script().resource_path.get_base_dir() + "/SplashDefer.gd")
		if defer:
			var cards = node.splash_cards
			node.set_script(defer)
			node.splash_cards = cards
			_log("splash script replaced (load under the boot splash image)")
		return
	# controller assignment screen: player 1's slot shows a handheld for the built-in controls (PortJoypadSlot.gd)
	if node.get_script() and node.get_script().resource_path.get_basename() == "res://menus/joypad_select/JoypadSlot":
		_swap_script(node, "PortJoypadSlot.gd")
	# the first steps' movement hint: no keyboard keys for the handheld (PortWASDHint.gd)
	if node.get_script() and node.get_script().resource_path.get_basename() == "res://world/ui/WASDHint":
		_swap_script(node, "PortWASDHint.gd")
	# (a check of its own: the menu-fit branch below also takes the settings menu)
	if node.get_script() and node.get_script().resource_path.get_basename() == "res://menus/settings/SettingsMenu":
		node.connect("ready", self, "_drop_keyboard_tab", [node], CONNECT_ONESHOT)
	if node.name == "GraphicsPanel" and node.get_script() and "GraphicsPanel" in node.get_script().resource_path:
		call_deferred("_inject", node)
	elif node.name == "TitleMenu" and "UPDATE_POPUPS" in node:
		_title_menu(node)
	elif node.name == "MapPauseMenu":
		_pause_menu(node)
	elif node is Control and ("overscan_container" in node or node.name == "FileMenu"):
		_menus.append(weakref(node))
		_fit_menu(node)
	elif node.name == "MessageBox" and node is VBoxContainer:
		_message_boxes.append(weakref(node))
		call_deferred("_fit_message_box", node)
	elif node.name == "CassettePlayer3D" and "flee_chance_label" in node:
		node.connect("ready", self, "_cassette_labels", [node], CONNECT_ONESHOT)
	elif node is ScrollContainer and node.get_script() and node.get_script().resource_path.get_basename().ends_with("AutoScrollContainer"):
		# scrolling settings panels get what the game's Keyboard panel has: the rows clipped at the panel's edge and the
		# game's own ScrollIndicator (blinking "more that way" tabs) over them
		# deferred: at "ready" the panel is still setting up its children and add_child on it is refused
		call_deferred("_scroll_indicator", node)
	elif node is TextureRect and node.material is ShaderMaterial and node.material.shader \
			and node.material.shader.resource_path.get_file() in SHRINK_SHADERS:
		# deferred: the intro scene is still adding its children
		call_deferred("_shrink_vortex", node)
	elif node is Sprite3D and node.texture is ViewportTexture:
		call_deferred("_shrink_sprite_viewport", node)
	elif node.get_script() and node.get_script().resource_path.get_basename().ends_with("NetInfoInviteCode"):
		node.connect("ready", self, "_hide_clipboard_note", [node], CONNECT_ONESHOT)


# Settings: no Keyboard section (key rebinding; the handhelds' pad is read as a gamepad, so keyboard bindings do
# nothing). SettingsMenu builds its tab list in _ready: the entry and its panel are removed right after, then the
# category labels are refreshed (Keyboard is the last tab, so the others keep their places)
func _drop_keyboard_tab(menu):
	if not is_instance_valid(menu) or not "tabs" in menu:
		return
	for i in range(menu.tabs.size() - 1, -1, -1):
		var tab = menu.tabs[i]
		if tab.get("name") == "UI_SETTINGS_KEYBOARD":
			if is_instance_valid(tab.get("node")):
				tab.node.queue_free()
			menu.tabs.remove(i)
	menu.current_index = int(clamp(menu.current_index, 0, max(menu.tabs.size() - 1, 0)))
	if menu.has_method("setup_tab"):
		menu.setup_tab()
	var names = []
	for tab in menu.tabs:
		names.append(str(tab.get("name")))
	_log("settings: sections %s" % str(names))


# online play: the invite code panel says the code was copied to the clipboard (true on PC, meaningless on a
# handheld): the note is hidden and its fade animation stopped (the game still copies the code)
func _hide_clipboard_note(node):
	if not is_instance_valid(node):
		return
	var ap = node.get_node_or_null("AnimationPlayer")
	if ap:
		ap.stop()
	var label = node.get("clipboard_label")
	if label is CanvasItem:
		label.visible = false


# Some bosses are a 2D scene drawn into an off-screen 2D viewport and shown on a billboard Sprite3D (Skeleton3D
# 1500x1250, machine3D_* 1350x920, Mammon3D 750x750: bigger than a 720p screen, every frame). The 3D viewport cap
# (viewports/max_3d_pixels) only covers 3D viewports. These get the 3D render scale too (0.5 off Snapdragon, 1.0 =
# unchanged there): the viewport keeps laying its 2D out at the original size
# (size override + stretch) at fewer pixels, and the sprite's pixel_size/offset compensate, so the boss keeps its
# size and place in the world.
const SPRITE_VIEWPORT_MIN_PIXELS = 250000


func _shrink_sprite_viewport(spr):
	if not is_instance_valid(spr) or not spr.is_inside_tree() or spr.has_meta("port_viewport_shrunk"):
		return
	var tex = spr.texture
	if not tex is ViewportTexture:
		return
	var vp = null
	for base in [spr.get_parent(), spr.owner]:
		if base and not vp:
			vp = base.get_node_or_null(tex.viewport_path)
	if not vp is Viewport or (vp.usage >= Viewport.USAGE_3D and not vp.disable_3d):
		return # 3D viewports: the engine's max_3d_pixels companion
	var s = float(ProjectSettings.get_setting("rendering/quality/3d_render_scale")) if ProjectSettings.has_setting("rendering/quality/3d_render_scale") else 1.0
	var orig = vp.size
	if s >= 0.99 or s <= 0.0 or orig.x * orig.y < SPRITE_VIEWPORT_MIN_PIXELS:
		return
	var small = (orig * s).round()
	vp.size = small
	vp.set_size_override(true, orig)
	vp.size_override_stretch = true
	var k = small.x / orig.x
	spr.pixel_size = spr.pixel_size / k
	spr.offset = spr.offset * k
	spr.set_meta("port_viewport_shrunk", true)
	_log("sprite viewport %s: %s -> %s" % [vp.get_path(), str(orig), str(small)])


# The warp tunnel behind character creation (NewGameIntro2.tscn "Background"; also the warp cutscenes) ray-marches up to 25 steps for every
# screen pixel each frame: the whole menu crawled on the TrimUI Smart Pro. Drawn into a viewport with VORTEX_SCALE
# of the screen's lines (port/vortex_lines = texture lines overrides, 0 = full size) and stretched with filtering
# over the same area instead: a quarter of the pixels, the same shader, animation and colours, softer streak edges.
# PC (llvmpipe, 1280x720): 17 -> 25 fps with the character creation menu up. Snapdragon (Adreno) keeps the full size: override_hi.cfg sets port/vortex_lines=0.
const VORTEX_SCALE = 0.5
# full-screen 2D backgrounds that get this treatment: the tunnel, and the animated fractal background of a few
# cutscenes (morgante_song_bg.shader: a 7-step loop per pixel; root TextureRect with the scene inside, like the warp
# cutscenes; its animated material track belongs to the glitch overlay child, not to this node)
const SHRINK_SHADERS = ["vortex_warp_canvas.shader", "morgante_song_bg.shader"]


func _shrink_vortex(bg):
	# (our own copy inside the small viewport comes through node_added too)
	if not is_instance_valid(bg) or not bg.is_inside_tree() or bg.get_viewport() != get_tree().root \
			or bg.get_node_or_null("PortVortex"):
		return
	# the game's 2D is laid out in 1920x1080-ish units, the small viewport's size is in those units too: shrink from
	# the node's height in units to the wanted texture lines (half the screen's real lines by default)
	var lines = OS.get_window_size().y * VORTEX_SCALE
	if ProjectSettings.has_setting("port/vortex_lines"):
		lines = int(ProjectSettings.get_setting("port/vortex_lines"))
	var shrink = int(round(bg.rect_size.y / max(lines, 1))) if lines > 0 else 1
	if shrink < 2:
		return
	# the small viewport goes INTO the original node, first child (under the rest), and the original stops drawing
	# itself: the warp cutscenes (BaseWarpZone.tscn) use the tunnel as their root, with the falling player inside
	var vc = ViewportContainer.new()
	vc.name = "PortVortex"
	vc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vc.anchor_right = 1.0
	vc.anchor_bottom = 1.0
	vc.stretch = true
	vc.stretch_shrink = shrink
	var vp = Viewport.new()
	vp.usage = Viewport.USAGE_2D
	vp.hdr = false
	vp.disable_3d = true
	vp.transparent_bg = false
	vp.gui_disable_input = true
	vp.render_target_update_mode = Viewport.UPDATE_ALWAYS
	var rect = TextureRect.new()
	rect.texture = bg.texture
	rect.expand = true
	rect.flip_h = bg.flip_h
	rect.flip_v = bg.flip_v
	rect.material = bg.material
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.add_child(rect)
	vc.add_child(vp)
	bg.add_child(vc)
	bg.move_child(vc, 0)
	vp.get_texture().flags = Texture.FLAG_FILTER
	bg.material = null
	bg.texture = null
	_log("%s drawn at 1/%d size (%s)" % [rect.material.shader.resource_path.get_file(), shrink, str(vp.size)])


const SCROLL_INDICATOR = "res://nodes/menus/ScrollIndicator.tscn"


func _scroll_indicator(sc):
	if not is_instance_valid(sc) or not sc.is_inside_tree():
		return
	# the panel around the scroller (as in KeyboardPanel.tscn: PanelContainer > ... > ScrollContainer)
	var panel = sc.get_parent()
	while panel and not panel is PanelContainer:
		panel = panel.get_parent()
	if not panel:
		return
	for p in [panel, panel.get_parent()]:
		if p:
			for c in p.get_children():
				if c.name == "ScrollIndicator":
					return # the game's own (Keyboard panel)
	var scene = load(SCROLL_INDICATOR)
	if not scene:
		return
	panel.rect_clip_content = true
	var ind = scene.instance()
	ind.name = "ScrollIndicator"
	panel.add_child(ind)
	ind.scroll_container = ind.get_path_to(sc)
	ind.raise()
	_log("scroll indicator added to %s" % panel.get_path())



# battle: the focused cassette button's name, readable (PortCassetteLabels.gd)
func _cassette_labels(player):
	var layer = player.get_node_or_null("CanvasLayer")
	if not layer:
		return
	var labels = load(get_script().resource_path.get_base_dir() + "/PortCassetteLabels.gd").new()
	labels.name = "PortCassetteLabels"
	layer.add_child(labels)
	var err = labels.setup(player)
	if err != "":
		_log("cassette labels: off (%s)" % err)
		labels.queue_free()


# title screen: no "what's new" update pop-ups on the first start (the DLC pop-ups, shown only to DLC owners, stay),
# and no store buttons (PortDelegate.has_store() is false; the Cassette Beasts 2 wishlist button checks the platform)
func _title_menu(node):
	var misc = UserSettings.misc_data
	for update in node.UPDATE_POPUPS:
		if not update.has("require_dlc") and not misc.has(update.flag):
			misc[update.flag] = true
	node.connect("ready", self, "_title_menu_ready", [node], CONNECT_ONESHOT)


# 16:9 or wider: letterbox, cropped and expanded view are the same picture
func wide_screen():
	var s = OS.window_size
	return s.y > 0 and s.x / s.y >= 1.7


func _title_menu_ready(node):
	var cb2 = node.store_btns.get("cb2") if "store_btns" in node else null
	if cb2:
		cb2.hide()
		node.version_container.setup_focus()
	# first start, once the title's buttons appear (after the game's own pop-ups): the aspect choice (screens
	# narrower than 16:9), then the shader preparation offer
	var buttons = node.get("buttons")
	if buttons and (_wants_aspect_choice() or _wants_low_tweaks_offer() or _wants_shader_offer()):
		buttons.connect("visibility_changed", self, "_first_run", [node, buttons])


func _first_value(key):
	var c = ConfigFile.new()
	c.load(CFG)
	return c.get_value("first_run", key, false)


func _set_first_value(key):
	var c = ConfigFile.new()
	c.load(CFG)
	c.set_value("first_run", key, true)
	c.save(CFG)


func _wants_aspect_choice():
	return not wide_screen() and not _first_value("aspect_choice")


# Ultra Low Tweaks explained once, on the handhelds where it is on by default (override_lo.cfg sets port/low_tweaks:
# RK3326 only), between the aspect choice and the shader offer; keeping it on is the default (also on B)
func _wants_low_tweaks_offer():
	return ProjectSettings.has_setting("port/low_tweaks") and ProjectSettings.get_setting("port/low_tweaks") == true \
			and not _first_value("low_tweaks_offer")


func _low_tweaks_offer(title):
	_set_first_value("low_tweaks_offer")
	var hidden = _hide_title_parts(title)
	yield(GlobalMessageDialog.show_message(tr("PORT_LT_OFFER"), false, false), "completed")
	var choice = yield(GlobalMenuDialog.show_menu(["PORT_LT_KEEP", "PORT_LT_OFF"], 0, 0), "completed")
	yield(GlobalMessageDialog.hide(), "completed")
	_on_low_tweaks_changed(0 if choice == 1 else 1, 0)
	_log("first start: Ultra Low Tweaks %s" % ("off" if choice == 1 else "kept on"))
	var path = "%s > %s > %s" % [tr("UI_SETTINGS"), tr("UI_SETTINGS_GRAPHICS"), tr("PORT_LOW_TWEAKS")]
	yield(GlobalMessageDialog.show_message(tr("PORT_LT_NOTE").format({"path": path})), "completed")
	for n in hidden:
		if is_instance_valid(n):
			n.show()


func _wants_shader_offer():
	if ProjectSettings.get_setting("rendering/gles3/shaders/shader_cache_sync") != true or _first_value("shader_offer"):
		return false
	var c = ConfigFile.new()
	c.load(CFG)
	return not c.get_value("shader_prep", "done", false)


func _first_run(title, buttons):
	if not is_instance_valid(title) or not buttons.visible:
		return
	buttons.disconnect("visibility_changed", self, "_first_run")
	yield(get_tree(), "idle_frame")
	if _wants_aspect_choice():
		_set_first_value("aspect_choice")
		var hidden = _hide_title_parts(title)
		var choice = load(get_script().resource_path.get_base_dir() + "/PortAspectChoice.gd").new()
		choice.path_text = "%s > %s > %s" % [tr("UI_SETTINGS"), tr("UI_SETTINGS_GRAPHICS"), tr("PORT_ASPECT")]
		get_tree().root.add_child(choice)
		var picked = yield(choice, "chosen")
		mode = int(picked)
		_apply()
		_save()
		_log("first start: aspect mode %d" % mode)
		for n in hidden:
			if is_instance_valid(n):
				n.show()
		yield(get_tree(), "idle_frame")
	if not is_instance_valid(title):
		return
	if _wants_low_tweaks_offer():
		yield(_low_tweaks_offer(title), "completed")
		yield(get_tree(), "idle_frame")
	if not is_instance_valid(title):
		return
	if _wants_shader_offer():
		_shader_offer(title)
	else:
		title.grab_focus()


# the title's buttons and its version / DLC list draw over the message box: hidden while it is up
func _hide_title_parts(title):
	var hidden = []
	if not is_instance_valid(title):
		return hidden
	for key in ["buttons", "version_container"]:
		var n = title.get(key)
		if n is CanvasItem and n.visible:
			n.hide()
			hidden.append(n)
	return hidden


func _shader_offer(title):
	_set_first_value("shader_offer")
	var hidden = _hide_title_parts(title)
	yield(GlobalMessageDialog.show_message(tr("PORT_OFFER"), false, false), "completed")
	var choice = yield(GlobalMenuDialog.show_menu(["PORT_OFFER_NOW", "PORT_OFFER_LATER"], 1), "completed")
	yield(GlobalMessageDialog.hide(), "completed")
	if choice != 0:
		yield(GlobalMessageDialog.show_message(tr("PORT_LATER_NOTE").format({"path": prep_path()})), "completed")
	if not is_instance_valid(title):
		return
	for n in hidden:
		if is_instance_valid(n):
			n.show()
	if choice == 0:
		_open_shader_prep(title)
	else:
		title.grab_focus()


# pause menu: the button column hangs from the top; on screens taller than 16:9 (the UI keeps its width and gains
# height) it is centred vertically; no overscan margin on the right
func _pause_menu(node):
	# the green stripe and the button column sit inside the TV overscan margin (129 units on the right at Large);
	# a handheld has no overscan: both go to the right edge and uncover that much more of the map
	for path in ["MenuHScroller/OverscanMarginContainer", "MenuVScroller/OverscanMarginContainer"]:
		var oc = node.get_node_or_null(path)
		if oc is MarginContainer and "horizontal_margin" in oc:
			oc.horizontal_margin = false # addons/misc_utils/OverscanMarginContainer.gd sets the margins from this
			oc.call_deferred("add_constant_override", "margin_right", 0)
			oc.call_deferred("add_constant_override", "margin_left", 0)
	var col = node.get_node_or_null("MenuVScroller/OverscanMarginContainer/MarginContainer")
	var size = get_viewport().size
	if col and size.x > 0 and size.y / size.x > 0.57:
		col.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _inject(panel):
	if not is_instance_valid(panel):
		return
	var inputs = panel.find_node("Inputs", true, false)
	if not inputs or inputs.has_node("UISizeInput"):
		return
	var tlabel = inputs.get_node_or_null("FrameRateLabel")
	var tinput = inputs.get_node_or_null("FrameRateInput")
	if not tlabel or not tinput:
		return
	var at = tinput.get_index() + 1
	if wide_screen(): # 16:9 or wider: the three modes look the same, no row
		at -= 2
	else:
		var label = tlabel.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
		label.name = "AspectLabel"
		label.text = "PORT_ASPECT"
		var input = tinput.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
		input.name = "AspectInput"
		input.values = [0, 1, 2]
		input.value_labels = MODES.duplicate()
		inputs.add_child(label)
		inputs.move_child(label, at)
		inputs.add_child(input)
		inputs.move_child(input, at + 1)
		input.selected_value = mode
		if input.has_method("adjust_min_size"):
			input.adjust_min_size()
		input.connect("value_changed", self, "_on_value_changed")
	var ulabel = tlabel.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
	ulabel.name = "UISizeLabel"
	ulabel.text = "PORT_UI_SIZE"
	var uinput = tinput.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
	uinput.name = "UISizeInput"
	uinput.values = range(UI_SIZES.size())
	uinput.value_labels = UI_LABELS.duplicate()
	inputs.add_child(ulabel)
	inputs.move_child(ulabel, at + 2)
	inputs.add_child(uinput)
	inputs.move_child(uinput, at + 3)
	uinput.selected_value = ui_size
	if uinput.has_method("adjust_min_size"):
		uinput.adjust_min_size()
	uinput.connect("value_changed", self, "_on_ui_size_changed")
	at += 2
	var rlabel = tlabel.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
	rlabel.name = "RenderScaleLabel"
	rlabel.text = "PORT_RENDER_SCALE"
	var rinput = tinput.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
	rinput.name = "RenderScaleInput"
	rinput.values = RS_VALUES.duplicate()
	var rlabels = ["%s (%d%%)" % [tr("PORT_AUTO"), int(round(_rs_auto * 100))]]
	for v in RS_VALUES.slice(1, RS_VALUES.size() - 1):
		rlabels.append("%d%%" % v)
	rinput.value_labels = rlabels
	inputs.add_child(rlabel)
	inputs.move_child(rlabel, at + 2)
	inputs.add_child(rinput)
	inputs.move_child(rinput, at + 3)
	rinput.selected_value = render_scale
	if rinput.has_method("adjust_min_size"):
		rinput.adjust_min_size()
	rinput.connect("value_changed", self, "_on_render_scale_changed")
	at += 2
	var llabel = tlabel.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
	llabel.name = "LowTweaksLabel"
	llabel.text = "PORT_LOW_TWEAKS"
	var linput = tinput.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
	linput.name = "LowTweaksInput"
	linput.values = [0, 1]
	linput.value_labels = ["PORT_OFF", "PORT_ON"]
	inputs.add_child(llabel)
	inputs.move_child(llabel, at + 2)
	inputs.add_child(linput)
	inputs.move_child(linput, at + 3)
	linput.selected_value = 1 if low_tweaks else 0
	if linput.has_method("adjust_min_size"):
		linput.adjust_min_size()
	linput.connect("value_changed", self, "_on_low_tweaks_changed")
	at += 2
	# "Shaders: Prepare" (PortShaderPrep.gd), only with the engine's program cache on
	if ProjectSettings.get_setting("rendering/gles3/shaders/shader_cache_sync") == true:
		var slabel = tlabel.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANCING)
		slabel.name = "ShaderPrepLabel"
		slabel.text = "PORT_SHADERS"
		var btn = Button.new()
		btn.name = "ShaderPrepButton"
		btn.focus_mode = Control.FOCUS_ALL
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.rect_min_size = Vector2(0, tinput.rect_size.y)
		btn.text = _shader_prep_text()
		inputs.add_child(slabel)
		inputs.move_child(slabel, at + 2)
		inputs.add_child(btn)
		inputs.move_child(btn, at + 3)
		btn.connect("pressed", self, "_open_shader_prep", [btn])
	# Fullscreen and Resolution do nothing on a handheld (the window is the screen): their rows go into an invisible
	# holder outside the grid, so the focus skips them while GraphicsPanel.gd still finds its inputs (it reads them
	# when saving and resetting; the values stay what they were)
	var holder = Control.new()
	holder.name = "PortHiddenRows"
	holder.visible = false
	panel.add_child(holder)
	for n in ["FullscreenLabel", "FullscreenInput", "ResolutionLabel", "ResolutionInput"]:
		var row = inputs.get_node_or_null(n)
		if row:
			inputs.remove_child(row)
			holder.add_child(row)
	if inputs.has_method("setup_focus"):
		inputs.setup_focus()


func _shader_prep_text():
	var c = ConfigFile.new()
	if c.load(CFG) == OK:
		if c.get_value("shader_prep", "done", false):
			return "PORT_PREP_DONE"
		if int(c.get_value("shader_prep", "next", 0)) > 0:
			return "PORT_PREP_CONTINUE"
	return "PORT_PREP_START"


# "Settings > Graphics > Shaders" in the game's own words for the first two
func prep_path():
	return "%s > %s > %s" % [tr("UI_SETTINGS"), tr("UI_SETTINGS_GRAPHICS"), tr("PORT_SHADERS")]


func _open_shader_prep(btn):
	if get_tree().root.has_node("PortShaderPrep"):
		return
	var prep = load(get_script().resource_path.get_base_dir() + "/PortShaderPrep.gd").new()
	prep.name = "PortShaderPrep"
	prep.connect("finished", self, "_shader_prep_closed", [btn])
	get_tree().root.add_child(prep)
	_log("shader prep: started")


# after a run (or a long part of one) a short result in the game's message box; the memory the run's shader
# variants held comes back by itself (variant eviction after 60 s + malloc_trim, override.cfg)
const PREP_NOTE_PERCENT = 20


func _shader_prep_closed(completed, percent, btn):
	_log("shader prep: closed (%s, %d%%)" % ["completed" if completed else "stopped", percent])
	if is_instance_valid(btn) and btn is Button:
		btn.text = _shader_prep_text()
	# from the settings row: a note after a long run; from the first-start offer (btn = the title menu): always, with
	# where to find it again
	var from_offer = not btn is Button
	if completed or percent >= PREP_NOTE_PERCENT or from_offer:
		var gmd = get_node_or_null("/root/GlobalMessageDialog")
		if gmd and gmd.has_method("show_message"):
			var msg = tr("PORT_ALL_DONE")
			var args = {"percent": percent, "path": prep_path()}
			if not completed and not from_offer:
				msg = tr("PORT_STOPPED_AGAIN").format(args)
			elif not completed and percent > 0:
				msg = tr("PORT_STOPPED_PATH").format(args)
			elif not completed:
				msg = tr("PORT_LATER_NOTE").format(args)
			var hidden = _hide_title_parts(btn) if from_offer else []
			var co = gmd.show_message(msg)
			if co is GDScriptFunctionState:
				yield(co, "completed")
			for n in hidden:
				if is_instance_valid(n):
					n.show()
	if is_instance_valid(btn) and btn.is_inside_tree():
		btn.call_deferred("grab_focus")


func _on_low_tweaks_changed(value, _index):
	low_tweaks = int(value) == 1
	_apply_low_physics()
	_apply_low_stream(_streamer)
	_save()


func _on_render_scale_changed(value, _index):
	render_scale = int(value)
	_apply_render_scale()
	_log("3D resolution: %s" % ("auto (%.3f)" % _rs_auto if render_scale == 0 else "%d%%" % render_scale))
	_save()


func _on_ui_size_changed(value, _index):
	ui_size = int(value)
	_apply_ui_size()
	_save()


func _on_value_changed(value, _index):
	mode = int(value)
	_apply()
	_save()
