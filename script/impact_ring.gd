extends Node2D
class_name ImpactRing

## วงแหวนแสงกระแทกพื้น ขยายออกแล้วจางหาย ใช้ตอนหมากตาย (ดู piece_spawner.gd:_play_victim_death)
## วาดด้วย _draw() ล้วนๆ ไม่ต้องมี asset รูป เป็น node ชั่วคราวที่ลบตัวเองทิ้งอัตโนมัติหลังเล่นจบ
## เทคนิคเดียวกับ SlashEffect: ใช้ tween_method() ยิงค่าเข้าตัวแปรแล้ว queue_redraw() ทุกครั้งที่ค่าขยับ

const START_RADIUS := 10.0
const END_RADIUS := 65.0
const DURATION := 0.35
const RING_WIDTH := 5.0

var _radius := START_RADIUS
var _alpha := 0.9

func _ready() -> void:
	z_index = 4  # อยู่เหนือตัวหมาก (Pieces z_index = 1) แต่ใต้รอยฟัน (SlashEffect z_index = 5)

	var tween := create_tween()
	tween.tween_method(_set_radius, START_RADIUS, END_RADIUS, DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_method(_set_alpha, 0.9, 0.0, DURATION)
	tween.chain().tween_callback(queue_free)

func _set_radius(r: float) -> void:
	_radius = r
	queue_redraw()

func _set_alpha(a: float) -> void:
	_alpha = a
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 48, Color(0.85, 0.8, 0.7, _alpha), RING_WIDTH, true)
