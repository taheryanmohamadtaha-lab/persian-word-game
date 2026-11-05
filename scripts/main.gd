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
}
var bg: Background
var cur: Control = null

func _ready() -> void:
	bg = Background.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	Sfx.music_start()
	go("start")

func go(screen_name: String, args: Dictionary = {}) -> void:
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
