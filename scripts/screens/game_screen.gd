extends Screen
## هستهٔ بازی: حدس کلمه از روی سرنخ با لمس حروف.

const BOX := 88.0
const GAP := 12.0
const DIALOGS := {
	"wrong": ["ای بابا! این یکی درست نبود!", "یه بار دیگه امتحان کن!", "نه نه! یه کم بیشتر فکر کن!", "نزدیک بودی! دوباره تلاش کن!"],
	"correct": ["آفرین! درست گفتی!", "باریکلا! چه باهوشی!", "عالی بود! بریم سراغ بعدی!", "آفرین قهرمان!"],
	"progress": ["تو داری عالی پیش می‌ری!", "ببینم این یکی رو هم می‌تونی حل کنی؟", "حواست رو جمع کن، سرنخ رو دقیق بخون!"],
}

var age := "kids"
var diff := "easy"
var level := 1
var qs: Array = []
var qi := 0
var answer: Array = []
var filled: Array = []
var fixed := 0
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
	qs = lv[level - 1]
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
	hero = Hero.new()
	hero.scale = Vector2(0.85, 0.85)
	hero.position = Vector2(x(0), 535.0 + yextra * 0.4)
	add_child(hero)
	bubble = Bubble.new()
	bubble.size = Vector2(500, 130)
	bubble.position = Vector2(x(200), 570.0 + yextra * 0.4)
	add_child(bubble)
	letters_root = Control.new()
	letters_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(letters_root)
	# نوار دکمه‌های پایین (از راست به چپ)
	var ay := 1180.0 + yextra
	var acts := [["حذف حرف", Color("e8b04a"), _delete_last], ["پاک‌کردن", Color("e8b04a"), _clear_all],
		["راهنما\n%s سکه" % UI.fa(Game.HINT_COST), Color("6fbf5a"), _hint], ["عبور\n−%s امتیاز" % UI.fa(Game.SKIP_COST), Color("d9826a"), _skip]]
	for i in acts.size():
		var b := UI.button(self, acts[i][0], Vector2(x(540.0 - i * 170.0), ay), Vector2(150, 80), acts[i][1], 22)
		b.pressed.connect(acts[i][2])
	load_question()

func _process(delta: float) -> void:
	if locked or qs.is_empty():
		return
	idle += delta
	if idle > 18.0:
		idle = 0.0
		say("هوم... بذار با هم فکر کنیم!", "thinking", 3.0)
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
	for ch in str(q["answer"]):
		answer.append(ch)
	filled = []
	fixed = 0
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
	build_boxes()
	build_letters(str(q["answer"]))
	refresh_stats()
	if qi == 0:
		say("ببینم این مرحله رو هم می‌تونی حل کنی؟", "encourage")
	elif qs.size() - qi == 1:
		say("فقط یه کلمه دیگه مونده!", "encourage")
	else:
		say(DIALOGS["progress"].pick_random(), "normal", 2.0)

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

func letter_set(ans: String) -> Array:
	var all: Array = Game.ALPHABET.duplicate()
	if diff == "hard":
		return all
	var need := {}
	for ch in ans:
		need[ch] = true
	var others: Array = all.filter(func(c): return not need.has(c))
	others.shuffle()
	var chosen: Array = need.keys()
	chosen.append_array(others.slice(0, 6 if diff == "easy" else 12))
	chosen.sort_custom(func(a, b): return all.find(a) < all.find(b))
	return chosen

func build_letters(ans: String) -> void:
	for c in letters_root.get_children():
		c.queue_free()
	var chosen := letter_set(ans)
	var big := chosen.size() <= 24
	var cols := 6 if big else 7
	var sz := 96.0 if big else 76.0
	var pitch := sz + (10.0 if big else 8.0)
	var rows := int(ceil(chosen.size() / float(cols)))
	var bottom := 1160.0 + yextra
	var top := bottom - rows * pitch + (pitch - sz)
	for i in chosen.size():
		var r := int(floor(i / float(cols)))
		var c := i % cols
		var cnt := mini(cols, chosen.size() - r * cols)
		var row_w := cnt * pitch - (pitch - sz)
		var px := x(360) + row_w / 2.0 - sz - c * pitch
		var ch: String = chosen[i]
		var b := UI.button(letters_root, ch, Vector2(px, top + r * pitch), Vector2(sz, sz), Color("ead6a4"), 52 if big else 42, false)
		b.pressed.connect(_on_letter.bind(ch))

