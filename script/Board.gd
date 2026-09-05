@tool
extends Node2D
class_name board

## Maps an 8x8 logical grid onto the perspective board painted in asset/bg.png.
## The four Marker2D corners below define the trapezoid — drag them in the
## editor to line up with the art if it doesn't match perfectly.

const COLS := 8
const ROWS := 8

const SFX_MOVE := preload("res://asset/audio/footsteps.mp3")  # เสียงเดินหมากปกติ (ไม่มีการกิน)

@export var show_debug_grid: bool = true

@onready var top_left: Marker2D = $TopLeft
@onready var top_right: Marker2D = $TopRight
@onready var bottom_left: Marker2D = $BottomLeft
@onready var bottom_right: Marker2D = $BottomRight

# board_state[row][col] holds whatever piece object occupies that square, or null.
var board_state: Array = []

## เดินสำเร็จหนึ่งตา (ส่ง piece หลัง promote แล้ว ถ้ามีการ promote)
signal move_made(from_cell: Vector2i, to_cell: Vector2i, piece: ChessPiece)
## เปลี่ยนตาเดินเป็นอีกฝ่าย
signal turn_changed(side: int)
## ฝ่ายที่ถึงตาเดินกำลังถูกรุกอยู่
signal check_alerted(side: int)
## เกมจบ — result ดูค่าที่เป็นไปได้ใน ChessRules.status(), winner = -1 คือเสมอ
signal game_ended(result: String, winner: int)

var side_to_move: int = ChessPiece.Team.WHITE
## ช่องที่เบี้ยฝ่ายตรงข้ามเพิ่งเดินผ่านเมื่อตาที่แล้ว (กินผ่านได้เฉพาะตาถัดไปเท่านั้น)
var en_passant_target: Vector2i = ChessRules.NO_CELL
## นับตาที่ไม่มีการกินและไม่มีการเดินเบี้ย ใช้ตัดสินกฎ 50 ตา
var halfmove_clock: int = 0
var fullmove_number: int = 1
var game_over: bool = false
## [from, to] ของตาล่าสุด ว่างถ้ายังไม่มีใครเดิน
var last_move: Array = []
## true ระหว่างที่หมากกำลังเลื่อนด้วย animation — กันไม่ให้คลิกเดินซ้อนจนสถานะสับสน
var animating: bool = false

func _ready() -> void:
	_init_board_state()
	_reset_game_state()

func _init_board_state() -> void:
	board_state.clear()
	for row in range(ROWS):
		var row_data: Array = []
		for col in range(COLS):
			row_data.append(null)
		board_state.append(row_data)

func _reset_game_state() -> void:
	side_to_move = ChessPiece.Team.WHITE
	en_passant_target = ChessRules.NO_CELL
	halfmove_clock = 0
	fullmove_number = 1
	game_over = false
	last_move = []
	animating = false

## World position of the center of cell (col, row), 0-indexed from the top-left square.
func cell_to_world(col: int, row: int) -> Vector2:
	return _project(col + 0.5, row + 0.5)

## World position of a grid intersection point; u in [0, COLS], v in [0, ROWS].
## Uses a projective (homography) mapping from the unit square to the four
## corner markers, which is what a camera-perspective quad actually needs —
## plain bilinear interpolation bends the grid lines away from the art.
func _project(u: float, v: float) -> Vector2:
	var c := _homography_coeffs()
	var fu := u / float(COLS)
	var fv := v / float(ROWS)
	var denom: float = c.a13 * fu + c.a23 * fv + 1.0
	var x: float = (c.a11 * fu + c.a21 * fv + c.a31) / denom
	var y: float = (c.a12 * fu + c.a22 * fv + c.a32) / denom
	return Vector2(x, y)

