extends Screen
## هستهٔ بازی: حدس کلمه از روی سرنخ. هر حرف درست همهٔ جاهای خودش را پر می‌کند؛ هر حرف اشتباه یک گوی می‌شکند.

const BOX := 88.0
const GAP := 12.0
const ORBS := {"easy": 6, "medium": 5, "hard": 5}
var age := "kids"
var diff := "easy"
var level := 1
var qs: Array = []
var qi := 0
var answer: Array = []
var filled: Array = []   # برای هر خانه حرف یا رشتهٔ خالی
var q_wrong := 0
var used := {}
var letter_btns := {}
var orbs: OrbsView
var overlay: Control = null
var boxes: Array = []
var box_labels: Array = []
var mistakes := 0
var hints_used := 0
var skipped := 0
var level_score := 0
var level_coins := 0
var streak := 0
var locked := false
var q_hints := 0
var q_start := 0.0
var idle := 0.0
var time_left := 60.0
var yextra := 0.0
var hero: Hero
var bubble: Bubble
var cups: CupsView
var counter: Label
var clue_label: Label
var coins_label: Label
var score_label: Label
var timer_label: Label
var boxes_root: Control
var letters_root: Control

func build() -> void:
	age = args.get("age", Game.cur_age)
	diff = args.get("diff", Game.cur_diff)
	level = int(args.get("level", 1))
	var lv := Game.levels_for(age, diff)
	if level < 1 or level > lv.size():
		main.go("map")
		return
	Game.cur_age = age
	Game.cur_diff = diff
	qs = Game.pick_level_questions(age, diff)
	main.bg.set_palette(level)
	Game.last = {"age": age, "diff": diff, "level": level}
	Game.save()
	yextra = maxf(0.0, H - 1280.0)

	back_button("map")
	UI.label(self, "مرحلهٔ %s — %s" % [UI.fa(level), Game.AGES[age]], Vector2(x(170), 34), Vector2(380, 56), 30)
	coins_label = UI.label(self, "", Vector2(x(520), 30), Vector2(160, 34), 24, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
	score_label = UI.label(self, "", Vector2(x(520), 62), Vector2(160, 34), 24, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
	cups = CupsView.new()
	cups.total = qs.size()
	cups.position = Vector2(x(36), 100)
	cups.size = Vector2(260, 64)
	add_child(cups)
	timer_label = UI.label(self, "", Vector2(x(290), 92), Vector2(140, 70), 44, Color("a03020"))
	counter = UI.label(self, "", Vector2(x(380), 100), Vector2(300, 64), 28, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
	var clue_panel := UI.panel(self, Vector2(x(30), 174), Vector2(660, 108), Color("f1b366"), 26, UI.GOLD, 4)
	clue_label = UI.label(clue_panel, "", Vector2(16, 6), Vector2(628, 96), 30)
	var carpet := Carpet.new()
	carpet.position = Vector2(x(60), 296)
	carpet.size = Vector2(600, 230)
	add_child(carpet)
	boxes_root = Control.new()
	boxes_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(boxes_root)
	orbs = OrbsView.new()
	orbs.reset(ORBS[diff])
	orbs.position = Vector2(x(360) - orbs.size.x / 2.0, 536.0)
	add_child(orbs)
	hero = UI.make_hero()
	hero.scale = Vector2(0.9, 0.9)
	hero.position = Vector2(x(0), 612.0 + yextra * 0.4)
	add_child(hero)
	bubble = Bubble.new()
	bubble.size = Vector2(470, 130)
	bubble.position = Vector2(x(215), 650.0 + yextra * 0.4)
	add_child(bubble)
	letters_root = Control.new()
	letters_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(letters_root)
	# نوار دکمه‌های پایین
	var ay := 1180.0 + yextra
	var hb := UI.button(self, "راهنما\n%s سکه" % UI.fa(Game.HINT_COST), Vector2(x(370), ay), Vector2(320, 80), UI.col("primary"), 24)
	hb.pressed.connect(_hint)
	var sb := UI.button(self, "عبور\n−%s امتیاز" % UI.fa(Game.SKIP_COST), Vector2(x(30), ay), Vector2(320, 80), Color("d9826a"), 24)
	sb.pressed.connect(_skip)
	load_question()

func _process(delta: float) -> void:
	if locked or qs.is_empty():
		return
	idle += delta
	if idle > 18.0:
		idle = 0.0
		say(Dialogs.line("idle"), "thinking", 3.0)
	if diff == "hard":
		time_left -= delta
		timer_label.text = UI.fa(maxi(0, int(ceil(time_left))))
		if time_left <= 0.0:
			_on_timeout()

func say(text: String, mood: String, dur: float = 2.5) -> void:
	hero.set_mood(mood, dur)
	bubble.say(text)

func refresh_stats() -> void:
	coins_label.text = "سکه: %s" % UI.fa(Game.coins)
	score_label.text = "امتیاز: %s" % UI.fa(level_score)

func load_question() -> void:
	var q: Dictionary = qs[qi]
	answer = []
	filled = []
	for ch in str(q["answer"]):
		answer.append(ch)
		filled.append("")
	used = {}
	q_wrong = 0
	q_hints = 0
	locked = false
	q_start = Time.get_ticks_msec() / 1000.0
	idle = 0.0
	time_left = 60.0
	clue_label.text = str(q["clue"])
	UI.pop(clue_label, 1.08)
	counter.text = "%s پرسش تا گنجینه" % UI.fa(qs.size() - qi)
	cups.left = qs.size() - qi
	timer_label.visible = diff == "hard"
	orbs.reset(ORBS[diff])
	build_boxes()
	build_letters()
	refresh_stats()
	if qi == 0:
		say(Dialogs.line("greet" if qi == 0 else "progress"), "encourage")
	elif qs.size() - qi == 1:
		say(Dialogs.line("last"), "encourage")
	else:
		say(Dialogs.line("progress"), "normal", 2.0)

func build_boxes() -> void:
	for c in boxes_root.get_children():
		c.queue_free()
	boxes.clear()
	box_labels.clear()
	var n := answer.size()
	var rows: Array = [n]
	if n > 5:
		var first := int(ceil(n / 2.0))
		rows = [first, n - first]
	var cx := x(60) + 300.0
	var total_h := rows.size() * BOX + (rows.size() - 1) * GAP
	var y0 := 296.0 + (230.0 - total_h) / 2.0
	for r in rows.size():
		var cnt: int = rows[r]
		var row_w := cnt * BOX + (cnt - 1) * GAP
		for c in cnt:
			var px := cx + row_w / 2.0 - BOX - c * (BOX + GAP)
			var py := y0 + r * (BOX + GAP)
			var p := UI.panel(boxes_root, Vector2(px, py), Vector2(BOX, BOX), Color("d8bf8c"), 16, Color("7d6338"), 3)
			p.pivot_offset = Vector2(BOX / 2.0, BOX / 2.0)
			boxes.append(p)
			box_labels.append(UI.label(p, "", Vector2.ZERO, Vector2(BOX, BOX), 54))

func build_letters() -> void:
	for c in letters_root.get_children():
		c.queue_free()
	letter_btns.clear()
	var all: Array = Game.ALPHABET
	var cols := 9
	var sz := 66.0
	var pitch := 74.0
	var rows := int(ceil(all.size() / float(cols)))
	var bottom := 1160.0 + yextra
	var top := bottom - rows * pitch + (pitch - sz)
	for i in all.size():
		var r := int(floor(i / float(cols)))
		var c := i % cols
		var cnt := mini(cols, all.size() - r * cols)
		var row_w := cnt * pitch - (pitch - sz)
		var px := x(360) + row_w / 2.0 - sz - c * pitch
		var ch: String = all[i]
		var b := UI.button(letters_root, ch, Vector2(px, top + r * pitch), Vector2(sz, sz), UI.col("letter"), 38, false)
		b.pressed.connect(_on_letter.bind(ch))
		letter_btns[ch] = b

func set_box(i: int, ch: String, tint: Color = Color(0, 0, 0, 0)) -> void:
	box_labels[i].text = ch
	if ch != "":
		UI.pop(boxes[i], 1.18)
	var col := tint if tint.a > 0.0 else Color("d8bf8c")
	boxes[i].add_theme_stylebox_override("panel", UI.style(col, 16, Color("7d6338"), 3))

func _mark_letter(ch: String, good: bool) -> void:
	var b: Button = letter_btns.get(ch)
	if b == null:
		return
	var col := Color("8fd17a") if good else Color("e08a80")
	b.add_theme_stylebox_override("disabled", UI.style(col, 20, col.darkened(0.4), 0, 4))
	b.add_theme_color_override("font_disabled_color", Color(UI.INK, 0.85))
	b.disabled = true

## یک حرف را اعمال می‌کند: درست = همهٔ جاهای آن پر می‌شود، غلط = یک گوی می‌شکند.
func _apply_letter(ch: String, free: bool = false) -> void:
	used[ch] = true
	if answer.has(ch):
		_mark_letter(ch, true)
		Sfx.play("pick")
		for i in answer.size():
			if answer[i] == ch:
				filled[i] = ch
				set_box(i, ch, Color("f2d27a") if free else Color("e9d9a8"))
		if not filled.has(""):
			locked = true
			hero.set_mood("excited", 0.6)
			await get_tree().create_timer(0.45).timeout
			if is_inside_tree():
				_on_correct()
	else:
		_mark_letter(ch, false)
		_break_orb()

func _on_letter(ch: String) -> void:
	if locked or used.has(ch):
		return
	idle = 0.0
	_apply_letter(ch)

func _hint() -> void:
	if locked:
		return
	if Game.coins < Game.HINT_COST:
		say(Dialogs.line("no_coins"), "sad", 2.5)
		return
	var missing: Array = []
	for i in answer.size():
		if filled[i] == "" and not missing.has(answer[i]):
			missing.append(answer[i])
	if missing.is_empty():
		return
	Game.add_coins(-Game.HINT_COST)
	hints_used += 1
	q_hints += 1
	Sfx.play("hint")
	refresh_stats()
	say(str(qs[qi].get("hint", "یه حرف رو برات گذاشتم!")), "encourage", 3.0)
	_apply_letter(missing.pick_random(), true)

func _break_orb() -> void:
	mistakes += 1
	q_wrong += 1
	streak = 0
	orbs.shatter()
	Sfx.play("shatter")
	if q_wrong >= orbs.total:
		_game_over()
		return
	var left := orbs.total - q_wrong
	if left == 1:
		say(Dialogs.line("one_orb"), "surprised", 2.2)
	else:
		say(Dialogs.line("wrong"), "sad", 1.8)

func _game_over() -> void:
	locked = true
	Sfx.play("gameover")
	for i in answer.size():
		if filled[i] == "":
			set_box(i, answer[i], Color("e8a09a"))
	say(Dialogs.line("over"), "sad", 5.0)
	await get_tree().create_timer(1.8).timeout
	if not is_inside_tree():
		return
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)
	var py := H / 2.0 - 230.0
	var panel := UI.panel(overlay, Vector2(x(60), py), Vector2(600, 460), UI.CREAM, 34, Color("c0504a"), 6)
	UI.label(panel, "همهٔ گوی‌ها شکستند!", Vector2(0, 24), Vector2(600, 80), 46, Color("a03020"))
	UI.label(panel, "جواب این بود: %s" % "".join(answer), Vector2(20, 120), Vector2(560, 70), 36)
	UI.label(panel, "مرحله از اول شروع می‌شود.", Vector2(20, 195), Vector2(560, 56), 28)
	var again := UI.button(panel, "شروع دوباره", Vector2(80, 270), Vector2(440, 84), UI.col("primary"), 38)
	again.pressed.connect(func(): main.go("game", {"age": age, "diff": diff, "level": level}))
	var mp := UI.button(panel, "نقشه مرحله‌ها", Vector2(80, 366), Vector2(440, 70), UI.col("secondary"), 30)
	mp.pressed.connect(func(): main.go("map"))
	UI.pop(panel, 0.85)

func _on_correct() -> void:
	var q: Dictionary = qs[qi]
	var elapsed := Time.get_ticks_msec() / 1000.0 - q_start
	if q_wrong == 0:
		streak += 1
	else:
		streak = 0
	var pts := int(round(float(q.get("points", 10)) * float(Game.DIFF_MULT[diff])))
	pts += clampi(int(20.0 - elapsed), 0, 10)
	if q_hints == 0:
		pts += 5
	if q_wrong == 0:
		pts += 5
	pts += mini(maxi(streak - 1, 0), 5) * 2
	level_score += pts
	level_coins += 2
	Game.add_coins(2)
	for i in boxes.size():
		boxes[i].add_theme_stylebox_override("panel", UI.style(Color("a8d98a"), 16, Color("4f7d36"), 3))
	cups.left = qs.size() - qi - 1
	Sfx.play("correct")
	Sfx.play("coin")
	burst(Vector2(x(360), 410))
	float_text("+%s" % UI.fa(pts), Vector2(x(360) - 60.0, 330))
	say(Dialogs.line("correct"), "excited" if streak >= 2 else "happy", 2.0)
	refresh_stats()
	if Game.grant("first_word"):
		toast("دستاورد: اولین کلمه")
	if streak == 3 and Game.grant("streak_3"):
		toast("دستاورد: سه‌تایی")
	await get_tree().create_timer(1.7).timeout
	if is_inside_tree():
		_next()

func _reveal_answer() -> void:
	for i in answer.size():
		set_box(i, answer[i], Color("f2d27a"))

func _skip() -> void:
	if locked:
		return
	locked = true
	skipped += 1
	streak = 0
	level_score = maxi(0, level_score - Game.SKIP_COST)
	_reveal_answer()
	cups.left = qs.size() - qi - 1
	refresh_stats()
	say("%s جواب این بود: %s" % [Dialogs.line("skip"), "".join(answer)], "surprised", 2.5)
	await get_tree().create_timer(2.2).timeout
	if is_inside_tree():
		_next()

func _on_timeout() -> void:
	# پایان وقت (سطح سخت): یک گوی می‌شکند و زمان دوباره از ۶۰ ثانیه شروع می‌شود
	time_left = 60.0
	_break_orb()

func _next() -> void:
	qi += 1
	if qi >= qs.size():
		_finish()
	else:
		load_question()

func _finish() -> void:
	locked = true
	var stars := 1
	if mistakes == 0 and hints_used == 0 and skipped == 0:
		stars = 3
	elif mistakes <= 3 and skipped == 0:
		stars = 2
	if stars == 3:
		level_coins += 5
		Game.add_coins(5)
	Game.complete_level(age, diff, level, stars, level_score)
	var count := Game.level_count(age, diff)
	Game.last = {"age": age, "diff": diff, "level": mini(level + 1, count)}
	Game.save()
	main.go("result", {"age": age, "diff": diff, "level": level, "stars": stars, "score": level_score,
		"coins": level_coins, "mistakes": mistakes, "hints": hints_used, "skipped": skipped})

func burst(pos: Vector2) -> void:
	var amt := int(40.0 * Game.particles_scale())
	if amt <= 0:
		return
	var p := CPUParticles2D.new()
	p.position = pos
	p.amount = amt
	p.lifetime = 1.0
	p.one_shot = true
	p.explosiveness = 1.0
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.initial_velocity_min = 180.0
	p.initial_velocity_max = 420.0
	p.gravity = Vector2(0, 700)
	p.scale_amount_min = 5.0
	p.scale_amount_max = 11.0
	var g := Gradient.new()
	g.colors = PackedColorArray([Color("f7c531"), Color("e8573a"), Color("4fb36a"), Color("4a8fe0")])
	g.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
	p.color_initial_ramp = g
	add_child(p)
	p.emitting = true
	get_tree().create_timer(1.6).timeout.connect(p.queue_free)

func float_text(text: String, pos: Vector2) -> void:
	var l := UI.label(self, text, pos, Vector2(120, 60), 46, Color("1f7a2e"))
	var tw := create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", pos.y - 80.0, 1.0)
	tw.tween_property(l, "modulate:a", 0.0, 1.0)
	tw.chain().tween_callback(l.queue_free)

func toast(text: String) -> void:
	var p := UI.panel(self, Vector2(x(110), 292.0 + 0.0), Vector2(500, 60), Color("fff0b8"), 20, UI.GOLD, 3)
	UI.label(p, text, Vector2.ZERO, Vector2(500, 60), 26)
	p.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.2)
	tw.tween_interval(1.4)
	tw.tween_property(p, "modulate:a", 0.0, 0.3)
	tw.tween_callback(p.queue_free)
