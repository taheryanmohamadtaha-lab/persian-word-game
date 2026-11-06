class_name Hero
extends Control
## شخصیت‌های کارتونی همراه بازی (کدنویسی‌شده): دایی کلاه‌سبز، حاج‌خانوم، ممدقلی و ببری.
## ۸ حالت: normal, happy, encourage, surprised, sad, thinking, excited, victory

const PROFILES := {
	"kolah": {"skin": Color("f1b37e"), "skin_d": Color("d9955f"), "robe": Color("2d4f8c"), "sleeve": Color("3a5f9e")},
	"haji": {"skin": Color("f3c19a"), "skin_d": Color("d9a07a"), "robe": Color("22304f"), "sleeve": Color("2d3d63")},
	"mamad": {"skin": Color("d9a066"), "skin_d": Color("b8804a"), "robe": Color("efe3c8"), "sleeve": Color("efe3c8")},
	"babri": {"skin": Color("ee9a3a"), "skin_d": Color("c9761f"), "robe": Color("ee9a3a"), "sleeve": Color("ee9a3a")},
}
const HAT := Color("0f5a24")
const HAT_D := Color("0a3f19")
const SASH := Color("e0a830")
const MUST := Color("3d3a35")
const INK := Color("2a1a10")

var character := "kolah"
var mood := "normal"
var t := 0.0
var _revert := 0.0
var _blink := 0.0
var _next_blink := 2.5

func _ready() -> void:
	size = Vector2(200, 240)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_mood(m: String, duration: float = 0.0) -> void:
	mood = m
	_revert = duration

func _process(d: float) -> void:
	t += d
	if _revert > 0.0:
		_revert -= d
		if _revert <= 0.0:
			mood = "normal"
	_next_blink -= d
	if _next_blink <= 0.0:
		_blink = 0.14
		_next_blink = randf_range(2.5, 5.0)
	if _blink > 0.0:
		_blink -= d
	queue_redraw()

func _params() -> Dictionary:
	match mood:
		"happy": return {"eye": 0.3, "brow": -0.3, "mouth": "big", "arms": "clap", "hop": 6.0, "tilt": 0.0, "droop": 0.0}
		"encourage": return {"eye": 1.0, "brow": -0.2, "mouth": "smile", "arms": "up1", "hop": 2.0, "tilt": 0.05, "droop": 0.0}
		"surprised": return {"eye": 1.45, "brow": -0.9, "mouth": "o", "arms": "small", "hop": 0.0, "tilt": 0.0, "droop": 0.0}
		"sad": return {"eye": 0.8, "brow": 0.7, "mouth": "frown", "arms": "down", "hop": 0.0, "tilt": -0.04, "droop": 7.0}
		"thinking": return {"eye": 0.9, "brow": 0.25, "mouth": "flat", "arms": "chin", "hop": 0.0, "tilt": 0.06, "droop": 0.0}
		"excited": return {"eye": 1.25, "brow": -0.5, "mouth": "big", "arms": "up", "hop": 10.0, "tilt": 0.0, "droop": 0.0}
		"victory": return {"eye": 0.3, "brow": -0.4, "mouth": "big", "arms": "up", "hop": 16.0, "tilt": 0.0, "droop": 0.0}
	return {"eye": 1.0, "brow": 0.0, "mouth": "smile_small", "arms": "down", "hop": 0.0, "tilt": 0.0, "droop": 0.0}

func _ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 28:
		var a := i * TAU / 28.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)

