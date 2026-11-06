extends Screen
## ظاهر بازی: انتخاب تم رنگی (رنگ بازی و پس‌زمینه) و شخصیت همراه.

const CHAR_IDS := ["kolah", "haji", "mamad", "babri"]

func build() -> void:
	main.bg.set_palette(0)
	back_button("start")
	title_bar("ظاهر بازی")
	UI.label(self, "رنگ بازی و پس‌زمینه", Vector2(x(40), 110), Vector2(640, 44), 28, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
	var ids: Array = Game.THEME_ORDER.duplicate()
	ids.append("auto")
	var cur: String = Game.settings.get("theme", "warm")
	for i in ids.size():
		var id: String = ids[i]
		var r := int(floor(i / 3.0))
		var c := i % 3
		var px := x(40) + (2 - c) * 218.0
		var py := 162.0 + r * 104.0
		var col: Color = Color("e6e0d6") if id == "auto" else Game.THEMES[id]["bg1"]
		var label: String = "خودکار" if id == "auto" else Game.THEMES[id]["name"]
		var on := cur == id
		var b := UI.button(self, label, Vector2(px, py), Vector2(204, 92), col, 24)
		if on:
			b.add_theme_stylebox_override("normal", UI.style(col, 20, UI.INK, 6))
			b.add_theme_stylebox_override("hover", UI.style(col, 20, UI.INK, 6))
			b.text = label + "\n(انتخاب‌شده)"
		b.pressed.connect(func():
			Game.settings["theme"] = id
			Game.save()
			main.go("appearance"))
	var y0 := 162.0 + 2 * 104.0 + 20.0
	UI.label(self, "شخصیت همراه", Vector2(x(40), y0), Vector2(640, 44), 28, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
	var cur_char: String = Game.settings.get("character", "kolah")
	var card_h := minf(330.0, (H - y0 - 70.0 - 60.0) / 2.0)
	for i in CHAR_IDS.size():
		var id: String = CHAR_IDS[i]
		var r := int(floor(i / 2.0))
		var c := i % 2
		var px := x(40) + (1 - c) * 330.0
		var py := y0 + 52.0 + r * (card_h + 12.0)
		var sel := cur_char == id
		var card := UI.panel(self, Vector2(px, py), Vector2(310, card_h), UI.CREAM, 26, UI.INK if sel else UI.GOLD, 7 if sel else 3)
		var hero := Hero.new()
		hero.character = id
		var sc := (card_h - 70.0) / 240.0
		hero.scale = Vector2(sc, sc)
		hero.position = Vector2(155.0 - 100.0 * sc, 4.0)
		card.add_child(hero)
		if sel:
			hero.set_mood("happy")
		UI.label(card, Dialogs.char_name(id) + ("  (انتخاب‌شده)" if sel else ""), Vector2(0, card_h - 62.0), Vector2(310, 54), 24)
		var tap := Button.new()
		tap.flat = true
		tap.position = Vector2(px, py)
		tap.size = Vector2(310, card_h)
		tap.focus_mode = Control.FOCUS_NONE
		tap.pressed.connect(func():
			Game.settings["character"] = id
			Game.save()
			Sfx.play("tap")
			main.go("appearance"))
		add_child(tap)
