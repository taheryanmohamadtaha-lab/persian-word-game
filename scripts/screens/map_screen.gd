extends Screen
## نقشهٔ مرحله‌ها برای گروه سنی و سطح انتخاب‌شده.

func build() -> void:
	main.bg.set_palette(2)
	back_button("choice", {"kind": "diff"})
	title_bar("مرحله‌ها")
	var age := Game.cur_age
	var diff := Game.cur_diff
	UI.label(self, "%s — %s" % [Game.AGES[age], Game.DIFFS[diff]], Vector2(x(60), 100), Vector2(600, 50), 32, Color("5a2a1a"))
	var n := Game.level_count(age, diff)
	if n == 0:
		UI.label(self, "هنوز سؤالی برای این بخش نیست.", Vector2(x(60), 400), Vector2(600, 100), 32)
		return
	var cols := 3
	for i in n:
		var lv := i + 1
		var r := i / cols
		var c := i % cols
		var cnt := mini(cols, n - r * cols)
		var row_w := cnt * 180.0 - 30.0
		var px := x(360) + row_w / 2.0 - 150.0 - c * 180.0
		var py := 200.0 + r * 230.0
		var open := Game.is_unlocked(age, diff, lv)
		var b := UI.button(self, UI.fa(lv) if open else "قفل", Vector2(px, py), Vector2(150, 150), UI.col("primary") if open else Color("a9a39a"), 56 if open else 34)
		b.disabled = not open
		if open:
			b.pressed.connect(func(): main.go("game", {"age": age, "diff": diff, "level": lv}))
			var sv := StarsView.new()
			sv.setup(34.0, Game.stars_of(age, diff, lv))
			sv.position = Vector2(px + 75.0 - sv.size.x / 2.0, py + 160.0)
			add_child(sv)
	UI.label(self, "سکه‌ها: %s    امتیاز کل: %s" % [UI.fa(Game.coins), UI.fa(Game.total_score)], Vector2(x(60), H - 90.0), Vector2(600, 50), 28, Color("5a2a1a"))
