extends CanvasLayer

@onready var fade_rect = $FadeRect

func _ready():
	fade_rect.modulate.a = 0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene(path: String):
	# Fade to black
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished

	# เปลี่ยน scene ตอนจอมืดสนิท
	get_tree().change_scene_to_file(path)

	# Fade กลับมาโปร่งใส
	var tween2 = create_tween()
	tween2.tween_property(fade_rect, "modulate:a", 0.0, 0.5)