## Unit-square-to-quadrilateral projective mapping (Heckbert).
## p0=TL at (0,0), p1=TR at (1,0), p2=BR at (1,1), p3=BL at (0,1).
func _homography_coeffs() -> Dictionary:
	var p0 := top_left.global_position
	var p1 := top_right.global_position
	var p2 := bottom_right.global_position
	var p3 := bottom_left.global_position

	var dx1 := p1.x - p2.x
	var dx2 := p3.x - p2.x
	var dx3 := p0.x - p1.x + p2.x - p3.x
	var dy1 := p1.y - p2.y
	var dy2 := p3.y - p2.y
	var dy3 := p0.y - p1.y + p2.y - p3.y

	var a13 := 0.0
	var a23 := 0.0
	var det := dx1 * dy2 - dx2 * dy1
	if absf(dx3) > 0.0001 or absf(dy3) > 0.0001:
		if absf(det) > 0.0001:
			a13 = (dx3 * dy2 - dx2 * dy3) / det
			a23 = (dx1 * dy3 - dx3 * dy1) / det

	var a11 := p1.x - p0.x + a13 * p1.x
	var a21 := p3.x - p0.x + a23 * p3.x
	var a31 := p0.x
	var a12 := p1.y - p0.y + a13 * p1.y
	var a22 := p3.y - p0.y + a23 * p3.y
	var a32 := p0.y

	return {
		"a11": a11, "a21": a21, "a31": a31, "a13": a13,
		"a12": a12, "a22": a22, "a32": a32, "a23": a23,
	}

## 4 มุมของช่อง (col, row) ตามเปอร์สเปกทีฟจริงของกระดาน (ไม่ใช่สี่เหลี่ยมจัตุรัสตรงๆ
## เพราะกระดานเป็นภาพมุมกล้อง) เรียงตามเข็มนาฬิกาเริ่มจากมุมบนซ้าย ใช้วาดกรอบไฮไลต์ช่อง
func cell_corners(col: int, row: int) -> PackedVector2Array:
	return PackedVector2Array([
		_project(col, row),
		_project(col + 1, row),
		_project(col + 1, row + 1),
		_project(col, row + 1),
	])

## Nearest logical cell to a world position (e.g. a mouse click). Returns (-1,-1) if unset.
func world_to_cell(world_pos: Vector2) -> Vector2i:
	if not (top_left and top_right and bottom_left and bottom_right):
		return Vector2i(-1, -1)
	var best_cell := Vector2i(-1, -1)
	var best_dist := INF
	for row in range(ROWS):
		for col in range(COLS):
			var dist := cell_to_world(col, row).distance_squared_to(world_pos)
			if dist < best_dist:
				best_dist = dist
				best_cell = Vector2i(col, row)
	return best_cell

# ------------------------------------------------------------------- ตัวคุมเกม
# Board เป็นเจ้าของทั้ง "สภาพกระดาน" และ "สถานะเกม" ส่วนกติกาอยู่ใน ChessRules
# และการวางตำแหน่ง/ขนาด sprite อยู่ใน piece_spawner.gd (node ลูกชื่อ Pieces)

## ตาเดินที่คลิกได้จริงของหมากในช่องนี้ — คืน [] ถ้าเป็นช่องว่าง
## เป็นหมากฝ่ายตรงข้าม หรือหมากตัวนั้นขยับไม่ได้เลย (เช่นถูกตรึงอยู่หน้าคิง)
func legal_moves_for(cell: Vector2i) -> Array:
	if game_over:
		return []
	var piece := ChessRules.at(board_state, cell)
	if piece == null or piece.side != side_to_move:
		return []
	return ChessRules.legal_moves(board_state, cell, en_passant_target)

## พยายามเดินหมากจาก from ไป to คืน true ถ้าเดินได้จริง
## promote_to ใช้เฉพาะตอนเบี้ยถึงแถวสุดท้าย (ค่าเริ่มต้นคือควีน)
##
## ลำดับขั้นตอนในฟังก์ชันนี้ตายตัว ห้ามสลับที่ เพราะแต่ละขั้นอิงผลจากขั้นก่อนหน้า:
##   1. อัปเดต board_state (ตรรกะเกม) ให้เสร็จทันทีทั้งหมดก่อน — ตัวเดิน + เรือ (ถ้า castling)
##   2. เริ่ม animation เลื่อนหมาก แล้ว await ให้เลื่อนเสร็จก่อนค่อยไปขั้นต่อไป
##      (กันไม่ให้ popup รุกฆาต/เช็ครุก โผล่ทับตอนหมากยังเลื่อนค้างอยู่)
##   3. หลังเลื่อนเสร็จ: promote (ถ้าเบี้ยถึงแถวสุดท้าย), อัปเดต en passant / 50 ตา / เปลี่ยนตา
##   4. ส่ง signal ให้ UI ไปอัปเดตทีหลังสุด
## เกมจบแล้วหรือยัง — winner = -1 คือเสมอ (ดู ChessRules.status())
## ส่งเพิ่มจากของเดิม: แจ้งตอนโจมตีสำเร็จ ไม่ว่าจะฆ่าตายหรือแค่ลดเลือด (เอาไว้ต่อเสียง/เอฟเฟกต์ทีหลัง)
signal piece_attacked(attacker: ChessPiece, victim: ChessPiece, damage: float, killed: bool)

