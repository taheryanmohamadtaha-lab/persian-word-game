extends Screen
## صفحهٔ موفقیت در مرحله و صفحهٔ پایان بخش.

func build() -> void:
	var age: String = args["age"]
	var diff: String = args["diff"]
	var level: int = args["level"]
	var stars: int = args["stars"]
	var count := Game.level_count(age, diff)
	var is_last := level >= count
	main.bg.set_palette(3)
	Sfx.play("win")
	if Game.particles_scale() > 0.0:
		_confetti()
	var top := 90.0
	UI.label(self, "همهٔ مرحله‌های این بخش تمام شد!" if is_last else "آفرین! مرحله تمام شد!", Vector2(x(40), top), Vector2(640, 110), 44, Color("7a2a1a"))
	var sv := StarsView.new()
	sv.setup(110.0, stars, true)
	sv.position = Vector2(x(360) - sv.size.x / 2.0, top + 120.0)
	add_child(sv)
	var hero := Hero.new()
	hero.position = Vector2(x(10), 420)
	hero.scale = Vector2(1.3, 1.3)
	add_child(hero)
	hero.set_mood("victory")
	var info := UI.panel(self, Vector2(x(290), 430), Vector2(400, 300), UI.CREAM, 28, UI.GOLD, 4)
	var rows := [["امتیاز مرحله", UI.fa(args["score"])], ["سکهٔ گرفته‌شده", UI.fa(args["coins"])],
		["اشتباه‌ها", UI.fa(args["mistakes"])], ["راهنماها", UI.fa(args["hints"])]]
	for i in rows.size():
		UI.label(info, rows[i][0], Vector2(200, 14 + i * 70.0), Vector2(190, 60), 26, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
		UI.label(info, rows[i][1], Vector2(10, 14 + i * 70.0), Vector2(180, 60), 34, Color("1f7a2e"), HORIZONTAL_ALIGNMENT_LEFT)
	var bubble := Bubble.new()
	bubble.size = Vector2(340, 110)
	bubble.position = Vector2(x(320), 760)
	add_child(bubble)
	bubble.say("آفرین قهرمان! تو واقعاً گنجینه رو پیدا کردی!" if stars == 3 else "خیلی خوب بود! دفعه بعد بهتر هم می‌شه!")
	var y := maxf(920.0, H - 330.0)
	if not is_last:
		var nb := UI.button(self, "مرحلهٔ بعد", Vector2(x(150), y), Vector2(420, 90), Color("6fbf5a"), 40)
		nb.pressed.connect(func(): main.go("game", {"age": age, "diff": diff, "level": level + 1}))
		Sfx.play("unlock")
		y += 106.0
	else:
		var ob := UI.button(self, "انتخاب بخش دیگر", Vector2(x(150), y), Vector2(420, 90), Color("6fbf5a"), 38)
		ob.pressed.connect(func(): main.go("choice", {"kind": "age"}))
		y += 106.0
	var rb := UI.button(self, "تکرار مرحله", Vector2(x(60), y), Vector2(290, 74), Color("f0a64a"), 28)
	rb.pressed.connect(func(): main.go("game", {"age": age, "diff": diff, "level": level}))
	var mb := UI.button(self, "نقشه مرحله‌ها", Vector2(x(370), y), Vector2(290, 74), Color("d9b36a"), 28)
	mb.pressed.connect(func(): main.go("map"))

func _confetti() -> void:
	var p := CPUParticles2D.new()
	p.position = Vector2(W / 2.0, -10)
	p.amount = int(60.0 * Game.particles_scale())
	p.lifetime = 3.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(W / 2.0, 4)
	p.direction = Vector2(0, 1)
	p.spread = 25.0
	p.gravity = Vector2(0, 160)
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 200.0
	p.scale_amount_min = 5.0
	p.scale_amount_max = 10.0
	var g := Gradient.new()
	g.colors = PackedColorArray([Color("f7c531"), Color("e8573a"), Color("4fb36a"), Color("4a8fe0")])
	g.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
	p.color_initial_ramp = g
	add_child(p)
