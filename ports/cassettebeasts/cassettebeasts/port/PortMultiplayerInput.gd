extends "res://global/MultiplayerInput.gd"
# Cassette Beasts port: the handheld's controls arrive as keys (gptokeyb2), so the handheld is the game's keyboard
# player, always player 1, and every pad the game sees is an extra (co-op) pad. The PC game makes the first pad
# player 1 as well: when it connects as device 0, and when the title screen's "Press A" comes from the keyboard
# (reset_joypad_players with no device). Here pads start without a player and join on the controller screen; a pad
# pressing A on the title still takes player 1 as in the PC game. Installed by PortOptions.gd. License: 0BSD.


# the game's version for a connected pad, minus "device 0 = player 1"
func _on_joy_connection_changed(device: int, connected: bool):
	if not connected:
		._on_joy_connection_changed(device, connected)
		return
	print("Device " + str(device) + " connected: " + Input.get_joy_name(device) + " " + Input.get_joy_guid(device))
	configure_device(device)
	if HANDHELD_DEVICE_NAMES.has(Input.get_joy_name(device)):
		handheld_device = device
	set_joypad_player(device, 0 if device == handheld_device else default_joypad_player)
	update_icons()


func reset_joypad_players(primary_device: int = -1):
	if primary_device != -1:
		.reset_joypad_players(primary_device)
		return
	for device in joypad_players.keys():
		set_joypad_player(device, -1)


# pads the game already made player 1 before this script was installed (at start-up, nothing has used them yet)
func release_startup_pads():
	for device in joypad_players.keys():
		if joypad_players[device] == 0 and device != handheld_device:
			joypad_players[device] = -1
	update_icons()


# The game shows the mouse cursor on any mouse event and hides it again only while a pad is in use. The handheld is
# keys, so the cursor goes away on the next button press, after the game's 10 s without the mouse, and right away
# for mouse events that did not move anything (SDL sends one at start: the cursor sat in the top left corner).
var _hide_cursor = true


func _input(event: InputEvent):
	if event is InputEventMouseMotion and event.relative == Vector2.ZERO:
		_hide_cursor = true
	elif (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		_hide_cursor = true


func _process(_delta: float):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and (_hide_cursor or time_since_mouse_input > MOUSE_HIDE_DELAY):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_hide_cursor = false
