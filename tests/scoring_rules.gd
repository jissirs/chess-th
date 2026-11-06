extends SceneTree

## เทสต์ระบบคะแนนแบบหลายหมวด: กลยุทธ์ (รุก/castling/en passant/เลื่อนขั้น/พัฒนา/ยึดกลาง/แลกคุ้ม/กินปลอดภัย),
## อัตรารอดของทีม, การรวมคะแนนแยกหมวดในเกมจริง
const ScoreRules := preload("res://script/score_rules.gd")

var failures := 0
var allocated: Array = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	print("PASS: " if ok else "FAIL: ", label)
	if not ok:
		failures += 1

func piece(state: Array, kind: int, side: int, x: int, y: int, hp: float = 100.0) -> ChessPiece:
	var p = ChessPiece.new()
	p.piece_kind = kind
	p.side = side
	p.hp = hp
	p.max_hp = 100.0
	p.attack_power = ChessPiece.base_attack(kind)
	state[y][x] = p
	allocated.append(p)
	return p

func labels(awards: Array) -> Array:
	var out: Array = []
	for a in awards:
		out.append(a.label)
	return out

func info(p: ChessPiece, from: Vector2i, to: Vector2i, extra: Dictionary = {}) -> Dictionary:
	var d := {"side": p.side, "piece": p, "kind": p.piece_kind, "from": from, "to": to, "moved": true,
		"castle": false, "en_passant": false, "promoted": false, "first_move": false, "captured_kind": -1}
	d.merge(extra, true)
	return d

func total(awards: Array) -> int:
	var t := 0
	for a in awards:
		t += a.points
	return t

func full_team(state: Array, side: int) -> void:
	var back: int = 7 if side == 0 else 0
	var pawn_row: int = 6 if side == 0 else 1
	for x in 8:
		piece(state, ChessPiece.Kind.PAWN, side, x, pawn_row)
	for entry in [[0, ChessPiece.Kind.ROOK], [1, ChessPiece.Kind.KNIGHT], [2, ChessPiece.Kind.BISHOP], [3, ChessPiece.Kind.QUEEN],
			[4, ChessPiece.Kind.KING], [5, ChessPiece.Kind.BISHOP], [6, ChessPiece.Kind.KNIGHT], [7, ChessPiece.Kind.ROOK]]:
		piece(state, entry[1], side, entry[0], back)