## พยายามเดินหมากจาก from ไป to คืน true ถ้าเดินได้จริง
## promote_to ใช้เฉพาะตอนเบี้ยถึงแถวสุดท้าย (ค่าเริ่มต้นคือควีน)
##
## ลำดับขั้นตอนในฟังก์ชันนี้ตายตัว ห้ามสลับที่ เพราะแต่ละขั้นอิงผลจากขั้นก่อนหน้า:
##   1. ตัดสินก่อนว่าถ้ามีการโจมตี จะฆ่าเหยื่อตายจริงไหม (ระบบเลือด) แล้วค่อยอัปเดต board_state
##      ตามผลนั้น — ถ้าไม่ตาย ผู้โจมตี "ไม่ขยับ" เข้าไปแทนที่ (เหยื่อยังยืนอยู่ที่เดิม แค่เลือดลด)
##   2. เริ่ม animation แล้ว await ให้เล่นจบก่อนค่อยไปขั้นต่อไป
##   3. หลังเล่นจบ: promote / en passant / 50 ตา / เปลี่ยนตา (เฉพาะกรณีที่ตัวหมากขยับจริง)
##   4. ส่ง signal ให้ UI ไปอัปเดตทีหลังสุด
func try_move(from_cell: Vector2i, to_cell: Vector2i, promote_to: int = ChessPiece.Kind.QUEEN) -> bool:
	if animating or not (to_cell in legal_moves_for(from_cell)):
		return false

	var piece: ChessPiece = board_state[from_cell.y][from_cell.x]
	var is_pawn := piece.piece_kind == ChessPiece.Kind.PAWN
	var captured: ChessPiece = board_state[to_cell.y][to_cell.x]
	var is_en_passant := is_pawn and to_cell == en_passant_target and captured == null
	if is_en_passant:
		captured = board_state[from_cell.y][to_cell.x]

	# ---------- ขั้นที่ 1: ตัดสินผลการโจมตี (ถ้ามี) ก่อนแตะ board_state ----------

	#var lethal := true  # ไม่มีการกินเลย ก็ถือว่า "ผ่าน" ได้ปกติเหมือนเดิม
	#if captured != null:
	#	lethal = captured.take_damage(piece.attack_power)
	#	piece_attacked.emit(piece, captured, piece.attack_power, lethal)
	
	var lethal := true  # ไม่มีการกินเลย ก็ถือว่า "ผ่าน" ได้ปกติเหมือนเดิม
	if captured != null:
		# ตำแหน่งจริงของเหยื่อ — กินผ่าน (en passant) เหยื่อไม่ได้อยู่ที่ to_cell แต่อยู่ข้างๆ
		var captured_cell: Vector2i = to_cell
		if is_en_passant:
			captured_cell = Vector2i(to_cell.x, from_cell.y)

		#var damage := PassiveSkills.compute_damage(piece, captured, board_state, captured_cell)
		#lethal = captured.take_damage(damage)
		#piece_attacked.emit(piece, captured, damage, lethal)
		#piece.has_attacked = true  # ใช้ตัดสิน passive "จู่โจมครั้งแรก" ของม้าตาถัดๆ ไป
		
		var damage := PassiveSkills.compute_damage(piece, captured, board_state, captured_cell)
		damage *= piece.attack_buff_multiplier  # บัฟจากสกิลม้า/ควีน (ถ้าเพิ่งใช้) ใช้แล้วรีเซ็ตทันที
		piece.attack_buff_multiplier = 1.0
		lethal = captured.take_damage(damage)
		piece_attacked.emit(piece, captured, damage, lethal)
		piece.has_attacked = true  # ใช้ตัดสิน passive "จู่โจมครั้งแรก" ของม้าตาถัดๆ ไป
		
	# piece_moved = ผู้โจมตีได้ขยับไปช่องปลายทางจริงไหมในตานี้ — false เฉพาะกรณี
	# "โจมตีแล้วเหยื่อไม่ตาย" เท่านั้น (เหยื่อยังกีดขวางอยู่ ขยับเข้าไปแทนที่ไม่ได้)
	var piece_moved: bool = captured == null or lethal

	var move_tweens: Array = []

	if piece_moved:
		# ---------- อัปเดต board_state (ตรรกะเกม) ให้ครบก่อน — เหมือนโค้ดเดิมทุกประการ ----------

		if is_en_passant:
			board_state[from_cell.y][to_cell.x] = null

		# castling: คิงขยับ 2 ช่อง ต้องลากเรือข้ามมาอยู่อีกฝั่งของคิงด้วย (เลื่อนพร้อมกับคิง)
		if piece.piece_kind == ChessPiece.Kind.KING and absi(to_cell.x - from_cell.x) == 2:
			var rook_col: int = COLS - 1 if to_cell.x > from_cell.x else 0
			var rook_dest: int = to_cell.x - 1 if to_cell.x > from_cell.x else to_cell.x + 1
			var rook: ChessPiece = board_state[from_cell.y][rook_col]
			board_state[from_cell.y][rook_col] = null
			board_state[from_cell.y][rook_dest] = rook
			rook.has_moved = true
			move_tweens.append(_place_visual(rook, Vector2i(rook_dest, from_cell.y), true))

		board_state[from_cell.y][from_cell.x] = null
		board_state[to_cell.y][to_cell.x] = piece
		piece.has_moved = true

		if captured != null:
			move_tweens.append(_play_capture(piece, captured, to_cell))
		else:
			AudioManager.play_sfx(SFX_MOVE)  # เสียงกินอยู่ในจังหวะปะทะของ play_capture()/play_attack_bounce() แทน
			move_tweens.append(_place_visual(piece, to_cell, true))
	else:
		# โจมตีไม่ตาย — board_state ไม่เปลี่ยนเลย (ทั้งผู้โจมตีและเหยื่อยังอยู่ที่เดิม)
		move_tweens.append(_play_attack_bounce(piece, captured))

	# ---------- ขั้นที่ 2: รอ animation เลื่อนหมากให้จบก่อน ----------
	animating = true
	for t in move_tweens:
		if t != null:
			await (t as Tween).finished
	animating = false

	# ---------- ขั้นที่ 3: หลังเลื่อนเสร็จแล้วเท่านั้น ค่อยจัดการส่วนที่เหลือ ----------

	# 3a) promote ก่อน (ถ้าเข้าเงื่อนไข) — เฉพาะกรณีขยับไปจริง เพราะโจมตีไม่ตายเบี้ยยังไม่ถึงแถวไหน
	if piece_moved and is_pawn and to_cell.y == ChessRules.promotion_row(piece.side):
		piece = _promote(piece, to_cell, promote_to)

	# 3b) ตั้งช่อง en passant ให้ตาถัดไป เฉพาะตอนเบี้ยเพิ่งเดินรวด 2 ช่องจริง
	if piece_moved and is_pawn and absi(to_cell.y - from_cell.y) == 2:
		en_passant_target = Vector2i(from_cell.x, (from_cell.y + to_cell.y) / 2)
	else:
		en_passant_target = ChessRules.NO_CELL

	# 3c) กฎ 50 ตา: นับใหม่เฉพาะตอนเดินเบี้ยจริงหรือมีการกิน (ตาย) จริง — โจมตีไม่ตายไม่นับรีเซ็ต
	if piece_moved and (is_pawn or captured != null):
		halfmove_clock = 0
	else:
		halfmove_clock += 1
	if side_to_move == ChessPiece.Team.BLACK:
		fullmove_number += 1

	# 3d) สลับตาเดิน — เสียตาเสมอไม่ว่าจะโจมตีตายหรือไม่ตาย (ตัดสินใจโจมตีก็ถือว่าเสียตานี้ไปแล้ว)
	last_move = [from_cell, to_cell]
	_tick_skill_cooldowns()
	side_to_move = ChessRules.opponent(side_to_move)

	# ---------- ขั้นที่ 4: ส่ง signal ให้ UI ไปอัปเดต (ต้องมาหลังสุด) ----------
	move_made.emit(from_cell, to_cell, piece)
	turn_changed.emit(side_to_move)
	_evaluate_status()  # เช็ค check / รุกฆาต / อับ ด้วย side_to_move ที่อัปเดตแล้ว
	return true

