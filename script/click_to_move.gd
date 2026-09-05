extends Node2D

## ระบบคลิกเดินหมาก — รับ input แล้วส่งต่อให้ Board.try_move() ตัดสิน
## กติกาทั้งหมดอยู่ใน chess_rules.gd ไฟล์นี้ไม่ตัดสินอะไรเองเลย
##
## คลิกหมากฝ่ายตัวเอง = เลือก (ขึ้นจุดไฮไลต์ช่องที่เดินได้)
## คลิกช่องที่ไฮไลต์ = เดิน, คลิกช่องเดิม = ยกเลิก, คลิกหมากตัวอื่นของตัวเอง = เปลี่ยนไปเลือกตัวนั้น

const SELECTED_SCALE_MULT := 1.15  # ขยายหมากที่เลือกไว้เล็กน้อย ให้เห็นชัดว่าเลือกอยู่
const SELECT_DURATION := 0.32  # ระยะเวลาเด้งตอนเลือก/ยกเลิกเลือก

const SFX_SELECT := preload("res://asset/audio/select_click.mp3")

const PULSE_SPEED := 3.2   # เรเดียนต่อวินาที ยิ่งมากยิ่งเต้นถี่
const PULSE_MIN := 0.55    # ความเข้มแสงต่ำสุดตอนจังหวะจาง (0-1)
const PULSE_MAX := 1.0     # ความเข้มแสงสูงสุดตอนจังหวะสว่าง

## หมากที่เบี้ยจะกลายเป็นตอนถึงแถวสุดท้าย
## TODO: ทำ UI ให้ผู้เล่นเลือกเองตอน promote (ตอนนี้เป็นควีนอัตโนมัติ)
@export var auto_promote_to: ChessPiece.Kind = ChessPiece.Kind.QUEEN

var selected_cell: Vector2i = ChessRules.NO_CELL
var legal_targets: Array = []
var skill_button: SkillButton = null
var promotion_picker: PromotionPicker = null
var _pending_promotion: Dictionary = {}
var _skill_tooltip_visible: bool = false
var _pulse_time: float = 0.0

@onready var board: Node = get_parent()

func _ready() -> void:
	# กรอบไฮไลต์ต้องอยู่ "เหนือพื้นหลัง แต่ใต้ตัวหมาก" — z_index เทียบกันทั้งฉาก
	# ไม่ใช่แค่ในกลุ่มพี่น้อง ถ้าลด z ตัวเองต่ำกว่า 0 จะโดนพื้นหลังบังไปด้วย (เจอปัญหานี้มาแล้ว)
	# จึงยกตัวหมากขึ้นแทน (ดู Pieces.z_index ใน piece_spawner.gd) แล้วปล่อยตัวนี้ไว้ที่ 0 ตามปกติ
	board.turn_changed.connect(_on_board_changed)
	board.game_ended.connect(_on_game_ended)

func _on_board_changed(_side: int) -> void:
	queue_redraw()  # วงแหวนเตือน "ถูกรุก" ต้องวาดใหม่ทุกครั้งที่เปลี่ยนตา

func _on_game_ended(_result: String, _winner: int) -> void:
	_deselect()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()

## Board ตั้ง board_state ใน _ready ของมัน ซึ่งรันหลัง _ready ของ node ลูกอย่างเรานี้
## เลยต้องกันไว้ ไม่งั้นอ่าน board_state ตอนยังเป็น array ว่างแล้ว index หลุด
func _board_ready() -> bool:
	return board.board_state.size() == ChessRules.ROWS

