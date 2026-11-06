class_name OrbsView
extends Control
## گوی‌های شیشه‌ای؛ با هر حرف اشتباه یکی می‌شکند و تکه‌های شیشه می‌ریزد.

var total := 6
var broken := 0
var shards: Array = []
const PITCH := 66.0
const R := 25.0

func reset(n: int) -> void:
	total = n
	broken = 0
	shards.clear()
	size = Vector2(n * PITCH, 62.0)
	queue_redraw()

func orb_center(i: int) -> Vector2:
	# گوی اول از سمت راست
	return Vector2(size.x - PITCH / 2.0 - i * PITCH, size.y / 2.0)

func shatter() -> void:
	if broken >= total:
		return
	var c := orb_center(broken)
	for k in 14:
		var a := randf() * TAU
		shards.append({"p": c, "v": Vector2(cos(a), sin(a)) * randf_range(60.0, 260.0) + Vector2(0, -60), "r": randf() * TAU, "s": randf_range(5.0, 12.0), "life": 1.0})
	broken += 1
	set_process(true)
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)

func _process(d: float) -> void:
	for s in shards:
		s["p"] += s["v"] * d
		s["v"].y += 700.0 * d
		s["r"] += 6.0 * d
		s["life"] -= d * 1.4
	shards = shards.filter(func(s): return s["life"] > 0.0)
	if shards.is_empty():
		set_process(false)
	queue_redraw()

func _draw() -> void:
	for i in total:
		var c := orb_center(i)
		if i < broken:
			draw_arc(c, R, 0, TAU, 24, Color(0.4, 0.3, 0.2, 0.18), 2.0)
			continue
		draw_circle(c + Vector2(2, 4), R, Color(0, 0, 0, 0.15))
		draw_circle(c, R, Color(0.55, 0.82, 0.96, 0.75))
		draw_circle(c + Vector2(3, 4), R * 0.72, Color(0.35, 0.65, 0.9, 0.55))
		draw_arc(c, R, 0, TAU, 28, Color(1, 1, 1, 0.9), 3.0)
		draw_circle(c + Vector2(-8, -9), 6.0, Color(1, 1, 1, 0.9))
		draw_circle(c + Vector2(9, 10), 3.0, Color(1, 1, 1, 0.5))
	for s in shards:
		var p: Vector2 = s["p"]
		var sz: float = s["s"]
		var r: float = s["r"]
		var pts := PackedVector2Array([p + Vector2(0, -sz).rotated(r), p + Vector2(sz * 0.8, sz * 0.6).rotated(r), p + Vector2(-sz * 0.8, sz * 0.6).rotated(r)])
		draw_colored_polygon(pts, Color(0.7, 0.9, 1.0, clampf(s["life"], 0.0, 0.85)))
