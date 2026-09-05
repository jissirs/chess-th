extends Node2D

## สร้างและจัดวางตัวหมากบนกระดาน โดยดึงตำแหน่งจาก board.cell_to_world(col, row)
## ของ node แม่ (Board) — ผูกสคริปต์นี้กับ node ลูกชื่อ "Pieces" ที่อยู่ใต้ Board
##
## ไฟล์นี้รับผิดชอบเฉพาะ "การแสดงผล" (โหลดรูป / คำนวณขนาดตามเปอร์สเปกทีฟ / วางตำแหน่ง)
## ส่วนกติกาการเดินอยู่ใน chess_rules.gd และสถานะเกมอยู่ใน Board.gd

const PIECE_DIR := "res://asset/pieces/"

const FEET_OFFSET_RATIO := 0.35  # เลื่อนขึ้นเท่าไหร่ให้ "เท้า" หมากอยู่กึ่งกลางช่อง
const MOVE_DURATION := 0.28  # ระยะเวลาที่หมากใช้เลื่อนจากช่องหนึ่งไปอีกช่อง

const LUNGE_RATIO := 0.6      # ระยะที่ผู้โจมตีพุ่งเข้าหาเหยื่อก่อนหยุดชั่วครู่ (0-1 ของระยะทางถึงตัวเหยื่อ)
const LUNGE_DURATION := 0.12  # เวลาพุ่งเข้าใส่ — ต้องไวกว่า MOVE_DURATION ปกติ ให้รู้สึก "ปะทะ" ไม่ใช่ "เดิน"
const IMPACT_HOLD := 0.06     # หยุดนิ่งชั่วครู่ตอนปะทะ ก่อนเดินต่อ ให้เห็นจังหวะกระแทกชัดขึ้น
const VICTIM_FALL_DURATION := 0.3  # เวลาที่หมากซึ่งโดนกินสะบัด/ล้ม/จางหายก่อนถูกลบทิ้งจริง
const IDLE_SWAY_ANGLE_DEG := 1.5   # องศา มุมเอียงสูงสุดตอนแกว่ง (เบามาก ไม่ให้ดูรก)
const IDLE_SWAY_MIN_DURATION := 1.6
const IDLE_SWAY_MAX_DURATION := 2.4
const SHATTER_GRID := 3            # ตัดภาพตัวหมากเป็นตาราง 3x3 = 9 ชิ้นตอนแตก
const SHATTER_FLY_DURATION := 0.5  # เวลาที่เศษชิ้นบินกระเด็นก่อนจางหาย

const SFX_KILL := preload("res://asset/audio/Film Punch.mp3")  # ตีตายจริง (play_capture) — fallback
const SFX_HIT := preload("res://asset/audio/punchsound.mp3")   # ตีไม่ตาย (play_attack_bounce) — fallback

const SFX_PAWN_HIT := preload("res://asset/audio/pawn_hit.mp3")
const SFX_KNIGHT_HIT := preload("res://asset/audio/knight_hit.mp3")
const SFX_BISHOP_HIT := preload("res://asset/audio/bishop_hit.mp3")
const SFX_ROOK_HIT := preload("res://asset/audio/rook_hit.mp3")
const SFX_QUEEN_HIT := preload("res://asset/audio/queen_hit.mp3")
const SFX_KING_HIT := preload("res://asset/audio/king_hit.mp3")
# ลำดับหมากแถวหลัง เรียงจากซ้ายไปขวา (คิงอยู่ col 4 ควีนอยู่ col 3 ตามกติกาสากล)
var back_rank_kinds: Array = [
	ChessPiece.Kind.ROOK, ChessPiece.Kind.KNIGHT, ChessPiece.Kind.BISHOP, ChessPiece.Kind.QUEEN,
	ChessPiece.Kind.KING, ChessPiece.Kind.BISHOP, ChessPiece.Kind.KNIGHT, ChessPiece.Kind.ROOK,
]

# เบี้ยมีหลายสีให้เลือกใช้สลับกันไป (คนละชุดระหว่างฝั่งหน้ากับฝั่งหลัง)
const BLACK_SOLDIER_COLORS := ["crimson", "purple", "goldfire", "sapphie"]
const WHITE_SOLDIER_COLORS := ["crimson", "purple", "runic1", "runic2"]

