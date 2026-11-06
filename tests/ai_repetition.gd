extends SceneTree

## เทสต์: AI หลบ/ยอมรับการเสมอแบบซ้ำตำแหน่ง 3 ครั้งตามความได้เปรียบ
var failures := 0
var allocated: Array = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok:
		failures += 1

func piece(state: Array, kind: int, side: int, x: int, y: int) -> ChessPiece:
	var p = ChessPiece.new()
	p.piece_kind = kind
	p.side = side
	p.hp = 100.0
	p.attack_power = ChessPiece.base_attack(kind)
	state[y][x] = p
	allocated.append(p)
	return p

## คีย์ตำแหน่งหลัง AI (ดำ) เดินตา move ตามที่ Board จะนับจริง
func key_after(state: Array, move: Dictionary) -> String:
	var result = ChessAI._apply_hp_aware(state, move.from, move.to, ChessRules.NO_CELL, {})
	var moved: ChessPiece = state[move.from.y][move.from.x]
	return ChessRules.position_key(result.state, ChessPiece.Team.WHITE, ChessRules.NO_CELL, result.overrides, moved)

func chosen_move(state: Array, counts: Dictionary, tries: int) -> Array:
	var picks: Array = []
	for i in tries:
		var action: Dictionary = ChessAI.best_move(state, ChessPiece.Team.BLACK, ChessRules.NO_CELL, 1, false, counts)
		picks.append([action.from, action.to])
	return picks

func run() -> void:
	# ---------- AI ได้เปรียบ: ต้องไม่เลือกตาที่ทำให้ซ้ำครบ 3 ----------
	var state = ChessRules.empty_state()
	piece(state, ChessPiece.Kind.KING, 0, 7, 7)
	piece(state, ChessPiece.Kind.KING, 1, 0, 0)
	piece(state, ChessPiece.Kind.QUEEN, 1, 3, 3)
	var moves: Array = ChessRules.all_legal_moves(state, ChessPiece.Team.BLACK, ChessRules.NO_CELL)
	var target: Dictionary = moves[0]
	var counts := {key_after(state, target): 2}
	var avoided := true
	for pick in chosen_move(state, counts, 40):
		if pick[0] == target.from and pick[1] == target.to:
			avoided = false
	check(avoided, "AI with a material lead never plays the move that makes a third repetition")

	# ---------- ซ้ำแค่ 1 ครั้ง: หักคะแนนเล็กน้อย ไม่ใช่เสมอ ----------
	var minor := {key_after(state, target): 1}
	var best_plain: Dictionary = ChessAI.best_move(state, ChessPiece.Team.BLACK, ChessRules.NO_CELL, 1, false)
	check(not best_plain.is_empty(), "AI still returns a move with empty history")
	check(not minor.is_empty(), "history with one earlier occurrence is accepted")

	# ---------- AI เสียเปรียบ: ยอมรับเสมอได้ (0 ดีกว่าแพ้) ----------
	var behind = ChessRules.empty_state()
	piece(behind, ChessPiece.Kind.KING, 1, 0, 0)
	piece(behind, ChessPiece.Kind.KING, 0, 7, 7)
	piece(behind, ChessPiece.Kind.QUEEN, 0, 6, 5)
	var behind_moves: Array = ChessRules.all_legal_moves(behind, ChessPiece.Team.BLACK, ChessRules.NO_CELL)
	var repeat_move: Dictionary = behind_moves[0]
	var behind_counts := {key_after(behind, repeat_move): 2}
	var took_draw := true
	for pick in chosen_move(behind, behind_counts, 20):
		if not (pick[0] == repeat_move.from and pick[1] == repeat_move.to):
			took_draw = false
	check(took_draw, "AI that is losing prefers the repetition draw")

	# ---------- คีย์ตำแหน่งของ AI ตรงกับ Board จริง ----------
	var board = load("res://script/Board.gd").new()
	board.board_state = state
	allocated.append(board)
	var sim_key := key_after(state, target)
	var result = ChessAI._apply_hp_aware(state, target.from, target.to, ChessRules.NO_CELL, {})
	board.board_state = result.state
	var mover: ChessPiece = result.state[target.to.y][target.to.x]
	mover.has_moved = true  # Board.try_move() ตั้งค่านี้ก่อนประเมินสถานะ — การจำลองของ AI ไม่แตะตัวหมากจริง จึงต้องบอกผ่าน just_moved
	board.side_to_move = ChessPiece.Team.WHITE
	board._evaluate_status()
	check(board.position_counts.has(sim_key), "AI simulation key equals the key the Board records after the real move")

	for item in allocated:
		if is_instance_valid(item):
			item.free()
	print("FAILURES=", failures)
	quit(1 if failures else 0)
