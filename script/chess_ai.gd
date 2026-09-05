extends RefCounted
class_name ChessAI

## AI หมากรุกแบบง่าย ใช้ minimax + alpha-beta pruning ประเมินจาก "มูลค่าหมากถ่วงน้ำหนักด้วยเลือด"
## รู้จักระบบเลือด (HP) แบบเดียวกับที่ Board.try_move() ใช้จริง: โจมตีไม่ได้ฆ่าเสมอไป ถ้าดาเมจไม่พอ
## ผู้โจมตี "ไม่ขยับ" เข้าไปแทนที่ เหยื่อแค่เลือดลด — AI จึงเข้าใจว่า "ตีให้เลือดใกล้หมด" มีค่า แม้จะ
## ยังไม่ฆ่าตายในตานั้นก็ตาม ไม่ผูกกับ node ใดๆ — เรียกใช้แบบ ChessAI.best_move(...) ได้เลย
##
## มุมมองคะแนน: บวก = ได้เปรียบฝ่ายดำ (AI), ลบ = ได้เปรียบฝ่ายขาว (ผู้เล่น)
## เพราะ AI เล่นฝ่ายดำเสมอ (ดู ai_player.gd) — ไม่ใช่คะแนนสัมบูรณ์แบบ "ฝ่ายที่กำลังจะเดิน"
##
## ⚠️ ข้อควรระวังสำคัญที่สุดของไฟล์นี้: state ที่ ChessRules.copy_state() ก๊อปมาให้ยังใช้ ChessPiece
## object ตัวเดิมเสมอ (ก๊อปแค่ array ไม่ก๊อปตัวหมาก) เพราะแต่เดิม chess_rules.gd แค่ย้าย/ลบ reference
## ไม่เคยแก้ค่าในตัวหมากเลย ปลอดภัยมาตลอด — แต่ถ้าไฟล์นี้เรียก piece.take_damage() ตรงๆ ระหว่างค้นหา
## จะไปแก้ hp จริงของหมากในเกมจริงทันทีโดยไม่ตั้งใจ! จึงต้องเก็บ "เลือดจำลอง" แยกไว้ต่างหากใน
## hp_overrides (Dictionary คีย์เป็นตัว ChessPiece เอง แม็ปไปหา HP ที่ใช้ในการจำลองครั้งนี้)
## แล้วส่งต่อ (ก๊อปใหม่ทุกชั้นเหมือน state) ไปตลอดทั้งต้นไม้การค้นหา ไม่แตะ piece.hp จริงเลย
##
## ข้อจำกัดที่รู้อยู่แล้ว (ยอมรับได้สำหรับ AI ระดับนี้):
## - มองไม่เห็น en passant ที่ลึกกว่าตาแรก (ส่งต่อ NO_CELL ในทุกชั้นถัดไป)
## - จำลองอนาคตด้วย ChessRules.apply() (ผ่าน _apply_hp_aware) ซึ่งไม่ทำ promotion ให้ (เบี้ยที่ถึง
##   แถวสุดท้ายในผลลัพธ์สมมติยังนับเป็นเบี้ยอยู่) ทำให้ประเมินค่าตาเดินที่นำไปสู่การเลื่อนขั้นต่ำกว่า
##   ความเป็นจริงเล็กน้อย

## มูลค่าหมากแบบมาตรฐาน (หน่วยเทียบเท่าเบี้ย 1 ตัว) คิงไม่นับคะแนนเพราะกินไม่ได้อยู่แล้ว
## (เกมจบด้วยรุกฆาตก่อนเสมอ — ดู _minimax ที่ให้คะแนนสุดขั้วเมื่อไม่มีตาเดินเหลือ)
const PIECE_VALUES := {
	ChessPiece.Kind.PAWN: 1.0,
	ChessPiece.Kind.KNIGHT: 3.0,
	ChessPiece.Kind.BISHOP: 3.0,
	ChessPiece.Kind.ROOK: 5.0,
	ChessPiece.Kind.QUEEN: 9.0,
	ChessPiece.Kind.KING: 0.0,
}