## เกมจบแล้วหรือยัง — ใช้สกิลของหมากที่ cell แทนการเดิน (เสียตาเหมือนเดิน แต่ตัวหมากไม่ขยับ)
## ตอนนี้รองรับสกิลครบทุกชนิดตาม ChessPiece.skill_label() — เพิ่ม/แก้ผลลัพธ์ได้ที่ _apply_skill()
signal skill_used(piece: ChessPiece, effect_kind: String)

func try_use_skill(cell: Vector2i) -> bool:
	if animating or game_over:
		return false
	var piece: ChessPiece = ChessRules.at(board_state, cell)
	if piece == null or piece.side != side_to_move or not piece.can_use_skill():
		return false

	var effect_kind := _apply_skill(piece)
	skill_used.emit(piece, effect_kind)

	last_move = [cell, cell]
	_tick_skill_cooldowns()
	piece.skill_cooldown_remaining = ChessPiece.SKILL_COOLDOWN_TURNS
	side_to_move = ChessRules.opponent(side_to_move)
	turn_changed.emit(side_to_move)
	_evaluate_status()
	return true

## ใช้ผลของสกิลจริง คืนชื่อประเภทเอฟเฟกต์ ("heal"/"buff"/"rally") ให้ piece_spawner.gd เลือกภาพให้ตรง
func _apply_skill(piece: ChessPiece) -> String:
	match piece.piece_kind:
		ChessPiece.Kind.PAWN:
			piece.hp = minf(piece.hp + 40.0, piece.max_hp)
			return "heal"
		ChessPiece.Kind.BISHOP:
			piece.hp = piece.max_hp
			return "heal"
		ChessPiece.Kind.ROOK:
			piece.max_hp += 30.0
			piece.hp += 30.0
			return "heal"
		ChessPiece.Kind.KNIGHT:
			piece.attack_buff_multiplier = 1.5
			return "buff"
		ChessPiece.Kind.QUEEN:
			piece.attack_buff_multiplier = 2.0
			return "buff"
		ChessPiece.Kind.KING:
			for row in board_state:
				for p in row:
					if p != null and p.side == piece.side:
						p.hp = minf(p.hp + 20.0, p.max_hp)
			return "rally"
		_:
			return ""

