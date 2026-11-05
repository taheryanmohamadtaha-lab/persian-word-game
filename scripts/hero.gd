class_name Hero
extends Control
## شخصیت کارتونی همراه بازی؛ ۸ حالت: normal, happy, encourage, surprised, sad, thinking, excited, victory
## همه‌چیز با کد کشیده می‌شود (بدون دارایی خارجی) و دائماً نفس می‌کشد و پلک می‌زند.

const SKIN := Color("f1b37e")
const SKIN_D := Color("d9955f")
const HAT := Color("0f5a24")
const HAT_D := Color("0a3f19")
const ROBE := Color("2d4f8c")
const SASH := Color("e0a830")
const MUST := Color("3d3a35")
const INK := Color("2a1a10")

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
	var hop: float = p["hop"]
	var dy := -absf(sin(t * 7.0)) * hop + sin(t * 2.0) * 2.0
	draw_set_transform(Vector2(size.x / 2.0, size.y - 8.0 + dy), p["tilt"], Vector2.ONE)
	var droop: float = p["droop"]
	# بدن
	draw_colored_polygon(PackedVector2Array([Vector2(-46, -85), Vector2(46, -85), Vector2(68, 0), Vector2(-68, 0)]), ROBE)
	draw_rect(Rect2(-62, -42, 124, 12), SASH)
	draw_rect(Rect2(-14, -96, 28, 16), SKIN_D)
	# بازوها
	_arms(p["arms"])
	# سر
	var hc := Vector2(0, -135 + droop)
	_ellipse(hc + Vector2(-54, 5), 10, 16, SKIN_D)
	_ellipse(hc + Vector2(54, 5), 10, 16, SKIN_D)
	_ellipse(hc, 52, 60, SKIN)
	# کلاه
	draw_colored_polygon(PackedVector2Array([hc + Vector2(-40, -74), hc + Vector2(40, -74), hc + Vector2(46, -40), hc + Vector2(-46, -40)]), HAT)
	draw_rect(Rect2(hc + Vector2(-48, -44), Vector2(96, 9)), HAT_D)
	# ابرو و چشم
	var eye: float = p["eye"]
	var b: float = p["brow"]
	var lift := minf(b, 0.0) * 8.0
	var inner := maxf(b, 0.0) * 9.0
	for side in [-1.0, 1.0]:
		var ec := hc + Vector2(side * 21.0, 0)
		var by := hc.y - 24.0 + lift
		draw_line(Vector2(hc.x + side * 36.0, by), Vector2(hc.x + side * 8.0, by - inner), MUST, 5.0)
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
	# بینی و سبیل
	_ellipse(hc + Vector2(0, 8), 8, 10, SKIN_D)
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			hc + Vector2(side * 2, 16), hc + Vector2(side * 18, 12), hc + Vector2(side * 38, 20),
			hc + Vector2(side * 50, 36), hc + Vector2(side * 34, 30), hc + Vector2(side * 14, 28)]), MUST)
	# دهان
	var mc := hc + Vector2(0, 46)
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
			_ellipse(mc + Vector2(0, 0), 8, 10, Color("5a1a1e"))
		"frown":
			draw_arc(mc + Vector2(0, 12), 14.0, 1.15 * PI, 1.85 * PI, 12, Color("8a3030"), 4.0)
		"flat":
			draw_line(mc + Vector2(-9, 0), mc + Vector2(9, -3), Color("8a3030"), 4.0)
	# جلوه‌های ویژه
	if mood == "thinking":
		for i in 3:
			var a := clampf(sin(t * 3.0 - i * 0.7) * 0.5 + 0.6, 0.15, 1.0)
			draw_circle(Vector2(46 + i * 14.0, -205 - i * 10.0), 4.0 + i * 2.0, Color(1, 1, 1, a))
			draw_arc(Vector2(46 + i * 14.0, -205 - i * 10.0), 4.0 + i * 2.0, 0, TAU, 12, Color(INK, a), 1.5)
	if mood == "victory" or mood == "excited" or mood == "happy":
		for i in 4:
			var a := t * 2.0 + i * TAU / 4.0
			_star(Vector2(cos(a) * 86.0, -140.0 + sin(a) * 70.0), 7.0 + 3.0 * sin(t * 6.0 + i), Color("f7c531"))
	if mood == "sad":
		draw_circle(hc + Vector2(-34, 8 + fmod(t * 40.0, 36.0)), 4.0, Color("6fb3e6"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _hand(c: Vector2) -> void:
	draw_circle(c, 11.0, SKIN)
	draw_arc(c, 11.0, 0, TAU, 14, SKIN_D, 2.0)

func _arm(shoulder: Vector2, hand: Vector2) -> void:
	draw_line(shoulder, hand, ROBE.lightened(0.1), 20.0)
	_hand(hand)

func _arms(kind: String) -> void:
	var ls := Vector2(-46, -78)
	var rs := Vector2(46, -78)
	match kind:
		"down":
			_arm(ls, Vector2(-64, -26))
			_arm(rs, Vector2(64, -26))
		"clap":
			var s := sin(t * 18.0) * 5.0
			_arm(ls, Vector2(-10 + s, -62))
			_arm(rs, Vector2(10 - s, -62))
		"up":
			var w := sin(t * 10.0) * 8.0
			_arm(ls, Vector2(-78, -158 + w))
			_arm(rs, Vector2(78, -158 - w))
		"up1":
			_arm(ls, Vector2(-64, -26))
			_arm(rs, Vector2(76, -150 + sin(t * 8.0) * 8.0))
		"small":
			_arm(ls, Vector2(-72, -112))
			_arm(rs, Vector2(72, -112))
		"chin":
			_arm(ls, Vector2(-64, -26))
			_arm(rs, Vector2(24, -70))