const CHECKMATE_SCORE := 9999.0

## ค่าติดลบเล็กมาก หักออกจากคะแนนของ "การใช้สกิล" เสมอ — กันไม่ให้ AI เลือกใช้สกิลที่ให้ผลเท่ากับ
## เดินเฉยๆ (เช่นฮีลตอนเลือดเต็มอยู่แล้ว) เพราะคะแนนเท่ากันเป๊ะจะถูกสุ่มเลือกได้ 50/50 — ต้องเล็กกว่า
## ผลจริงของสกิลมากๆ (เบี้ยฮีล +40 มีผลต่อคะแนนหลักสิบ) ไม่งั้นจะไปกลบประโยชน์จริงของสกิลจนไม่ถูกเลือกเลย
const SKILL_TIEBREAK_PENALTY := 0.001

## น้ำหนักของคะแนนเชิงตำแหน่งเทียบกับคะแนนมูลค่าหมาก (material_score) — 0.05 = มีผลเสริมเบาๆ
## ไม่ทำให้ AI ยอมเสียหมากฟรีๆ แค่เพื่อได้ตำแหน่งดีขึ้นนิดหน่อย
const POSITIONAL_WEIGHT := 0.05

## HP ปัจจุบันของ piece "ในมุมมองของการจำลองนี้" — ถ้ายังไม่เคยโดนจำลองตีในสายนี้เลย ใช้ piece.hp
## จริงได้ตรงๆ (เพราะยังไม่มีการจำลองใดๆ มาเปลี่ยนมัน) มีผลแค่ตอน "อ่าน" ไม่แก้ piece.hp จริงเด็ดขาด
static func _effective_hp(piece: ChessPiece, hp_overrides: Dictionary) -> float:
	return hp_overrides.get(piece, piece.hp)

## ให้คะแนน "มูลค่าหมากสุทธิ" ถ่วงน้ำหนักด้วยสัดส่วนเลือดที่เหลือ (piece.max_hp คงที่ ไม่ต้องจำลอง)
## หมากเลือดเหลือ 20% มีค่าแค่ 20% ของมูลค่าเต็ม — ให้เครดิต AI ที่ทำดาเมจสะสมแม้ยังไม่ฆ่าตาย
static func material_score(state: Array, hp_overrides: Dictionary) -> float:
	var score := 0.0
	for row in state:
		for piece in row:
			if piece == null:
				continue
			var value: float = PIECE_VALUES[piece.piece_kind]
			var hp_ratio: float = clampf(_effective_hp(piece, hp_overrides) / piece.max_hp, 0.0, 1.0) \
				if piece.max_hp > 0.0 else 1.0
			value *= hp_ratio
			score += value if piece.side == ChessPiece.Team.BLACK else -value
	return score

## ให้คะแนนเสริมจากตำแหน่งบนกระดาน (ไม่ใช่แค่นับมูลค่าหมากเฉยๆ) — สอง idea ง่ายๆ:
## 1) ม้า/บิชอป/ควีนอยู่ใกล้กลางกระดานมีค่ามากกว่าอยู่ริม (ควบคุมพื้นที่ได้กว้างกว่า)
## 2) เบี้ยที่รุกคืบไปข้างหน้าใกล้แถวโปรโมทมีค่ามากกว่าเบี้ยที่ยังไม่ขยับ
static func positional_score(state: Array) -> float:
	var score := 0.0
	for row in range(state.size()):
		for col in range(state[row].size()):
			var piece: ChessPiece = state[row][col]
			if piece == null:
				continue
			var bonus := 0.0
			match piece.piece_kind:
				ChessPiece.Kind.KNIGHT, ChessPiece.Kind.BISHOP, ChessPiece.Kind.QUEEN:
					bonus = _center_bonus(col, row)
				ChessPiece.Kind.PAWN:
					bonus = _pawn_advance_bonus(row, piece.side)
			score += bonus if piece.side == ChessPiece.Team.BLACK else -bonus
	return score