## อัตราส่วนความสูงของหมากเทียบกับขนาดช่องจริงของแถวนั้นๆ
## (แทนที่จะ fix เป็นพิกเซลตายตัว — ตอนนี้คำนวณตามเปอร์สเปกทีฟ
## แถวไกลกล้อง (บนกระดาน) ช่องเล็ก หมากก็เล็กลงตาม, แถวใกล้กล้อง (ล่าง) ช่องใหญ่ หมากก็ใหญ่ขึ้นตาม)
@export var height_to_cell_ratio: float = 1.5

## ตัวหน่วงความต่างระหว่างแถว: 0 = ทุกตัวขนาดเท่ากันหมด (ใช้ค่าเฉลี่ยกลางกระดาน),
## 1 = ตามเปอร์สเปกทีฟจริงเป๊ะๆ (แถวบนเล็กมาก แถวล่างใหญ่มาก ต่างกันสุดโต่ง)
## ค่ากลางๆ เช่น 0.5-0.6 จะให้ความรู้สึกเปอร์สเปกทีฟแต่ยังดูสมดุล อ่านง่าย
@export_range(0.0, 1.0) var perspective_strength: float = 0.55

func _ready() -> void:
	# เรียงลำดับการวาดตามตำแหน่ง Y อัตโนมัติ (ใกล้กล้อง/แถวล่าง = วาดทับแถวไกลกล้อง/แถวบน)
	# ไม่งั้นหมากแถวใกล้เคียงกันที่ตัวสูงๆ จะซ้อนทับกันผิดลำดับ (ตัวที่ควรอยู่หน้ากลับโดนบัง)
	y_sort_enabled = true

	# ยกให้อยู่เหนือกรอบไฮไลต์ของ ClickToMove (z_index 0) เสมอ กันไม่ให้กรอบไปทับตัวหมาก
	z_index = 1

	await get_tree().process_frame   # รอให้ Board ตั้ง board_state เสร็จก่อน
	var board := get_parent()
	_spawn_team(board, 0, ChessPiece.Team.BLACK, BLACK_SOLDIER_COLORS)  # ศัตรู: แถวหลัง row 0, เบี้ย row 1
	_spawn_team(board, 7, ChessPiece.Team.WHITE, WHITE_SOLDIER_COLORS)  # ผู้เล่น: แถวหลัง row 7, เบี้ย row 6
	board.piece_attacked.connect(_on_piece_attacked)
	board.skill_used.connect(_on_skill_used)
	board.move_made.connect(_on_move_made_update_passives)
	board.skill_used.connect(_on_skill_used_update_passives)
	_update_passive_indicators()

func _spawn_team(_board: Node, back_row: int, side: int, soldier_colors: Array) -> void:
	# แถวเบี้ยอยู่ติดกับแถวหลัง เยื้องเข้ามาตรงกลางกระดาน
	var pawn_row := back_row + 1 if back_row == 0 else back_row - 1

	for col in range(8):
		var kind: int = back_rank_kinds[col]
		spawn_piece(ChessPiece.art_name(kind), side, Vector2i(col, back_row), kind)

	for col in range(8):
		var color: String = soldier_colors[col % soldier_colors.size()]
		spawn_piece("soldier_%s" % color, side, Vector2i(col, pawn_row), ChessPiece.Kind.PAWN)

## สร้างหมากตัวใหม่วางลงช่อง cell แล้วบันทึกลง board_state ให้เรียบร้อย
## ใช้ทั้งตอนตั้งกระดานเริ่มเกม และตอนเบี้ย promote
func spawn_piece(art_name: String, side: int, cell: Vector2i, kind: int) -> ChessPiece:
	var path := "%s%s_%s.png" % [PIECE_DIR, art_name, ChessPiece.suffix_for(side)]
	var tex: Texture2D = load(path)
	if tex == null:
		push_warning("หารูปหมากไม่เจอ: %s" % path)  # ชื่อไฟล์อาจพิมพ์ผิด
		return null

	#var piece := ChessPiece.new()
	#piece.name = "%s_%d_%d" % [art_name, cell.x, cell.y]
	#piece.texture = tex
	#piece.piece_kind = kind
	#piece.side = side

	#add_child(piece)
	#place_piece(piece, cell)
	#get_parent().board_state[cell.y][cell.x] = piece
	#return piece
	var piece := ChessPiece.new()
	piece.name = "%s_%d_%d" % [art_name, cell.x, cell.y]
	piece.texture = tex
	piece.piece_kind = kind
	piece.side = side
	piece.max_hp = ChessPiece.BASE_HP
	piece.hp = ChessPiece.BASE_HP
	piece.attack_power = ChessPiece.base_attack(kind)

	add_child(piece)
	_spawn_power_aura(piece)
	_start_idle_sway(piece)
	place_piece(piece, cell)
	get_parent().board_state[cell.y][cell.x] = piece
	return piece
