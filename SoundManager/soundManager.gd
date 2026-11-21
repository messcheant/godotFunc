extends Node

# ====================== PENGATURAN ======================
@export var sfx_pool_size: int = 16
@export var default_sfx_bus: String = "SFX"
@export var default_music_bus: String = "Music"

# ====================== INTERNAL ======================
var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _current_music_path: String = ""

func _ready() -> void:
	# Buat pool SFX
	for i in sfx_pool_size:
		var player := AudioStreamPlayer.new()
		player.bus = default_sfx_bus
		player.finished.connect(_on_sfx_finished.bind(player))
		add_child(player)
		_sfx_players.append(player)
	
	# Player Musik
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = default_music_bus
	add_child(_music_player)

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	player.stream = null


# ======================================================
#                    FUNGSI SFX
# ======================================================

## Play dari path (string)
func play_sfx(path: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var stream = load(path)
	if stream is AudioStream:
		_play_stream(stream, volume_db, pitch)
	else:
		push_warning("SoundManager: Gagal load SFX → " + path)


## Play dari AudioStream langsung
func play_sfx_stream(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if stream:
		_play_stream(stream, volume_db, pitch)


## Play dari SoundEntry
func play_entry(entry: SoundEntry, volume_offset: float = 0.0, pitch_mult: float = 1.0) -> void:
	if entry and entry.stream:
		_play_stream(entry.stream, entry.volume_db + volume_offset, entry.pitch_scale * pitch_mult)


## Play dari SoundLibrary + nama
func play_from_library(library: SoundLibrary, sound_name: String, volume_offset: float = 0.0, pitch_mult: float = 1.0) -> void:
	if library == null:
		return
	var entry = library.get_sound(sound_name)
	play_entry(entry, volume_offset, pitch_mult)


# ======================================================
#                    FUNGSI MUSIK
# ======================================================

func play_music(path: String, volume_db: float = 0.0, fade_time: float = 0.8) -> void:
	if path == _current_music_path and _music_player.playing:
		return
	
	var stream = load(path)
	if not stream is AudioStream:
		push_warning("SoundManager: Gagal load musik → " + path)
		return
	
	_current_music_path = path
	_music_player.stream = stream
	_music_player.volume_db = -80.0
	_music_player.play()
	
	if fade_time > 0.0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", volume_db, fade_time)
	else:
		_music_player.volume_db = volume_db


func stop_music(fade_time: float = 0.8) -> void:
	if not _music_player.playing:
		return
	
	_current_music_path = ""
	
	if fade_time > 0.0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_time)
		tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()


func set_music_volume(volume_db: float, fade_time: float = 0.3) -> void:
	if fade_time > 0.0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", volume_db, fade_time)
	else:
		_music_player.volume_db = volume_db


# ======================================================
#                    INTERNAL
# ======================================================

func _play_stream(stream: AudioStream, volume_db: float, pitch: float) -> void:
	# Cari player yang kosong
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch
			player.play()
			return
	
	# Kalau semua penuh → pakai yang paling lama
	var player = _sfx_players[0]
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()
