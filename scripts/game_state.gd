extends Node
## وضعیت کلی بازی: سؤال‌ها، مرحله‌ها، امتیاز، سکه، پیشرفت، تنظیمات و ذخیره‌سازی.

const SAVE_PATH := "user://save_v1.json"
const LEVEL_SIZE := 3
const QUESTION_DIR := "res://data/questions/"
const AGES := {"kids": "کودکان", "teens": "نوجوانان", "adults": "بزرگسالان"}
const DIFFS := {"easy": "آسان", "medium": "متوسط", "hard": "سخت"}
const DIFF_MULT := {"easy": 1.0, "medium": 1.5, "hard": 2.0}
const ALPHABET: Array[String] = ["آ","ا","ب","پ","ت","ث","ج","چ","ح","خ","د","ذ","ر","ز","ژ","س","ش","ص","ض","ط","ظ","ع","غ","ف","ق","ک","گ","ل","م","ن","و","ه","ی"]
const HINT_COST := 5
const SKIP_COST := 10
const ACH := {
	"first_word": "اولین کلمه — اولین پاسخ درست را دادی",
	"streak_3": "سه‌تایی — سه پاسخ درست پشت سر هم",
	"level_done": "گام اول — یک مرحله را تمام کردی",
	"perfect": "بی‌نقص — مرحله را بدون اشتباه و راهنما تمام کردی",
	"rich": "ثروتمند — به ۵۰ سکه رسیدی",
	"all_levels": "قهرمان بخش — همه مرحله‌های یک بخش را تمام کردی",
}

var questions: Array = []
var settings := {"music": true, "sfx": true, "voice": true, "music_vol": 0.6, "sfx_vol": 0.9, "voice_vol": 0.9, "quality": "high"}
var coins := 20
var total_score := 0
var progress := {}   # "kids_easy" -> {"unlocked": 1, "stars": {"1": 3}, "best": {"1": 120}}
var achievements := {}
var last := {}       # {"age","diff","level"} آخرین مرحله برای ادامه بازی
var cur_age := "kids"
var cur_diff := "easy"

func _ready() -> void:
	load_questions()
	load_save()
	apply_quality()

# ---------- سؤال‌ها ----------
func load_questions() -> void:
	questions.clear()
	var seen := {}
	var idx = _read_json(QUESTION_DIR + "index.json")
	if typeof(idx) != TYPE_DICTIONARY:
		push_error("index.json سؤال‌ها خوانده نشد")
		return
	for fn in idx.get("files", []):
		var arr = _read_json(QUESTION_DIR + str(fn))
		if typeof(arr) != TYPE_ARRAY:
			continue
		for q in arr:
			if typeof(q) != TYPE_DICTIONARY or not _valid_question(q) or seen.has(q["id"]):
				continue
			seen[q["id"]] = true
			questions.append(q)

func _valid_question(q: Dictionary) -> bool:
	for k in ["id", "age", "diff", "answer", "clue"]:
		if not q.has(k):
			return false
	if not AGES.has(q["age"]) or not DIFFS.has(q["diff"]):
		return false
	for ch in str(q["answer"]):
		if not ALPHABET.has(ch):
			return false
	return str(q["answer"]).length() >= 2 and str(q["answer"]).length() <= 10

func _read_json(path: String):
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func levels_for(age: String, diff: String) -> Array:
	var pool: Array = questions.filter(func(q): return q["age"] == age and q["diff"] == diff)
	pool.sort_custom(func(a, b): return str(a["id"]) < str(b["id"]))
	var out: Array = []
	var i := 0
	while i < pool.size():
		out.append(pool.slice(i, i + LEVEL_SIZE))
		i += LEVEL_SIZE
	return out

func level_count(age: String, diff: String) -> int:
	return levels_for(age, diff).size()

# ---------- پیشرفت ----------
func key(age: String, diff: String) -> String:
	return "%s_%s" % [age, diff]

func prog(age: String, diff: String) -> Dictionary:
	var k := key(age, diff)
	if not progress.has(k):
		progress[k] = {"unlocked": 1, "stars": {}, "best": {}}
	return progress[k]

func is_unlocked(age: String, diff: String, level: int) -> bool:
	return level <= int(prog(age, diff)["unlocked"])

func stars_of(age: String, diff: String, level: int) -> int:
	return int(prog(age, diff)["stars"].get(str(level), 0))

func complete_level(age: String, diff: String, level: int, stars: int, score: int) -> void:
	var p := prog(age, diff)
	p["stars"][str(level)] = maxi(stars, int(p["stars"].get(str(level), 0)))
	p["best"][str(level)] = maxi(score, int(p["best"].get(str(level), 0)))
	if level >= int(p["unlocked"]) and level < level_count(age, diff):
		p["unlocked"] = level + 1
	total_score += score
	grant("level_done")
	if stars >= 3:
		grant("perfect")
	if p["stars"].size() >= level_count(age, diff):
		grant("all_levels")
	save()

func completed_levels() -> int:
	var n := 0
	for k in progress:
		n += progress[k]["stars"].size()
	return n

func grant(id: String) -> bool:
	if achievements.has(id):
		return false
	achievements[id] = true
	save()
	return true

func add_coins(n: int) -> void:
	coins = maxi(0, coins + n)
	if coins >= 50:
		grant("rich")
	save()

# ---------- تنظیمات ----------
func apply_quality() -> void:
	match settings["quality"]:
		"low": Engine.max_fps = 30
		_: Engine.max_fps = 60

func particles_scale() -> float:
	match settings["quality"]:
		"low": return 0.0
		"mid": return 0.5
		_: return 1.0

# ---------- ذخیره ----------
func save() -> void:
	var data := {"settings": settings, "coins": coins, "total_score": total_score,
		"progress": progress, "achievements": achievements, "last": last}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

func load_save() -> void:
	var d = _read_json(SAVE_PATH)
	if typeof(d) != TYPE_DICTIONARY:
		return
	for k in d.get("settings", {}):
		if settings.has(k):
			settings[k] = d["settings"][k]
	coins = int(d.get("coins", coins))
	total_score = int(d.get("total_score", 0))
	progress = d.get("progress", {})
	achievements = d.get("achievements", {})
	last = d.get("last", {})

func reset_all() -> void:
	coins = 20
	total_score = 0
	progress = {}
	achievements = {}
	last = {}
	save()
