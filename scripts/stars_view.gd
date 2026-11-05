class_name StarsView
extends Control
## نمایش ستاره‌ها؛ با animate_to تدریجی روشن می‌شوند.

var total := 3
var star_size := 40.0
var shown := 0.0:
	set(v):
		shown = v
		queue_redraw()

func setup(sz: float, count: int, animate: bool = false) -> void:
	star_size = sz
	size = Vector2(total * sz * 1.25, sz * 1.25)
	if animate:
		var tw := create_tween()
		tw.tween_property(self, "shown", float(count), 0.45 * maxf(1.0, count)).set_delay(0.4)
	else:
		shown = float(count)

func _draw() -> void:
	for i in total:
		var cc := Vector2(star_size * 0.62 + i * star_size * 1.25, size.y / 2.0)
		var s := clampf(shown - i, 0.0, 1.0)
		if s > 0.0:
			_star(cc, star_size * 0.5 * (0.6 + 0.4 * s), Color("f7c531"))
		else:
			_star(cc, star_size * 0.5, Color(0.45, 0.4, 0.35, 0.45))

func _star(cc: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var rr := r if i % 2 == 0 else r * 0.45
		var a := -PI / 2.0 + i * PI / 5.0
		pts.append(cc + Vector2(cos(a), sin(a)) * rr)
	draw_colored_polygon(pts, col)
	draw_polyline(pts + PackedVector2Array([pts[0]]), col.darkened(0.4), 2.0)
