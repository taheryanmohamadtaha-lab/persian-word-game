extends Screen

func build() -> void:
	main.bg.set_palette(2)
	back_button("start")
	title_bar("دستاوردها و امتیازها")
	var stats := UI.panel(self, Vector2(x(30), 100), Vector2(660, 150), UI.CREAM, 26, UI.GOLD, 4)
	var total_stars := 0
	for k in Game.progress:
		for s in Game.progress[k]["stars"].values():
			total_stars += int(s)
	UI.label(stats, "امتیاز کل: %s      سکه‌ها: %s" % [UI.fa(Game.total_score), UI.fa(Game.coins)], Vector2(10, 8), Vector2(640, 60), 30)
	UI.label(stats, "مرحله‌های تمام‌شده: %s      ستاره‌ها: %s" % [UI.fa(Game.completed_levels()), UI.fa(total_stars)], Vector2(10, 74), Vector2(640, 60), 28)
	var yy := 280.0
	for id in Game.ACH:
		var got: bool = Game.achievements.has(id)
		var row := UI.panel(self, Vector2(x(30), yy), Vector2(660, 96), Color("f7d77a") if got else Color(0.75, 0.72, 0.68, 0.7), 24, UI.GOLD if got else Color(0.5, 0.5, 0.5), 3)
		UI.label(row, Game.ACH[id], Vector2(20, 6), Vector2(620, 84), 26, UI.INK if got else Color(UI.INK, 0.55))
		yy += 108.0
