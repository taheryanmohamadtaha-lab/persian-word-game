extends Screen

var reset_armed := false

func build() -> void:
	main.bg.set_palette(1)
	back_button("start")
	title_bar("تنظیمات")
	var yy := 110.0
	yy = _toggle("موسیقی", "music", yy)
	yy = _slider("music_vol", yy)
	yy = _music_modes(yy)
	yy = _toggle("جلوه‌های صوتی", "sfx", yy)
	yy = _slider("sfx_vol", yy)
	yy = _toggle("صدای شخصیت", "voice", yy)
	yy = _slider("voice_vol", yy)
	UI.label(self, "کیفیت گرافیک", Vector2(x(360), yy), Vector2(330, 56), 28, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
	var qs := [["low", "کم"], ["mid", "متوسط"], ["high", "زیاد"]]
	for i in 3:
		var q: String = qs[i][0]
		var on: bool = Game.settings["quality"] == q
		var b := UI.button(self, qs[i][1], Vector2(x(30 + (2 - i) * 120), yy), Vector2(110, 56), UI.col("primary") if on else UI.col("secondary"), 24)
		b.pressed.connect(func():
			Game.settings["quality"] = q
			Game.apply_quality()
			Game.save()
			main.go("settings"))
	yy += 80.0
	var lang := UI.button(self, "زبان: فارسی (زبان‌های بیشتر به‌زودی)", Vector2(x(30), yy), Vector2(660, 60), Color("b8b0a4"), 24)
	lang.disabled = true
	yy += 76.0
	var rb := UI.button(self, "بازنشانی اطلاعات بازی", Vector2(x(30), yy), Vector2(660, 70), Color("d9826a"), 28)
	rb.pressed.connect(func():
		if not reset_armed:
			reset_armed = true
			rb.text = "مطمئنی؟ دوباره بزن تا همه‌چیز پاک شود"
			get_tree().create_timer(4.0).timeout.connect(func():
				if is_instance_valid(rb):
					reset_armed = false
					rb.text = "بازنشانی اطلاعات بازی")
		else:
			Game.reset_all()
			main.go("start"))
	UI.label(self, "سازنده: %s" % Game.CREATOR, Vector2(x(60), H - 80.0), Vector2(600, 44), 26, Color("2f4a5a"))

func _music_modes(yy: float) -> float:
	var tracks: Array = Game.MUSIC_TRACKS
	var w := 100.0
	var gap := 4.0
	var total := tracks.size() * w + (tracks.size() - 1) * gap
	for i in tracks.size():
		var id: String = tracks[i][0]
		var on: bool = Game.settings["music_mode"] == id
		var b := UI.button(self, tracks[i][1], Vector2(x(360) + total / 2.0 - w - i * (w + gap), yy), Vector2(w, 56), UI.col("primary") if on else UI.col("secondary"), 21)
		b.pressed.connect(func():
			Game.settings["music_mode"] = id
			Game.save()
			Sfx.music_change()
			main.go("settings"))
	return yy + 74.0

func _toggle(title: String, key: String, yy: float) -> float:
	var on: bool = Game.settings[key]
	var b := UI.button(self, "%s: %s" % [title, "روشن" if on else "خاموش"], Vector2(x(30), yy), Vector2(660, 62), UI.col("primary") if on else Color("c8bfae"), 28)
	b.pressed.connect(func():
		Game.settings[key] = not Game.settings[key]
		Game.save()
		Sfx.music_refresh()
		main.go("settings"))
	return yy + 72.0

func _slider(key: String, yy: float) -> float:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = float(Game.settings[key])
	s.position = Vector2(x(60), yy + 4.0)
	s.size = Vector2(600, 40)
	s.focus_mode = Control.FOCUS_NONE
	var track := UI.style(Color(0.35, 0.25, 0.15, 0.5), 8)
	var fill := UI.style(UI.col("primary"), 8)
	var fill_h := UI.style(UI.col("primary").lightened(0.15), 8)
	for sb in [track, fill, fill_h]:
		sb.content_margin_top = 8.0
		sb.content_margin_bottom = 8.0
	s.add_theme_stylebox_override("slider", track)
	s.add_theme_stylebox_override("grabber_area", fill)
	s.add_theme_stylebox_override("grabber_area_highlight", fill_h)
	s.add_theme_icon_override("grabber", UI.circle_tex(20, Color("fff3d6")))
	s.add_theme_icon_override("grabber_highlight", UI.circle_tex(20, Color("ffd36b")))
	s.value_changed.connect(func(v: float):
		Game.settings[key] = v
		Game.save()
		Sfx.music_refresh())
	add_child(s)
	return yy + 52.0
