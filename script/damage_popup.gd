extends Node2D
class_name DamagePopup

## ตัวเลขดาเมจลอยขึ้นแล้วจางหาย สไตล์เกม RPG — ยิ่งดาเมจแรง ยิ่งตัวใหญ่ + เขย่าแรงตอนโผล่
## โผล่ตอนโจมตีสำเร็จ (ทั้งกรณีตายและไม่ตาย) — วาดด้วย draw_string() ล้วนๆ ไม่ต้องมี asset ฟอนต์เพิ่ม
##
## ต้องเรียก setup() ก่อน add_child() เสมอ (ดู piece_spawner.gd:_on_piece_attacked) เพราะ
## _ready() อ่านค่าที่ setup() ตั้งไว้ไปคำนวณความแรงของเอฟเฟกต์ทันทีที่ node เข้าฉาก

const FONT_SIZE := 34

## ดาเมจระดับนี้ขึ้นไป = เอฟเฟกต์ (ขนาด/แรงเขย่า) แรงเต็มที่ — ปรับเลขนี้เพื่อจูนความรู้สึกได้
const REFERENCE_DAMAGE := 60.0

const BASE_FONT_SCALE := 0.85
const MAX_FONT_SCALE := 1.8
const BASE_SHAKE := 3.0
const MAX_SHAKE := 16.0
const SHAKE_STEPS := 5
const SHAKE_STEP_DURATION := 0.03

const RISE_DISTANCE := 55.0
const RISE_DURATION := 0.7

var _text: String = ""
var _color: Color = Color.WHITE
var _alpha: float = 1.0
var _damage: float = 0.0
var _killed: bool = false
var _font: Font

## เรียกก่อน add_child() เสมอ — killed=true แสดงว่าตีครั้งนี้ฆ่าเหยื่อตายจริง (สีแดง) ไม่ตายก็แค่เลือดลด (สีทอง)
func setup(damage: float, killed: bool) -> void:
	_text = "-%d" % int(round(damage))
	_damage = damage
	_killed = killed
	_color = Color(1.0, 0.35, 0.25) if killed else Color(1.0, 0.85, 0.3)

func _ready() -> void:
	_font = ThemeDB.fallback_font
	z_index = 7  # เหนือทุกเอฟเฟกต์ รวมถึงเศษชิ้นแตก (z_index 6)

	# ความแรง 0.0-1.0 เทียบกับ REFERENCE_DAMAGE — ใช้คุมทั้งขนาดตัวอักษรและแรงเขย่า
	var strength: float = clampf(_damage / REFERENCE_DAMAGE, 0.0, 1.0)
	var font_scale: float = lerp(BASE_FONT_SCALE, MAX_FONT_SCALE, strength) * (1.2 if _killed else 1.0)
	var shake_mag: float = lerp(BASE_SHAKE, MAX_SHAKE, strength)
	var base_pos: Vector2 = position

	scale = Vector2(font_scale, font_scale) * 1.9  # โผล่มาใหญ่เว่อร์ก่อน ให้ความรู้สึก "กระแทก"

	var tween := create_tween()

	# 1) หดจากใหญ่เว่อร์ลงมาขนาดจริงแบบเด้ง (impact punch)
	tween.tween_property(self, "scale", Vector2(font_scale, font_scale), 0.14) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# 2) เขย่าอยู่กับที่สั้นๆ ตามแรงโจมตี ก่อนเริ่มลอยขึ้น — ยิ่งดาเมจสูง ยิ่งเขย่าแรง
	for i in range(SHAKE_STEPS):
		var falloff: float = 1.0 - float(i) / SHAKE_STEPS
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_mag * falloff
		tween.tween_property(self, "position", base_pos + offset, SHAKE_STEP_DURATION)
	tween.tween_property(self, "position", base_pos, SHAKE_STEP_DURATION)

	# 3) ลอยขึ้นพร้อมจางหายตามปกติ
	var rand_x_offset := randf_range(-15.0, 15.0)
	var target: Vector2 = base_pos + Vector2(rand_x_offset, -RISE_DISTANCE)
	tween.tween_property(self, "position", target, RISE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_method(_set_alpha, 1.0, 0.0, RISE_DURATION).set_delay(RISE_DURATION * 0.3)
	tween.chain().tween_callback(queue_free)

func _set_alpha(a: float) -> void:
	_alpha = a
	queue_redraw()

func _draw() -> void:
	if _font == null:
		return
	var col := Color(_color.r, _color.g, _color.b, _alpha)
	var outline := Color(0.0, 0.0, 0.0, _alpha * 0.85)
	for offset in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		draw_string(_font, Vector2(-18, 8) + offset, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, outline)
	draw_string(_font, Vector2(-18, 8), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, col)
