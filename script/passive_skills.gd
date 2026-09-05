extends RefCounted
class_name PassiveSkills

## Passive skill ของหมากแต่ละชนิด — ปรับดาเมจตอนโจมตี ตามชนิดของ "ผู้โจมตี" และ "เหยื่อ"
## เรียกจาก Board.try_move() แทนการใช้ attacker.attack_power ตรงๆ
##
## แต่ละ passive คำนวณเป็น "ตัวคูณ" แยกอิสระจากกัน แล้วคูณรวมกันตอนจบใน compute_damage()
## เพิ่ม/ถอด passive ตัวใหม่ทีหลัง แค่เพิ่มเงื่อนไขใน _attacker_multiplier()/_victim_multiplier()
## โดยไม่กระทบ passive ตัวอื่นที่มีอยู่แล้วเลย — ยังไม่ทำ: บิชอป/คิง (เพิ่มทีหลังได้)
##
## ⚠️ ทำไมต้องรับ state + victim_cell เพิ่ม — passive ของเบี้ย ("แนวรบเหล็ก") ต้องเช็คว่ามีเบี้ย
## ฝ่ายเดียวกันอยู่ช่องข้างๆ ไหม ซึ่งต้องรู้ตำแหน่งบนกระดานของเหยื่อถึงจะเช็คได้ — Rook/Queen เดิม
## ไม่ต้องใช้ 2 ค่านี้เลย (ใส่ underscore หน้าพารามิเตอร์ที่ไม่ได้ใช้ในฟังก์ชันที่ไม่เกี่ยวกับตำแหน่ง)

const QUEEN_EXECUTE_HP_THRESHOLD := 0.25  # เหยื่อเลือดเหลือ ≤25% ควีนโค่นล้มดาเมจ x2
const QUEEN_EXECUTE_MULTIPLIER := 2.0

const ROOK_FORTIFY_REDUCTION := 0.30  # เรือที่ยังไม่เคยขยับเลย ลดดาเมจที่ได้รับ 30%

const PAWN_SHIELDWALL_REDUCTION := 0.20  # เบี้ยที่มีเบี้ยฝ่ายเดียวกันอยู่ช่องข้างๆ ลดดาเมจที่ได้รับ 20%

const KNIGHT_FIRST_STRIKE_MULTIPLIER := 1.25  # ม้าโจมตีครั้งแรกสุดในเกมของตัวเอง ดาเมจ +25%
const BISHOP_PURIFY_MULTIPLIER := 1.15  # บิชอปตีเป้าหมายที่เลือดเต็ม (ยังไม่เคยโดนตี) ดาเมจ +15%
const KING_ROYAL_GUARD_REDUCTION := 0.15  # หมากในระยะประชิดคิงฝ่ายเดียวกัน (รวมคิงเอง) ลดดาเมจที่ได้รับ 15%

## คำนวณดาเมจจริงที่เหยื่อจะได้รับ หลังคิด passive ของทั้งผู้โจมตีและเหยื่อแล้ว
## เรียกแทนการใช้ attacker.attack_power ตรงๆ ทุกที่ที่มีการคำนวณดาเมจ (ทั้งเกมจริงและ AI จำลอง)
## state + victim_cell คือกระดานปัจจุบันและตำแหน่งของเหยื่อ (ดูคำเตือนหัวไฟล์ว่าทำไมต้องมี)
static func compute_damage(attacker: ChessPiece, victim: ChessPiece, state: Array, victim_cell: Vector2i) -> float:
	var damage := attacker.attack_power
	damage *= _attacker_multiplier(attacker, victim)
	damage *= _victim_multiplier(attacker, victim, state, victim_cell)
	return damage

