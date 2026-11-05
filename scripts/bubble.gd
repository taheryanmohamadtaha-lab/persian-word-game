class_name Bubble
extends Control
## حباب گفتار شخصیت؛ دیالوگ را نمایش می‌دهد و (در صورت وجود صدای فارسی) می‌خواند.

var label: Label
var _sb := StyleBoxFlat.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sb.bg_color = Color("fff6e0")
	_sb.set_corner_radius_all(24)
	_sb.set_border_width_all(4)
	_sb.border_color = Color("c9962e")
	label = Label.new()
	label.position = Vector2(20, 10)
	label.size = size - Vector2(40, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", UI.INK)
	add_child(label)

func _draw() -> void:
	draw_style_box(_sb, Rect2(Vector2.ZERO, size))
	var cy := size.y * 0.5
	var tail := PackedVector2Array([Vector2(3, cy - 16), Vector2(-24, cy), Vector2(3, cy + 16)])
	draw_colored_polygon(tail, Color("fff6e0"))
	draw_polyline(tail, Color("c9962e"), 4.0)

func say(text: String, speak: bool = true) -> void:
	label.text = text
	pivot_offset = Vector2(0, size.y / 2.0)
	scale = Vector2(0.8, 0.8)
	modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	if speak:
		UI.speak(text)
