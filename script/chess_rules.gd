extends RefCounted
class_name ChessRules

## กติกาหมากรุกสากลทั้งหมด เป็น static function ล้วนๆ ไม่ผูกกับ node ใดๆ
## ทำให้เทสต์/เรียกใช้ซ้ำได้ง่าย และ Board.gd แค่เรียกใช้เป็น "สมอง" ของเกม
##
## รูปแบบ state: Array 8 แถว แต่ละแถวเป็น Array 8 ช่อง เก็บ ChessPiece หรือ null
## อ้างอิงช่องด้วย Vector2i(col, row) — ตรงกับที่ Board.gd ใช้อยู่เดิม (x = col, y = row)
##
## รองรับ: เดินตามชนิดหมาก, กิน, รุก (check), ห้ามเดินให้ตัวเองถูกรุก,
##         castling, en passant, promotion, รุกฆาต, อับ (stalemate),
##         หมากไม่พอชนะ (insufficient material), กฎ 50 ตา
## ยังไม่รองรับ: เสมอจากการเดินซ้ำ 3 ครั้ง (threefold repetition)

const COLS := 8
const ROWS := 8

const NO_CELL := Vector2i(-1, -1)

const KNIGHT_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, -1), Vector2i(1, -2),
	Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, 2),
]
const KING_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
]
const ROOK_DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
]
const BISHOP_DIRS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]


# ---------------------------------------------------------------- ตัวช่วยพื้นฐาน

static func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < COLS and cell.y >= 0 and cell.y < ROWS


static func at(state: Array, cell: Vector2i) -> ChessPiece:
	if not in_bounds(cell):
		return null
	return state[cell.y][cell.x]


static func opponent(p_side: int) -> int:
	return ChessPiece.Team.BLACK if p_side == ChessPiece.Team.WHITE else ChessPiece.Team.WHITE


## ทิศที่เบี้ยเดินไปข้างหน้า: ขาวอยู่แถวล่าง (row 7) จึงเดินขึ้นไปทาง row 0
static func forward(p_side: int) -> int:
	return -1 if p_side == ChessPiece.Team.WHITE else 1


## แถวเริ่มต้นของเบี้ย (แถวที่ยังเดิน 2 ช่องได้)
static func pawn_start_row(p_side: int) -> int:
	return 6 if p_side == ChessPiece.Team.WHITE else 1


## แถวปลายทางที่เบี้ยจะ promote
static func promotion_row(p_side: int) -> int:
	return 0 if p_side == ChessPiece.Team.WHITE else 7


static func empty_state() -> Array:
	var state: Array = []
	for row in range(ROWS):
		var row_data: Array = []
		for col in range(COLS):
			row_data.append(null)
		state.append(row_data)
	return state


## ก็อป state แบบตื้น — ตัว ChessPiece ยังเป็นตัวเดิม (เราแค่ย้ายตำแหน่งใน array
## ระหว่างจำลองตาเดิน ไม่ได้แก้ค่าอะไรในตัวหมาก จึงปลอดภัย)
static func copy_state(state: Array) -> Array:
	var out: Array = []
	for row in state:
		out.append((row as Array).duplicate())
	return out


# ------------------------------------------------------- ตาเดินดิบ (ยังไม่กรองรุก)

## ตาเดินที่ "ถูกต้องตามการเคลื่อนที่ของหมากชนิดนั้น" แต่ยังไม่ได้เช็คว่า
## เดินแล้วคิงตัวเองจะถูกรุกหรือไม่ — ใช้ legal_moves() ถ้าต้องการตาเดินที่ใช้ได้จริง
static func pseudo_moves(state: Array, from: Vector2i, ep_target: Vector2i, allow_castling: bool = true) -> Array:
	var piece := at(state, from)
	if piece == null:
		return []

	var moves: Array = []
	match piece.piece_kind:
		ChessPiece.Kind.PAWN:
			_add_pawn_moves(state, from, piece, ep_target, moves)
		ChessPiece.Kind.KNIGHT:
			_add_steps(state, from, KNIGHT_OFFSETS, piece.side, moves)
		ChessPiece.Kind.BISHOP:
			_add_rays(state, from, BISHOP_DIRS, piece.side, moves)
		ChessPiece.Kind.ROOK:
			_add_rays(state, from, ROOK_DIRS, piece.side, moves)
		ChessPiece.Kind.QUEEN:
			_add_rays(state, from, ROOK_DIRS, piece.side, moves)
			_add_rays(state, from, BISHOP_DIRS, piece.side, moves)
		ChessPiece.Kind.KING:
			_add_steps(state, from, KING_OFFSETS, piece.side, moves)
			if allow_castling:
				_add_castling(state, from, piece, moves)
	return moves