func set_box(i: int, ch: String, tint: Color = Color(0, 0, 0, 0)) -> void:
	box_labels[i].text = ch
	if ch != "":
		UI.pop(boxes[i], 1.18)
	var col := tint if tint.a > 0.0 else Color("d8bf8c")
	boxes[i].add_theme_stylebox_override("panel", UI.style(col, 16, Color("7d6338"), 3))

func _on_letter(ch: String) -> void:
	if locked or filled.size() >= answer.size():
		return
	idle = 0.0
	Sfx.play("pick")
	filled.append(ch)
	set_box(filled.size() - 1, ch, Color("e9d9a8"))
	if filled.size() == answer.size():
		locked = true
		hero.set_mood("excited", 0.6)
		await get_tree().create_timer(0.35).timeout
		if is_inside_tree():
			_check()

func _delete_last() -> void:
	if locked or filled.size() <= fixed:
		return
	Sfx.play("delete")
	filled.pop_back()
	set_box(filled.size(), "")

func _clear_all() -> void:
	if locked:
		return
	Sfx.play("delete")
	while filled.size() > fixed:
		filled.pop_back()
		set_box(filled.size(), "")

func _hint() -> void:
	if locked:
		return
	if Game.coins < Game.HINT_COST:
		say("سکه‌هات کافی نیست! چند تا سؤال دیگه حل کن.", "sad", 2.5)
		return
	var k := 0
	while k < filled.size() and k < answer.size() and filled[k] == answer[k]:
		k += 1
	while filled.size() > k:
		filled.pop_back()
		set_box(filled.size(), "")
	Game.add_coins(-Game.HINT_COST)
	hints_used += 1
	q_hints += 1
	Sfx.play("hint")
	filled.append(answer[k])
	fixed = filled.size()
	set_box(k, answer[k], Color("f2d27a"))
	refresh_stats()
	say(str(qs[qi].get("hint", "یه حرف رو برات گذاشتم!")), "encourage", 3.0)
	if filled.size() == answer.size():
		locked = true
		await get_tree().create_timer(0.5).timeout
		if is_inside_tree():
			_check()

func _check() -> void:
	if "".join(filled) == "".join(answer):
		_on_correct()
	else:
		_on_wrong()

func _on_correct() -> void:
	var q: Dictionary = qs[qi]
	var elapsed := Time.get_ticks_msec() / 1000.0 - q_start
	streak += 1
	var pts := int(round(float(q.get("points", 10)) * float(Game.DIFF_MULT[diff])))
	pts += clampi(int(20.0 - elapsed), 0, 10)
	if q_hints == 0:
		pts += 5
	pts += mini(streak - 1, 5) * 2
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
	say(DIALOGS["correct"].pick_random(), "excited" if streak >= 2 else "happy", 2.0)
	refresh_stats()
	if Game.grant("first_word"):
		toast("دستاورد: اولین کلمه")
	if streak == 3 and Game.grant("streak_3"):
		toast("دستاورد: سه‌تایی")
	await get_tree().create_timer(1.7).timeout
	if is_inside_tree():
		_next()

func _on_wrong() -> void:
	mistakes += 1
	streak = 0
	Sfx.play("wrong")
	say(DIALOGS["wrong"].pick_random(), "sad", 2.2)
	for i in range(fixed, boxes.size()):
		boxes[i].add_theme_stylebox_override("panel", UI.style(Color("e8a09a"), 16, Color("9a4a40"), 3))
	var tw := create_tween()
	for k in 4:
		tw.tween_property(boxes_root, "position:x", 10.0 if k % 2 == 0 else -10.0, 0.05)
	tw.tween_property(boxes_root, "position:x", 0.0, 0.05)
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree():
		return
	while filled.size() > fixed:
		filled.pop_back()
		set_box(filled.size(), "")
	locked = false

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
	say("جواب این بود: %s" % "".join(answer), "surprised", 2.5)
	await get_tree().create_timer(2.2).timeout
	if is_inside_tree():
		_next()

func _on_timeout() -> void:
	locked = true
	mistakes += 1
	streak = 0
	Sfx.play("wrong")
	_reveal_answer()
	cups.left = qs.size() - qi - 1
	say("وقت تمام شد! جواب این بود: %s" % "".join(answer), "sad", 2.5)
	await get_tree().create_timer(2.4).timeout
	if is_inside_tree():
		_next()

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
	elif mistakes <= 2 and skipped == 0:
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