func _handle_click() -> void:
	if promotion_picker != null and is_instance_valid(promotion_picker):
		_handle_promotion_click()
		return
	if board.game_over or board.animating or not _board_ready():
		return
	if GameManager.game_mode == "PVC" and board.side_to_move == ChessPiece.Team.BLACK:
		return  # ตาของ AI (ฝ่ายดำ) ในโหมด PVC ผู้เล่นคุมฝ่ายดำเองไม่ได้ (ดู ai_player.gd)

	# เช็คว่าคลิกโดนปุ่มสกิลไหมก่อนอย่างอื่นทั้งหมด (ต้องมีหมากถูกเลือกอยู่ก่อน ปุ่มถึงจะโผล่)
	if skill_button != null and is_instance_valid(skill_button):
		var mouse := get_global_mouse_position()
		if mouse.distance_to(skill_button.global_position) <= SkillButton.HIT_RADIUS:
			board.try_use_skill(selected_cell)
			_deselect()
			return

	var cell := _cell_at_mouse()
	if cell.x < 0:
		return  # กระดานยังไม่พร้อม (มุมยังไม่ถูกกำหนด)

	if selected_cell != ChessRules.NO_CELL:
		if cell == selected_cell:
			_deselect()  # คลิกช่องเดิมซ้ำ = ยกเลิกการเลือก
			return
		if cell in legal_targets:
			# ลำดับตรงนี้สำคัญ ห้ามสลับ:
			# 1) จำ "ช่องต้นทาง" ไว้ก่อน เพราะขั้นต่อไปจะล้าง selected_cell ทิ้ง
			var from := selected_cell
			# 2) เคลียร์สถานะเลือก (ไม่ tween คืนขนาด) ก่อนสั่งเดิน
			_clear_selection_state()
			# 3) ค่อยสั่งเดิน — tween การเดินใน Board.try_move() จะรับช่วงขนาดปัจจุบัน
			#    ของหมาก (ที่ยังขยายค้างจากตอนเลือก) ต่อไปเอง ไม่ต้อง tween คืนขนาดแยก
			#    เพราะถ้าสั่ง _deselect() ตรงนี้แทน จะมี 2 tween แย่งกันแก้ scale พร้อมกัน
			var moving_piece := ChessRules.at(board.board_state, from)
			if moving_piece != null and moving_piece.piece_kind == ChessPiece.Kind.PAWN \
					and cell.y == ChessRules.promotion_row(moving_piece.side):
				_show_promotion_picker(from, cell)
			else:
				board.try_move(from, cell, auto_promote_to)
			return
		# คลิกช่องอื่นที่เดินไปไม่ได้ — ลองตีความว่าอยากเปลี่ยนไปเลือกหมากตัวนั้นแทน
		_deselect()

	_try_select(cell)

## หาช่องที่ผู้เล่นตั้งใจคลิก
## board.world_to_cell() หาแค่ "ช่องที่ศูนย์กลางใกล้เมาส์ที่สุด" ซึ่งใช้ไม่ได้ดีกับหมากตัวสูง
## เพราะตัวหมากยืนล้ำขึ้นไปทับแถวข้างบน คลิกที่ลำตัวจะไปโดนช่องแถวบนแทน
## จึงเช็คว่าคลิกโดนรูปหมากตัวไหนก่อน แล้วค่อย fallback ไปใช้ระยะทางถึงศูนย์กลางช่อง
func _cell_at_mouse() -> Vector2i:
	var mouse := get_global_mouse_position()
	var grid_cell: Vector2i = board.world_to_cell(mouse)
	var piece_cell := _piece_cell_under(mouse)
	if piece_cell == ChessRules.NO_CELL:
		return grid_cell
	# ถ้าเลือกหมากไว้แล้วและช่องกริดใต้เมาส์เป็นเป้าหมายที่เดินได้จริง ให้เดินไปช่องนั้น
	# (ไม่งั้นจะเดินเข้าช่องว่างที่โดนตัวหมากตัวอื่นบังอยู่ไม่ได้เลย)
	if selected_cell != ChessRules.NO_CELL and grid_cell in legal_targets:
		return grid_cell
	return piece_cell

