class_name CupsView
extends Control
## سینی استکان‌های چای؛ با هر پاسخ درست یک استکان برداشته می‌شود.

var total := 3
var left := 3:
	set(v):
		left = v
		queue_redraw()

func _draw() -> void:
	for i in total:
		var c := Vector2(30.0 + i * 58.0, size.y / 2.0)
		draw_circle(c, 25.0, Color("a9a9a9") if i < left else Color(0.6, 0.6, 0.6, 0.25))
		if i < left:
			draw_circle(c, 15.0, Color("b3321f"))
			draw_circle(c + Vector2(-3, -3), 8.0, Color("e8735a"))
