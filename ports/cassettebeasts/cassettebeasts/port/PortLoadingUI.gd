extends "res://global/scene_manager/LoadingUI.gd"
# Cassette Beasts port: the game's loading screen controller. The game chains the steps of its full load (datatables,
# monsters, moves, ...) through deferred calls that all run inside one frame, so nothing is drawn until the load
# ends. While frame_per_task is set (SplashDefer.gd, during the load under the key art) each step first waits for
# one frame, so the splash's progress bar is drawn between steps (~20 frames more). Installed by SplashDefer.gd
# (set_script, keeping the node's values). License: 0BSD.

var frame_per_task = false


func run_task(message: String, promise, task_index: int):
	if frame_per_task:
		yield(get_tree(), "idle_frame")
	var co = .run_task(message, promise, task_index)
	if co is GDScriptFunctionState:
		return yield(co, "completed")
	return co