## จัดขนาดและตำแหน่ง sprite ให้ตรงกับช่อง cell
## เรียกทั้งตอน spawn และทุกครั้งที่หมากเดิน — ขนาดต้องคำนวณใหม่ทุกครั้ง
## เพราะกระดานเป็นเปอร์สเปกทีฟ ช่องแถวบนเล็กกว่าช่องแถวล่างอย่างชัดเจน
##
## animate = true จะเลื่อน/ย่อขยายไปหาตำแหน่งใหม่แบบนุ่มนวลแทนการเซ็ตทันที
## คืนค่า Tween ที่สร้างไว้ (null ถ้าไม่ animate) ให้ผู้เรียก await ต่อได้ว่าเลื่อนเสร็จเมื่อไหร่
func place_piece(piece: ChessPiece, cell: Vector2i, animate: bool = false) -> Tween:
	var board := get_parent()
	var scale_factor := _scale_for(board, cell, piece.texture)
	var new_resting_scale := Vector2(scale_factor, scale_factor)

	# วางโดยให้ "เท้า" ของหมาก (ไม่ใช่กึ่งกลางรูป) อยู่ตรงกึ่งกลางช่อง
	# ไม่งั้นครึ่งบนของตัวหมาก (หัว/ไหล่) จะยื่นล้ำขึ้นไปทับแถวข้างบน
	var scaled_height: float = piece.texture.get_height() * scale_factor
	var target_pos: Vector2 = board.cell_to_world(cell.x, cell.y) + Vector2(0, -scaled_height * FEET_OFFSET_RATIO)

	# resting_scale ต้องอัปเดตทันทีเสมอ (ใช้เป็นค่าอ้างอิง "ขนาดปกติ" ของช่องใหม่
	# เวลา click_to_move.gd จะขยาย/หดตอนเลือก-ยกเลิกเลือก) ไม่ว่าจะ animate หรือไม่
	piece.resting_scale = new_resting_scale

	if not animate:
		piece.position = target_pos
		piece.scale = new_resting_scale
		return null

	# เลื่อนตำแหน่งพร้อมปรับขนาดไปพร้อมกัน (ตำแหน่งกับขนาดผูกกับเปอร์สเปกทีฟของแถว
	# ปลายทาง จึงต้อง tween คู่กันไม่งั้นหมากจะเปลี่ยนขนาดวูบเดียวหลังเลื่อนเสร็จ)
	var tween := create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(piece, "position", target_pos, MOVE_DURATION)
	tween.tween_property(piece, "scale", new_resting_scale, MOVE_DURATION)
	return tween

