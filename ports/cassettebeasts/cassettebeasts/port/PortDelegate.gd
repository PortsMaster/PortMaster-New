extends "res://addons/platform/PlatformDelegate.gd"
# Cassette Beasts port: the game's plain PC platform delegate (no Steam) with an on-screen keyboard
# (PortKeyboard.gd) behind Platform.show_virtual_keyboard, which GlobalUI calls when a pad button is pressed on a
# text field (character name, monster names, ...). Installed by PortOptions.gd. License: 0BSD.

var keyboard = null


func has_virtual_keyboard() -> bool:
	return true


# no store on a handheld (hides the title screen's Steam DLC buttons)
func has_store() -> bool:
	return false


func is_overlay_visible() -> bool:
	return keyboard != null and is_instance_valid(keyboard)


# Online play: the plain PC delegate signs in to Nakama with OS.get_unique_id(), which the FRT platform does not
# implement (empty string: "Device ID is required", online play failed while LAN worked; RG552/RG351P 2026-10-11).
# The port keeps its own random device ID in the save folder instead: created once, the same on every start and after
# updates (a Windows copy of the game sends its machine ID the same way). It is the key to the player's online
# account, so it is kept away from the saves (conf/, which players share) in a hidden file of the port folder, and
# encrypted (obfuscation: the pass is in this script). Updating the port keeps it; deleting the port folder resets it.
const DEVICE_ID_PASS = "cb-port-nk-7f3a91d2"


# ports/cassettebeasts/.port_id (this script is in ports/cassettebeasts/port/)
func _device_id_file() -> String:
	return get_script().resource_path.get_base_dir().get_base_dir() + "/.port_id"


func authenticate_nakama(client):
	return client.authenticate_device_async(port_device_id())


func port_device_id() -> String:
	var f = File.new()
	var id = ""
	if f.open_encrypted_with_pass(_device_id_file(), File.READ, DEVICE_ID_PASS) == OK:
		id = f.get_line().strip_edges()
		f.close()
	if id.length() >= 16:
		return id
	id = Crypto.new().generate_random_bytes(16).hex_encode()
	if f.open_encrypted_with_pass(_device_id_file(), File.WRITE, DEVICE_ID_PASS) == OK:
		f.store_line(id)
		f.close()
	_log("online: new device ID created for Nakama sign-in")
	return id


