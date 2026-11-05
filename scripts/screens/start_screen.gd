extends Screen

func build() -> void:
	main.bg.set_palette(0)
	if Game.particles_scale() > 0.0:
		var letters := ["ک", "ل", "م", "ه", "ب", "ا", "ر", "س", "ت", "ن", "ی", "و"]
		for i in letters.size():
			var l := UI.label(self, letters[i], Vector2(randf() * (W - 60.0), 60.0 + randf() * (H - 160.0)), Vector2(60, 60), 48, Color(0.35, 0.25, 0.12, 0.22))
			var y0 := l.position.y
			var tw := create_tween().set_loops()
			tw.tween_property(l, "position:y", y0 - 40.0, randf_range(2.0, 4.0)).set_trans(Tween.TRANS_SINE)
			tw.tween_property(l, "position:y", y0, randf_range(2.0, 4.0)).set_trans(Tween.TRANS_SINE)
	var ribbon := UI.panel(self, Vector2(x(50), 80), Vector2(620, 190), UI.CREAM, 36, UI.GOLD, 6)
	UI.label(ribbon, "بازی با کلمات", Vector2(0, 14), Vector2(620, 110), 76, Color("7a2a1a"))
	UI.label(ribbon, "با یک دوست خوش‌مشرب", Vector2(0, 118), Vector2(620, 54), 28, UI.INK)
	UI.pop(ribbon, 1.15)
	var hero := Hero.new()
	hero.position = Vector2(x(30), 300)
	hero.scale = Vector2(1.5, 1.5)
	add_child(hero)
	hero.set_mood("encourage", 4.0)
	var bubble := Bubble.new()
	bubble.size = Vector2(340, 160)
	bubble.position = Vector2(x(350), 380)
	add_child(bubble)
	bubble.say("سلام! بیا با هم کلمه بسازیم!", false)
	var y := maxf(700.0, H * 0.55)
	var start := UI.button(self, "شروع بازی", Vector2(x(150), y), Vector2(420, 104), Color("6fbf5a"), 46)
	start.pressed.connect(func(): main.go("choice", {"kind": "age"}))
	var yy := y + 124.0
	if Game.last.size() > 0 and Game.level_count(Game.last.get("age", ""), Game.last.get("diff", "")) > 0:
		var cont := UI.button(self, "ادامه بازی", Vector2(x(150), yy), Vector2(420, 84), Color("f0a64a"), 36)
		cont.pressed.connect(func(): main.go("game", Game.last))
		yy += 104.0
	var b1 := UI.button(self, "دستاوردها", Vector2(x(40), yy), Vector2(200, 74), Color("d9b36a"), 28)
	var b2 := UI.button(self, "تنظیمات", Vector2(x(260), yy), Vector2(200, 74), Color("d9b36a"), 28)
	var b3 := UI.button(self, "راهنما", Vector2(x(480), yy), Vector2(200, 74), Color("d9b36a"), 28)
	b1.pressed.connect(func(): main.go("achievements"))
	b2.pressed.connect(func(): main.go("settings"))
	b3.pressed.connect(func(): main.go("help"))
	UI.label(self, "نسخهٔ ۰٫۱ — ساخته‌شده برای گوشی و تبلت", Vector2(x(60), H - 80.0), Vector2(600, 40), 20, Color(UI.INK, 0.7))
