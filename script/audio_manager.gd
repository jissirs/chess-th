extends Node

## ตัวกลางคุมเสียงทั้งเกม — เพลงพื้นหลัง (Music) กับเสียงเอฟเฟกต์ (SFX)
## ต้องตั้งเป็น Autoload ชื่อ "AudioManager" ใน Project Settings
## และต้องมี Audio Bus ชื่อ "Music" กับ "SFX" ในแท็บ Audio ก่อน

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const SAVE_PATH := "user://audio_settings.cfg"

const GREETING_REPEAT_MS := 700
const GREETING_STREAMS := {
	ChessPiece.Kind.PAWN: preload("res://asset/audio/selection/ack_pawn.wav"),
	ChessPiece.Kind.KNIGHT: preload("res://asset/audio/selection/ack_knight.wav"),
	ChessPiece.Kind.BISHOP: preload("res://asset/audio/selection/ack_bishop.wav"),
	ChessPiece.Kind.ROOK: preload("res://asset/audio/selection/ack_rook.wav"),
	ChessPiece.Kind.QUEEN: preload("res://asset/audio/selection/ack_queen.wav"),
	ChessPiece.Kind.KING: preload("res://asset/audio/selection/ack_king.wav"),
}
const DEATH_STREAMS := {
	ChessPiece.Kind.PAWN: preload("res://asset/audio/combat/death_pawn.wav"),
	ChessPiece.Kind.KNIGHT: preload("res://asset/audio/combat/death_knight.wav"),
	ChessPiece.Kind.BISHOP: preload("res://asset/audio/combat/death_bishop.wav"),
	ChessPiece.Kind.ROOK: preload("res://asset/audio/combat/death_rook.wav"),
	ChessPiece.Kind.QUEEN: preload("res://asset/audio/combat/death_queen.wav"),
	ChessPiece.Kind.KING: preload("res://asset/audio/combat/death_king.wav"),
}
var reaction_player: AudioStreamPlayer
var greeting_player: AudioStreamPlayer
var _greeting_last_played: Dictionary = {}

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	_load_settings()
	_ensure_greeting_player()
	_ensure_reaction_player()

## เล่นเพลงพื้นหลัง (loop อัตโนมัติถ้าไฟล์ตั้ง loop ไว้ในตัว import เอง)
func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return  # เพลงเดิมกำลังเล่นอยู่แล้ว ไม่ต้องเริ่มใหม่
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()

## เล่นเสียงเอฟเฟกต์ (คลิกปุ่ม, เดินหมาก, กินหมาก ฯลฯ)
## สร้าง AudioStreamPlayer ชั่วคราวแล้วลบตัวเองทิ้งหลังเล่นจบ เล่นซ้อนกันได้หลายเสียงพร้อมกัน
func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	# Keep UI and game-result effects playing while the game is paused.
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.stream = stream
	player.bus = SFX_BUS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

## One dedicated selection-ack channel prevents short vocal responses from stacking.
func _ensure_greeting_player() -> void:
	if is_instance_valid(greeting_player):
		return
	greeting_player = get_node_or_null("CharacterGreeting") as AudioStreamPlayer
	if greeting_player == null:
		greeting_player = AudioStreamPlayer.new()
		greeting_player.name = "CharacterGreeting"
		greeting_player.bus = SFX_BUS
		greeting_player.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(greeting_player)

func play_greeting(kind: int) -> bool:
	if get_tree().paused or not GREETING_STREAMS.has(kind):
		return false
	if is_instance_valid(reaction_player) and reaction_player.playing:
		return false
	_ensure_greeting_player()
	var stream: AudioStream = GREETING_STREAMS[kind]
	var now := Time.get_ticks_msec()
	if greeting_player.playing and greeting_player.stream == stream:
		return false
	if now - int(_greeting_last_played.get(kind, -GREETING_REPEAT_MS)) < GREETING_REPEAT_MS:
		return false
	greeting_player.stop()
	greeting_player.stream = stream
	greeting_player.play()
	_greeting_last_played[kind] = now
	return true

func stop_greeting() -> void:
	if is_instance_valid(greeting_player):
		greeting_player.stop()
	_greeting_last_played.clear()

## Victim reactions survive the piece being removed and the result menu pausing play.
func _ensure_reaction_player() -> void:
	if is_instance_valid(reaction_player):
		return
	reaction_player = AudioStreamPlayer.new()
	reaction_player.name = "CharacterReaction"
	reaction_player.bus = SFX_BUS
	reaction_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(reaction_player)

func play_character_reaction(kind: int, killed: bool) -> bool:
	var streams: Dictionary = DEATH_STREAMS
	if not killed or get_tree().paused or not streams.has(kind):
		return false
	_ensure_reaction_player()
	stop_greeting()
	reaction_player.stop()
	reaction_player.stream = streams[kind]
	reaction_player.play()
	return true

func stop_character_audio() -> void:
	stop_greeting()
	if is_instance_valid(reaction_player):
		reaction_player.stop()

## --- ควบคุมระดับเสียง (รับค่า 0.0-1.0 จาก slider แล้วแปลงเป็นเดซิเบล) ---

func set_music_volume(linear: float) -> void:
	_set_bus_volume(MUSIC_BUS, linear)
	_save_settings()

func set_sfx_volume(linear: float) -> void:
	_set_bus_volume(SFX_BUS, linear)
	_save_settings()

func get_music_volume() -> float:
	return _get_bus_volume(MUSIC_BUS)

func get_sfx_volume() -> float:
	return _get_bus_volume(SFX_BUS)

func _set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("ไม่พบ audio bus ชื่อ '%s' — เช็คว่าสร้างไว้ในแท็บ Audio แล้วหรือยัง" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clampf(linear, 0.0, 1.0)))
	AudioServer.set_bus_mute(bus_idx, linear <= 0.0)

func _get_bus_volume(bus_name: String) -> float:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))

## --- เซฟ/โหลดค่าเสียงลงไฟล์ ให้จำค่าไว้ข้ามการเปิดเกมใหม่ ---

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", get_music_volume())
	config.set_value("audio", "sfx_volume", get_sfx_volume())
	config.save(SAVE_PATH)

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return  # ยังไม่เคยเซฟมาก่อน ใช้ค่า default ของ bus ต่อไป
	set_music_volume(config.get_value("audio", "music_volume", 1.0))
	set_sfx_volume(config.get_value("audio", "sfx_volume", 1.0))