func _star(c: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var rr := r if i % 2 == 0 else r * 0.45
		var a := -PI / 2.0 + i * PI / 5.0
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	draw_colored_polygon(pts, col)

func _draw() -> void:
	var p := _params()
	var pr: Dictionary = PROFILES.get(character, PROFILES["kolah"])
	var skin: Color = pr["skin"]
	var skin_d: Color = pr["skin_d"]
	var hop: float = p["hop"]
	var dy := -absf(sin(t * 7.0)) * hop + sin(t * 2.0) * 2.0
	draw_set_transform(Vector2(size.x / 2.0, size.y - 8.0 + dy), p["tilt"], Vector2.ONE)
	var droop: float = p["droop"]
	var hc := Vector2(0, -135 + droop)
	# --- دم ببری (پشت بدن)
	if character == "babri":
		var tail := PackedVector2Array()
		for i in 12:
			tail.append(Vector2(50 + sin(i * 0.5 + t * 3.0) * 6.0 + i * 3.5, -20 - i * 6.0))
		draw_polyline(tail, skin, 14.0)
		draw_polyline(PackedVector2Array([tail[4], tail[5]]), MUST, 14.0)
		draw_polyline(PackedVector2Array([tail[8], tail[9]]), MUST, 14.0)
	# --- بدن
	var robe: Color = pr["robe"]
	match character:
		"haji":
			draw_colored_polygon(PackedVector2Array([Vector2(-58, -88), Vector2(58, -88), Vector2(82, 0), Vector2(-82, 0)]), robe)
			for i in 9:
				var q := Vector2(-52 + (i % 3) * 52 + (i / 3) * 6, -70 + (i / 3) * 24)
				draw_circle(q, 4.0, Color("e8e2f4", 0.8))
		"mamad":
			draw_colored_polygon(PackedVector2Array([Vector2(-46, -85), Vector2(46, -85), Vector2(68, 0), Vector2(-68, 0)]), robe)
			draw_colored_polygon(PackedVector2Array([Vector2(-46, -85), Vector2(-14, -85), Vector2(-20, 0), Vector2(-68, 0)]), Color("6b4a2a"))
			draw_colored_polygon(PackedVector2Array([Vector2(46, -85), Vector2(14, -85), Vector2(20, 0), Vector2(68, 0)]), Color("6b4a2a"))
			draw_rect(Rect2(-62, -40, 124, 10), Color("c0392b"))
		"babri":
			draw_colored_polygon(PackedVector2Array([Vector2(-46, -85), Vector2(46, -85), Vector2(66, 0), Vector2(-66, 0)]), robe)
			_ellipse(Vector2(0, -38), 30, 42, Color("fbe3b8"))
			for k in 3:
				draw_line(Vector2(-60 + k * 6, -70 + k * 22), Vector2(-40 + k * 4, -64 + k * 22), MUST, 6.0)
				draw_line(Vector2(60 - k * 6, -70 + k * 22), Vector2(40 - k * 4, -64 + k * 22), MUST, 6.0)
		_:
			draw_colored_polygon(PackedVector2Array([Vector2(-46, -85), Vector2(46, -85), Vector2(68, 0), Vector2(-68, 0)]), robe)
			draw_rect(Rect2(-62, -42, 124, 12), SASH)
	draw_rect(Rect2(-14, -96, 28, 16), skin_d)
	if character == "mamad":
		draw_colored_polygon(PackedVector2Array([Vector2(-26, -92), Vector2(26, -92), Vector2(0, -60)]), Color("c0392b"))
	# --- بازوها
	_arms(p["arms"], pr)
	# --- پشت سر (گوش‌ها / روسری)
	match character:
		"haji":
			_ellipse(hc + Vector2(0, -4), 64, 74, Color("7a3d8f"))
			for i in 7:
				var a := i * TAU / 7.0 + 0.3
				draw_circle(hc + Vector2(cos(a) * 52.0, -4 + sin(a) * 62.0), 4.0, Color("f1e6f7", 0.85))
		"babri":
			for side in [-1.0, 1.0]:
				_ellipse(hc + Vector2(side * 40, -48), 20, 20, skin)
				_ellipse(hc + Vector2(side * 40, -46), 11, 11, Color("f4b6a8"))
		_:
			_ellipse(hc + Vector2(-54, 5), 10, 16, skin_d)
			_ellipse(hc + Vector2(54, 5), 10, 16, skin_d)
	# --- صورت
	if character == "haji":
		_ellipse(hc + Vector2(0, 6), 46, 55, skin)
	elif character == "babri":
		_ellipse(hc, 56, 56, skin)
	else:
		_ellipse(hc, 52, 60, skin)
	# --- جلوی سر (کلاه / روسری / خط‌خطی‌ها)
	match character:
		"kolah":
			draw_colored_polygon(PackedVector2Array([hc + Vector2(-40, -74), hc + Vector2(40, -74), hc + Vector2(46, -40), hc + Vector2(-46, -40)]), HAT)
			draw_rect(Rect2(hc + Vector2(-48, -44), Vector2(96, 9)), HAT_D)
		"mamad":
			var dome := PackedVector2Array()
			for i in 15:
				var a := PI + i * PI / 14.0
				dome.append(hc + Vector2(0, -38) + Vector2(cos(a) * 52.0, sin(a) * 42.0))
			draw_colored_polygon(dome, Color("8a6a46"))
			draw_rect(Rect2(hc + Vector2(-54, -42), Vector2(108, 10)), Color("5a3f26"))
		"haji":
			var cap := PackedVector2Array()
			for i in 15:
				var a := PI + i * PI / 14.0
				cap.append(hc + Vector2(0, -6) + Vector2(cos(a) * 50.0, sin(a) * 52.0))
			draw_colored_polygon(cap, Color("7a3d8f"))
			draw_arc(hc + Vector2(0, -6), 50.0, PI, TAU, 20, Color("5d2c70"), 4.0)
			_ellipse(hc + Vector2(-30, 28), 9, 7, Color("f0a0a0", 0.55))
			_ellipse(hc + Vector2(30, 28), 9, 7, Color("f0a0a0", 0.55))
		"babri":
			for side in [-1.0, 1.0]:
				draw_colored_polygon(PackedVector2Array([hc + Vector2(side * 4, -56), hc + Vector2(side * 16, -34), hc + Vector2(side * 8, -34)]), MUST)
				draw_colored_polygon(PackedVector2Array([hc + Vector2(side * 30, -50), hc + Vector2(side * 36, -28), hc + Vector2(side * 26, -32)]), MUST)
				draw_colored_polygon(PackedVector2Array([hc + Vector2(side * 52, 4), hc + Vector2(side * 34, 8), hc + Vector2(side * 34, 14)]), MUST)
				draw_colored_polygon(PackedVector2Array([hc + Vector2(side * 52, 22), hc + Vector2(side * 36, 22), hc + Vector2(side * 36, 28)]), MUST)
			_ellipse(hc + Vector2(0, 34), 30, 20, Color("fbe3b8"))
	# --- ابرو و چشم
	var eye: float = p["eye"]
	var b: float = p["brow"]
	var lift := minf(b, 0.0) * 8.0
	var inner := maxf(b, 0.0) * 9.0
	var brow_w := 8.0 if character == "mamad" else 5.0
	var ey := 0.0
	for side in [-1.0, 1.0]:
		var ec := hc + Vector2(side * 21.0, ey)
		var by := hc.y - 24.0 + lift
		if character != "babri":
			draw_line(Vector2(hc.x + side * 36.0, by), Vector2(hc.x + side * 8.0, by - inner), MUST, brow_w)
		if _blink > 0.0 and eye >= 0.5:
			draw_line(ec + Vector2(-12, 0), ec + Vector2(12, 0), INK, 4.0)
		elif eye < 0.5:
			draw_arc(ec + Vector2(0, 4), 11.0, PI, TAU, 12, INK, 4.0)
		else:
			_ellipse(ec, 14.0, 12.0 * minf(eye, 1.3), Color.WHITE)
			var look := Vector2(sin(t * 0.9) * 3.0, 0)
			if mood == "thinking":
				look = Vector2(-5, -4)
			_ellipse(ec + look, 5.5, 5.5 * minf(eye, 1.2), Color("1d3a28"))
		if character == "haji":
			draw_arc(ec, 17.0, 0, TAU, 20, Color("3a2a1a"), 3.0)
	if character == "haji":
		draw_line(hc + Vector2(-5, 0), hc + Vector2(5, 0), Color("3a2a1a"), 3.0)
	# --- بینی / سبیل / پوزه
	match character:
		"babri":
			draw_colored_polygon(PackedVector2Array([hc + Vector2(-9, 16), hc + Vector2(9, 16), hc + Vector2(0, 26)]), Color("3a1f1f"))
			for side in [-1.0, 1.0]:
				for k in 3:
					draw_line(hc + Vector2(side * 22, 30 + k * 5), hc + Vector2(side * 56, 24 + k * 10), Color(0.2, 0.15, 0.1, 0.8), 2.0)
		"haji":
			_ellipse(hc + Vector2(0, 14), 6, 8, skin_d)
		"mamad":
			_ellipse(hc + Vector2(0, 8), 9, 11, skin_d)
			for side in [-1.0, 1.0]:
				draw_colored_polygon(PackedVector2Array([
					hc + Vector2(side * 2, 14), hc + Vector2(side * 22, 8), hc + Vector2(side * 46, 18),
					hc + Vector2(side * 58, 38), hc + Vector2(side * 44, 40), hc + Vector2(side * 36, 28),
					hc + Vector2(side * 14, 28)]), MUST)
				draw_circle(hc + Vector2(side * 50, 40), 6.0, MUST)
		_:
			_ellipse(hc + Vector2(0, 8), 8, 10, skin_d)
			for side in [-1.0, 1.0]:
				draw_colored_polygon(PackedVector2Array([
					hc + Vector2(side * 2, 16), hc + Vector2(side * 18, 12), hc + Vector2(side * 38, 20),
					hc + Vector2(side * 50, 36), hc + Vector2(side * 34, 30), hc + Vector2(side * 14, 28)]), MUST)
	# --- دهان
	var mc := hc + Vector2(0, 46)
	if character == "mamad":
		mc = hc + Vector2(0, 50)
	match p["mouth"]:
		"smile_small":
			draw_arc(mc + Vector2(0, -6), 11.0, 0.2 * PI, 0.8 * PI, 10, Color("8a3030"), 4.0)
		"smile":
			draw_arc(mc + Vector2(0, -8), 15.0, 0.15 * PI, 0.85 * PI, 12, Color("8a3030"), 4.0)
		"big":
			var pts := PackedVector2Array()
			for i in 13:
				var a := i * PI / 12.0
				pts.append(mc + Vector2(cos(a) * 16.0, sin(a) * 15.0 - 6.0))
			draw_colored_polygon(pts, Color("7a1f24"))
			_ellipse(mc + Vector2(0, 3), 8, 5, Color("e86a6a"))
		"o":
			_ellipse(mc, 8, 10, Color("5a1a1e"))
		"frown":
			draw_arc(mc + Vector2(0, 12), 14.0, 1.15 * PI, 1.85 * PI, 12, Color("8a3030"), 4.0)
		"flat":
			draw_line(mc + Vector2(-9, 0), mc + Vector2(9, -3), Color("8a3030"), 4.0)
	# --- جلوه‌های ویژه
	var top := -205.0 if character != "haji" else -212.0
	if mood == "thinking":
		for i in 3:
			var a := clampf(sin(t * 3.0 - i * 0.7) * 0.5 + 0.6, 0.15, 1.0)
			draw_circle(Vector2(46 + i * 14.0, top - i * 10.0), 4.0 + i * 2.0, Color(1, 1, 1, a))
			draw_arc(Vector2(46 + i * 14.0, top - i * 10.0), 4.0 + i * 2.0, 0, TAU, 12, Color(INK, a), 1.5)
	if mood == "victory" or mood == "excited" or mood == "happy":
		for i in 4:
			var a := t * 2.0 + i * TAU / 4.0
			_star(Vector2(cos(a) * 86.0, -140.0 + sin(a) * 70.0), 7.0 + 3.0 * sin(t * 6.0 + i), Color("f7c531"))
	if mood == "sad":
		draw_circle(hc + Vector2(-34, 8 + fmod(t * 40.0, 36.0)), 4.0, Color("6fb3e6"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _hand(c: Vector2, pr: Dictionary) -> void:
	var skin: Color = pr["skin"]
	draw_circle(c, 11.0, skin)
	draw_arc(c, 11.0, 0, TAU, 14, pr["skin_d"], 2.0)

func _arm(shoulder: Vector2, hand: Vector2, pr: Dictionary) -> void:
	var sl: Color = pr["sleeve"]
	draw_line(shoulder, hand, sl, 20.0)
	_hand(hand, pr)

func _arms(kind: String, pr: Dictionary) -> void:
	var ls := Vector2(-46, -78)
	var rs := Vector2(46, -78)
	match kind:
		"down":
			_arm(ls, Vector2(-64, -26), pr)
			_arm(rs, Vector2(64, -26), pr)
		"clap":
			var s := sin(t * 18.0) * 5.0
			_arm(ls, Vector2(-10 + s, -62), pr)
			_arm(rs, Vector2(10 - s, -62), pr)
		"up":
			var w := sin(t * 10.0) * 8.0
			_arm(ls, Vector2(-78, -158 + w), pr)
			_arm(rs, Vector2(78, -158 - w), pr)
		"up1":
			_arm(ls, Vector2(-64, -26), pr)
			_arm(rs, Vector2(76, -150 + sin(t * 8.0) * 8.0), pr)
		"small":
			_arm(ls, Vector2(-72, -112), pr)
			_arm(rs, Vector2(72, -112), pr)
		"chin":
			_arm(ls, Vector2(-64, -26), pr)
			_arm(rs, Vector2(24, -70), pr)