func _evaluate_status() -> void:
	var state: Dictionary = ChessRules.status(board_state, side_to_move, en_passant_target, halfmove_clock)
	var result: String = state.result
	if result != "":
		game_over = true
		# รุกฆาตเท่านั้นที่มีผู้ชนะ กรณีอื่น (อับ / หมากไม่พอ / 50 ตา) คือเสมอ
		var winner: int = ChessRules.opponent(side_to_move) if result == "checkmate" else -1
		game_ended.emit(result, winner)
	elif state.check:
		check_alerted.emit(side_to_move)

## เปลี่ยนเบี้ยเป็นหมากตัวใหม่ คืน node ตัวใหม่ (ตัวเก่าถูกลบทิ้ง)
func _promote(pawn: ChessPiece, cell: Vector2i, kind: int) -> ChessPiece:
	var pieces := get_node_or_null("Pieces")
	if pieces == null or not pieces.has_method("spawn_piece"):
		return pawn
	var promoted: ChessPiece = pieces.spawn_piece(ChessPiece.art_name(kind), pawn.side, cell, kind)
	if promoted == null:
		return pawn
	promoted.has_moved = true
	if pieces.has_method("play_promote_effect"):
		pieces.play_promote_effect(promoted, cell)
	pawn.queue_free()
	return promoted