## เล่น animation การกิน: ผู้โจมตี "พุ่ง" เข้าใส่ตำแหน่งปัจจุบันของเหยื่อก่อน (lunge) แทนที่จะ
## เดินตรงไปช่องปลายทางเฉยๆ — ให้ความรู้สึกปะทะกันก่อนกินจริง แล้วเหยื่อสะบัด/ล้ม/จางหายไป
## จากนั้นผู้โจมตีค่อยเดินต่อจนถึงช่องปลายทางตามปกติ
##
## ใช้ตำแหน่งจริงของเหยื่อ (ไม่ใช่ตำแหน่งช่องปลายทาง) เป็นเป้าพุ่งเข้าใส่ เพราะ en passant
## เหยื่ออยู่คนละช่องกับที่ผู้โจมตีจะไปจอดจริง (กินทแยงแต่ไปจอดช่องข้างๆ) พุ่งเข้าหาตัวเหยื่อ
## ตรงๆ จึงดูสมเหตุสมผลกว่าพุ่งไปช่องปลายทางเฉยๆ ในทุกกรณี
##
## คืน Tween ตัวเดียวที่ครอบคลุมทั้งการพุ่ง+เดินต่อของผู้โจมตี ให้ Board.try_move() await ต่อได้
## (การสะบัด/ล้มของเหยื่อรันเป็น tween แยกต่างหาก ไม่บล็อกผู้โจมตีให้รอ)
func play_capture(attacker: ChessPiece, victim: ChessPiece, dest_cell: Vector2i) -> Tween:
	var board := get_parent()
	var start_pos: Vector2 = attacker.position
	var start_scale: Vector2 = attacker.scale

	# คำนวณตำแหน่ง/ขนาดสุดท้ายของผู้โจมตีล่วงหน้า เหมือนที่ place_piece() ทำปกติ
	var scale_factor := _scale_for(board, dest_cell, attacker.texture)
	var final_scale := Vector2(scale_factor, scale_factor)
	var scaled_height: float = attacker.texture.get_height() * scale_factor
	var final_pos: Vector2 = board.cell_to_world(dest_cell.x, dest_cell.y) + Vector2(0, -scaled_height * FEET_OFFSET_RATIO)
	attacker.resting_scale = final_scale

	var lunge_pos: Vector2 = start_pos.lerp(victim.position, LUNGE_RATIO)
	var lunge_scale: Vector2 = start_scale.lerp(final_scale, LUNGE_RATIO)

	var tween := create_tween()

	# 1) พุ่งเข้าใส่เหยื่อ — ease-in เพราะการพุ่งจริงๆ เร่งความเร็วขึ้นตอนใกล้ปะทะ ไม่ใช่ชะลอ
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(attacker, "position", lunge_pos, LUNGE_DURATION)
	tween.parallel().tween_property(attacker, "scale", lunge_scale, LUNGE_DURATION)

	# 2) จังหวะปะทะ: สั่งเหยื่อเริ่มสะบัด/ล้ม + โชว์รอยฟัน + เสียงตีตาย (รันแยก ไม่บล็อกคิวหลัก) แล้วหยุดนิ่งสั้นๆ
	tween.tween_callback(_play_victim_death.bind(victim))
	tween.tween_callback(_spawn_slash_effect.bind(victim.position))
	tween.tween_callback(AudioManager.play_sfx.bind(_attack_sfx_for(attacker.piece_kind)))
	tween.tween_interval(IMPACT_HOLD)

	# 3) ผู้โจมตีเดินต่อไปช่องปลายทางตามปกติ (ease-out เหมือน place_piece ทั่วไป)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(attacker, "position", final_pos, MOVE_DURATION)
	tween.parallel().tween_property(attacker, "scale", final_scale, MOVE_DURATION)

	return tween

## สร้างเอฟเฟกต์รอยฟัน (SlashEffect) ที่ตำแหน่งปะทะ — วาดด้วยโค้ดล้วนๆ ไม่ต้องมี asset รูป
## เป็น node ชั่วคราวที่ลบตัวเองทิ้งอัตโนมัติหลังเล่นจบ (ดู slash_effect.gd)
func _spawn_slash_effect(at_position: Vector2) -> void:
	var slash := SlashEffect.new()
	slash.position = at_position
	add_child(slash)

## เหยื่อสะบัดหมุนไปทางสุ่ม (ซ้าย/ขวา) พร้อมเลื่อนลงเหมือนล้ม แล้วจางหายไป ก่อนถูกลบทิ้งจริง
## เป็น tween แยกจาก play_capture() โดยตั้งใจ — จะได้ไม่ต้องรอเหยื่อล้มเสร็จก่อนผู้โจมตีเดินต่อ
#func _play_victim_death(victim: ChessPiece) -> void:
#	if victim == null or not is_instance_valid(victim):
#		return
#	var death_tween := create_tween().set_parallel(true)
#	death_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
#	var spin_dir := 1.0 if randf() < 0.5 else -1.0  # สุ่มทิศทางสะบัด กันดูซ้ำจำเจทุกครั้งที่กิน
#	death_tween.tween_property(victim, "rotation", spin_dir * deg_to_rad(100), VICTIM_FALL_DURATION)
#	death_tween.tween_property(victim, "position:y", victim.position.y + 40.0, VICTIM_FALL_DURATION)
#	death_tween.tween_property(victim, "modulate:a", 0.0, VICTIM_FALL_DURATION)
#	death_tween.chain().tween_callback(victim.queue_free)
## เหยื่อตายจริง — แทนที่จะจางหายเฉยๆ จะ "แตกกระจายเป็นเศษชิ้น" เหมือนหินแตก พร้อมฝุ่นกระจาย
## และวงแหวนกระแทกพื้น เป็น effect แยกจาก play_capture() โดยตั้งใจ จะได้ไม่ต้องรอเล่นจบก่อน
## ผู้โจมตีเดินต่อ
func _play_victim_death(victim: ChessPiece) -> void:
	if victim == null or not is_instance_valid(victim):
		return
	var tex := victim.texture
	var pos := victim.global_position
	var piece_scale := victim.scale
	var piece_rotation := victim.rotation

	victim.visible = false  # ซ่อนตัวเต็มทันที ให้เห็นแต่เศษชิ้นที่แตกออกแทน
	_spawn_dust_burst(pos)
	_spawn_impact_ring(pos)
	if tex != null:
		_spawn_shatter_pieces(tex, pos, piece_scale, piece_rotation)

	# รอให้เศษชิ้นบินไปสักพักก่อนค่อยลบตัวเดิมทิ้งจริง
	await get_tree().create_timer(SHATTER_FLY_DURATION).timeout
	if is_instance_valid(victim):
		victim.queue_free()
