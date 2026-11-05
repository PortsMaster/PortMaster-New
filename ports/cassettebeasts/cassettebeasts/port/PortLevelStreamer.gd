extends "res://addons/level_streamer/LevelStreamer.gd"
# Cassette Beasts port: the game's level streamer with the work spread over frames. The game fills a chunk one
# detail (building, prop, NPC) per frame and sets new chunks up on its JobQueue thread; on a handheld at 30 fps the
# first is too slow (the town stays half built) and the second crashes, so the port used the synchronous mode, where
# every chunk coming into range is instanced and filled in one frame: a hitch while walking. Here new chunks are set
# up on the main thread one per frame (nearest first, PortChunk.gd) and details go in nearest first until BUDGET_US
# of work in the frame; the first frame and warps stay synchronous as in the game. Chunks the game drops are kept
# in a small memory-bounded cache (see CACHE_MAX). Installed by PortOptions.gd
# (set_script, keeping the scene's settings). License: 0BSD.

const BUDGET_US = 4000
const SETUP_US = 5000 # chunk scene building per frame (PortChunk.step_setup)
const MAX_STEPS = 400
const LOG_MS = 15
# Chunk cache: a chunk the game drops (terrain out of range) is kept out of the tree instead of freed, so walking
# back is a cheap re-add instead of instancing the chunk scene again (40-120 ms on the RG Cube XX, measured for all
# 128 Overworld chunks; ~5.6 MB each kept). Bounded by count and by free memory (battles need their headroom).
const CACHE_MAX = 8
const CACHE_MIN_AVAIL_MB = 200 # cache a dropped chunk only above this
const CACHE_PRUNE_AVAIL_MB = 160 # drop cached chunks (oldest first) below this
const CACHE_CHECK_MSEC = 2000

var stream_work = 0
var detail_far = 0.0 # > 0: details (props, NPCs) only this far ahead, terrain to camera_far_distance (PortOptions.gd)
var log_target = null # PortOptions (its _log)
var detail_keep = null # with detail_far: the box outside which details are removed (d_mid); PortOptions' stream guard
# completes only chunks that touch it, else the guard and this streamer took turns (a building flashing in and out
# every 2.4 s while the player stood still, R36S log 2026-10-11)
var _pending = []
var _building = null # the chunk being built over frames
var _building_us = 0
var _chunk_script = null
var _cache = {} # chunk index -> chunk (out of the tree)
var _cache_order = [] # oldest first
var _cache_checked = 0
var cache_hits = 0
var cache_max = CACHE_MAX


func queue_setup(chunk):
	_pending.append(chunk)


# LevelStreamer.load_chunk with the port's Chunk subclass; a cached chunk comes back as it was left
func load_chunk(index: Vector2, synchronous: bool):
	if _cache.has(index):
		var c = _cache[index]
		_cache.erase(index)
		_cache_order.erase(index)
		if is_instance_valid(c):
			chunks[index] = c
			cache_hits += 1
			if log_target:
				log_target._log("stream: %s back from the cache (%d cached, %d MB available)" % [c.name, _cache.size(), _avail_mb()])
			return c
	if not _chunk_script:
		_chunk_script = load(get_script().resource_path.get_base_dir() + "/PortChunk.gd")
	var res_name = chunk_name_format % [str(int(index.x)), str(int(index.y))]
	var chunk = _chunk_script.new()
	chunk.streamer = self
	chunk.name = res_name
	chunk.chunk_size = chunk_size
	chunk.vertical_extent = vertical_extent
	chunk.roaming_collision_mask = roaming_collision_mask
	chunk.empty_static_collision_mask = empty_static_collision_mask
	chunk.partial_static_collision_mask = partial_static_collision_mask
	chunk.synchronous = synchronous
	chunk.transform.origin = chunk_pos(index)
	if instances.has(res_name):
		chunk.chunk_res = instances[res_name]
		instances.erase(res_name)
	else:
		if has_chunk(res_name):
			chunk.chunk_res = get_chunk(res_name)
		else:
			chunk.chunk_res = oob_chunk
		chunk.connect("removed_terrain", self, "_erase_chunk", [index, chunk])
	chunks[index] = chunk
	return chunk


# LevelStreamer._erase_chunk (the chunk's removed_terrain signal): keep the chunk instead of freeing it
func _erase_chunk(index: Vector2, chunk):
	if chunks.get(index) == chunk:
		chunks.erase(index)
	if cache_max > 0 and is_instance_valid(chunk) and not chunk.pending and _avail_mb() >= CACHE_MIN_AVAIL_MB:
		if chunk.get_parent():
			chunk.get_parent().remove_child(chunk)
		_cache[index] = chunk
		_cache_order.append(index)
		while _cache_order.size() > cache_max:
			_drop_oldest()
	else:
		chunk.free_chunk()


func _drop_oldest():
	var index = _cache_order.pop_front()
	var c = _cache.get(index)
	_cache.erase(index)
	if is_instance_valid(c):
		c.free_chunk()


func _avail_mb():
	var f = File.new()
	if f.open("/proc/meminfo", File.READ) != OK:
		return 100000 # not Linux: no limit
	var mb = 100000
	while not f.eof_reached():
		var line = f.get_line()
		if line.begins_with("MemAvailable:"):
			mb = int(line.split(":")[1].strip_edges().split(" ")[0]) / 1024
			break
	f.close()
	return mb


