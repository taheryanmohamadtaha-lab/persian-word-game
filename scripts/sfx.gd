extends Node
## پخش جلوه‌های صوتی، موسیقی و گفتار فارسی شخصیت (در صورت پشتیبانی دستگاه).

var _players: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _cache := {}

func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	add_child(_music)

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

func music_start() -> void:
	if not Game.settings["music"]:
		_music.stop()
		return
	if _music.stream == null:
		var path := "res://assets/music/loop.wav"
		if not ResourceLoader.exists(path):
			return
		var s = load(path)
		if s is AudioStreamWAV:
			s.loop_mode = AudioStreamWAV.LOOP_FORWARD
			s.loop_begin = 0
			s.loop_end = s.data.size() / 2
		_music.stream = s
	_music.volume_db = linear_to_db(maxf(0.001, float(Game.settings["music_vol"]) * 0.5))
	if not _music.playing:
		_music.play()

func music_refresh() -> void:
	if Game.settings["music"]:
		music_start()
	else:
		_music.stop()

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
