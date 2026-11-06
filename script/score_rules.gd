extends RefCounted

## ไม่ใช้ class_name — เรียกผ่าน `const ScoreRules := preload("res://script/score_rules.gd")` (main.gd) เพื่อไม่ต้องรอ
## Godot สแกนคลาสใหม่เข้า cache (โปรเจกต์ที่เพิ่งโคลนมายังไม่มี cache จะหาคลาสไม่เจอจนกว่าจะเปิด editor)
##
## กติกาคะแนนทั้งหมด (ตรรกะล้วน ไม่ผูก node — เหมือน chess_rules.gd / chess_ai.gd) main.gd แค่เรียกใช้แล้วเอาผลไปรวม/โชว์
##
## คะแนนมาจาก 4 หมวด (ดูหมวดที่แสดงบนหน้าจอจบเกมได้ที่ CATEGORIES):
##   CAPTURES = กินหมากตามมูลค่า (เบี้ย 100 … ควีน 900)
##   STRATEGY = กลยุทธ์และวิธีเดิน: รุก, castling, en passant, เลื่อนขั้น, พัฒนาหมาก, ยึดกลางกระดาน,
##              แลกหมากคุ้ม (กินตัวที่มูลค่าสูงกว่า), กินปลอดภัย (ไม่โดนกินกลับ), ใช้สกิล
##   SURVIVAL = อัตราการรอดของทีมตอนจบเกม (จำนวนหมากที่เหลือ + เลือดที่เหลือ) + โบนัสไม่เสียหมากเลย
##   VICTORY  = โบนัสชนะ (รุกฆาต/คู่แข่งหมดเวลา)

const CATEGORIES := ["CAPTURES", "STRATEGY", "SURVIVAL", "VICTORY"]

const CAPTURE_POINTS := {
	ChessPiece.Kind.PAWN: 100,
	ChessPiece.Kind.KNIGHT: 300,
	ChessPiece.Kind.BISHOP: 300,
	ChessPiece.Kind.ROOK: 500,
	ChessPiece.Kind.QUEEN: 900,
}
const VICTORY_BONUS := 1000

const CHECK_POINTS := 50
const CASTLE_POINTS := 100
const EN_PASSANT_POINTS := 100
const PROMOTION_POINTS := 300
const DEVELOP_POINTS := 30          # ม้า/บิชอปออกจากแถวหลังครั้งแรก
const CENTER_POINTS := 20           # หมากแต่ละตัวได้ครั้งเดียวตอนเข้ากลางกระดานครั้งแรก (กันเดินเข้าออกปั่นคะแนน)
const FAVORABLE_TRADE_POINTS := 60  # กินตัวที่มูลค่าสูงกว่าตัวเองด้วยตัวที่ถูกกว่า
const CLEAN_CAPTURE_POINTS := 40    # กินแล้วหมากที่กินไม่โดนกินกลับ
const SKILL_POINTS := 25            # ใช้ Active Skill

## โบนัสอัตรารอดสูงสุด (รอดครบทั้งทีมเลือดเต็ม) และโบนัสพิเศษถ้า "ไม่เสียหมากสักตัว"
const SURVIVAL_MAX := 1500
const FLAWLESS_BONUS := 500
const MIN_MOVES_FOR_FULL_SURVIVAL := 20

## ทีมเริ่มต้น: 16 ตัว มูลค่ารวมไม่นับคิง = เบี้ย 8×1 + ม้า 2×3 + บิชอป 2×3 + เรือ 2×5 + ควีน 9 = 39
const START_PIECES := 16
const START_VALUE := 39.0
const PIECE_VALUES := {
	ChessPiece.Kind.PAWN: 1.0, ChessPiece.Kind.KNIGHT: 3.0, ChessPiece.Kind.BISHOP: 3.0,
	ChessPiece.Kind.ROOK: 5.0, ChessPiece.Kind.QUEEN: 9.0, ChessPiece.Kind.KING: 0.0,
}

## ช่องกลางกระดาน d4 e4 d5 e5 (col 3-4, row 3-4)
static func is_center(cell: Vector2i) -> bool:
	return cell.x in [3, 4] and cell.y in [3, 4]

