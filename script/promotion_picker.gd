extends Node2D
class_name PromotionPicker

## ป๊อปอัพให้ผู้เล่นเลือกว่าจะให้เบี้ยที่ถึงแถวสุดท้ายกลายเป็นหมากอะไร (ควีน/เรือ/บิชอป/ม้า)
## แทนที่จะกลายเป็นควีนอัตโนมัติเสมอ — โผล่เหนือช่องปลายทางตอนเบี้ยเดินถึงแถวโปรโมท
## click_to_move.gd เช็คระยะคลิกเอง (ไม่รับคลิกจริง) เทคนิคเดียวกับ skill_button.gd

const HIT_RADIUS := 26.0
const OPTION_SPACING := 60.0
const OPTIONS: Array = [
	ChessPiece.Kind.QUEEN, ChessPiece.Kind.ROOK, ChessPiece.Kind.BISHOP, ChessPiece.Kind.KNIGHT,
]
const OPTION_LABELS := ["Q", "R", "B", "N"]

func _ready() -> void:
	z_index = 9  # เหนือทุกอย่าง รวมถึงปุ่มสกิล (z_index 8)

## ตำแหน่งโลก (global) ของตัวเลือกลำดับที่ i (0-3) — ใช้เช็คระยะคลิกจาก click_to_move.gd
func option_global_position(i: int) -> Vector2:
	var offset_x: float = (i - 1.5) * OPTION_SPACING
	return global_position + Vector2(offset_x, 0)

func _draw() -> void:
	var font := ThemeDB.fallback_font
	for i in range(OPTIONS.size()):
		var offset_x: float = (i - 1.5) * OPTION_SPACING
		var center := Vector2(offset_x, 0)
		draw_circle(center, HIT_RADIUS, Color(0.15, 0.15, 0.2, 0.92))
		draw_arc(center, HIT_RADIUS, 0.0, TAU, 32, Color(1.0, 0.85, 0.3, 0.95), 3.0, true)
		var label: String = OPTION_LABELS[i]
		var text_size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 28)
		draw_string(font, center - text_size * 0.5 + Vector2(0, text_size.y * 0.35), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
