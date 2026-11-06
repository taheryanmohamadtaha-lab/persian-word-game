class_name Background
extends Control
## پس‌زمینهٔ زنده: گرادیان رنگی، حاشیهٔ کاشی‌کاری و حباب‌های شناور. پالت با مرحله عوض می‌شود.

var pal := 0
var blobs: Array = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 9:
		blobs.append({"p": Vector2(randf(), randf()), "r": randf_range(30.0, 90.0), "s": randf_range(0.01, 0.03)})
	set_process(UI.particles() > 0.0)

func set_palette(i: int) -> void:
	pal = i
	UI._root().get_node("Game").auto_idx = i
	queue_redraw()

func _process(delta: float) -> void:
	for b in blobs:
		b["p"].y -= b["s"] * delta
		if b["p"].y < -0.1:
			b["p"].y = 1.1
			b["p"].x = randf()
	queue_redraw()

func _draw() -> void:
	var th := UI.theme()
	var c: Array = [th["bg0"], th["bg1"], th["border"]]
	var s := size
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(s.x, 0), s, Vector2(0, s.y)]),
		PackedColorArray([c[0], c[0], c[1], c[1]]))
	for b in blobs:
		draw_circle(Vector2(b["p"].x * s.x, b["p"].y * s.y), b["r"], Color(1, 1, 1, 0.12))
	var t := 28.0
	for i in int(s.x / t) + 1:
		_tile(Vector2(i * t + t / 2.0, t / 2.0), t, c[2])
		_tile(Vector2(i * t + t / 2.0, s.y - t / 2.0), t, c[2])
	for j in int(s.y / t) + 1:
		_tile(Vector2(t / 2.0, j * t + t / 2.0), t, c[2])
		_tile(Vector2(s.x - t / 2.0, j * t + t / 2.0), t, c[2])

func _tile(center: Vector2, t: float, col: Color) -> void:
	var r := t * 0.42
	draw_colored_polygon(PackedVector2Array([center + Vector2(0, -r), center + Vector2(r, 0), center + Vector2(0, r), center + Vector2(-r, 0)]), col)
	draw_circle(center, r * 0.28, col.lightened(0.6))
