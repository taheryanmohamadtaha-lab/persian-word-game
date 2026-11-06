class_name Screen
extends Control
## پایهٔ همهٔ صفحه‌ها: ابعاد، فاصلهٔ افقی (برای تبلت) و تابع build.

var main
var args := {}
var W := 720.0
var H := 1280.0
var ox := 0.0

func setup(m, a: Dictionary = {}) -> void:
	main = m
	args = a
	var vs := get_viewport_rect().size
	W = vs.x
	H = vs.y
	ox = (W - 720.0) / 2.0
	mouse_filter = Control.MOUSE_FILTER_PASS
	build()

func build() -> void:
	pass

func x(v: float) -> float:
	return ox + v

func back_button(target: String, target_args: Dictionary = {}) -> Button:
	var b := UI.button(self, "بازگشت", Vector2(x(40), 36), Vector2(120, 60), UI.col("secondary"), 24)
	b.pressed.connect(func(): main.go(target, target_args))
	return b

func title_bar(text: String) -> void:
	UI.label(self, text, Vector2(x(180), 34), Vector2(360, 62), 36)
