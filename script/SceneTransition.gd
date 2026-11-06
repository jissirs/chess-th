extends CanvasLayer

const FADE_DURATION := 0.5
var is_transitioning: bool = false
@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	fade_rect.modulate.a = 0.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(_event: InputEvent) -> void:
	if is_transitioning:
		get_viewport().set_input_as_handled()

## Fade around either a scene change or an in-place UI switch, including while paused.
func transition(action: Callable) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_out := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_out.tween_property(fade_rect, "modulate:a", 1.0, FADE_DURATION)
	await fade_out.finished
	if action.is_valid():
		action.call()
	await get_tree().process_frame
	var fade_in := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_in.tween_property(fade_rect, "modulate:a", 0.0, FADE_DURATION)
	await fade_in.finished
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

func change_scene(path: String) -> void:
	transition(func(): get_tree().change_scene_to_file(path))
