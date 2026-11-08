extends Node
# Cassette Beasts port: readable battle button names. The cassette player's labels (FIGHT, SWITCH, ITEM, FLEE,
# RECORD) are a texture on the 3D model, drawn with the rest of the 3D at half resolution: a few blurry pixels on
# a handheld. Here the focused button's word floats above it the way the game shows the flee chance (same place,
# white with a black outline, fading in while rising), cut out of the game's own localized label texture (every
# language's art, no strings needed). On Flee the word joins the game's percentage label ("FLEE 75%").
# Added to CassettePlayer3D's CanvasLayer by PortOptions.gd. License: 0BSD.

const BUTTONS = ["FightButton", "FormsButton", "ItemButton", "FleeButton", "RecordButton"]
const WORD_GAP_PX = 14 # empty texture columns between two words
const CAP_HEIGHT = 0.74 # of the label font's ascent: the words' letter height
const OUTLINE = 2.0
const RISE_FROM = -33.0 # the flee label's offsets above the button (CassettePlayer3D.gd)
const RISE_TO = -66.0


class Word extends Control:
	var texture = null
	var region = Rect2()
	var outline = 2.0
	var rise = -33.0 # above the button, tweened like the game's flee label

	func _draw():
		var r = Rect2(Vector2.ZERO, rect_size)
		for d in [Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1)]:
			draw_texture_rect_region(texture, Rect2(r.position + d * outline, r.size), region, Color.black)
		draw_texture_rect_region(texture, r, region, Color.white)


var player = null
var _buttons = {}
var _words = {}
var _tweens = {}
var _flee_word = null


func setup(p_player):
	player = p_player
	var body = player.find_node("CassettePlayer", true, false)
	var mat = body.material_override if body else null
	var tex = mat.get_shader_param("texture_detail_albedo") if mat is ShaderMaterial else null
	var rects = _find_words(tex)
	if rects.size() != BUTTONS.size():
		return "%d words in %s" % [rects.size(), str(tex.resource_path) if tex else "no texture"]
	var font = player.flee_chance_label.get_font("font")
	var scale = font.get_ascent() * CAP_HEIGHT / rects[0][1]
	for i in BUTTONS.size():
		var b = player.find_node(BUTTONS[i], true, false)
		if not b:
			continue
		var w = Word.new()
		w.texture = tex
		w.region = rects[i][0]
		w.outline = OUTLINE
		w.mouse_filter = Control.MOUSE_FILTER_IGNORE
		w.rect_size = w.region.size * scale
		if BUTTONS[i] == "FleeButton":
			# inside the game's flee chance label, left of the percentage: fades and moves with it
			_flee_word = w
			player.flee_chance_label.add_child(w)
			continue
		w.visible = false
		w.modulate.a = 0.0
		get_parent().add_child(w)
		var t = Tween.new()
		add_child(t)
		_buttons[b] = BUTTONS[i]
		_words[b] = w
		w.rise = RISE_FROM
		_tweens[b] = t
		b.connect("focus_entered", self, "_on_focus", [b, true])
		b.connect("focus_exited", self, "_on_focus", [b, false])
	return ""


# word boxes of the label texture, left to right: [region in pixels, letter height of the main text line]
func _find_words(tex):
	var out = []
	if not tex:
		return out
	var img = tex.get_data()
	if not img:
		return out
	if img.is_compressed():
		img.decompress()
	img.lock()
	var w = img.get_width()
	var h = img.get_height()
	var rows = []
	for y in h:
		var any = false
		for x in range(0, w, 2):
			if img.get_pixel(x, y).a > 0.15:
				any = true
				break
		rows.append(any)
	# the tallest run of text rows is the line; rows just above it (umlaut dots) belong to it too
	var best = [0, -1]
	var start = -1
	for y in h + 1:
		var on = y < h and rows[y]
		if on and start < 0:
			start = y
		elif not on and start >= 0:
			if y - start > best[1] - best[0] + 1:
				best = [start, y - 1]
			start = -1
	if best[1] < 0:
		img.unlock()
		return out
	var top = best[0]
	while top > 0 and best[0] - top < (best[1] - best[0]) / 2 and (rows[top - 1] or (top > 1 and rows[top - 2])):
		top -= 1
	var letter_h = best[1] - best[0] + 1
	var cols = []
	for x in w:
		var any = false
		for y in range(top, best[1] + 1):
			if img.get_pixel(x, y).a > 0.15:
				any = true
				break
		cols.append(any)
	img.unlock()
	var x0 = -1
	var last = -100
	for x in w:
		if cols[x]:
			if x0 < 0:
				x0 = x
			elif x - last > WORD_GAP_PX:
				out.append([Rect2(x0, top, last - x0 + 1, best[1] - top + 1), letter_h])
				x0 = x
			last = x
	if x0 >= 0:
		out.append([Rect2(x0, top, last - x0 + 1, best[1] - top + 1), letter_h])
	return out


func _on_focus(b, entered):
	var w = _words[b]
	var t = _tweens[b]
	t.stop_all()
	t.remove_all()
	t.interpolate_property(w, "modulate:a", null, 1.0 if entered else 0.0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	t.interpolate_property(w, "rise", null, RISE_TO if entered else RISE_FROM, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	t.start()
	if entered:
		w.visible = true
	_place(b)


func _place(b):
	var cam = get_viewport().get_camera()
	if not cam:
		return
	var w = _words[b]
	var pos = cam.unproject_position(b.global_transform.origin) + Vector2(0, w.rise)
	w.rect_position = pos - Vector2(w.rect_size.x * 0.5, w.rect_size.y)


func _process(_d):
	for b in _words:
		var w = _words[b]
		if not is_instance_valid(b) or not is_instance_valid(w):
			continue
		if w.visible:
			_place(b)
			if w.modulate.a <= 0.01 and not b.has_focus():
				w.visible = false
	if _flee_word and is_instance_valid(_flee_word):
		var label = player.flee_chance_label
		var lh = label.rect_size.y
		_flee_word.rect_position = Vector2(-_flee_word.rect_size.x - 12.0, (lh - _flee_word.rect_size.y) * 0.5)