## ยิ่งใกล้กลางกระดาน (d4/d5/e4/e5) ยิ่งได้คะแนนสูง — ใช้ระยะ Chebyshev จากจุดกึ่งกลาง
static func _center_bonus(col: int, row: int) -> float:
	var dist: float = maxf(absf(col - 3.5), absf(row - 3.5))
	return maxf(0.0, 0.3 - dist * 0.08)

## เบี้ยยิ่งใกล้แถวโปรโมทของฝ่ายตัวเองยิ่งได้คะแนนสูง — คิดจากจำนวนแถวที่เหลือถึงเป้าหมาย
static func _pawn_advance_bonus(row: int, side: int) -> float:
	var distance_to_promotion: int = row if side == ChessPiece.Team.WHITE else (7 - row)
	var progress: int = 6 - distance_to_promotion
	return maxf(0.0, progress) * 0.05

## จำลองตาเดินแบบรู้จักเลือด — เหมือน ChessRules.apply() แต่ "กิน" ไม่ได้ฆ่าทันทีเสมอไป
## คืน {"state": Array, "overrides": Dictionary} ให้ส่งต่อเป็นอินพุตของชั้นถัดไปในการค้นหา
static func _apply_hp_aware(state: Array, from: Vector2i, to: Vector2i, ep_target: Vector2i, hp_overrides: Dictionary) -> Dictionary:
	var piece := ChessRules.at(state, from)
	if piece == null:
		return {"state": ChessRules.copy_state(state), "overrides": hp_overrides.duplicate()}

	# หาตัวที่จะโดนกิน (รวมกินผ่าน en passant) ด้วยวิธีเดียวกับที่ Board.try_move() ใช้จริง
	var captured := ChessRules.at(state, to)
	var is_en_passant := piece.piece_kind == ChessPiece.Kind.PAWN and to == ep_target and captured == null
	if is_en_passant:
		captured = ChessRules.at(state, Vector2i(to.x, from.y))

	var new_overrides: Dictionary = hp_overrides.duplicate()

	if captured == null:
		# ไม่มีการกิน — พฤติกรรมเหมือน ChessRules.apply() เดิมทุกอย่าง ไม่ต้องยุ่งกับเลือดเลย
		return {"state": ChessRules.apply(state, from, to, ep_target), "overrides": new_overrides}

	# ตำแหน่งจริงของเหยื่อ — กินผ่าน (en passant) เหยื่อไม่ได้อยู่ที่ to แต่อยู่ข้างๆ
	var captured_cell: Vector2i = to
	if is_en_passant:
		captured_cell = Vector2i(to.x, from.y)

	var remaining_hp: float = _effective_hp(captured, hp_overrides) - PassiveSkills.compute_damage(piece, captured, state, captured_cell)

	var lethal := remaining_hp <= 0.0

	if lethal:
		# ตายจริง — เหมือนเดิมทุกอย่าง ใช้ ChessRules.apply() ได้เลย (ลบเหยื่อ + ย้ายผู้โจมตีให้แล้ว)
		new_overrides.erase(captured)  # ตายแล้วไม่ต้องมีสถานะเลือดค้างให้จำต่อในสายนี้อีก
		return {"state": ChessRules.apply(state, from, to, ep_target), "overrides": new_overrides}

	# ไม่ตาย — board_state ไม่เปลี่ยนเลย (เหมือน Board.try_move() ตอน piece_moved = false:
	# ผู้โจมตีไม่ขยับเข้าไปแทนที่ เหยื่อยังยืนอยู่ที่เดิม) มีแค่เลือดจำลองของเหยื่อที่ลดลง
	new_overrides[captured] = remaining_hp
	return {"state": ChessRules.copy_state(state), "overrides": new_overrides}

