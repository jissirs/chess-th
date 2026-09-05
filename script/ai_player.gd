extends Node

## เดินให้ฝ่ายศัตรู (ดำ) อัตโนมัติเมื่อ GameManager.game_mode == "PVC"
## ผูกสคริปต์นี้กับ node ลูกของ Board (เช่นชื่อ "AIPlayer") เหมือน click_to_move.gd
## กติกาการเลือกตาเดินอยู่ใน chess_ai.gd ไฟล์นี้แค่ "ฟังจังหวะ" แล้วสั่ง Board.try_move()

const AI_SIDE := ChessPiece.Team.BLACK
## หน่วงเวลาก่อนเดิน ให้ความรู้สึกเหมือน "กำลังคิด" ไม่ใช่เดินทันทีจนดูเหมือนบั๊ก
const THINK_DELAY := 0.5

## ความลึกการมองล่วงหน้า (จำนวนครึ่งตาที่ AI จำลองไปข้างหน้า) ยิ่งมากยิ่งฉลาดแต่ยิ่งช้า
## depth 2 = มองตาตัวเอง + ตาตอบโต้ของคู่แข่ง เพียงพอสำหรับ AI ระดับเล่นสนุกๆ ไม่หน่วงจนรู้สึกได้
const SEARCH_DEPTH := 2

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

	await get_tree().create_timer(THINK_DELAY).timeout

	# เช็คซ้ำหลังหน่วงเวลา เผื่อสถานะเปลี่ยนไปแล้วระหว่างรอ (เช่นผู้เล่นกด Restart/Main Menu)
	if board.game_over or board.side_to_move != AI_SIDE:
		return

	var action: Dictionary = ChessAI.best_move(board.board_state, AI_SIDE, board.en_passant_target, SEARCH_DEPTH)
	if action.is_empty():
		return  # ไม่มีตาเดิน/สกิลให้เลือกเลย (ไม่ควรเกิด เพราะ Board._evaluate_status ควรจับจบเกมได้ก่อนหน้านี้แล้ว)
	if action.get("type", "") == "skill":
		board.try_use_skill(action.cell)
	else:
		board.try_move(action.from, action.to)