static func _add_pawn_moves(state: Array, from: Vector2i, piece: ChessPiece, ep_target: Vector2i, moves: Array) -> void:
	var dir := forward(piece.side)

	# เดินหน้า 1 ช่อง (ต้องว่าง) และ 2 ช่องถ้ายังอยู่แถวเริ่มต้นและว่างทั้งคู่
	var one := from + Vector2i(0, dir)
	if in_bounds(one) and at(state, one) == null:
		moves.append(one)
		var two := from + Vector2i(0, dir * 2)
		if from.y == pawn_start_row(piece.side) and in_bounds(two) and at(state, two) == null:
			moves.append(two)

	# กินทแยง 2 ข้าง — ต้องมีหมากฝ่ายตรงข้ามอยู่ หรือเป็นช่อง en passant
	for dx in [-1, 1]:
		var cap := from + Vector2i(dx, dir)
		if not in_bounds(cap):
			continue
		var target := at(state, cap)
		if target != null:
			if target.side != piece.side:
				moves.append(cap)
		elif cap == ep_target:
			moves.append(cap)


## หมากที่เดินทีละก้าว (ม้า, คิง)
static func _add_steps(state: Array, from: Vector2i, offsets: Array[Vector2i], p_side: int, moves: Array) -> void:
	for offset in offsets:
		var cell := from + offset
		if not in_bounds(cell):
			continue
		var target := at(state, cell)
		if target == null or target.side != p_side:
			moves.append(cell)


## หมากที่เดินเป็นเส้นยาวจนติดตัวอื่น (เรือ, บิชอป, ควีน)
static func _add_rays(state: Array, from: Vector2i, dirs: Array[Vector2i], p_side: int, moves: Array) -> void:
	for dir in dirs:
		var cell := from + dir
		while in_bounds(cell):
			var target := at(state, cell)
			if target == null:
				moves.append(cell)
			else:
				if target.side != p_side:
					moves.append(cell)  # กินได้ แต่ไปต่อไม่ได้
				break
			cell += dir


## Castling — เงื่อนไขครบตามกติกาสากล:
## คิงและเรือต้องยังไม่เคยเดิน, ช่องระหว่างกลางต้องว่างหมด,
## และคิงต้องไม่กำลังถูกรุก / ไม่เดินผ่าน / ไม่ไปหยุดบนช่องที่ถูกโจมตี
static func _add_castling(state: Array, from: Vector2i, king: ChessPiece, moves: Array) -> void:
	if king.has_moved:
		return
	if is_in_check(state, king.side):
		return

	var enemy := opponent(king.side)
	for corner in [0, COLS - 1]:
		var rook_col: int = corner
		var rook := at(state, Vector2i(rook_col, from.y))
		if rook == null or rook.side != king.side or rook.piece_kind != ChessPiece.Kind.ROOK or rook.has_moved:
			continue

		var step: int = 1 if rook_col > from.x else -1

		# ช่องระหว่างคิงกับเรือต้องว่างทั้งหมด
		var blocked := false
		var col: int = from.x + step
		while col != rook_col:
			if state[from.y][col] != null:
				blocked = true
				break
			col += step
		if blocked:
			continue

		var pass_cell := Vector2i(from.x + step, from.y)
		var dest := Vector2i(from.x + step * 2, from.y)
		if is_square_attacked(state, pass_cell, enemy):
			continue
		if is_square_attacked(state, dest, enemy):
			continue
		moves.append(dest)


# ------------------------------------------------------------------ การรุก (check)

## ช่องที่หมากตัวนี้ "โจมตีถึง" — ต่างจากตาเดินตรงที่เบี้ยโจมตีเฉพาะแนวทแยง
## (เดินหน้าตรงๆ ไม่นับเป็นการโจมตี) และคิงไม่นับ castling ป้องกันการเรียกวนซ้ำ
static func attack_squares(state: Array, from: Vector2i) -> Array:
	var piece := at(state, from)
	if piece == null:
		return []
	if piece.piece_kind == ChessPiece.Kind.PAWN:
		var dir := forward(piece.side)
		var out: Array = []
		for dx in [-1, 1]:
			var cell := from + Vector2i(dx, dir)
			if in_bounds(cell):
				out.append(cell)
		return out
	return pseudo_moves(state, from, NO_CELL, false)


static func is_square_attacked(state: Array, cell: Vector2i, by_side: int) -> bool:
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.side != by_side:
				continue
			if cell in attack_squares(state, Vector2i(col, row)):
				return true
	return false


static func find_king(state: Array, p_side: int) -> Vector2i:
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece != null and piece.side == p_side and piece.piece_kind == ChessPiece.Kind.KING:
				return Vector2i(col, row)
	return NO_CELL


static func is_in_check(state: Array, p_side: int) -> bool:
	var king_cell := find_king(state, p_side)
	if king_cell == NO_CELL:
		return false  # ไม่มีคิงบนกระดาน (เช่นตอนตั้งกระดานทดสอบ) ถือว่าไม่ถูกรุก
	return is_square_attacked(state, king_cell, opponent(p_side))


# --------------------------------------------------------------- ตาเดินที่ใช้ได้จริง

