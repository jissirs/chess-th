extends Node2D
class_name SkillButton

## ไอคอนปุ่ม "ใช้สกิล" ลอยเหนือหัวหมากที่เลือกอยู่ — รูปร่าง/สีเปลี่ยนตามประเภทสกิลของหมากตัวนั้น
## วาดด้วยโค้ดล้วนๆ ไม่ต้องมี asset ตัวเองไม่รับคลิกจริง (ดู click_to_move.gd ที่เช็คระยะเอง)
##
## ต้องเรียก setup() ก่อน add_child() เสมอ (เหมือน DamagePopup.setup()) เพราะ _draw()
## ต้องรู้ก่อนว่าไอคอนควรเป็นแบบไหน

const HIT_RADIUS := 24.0

var _icon_kind: String = "heal"

## แบ่งกลุ่มไอคอนตามชนิดหมาก — ต้องตรงกับที่ Board._apply_skill() คืนค่า effect_kind จริงตอนใช้:
## เบี้ย/บิชอป/เรือ = "heal", ม้า/ควีน = "buff", คิง = "rally"
func setup(piece_kind: int) -> void:
	match piece_kind:
		ChessPiece.Kind.PAWN, ChessPiece.Kind.BISHOP, ChessPiece.Kind.ROOK:
			_icon_kind = "heal"
		ChessPiece.Kind.KNIGHT, ChessPiece.Kind.QUEEN:
			_icon_kind = "buff"
		ChessPiece.Kind.KING:
			_icon_kind = "rally"

func _ready() -> void:
	z_index = 8  # เหนือทุกเอฟเฟกต์ รวมถึงตัวเลขดาเมจ (z_index 7)

func _draw() -> void:
	var bg_color: Color
	match _icon_kind:
		"heal": bg_color = Color(0.25, 0.75, 0.35, 0.92)
		"buff": bg_color = Color(0.95, 0.55, 0.15, 0.92)
		"rally": bg_color = Color(0.35, 0.55, 0.95, 0.92)
		_: bg_color = Color(0.25, 0.55, 1.0, 0.9)

	draw_circle(Vector2.ZERO, HIT_RADIUS, bg_color)
	draw_arc(Vector2.ZERO, HIT_RADIUS, 0.0, TAU, 32, Color(1.0, 1.0, 1.0, 0.95), 3.0, true)

	match _icon_kind:
		"heal":
			_draw_cross()
		"buff":
			_draw_lightning()
		"rally":
			_draw_star()

## เครื่องหมายบวก (+) สำหรับสกิลฮีล/เสริมเกราะ
func _draw_cross() -> void:
	var w := 6.0
	var l := 16.0
	draw_rect(Rect2(Vector2(-w * 0.5, -l * 0.5), Vector2(w, l)), Color.WHITE)
	draw_rect(Rect2(Vector2(-l * 0.5, -w * 0.5), Vector2(l, w)), Color.WHITE)

## สายฟ้าสำหรับสกิลบัฟโจมตี
func _draw_lightning() -> void:
	var points := PackedVector2Array([
		Vector2(2, -14), Vector2(-8, 2), Vector2(-1, 2),
		Vector2(-2, 14), Vector2(8, -2), Vector2(1, -2),
	])
	draw_colored_polygon(points, Color.WHITE)

## ดาว 5 แฉกสำหรับสกิลปลุกใจทีม
func _draw_star() -> void:
	var points := PackedVector2Array()
	var outer := 13.0
	var inner := 5.5
	for i in range(10):
		var angle := deg_to_rad(-90 + i * 36)
		var r := outer if i % 2 == 0 else inner
		points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, Color.WHITE)
