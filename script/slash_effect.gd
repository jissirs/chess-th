extends Node2D
class_name SlashEffect

## เอฟเฟกต์รอยฟันตอนกิน — เส้นสว่างพาดขวางแบบฟันดาบ ไม่ต้องมี asset รูปใดๆ เลย
## วาดด้วย _draw() ล้วนๆ (สองเส้นซ้อนกัน: เส้นแกนกลางสว่างจ้า + เส้นขอบฟุ้งจางรอบนอก)
## แล้วขยายออกทางแนวนอนพร้อมจางหายอย่างรวดเร็ว จากนั้นลบตัวเองทิ้งอัตโนมัติ
##
## เรียกใช้จาก piece_spawner.gd:play_capture() ตอนจังหวะปะทะ (ดูฟังก์ชัน _spawn_slash_effect)

const LENGTH := 70.0
const WIDTH := 6.0
const DURATION := 0.18

func _ready() -> void:
	rotation = randf_range(-0.5, 0.5)  # เอียงมุมสุ่มเล็กน้อย กันดูซ้ำจำเจทุกครั้งที่กิน
	z_index = 5  # อยู่เหนือตัวหมากเสมอ (Pieces z_index = 1) ให้เห็นรอยฟันชัดไม่โดนบัง

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.6, 1.0), DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, DURATION).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func _draw() -> void:
	var half := LENGTH * 0.5
	var from := Vector2(-half, 0)
	var to := Vector2(half, 0)
	# เส้นขอบฟุ้งจาง (หนา สีอ่อน โปร่งใสบางส่วน) วาดก่อน แล้วทับด้วยเส้นแกนกลางสว่างจ้า
	# ซ้อนกันแบบนี้ได้ความรู้สึก "แสงฟุ้งรอบรอยฟัน" แบบเดียวกับกรอบไฮไลต์ใน click_to_move.gd
	draw_line(from, to, Color(1.0, 0.95, 0.6, 0.35), WIDTH * 2.5)
	draw_line(from, to, Color(1.0, 1.0, 0.9, 1.0), WIDTH)