## คะแนนกลยุทธ์ของ "ตาที่เพิ่งเดิน" — state คือกระดานหลังเดินแล้ว info มาจาก Board.last_move_info
## center_seen เก็บ id ของหมากที่เคยได้คะแนนยึดกลางแล้ว (ผู้เรียกเก็บไว้ตลอดเกม)
## คืน Array ของ {"label": String, "points": int}
static func move_awards(state: Array, info: Dictionary, center_seen: Dictionary) -> Array:
	var awards: Array = []
	if info.is_empty() or not info.get("moved", false):
		return awards  # โจมตีไม่ตาย หมากไม่ได้ขยับ — ไม่มีกลยุทธ์ให้ให้คะแนน
	var side: int = info.side
	var kind: int = info.kind
	var piece: ChessPiece = info.piece
	var from: Vector2i = info.from
	var to: Vector2i = info.to

	if info.get("castle", false):
		awards.append({"label": "CASTLING", "points": CASTLE_POINTS})
	if info.get("en_passant", false):
		awards.append({"label": "EN PASSANT", "points": EN_PASSANT_POINTS})
	if info.get("promoted", false):
		awards.append({"label": "PROMOTION", "points": PROMOTION_POINTS})
	if info.get("first_move", false) and (kind == ChessPiece.Kind.KNIGHT or kind == ChessPiece.Kind.BISHOP):
		awards.append({"label": "DEVELOP", "points": DEVELOP_POINTS})
	if kind != ChessPiece.Kind.KING and is_center(to) and not is_center(from) and piece != null:
		var id := piece.get_instance_id()
		if not center_seen.has(id):
			center_seen[id] = true
			awards.append({"label": "CENTER", "points": CENTER_POINTS})

	var captured_kind: int = info.get("captured_kind", -1)
	if captured_kind >= 0:
		var gain: int = CAPTURE_POINTS.get(captured_kind, 0)
		var risked: int = CAPTURE_POINTS.get(kind, 0)
		if risked > 0 and gain > risked:
			awards.append({"label": "GOOD TRADE", "points": FAVORABLE_TRADE_POINTS})
		if not ChessRules.is_square_attacked(state, to, ChessRules.opponent(side)):
			awards.append({"label": "CLEAN CAPTURE", "points": CLEAN_CAPTURE_POINTS})

	if ChessRules.is_in_check(state, ChessRules.opponent(side)):
		awards.append({"label": "CHECK", "points": CHECK_POINTS})
	return awards

## อัตรารอดของทีม 0.0–1.0 = ครึ่งหนึ่งมาจากจำนวนหมากที่เหลือ (จาก 16) อีกครึ่งมาจากมูลค่าหมากที่ถ่วงด้วยเลือด
## (หมากที่เลือดเหลือน้อยนับน้อย) — โดนตีเลือดลดแต่ไม่ตายก็ยังเสียอัตรารอดบางส่วน
static func survival_rate(state: Array, side: int) -> float:
	var alive := 0
	var weighted := 0.0
	for row in state:
		for piece in row:
			if piece == null or not is_instance_valid(piece) or piece.side != side or piece.hp <= 0.0:
				continue
			alive += 1
			var ratio: float = clampf(piece.hp / piece.max_hp, 0.0, 1.0) if piece.max_hp > 0.0 else 1.0
			weighted += PIECE_VALUES.get(piece.piece_kind, 0.0) * ratio
	var count_rate: float = clampf(float(alive) / START_PIECES, 0.0, 1.0)
	var value_rate: float = clampf(weighted / START_VALUE, 0.0, 1.0)
	return 0.5 * count_rate + 0.5 * value_rate

## จำนวนหมากที่ยังเหลือของฝ่าย side (นับคิงด้วย)
static func pieces_alive(state: Array, side: int) -> int:
	var alive := 0
	for row in state:
		for piece in row:
			if piece != null and is_instance_valid(piece) and piece.side == side and piece.hp > 0.0:
				alive += 1
	return alive

## โบนัสอัตรารอดตอนจบเกม ปัดเป็นหลักสิบ + FLAWLESS_BONUS ถ้ายังเหลือครบ 16 ตัว
## moves_played = จำนวนตาที่ฝ่ายนี้เดินจริงในเกม: ต้องเดินให้ถึง MIN_MOVES_FOR_FULL_SURVIVAL ตาถึงได้เต็ม
## ไม่งั้นค่อยๆ ลดตามสัดส่วน — กันการ "นั่งเฉยๆ" (ปล่อยหมดเวลาจนซ้ำตำแหน่งเสมอ) แล้วได้โบนัสรอดฟรี
static func survival_bonus(state: Array, side: int, moves_played: int = MIN_MOVES_FOR_FULL_SURVIVAL) -> int:
	var bonus: int = int(round(SURVIVAL_MAX * survival_rate(state, side) / 10.0)) * 10
	if pieces_alive(state, side) >= START_PIECES:
		bonus += FLAWLESS_BONUS
	var participation: float = clampf(float(moves_played) / MIN_MOVES_FOR_FULL_SURVIVAL, 0.0, 1.0)
	return int(round(bonus * participation / 10.0)) * 10
