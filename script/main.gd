extends Node2D

const GAMEPLAY_MUSIC := preload("res://asset/audio/BRAZILIAN PHONK.mp3")

const SFX_BUTTON := preload("res://asset/audio/ui_button.mp3")
const SFX_VICTORY := preload("res://asset/audio/victory_fanfare.mp3")  # รุกฆาต
const SFX_DEFEAT := preload("res://asset/audio/game_over.mp3")         # เสมอ/จบเกมแบบอื่น
const SFX_CHECK := preload("res://asset/audio/check_alert.mp3")

const SHAKE_REFERENCE_DAMAGE := 60.0  # ดาเมจระดับนี้ = สั่นเต็มแรง (สูงกว่านี้ก็สั่นแรงเท่าเดิม)
const SHAKE_MAX_OFFSET := 22.0        # พิกเซล ระยะสั่นสูงสุดตอนดาเมจเต็มแรง
const SHAKE_STEPS := 6
const SHAKE_STEP_DURATION := 0.035

const BG_SWAY_OFFSET := 6.0     # พิกเซล ระยะขยับของพื้นหลัง
const BG_SWAY_DURATION := 4.0   # วินาทีต่อช่วงการขยับ 1 รอบ (ยิ่งมากยิ่งขยับช้า นุ่มนวล)

const PAUSE_FADE_DURATION := 0.25

const TURN_TIME_LIMIT := 30.0  # วินาทีต่อตา รวมกันทุกฝ่าย หมดแล้วเสียตาไปเลย (ดู Board.force_pass_turn)

var _shake_tween: Tween

@onready var board: Node = $Board
@onready var pause_menu: Control = $UI/PauseMenu
@onready var result_label: Label = $UI/PauseMenu/PausePanel/VBoxContainer/Label
@onready var resume_button: TextureButton = $UI/PauseMenu/PausePanel/VBoxContainer/Resume
@onready var background: Sprite2D = $Background
@onready var timer_label: Label = $UI/TimerPanel/Label
@onready var score_label: Label = $UI/ScorePanel/Label
@onready var our_team_label: Label = $UI/OurTeamPanel/Label
@onready var opponent_team_label: Label = $UI/OpponentTeamPanel/Label

## เกมจบแล้วหรือยัง — ใช้กันไม่ให้ปุ่ม Resume โผล่กลับมาตอนกด pause หลังเกมจบ
var _finished: bool = false
var _turn_time_remaining: float = TURN_TIME_LIMIT
var _score: int = 0  # จำนวนศัตรู (ฝ่ายดำ) ที่ฝ่ายขาวฆ่าได้ในเกมนี้เกมเดียว (คนละตัวกับ StatsManager สะสม)

func _ready():
	AudioManager.play_music(GAMEPLAY_MUSIC)
	_start_background_sway()

	pause_menu.visible = false
	result_label.text = ""
	$UI/PauseButton.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	$UI/PauseMenu/PausePanel/VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	$UI/PauseMenu/PausePanel/VBoxContainer/MainMenu.pressed.connect(_on_main_menu_pressed)

	board.game_ended.connect(_on_game_ended)
	board.piece_attacked.connect(_on_piece_attacked)
	board.check_alerted.connect(_on_check_alerted)
	board.skill_used.connect(_on_skill_used_stats)
	StatsManager.achievement_unlocked.connect(_on_achievement_unlocked)
	board.turn_changed.connect(_on_turn_changed_reset_timer)
	board.move_made.connect(_on_move_made_update_team_counts)
	_update_score_label()
	_update_timer_label()
	# หมายเหตุ: ไม่เรียก _update_team_counts() ตรงนี้ตั้งใจ — Pieces (ลูกของ Board) ยัง spawn หมาก
	# ไม่เสร็จตอนนี้ (รอ await get_tree().process_frame ของตัวเองอยู่) เรียกตอนนี้จะได้ 0/0 ผิดๆ
	# ค่าเริ่มต้น "16" ที่ตั้งไว้ตรงๆ ใน main.tscn (OurTeamPanel/OpponentTeamPanel) ถูกต้องอยู่แล้ว
	# เพราะกระดานเริ่มเกมมีหมากฝ่ายละ 16 ตัวเสมอ — ฟังก์ชันนี้จะถูกเรียกจริงตอนมีการกินหมากครั้งแรก

