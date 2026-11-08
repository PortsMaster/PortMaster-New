extends CanvasLayer
# Cassette Beasts port: "Prepare shaders" (Settings > Graphics). Goes through the game's scenes and resources one
# file at a time, draws every material once on a hidden quad so the engine compiles its shader into the on-disk
# program cache (apply_shader_cache_sync.py), and frees the file before the next: afterwards a material seen for
# the first time loads its compiled shader instead of stalling the game for half a second. A shader's variant depends
# on the lights and environment around it (sun, fog, sky), so every material is drawn in two hidden viewports with
# worlds of their own, lit by the game's own lighting scenes: the Overworld's (WorldDayNightCycle.tscn: sun and
# world_camera_env_daylight) and the battles' (BattleDayNightCycle.tscn), at the current time of day and weather,
# with the sun's shadows as set in Graphics. So it prepares the variants the world and battles use wherever it is
# started (title screen or pause menu). Survey of the pack: every Environment has a sky (radiance map on
# everywhere), so lights are what tell variants apart: the Overworld sun follows Graphics > Shadows (off on the
# handhelds), the battle sun and 139 other directional lights (battles, caves, interiors, dungeons) always cast
# simple orthogonal shadows - the two lighting scenes cover both; omni/spot lights add no variant (no shadow atlas).
# Not covered: 4 small maps without a directional light, 1 with split shadows (Hospital).
# Geometry matters too: imported meshes (and QuadMesh) store octahedral-compressed normals, while Sprite3D and
# AnimatedSprite3D (characters, NPCs, monsters, many props) draw through immediate geometry, which never uses that
# variant: every 3D material is drawn both ways (plus instanced where the game's ShaderCache would).
# The game's 2D shaders are drawn behind this screen.
# The screen is the game's own: its loading screen (global/scene_manager/LoadingUI.tscn, dark, with the
# "UI_LOADING_SHADER_PROGRESS" text and the teal bar it shows for its own shader precompile) and the menus' prompt
# bar (menus/BackButtonPanel.tscn) for stopping. Stopping keeps the place in user://port_options.cfg; the next run
# continues there. Opened by PortOptions.gd. License: 0BSD.

signal finished(completed, percent) # PortOptions shows the restart note

const CFG = "user://port_options.cfg"
const EXTS = ["tscn", "scn", "tres", "res", "material", "mesh"]
# world/maps: 5-20 s per file on a PC (every prop and mesh loaded again) and no shader of their own beyond the props
# and models compiled from their own files (PC run: no new program over 150 map files); data/region_settings
# (0.5-1.5 s each, they pull in battle backgrounds and environments, done from their own files) and the developers'
# tools/ test scenes: 110 of 545 s on a PC
const SKIP_DIRS = ["res://.import", "res://music", "res://sfx", "res://translation", "res://fonts", "res://mods",
		"res://world/maps", "res://data/region_settings", "res://tools"]
const MAX_DEPS = 150 # maps that preload every chunk (Overworld): their chunks are separate files anyway
const MATS_PER_FRAME = 6
const FRAME_BUDGET_US = 120000
const LIGHTING = ["res://nodes/day_night_cycle/WorldDayNightCycle.tscn", "res://nodes/day_night_cycle/BattleDayNightCycle.tscn"]
const CONTEXT_MESH = 1
const CONTEXT_MULTIMESH = 2
const LOADING_UI = "res://global/scene_manager/LoadingUI.tscn"
const PROMPT_BAR = "res://menus/BackButtonPanel.tscn"
const STOP_KEYS = ["UI_BUTTON_STOP", "UI_BUTTON_CANCEL"]

var paths = []
var next_index = 0
var drawn = 0
var _state = "scan"
var _dirs = []
var _seen_mats = {}
var _mats = [] # [material, context]
var _res = null
var _drawn_nodes = []
var _t_start = 0
var _quad = null
var _multimesh = null
var _worlds = [] # where the 3D materials are drawn: one Spatial per lighting world
var _layer2d = null
var _loading = null
var _promise = null
var _done_t = 0.0


func _ready():
	layer = 126
	pause_mode = Node.PAUSE_MODE_PROCESS
	_build_ui()
	_quad = QuadMesh.new()
	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.mesh = _quad
	_multimesh.instance_count = 1
	_multimesh.set_instance_transform(0, Transform())
	for path in LIGHTING:
		var lighting = load(path)
		if not lighting:
			continue
		var vp = Viewport.new()
		vp.size = Vector2(64, 64)
		vp.own_world = true
		vp.usage = Viewport.USAGE_3D_NO_EFFECTS
		vp.hdr = false
		vp.msaa = Viewport.MSAA_DISABLED
		vp.render_target_update_mode = Viewport.UPDATE_ALWAYS
		add_child(vp)
		vp.add_child(lighting.instance())
		var base = Spatial.new()
		vp.add_child(base)
		var cam = Camera.new()
		cam.translation = Vector3(0, 0, 2)
		base.add_child(cam)
		cam.make_current()
		_worlds.append(base)
	_layer2d = CanvasLayer.new()
	_layer2d.layer = -128 # the game's own precompile draws its 2D materials here too (under everything)
	add_child(_layer2d)
	var c = ConfigFile.new()
	if c.load(CFG) == OK:
		next_index = int(c.get_value("shader_prep", "next", 0))
	_dirs = ["res://"]
	_t_start = OS.get_ticks_msec()


