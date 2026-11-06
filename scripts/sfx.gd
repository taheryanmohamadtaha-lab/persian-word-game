extends Node
## پخش جلوه‌های صوتی، موسیقی و گفتار فارسی شخصیت (در صورت پشتیبانی دستگاه).

var _players: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _cache := {}
var _cur_track := ""

func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	add_child(_music)
	_music.finished.connect(_on_music_finished)

func _stream(n: String) -> AudioStream:
	if not _cache.has(n):
		var path := "res://assets/sounds/%s.wav" % n
		_cache[n] = load(path) if ResourceLoader.exists(path) else null
	return _cache[n]

func play(n: String) -> void:
	if not Game.settings["sfx"]:
		return
	var s := _stream(n)
	if s == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = s
			p.volume_db = linear_to_db(maxf(0.001, float(Game.settings["sfx_vol"])))
			p.play()
			return

func _track_stream(n: String) -> AudioStream:
	var key := "music_" + n
	if not _cache.has(key):
		var path := "res://assets/music/%s.wav" % n
		_cache[key] = load(path) if ResourceLoader.exists(path) else null
	return _cache[key]

func _pick_random_track() -> String:
	var names: Array = []
	for t in Game.MUSIC_TRACKS:
		if t[0] != "shuffle" and t[0] != _cur_track:
			names.append(t[0])
	return str(names.pick_random())

func music_start() -> void:
	if not Game.settings["music"]:
		_music.stop()
		return
	var mode: String = Game.settings.get("music_mode", "shuffle")
	var n := _pick_random_track() if mode == "shuffle" else mode
	var s = _track_stream(n)
	if s == null:
		return
	if s is AudioStreamWAV:
		s.loop_mode = AudioStreamWAV.LOOP_DISABLED if mode == "shuffle" else AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = s.data.size() / 2
	_cur_track = n
	_music.stream = s
	_music.volume_db = linear_to_db(maxf(0.001, float(Game.settings["music_vol"]) * 0.5))
	_music.play()

## تغییر حالت پخش (تصادفی یا یک آهنگ مشخص) و شروع دوباره
func music_change() -> void:
	_music.stop()
	_cur_track = ""
	music_start()

func _on_music_finished() -> void:
	if Game.settings["music"] and Game.settings.get("music_mode", "shuffle") == "shuffle":
		music_start()

func music_refresh() -> void:
	if Game.settings["music"]:
		_music.volume_db = linear_to_db(maxf(0.001, float(Game.settings["music_vol"]) * 0.5))
		if not _music.playing:
			music_start()
	else:
		_music.stop()

func current_track() -> String:
	return _cur_track

func speak(text: String) -> void:
	if not Game.settings["voice"]:
		return
	if not DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		return
	var voices := DisplayServer.tts_get_voices_for_language("fa")
	if voices.is_empty():
		return
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(text, voices[0], int(float(Game.settings["voice_vol"]) * 100.0), 1.0, 1.1)