## จำลองการเดินบน state ก๊อปใหม่ (รวมผลข้างเคียงของ en passant และ castling)
## ไม่แตะ state เดิมและไม่แก้ค่าในตัวหมาก — ใช้สำหรับทดสอบว่าเดินแล้วคิงปลอดภัยไหม
static func apply(state: Array, from: Vector2i, to: Vector2i, ep_target: Vector2i) -> Array:
	var new_state := copy_state(state)
	var piece := at(state, from)
	if piece == null:
		return new_state

	# en passant: เบี้ยที่ถูกกินไม่ได้อยู่ช่องปลายทาง แต่อยู่ช่องข้างๆ ในแถวเดิม
	if piece.piece_kind == ChessPiece.Kind.PAWN and to == ep_target and at(state, to) == null:
		new_state[from.y][to.x] = null

	# castling: คิงขยับ 2 ช่อง แปลว่าต้องลากเรือมาอยู่ฝั่งตรงข้ามคิงด้วย
	if piece.piece_kind == ChessPiece.Kind.KING and absi(to.x - from.x) == 2:
		var rook_col: int = COLS - 1 if to.x > from.x else 0
		var rook_dest: int = to.x - 1 if to.x > from.x else to.x + 1
		new_state[from.y][rook_dest] = new_state[from.y][rook_col]
		new_state[from.y][rook_col] = null

	new_state[to.y][to.x] = piece
	new_state[from.y][from.x] = null
	return new_state


## ตาเดินที่ใช้ได้จริง = ตาเดินดิบ ที่กรองเอาตาที่ทำให้คิงตัวเองถูกรุกออกแล้ว
static func legal_moves(state: Array, from: Vector2i, ep_target: Vector2i) -> Array:
	var piece := at(state, from)
	if piece == null:
		return []
	var out: Array = []
	for to in pseudo_moves(state, from, ep_target):
		if not is_in_check(apply(state, from, to, ep_target), piece.side):
			out.append(to)
	return out


## ตาเดินทั้งหมดของฝ่ายหนึ่ง คืนเป็น Array ของ {"from": Vector2i, "to": Vector2i}
static func all_legal_moves(state: Array, p_side: int, ep_target: Vector2i) -> Array:
	var out: Array = []
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.side != p_side:
				continue
			var from := Vector2i(col, row)
			for to in legal_moves(state, from, ep_target):
				out.append({"from": from, "to": to})
	return out


## เช็คแบบลัด — เจอตาแรกก็หยุด เร็วกว่า all_legal_moves มากเวลาใช้ตัดสินรุกฆาต/อับ
static func has_legal_move(state: Array, p_side: int, ep_target: Vector2i) -> bool:
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.side != p_side:
				continue
			if not legal_moves(state, Vector2i(col, row), ep_target).is_empty():
				return true
	return false


# ------------------------------------------------------------------- สถานะของเกม

## หมากเหลือน้อยจนไม่มีทางรุกฆาตได้เลย → เสมอทันที
## ครอบคลุม: คิงเปล่า vs คิงเปล่า, คิง+บิชอป vs คิง, คิง+ม้า vs คิง,
##           และคิง+บิชอป vs คิง+บิชอป ที่บิชอปทั้งคู่อยู่ช่องสีเดียวกัน
static func insufficient_material(state: Array) -> bool:
	var minors: Array = []  # หมากที่ไม่ใช่คิง
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.piece_kind == ChessPiece.Kind.KING:
				continue
			# เบี้ย เรือ ควีน เหลืออยู่แม้ตัวเดียวก็ยังรุกฆาตได้ → ไม่เสมอ
			if piece.piece_kind != ChessPiece.Kind.BISHOP and piece.piece_kind != ChessPiece.Kind.KNIGHT:
				return false
			minors.append({"piece": piece, "cell": Vector2i(col, row)})

	if minors.size() <= 1:
		return true
	if minors.size() == 2:
		var a: Dictionary = minors[0]
		var b: Dictionary = minors[1]
		var both_bishops: bool = (a.piece as ChessPiece).piece_kind == ChessPiece.Kind.BISHOP \
			and (b.piece as ChessPiece).piece_kind == ChessPiece.Kind.BISHOP
		if both_bishops and (a.piece as ChessPiece).side != (b.piece as ChessPiece).side:
			var color_a: int = ((a.cell as Vector2i).x + (a.cell as Vector2i).y) % 2
			var color_b: int = ((b.cell as Vector2i).x + (b.cell as Vector2i).y) % 2
			return color_a == color_b
	return false


## สรุปสถานะกระดานสำหรับฝ่ายที่ถึงตาเดิน
## คืน {"check": bool, "result": String} โดย result == "" แปลว่าเกมยังไม่จบ
## ค่าอื่นที่เป็นไปได้: "checkmate", "stalemate", "insufficient_material", "fifty_move"
static func status(state: Array, side_to_move: int, ep_target: Vector2i, halfmove_clock: int) -> Dictionary:
	var check := is_in_check(state, side_to_move)
	var result := ""
	if not has_legal_move(state, side_to_move, ep_target):
		result = "checkmate" if check else "stalemate"
	elif insufficient_material(state):
		result = "insufficient_material"
	elif halfmove_clock >= 100:  # 50 ตาของทั้งสองฝ่าย = 100 halfmove
		result = "fifty_move"
	return {"check": check, "result": result}
