extends Control

const SFX_BUTTON := preload("res://asset/audio/ui_button.mp3")

func _ready():
	$Singleplayerbutton.pressed.connect(_on_singleplayer_pressed)
	$multiplayerbutton.pressed.connect(_on_multiplayer_pressed)
	$settingbutton.pressed.connect(_on_settings_pressed)
	$quitbutton.pressed.connect(_on_quit_pressed)

func _on_singleplayer_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	GameManager.game_mode = "PVC"
	SceneTransition.change_scene("res://Scene/main.tscn")

func _on_multiplayer_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	GameManager.game_mode = "PVP"
	SceneTransition.change_scene("res://Scene/main.tscn")

func _on_settings_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	SceneTransition.change_scene("res://Scene/settings.tscn")

func _on_quit_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	get_tree().quit()
