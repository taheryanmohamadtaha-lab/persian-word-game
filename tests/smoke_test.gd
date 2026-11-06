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
	check(game.questions.size() == 270, "۲۷۰ سؤال بارگذاری شد (%d)" % game.questions.size())
	for age in game.AGES:
		for diff in game.DIFFS:
			check(game.level_count(age, diff) >= 6, "%s/%s حداقل ۶ مرحله دارد" % [age, diff])
	print("== صفحه‌ها")
	for s in [["start", {}], ["choice", {"kind": "age"}], ["choice", {"kind": "diff"}], ["map", {}],
			["achievements", {}], ["settings", {}], ["help", {}], ["appearance", {}]]:
		main.go(s[0], s[1])
		await process_frame
		await process_frame
		check(is_instance_valid(main.cur) and main.cur.get_child_count() > 0, "صفحهٔ %s ساخته شد" % s[0])
	print("== سؤال‌های تصادفی و بدون تکرار")
	var a: Array = game.pick_level_questions("teens", "easy")
	var b: Array = game.pick_level_questions("teens", "easy")
	var ids_a: Array = a.map(func(q): return q["id"])
	var ids_b: Array = b.map(func(q): return q["id"])
	var overlap := 0
	for i in ids_b:
		if ids_a.has(i):
			overlap += 1
	check(a.size() == 5 and b.size() == 5 and overlap == 0, "دو شروع پشت‌سرهم: سؤال‌ها کاملاً متفاوت‌اند")
	var all_ok := true
	for k in 12:
		var c: Array = game.pick_level_questions("teens", "easy")
		var uniq := {}
		for q in c:
			uniq[q["id"]] = true
		if c.size() != 5 or uniq.size() != 5:
			all_ok = false
	check(all_ok, "پس از تمام شدن سؤال‌ها هم هر مرحله ۵ سؤال غیرتکراری دارد")
	var order_differs := false
	var first: Array = game.pick_level_questions("adults", "hard").map(func(q): return q["id"])
	for k in 5:
		if game.pick_level_questions("adults", "hard").map(func(q): return q["id"]) != first:
			order_differs = true
	check(order_differs, "ترکیب سؤال‌ها هر بار فرق می‌کند")
	game.seen = {}
	print("== شخصیت‌ها، تم و موسیقی")
	for ch in ["kolah", "haji", "mamad", "babri"]:
		var ok := true
		for key in ["greet", "correct", "wrong", "progress", "last", "one_orb", "over", "no_coins", "idle", "skip", "win3", "win"]:
			if Dialogs.line(key, ch) == "":
				ok = false
		check(ok and Dialogs.char_name(ch) != "", "شخصیت %s: همهٔ دیالوگ‌ها موجود است" % ch)
		game.settings["character"] = ch
		main.go("start")
		await process_frame
		check(is_instance_valid(main.cur) and main.cur.get_child_count() > 0, "صفحهٔ شروع با شخصیت %s" % ch)
	game.settings["character"] = "kolah"
	game.settings["theme"] = "auto"
	var t0: Color = game.theme()["bg0"]
	game.auto_idx = 1
	check(game.theme()["bg0"] != t0, "تم خودکار با مرحله عوض می‌شود")
	for tid in game.THEMES:
		game.settings["theme"] = tid
		check(game.theme()["name"] == game.THEMES[tid]["name"], "تم %s" % tid)
	game.settings["theme"] = "warm"
	game.auto_idx = 0
	for t in game.MUSIC_TRACKS:
		game.settings["music_mode"] = t[0]
		root.get_node("Sfx").music_change()
		if t[0] != "shuffle":
			check(root.get_node("Sfx").current_track() == t[0], "پخش آهنگ %s" % t[0])
		else:
			check(root.get_node("Sfx").current_track() != "", "حالت تصادفی آهنگی انتخاب کرد")
	game.settings["music_mode"] = "shuffle"
	print("== دکمهٔ خروج")
	main.go("start")
	await process_frame
	main.ask_exit()
	check(main.exit_overlay != null, "پنجرهٔ تأیید خروج باز شد")
	main.close_exit()
	check(main.exit_overlay == null, "ادامهٔ بازی پنجره را بست")
	print("== بازی کودکان/آسان مرحله ۱")
	main.go("game", {"age": "kids", "diff": "easy", "level": 1})
	await process_frame
	await process_frame
	var g = main.cur
	check(g.qs.size() == 5 and g.boxes.size() == g.answer.size(), "مرحله (۵ سؤال) و خانه‌ها ساخته شد")
	for q in game.questions:
		if q["id"] == "k-e-004":
			g.qs[3] = q
	check(g.letters_root.get_child_count() == 33, "همهٔ ۳۳ حرف الفبا نمایش داده می‌شود")
	check(g.orbs.total == 6, "سطح آسان: ۶ گوی")
	# حرف اشتباه
	var wrong_ch := ""
	for ch in game.ALPHABET:
		if not g.answer.has(ch):
			wrong_ch = ch
			break
	g._on_letter(wrong_ch)
	check(g.orbs.broken == 1 and g.mistakes == 1, "حرف اشتباه: یک گوی شکست")
	g._on_letter(wrong_ch)
	check(g.orbs.broken == 1 and g.mistakes == 1, "حرف تکراری جریمه ندارد")
	# حرف درست
	g._on_letter(g.answer[0])
	check(g.filled[0] == g.answer[0], "حرف درست در خانه نشست")
	# راهنما
	var coins_before: int = game.coins
	var filled_before: int = g.filled.count("")
	g._hint()
	check(game.coins == coins_before - 5 and g.filled.count("") < filled_before, "راهنما: یک حرف درست و ۵ سکه کم شد")
	await _solve(g)
	await wait(2.6)
	check(g.qi == 1 and g.level_score > 0, "پاسخ درست: رفتن به سؤال بعد و امتیاز (%d)" % g.level_score)
	check(game.achievements.has("first_word"), "دستاورد اولین کلمه")
	# عبور
	var score_before: int = g.level_score
	g._skip()
	await wait(2.6)
	check(g.qi == 2 and g.skipped == 1 and g.level_score == maxi(0, score_before - 10), "عبور: ده امتیاز کم شد")
	await _solve(g)
	await wait(2.6)
	check(g.qi == 3, "سؤال سوم حل شد")
	# حرف تکراری در کلمه: همهٔ خانه‌ها با هم پر شوند
	var dup := ""
	for ch in g.answer:
		if g.answer.count(ch) > 1:
			dup = ch
			break
	check(dup != "", "کلمهٔ «%s» حرف تکراری دارد" % "".join(g.answer))
	g._on_letter(dup)
	var cnt := 0
	for c in g.filled:
		if c == dup:
			cnt += 1
	check(cnt == g.answer.count(dup) and cnt >= 2, "یک لمس، همهٔ خانه‌های همان حرف را پر کرد (%d خانه)" % cnt)
	await _solve(g)
	await wait(2.6)
	check(g.qi == 4, "سؤال چهارم حل شد")
	await _solve(g)
	await wait(2.6)
	var r = main.cur
	check(r != g and r.args.has("stars"), "صفحهٔ نتیجه نمایش داده شد")
	check(game.is_unlocked("kids", "easy", 2), "مرحلهٔ ۲ باز شد")
	check(game.achievements.has("level_done"), "دستاورد گام اول")
	print("== ذخیره و بازیابی")
	var saved_coins: int = game.coins
	game.load_save()
	check(game.coins == saved_coins and game.is_unlocked("kids", "easy", 2), "ذخیره/بازیابی پیشرفت")
	print("== شکستن همهٔ گوی‌ها و شروع دوباره")
	main.go("game", {"age": "kids", "diff": "easy", "level": 2})
	await process_frame
	await process_frame
	g = main.cur
	for ch in game.ALPHABET:
		if g.locked:
			break
		if not g.answer.has(ch):
			g._on_letter(ch)
	check(g.orbs.broken == g.orbs.total and g.locked, "همهٔ گوی‌ها شکست و بازی قفل شد")
	await wait(2.4)
	check(g.overlay != null and is_instance_valid(g.overlay), "پیام «شروع دوباره» نمایش داده شد")
	main.go("game", {"age": "kids", "diff": "easy", "level": 2})
	await process_frame
	await process_frame
	g = main.cur
	check(g.qi == 0 and g.orbs.broken == 0 and not g.locked, "مرحله از اول شروع شد")
	print("== سطح سخت (زمان‌دار)")
	main.go("game", {"age": "adults", "diff": "hard", "level": 1})
	await process_frame
	await process_frame
	g = main.cur
	check(g.orbs.total == 5, "سطح سخت: ۵ گوی")
	g.time_left = 0.05
	await wait(0.4)
	check(g.mistakes == 1 and g.orbs.broken == 1 and not g.locked, "پایان وقت: یک گوی شکست")
	print("== نتیجه: ", "همه موفق" if fails == 0 else "%d شکست" % fails)
	quit(1 if fails > 0 else 0)

func _solve(g) -> void:
	var seen := {}
	for ch in g.answer:
		if seen.has(ch):
			continue
		seen[ch] = true
		if not g.used.has(ch):
			g._on_letter(ch)
