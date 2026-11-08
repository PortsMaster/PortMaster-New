extends CanvasLayer
# Cassette Beasts port: on-screen keyboard for text fields (opened by PortDelegate.show_virtual_keyboard), in the
# style of the game's own text input menu (menus/text_input/TextInputMenu.tscn): scrolling purple checker backdrop,
# purple title tab, white panel with the hard black drop shadow, battle_theme buttons, the purple focus arrow
# (nodes/menus/FocusIndicator.tscn) and the menu sounds (AutoFocusButton). D-pad or left stick moves (the stick
# repeats while held), A types, B deletes, Start (or OK) confirms and hands the text to the game's callback
# (Bind.call_func1). Texts: PortText.gd. License: 0BSD.

const ROWS = [
	["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
	["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
	["a", "s", "d", "f", "g", "h", "j", "k", "l", "'"],
	["z", "x", "c", "v", "b", "n", "m", "-", ".", "!"],
	["SHIFT", "SPACE", "DEL", "OK"],
]
const THEME = "res://ui/battle_theme.tres"
const FOCUS_INDICATOR = "res://nodes/menus/FocusIndicator.tscn"
const KEY = Vector2(118, 96)
const STICK_ON = 0.5 # axis value that counts as a push
const STICK_OFF = 0.35 # and as released
const STICK_DELAY = 0.35 # first repeat while held
const STICK_REPEAT = 0.12
const BACKDROP_SHADER = """
shader_type canvas_item;
uniform float progress = 0.0;
uniform vec4 base_color : hint_color = vec4(0.1686, 0.1098, 0.2235, 1.0);
uniform vec4 hi_color : hint_color = vec4(0.6706, 0.4588, 0.9098, 0.0625);
uniform float cell = 12.0;
void fragment() {
	vec2 p = FRAGCOORD.xy / cell;
	p.x -= p.y * 0.333;
	p.y -= TIME;
	vec2 m = mod(floor(p), 2.0);
	vec3 pattern = mix(base_color.rgb, hi_color.rgb, hi_color.a * mod(m.x + m.y, 2.0));
	COLOR = vec4(pattern, progress * 0.92);
}
"""

var hint = ""
var text = ""
var max_length = 100
var callback = null
var field = null # the text field (WeakRef): gets the focus back on close
var shift = true
var row = 1
var col = 0

var _root
var _backdrop
var _display
var _buttons = []
var _stick = Vector2.ZERO
var _stick_dir = Vector2.ZERO
var _stick_t = 0.0


func setup(p_hint, p_text, p_max_length, p_callback, p_field = null):
	hint = p_hint
	text = p_text
	max_length = p_max_length if p_max_length > 0 else 100
	callback = p_callback
	field = weakref(p_field) if p_field else null
	shift = text == ""


func _style_tab():
	var s = StyleBoxFlat.new()
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	s.bg_color = Color(0.670588, 0.458824, 0.909804)
	s.corner_radius_top_right = 100
	s.corner_detail = 1
	s.expand_margin_right = 80
	s.shadow_color = Color(0, 0, 0)
	s.shadow_size = 1
	s.shadow_offset = Vector2(-20, 20)
	return s


func _style_panel():
	var s = StyleBoxFlat.new()
	s.content_margin_left = 48
	s.content_margin_right = 48
	s.content_margin_top = 32
	s.content_margin_bottom = 32
	s.bg_color = Color(1, 1, 1)
	s.corner_radius_top_right = 20
	s.corner_radius_bottom_left = 20
	s.corner_detail = 1
	s.shadow_color = Color(0, 0, 0)
	s.shadow_size = 2
	s.shadow_offset = Vector2(-20, 20)
	return s


func _ready():
	layer = 127
	pause_mode = Node.PAUSE_MODE_PROCESS
	_root = Control.new()
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	if ResourceLoader.exists(THEME):
		_root.theme = load(THEME)
	add_child(_root)

	_backdrop = ColorRect.new()
	_backdrop.anchor_right = 1.0
	_backdrop.anchor_bottom = 1.0
	var sh = Shader.new()
	sh.code = BACKDROP_SHADER
	var mat = ShaderMaterial.new()
	mat.shader = sh
	_backdrop.material = mat
	_root.add_child(_backdrop)

	var column = VBoxContainer.new()
	column.add_constant_override("separation", 0)
	_root.add_child(column)

	var tab_margin = MarginContainer.new()
	tab_margin.add_constant_override("margin_right", 100)
	column.add_child(tab_margin)
	var tab = PanelContainer.new()
	tab.size_flags_horizontal = 0
	tab.add_stylebox_override("panel", _style_tab())
	tab_margin.add_child(tab)
	var title = Label.new()
	title.text = hint if hint != "" else "PORT_KB_TITLE"
	tab.add_child(title)

	var panel = PanelContainer.new()
	panel.add_stylebox_override("panel", _style_panel())
	column.add_child(panel)
	var box = VBoxContainer.new()
	box.add_constant_override("separation", 14)
	panel.add_child(box)

	_display = LineEdit.new()
	_display.editable = false
	_display.focus_mode = Control.FOCUS_NONE
	_display.virtual_keyboard_enabled = false
	_display.caret_blink = true
	# read-only field, but drawn like the game's editable one (Godot greys out non-editable text)
	_display.add_color_override("font_color_uneditable", Color(0.12, 0.08, 0.18))
	_display.rect_min_size = Vector2(KEY.x * 10 + 9 * 8, 0)
	box.add_child(_display)

	for r in range(ROWS.size()):
		var hb = HBoxContainer.new()
		hb.alignment = BoxContainer.ALIGN_CENTER
		hb.add_constant_override("separation", 8)
		box.add_child(hb)
		var line = []
		for c in range(ROWS[r].size()):
			var key = ROWS[r][c]
			var b = Button.new()
			b.focus_mode = Control.FOCUS_ALL
			b.rect_min_size = KEY if key.length() == 1 else Vector2(KEY.x * 2 + 8, KEY.y)
			b.connect("pressed", self, "_on_key", [r, c])
			var snd = AutoFocusButton.new()
			b.add_child(snd)
			hb.add_child(b)
			line.append(b)
		_buttons.append(line)

	var help = Label.new()
	help.text = "PORT_KB_HELP"
	help.align = Label.ALIGN_CENTER
	help.add_color_override("font_color", Color(0.35, 0.3, 0.42))
	box.add_child(help)

	if ResourceLoader.exists(FOCUS_INDICATOR):
		var fi = load(FOCUS_INDICATOR).instance()
		_root.add_child(fi)
		fi.container_path = fi.get_path_to(panel)

	_refresh_labels()
	yield(get_tree(), "idle_frame")
	var vs = _root.get_viewport_rect().size
	column.rect_position = ((vs - column.rect_size) / 2.0).floor()
	_focus()
	var tw = Tween.new()
	add_child(tw)
	tw.interpolate_property(mat, "shader_param/progress", 0.0, 1.0, 0.2)
	tw.start()


func _key_label(key):
	if key == "SPACE":
		return tr("PORT_KB_SPACE")
	if key == "SHIFT":
		return tr("PORT_KB_SHIFT").to_upper() if shift else tr("PORT_KB_SHIFT")
	if key == "DEL":
		return tr("PORT_KB_DEL")
	if key == "OK":
		return tr("UI_BUTTON_OK")
	return key.to_upper() if shift else key


func _refresh_labels():
	_display.text = text
	for r in range(_buttons.size()):
		for c in range(_buttons[r].size()):
			_buttons[r][c].text = _key_label(ROWS[r][c])


func _focus():
	_buttons[row][col].grab_focus()


func _move(dr, dc):
	if dr != 0:
		var old_len = ROWS[row].size()
		row = (row + dr + ROWS.size()) % ROWS.size()
		col = int(round(float(col) / max(1, old_len - 1) * (ROWS[row].size() - 1)))
	if dc != 0:
		col = (col + dc + ROWS[row].size()) % ROWS[row].size()
	_focus()


func _on_key(r, c):
	var key = ROWS[r][c]
	if key == "OK":
		_finish()
		return
	if key == "DEL":
		_delete()
		return
	if key == "SHIFT":
		shift = not shift
	elif text.length() < max_length:
		text += " " if key == "SPACE" else (key.to_upper() if shift else key)
		if shift and key.length() == 1:
			shift = false
	_refresh_labels()


func _delete():
	if text.length() > 0:
		text = text.substr(0, text.length() - 1)
	shift = text == "" or text.ends_with(" ")
	_refresh_labels()


func _finish():
	if callback:
		callback.call_func1(text)
	var f = field.get_ref() if field else null
	if f and f.is_inside_tree():
		f.call_deferred("grab_focus")
	Platform.hide_virtual_keyboard()
	queue_free()


# left stick: the strongest axis past STICK_ON is a direction; a move on the push, then repeats while held
func _stick_motion(event):
	if event.axis == JOY_AXIS_0:
		_stick.x = event.axis_value
	elif event.axis == JOY_AXIS_1:
		_stick.y = event.axis_value
	else:
		return
	var dir = _stick_dir
	if dir != Vector2.ZERO and max(abs(_stick.x), abs(_stick.y)) < STICK_OFF:
		dir = Vector2.ZERO
	elif abs(_stick.x) >= STICK_ON or abs(_stick.y) >= STICK_ON:
		dir = Vector2(sign(_stick.x), 0) if abs(_stick.x) > abs(_stick.y) else Vector2(0, sign(_stick.y))
	if dir != _stick_dir:
		_stick_dir = dir
		_stick_t = STICK_DELAY
		if dir != Vector2.ZERO:
			_move(int(dir.y), int(dir.x))


func _process(delta):
	if _stick_dir == Vector2.ZERO:
		return
	_stick_t -= delta
	if _stick_t <= 0.0:
		_stick_t = STICK_REPEAT
		_move(int(_stick_dir.y), int(_stick_dir.x))


func _input(event):
	if event is InputEventJoypadButton or event is InputEventKey or event is InputEventJoypadMotion or event is InputEventAction:
		get_tree().set_input_as_handled()
	if event is InputEventJoypadMotion:
		_stick_motion(event)
		return
	if not event.is_pressed() or event.is_echo():
		return
	# Start: a pad's button, or the handheld's (gptokeyb2 sends it as Enter, cassettebeasts.ini)
	if (event is InputEventJoypadButton and event.button_index == JOY_START) or (event is InputEventKey and event.scancode == KEY_ENTER):
		_finish()
	elif event.is_action_pressed("ui_left"):
		_move(0, -1)
	elif event.is_action_pressed("ui_right"):
		_move(0, 1)
	elif event.is_action_pressed("ui_up"):
		_move(-1, 0)
	elif event.is_action_pressed("ui_down"):
		_move(1, 0)
	elif event.is_action_pressed("ui_accept"):
		_buttons[row][col].emit_signal("pressed")
	elif event.is_action_pressed("ui_cancel"):
		_delete()
