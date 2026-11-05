class_name UI
extends RefCounted
## ابزارهای ساخت سریع عناصر رابط کاربری (دکمه، برچسب، پنل) با ظاهر شبه‌سه‌بعدی.

const INK := Color("3b2412")
const GOLD := Color("c9962e")
const CREAM := Color("fff3d6")

static func _root() -> Node:
	return (Engine.get_main_loop() as SceneTree).root

static func sfx(n: String) -> void:
	_root().get_node("Sfx").play(n)

static func speak(t: String) -> void:
	_root().get_node("Sfx").speak(t)

static func particles() -> float:
	return _root().get_node("Game").particles_scale()

static func fa(v) -> String:
	var out := ""
	for ch in str(v):
		if ch >= "0" and ch <= "9":
			out += char(0x06F0 + int(ch))
		else:
			out += ch
	return out

static func style(bg: Color, radius: int = 18, border: Color = Color(0, 0, 0, 0), bw: int = 0, bottom: int = -1) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if bw > 0:
		sb.border_color = border
		sb.set_border_width_all(bw)
	if bottom >= 0:
		sb.border_color = border
		sb.border_width_bottom = bottom
	return sb

static func button(parent: Node, text: String, pos: Vector2, sz: Vector2, color: Color = Color("e0a84a"), fs: int = 30, sfx: bool = true) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = sz
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", fs)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(c, INK)
	b.add_theme_color_override("font_disabled_color", Color(INK, 0.5))
	var dark := color.darkened(0.4)
	b.add_theme_stylebox_override("normal", style(color, 20, dark, 0, 8))
	b.add_theme_stylebox_override("hover", style(color.lightened(0.1), 20, dark, 0, 8))
	var pr := style(color.darkened(0.1), 20, dark, 0, 3)
	pr.content_margin_top = 8.0
	b.add_theme_stylebox_override("pressed", pr)
	b.add_theme_stylebox_override("disabled", style(color.darkened(0.3).lerp(Color.GRAY, 0.5), 20, dark, 0, 8))
	if sfx:
		b.pressed.connect(func(): UI.sfx("tap"))
	parent.add_child(b)
	return b

static func label(parent: Node, text: String, pos: Vector2, sz: Vector2, fs: int = 28, color: Color = INK, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = sz
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

static func panel(parent: Node, pos: Vector2, sz: Vector2, color: Color, radius: int = 24, border: Color = Color(0, 0, 0, 0), bw: int = 0) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = sz
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", style(color, radius, border, bw))
	parent.add_child(p)
	return p

static func circle_tex(radius: int, color: Color) -> ImageTexture:
	var d := radius * 2
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	for yy in d:
		for xx in d:
			var dist := Vector2(xx - radius + 0.5, yy - radius + 0.5).length()
			if dist <= radius - 1.0:
				img.set_pixel(xx, yy, color)
			elif dist <= radius:
				img.set_pixel(xx, yy, Color(color, 0.5))
	return ImageTexture.create_from_image(img)

static func pop(node: Control, strength: float = 1.2) -> void:
	node.pivot_offset = node.size / 2.0
	node.scale = Vector2(strength, strength)
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