## หมากที่รูปคลุมจุดนี้อยู่ ถ้าซ้อนกันหลายตัวเอาตัวที่อยู่ใกล้กล้องที่สุด (y มากสุด)
## ซึ่งคือตัวที่ y-sort วาดทับอยู่ด้านหน้า — ตรงกับที่ผู้เล่นเห็นและตั้งใจคลิก
func _piece_cell_under(point: Vector2) -> Vector2i:
	var best := ChessRules.NO_CELL
	var best_y := -INF
	for row in range(ChessRules.ROWS):
		for col in range(ChessRules.COLS):
			var piece: ChessPiece = board.board_state[row][col]
			if piece == null or piece.texture == null:
				continue
			var half: Vector2 = piece.texture.get_size() * piece.scale * 0.5
			var rect := Rect2(piece.global_position - half, half * 2.0)
			if rect.has_point(point) and piece.global_position.y > best_y:
				best_y = piece.global_position.y
				best = Vector2i(col, row)
	return best

func _try_select(cell: Vector2i) -> void:
	var piece := ChessRules.at(board.board_state, cell)
	if piece == null or piece.side != board.side_to_move:
		return  # ช่องว่าง หรือหมากฝ่ายตรงข้าม (ยังไม่ถึงตาเขา)

	var moves: Array = board.legal_moves_for(cell)
	if moves.is_empty():
		return  # หมากตัวนี้ขยับไม่ได้เลย (เช่นถูกตรึงอยู่หน้าคิง) — ไม่ต้องเลือกให้เสียเวลา

	# 1) บันทึกสถานะเลือกก่อน (ให้ _draw() วาดกรอบไฮไลต์ได้ทันทีเฟรมถัดไป)
	selected_cell = cell
	legal_targets = moves
	# 2) แล้วค่อยสั่งเด้งขนาด — bounce=true ใช้ TRANS_ELASTIC ให้ดูมีชีวิตชีวา
	_animate_scale(piece, piece.resting_scale * SELECTED_SCALE_MULT, true)
	AudioManager.play_sfx(SFX_SELECT)
	_update_skill_button(piece)
	queue_redraw()

## ใช้ตอน "ยกเลิกการเลือกจริงๆ" เท่านั้น (คลิกช่องเดิมซ้ำ / คลิกช่องที่เดินไม่ได้ / เกมจบ)
## ต่างจาก _clear_selection_state() ตรงที่ตัวนี้ tween คืนขนาดปกติให้ด้วย
func _deselect() -> void:
	# 1) หาตัวหมากที่กำลังเลือกอยู่ (ต้องหาก่อนเคลียร์ selected_cell ไม่งั้นหาไม่เจอ)
	var piece := ChessRules.at(board.board_state, selected_cell)
	# 2) สั่ง tween คืนขนาดปกติแบบนุ่มนวล (bounce=false ใช้ TRANS_BACK ไม่เด้งเกิน)
	if piece != null:
		_animate_scale(piece, piece.resting_scale, false)
	# 3) ค่อยล้างสถานะเลือกทีหลัง
	_clear_selection_state()

## แค่ล้าง "สถานะเลือก" ในสคริปต์นี้ ไม่ยุ่งกับ scale ของหมากเลย
## ใช้ตอนกำลังจะสั่งเดินหมากจริง (ดู _handle_click) — ปล่อยให้ tween การเดินใน
## Board.try_move() รับช่วงขนาดปัจจุบัน (ที่ยังขยายค้างจากตอนเลือก) ต่อไปเอง
## ถ้าเผลอเรียก _deselect() ตรงนี้แทน จะมี 2 tween แย่งกันแก้ scale จนหมากกระตุก
func _clear_selection_state() -> void:
	selected_cell = ChessRules.NO_CELL
	legal_targets = []
	_clear_skill_button()
	queue_redraw()

## เด้งขนาดหมากด้วย tween ตัวเดียว (สร้างใหม่ทุกครั้งที่เรียก — ตัวเก่าถ้ายังไม่จบ
## จะถูกแทนที่ไปเอง ไม่ต้องกังวลเรื่อง tween ค้าง)
func _animate_scale(piece: ChessPiece, target_scale: Vector2, bounce: bool) -> void:
	var tween := create_tween()
	if bounce:
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	else:
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(piece, "scale", target_scale, SELECT_DURATION)

