extends "res://menus/joypad_select/JoypadSlot.gd"
# Cassette Beasts port: a slot of the game's controller assignment screen (local co-op). The handheld is the keyboard
# player, always player 1 (PortMultiplayerInput.gd), and the PC game has no slot picture for that: the player slot
# shows a horizontal / vertical handheld (port/icons/joypad/handheld.png, PortOptions.handheld_icon) while no pad
# holds player 1, and pads cannot join it (they join as the partner). Installed by PortOptions.gd. License: 0BSD.

const NO_JOIN = "port_no_join" # an action without events: the screen's join check never matches it


func _ready():
	if player_index == PlayerIndex.PLAYER:
		if not InputMap.has_action(NO_JOIN):
			InputMap.add_action(NO_JOIN)
		join_action = NO_JOIN
	._ready()


func refresh():
	if player_index == PlayerIndex.PLAYER and device == -1 and texture_rect:
		var po = get_node_or_null("/root/PortOptions")
		texture_rect.texture = po.handheld_icon if po else null
		texture_rect.visible = texture_rect.texture != null
		join_prompt.visible = false
		leave_prompt.text = ""
		left_arrow.visible = false
		right_arrow.visible = false
		return
	.refresh()
