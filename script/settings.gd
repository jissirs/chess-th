extends Control

signal back_requested
## True for an overlay opened from gameplay; false for the main-menu settings scene.
@export var embedded: bool = false
var _returning: bool = false

const RUNIC_FONT := preload("res://asset/ui/components/fonts/runic_font.fnt")
const ACCENT := Color(0.35, 0.8, 1.0)

@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SfxSlider
@onready var back_button: TextureButton = $BackButton
## ปุ่มเลือกระดับความยาก AI — เรียงตาม GameManager.AIDifficulty (EASY, NORMAL, HARD)
var difficulty_buttons: Array[Button] = []

func _ready() -> void:
	# ตั้งค่า slider ให้ตรงกับค่าเสียงปัจจุบัน (กรณีเคยปรับ/เซฟไว้ก่อนหน้า)
	music_slider.value = AudioManager.get_music_volume()
	sfx_slider.value = AudioManager.get_sfx_volume()

	# ต่อสัญญาณ: ลาก slider แล้วเปลี่ยนเสียงทันที
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)
	_build_difficulty_row()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()


func _on_music_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

## แถว "AI LEVEL  [EASY] [NORMAL] [HARD]" ใต้แผงสไลเดอร์ — สร้างด้วยโค้ดเพื่อให้ใช้ได้ทั้งหน้า Settings
## จากเมนูหลักและตอนเปิดซ้อนในเกม (embedded) ปรับแล้วมีผลกับตาเดินถัดไปของ AI ทันที และเซฟลงไฟล์
func _build_difficulty_row() -> void:
	var row := HBoxContainer.new()
	row.name = "DifficultyRow"
	row.position = Vector2(645, 712)
	row.size = Vector2(630, 70)
	row.add_theme_constant_override("separation", 14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(row)

	var title := Label.new()
	title.text = "AI LEVEL"
	title.add_theme_font_override("font", RUNIC_FONT)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.05))
	title.add_theme_constant_override("outline_size", 5)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(title)

	var group := ButtonGroup.new()
	for level in GameManager.AI_DIFFICULTY_NAMES.size():
		var button := Button.new()
		button.text = GameManager.AI_DIFFICULTY_NAMES[level]
		button.toggle_mode = true
		button.button_group = group
		button.custom_minimum_size = Vector2(138, 62)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_override("font", RUNIC_FONT)
		button.add_theme_font_size_override("font_size", 28)
		button.add_theme_stylebox_override("normal", _button_style(Color(0.05, 0.08, 0.13, 0.92), 2))
		button.add_theme_stylebox_override("hover", _button_style(Color(0.09, 0.16, 0.26, 0.95), 2))
		button.add_theme_stylebox_override("pressed", _button_style(Color(0.12, 0.42, 0.66, 0.97), 4))
		button.add_theme_stylebox_override("hover_pressed", _button_style(Color(0.14, 0.46, 0.72, 0.97), 4))
		button.button_pressed = level == GameManager.ai_difficulty
		button.pressed.connect(_on_difficulty_pressed.bind(level))
		row.add_child(button)
		difficulty_buttons.append(button)

func _button_style(fill: Color, border: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = ACCENT
	style.set_border_width_all(border)
	style.set_corner_radius_all(8)
	return style

func _on_difficulty_pressed(level: int) -> void:
	AudioManager.play_sfx(preload("res://asset/audio/ui_button.mp3"))
	GameManager.set_ai_difficulty(level)

func _on_back_pressed() -> void:
	if _returning:
		return
	_returning = true
	if embedded:
		back_requested.emit()
		return
	SceneTransition.change_scene("res://Scene/main_menu.tscn")