func _build_ui():
	var back = ColorRect.new()
	back.color = Color.black # where the game's fade to a loading screen ends
	back.anchor_right = 1.0
	back.anchor_bottom = 1.0
	add_child(back)
	_loading = load(LOADING_UI).instance()
	add_child(_loading)
	_loading.set_dark_mode(true)
	_loading.start(1, false) # no joke lines: the shader text with its counts, as in the game's precompile
	_promise = Promise.new()
	_promise.progress_max = 1
	_loading.run_task("UI_LOADING_SHADER_PROGRESS", _promise, 0)
	var bar = load(PROMPT_BAR).instance()
	var stop = "Stop"
	for k in STOP_KEYS:
		if tr(k) != k:
			stop = k
			break
	bar.back_text_override = stop
	add_child(bar)


# the prompt bar calls this when its button is pressed
func cancel():
	_finish()


func _input(event):
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventAction:
		get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_cancel"):
			_finish()


func _process(_d):
	match _state:
		"scan":
			_scan_step()
		"work":
			_work_step()
		"done":
			if OS.get_ticks_msec() / 1000.0 - _done_t > 1.5:
				_finish()


func _scan_step():
	var t0 = OS.get_ticks_usec()
	while not _dirs.empty() and OS.get_ticks_usec() - t0 < FRAME_BUDGET_US:
		var dir_path = _dirs.pop_back()
		var d = Directory.new()
		if d.open(dir_path) != OK:
			continue
		d.list_dir_begin(true, true)
		var f = d.get_next()
		var found = {}
		while f != "":
			var full = dir_path.plus_file(f)
			if d.current_is_dir():
				if not full in SKIP_DIRS:
					_dirs.append(full)
			else:
				if f.ends_with(".remap"):
					full = full.get_basename()
				if full.get_extension() in EXTS:
					found[full] = true
			f = d.get_next()
		d.list_dir_end()
		for p in found:
			paths.append(p)
	if _dirs.empty():
		paths.sort()
		if next_index >= paths.size():
			next_index = 0
		_promise.progress_max = max(1, paths.size())
		_promise.progress = next_index
		_state = "work"


func _work_step():
	# what was added last frame has been drawn (and its shaders compiled): free it
	for n in _drawn_nodes:
		n.queue_free()
	_drawn_nodes.clear()
	var t0 = OS.get_ticks_usec()
	var added = 0
	while added < MATS_PER_FRAME and OS.get_ticks_usec() - t0 < FRAME_BUDGET_US:
		if _mats.empty():
			_res = null
			if next_index >= paths.size():
				_done()
				return
			var p = paths[next_index]
			next_index += 1
			if ResourceLoader.get_dependencies(p).size() > MAX_DEPS:
				continue
			var tl = OS.get_ticks_usec()
			_res = ResourceLoader.load(p)
			_collect(_res, CONTEXT_MESH)
			_note_time(p, OS.get_ticks_usec() - tl)
			continue
		var item = _mats.pop_front()
		if _draw(item[0], item[1]):
			added += 1
	_promise.progress = next_index


# load time per folder (two levels below res://), printed to the log when the run ends or stops
var _folder_us = {}
var _folder_n = {}


func _note_time(p, us):
	var parts = p.substr(6).split("/")
	var folder = parts[0] + ("/" + parts[1] if parts.size() > 2 else "")
	_folder_us[folder] = _folder_us.get(folder, 0) + us
	_folder_n[folder] = _folder_n.get(folder, 0) + 1
	if us > 500000:
		print("shader prep: slow load %d ms %s" % [us / 1000, p])


func _print_times():
	var rows = _folder_us.keys()
	rows.sort_custom(self, "_slower")
	for k in rows.slice(0, min(rows.size(), 25) - 1):
		print("shader prep: %6d ms %4d files %s" % [_folder_us[k] / 1000, _folder_n[k], k])


func _slower(a, b):
	return _folder_us[a] > _folder_us[b]


func _is_spatial(m):
	return m is SpatialMaterial or (m is ShaderMaterial and m.shader and m.shader.get_mode() == Shader.MODE_SPATIAL)


func _is_particles(m):
	return m is ParticlesMaterial or (m is ShaderMaterial and m.shader and m.shader.get_mode() == Shader.MODE_PARTICLES)


