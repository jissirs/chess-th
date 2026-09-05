extends Node2D
class_name PromoteGlow

## แสงพวยพุ่งขึ้นฟ้าตอนเบี้ย promote — เสาแสงสามเหลี่ยมยืดขึ้นแล้วจางหาย + จุดแสงตรงฐาน
## วาดด้วย _draw() ล้วนๆ ไม่ต้องมี asset รูป เป็น node ชั่วคราวที่ลบตัวเองทิ้งอัตโนมัติหลังเล่นจบ

const DURATION := 0.6
const BEAM_HEIGHT := 220.0
const BEAM_WIDTH := 40.0

var _progress := 0.0  # 0 → 1 ตลอดช่วงอายุของเอฟเฟกต์

func _ready() -> void:
	z_index = 4  # อยู่เหนือตัวหมาก (Pieces z_index = 1) เหมือน ImpactRing
	var tween := create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, DURATION) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)

func _set_progress(p: float) -> void:
	_progress = p
	queue_redraw()

func _draw() -> void:
	var alpha := 1.0 - _progress
	var height := BEAM_HEIGHT * (0.3 + _progress * 0.7)
	var half_w := BEAM_WIDTH * 0.5 * (1.0 - _progress * 0.5)
	var points := PackedVector2Array([
		Vector2(-half_w, 0), Vector2(half_w, 0),
		Vector2(half_w * 0.3, -height), Vector2(-half_w * 0.3, -height),
	])
	draw_colored_polygon(points, Color(1.0, 0.95, 0.6, alpha * 0.85))
	draw_circle(Vector2.ZERO, 8.0 + _progress * 6.0, Color(1.0, 1.0, 0.85, alpha))
