class_name Carpet
extends Control
## فرش ایرانی (طراحی کدنویسی‌شده) پشت خانه‌های پاسخ.

func _draw() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UI.col("carpet")
	sb.set_corner_radius_all(30)
	sb.set_border_width_all(10)
	sb.border_color = Color("6b4a2a")
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.25)
	draw_style_box(sb, Rect2(Vector2.ZERO, size))
	var inner := StyleBoxFlat.new()
	inner.bg_color = Color(0, 0, 0, 0)
	inner.set_corner_radius_all(20)
	inner.set_border_width_all(3)
	inner.border_color = Color("d9a441")
	draw_style_box(inner, Rect2(Vector2(18, 18), size - Vector2(36, 36)))
	var c := size / 2.0
	for i in 4:
		draw_arc(c, 28.0 + i * 24.0, 0.0, TAU, 64, Color(Color("d9a441"), 0.55 - i * 0.1), 3.0)
	for k in 8:
		var d := Vector2.RIGHT.rotated(k * TAU / 8.0)
		draw_colored_polygon(PackedVector2Array([c + d * 30.0, c + d.rotated(0.25) * 78.0, c + d * 104.0, c + d.rotated(-0.25) * 78.0]), Color(Color("d9714f"), 0.5))