## หาช่อง (cell) ของหมากทั้งหมดฝ่าย side ที่ "ใช้สกิลได้ตอนนี้" — เรียกที่ root เท่านั้น (state จริง
## ยังไม่ถูกจำลองอะไรเลย ค่า can_use_skill() ของหมากจริงจึงเชื่อถือได้ 100%)
static func _skill_candidates(state: Array, side: int) -> Array:
	var candidates: Array = []
	for row in range(state.size()):
		for col in range(state[row].size()):
			var piece: ChessPiece = state[row][col]
			if piece != null and piece.side == side and piece.can_use_skill():
				candidates.append(Vector2i(col, row))
	return candidates

## จำลองผลของ "ใช้สกิล" แบบรู้จักเลือด (เหมือน _apply_hp_aware() แต่ไม่มีการเดิน/กิน) — คืน
## {"state", "overrides"} ให้ส่งต่อเป็นอินพุตของ _minimax() ชั้นถัดไปเหมือนตาเดินปกติทุกประการ
## ⚠️ ม้า/ควีน (บัฟโจมตี) ไม่มีผลต่อคะแนนเลยตรงนี้ — material_score() ไม่รู้จัก "ดาเมจอนาคต"
## จึงเป็นข้อจำกัดที่ยอมรับ: AI แทบไม่เลือกใช้ 2 สกิลนี้เอง (ดูตอนที่ 11.26 ใน BUILD_GUIDE.md)
static func _apply_skill_aware(state: Array, cell: Vector2i, hp_overrides: Dictionary) -> Dictionary:
	var piece := ChessRules.at(state, cell)
	var new_overrides: Dictionary = hp_overrides.duplicate()
	if piece == null:
		return {"state": ChessRules.copy_state(state), "overrides": new_overrides}

	match piece.piece_kind:
		ChessPiece.Kind.PAWN:
			new_overrides[piece] = minf(_effective_hp(piece, hp_overrides) + 40.0, piece.max_hp)
		ChessPiece.Kind.BISHOP:
			new_overrides[piece] = piece.max_hp
		ChessPiece.Kind.ROOK:
			new_overrides[piece] = minf(_effective_hp(piece, hp_overrides) + 30.0, piece.max_hp)
		ChessPiece.Kind.KING:
			for row in state:
				for p in row:
					if p != null and p.side == piece.side:
						new_overrides[p] = minf(_effective_hp(p, hp_overrides) + 20.0, p.max_hp)
		_:
			pass  # ม้า/ควีน — ไม่มีผลต่อ overrides เลยตามที่อธิบายไว้ด้านบน

	return {"state": ChessRules.copy_state(state), "overrides": new_overrides}

## หาตาเดินที่ดีที่สุดสำหรับฝ่าย side ที่ความลึก depth ชั้น
## คืน {} ถ้าไม่มีตาเดินให้เลือกเลย (ไม่ควรเกิด เพราะ Board._evaluate_status ควรจับจบเกมได้ก่อนแล้ว)
static func best_move(state: Array, side: int, ep_target: Vector2i, depth: int = 2) -> Dictionary:
	var moves: Array = ChessRules.all_legal_moves(state, side, ep_target)
	var skill_cells: Array = _skill_candidates(state, side)
	if moves.is_empty() and skill_cells.is_empty():
		return {}

	var maximizing := side == ChessPiece.Team.BLACK
	var best_score: float = -INF if maximizing else INF
	var best_actions: Array = []  # เก็บทุกตา/สกิลที่คะแนนเท่ากับดีที่สุด แล้วค่อยสุ่มเลือก 1 อัน

	for move in moves:
		# เริ่มจาก overrides ว่างเปล่า (ตอนนี้ยังไม่มีการจำลองใดๆ มาก่อนหน้า) piece.hp จริงยังเชื่อถือได้
		var result := _apply_hp_aware(state, move.from, move.to, ep_target, {})
		var score := _minimax(result.state, depth - 1, ChessRules.opponent(side), -INF, INF, result.overrides)
		var better: bool = score > best_score if maximizing else score < best_score
		if better:
			best_score = score
			best_actions = [move]
		elif score == best_score:
			best_actions.append(move)

	# พิจารณาสกิลเป็นตัวเลือกคู่ขนานกับตาเดิน — เทียบคะแนนกันตรงๆ ในบันไดเดียวกัน
	for cell in skill_cells:
		var result := _apply_skill_aware(state, cell, {})
		var score := _minimax(result.state, depth - 1, ChessRules.opponent(side), -INF, INF, result.overrides)
		# หักคะแนนเล็กน้อย (ไปทางที่แย่ลงสำหรับฝ่าย side) กันสกิลที่ไม่มีผลจริงชนะเสมอกับเดินเฉยๆ
		score += -SKILL_TIEBREAK_PENALTY if maximizing else SKILL_TIEBREAK_PENALTY
		var better: bool = score > best_score if maximizing else score < best_score
		var action := {"type": "skill", "cell": cell}
		if better:
			best_score = score
			best_actions = [action]
		elif score == best_score:
			best_actions.append(action)

	# สุ่มในบรรดาตัวเลือกที่ดีที่สุดเท่าๆ กัน กัน AI เดินซ้ำแบบเดิมทุกครั้งที่เจอสถานการณ์เดียวกัน
	return best_actions[randi() % best_actions.size()]