func _draw() -> void:
	if not _board_ready():
		return
	_draw_check_warning()
	if selected_cell == ChessRules.NO_CELL:
		return

	# กรอบเรืองแสงรอบช่องที่เลือกอยู่ (โทนทอง)
	_draw_glow_quad(selected_cell, Color(1.0, 0.85, 0.25))

	for target in legal_targets:
		# แดง = ช่องนี้กินได้ (รวมกินผ่านที่ช่องปลายทางดูเหมือนว่าง), เขียว = ช่องว่างที่เดินไปได้
		var color := Color(1.0, 0.3, 0.25) if _is_capture(target) else Color(0.3, 1.0, 0.45)
		_draw_glow_quad(target, color)

	if _skill_tooltip_visible and skill_button != null and is_instance_valid(skill_button):
		_draw_skill_tooltip()

## วาดกรอบสี่เหลี่ยมเรืองแสงรอบช่อง (col, row) — ใช้มุมจริงตามเปอร์สเปกทีฟของกระดาน
## ทำเอฟเฟกต์เรืองแสงโดยวาดเส้นซ้อนกันหลายชั้น ชั้นนอกหนา-จางลงเรื่อยๆ ไปจนถึงชั้นในสุดที่คมชัด
func _draw_glow_quad(cell: Vector2i, color: Color) -> void:
	var corners: PackedVector2Array = board.cell_corners(cell.x, cell.y)
	var local_corners := PackedVector2Array()
	for point in corners:
		local_corners.append(to_local(point))
	local_corners.append(local_corners[0])  # ปิดกรอบให้ครบวง

	var pulse: float = PULSE_MIN + (PULSE_MAX - PULSE_MIN) * (sin(_pulse_time * PULSE_SPEED) * 0.5 + 0.5)
	var glow_layers := [
		{"width": 16.0, "alpha": 0.12},
		{"width": 10.0, "alpha": 0.22},
		{"width": 5.0, "alpha": 0.45},
		{"width": 2.5, "alpha": 0.95},
	]
	for layer in glow_layers:
		draw_polyline(local_corners, Color(color.r, color.g, color.b, layer.alpha * pulse), layer.width, true)

func _is_capture(target: Vector2i) -> bool:
	if ChessRules.at(board.board_state, target) != null:
		return true
	# กินผ่าน (en passant): ช่องปลายทางว่าง แต่ยังนับเป็นการกิน
	var piece := ChessRules.at(board.board_state, selected_cell)
	return piece != null and piece.piece_kind == ChessPiece.Kind.PAWN and target == board.en_passant_target

func _draw_check_warning() -> void:
	if board.game_over:
		return
	if not ChessRules.is_in_check(board.board_state, board.side_to_move):
		return
	var king_cell: Vector2i = ChessRules.find_king(board.board_state, board.side_to_move)
	if king_cell == ChessRules.NO_CELL:
		return
	var point := to_local(board.cell_to_world(king_cell.x, king_cell.y))
	draw_arc(point, 40.0, 0.0, TAU, 40, Color(1.0, 0.15, 0.15, 0.9), 6.0, true)

## โผล่/อัปเดตปุ่มสกิลลอยเหนือหัวหมากที่เพิ่งเลือก — โผล่เฉพาะตอนหมากตัวนั้นมีสกิลให้ใช้จริง
func _update_skill_button(piece: ChessPiece) -> void:
	_clear_skill_button()
	if not piece.can_use_skill():
		return
	skill_button = SkillButton.new()
	var scaled_height: float = piece.texture.get_height() * piece.scale.y
	skill_button.global_position = piece.global_position + Vector2(0, -scaled_height * 0.5 - 46.0)
	skill_button.setup(piece.piece_kind)
	add_child(skill_button)