func show_virtual_keyboard(hint: String, existing_text: String, max_length: int, callback) -> void:
	if is_overlay_visible():
		return
	var tree = Engine.get_main_loop()
	# GlobalUI keeps the focused text field it is opening the keyboard for (Godot 3 viewports have no focus getter)
	var gui = tree.root.get_node_or_null("GlobalUI")
	var ref = gui.get("focus_owner") if gui else null
	var field = ref.get_ref() if ref is WeakRef else null
	# GlobalUI asks on any A press while a text field has the focus; a field can keep it after its menu is gone
	# (character creation closed, the intro going on before the beach): no keyboard unless the field is in the
	# game's current top menu (MenuHelper.is_in_top_menu, what the game's own menus check), and the stale focus
	# goes away so A reaches the game again
	var sm = tree.root.get_node_or_null("SceneManager")
	var mh = tree.root.get_node_or_null("MenuHelper")
	var busy = sm and (sm.get("transitioning") == true or sm.get("loading") == true)
	var stale = busy or (field is Control and (not field.is_visible_in_tree() or field.is_queued_for_deletion() or (field is LineEdit and not field.editable)))
	if field is Control and not stale and mh and mh.has_method("is_in_top_menu") and not mh.is_in_top_menu(field):
		stale = true
	# a menu that faded out (modulate) or slid off the screen is "visible" to Godot: not to the player
	var alpha = _effective_alpha(field) if field is CanvasItem else 1.0
	var on_screen = field is Control and field.get_global_rect().intersects(field.get_viewport().get_visible_rect())
	if field is Control and not stale and (alpha < 0.1 or not on_screen):
		stale = true
	_log("keyboard asked: field %s stale %s | visible %s alpha %.2f on_screen %s editable %s | loading %s transitioning %s | top menu %s in_top %s" % [field.get_path() if field is Node else str(field), stale, field.is_visible_in_tree() if field is Control else "-", alpha, on_screen, field.editable if field is LineEdit else "-", sm.get("loading") if sm else "-", sm.get("transitioning") if sm else "-", mh.get_top_menu().get_path() if mh and mh.has_method("get_top_menu") and mh.get_top_menu() else "none", mh.is_in_top_menu(field) if mh and field is Node else "-"])
	if stale:
		if field is Control and field.has_focus():
			field.release_focus()
		# a menu the game faded out (alpha 0) or slid off the screen but left as the current scene (character
		# creation after Confirm, until the intro's scene change): the game's MenuHelper re-focuses its text field
		# every frame, so every A press lands in the invisible menu (button sounds, keyboard requests). Hide that
		# menu for real: the scene change frees it anyway
		# but not a menu that is still fading IN: A pressed before character creation finished appearing hid it for
		# good (its "show" animation starts at alpha 0; Brick, 2026-10-11)
		if field is Control and (alpha < 0.1 or not on_screen) and _showing(field):
			_log("menu still appearing: keyboard refused, nothing hidden")
		elif field is Control and (alpha < 0.1 or not on_screen):
			# only the faded / off-screen part: the highest ancestor that carries the fade (modulate) or lies off the
			# screen, never the scene itself (the character creation scene also holds the portal animation)
			var hide = null
			var n = field
			var screen = field.get_viewport().get_visible_rect()
			while n is CanvasItem and n.get_parent() != tree.root:
				var faded = n.modulate.a < 0.1 or n.self_modulate.a < 0.1
				var away = n is Control and not n.get_global_rect().intersects(screen)
				if faded or away:
					hide = n
				n = n.get_parent()
			if hide:
				if hide.visible:
					hide.visible = false
				# hidden is not enough: MenuHelper re-focuses the menu every frame and the menu hands the focus to its
				# first input, the name field, where A = "text entered" = the menu's confirm (button sound). Nothing in
				# the faded part may take the focus any more.
				var n_unfocus = _unfocusable(hide)
				_log("faded-out menu part hidden: %s (%d controls made unfocusable)" % [hide.get_path(), n_unfocus])
		if gui and "vk_shown" in gui:
			gui.vk_shown = false
		return
	if hint == "":
		hint = _hint_from_field(field)
	keyboard = load(get_script().resource_path.get_base_dir() + "/PortKeyboard.gd").new()
	keyboard.setup(hint, existing_text, max_length, callback, field)
	tree.root.add_child(keyboard)
	# GlobalUI closes the keyboard as soon as the text field loses the focus (made for system overlays like Steam's,
	# which never take it), but these keys take it: the keyboard closes itself and gives the focus back instead
	if gui and "vk_shown" in gui:
		gui.vk_shown = false


# fields without a hint (the game's TextInputMenu: nicknames, codes): the menu's title, else the placeholder
func _hint_from_field(fo) -> String:
	if not fo:
		return ""
	var n = fo.get_parent()
	while n:
		if "title" in n and n.get("title") is String and n.get("title") != "":
			return tr(n.get("title"))
		n = n.get_parent()
	if fo is LineEdit and fo.placeholder_text != "":
		return tr(fo.placeholder_text)
	return ""


# a menu above the field is playing its "show" animation forwards (BaseMenu.display; hide() plays it backwards)
func _showing(field) -> bool:
	var n = field
	while n:
		var ap = n.get_node_or_null("AnimationPlayer") if n is Node else null
		if ap is AnimationPlayer and ap.is_playing() and ap.current_animation == "show" and ap.get_playing_speed() > 0:
			return true
		n = n.get_parent()
	return false


# every control of a branch loses its focus (and the ability to take it); returns how many changed
func _unfocusable(n) -> int:
	var count = 0
	if n is Control:
		if n.has_focus():
			n.release_focus()
		if n.focus_mode != Control.FOCUS_NONE:
			n.focus_mode = Control.FOCUS_NONE
			count += 1
	for c in n.get_children():
		count += _unfocusable(c)
	return count


# modulate and self_modulate alpha multiplied up the tree (what the player actually sees of a control)
func _effective_alpha(n) -> float:
	var a = 1.0
	while n is CanvasItem:
		a *= n.modulate.a * n.self_modulate.a
		n = n.get_parent()
	return a


# the port's log (PortOptions.gd writes the same file)
func _log(msg):
	var f = File.new()
	var path = "user://port_options.log"
	if f.open(path, File.READ_WRITE) != OK:
		if f.open(path, File.WRITE) != OK:
			return
	f.seek_end()
	f.store_line("%.1f %s" % [OS.get_ticks_msec() / 1000.0, msg])
	f.close()


func hide_virtual_keyboard():
	if is_overlay_visible():
		keyboard.queue_free()
	keyboard = null