func _is_canvas(m):
	return m is CanvasItemMaterial or (m is ShaderMaterial and m.shader and m.shader.get_mode() == Shader.MODE_CANVAS_ITEM)


func _queue_mat(m, context):
	if not m is Material:
		return
	var key = "%s:%d" % [_shader_key(m), context]
	if _seen_mats.has(key):
		return
	_seen_mats[key] = true
	_mats.append([m, context])


# materials that compile to the same shader count once: a ShaderMaterial by its shader (parameters are uniforms),
# the built-in materials by what their generated shader depends on (flags, modes, feature switches and which
# texture slots are used; colours and numbers are uniforms)
func _shader_key(m):
	if m is ShaderMaterial:
		return "S%d" % (m.shader.get_instance_id() if m.shader else 0)
	var key = m.get_class()
	for prop in m.get_property_list():
		if not prop.usage & PROPERTY_USAGE_STORAGE:
			continue
		var v = m.get(prop.name)
		if v is bool or v is int:
			key += "|%s=%s" % [prop.name, str(v)]
		elif prop.type == TYPE_OBJECT and prop.name != "next_pass":
			key += "|%s=%s" % [prop.name, "1" if v else "0"]
	return key


func _queue_mesh(mesh, context):
	if not mesh is Mesh:
		return
	for i in mesh.get_surface_count():
		_queue_mat(mesh.surface_get_material(i), context)


# like the game's ShaderCache: scenes with particle materials need the instanced (multimesh) variants too,
# MeshLibrary meshes (GridMap terrain) only those
func _collect(res, context):
	if res == null:
		return
	if res is PackedScene:
		var variants = res._bundled.get("variants", [])
		var particles = 0
		for v in variants:
			if _is_particles(v):
				particles += 1
		var ctx = CONTEXT_MESH | (CONTEXT_MULTIMESH if particles > 0 else 0)
		for v in variants:
			if v is PackedScene:
				continue # its own file, done on its own
			if v is Resource:
				_collect(v, ctx)
	elif res is Material:
		_queue_mat(res, context)
		if res.next_pass:
			_queue_mat(res.next_pass, context)
	elif res is Mesh:
		_queue_mesh(res, context)
	elif res is MeshLibrary:
		for id in res.get_item_list():
			_queue_mesh(res.get_item_mesh(id), CONTEXT_MULTIMESH)


# a quad drawn the way Sprite3D draws (immediate geometry, uncompressed normals)
func _immediate_quad(m):
	var g = ImmediateGeometry.new()
	g.material_override = m
	g.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, 0.5)]:
		g.set_normal(Vector3(0, 0, 1))
		g.set_tangent(Plane(1, 0, 0, 1))
		g.set_color(Color.white)
		g.set_uv(Vector2(v.x + 0.5, 0.5 - v.y))
		g.add_vertex(Vector3(v.x, v.y, 0))
	g.end()
	return g


func _draw(m, context):
	if _is_spatial(m):
		for w in _worlds:
			if context & CONTEXT_MESH:
				var n = MeshInstance.new()
				n.mesh = _quad
				n.material_override = m
				w.add_child(n)
				_drawn_nodes.append(n)
				var g = _immediate_quad(m)
				w.add_child(g)
				_drawn_nodes.append(g)
			if context & CONTEXT_MULTIMESH:
				var mm = MultiMeshInstance.new()
				mm.multimesh = _multimesh
				mm.material_override = m
				w.add_child(mm)
				_drawn_nodes.append(mm)
	elif _is_particles(m):
		for w in _worlds:
			var p = Particles.new()
			p.amount = 1
			p.emitting = true
			p.process_material = m
			p.draw_pass_1 = _quad
			w.add_child(p)
			_drawn_nodes.append(p)
	elif _is_canvas(m):
		var s = Sprite.new()
		s.texture = preload("res://icon.png")
		s.material = m
		_layer2d.add_child(s)
		_drawn_nodes.append(s)
	else:
		return false
	drawn += 1
	return true


func _save():
	var c = ConfigFile.new()
	c.load(CFG)
	c.set_value("shader_prep", "next", next_index if next_index < paths.size() else 0)
	c.set_value("shader_prep", "done", next_index >= paths.size() and paths.size() > 0)
	c.save(CFG)


func _done():
	_state = "done"
	_done_t = OS.get_ticks_msec() / 1000.0
	next_index = paths.size()
	_promise.progress = next_index
	_save()


func _finish():
	if _state == "closed":
		return
	_print_times()
	if _state != "done":
		_save()
	_state = "closed"
	for n in _drawn_nodes:
		n.queue_free()
	_drawn_nodes.clear()
	_mats.clear()
	_res = null
	if _promise and not _promise.ready:
		_promise.fulfill(null)
	if _loading:
		_loading.stop()
	var completed = next_index >= paths.size() and paths.size() > 0
	emit_signal("finished", completed, int(100.0 * next_index / max(1, paths.size())))
	queue_free()