## หาสเกลที่เหมาะกับช่องนี้: ผสมขนาดช่องจริงของแถวนั้นกับขนาดเฉลี่ยกลางกระดาน
## ตาม perspective_strength กันไม่ให้แถวบน-ล่างต่างกันสุดโต่งจนอ่านยาก
func _scale_for(board: Node, cell: Vector2i, tex: Texture2D) -> float:
	var cell_size: float = _local_cell_size(board, cell.x, cell.y)
	var avg_cell_size: float = _local_cell_size(board, cell.x, 3)  # แถวกลางกระดานเป็นค่าอ้างอิงเฉลี่ย
	var effective_size: float = lerp(avg_cell_size, cell_size, perspective_strength)
	return (effective_size * height_to_cell_ratio) / tex.get_height()

## วัดขนาด (ความสูง) โดยประมาณของช่อง (col, row) จริงบนภาพ โดยดูระยะห่าง
## ระหว่างช่องแถวข้างบนกับข้างล่างของมัน (หารด้วยจำนวนแถวที่วัด)
func _local_cell_size(board: Node, col: int, row: int) -> float:
	var row_a: int = max(row - 1, 0)
	var row_b: int = min(row + 1, 7)
	var a: Vector2 = board.cell_to_world(col, row_a)
	var b: Vector2 = board.cell_to_world(col, row_b)
	return a.distance_to(b) / float(row_b - row_a)
#---------------------------------------------------------------------------------

## ออร่าพลังลอยรอบตัวหมาก — ประกายฟุ้งขึ้นเบาๆ ตลอดเวลา สีต่างกันตามฝ่าย
## (เหลืองทอง = ผู้เล่น, ม่วงเข้ม = ศัตรู) เป็นลูกของตัวหมากเอง เลยลอยตามหมากไปทุกที่
## และถูกลบทิ้งอัตโนมัติพร้อมตัวหมากตอน queue_free() โดยไม่ต้องจัดการเอง
func _spawn_power_aura(piece: ChessPiece) -> void:
	var aura := CPUParticles2D.new()
	aura.amount = 10
	aura.lifetime = 1.6
	aura.local_coords = true
	aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	aura.emission_sphere_radius = 26.0
	aura.direction = Vector2(0, -1)
	aura.spread = 20.0
	aura.gravity = Vector2(0, -18)
	aura.initial_velocity_min = 6.0
	aura.initial_velocity_max = 16.0
	aura.scale_amount_min = 2.0
	aura.scale_amount_max = 4.0
	aura.color = Color(1.0, 0.85, 0.35, 0.85) if piece.side == ChessPiece.Team.WHITE else Color(0.55, 0.25, 0.9, 0.85)
	aura.position = Vector2(0, -piece.texture.get_height() * 0.3)
	piece.add_child(aura)
	aura.emitting = true
	
	## เล่น animation ตอนโจมตีสำเร็จแต่เหยื่อไม่ตาย (เลือดยังเหลือ) — พุ่งเข้าปะทะเหมือน play_capture()
