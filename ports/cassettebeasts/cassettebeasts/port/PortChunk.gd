extends "res://addons/level_streamer/Chunk.gd"
# Cassette Beasts port: the game's level-streaming chunk, set up on the main thread when PortLevelStreamer.gd gets
# to it (one per frame, nearest first) instead of on the JobQueue thread (instancing chunk scenes there crashes on
# the handhelds), and reporting its steps so the streamer can fill chunks within a time budget. With the port's
# engine (apply_instance_steps.py: PackedScene.instance_begin) the chunk scene itself is built a few milliseconds
# per frame (step_setup) instead of in one ~100 ms instance() call. Used by PortLevelStreamer.load_chunk.
# License: 0BSD.

# Ultra Low Tweaks exemptions (observe_split): these chunks keep their details for as long as their terrain is shown.
# Overworld_0_-1 = Harbourtown's Town Hall with the square's benches, planters and notice board in front of it (also the
# Tailor and two houses on its west side): the intro cutscene pans over it, and from the square the hall and its props
# popped in and out at the 50 m detail edge (user, R36S, 2026-10-11).
const FULL_DETAIL_CHUNKS = ["Overworld_0_-1"]

var streamer = null
var pending = false
var _running_setup = false
var _stepper = null # PackedSceneStepper while the chunk scene is being built


func setup():
	if not synchronous and not _running_setup and streamer and streamer.has_method("queue_setup"):
		pending = true
		streamer.queue_setup(self)
		return
	var was = synchronous
	synchronous = true # the game's own main-thread path (used for warps and the first frame)
	.setup()
	synchronous = was


# a slice of the set-up within p_budget_usec; true when the chunk is set up
func step_setup(p_budget_usec) -> bool:
	if not pending:
		return true
	if not _stepper and chunk_res is PackedScene and chunk_res.has_method("instance_begin"):
		_stepper = chunk_res.instance_begin()
	if _stepper and not _stepper.step(p_budget_usec):
		return false
	run_setup()
	return true


func run_setup():
	if not pending:
		return
	if _stepper: # needed now (warp, guard): build the rest at once
		var node = _stepper.get_node()
		_stepper = null
		if node:
			chunk_res = node # the game's set-up takes a built scene as well (_setup_chunk_task_load)
	pending = false
	_running_setup = true
	setup()
	_running_setup = false


func insert_all():
	run_setup() # warps and the port's guard need the chunk now
	.insert_all()


# not set up yet: no children at all (the game's check reads the last child)
func is_empty() -> bool:
	return pending or .is_empty()


# freed before its set-up: the game's version waits for setup_completed, which would never come
func free_chunk():
	if pending:
		pending = false
		_stepper = null # frees what it built
		chunk_res = null
		queue_free()
		return
	return .free_chunk()


func insert_terrain() -> bool:
	var r = .insert_terrain()
	if r and streamer:
		streamer.stream_work += 1
	return r


func insert_one_detail(point: Vector3) -> bool:
	var r = .insert_one_detail(point)
	if r and streamer:
		streamer.stream_work += 1
	return r


func remove_one_detail() -> void:
	var n = get_child_count()
	.remove_one_detail()
	if streamer and get_child_count() != n:
		streamer.stream_work += 1


# Chunk.observe with separate boxes for the terrain (t_outer / t_mid: the camera's full view) and the details (d_inner
# / d_mid: a shorter view, PortLevelStreamer.detail_far): far chunks show their ground and base mesh, their props and
# NPCs come in nearer. Same steps as the game's version otherwise.
func observe_split(t_outer: AABB, t_mid: AABB, d_inner: AABB, d_mid: AABB, point: Vector3, synchronous: bool) -> bool:
	if not terrain:
		return false
	# chunks whose details come and go with their terrain (the full distance) even under the shorter detail distance
	if name in FULL_DETAIL_CHUNKS:
		d_inner = t_mid
		d_mid = t_outer
	var over_t_mid = aabb.intersects(t_mid)
	var over_d_inner = aabb.intersects(d_inner)
	if over_t_mid and synchronous:
		if over_d_inner:
			insert_all()
		else:
			insert_terrain()
		return true
	var can_remove = Engine.editor_hint or WorldSystem.flags == WorldSystem.INITIAL_FLAGS
	var last_child = get_child(get_child_count() - 1)
	if last_child == static_body:
		return over_t_mid and insert_terrain()
	if over_d_inner:
		return insert_one_detail(point)
	if can_remove:
		if last_child == terrain:
			if not aabb.intersects(t_outer):
				remove_terrain()
		elif not aabb.intersects(d_mid):
			remove_one_detail()
	return false
