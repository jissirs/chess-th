extends Control

@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SfxSlider
@onready var back_button: TextureButton = $BackButton

func _ready() -> void:
	# ตั้งค่า slider ให้ตรงกับค่าเสียงปัจจุบัน (กรณีเคยปรับ/เซฟไว้ก่อนหน้า)
	music_slider.value = AudioManager.get_music_volume()
	sfx_slider.value = AudioManager.get_sfx_volume()

	# ต่อสัญญาณ: ลาก slider แล้วเปลี่ยนเสียงทันที
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)

func _on_music_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_back_pressed() -> void:
	SceneTransition.change_scene("res://Scene/main_menu.tscn")