## ให้ node Pieces จัดตำแหน่ง/ขนาด sprite ใหม่ตามช่องปลายทาง
## (ขนาดเปลี่ยนตามแถวด้วย เพราะกระดานเป็นเปอร์สเปกทีฟ แถวไกลกล้องช่องเล็กกว่า)
## animate = true คืน Tween ที่กำลังเลื่อนอยู่ ให้ try_move() await ต่อได้
func _place_visual(piece: ChessPiece, cell: Vector2i, animate: bool = false) -> Tween:
	var pieces := get_node_or_null("Pieces")
	if pieces != null and pieces.has_method("place_piece"):
		return pieces.place_piece(piece, cell, animate)
	return null

## ให้ node Pieces เล่น animation พุ่งเข้าปะทะ + เหยื่อล้มหาย (ดู piece_spawner.gd:play_capture)
## ถ้าหา Pieces ไม่เจอ (ไม่ควรเกิด) ให้ fallback ลบเหยื่อทันทีแล้วเดินแบบปกติ กันเกมค้าง
func _play_capture(attacker: ChessPiece, victim: ChessPiece, cell: Vector2i) -> Tween:
	var pieces := get_node_or_null("Pieces")
	if pieces != null and pieces.has_method("play_capture"):
		return pieces.play_capture(attacker, victim, cell)
	victim.queue_free()
	return _place_visual(attacker, cell, true)
	## ให้ node Pieces เล่น animation พุ่งเข้าปะทะแล้วถอยกลับ (โจมตีสำเร็จแต่เหยื่อไม่ตาย)
## ถ้าหา Pieces ไม่เจอ (ไม่ควรเกิด) ให้ fallback เฉยๆ ไม่ทำอะไร (board_state ไม่เปลี่ยนอยู่แล้ว)
func _play_attack_bounce(attacker: ChessPiece, victim: ChessPiece) -> Tween:
	var pieces := get_node_or_null("Pieces")
	if pieces != null and pieces.has_method("play_attack_bounce"):
		return pieces.play_attack_bounce(attacker, victim)
	return null

## ลดตัวนับ cooldown สกิลของหมากทุกตัวบนกระดานลง 1 ตา (ไม่ต่ำกว่า 0) — เรียกทุกครั้งที่เสียตา
## ไม่ว่าจะเป็นการเดินปกติหรือการใช้สกิล เพื่อให้สกิลใช้ซ้ำได้ทุก N ตาแทนที่จะหมดสิทธิ์ตลอดเกม
func _tick_skill_cooldowns() -> void:
	for row in board_state:
		for p in row:
			if p != null and p.skill_cooldown_remaining > 0:
				p.skill_cooldown_remaining -= 1

## บังคับเสียตาโดยไม่เดินอะไรเลย (หมดเวลาต่อตา) — ทำ bookkeeping เหมือนท้าย try_move() ทุกอย่าง
## ยกเว้นไม่มีการขยับหมาก/กิน/promote เพราะไม่มีตาเดินจริงเกิดขึ้น
func force_pass_turn() -> void:
	if animating or game_over:
		return
	last_move = []
	en_passant_target = ChessRules.NO_CELL
	_tick_skill_cooldowns()
	if side_to_move == ChessPiece.Team.BLACK:
		fullmove_number += 1
	side_to_move = ChessRules.opponent(side_to_move)
	turn_changed.emit(side_to_move)
	_evaluate_status()

func _process(_delta: float) -> void:
	if show_debug_grid and Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	# เส้นตารางนี้มีไว้ช่วยลากมุม Marker2D ให้ตรงกับภาพตอน edit เท่านั้น
	# ห้ามให้หลุดไปโชว์ตอนเล่นเกมจริง ไม่งั้นจะทับกรอบเรืองแสงและรกตา
	if not show_debug_grid or not Engine.is_editor_hint():
		return
	if not (top_left and top_right and bottom_left and bottom_right):
		return
	var color := Color(1, 0.15, 0.15, 0.65)
	for i in range(COLS + 1):
		draw_line(to_local(_project(i, 0)), to_local(_project(i, ROWS)), color, 2.0)
	for j in range(ROWS + 1):
		draw_line(to_local(_project(0, j)), to_local(_project(COLS, j)), color, 2.0)