func _clear_skill_button() -> void:
	if skill_button != null and is_instance_valid(skill_button):
		skill_button.queue_free()
	skill_button = null

## โผล่ป๊อปอัพเลือกโปรโมทเหนือช่องปลายทาง — ค้างรอผู้เล่นคลิกเลือกก่อนค่อยสั่ง try_move() จริง
func _show_promotion_picker(from: Vector2i, to: Vector2i) -> void:
	_pending_promotion = {"from": from, "to": to}
	promotion_picker = PromotionPicker.new()
	promotion_picker.global_position = board.cell_to_world(to.x, to.y) + Vector2(0, -70.0)
	add_child(promotion_picker)

## เช็คว่าคลิกโดนตัวเลือกไหนของป๊อปอัพโปรโมท — โดนแล้วค่อยสั่งเดินจริงพร้อมชนิดที่เลือก
func _handle_promotion_click() -> void:
	var mouse := get_global_mouse_position()
	for i in range(PromotionPicker.OPTIONS.size()):
		if mouse.distance_to(promotion_picker.option_global_position(i)) <= PromotionPicker.HIT_RADIUS:
			var chosen_kind: int = PromotionPicker.OPTIONS[i]
			var from: Vector2i = _pending_promotion["from"]
			var to: Vector2i = _pending_promotion["to"]
			_clear_promotion_picker()
			board.try_move(from, to, chosen_kind)
			return
	# คลิกไม่โดนตัวเลือกไหนเลย — บังคับให้เลือกก่อน ไม่ทำอะไร ไม่มีทางยกเลิกได้

func _clear_promotion_picker() -> void:
	if promotion_picker != null and is_instance_valid(promotion_picker):
		promotion_picker.queue_free()
	promotion_picker = null
	_pending_promotion = {}

## เช็คทุกเฟรมว่าเมาส์ชี้ค้างที่ปุ่มสกิลอยู่ไหม — เปลี่ยนสถานะแล้วค่อย queue_redraw() (ไม่ redraw
## รัวทุกเฟรมโดยไม่จำเป็น) เพราะปุ่มสกิลไม่ใช่ Control node จริง จะใช้ mouse_entered/exited ไม่ได้
func _process(delta: float) -> void:
	if selected_cell != ChessRules.NO_CELL:
		_pulse_time += delta
		queue_redraw()
	if skill_button == null or not is_instance_valid(skill_button):
		if _skill_tooltip_visible:
			_skill_tooltip_visible = false
			queue_redraw()
		return
	var mouse := get_global_mouse_position()
	var hovering: bool = mouse.distance_to(skill_button.global_position) <= SkillButton.HIT_RADIUS
	if hovering != _skill_tooltip_visible:
		_skill_tooltip_visible = hovering
		queue_redraw()

## กล่องข้อความบอกว่าสกิลของหมากที่เลือกอยู่ทำอะไร — โผล่ตอนเมาส์ชี้ค้างที่ปุ่มสกิล
func _draw_skill_tooltip() -> void:
	var piece := ChessRules.at(board.board_state, selected_cell)
	if piece == null:
		return
	var text: String = ChessPiece.skill_label(piece.piece_kind)
	if text == "":
		return
	var font := ThemeDB.fallback_font
	var font_size := 20
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var local_pos: Vector2 = to_local(skill_button.global_position) + Vector2(0, -50.0)
	var padding := Vector2(14, 8)
	var box_pos: Vector2 = local_pos - Vector2(text_size.x * 0.5, text_size.y) - padding
	var box_size: Vector2 = text_size + padding * 2
	draw_rect(Rect2(box_pos, box_size), Color(0.05, 0.05, 0.08, 0.9))
	draw_rect(Rect2(box_pos, box_size), Color(1.0, 0.85, 0.3, 0.9), false, 1.5)
	draw_string(font, local_pos - Vector2(text_size.x * 0.5, 4), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
