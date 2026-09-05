extends Node

## ตัวกลางคุมเสียงทั้งเกม — เพลงพื้นหลัง (Music) กับเสียงเอฟเฟกต์ (SFX)
## ต้องตั้งเป็น Autoload ชื่อ "AudioManager" ใน Project Settings
## และต้องมี Audio Bus ชื่อ "Music" กับ "SFX" ในแท็บ Audio ก่อน

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const SAVE_PATH := "user://audio_settings.cfg"

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	_load_settings()

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
	player.stream = stream
	player.bus = SFX_BUS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

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
