extends Sprite2D
class_name ChessPiece

## หมากหนึ่งตัวบนกระดาน เก็บทั้งข้อมูลเชิงกติกา (ชนิด / ฝ่าย / เคยเดินหรือยัง)
## และข้อมูลการแสดงผล (ขนาดพักปกติ ใช้ตอนย่อ-ขยายเวลาเลือก)
##
## กติกาทั้งหมดอยู่ใน chess_rules.gd — ไฟล์นี้เป็นแค่ "ข้อมูลของหมากตัวเดียว"

enum Kind { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }

## WHITE = ฝ่ายผู้เล่น อยู่แถวล่าง (row 7) ใช้ภาพชุด *_back.png
## BLACK = ฝ่ายศัตรู อยู่แถวบน (row 0) ใช้ภาพชุด *_front.png
enum Team { WHITE, BLACK }

var piece_kind: Kind = Kind.PAWN
var side: Team = Team.WHITE

## ใช้ตัดสินสิทธิ์ castling (คิง/เรือต้องยังไม่เคยเดิน) และเบี้ยเดิน 2 ช่อง
var has_moved: bool = false

## ขนาดปกติของ sprite ตัวนี้ ก่อนถูกขยายตอนถูกเลือก
## เก็บไว้เพื่อคืนค่าได้เป๊ะๆ ไม่ต้องหารกลับ (กันค่าเพี้ยนสะสมจาก float)
var resting_scale: Vector2 = Vector2.ONE
##-------------------------------------------------------------------------------------------
## --- ระบบเลือด (HP) --- ตีหลายทีถึงตาย แทนที่จะกินตายทันทีทีเดียวแบบหมากรุกปกติ
## เลือดเท่ากันหมดทุกตัว (100) แต่พลังโจมตีต่างกันตามชนิดหมาก
## piece_spawner.gd ตั้งค่า hp/max_hp/attack_power ให้ตอนสร้างตัวหมาก
## กติกาการ "เดินไปกินได้ไหม" ยังคงเดิมทุกอย่าง (chess_rules.gd ไม่ต้องแก้เลย) — HP มีผลแค่ตอน
## Board.try_move() ตัดสินว่าการกินครั้งนี้ตายจริงไหม ถ้าไม่ตายผู้โจมตีจะไม่ได้ขยับเข้าไปแทนที่
const BASE_HP := 100.0

var max_hp: float = BASE_HP
var hp: float = BASE_HP
var attack_power: float = 1.0


var has_attacked: bool = false  # เคยโจมตีสำเร็จมาก่อนไหม (ใช้ตัดสิน passive "จู่โจมครั้งแรก" ของม้า)
var passive_indicator: bool = false  # true ถ้า passive ของตัวเองกำลังทำงานอยู่ตอนนี้ (ดู PassiveSkills.is_passive_active)


## --- ระบบสกิล --- ทุกชนิดหมากมีสกิลของตัวเอง 1 อัน ใช้ได้ครั้งเดียวต่อเกม (แทนการเดินในตานั้น)
const SKILL_COOLDOWN_TURNS := 6  # จำนวนตา (ครึ่งตา) ที่ต้องรอก่อนใช้สกิลตัวเดิมได้อีกครั้ง
var skill_cooldown_remaining: int = 0

## คูณดาเมจของ "ตาถัดไปที่โจมตีสำเร็จ" (สกิลม้า/ควีน) แล้วรีเซ็ตกลับเป็น 1.0 อัตโนมัติหลังใช้ครั้งเดียว
var attack_buff_multiplier: float = 1.0

## หมากทุกชนิดมีสกิล (ตอนนี้ทุกอัน — เผื่ออนาคตอยากตัดบางชนิดออกได้ง่ายๆ)
static func has_skill(_kind: int) -> bool:
	return true

## คำอธิบายสกิลสั้นๆ ตามชนิดหมาก (เอาไว้โชว์ UI ทีหลังได้ถ้าต้องการ)
static func skill_label(kind: int) -> String:
	match kind:
		Kind.PAWN: return "ฮีล +40"
		Kind.KNIGHT: return "โจมตีตาถัดไปแรงขึ้น x1.5"
		Kind.BISHOP: return "ฮีลเต็ม"
		Kind.ROOK: return "เสริมเกราะ +30 เลือดสูงสุด"
		Kind.QUEEN: return "โจมตีตาถัดไปแรงขึ้น x2"
		Kind.KING: return "ปลุกใจฝ่ายเดียวกันทั้งหมด +20 เลือด"
		_: return ""