func run() -> void:
	var manager = root.get_node("GameManager")
	var stats = root.get_node("StatsManager")
	var stats_path = ProjectSettings.globalize_path("user://stats.cfg")
	var existed = FileAccess.file_exists(stats_path)
	var stats_bytes = FileAccess.get_file_as_bytes(stats_path) if existed else PackedByteArray()
	var saved_scores: Dictionary = stats.high_scores.duplicate()

	# ---------- กลยุทธ์ ----------
	var s = ChessRules.empty_state()
	piece(s, ChessPiece.Kind.KING, 0, 4, 7)
	piece(s, ChessPiece.Kind.KING, 1, 4, 0)
	var knight = piece(s, ChessPiece.Kind.KNIGHT, 0, 5, 2)
	var seen := {}
	var awards = ScoreRules.move_awards(s, info(knight, Vector2i(6, 7), Vector2i(5, 5), {"first_move": true}), seen)
	check("DEVELOP" in labels(awards), "first move of a knight scores DEVELOP")
	awards = ScoreRules.move_awards(s, info(knight, Vector2i(6, 7), Vector2i(5, 5), {"first_move": false}), seen)
	check("DEVELOP" not in labels(awards), "later knight moves do not score DEVELOP")

	var centre_piece = piece(s, ChessPiece.Kind.BISHOP, 0, 3, 3)
	awards = ScoreRules.move_awards(s, info(centre_piece, Vector2i(2, 4), Vector2i(3, 3)), seen)
	check("CENTER" in labels(awards), "entering the centre scores CENTER")
	awards = ScoreRules.move_awards(s, info(centre_piece, Vector2i(2, 4), Vector2i(3, 3)), seen)
	check("CENTER" not in labels(awards), "the same piece cannot farm CENTER again")

	var rook = piece(s, ChessPiece.Kind.ROOK, 0, 4, 4)
	check(ScoreRules.move_awards(s, info(rook, Vector2i(4, 5), Vector2i(4, 4), {"moved": false}), {}).is_empty(), "a non-lethal attack that does not move the piece scores no strategy")

	check("CASTLING" in labels(ScoreRules.move_awards(s, info(s[7][4], Vector2i(4, 7), Vector2i(6, 7), {"castle": true}), {})), "castling scores CASTLING")
	check("EN PASSANT" in labels(ScoreRules.move_awards(s, info(rook, Vector2i(4, 5), Vector2i(4, 4), {"en_passant": true}), {})), "en passant scores EN PASSANT")
	check("PROMOTION" in labels(ScoreRules.move_awards(s, info(rook, Vector2i(4, 1), Vector2i(4, 0), {"promoted": true}), {})), "promotion scores PROMOTION")

	# รุก: ควีนขาวอยู่คอลัมน์เดียวกับคิงดำ
	var s2 = ChessRules.empty_state()
	piece(s2, ChessPiece.Kind.KING, 0, 0, 7)
	piece(s2, ChessPiece.Kind.KING, 1, 4, 0)
	var queen = piece(s2, ChessPiece.Kind.QUEEN, 0, 4, 5)
	check("CHECK" in labels(ScoreRules.move_awards(s2, info(queen, Vector2i(3, 5), Vector2i(4, 5)), {})), "giving check scores CHECK")

	# กินตัวที่มูลค่าสูงกว่าด้วยตัวที่ถูกกว่า + กินแล้วปลอดภัย
	var s3 = ChessRules.empty_state()
	piece(s3, ChessPiece.Kind.KING, 0, 0, 7)
	piece(s3, ChessPiece.Kind.KING, 1, 7, 0)
	var pawn = piece(s3, ChessPiece.Kind.PAWN, 0, 2, 2)
	awards = ScoreRules.move_awards(s3, info(pawn, Vector2i(1, 3), Vector2i(2, 2), {"captured_kind": ChessPiece.Kind.QUEEN}), {})
	check("GOOD TRADE" in labels(awards) and "CLEAN CAPTURE" in labels(awards), "a pawn taking a queen safely scores GOOD TRADE and CLEAN CAPTURE")
	piece(s3, ChessPiece.Kind.ROOK, 1, 2, 0)  # เรือดำคุมคอลัมน์ 2 — หมากที่กินจะโดนกินกลับ
	awards = ScoreRules.move_awards(s3, info(pawn, Vector2i(1, 3), Vector2i(2, 2), {"captured_kind": ChessPiece.Kind.PAWN}), {})
	check("CLEAN CAPTURE" not in labels(awards) and "GOOD TRADE" not in labels(awards), "a capture that can be retaken is neither clean nor a good trade")

	# ---------- อัตรารอดของทีม ----------
	var full = ChessRules.empty_state()
	full_team(full, 0)
	check(is_equal_approx(ScoreRules.survival_rate(full, 0), 1.0) and ScoreRules.pieces_alive(full, 0) == 16, "a full-health team has survival rate 1.0")
	check(ScoreRules.survival_bonus(full, 0) == ScoreRules.SURVIVAL_MAX + ScoreRules.FLAWLESS_BONUS, "no losses gives the maximum survival bonus plus FLAWLESS")
	full[6][0].hp = 0.0  # เบี้ยตายหนึ่งตัว (ถูกลบออกจากกระดานจริงตอนกิน — ที่นี่จำลองด้วย hp = 0)
	var rate_one_lost = ScoreRules.survival_rate(full, 0)
	check(rate_one_lost < 1.0 and ScoreRules.survival_bonus(full, 0) < ScoreRules.SURVIVAL_MAX, "losing a piece lowers survival and removes FLAWLESS")
	full[6][1].hp = 20.0
	check(ScoreRules.survival_rate(full, 0) < rate_one_lost, "a badly wounded survivor counts less than a healthy one")
	var wiped = ChessRules.empty_state()
	piece(wiped, ChessPiece.Kind.KING, 0, 4, 7)
	check(ScoreRules.survival_rate(wiped, 0) < 0.1 and ScoreRules.survival_bonus(wiped, 0) < 150, "a team reduced to a lone king earns almost no survival bonus")
	check(ScoreRules.survival_rate(full, 1) == 0.0, "a side with no pieces has zero survival")
	var fresh = ChessRules.empty_state()
	full_team(fresh, 0)
	check(ScoreRules.survival_bonus(fresh, 0, 0) == 0, "standing still (no moves played) earns no survival bonus")
	check(ScoreRules.survival_bonus(fresh, 0, 10) == (ScoreRules.SURVIVAL_MAX + ScoreRules.FLAWLESS_BONUS) / 2, "survival bonus scales with moves played up to the minimum")
	check(ScoreRules.survival_bonus(fresh, 0, 200) == ScoreRules.SURVIVAL_MAX + ScoreRules.FLAWLESS_BONUS, "playing more than the minimum does not exceed the maximum")

	# ---------- รวมคะแนนในเกมจริง ----------
	manager.game_mode = "PVC"
	stats.high_scores["PVC"] = 0
	var scene = load("res://Scene/main.tscn").instantiate()
	root.add_child(scene)
	for i in 4:
		await process_frame
	var b = scene.board
	check(await b.try_move(Vector2i(4, 6), Vector2i(4, 4)), "white plays e4")
	check(scene._breakdown[0]["STRATEGY"] == 0 or scene._breakdown[0]["STRATEGY"] > 0, "strategy category exists")
	var after_pawn: int = scene._score
	# ม้าขาวออกจากแถวหลัง = DEVELOP (+30) ถ้ายังเป็นตาขาว
	await create_timer(1.2).timeout  # รอ AI เดินจบก่อน
	if b.side_to_move == 0:
		check(await b.try_move(Vector2i(6, 7), Vector2i(5, 5)), "white develops a knight")
		check(scene._breakdown[0]["STRATEGY"] >= ScoreRules.DEVELOP_POINTS, "developing a knight adds STRATEGY points in a real game")
		check(scene._score >= after_pawn + ScoreRules.DEVELOP_POINTS, "strategy points are part of the total score")
	var cat_sum := 0
	for category in ScoreRules.CATEGORIES:
		cat_sum += scene._breakdown[0][category]
	check(cat_sum == scene._score, "category totals add up to the score")
	scene._award_score(100, 0, "STRATEGY")
	scene._on_game_ended("stalemate", -1)
	await create_timer(0.3, true).timeout
	check(scene._breakdown[0]["SURVIVAL"] > 0, "survival bonus is awarded when the game ends (even on a draw)")
	check(scene._breakdown[0]["VICTORY"] == 0, "a draw gives no victory bonus")
	check(scene._breakdown[1]["SURVIVAL"] == 0 and scene._score_p2 == 0, "the AI side never scores in single player")
	scene.queue_free()
	await process_frame
	paused = false

	manager.game_mode = "PVP"
	stats.high_scores["PVP"] = 0
	scene = load("res://Scene/main.tscn").instantiate()
	root.add_child(scene)
	for i in 3:
		await process_frame
	scene._moves_played = {0: 20, 1: 20}
	scene._on_game_ended("checkmate", 1)
	await create_timer(0.3, true).timeout
	check(scene._breakdown[1]["VICTORY"] == ScoreRules.VICTORY_BONUS and scene._breakdown[1]["SURVIVAL"] > 0 and scene._breakdown[0]["SURVIVAL"] > 0,
		"PVP: both teams earn survival and the winner earns the victory bonus")
	check(scene._score_p2 > scene._score, "PVP: winner finishes ahead")
	scene.queue_free()
	await process_frame
	paused = false

	# ---------- คืนค่าเดิม ----------
	stats.high_scores = saved_scores
	if existed:
		var f = FileAccess.open(stats_path, FileAccess.WRITE)
		f.store_buffer(stats_bytes)
		f.close()
	else:
		DirAccess.remove_absolute(stats_path)
	for item in allocated:
		if is_instance_valid(item):
			item.free()
	print("FAILURES=", failures)
	quit(1 if failures else 0)
