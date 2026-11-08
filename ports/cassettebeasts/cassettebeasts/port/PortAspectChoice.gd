extends CanvasLayer
# Cassette Beasts port: first-start choice of the aspect mode on screens narrower than 16:9 (PortOptions.gd), in
# the style of the port's on-screen keyboard (the game's text input menu): checker backdrop, purple title tab,
# white panel, the game's focus arrow and button sounds. Two picture buttons (aspect_letterbox.png /
# aspect_fill.png, the same Harbourtown spot at 4:3 in each mode) under a short explanation; left/right picks,
# A chooses, B keeps the recommended 16:9 letterbox. Emits chosen(mode): 1 letterbox, 2 expanded view (fill width). Texts:
# PortText.gd. License: 0BSD.

signal chosen(mode)

const THEME = "res://ui/battle_theme.tres"
const FOCUS_INDICATOR = "res://nodes/menus/FocusIndicator.tscn"
const IMAGES = ["aspect_letterbox.png", "aspect_fill.png"]
const MODES = [1, 2]
const NAMES = ["PORT_ASPECT_LETTERBOX", "PORT_ASPECT_FILL"]
const NOTES = ["PORT_ASPECT_LB_NOTE", "PORT_ASPECT_FILL_NOTE"]
const TEXT_COLOR = Color(0.12, 0.08, 0.18)
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

var path_text = "" # "Settings > Graphics > Aspect ratio" in the game's words (PortOptions)
var _buttons = []
var _done = false
var _sel = 0


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


func _texture(file):
	var img = Image.new()
	if img.load(get_script().resource_path.get_base_dir().plus_file(file)) != OK:
		return null
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex


func _ready():
	layer = 126
	pause_mode = Node.PAUSE_MODE_PROCESS
	var root = Control.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	if ResourceLoader.exists(THEME):
		root.theme = load(THEME)
	add_child(root)

	var backdrop = ColorRect.new()
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	var sh = Shader.new()
	sh.code = BACKDROP_SHADER
	var mat = ShaderMaterial.new()
	mat.shader = sh
	backdrop.material = mat
	root.add_child(backdrop)

	var vs = root.get_viewport_rect().size
	var width = min(vs.x * 0.86, 1600.0)
	var pic_w = floor((width - 96 - 32) / 2.0)

	var column = VBoxContainer.new()
	column.add_constant_override("separation", 0)
	root.add_child(column)
	var tab_margin = MarginContainer.new()
	tab_margin.add_constant_override("margin_right", 100)
	column.add_child(tab_margin)
	var tab = PanelContainer.new()
	tab.size_flags_horizontal = 0
	tab.add_stylebox_override("panel", _style_tab())
	tab_margin.add_child(tab)
	var title = Label.new()
	title.text = "PORT_ASPECT"
	tab.add_child(title)

	var panel = PanelContainer.new()
	panel.add_stylebox_override("panel", _style_panel())
	column.add_child(panel)
	var box = VBoxContainer.new()
	box.add_constant_override("separation", 24)
	panel.add_child(box)

	var text = Label.new()
	text.autowrap = true
	text.rect_min_size = Vector2(width - 96, 0)
	text.text = tr("PORT_ASPECT_CHOICE_TEXT").format({"path": path_text})
	text.add_color_override("font_color", TEXT_COLOR)
	box.add_child(text)

	var row = HBoxContainer.new()
	row.add_constant_override("separation", 32)
	row.alignment = BoxContainer.ALIGN_CENTER
	box.add_child(row)
	for i in IMAGES.size():
		var b = Button.new()
		b.focus_mode = Control.FOCUS_ALL
		b.rect_min_size = Vector2(pic_w, 0)
		b.connect("pressed", self, "_choose", [i])
		b.add_child(AutoFocusButton.new())
		var inner = VBoxContainer.new()
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_constant_override("separation", 6)
		inner.anchor_right = 1.0
		inner.anchor_bottom = 1.0
		inner.margin_left = 16
		inner.margin_right = -16
		inner.margin_top = 16
		inner.margin_bottom = -12
		b.add_child(inner)
		var pic = TextureRect.new()
		pic.texture = _texture(IMAGES[i])
		pic.expand = true
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.rect_min_size = Vector2(pic_w - 32, (pic_w - 32) * 0.75)
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(pic)
		for t in [NAMES[i], NOTES[i]]:
			var l = Label.new()
			l.text = t
			l.align = Label.ALIGN_CENTER
			l.autowrap = true
			l.mouse_filter = Control.MOUSE_FILTER_IGNORE
			l.add_color_override("font_color", TEXT_COLOR if t == NAMES[i] else Color(0.35, 0.3, 0.42))
			inner.add_child(l)
		row.add_child(b)
		_buttons.append(b)

	if ResourceLoader.exists(FOCUS_INDICATOR):
		var fi = load(FOCUS_INDICATOR).instance()
		root.add_child(fi)
		fi.container_path = fi.get_path_to(panel)

	yield(get_tree(), "idle_frame")
	# the buttons' height follows their content (picture + two lines)
	for b in _buttons:
		b.rect_min_size.y = b.get_child(1).get_combined_minimum_size().y + 28
	yield(get_tree(), "idle_frame")
	# short screens (480x320: 3:2) cannot hold the panel at the UI size: scaled down to fit
	var size = column.rect_size + Vector2(20, 20) # + the drop shadow
	var sc = min(1.0, min(vs.y * 0.96 / size.y, vs.x * 0.96 / size.x))
	column.rect_scale = Vector2(sc, sc)
	column.rect_position = ((vs - column.rect_size * sc) / 2.0).floor()
	_select(0)
	var tw = Tween.new()
	add_child(tw)
	tw.interpolate_property(mat, "shader_param/progress", 0.0, 1.0, 0.2)
	tw.start()


func _choose(i):
	if _done:
		return
	_done = true
	emit_signal("chosen", MODES[i])
	queue_free()


func _select(i):
	_sel = clamp(i, 0, _buttons.size() - 1)
	_buttons[_sel].grab_focus()


# input handled here (the title screen keeps the GUI focus elsewhere), the focus follows for the arrow and sounds
func _input(event):
	if _done or _buttons.empty():
		return
	if event is InputEventJoypadButton or event is InputEventKey or event is InputEventAction:
		get_tree().set_input_as_handled()
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action_pressed("ui_left"):
		_select(_sel - 1)
	elif event.is_action_pressed("ui_right"):
		_select(_sel + 1)
	elif event.is_action_pressed("ui_accept"):
		_choose(_sel)
	elif event.is_action_pressed("ui_cancel"):
		_choose(0)