## ใช้สกิลได้ไหมตอนนี้ — ต้องเป็นชนิดที่มีสกิล และยังไม่เคยใช้มาก่อนในเกมนี้
func can_use_skill() -> bool:
	return has_skill(piece_kind) and skill_cooldown_remaining <= 0
	
	
## พลังโจมตีพื้นฐานตามชนิดหมาก — ดาเมจที่สร้างให้เหยื่อทุกครั้งที่กิน/โจมตีสำเร็จ
static func base_attack(kind: int) -> float:
	match kind:
		Kind.PAWN: return 30.0
		Kind.KNIGHT: return 35.0
		Kind.BISHOP: return 35.0
		Kind.ROOK: return 50.0
		Kind.QUEEN: return 75.0
		Kind.KING: return 40.0
		_: return 30.0

## โดนโจมตี amount หน่วย คืน true ถ้าเลือดหมด (ตาย)
func take_damage(amount: float) -> bool:
	hp = maxf(hp - amount, 0.0)
	queue_redraw()
	return hp <= 0.0

func _process(_delta: float) -> void:
	queue_redraw()  # เลือดขยับ/ขนาดหมากเปลี่ยนบ่อย วาดใหม่ทุกเฟรมง่ายกว่าคอย queue_redraw() ทุกจุดที่แก้ค่า

## วาดหลอดเลือดลอยเหนือหัวหมาก — หารด้วย scale ปัจจุบันทุกจุด กันไม่ให้หลอดยืด/หดเบี้ยว
## ตอนหมากถูกขยายเวลาเลือก หรือแถวไกล้-ไกลกล้องที่ขนาดหมากต่างกันมาก (ดู piece_spawner.gd)
func _draw() -> void:
	if texture == null or max_hp <= 0.0:
		return
	var sx: float = maxf(absf(scale.x), 0.0001)
	var sy: float = maxf(absf(scale.y), 0.0001)
	var bar_w := 70.0 / sx
	var bar_h := 9.0 / sy
	var gap := 14.0 / sy
	var top_y: float = -texture.get_height() * 0.5 - gap - bar_h
	var bg_rect := Rect2(Vector2(-bar_w * 0.5, top_y), Vector2(bar_w, bar_h))

	var pct: float = clampf(hp / max_hp, 0.0, 1.0)
	var fill_color: Color
	if pct > 0.5:
		fill_color = Color(0.25, 0.85, 0.3)
	elif pct > 0.25:
		fill_color = Color(0.95, 0.75, 0.15)
	else:
		fill_color = Color(0.9, 0.15, 0.15)

	draw_rect(bg_rect, Color(0.0, 0.0, 0.0, 0.55))
	if pct > 0.0:
		draw_rect(Rect2(bg_rect.position, Vector2(bar_w * pct, bar_h)), fill_color)
	draw_rect(bg_rect, Color(1.0, 1.0, 1.0, 0.4), false, 1.0 / sy)
	if passive_indicator:
		var badge_r: float = 9.0 / sy
		var badge_pos := Vector2(bar_w * 0.5 + badge_r + 4.0 / sx, top_y + bar_h * 0.5)
		draw_circle(badge_pos, badge_r, Color(1.0, 0.85, 0.25, 0.95))
		draw_arc(badge_pos, badge_r, 0.0, TAU, 16, Color(1.0, 1.0, 1.0, 0.9), 1.5 / sy, true)
	
	##-----------------------------------------------------------------------------------------------
## ชื่อไฟล์ภาพของหมากแต่ละชนิด (เบี้ยมีหลายสี จึงจัดการแยกใน piece_spawner.gd)
static func art_name(kind: int) -> String:
	match kind:
		Kind.KNIGHT: return "knight"
		Kind.BISHOP: return "bishop"
		Kind.ROOK: return "rook"
		Kind.QUEEN: return "queen"
		Kind.KING: return "king"
		_: return "soldier"

## ส่วนท้ายชื่อไฟล์ตามฝ่าย: ผู้เล่นเห็นหลังตัวหมาก ศัตรูเห็นหน้าตัวหมาก
static func suffix_for(p_side: int) -> String:
	return "back" if p_side == Team.WHITE else "front"

static func side_name(p_side: int) -> String:
	return "ขาว" if p_side == Team.WHITE else "ดำ"