## นับเวลาถอยหลังต่อตา — ไม่ต้องกัน paused เอง เพราะ Main ไม่ได้ตั้ง process_mode = Always
## (ค่าเริ่มต้น PROCESS_MODE_INHERIT) ตัว _process() นี้เลยหยุดขยับอัตโนมัติทันทีที่เกม paused
func _process(delta: float) -> void:
	if board.game_over or board.animating:
		return
	_turn_time_remaining -= delta
	if _turn_time_remaining <= 0.0:
		_turn_time_remaining = TURN_TIME_LIMIT
		board.force_pass_turn()
		return
	_update_timer_label()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		_on_pause_pressed()

func _on_pause_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	if _finished:
		return  # เกมจบแล้ว เมนูค้างอยู่ ไม่มีอะไรให้ pause
	result_label.text = ""
	_show_pause_menu()
	get_tree().paused = true

func _on_resume_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	_hide_pause_menu()
	get_tree().paused = false

func _on_restart_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	get_tree().paused = false          # ต้องคืนค่าก่อน เปลี่ยนฉากตอน paused=true จะค้าง
	AudioManager.stop_music()          # เพลง gameplay ไม่ควรเล่นต่อตอนกลับเมนูหลัก
	SceneTransition.change_scene("res://Scene/main_menu.tscn")

func _on_game_ended(result: String, winner: int) -> void:
	_finished = true
	if GameManager.game_mode == "PVC":
		if winner == ChessPiece.Team.WHITE:
			StatsManager.record_game_ended(true)
		elif winner == ChessPiece.Team.BLACK:
			StatsManager.record_game_ended(false)
		else:
			StatsManager.record_game_ended(null)
	else:
		StatsManager.record_game_ended(null)  # โหมด PVP ไม่มี "ผู้เล่น" ฝ่ายตายตัว ไม่นับแพ้/ชนะ
	if result == "checkmate":
		AudioManager.play_sfx(SFX_VICTORY)
	else:
		AudioManager.play_sfx(SFX_DEFEAT)
	result_label.text = _result_text(result, winner)
	resume_button.visible = false  # เกมจบแล้ว เล่นต่อไม่ได้ เหลือแค่ Restart / Main Menu
	_show_pause_menu()
	get_tree().paused = true

func _result_text(result: String, winner: int) -> String:
	match result:
		"checkmate":
			return "รุกฆาต! ฝ่าย%sชนะ" % ChessPiece.side_name(winner)
		"stalemate":
			return "อับ (Stalemate) — เสมอ"
		"insufficient_material":
			return "หมากไม่พอรุกฆาต — เสมอ"
		"fifty_move":
			return "ครบกฎ 50 ตา — เสมอ"
		_:
			return "จบเกม"

## สั่นหน้าจอตอนปะทะ — แรงสั่นตามดาเมจที่ตี (ฟังจาก signal Board.piece_attacked ที่มีอยู่แล้ว)
## สั่นเฉพาะ node "Main" (ตัวเอง) ซึ่งเป็น root ของฉากเกม — UI ไม่สั่นตามเพราะอยู่ใน CanvasLayer
## แยกต่างหาก ไม่ผูกกับ transform ของ Main
func _on_piece_attacked(attacker: ChessPiece, _victim: ChessPiece, damage: float, killed: bool) -> void:
	if killed:
		StatsManager.record_kill()
		if attacker.side == ChessPiece.Team.WHITE:
			_score += 1
			_update_score_label()
	var strength: float = clampf(damage / SHAKE_REFERENCE_DAMAGE, 0.0, 1.0)
	var magnitude: float = SHAKE_MAX_OFFSET * strength * (1.3 if killed else 1.0)
	_screen_shake(magnitude)

func _screen_shake(magnitude: float) -> void:
	if magnitude < 1.0:
		return
	if _shake_tween:
		_shake_tween.kill()  # กันสั่นซ้อนกันหลายรอบตอนตีรัวๆ

	var base_pos := Vector2.ZERO
	_shake_tween = create_tween()
	for i in range(SHAKE_STEPS):
		var falloff: float = 1.0 - float(i) / SHAKE_STEPS
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * magnitude * falloff
		_shake_tween.tween_property(self, "position", base_pos + offset, SHAKE_STEP_DURATION)
	_shake_tween.tween_property(self, "position", base_pos, SHAKE_STEP_DURATION)

## เล่นเสียงเตือนตอนฝ่ายใดฝ่ายหนึ่งถูกรุก (ฟังจาก signal Board.check_alerted ที่มีอยู่แล้วตั้งแต่
## ตอนที่ 5 แต่ยังไม่เคยมีใครฟังมาก่อน) — ไม่สนใจว่าฝ่ายไหนถูกรุก เล่นเสียงเดียวกันหมด
func _on_check_alerted(_side: int) -> void:
	AudioManager.play_sfx(SFX_CHECK)