## แต่ผู้โจมตี "ถอยกลับ" มาที่เดิมแทนที่จะเดินเข้าไปแทนที่ (เพราะเหยื่อยังไม่ตาย ยังยืนอยู่ที่เดิม)
## เหยื่อสั่น+กะพริบขาวแสดงว่าโดนตี (คนละแบบกับตอนตายที่จะสะบัด/ล้ม/จางหายไปเลย)
func play_attack_bounce(attacker: ChessPiece, victim: ChessPiece) -> Tween:
	var start_pos: Vector2 = attacker.position
	var start_scale: Vector2 = attacker.scale
	var lunge_pos: Vector2 = start_pos.lerp(victim.position, LUNGE_RATIO)
	var lunge_scale: Vector2 = start_scale.lerp(start_scale * 1.05, LUNGE_RATIO)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(attacker, "position", lunge_pos, LUNGE_DURATION)
	tween.parallel().tween_property(attacker, "scale", lunge_scale, LUNGE_DURATION)

	tween.tween_callback(_play_victim_hit.bind(victim))
	tween.tween_callback(_spawn_slash_effect.bind(victim.position))
	tween.tween_callback(AudioManager.play_sfx.bind(_attack_sfx_for(attacker.piece_kind)))
	tween.tween_interval(IMPACT_HOLD)

	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(attacker, "position", start_pos, MOVE_DURATION)
	tween.parallel().tween_property(attacker, "scale", start_scale, MOVE_DURATION)

	return tween

## เหยื่อสั่นตัวเบาๆ + กะพริบขาว แสดงว่าโดนตีแต่ยังไม่ตาย (ต่างจาก _play_victim_death ที่ล้มจริง)
func _play_victim_hit(victim: ChessPiece) -> void:
	if victim == null or not is_instance_valid(victim):
		return
	var original_pos: Vector2 = victim.position
	var hit_tween := create_tween()
	hit_tween.tween_property(victim, "modulate", Color(3.0, 3.0, 3.0), 0.05)
	hit_tween.parallel().tween_property(victim, "position:x", original_pos.x + 6.0, 0.05)
	hit_tween.tween_property(victim, "modulate", Color.WHITE, 0.15)
	hit_tween.parallel().tween_property(victim, "position:x", original_pos.x, 0.15)

## ตัดภาพตัวหมากเป็นตาราง SHATTER_GRID x SHATTER_GRID ชิ้น แล้วให้แต่ละชิ้นกระเด็นออกจากศูนย์กลาง
## คนละทิศทาง พร้อมหมุนและจางหาย — ใช้ AtlasTexture ตัด region ของภาพเดิม ไม่ต้องมี asset เพิ่ม
func _spawn_shatter_pieces(tex: Texture2D, global_pos: Vector2, piece_scale: Vector2, piece_rotation: float) -> void:
	var grid := SHATTER_GRID
	var tw := tex.get_width()
	var th := tex.get_height()
	var frag_w := tw / float(grid)
	var frag_h := th / float(grid)
	# มุมบนซ้ายของภาพเต็มในพิกัดโลก (ตัวหมากเดิม centered = true เหมือน Sprite2D ปกติทุกตัว)
	var top_left: Vector2 = global_pos - Vector2(tw, th) * 0.5 * piece_scale

	for gy in range(grid):
		for gx in range(grid):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(gx * frag_w, gy * frag_h, frag_w, frag_h)

			var frag := Sprite2D.new()
			frag.texture = atlas
			frag.centered = false
			frag.scale = piece_scale
			frag.rotation = piece_rotation
			frag.z_index = 6  # เหนือทุกอย่าง รวมถึงรอยฟัน (SlashEffect z_index = 5)
			frag.global_position = top_left + Vector2(gx * frag_w, gy * frag_h) * piece_scale
			add_child(frag)

			# ทิศทางกระเด็น: ออกจากจุดศูนย์กลางของภาพ ตามตำแหน่งของชิ้นนั้นในตาราง
			var center_offset := Vector2((gx + 0.5) / grid - 0.5, (gy + 0.5) / grid - 0.5)
			var outward := center_offset.normalized() if center_offset.length() > 0.01 \
				else Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			var fly_target: Vector2 = frag.global_position + outward * randf_range(45.0, 100.0) + Vector2(0, 30.0)

			var frag_tween := create_tween().set_parallel(true)
			frag_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			frag_tween.tween_property(frag, "global_position", fly_target, SHATTER_FLY_DURATION)
			frag_tween.tween_property(frag, "rotation", piece_rotation + randf_range(-3.0, 3.0), SHATTER_FLY_DURATION)
			frag_tween.tween_property(frag, "modulate:a", 0.0, SHATTER_FLY_DURATION * 0.6).set_delay(SHATTER_FLY_DURATION * 0.4)
			frag_tween.chain().tween_callback(frag.queue_free)