func _prune_cache():
	if _cache.empty():
		return
	var now = OS.get_ticks_msec()
	if now - _cache_checked < CACHE_CHECK_MSEC:
		return
	_cache_checked = now
	var avail = _avail_mb()
	var n = 0
	while not _cache_order.empty() and avail < CACHE_PRUNE_AVAIL_MB:
		_drop_oldest()
		n += 1
		if n >= 2:
			break # a few per check: freeing is not free either
	if n and log_target:
		log_target._log("stream: %d MB available, dropped %d cached chunks (%d left)" % [avail, n, _cache.size()])


# cached chunks are not in the tree, so the scene's freeing_scene path never reaches them; leaving the tree (a
# battle or menu pushed over the Overworld, or the scene freed) gives their memory back
func _notification(what):
	if what == NOTIFICATION_EXIT_TREE or what == NOTIFICATION_PREDELETE:
		clear_cache()


func clear_cache():
	if _cache.empty():
		return
	if log_target and is_instance_valid(log_target):
		log_target._log("stream: freeing %d cached chunks" % _cache.size())
	for index in _cache:
		var c = _cache[index]
		if is_instance_valid(c):
			c.free_chunk()
	_cache.clear()
	_cache_order.clear()


func _setup_next(point: Vector3):
	if is_instance_valid(_building) and _building.pending:
		_step_building()
		return
	_building = null
	var best = -1
	var best_d = INF
	for i in range(_pending.size() - 1, -1, -1):
		var c = _pending[i]
		if not is_instance_valid(c) or not c.pending:
			_pending.remove(i)
			# entries after i moved down by one: so did the best one found so far (was a stale index: wrong chunk or
			# "Invalid get index" past the end, PC log 2026-10-11)
			if best > i:
				best -= 1
			continue
		var d = c.transform.origin.distance_squared_to(point)
		if d < best_d:
			best_d = d
			best = i
	if best < 0:
		return
	_building = _pending[best]
	_pending.remove(best)
	_building_us = 0
	_step_building()


func _step_building():
	var t0 = OS.get_ticks_usec()
	var done = _building.step_setup(SETUP_US)
	var us = OS.get_ticks_usec() - t0
	_building_us += us
	if us / 1000 >= LOG_MS and log_target:
		log_target._log("stream: %s step %d ms" % [_building.name, us / 1000])
	if done:
		if _building_us / 1000 >= LOG_MS and log_target:
			log_target._log("stream: set up %s in %d ms" % [_building.name, _building_us / 1000])
		_building = null


func observe(camera: Camera, viewport: Viewport, synchronous: bool = false):
	if synchronous:
		_observe(camera, viewport, true)
		return
	var t0 = OS.get_ticks_usec()
	var point = camera.global_transform.origin
	point.y = 0.0
	_prune_cache()
	if not _pending.empty() or is_instance_valid(_building): # the chunk being built has left _pending
		_setup_next(point)
	var steps = 0
	while true:
		stream_work = 0
		_observe(camera, viewport, false)
		steps += 1
		if stream_work == 0 or steps >= MAX_STEPS or OS.get_ticks_usec() - t0 >= BUDGET_US:
			break
	var ms = (OS.get_ticks_usec() - t0) / 1000
	if ms >= LOG_MS and log_target:
		log_target._log("stream: frame %d ms, %d steps, %d chunks waiting" % [ms, steps, _pending.size()])


# LevelStreamer.observe, or with detail_far set the same with two view boxes: the terrain from the full camera
# distance, the details from detail_far (PortChunk.observe_split)
func _observe(camera: Camera, viewport: Viewport, synchronous: bool):
	if detail_far <= 0.0:
		detail_keep = null
		.observe(camera, viewport, synchronous)
		return
	var boundary = _check_boundaries()
	if boundary:
		swap_boundary(boundary)
		return
	var aabb = get_view_bounds(camera, viewport)
	var far = camera_far_distance
	camera_far_distance = detail_far
	var aabb_d = get_view_bounds(camera, viewport)
	camera_far_distance = far
	var t_mid = aabb.grow(mid_margin)
	var t_outer = aabb.grow(outer_margin)
	var d_inner = aabb_d.grow(inner_margin)
	var d_mid = aabb_d.grow(mid_margin)
	detail_keep = d_mid
	var instance_aabb = aabb.grow(instance_margin)
	var x_min = round(instance_aabb.position.x / chunk_size.x)
	var x_max = round(instance_aabb.end.x / chunk_size.x)
	var z_min = round(instance_aabb.position.z / chunk_size.y)
	var z_max = round(instance_aabb.end.z / chunk_size.y)
	for x in range(x_min, x_max + 1):
		for z in range(z_min, z_max + 1):
			var index = Vector2(x, z)
			if not _matches_current_boundary(index):
				continue
			if not chunks.has(index):
				level.add_child(load_chunk(index, synchronous))
			if not hot_chunks.has(index):
				hot_chunks.push_front(index)
	var point = camera.global_transform.origin
	for i in range(hot_chunks.size() - 1, -1, -1):
		var index = hot_chunks[i]
		var chunk = chunks[index]
		var worked = chunk.observe_split(t_outer, t_mid, d_inner, d_mid, point, synchronous) if chunk.has_method("observe_split") \
				else chunk.observe(t_outer, t_mid, d_inner, point, synchronous)
		if worked and not synchronous:
			hot_chunks.remove(i)
			hot_chunks.push_front(index)
			break
		elif chunk.is_empty():
			hot_chunks.remove(i)
