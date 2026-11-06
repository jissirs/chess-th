extends Node

## เดินให้ฝ่ายศัตรู (ดำ) อัตโนมัติเมื่อ GameManager.game_mode == "PVC"
## ผูกสคริปต์นี้กับ node ลูกของ Board (เช่นชื่อ "AIPlayer") เหมือน click_to_move.gd
## กติกาการเลือกตาเดินอยู่ใน chess_ai.gd ไฟล์นี้แค่ "ฟังจังหวะ" แล้วสั่ง Board.try_move()

const AI_SIDE := ChessPiece.Team.BLACK
## หน่วงเวลาก่อนเดิน ให้ความรู้สึกเหมือน "กำลังคิด" ไม่ใช่เดินทันทีจนดูเหมือนบั๊ก
const THINK_DELAY := 0.5

## ความลึกการมองล่วงหน้าไม่ตายตัวแล้ว — อ่านจาก GameManager.ai_search_depth() ตอนจะเดินทุกครั้ง
## (ผู้เล่นปรับระดับ EASY/NORMAL/HARD ได้จากหน้า Settings แม้ระหว่างเกม มีผลตั้งแต่ตาถัดไป)

@onready var board: Node = get_parent()

func _ready() -> void:
	board.turn_changed.connect(_on_turn_changed)
	# เผื่อกรณีเกมเริ่มแล้วดันเป็นตา AI พอดี (ปัจจุบันไม่เกิดเพราะฝ่ายขาวเดินก่อนเสมอ แต่กันไว้)
	_maybe_take_turn(board.side_to_move)

func _on_turn_changed(side: int) -> void:
	_maybe_take_turn(side)

func _maybe_take_turn(side: int) -> void:
	if GameManager.game_mode != "PVC":
		return  # โหมด PVP ปล่อยให้ผู้เล่นคุมทั้งสองฝ่ายตามปกติ ไม่ต้องยุ่ง
	if side != AI_SIDE or board.game_over:
		return

	await get_tree().create_timer(THINK_DELAY, false).timeout

	# เช็คซ้ำหลังหน่วงเวลา เผื่อสถานะเปลี่ยนไปแล้วระหว่างรอ (เช่นผู้เล่นกด Restart/Main Menu)
	if board.game_over or board.side_to_move != AI_SIDE:
		return

	var action: Dictionary = ChessAI.best_move(board.board_state, AI_SIDE, board.en_passant_target, GameManager.ai_search_depth(), board.ai_skill_moves_remaining <= 0, board.position_counts)
	if action.is_empty():
		return  # ไม่มีตาเดิน/สกิลให้เลือกเลย (ไม่ควรเกิด เพราะ Board._evaluate_status ควรจับจบเกมได้ก่อนหน้านี้แล้ว)
	if action.get("type", "") == "skill":
		board.try_use_skill(action.cell)
	else:
		board.try_move(action.from, action.to)