## ฝุ่น/เศษหินกระจายออกจากจุดตาย 1 ครั้ง (one-shot) แล้วร่วงลงตามแรงโน้มถ่วง
func _spawn_dust_burst(at_position: Vector2) -> void:
	var dust := CPUParticles2D.new()
	dust.position = at_position
	dust.z_index = 3
	dust.one_shot = true
	dust.explosiveness = 1.0
	dust.amount = 18
	dust.lifetime = 0.5
	dust.direction = Vector2(0, -1)
	dust.spread = 180.0
	dust.gravity = Vector2(0, 260)
	dust.initial_velocity_min = 40.0
	dust.initial_velocity_max = 120.0
	dust.scale_amount_min = 2.5
	dust.scale_amount_max = 5.0
	dust.color = Color(0.55, 0.5, 0.45, 0.9)
	add_child(dust)
	dust.emitting = true
	dust.finished.connect(dust.queue_free)

## วงแหวนแสงกระแทกพื้นที่จุดตาย (ดู impact_ring.gd) ลบตัวเองทิ้งอัตโนมัติหลังเล่นจบ
func _spawn_impact_ring(at_position: Vector2) -> void:
	var ring := ImpactRing.new()
	ring.position = at_position
	add_child(ring)

## โผล่ตัวเลขดาเมจลอยขึ้นเหนือหัวเหยื่อทุกครั้งที่โจมตีสำเร็จ (ฟังจาก signal Board.piece_attacked
## ที่มีอยู่แล้วจากระบบเลือด — ไม่ต้องแก้ Board.gd เลย)
func _on_piece_attacked(_attacker: ChessPiece, victim: ChessPiece, damage: float, killed: bool) -> void:
	if victim == null or not is_instance_valid(victim) or victim.texture == null:
		return
	var popup := DamagePopup.new()
	popup.global_position = victim.global_position + Vector2(0, -victim.texture.get_height() * victim.scale.y * 0.55)
	popup.setup(damage, killed)
	add_child(popup)

## เล่นเอฟเฟกต์ตอนใช้สกิลสำเร็จ (ฟังจาก signal Board.skill_used) — เลือกภาพตาม effect_kind
## ที่ Board._apply_skill() ส่งมา: "heal" (ฮีลตัวเอง/เสริมเกราะ), "buff" (บัฟโจมตี), "rally" (ฮีลทีม)
func _on_skill_used(piece: ChessPiece, effect_kind: String) -> void:
	if piece == null or not is_instance_valid(piece):
		return
	match effect_kind:
		"heal":
			_spawn_skill_sparkle(piece.global_position, Color(0.3, 1.0, 0.4, 0.9))
		"buff":
			_spawn_skill_sparkle(piece.global_position, Color(1.0, 0.6, 0.1, 0.9))
		"rally":
			# ฮีลทั้งทีม — ยิงประกายที่หมากฝ่ายเดียวกันทุกตัว ไม่ใช่แค่คิงตัวเดียว
			var board := get_parent()
			for row in board.board_state:
				for p in row:
					if p != null and p.side == piece.side:
						_spawn_skill_sparkle(p.global_position, Color(0.3, 1.0, 0.4, 0.9))

## ประกายฟุ้งลอยขึ้นครั้งเดียว (one-shot) ใช้กับทุกเอฟเฟกต์สกิล ต่างกันแค่สี
func _spawn_skill_sparkle(at_position: Vector2, color: Color) -> void:
	var fx := CPUParticles2D.new()
	fx.position = at_position
	fx.one_shot = true
	fx.explosiveness = 0.8
	fx.amount = 20
	fx.lifetime = 0.6
	fx.direction = Vector2(0, -1)
	fx.spread = 25.0
	fx.gravity = Vector2(0, -80)
	fx.initial_velocity_min = 30.0
	fx.initial_velocity_max = 70.0
	fx.scale_amount_min = 3.0
	fx.scale_amount_max = 5.0
	fx.color = color
	add_child(fx)
	fx.emitting = true
	fx.finished.connect(fx.queue_free)