## นับจำนวนครั้งที่ใช้ Active Skill สะสม (ฟังจาก signal Board.skill_used ที่มีอยู่แล้วตั้งแต่ตอนที่ 11.9)
func _on_skill_used_stats(_piece: ChessPiece, _effect_kind: String) -> void:
	StatsManager.record_skill_used()

## โชว์ toast ข้อความลอยขึ้นแจ้งเตือนตอนปลดล็อก achievement ใหม่ — สร้าง Label ชั่วคราวด้วยโค้ด
## ล้วนๆ ไม่ต้องมี node เตรียมไว้ในฉากเลย (เทคนิคเดียวกับ DamagePopup ตอนที่ 11.5 แต่เป็น UI แทนโลก 2D)
func _on_achievement_unlocked(title: String) -> void:
	var label := Label.new()
	label.text = "🏆 " + title
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	label.position = Vector2(-300, 40)
	label.custom_minimum_size = Vector2(600, 60)
	label.modulate = Color(1, 1, 1, 0)
	$UI.add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)

## เฟดเข้าเมนู pause นุ่มนวล — ใช้ทั้งตอนกด Pause และตอนเกมจบ (ดู _on_pause_pressed/_on_game_ended)
## ต้อง set_pause_mode(TWEEN_PAUSE_PROCESS) เพราะ get_tree().paused = true ถูกสั่งทันทีหลังเรียกฟังก์ชัน
## นี้ — ถ้าไม่ตั้งไว้ tween จะหยุดขยับทันทีที่ tree paused (ค้างตอน alpha ยังไม่ถึง 1.0)
func _show_pause_menu() -> void:
	pause_menu.visible = true
	pause_menu.modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pause_menu, "modulate:a", 1.0, PAUSE_FADE_DURATION)

## เฟดออกจากเมนู pause แล้วค่อยซ่อนจริงตอนจางหมด (ไม่ใช่ซ่อนทันที ไม่งั้นจะไม่เห็น fade เลย)
func _hide_pause_menu() -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pause_menu, "modulate:a", 0.0, PAUSE_FADE_DURATION)
	tween.tween_callback(func(): pause_menu.visible = false)

## ให้พื้นหลังขยับเบาๆ วนไปมาตลอดเวลา (idle sway) — ไม่ผูกกับ _screen_shake() เลย เพราะอันนั้น
## สั่น node "Main" (ตัวเอง) ส่วนนี้ขยับแค่ Background ลูกของมัน คนละ property กัน ไม่ชนกัน
func _start_background_sway() -> void:
	var base_pos: Vector2 = background.position
	var offset := Vector2(BG_SWAY_OFFSET, BG_SWAY_OFFSET * 0.4)
	var tween := create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(background, "position", base_pos + offset, BG_SWAY_DURATION)
	tween.tween_property(background, "position", base_pos - offset, BG_SWAY_DURATION)
	tween.tween_property(background, "position", base_pos, BG_SWAY_DURATION)

## รีเซ็ตนาฬิกาต่อตาทุกครั้งที่เปลี่ยนฝ่าย (ฟังจาก signal Board.turn_changed ที่มีอยู่แล้ว)
func _on_turn_changed_reset_timer(_side: int) -> void:
	_turn_time_remaining = TURN_TIME_LIMIT
	_update_timer_label()

## อัปเดตจำนวนหมากที่เหลือทุกครั้งที่มีการเดิน (กินหมากอาจทำให้จำนวนเปลี่ยน — ฟังจาก move_made ที่มีอยู่แล้ว)
func _on_move_made_update_team_counts(_from_cell: Vector2i, _to_cell: Vector2i, _piece: ChessPiece) -> void:
	_update_team_counts()

func _update_timer_label() -> void:
	var seconds: int = maxi(0, int(ceil(_turn_time_remaining)))
	timer_label.text = "TIME\n%02d:%02d" % [seconds / 60, seconds % 60]

func _update_score_label() -> void:
	score_label.text = "SCORE\n%06d" % _score

## นับหมากที่เหลือจริงบนกระดานแยกฝั่งขาว/ดำ แล้วอัปเดตป้าย Our Team / Opponent Team
func _update_team_counts() -> void:
	var white_count := 0
	var black_count := 0
	for row in board.board_state:
		for piece in row:
			if piece == null:
				continue
			if piece.side == ChessPiece.Team.WHITE:
				white_count += 1
			else:
				black_count += 1
	our_team_label.text = "OUR TEAM\n%02d" % white_count
	opponent_team_label.text = "OPPONENT TEAM\n%02d" % black_count