## minimax แบบมี alpha-beta pruning ตัดกิ่งที่รู้แล้วว่าอีกฝ่ายไม่มีทางเลือกมา
## side คือฝ่ายที่ "กำลังจะเดิน" ในชั้นนี้ (สลับไปมาทุกชั้นตามธรรมชาติของเกม)
## hp_overrides ไล่ตามการจำลองไปทุกชั้น เก็บเลือดจำลองสะสมของทุกตัวที่เคยโดนตีในสายนี้
static func _minimax(state: Array, depth: int, side: int, alpha: float, beta: float, hp_overrides: Dictionary) -> float:
	if depth <= 0:
		return material_score(state, hp_overrides) + positional_score(state) * POSITIONAL_WEIGHT

	# ค้นด้วย ep_target = NO_CELL เสมอ (ยกเว้นตาแรกสุดที่ best_move() รับมาจากสถานะจริง)
	# เพราะไม่ได้ tracking ว่าตาไหนเพิ่งเดินเบี้ย 2 ช่องระหว่างจำลอง — ยอมรับเป็นข้อจำกัดของ AI ระดับนี้
	var moves: Array = ChessRules.all_legal_moves(state, side, ChessRules.NO_CELL)
	if moves.is_empty():
		# ไม่มีตาเดิน = จบเกม เช็คว่ารุกฆาตหรืออับ
		if ChessRules.is_in_check(state, side):
			# side ที่โดนรุกฆาตแพ้ — ถ้าเป็นฝ่ายดำ (AI) คือคะแนนต่ำสุด, ถ้าเป็นฝ่ายขาวคือคะแนนสูงสุด (ดีกับ AI)
			return -CHECKMATE_SCORE if side == ChessPiece.Team.BLACK else CHECKMATE_SCORE
		return 0.0  # อับ (stalemate) — เสมอ

	if side == ChessPiece.Team.BLACK:
		var value := -INF
		for move in moves:
			var result := _apply_hp_aware(state, move.from, move.to, ChessRules.NO_CELL, hp_overrides)
			value = maxf(value, _minimax(result.state, depth - 1, ChessRules.opponent(side), alpha, beta, result.overrides))
			alpha = maxf(alpha, value)
			if alpha >= beta:
				break  # กิ่งนี้อีกฝ่ายไม่มีทางยอมให้ไปถึง — ตัดทิ้งได้เลย
		return value
	else:
		var value := INF
		for move in moves:
			var result := _apply_hp_aware(state, move.from, move.to, ChessRules.NO_CELL, hp_overrides)
			value = minf(value, _minimax(result.state, depth - 1, ChessRules.opponent(side), alpha, beta, result.overrides))
			beta = minf(beta, value)
			if alpha >= beta:
				break
		return value