## เสียงโจมตีของหมากแต่ละชนิด — ใช้แทน SFX_KILL/SFX_HIT เดี่ยวๆ ให้แต่ละตัวรู้สึกต่างกัน
func _attack_sfx_for(kind: int) -> AudioStream:
	match kind:
		ChessPiece.Kind.PAWN: return SFX_PAWN_HIT
		ChessPiece.Kind.KNIGHT: return SFX_KNIGHT_HIT
		ChessPiece.Kind.BISHOP: return SFX_BISHOP_HIT
		ChessPiece.Kind.ROOK: return SFX_ROOK_HIT
		ChessPiece.Kind.QUEEN: return SFX_QUEEN_HIT
		ChessPiece.Kind.KING: return SFX_KING_HIT
		_: return SFX_KILL

## อัปเดตไอคอนบอกว่าหมากตัวไหนกำลังได้ประโยชน์จาก passive skill อยู่ตอนนี้ — เรียกทุกครั้งที่บอร์ด
## เปลี่ยน (เดินหรือใช้สกิล) เพราะ passive อย่าง "ราชันคุ้มกัน"/"แนวรบเหล็ก" ขึ้นกับตำแหน่งบนกระดาน
## ที่เปลี่ยนได้ทุกตา
func _update_passive_indicators() -> void:
	var board := get_parent()
	for row in range(board.board_state.size()):
		for col in range(board.board_state[row].size()):
			var p: ChessPiece = board.board_state[row][col]
			if p != null:
				p.passive_indicator = PassiveSkills.is_passive_active(p, board.board_state, Vector2i(col, row))

func _on_move_made_update_passives(_from_cell: Vector2i, _to_cell: Vector2i, _piece: ChessPiece) -> void:
	_update_passive_indicators()

func _on_skill_used_update_passives(_piece: ChessPiece, _effect_kind: String) -> void:
	_update_passive_indicators()

## เล่นเอฟเฟกต์แสงพวยพุ่งตอนเบี้ย promote สำเร็จ — เรียกจาก Board._promote() หลังสร้างหมากตัวใหม่แล้ว
func play_promote_effect(piece: ChessPiece, cell: Vector2i) -> void:
	if piece == null or not is_instance_valid(piece):
		return
	var pos: Vector2 = piece.global_position
	var glow := PromoteGlow.new()
	glow.global_position = pos
	add_child(glow)
	_spawn_impact_ring(pos)  # วงแหวนแสงกระแทกพื้น ใช้ตัวเดียวกับตอนหมากตาย (ดูตอนที่ 11.4)
	_spawn_promote_sparkle(pos)

## ประกายทองฟุ้งขึ้นรอบตัวหมากที่เพิ่ง promote (one-shot) ต่างจาก skill sparkle ตรงสีทองอร่ามและแรงกว่า
func _spawn_promote_sparkle(at_position: Vector2) -> void:
	var fx := CPUParticles2D.new()
	fx.position = at_position
	fx.one_shot = true
	fx.explosiveness = 0.9
	fx.amount = 30
	fx.lifetime = 0.8
	fx.direction = Vector2(0, -1)
	fx.spread = 30.0
	fx.gravity = Vector2(0, -60)
	fx.initial_velocity_min = 50.0
	fx.initial_velocity_max = 110.0
	fx.scale_amount_min = 3.0
	fx.scale_amount_max = 6.0
	fx.color = Color(1.0, 0.9, 0.5, 0.95)
	add_child(fx)
	fx.emitting = true
	fx.finished.connect(fx.queue_free)

## แกว่งตัวเอียงซ้าย-ขวาเบาๆ วนตลอดเวลา (idle sway) ให้ความรู้สึก "มีชีวิต" โดยไม่ต้องมี sprite sheet
## หรือ Skeleton2D rig จริง — สุ่มความเร็วต่อตัวกันดูแกว่งพร้อมกันทั้งกระดานจนดูแข็ง/ไม่เป็นธรรมชาติ
## bind_node(piece) ให้ tween หยุดเองอัตโนมัติทันทีที่หมากตัวนี้ถูก queue_free() (ตอนโดนกินตาย/promote)
func _start_idle_sway(piece: ChessPiece) -> void:
	var amount := deg_to_rad(IDLE_SWAY_ANGLE_DEG)
	var duration := randf_range(IDLE_SWAY_MIN_DURATION, IDLE_SWAY_MAX_DURATION)
	var tween := create_tween().set_loops()
	tween.bind_node(piece)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(piece, "rotation", amount, duration)
	tween.tween_property(piece, "rotation", -amount, duration)