## ตัวคูณดาเมจจากฝั่ง "ผู้โจมตี" — ควีน: โค่นล้ม / ม้า: จู่โจมครั้งแรก
static func _attacker_multiplier(attacker: ChessPiece, victim: ChessPiece) -> float:
	var multiplier := 1.0
	if attacker.piece_kind == ChessPiece.Kind.QUEEN and victim.max_hp > 0.0:
		var hp_ratio: float = victim.hp / victim.max_hp
		if hp_ratio <= QUEEN_EXECUTE_HP_THRESHOLD:
			multiplier *= QUEEN_EXECUTE_MULTIPLIER
	if attacker.piece_kind == ChessPiece.Kind.KNIGHT and not attacker.has_attacked:
		multiplier *= KNIGHT_FIRST_STRIKE_MULTIPLIER
	if attacker.piece_kind == ChessPiece.Kind.BISHOP and victim.max_hp > 0.0 and victim.hp >= victim.max_hp:
		multiplier *= BISHOP_PURIFY_MULTIPLIER
	return multiplier

## ตัวคูณดาเมจจากฝั่ง "เหยื่อ" — เรือ: ป้อมปราการ / เบี้ย: แนวรบเหล็ก
static func _victim_multiplier(_attacker: ChessPiece, victim: ChessPiece, state: Array, victim_cell: Vector2i) -> float:
	var multiplier := 1.0
	if victim.piece_kind == ChessPiece.Kind.ROOK and not victim.has_moved:
		multiplier *= (1.0 - ROOK_FORTIFY_REDUCTION)
	if victim.piece_kind == ChessPiece.Kind.PAWN and _has_allied_pawn_beside(state, victim_cell, victim.side):
		multiplier *= (1.0 - PAWN_SHIELDWALL_REDUCTION)
	if _is_near_allied_king(state, victim_cell, victim.side):
		multiplier *= (1.0 - KING_ROYAL_GUARD_REDUCTION)
	return multiplier

## มีเบี้ยฝ่ายเดียวกันยืนอยู่ช่องซ้ายหรือขวา (แถวเดียวกัน) ของ cell ไหม
static func _has_allied_pawn_beside(state: Array, cell: Vector2i, side: int) -> bool:
	for dx in [-1, 1]:
		var check_col: int = cell.x + dx
		if check_col < 0 or check_col >= 8:
			continue
		var neighbor: ChessPiece = state[cell.y][check_col]
		if neighbor != null and neighbor.piece_kind == ChessPiece.Kind.PAWN and neighbor.side == side:
			return true
	return false

## หา cell ของคิงฝ่าย side บนกระดาน คืน Vector2i(-1,-1) ถ้าหาไม่เจอ (ไม่ควรเกิดในเกมจริง — คิงตายไม่ได้)
static func _find_king_cell(state: Array, side: int) -> Vector2i:
	for row in range(state.size()):
		for col in range(state[row].size()):
			var p: ChessPiece = state[row][col]
			if p != null and p.piece_kind == ChessPiece.Kind.KING and p.side == side:
				return Vector2i(col, row)
	return Vector2i(-1, -1)

## cell อยู่ในระยะประชิดคิงฝ่าย side ไหม (รวมช่องที่คิงยืนอยู่เองด้วย) — ใช้ Chebyshev distance <= 1
static func _is_near_allied_king(state: Array, cell: Vector2i, side: int) -> bool:
	var king_cell := _find_king_cell(state, side)
	if king_cell == Vector2i(-1, -1):
		return false
	return maxi(absi(cell.x - king_cell.x), absi(cell.y - king_cell.y)) <= 1

## หมากตัวนี้กำลังได้ประโยชน์จาก passive ของตัวเอง "ตอนนี้เลย" (ไม่ต้องรู้ว่าจะไปตีใคร) ไหม —
## ใช้แค่โชว์ไอคอนบอกสถานะเฉยๆ ไม่เกี่ยวกับ compute_damage() เลย ไม่ครอบคลุมควีน/บิชอปเพราะ
## passive ของ 2 ชนิดนั้นขึ้นกับเป้าหมายที่ยังไม่รู้ล่วงหน้า
static func is_passive_active(piece: ChessPiece, state: Array, cell: Vector2i) -> bool:
	if piece.piece_kind == ChessPiece.Kind.ROOK and not piece.has_moved:
		return true
	if piece.piece_kind == ChessPiece.Kind.PAWN and _has_allied_pawn_beside(state, cell, piece.side):
		return true
	if piece.piece_kind == ChessPiece.Kind.KNIGHT and not piece.has_attacked:
		return true
	if _is_near_allied_king(state, cell, piece.side):
		return true
	return false
