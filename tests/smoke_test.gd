extends SceneTree
## تست دودی: اجرا با  godot --headless --path . -s tests/smoke_test.gd
## کل جریان بازی (منوها، یک مرحله کامل، اشتباه، راهنما، عبور، ذخیره) را بدون رابط گرافیکی اجرا می‌کند.

var fails := 0
var main: Node

func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK   ", msg)
	else:
		fails += 1
		print("  FAIL ", msg)

func wait(sec: float) -> void:
	await create_timer(sec).timeout

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = root.get_node("Game")
	game.reset_all()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	print("== داده")
	check(game.questions.size() == 54, "۵۴ سؤال بارگذاری شد (%d)" % game.questions.size())
	for age in game.AGES:
		for diff in game.DIFFS:
			check(game.level_count(age, diff) >= 2, "%s/%s حداقل ۲ مرحله دارد" % [age, diff])
	print("== صفحه‌ها")
	for s in [["start", {}], ["choice", {"kind": "age"}], ["choice", {"kind": "diff"}], ["map", {}],
			["achievements", {}], ["settings", {}], ["help", {}]]:
		main.go(s[0], s[1])
		await process_frame
		await process_frame
		check(is_instance_valid(main.cur) and main.cur.get_child_count() > 0, "صفحهٔ %s ساخته شد" % s[0])
	print("== مجموعهٔ حروف (همهٔ سؤال‌ها قابل حل)")
	var gs_script = load("res://scripts/screens/game_screen.gd")
	var probe = Screen.new()
	probe.set_script(gs_script)
	var ok_all := true
	for q in game.questions:
		for d in ["easy", "medium", "hard"]:
			probe.diff = d
			var set_: Array = probe.letter_set(q["answer"])
			for ch in q["answer"]:
				if not set_.has(ch):
					ok_all = false
					print("    حرف ", ch, " در ", q["id"], " نیست")
	check(ok_all, "حروف پاسخ همیشه در مجموعهٔ حروف است")
	probe.diff = "hard"
	check(probe.letter_set("ماه").size() == 33, "سطح سخت: همهٔ ۳۳ حرف")
	probe.free()
	print("== بازی کودکان/آسان مرحله ۱")
	main.go("game", {"age": "kids", "diff": "easy", "level": 1})
	await process_frame
	await process_frame
	var g = main.cur
	check(g.qs.size() == 3 and g.boxes.size() == g.answer.size(), "مرحله و خانه‌ها ساخته شد")
	# اشتباه
	var wrong_letters: Array = ["ز", "ژ", "ظ"]
	var n: int = g.answer.size()
	for i in n:
		g._on_letter(wrong_letters[i % 3] if g.answer[i] != wrong_letters[i % 3] else "ض")
	await wait(1.6)
	check(g.mistakes == 1 and g.filled.size() == 0 and not g.locked, "پاسخ اشتباه: شمارش اشتباه و پاک‌سازی")
	# حذف حرف و پاک‌کردن
	g._on_letter(g.answer[0])
	g._on_letter(g.answer[1])
	g._delete_last()
	check(g.filled.size() == 1, "حذف آخرین حرف")
	g._clear_all()
	check(g.filled.size() == 0, "پاک‌کردن همه")
	# راهنما
	var coins_before: int = game.coins
	g._hint()
	check(g.filled.size() == 1 and g.filled[0] == g.answer[0] and game.coins == coins_before - 5, "راهنما: یک حرف درست و ۵ سکه کم شد")
	g._clear_all()
	check(g.filled.size() == 1, "حرف راهنما پاک نمی‌شود")
	for i in range(1, g.answer.size()):
		g._on_letter(g.answer[i])
	await wait(2.4)
	check(g.qi == 1 and g.level_score > 0, "پاسخ درست: رفتن به سؤال بعد و امتیاز (%d)" % g.level_score)
	check(game.achievements.has("first_word"), "دستاورد اولین کلمه")
	# عبور
	var score_before: int = g.level_score
	g._skip()
	await wait(2.6)
	check(g.qi == 2 and g.skipped == 1 and g.level_score == maxi(0, score_before - 10), "عبور: ده امتیاز کم شد")
	# سؤال آخر درست
	for ch in g.answer:
		g._on_letter(ch)
	await wait(2.4)
	var r = main.cur
	check(r != g and r.args.has("stars"), "صفحهٔ نتیجه نمایش داده شد")
	check(game.is_unlocked("kids", "easy", 2), "مرحلهٔ ۲ باز شد")
	check(game.achievements.has("level_done"), "دستاورد گام اول")
	print("== ذخیره و بازیابی")
	var saved_coins: int = game.coins
	game.load_save()
	check(game.coins == saved_coins and game.is_unlocked("kids", "easy", 2), "ذخیره/بازیابی پیشرفت")
	print("== سطح سخت (زمان‌دار)")
	main.go("game", {"age": "adults", "diff": "hard", "level": 1})
	await process_frame
	await process_frame
	g = main.cur
	check(g.letters_root.get_child_count() == 33, "۳۳ دکمهٔ حرف")
	g.time_left = 0.05
	await wait(3.2)
	check(g.mistakes == 1 and g.qi == 1, "پایان زمان: اشتباه ثبت و سؤال بعد")
	print("== نتیجه: ", "همه موفق" if fails == 0 else "%d شکست" % fails)
	quit(1 if fails > 0 else 0)
