extends Control
## مدیر صفحه‌ها: پس‌زمینهٔ ثابت + صفحهٔ فعلی.

const SCREENS := {
	"start": preload("res://scripts/screens/start_screen.gd"),
	"choice": preload("res://scripts/screens/choice_screen.gd"),
	"map": preload("res://scripts/screens/map_screen.gd"),
	"game": preload("res://scripts/screens/game_screen.gd"),
	"result": preload("res://scripts/screens/result_screen.gd"),
	"achievements": preload("res://scripts/screens/achievements_screen.gd"),
	"settings": preload("res://scripts/screens/settings_screen.gd"),
	"help": preload("res://scripts/screens/help_screen.gd"),
	"appearance": preload("res://scripts/screens/appearance_screen.gd"),
}
var bg: Background
var cur: Control = null
var cur_name := "start"
var exit_overlay: Control = null

func _ready() -> void:
	bg = Background.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	Sfx.music_start()
	go("start")

func go(screen_name: String, args: Dictionary = {}) -> void:
	cur_name = screen_name
	if exit_overlay != null:
		exit_overlay.queue_free()
		exit_overlay = null
	if cur != null:
		cur.queue_free()
	var s := Screen.new()
	s.set_script(SCREENS[screen_name])
	s.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(s)
	cur = s
	s.setup(self, args)
	s.modulate.a = 0.0
	create_tween().tween_property(s, "modulate:a", 1.0, 0.25)

const BACK_TARGETS := {"choice": "start", "map": "choice", "game": "map", "result": "map",
	"achievements": "start", "settings": "start", "help": "start", "appearance": "start"}

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if exit_overlay != null:
			close_exit()
		elif cur_name == "start" or not BACK_TARGETS.has(cur_name):
			ask_exit()
		else:
			var target: String = BACK_TARGETS[cur_name]
			go(target, {"kind": "diff"} if target == "choice" else {})

func close_exit() -> void:
	if exit_overlay != null:
		exit_overlay.queue_free()
		exit_overlay = null

func ask_exit() -> void:
	if exit_overlay != null:
		return
	var vs := get_viewport_rect().size
	exit_overlay = Control.new()
	exit_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	exit_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(exit_overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	exit_overlay.add_child(dim)
	var ox := (vs.x - 720.0) / 2.0
	var panel := UI.panel(exit_overlay, Vector2(ox + 70.0, vs.y / 2.0 - 190.0), Vector2(580, 380), UI.CREAM, 34, UI.GOLD, 6)
	UI.label(panel, "از بازی خارج می‌شوی؟", Vector2(0, 30), Vector2(580, 90), 42)
	UI.label(panel, "پیشرفتت ذخیره شده است.", Vector2(0, 120), Vector2(580, 50), 26)
	var yes := UI.button(panel, "خروج", Vector2(300, 210), Vector2(240, 90), Color("d9826a"), 36)
	yes.pressed.connect(func(): get_tree().quit())
	var no := UI.button(panel, "ادامه بازی", Vector2(40, 210), Vector2(240, 90), UI.col("primary"), 32)
	no.pressed.connect(close_exit)
	UI.pop(panel, 0.85)
