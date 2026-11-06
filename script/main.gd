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
const SETTINGS_SCENE := preload("res://Scene/settings.tscn")

const CAPTURE_POINTS := {
	ChessPiece.Kind.PAWN: 100,
	ChessPiece.Kind.KNIGHT: 300,
	ChessPiece.Kind.BISHOP: 300,
	ChessPiece.Kind.ROOK: 500,
	ChessPiece.Kind.QUEEN: 900,
}
const VICTORY_BONUS := 1000
const VICTORY_BANNER := preload("res://asset/wictory.png")
const DEFEAT_BANNER := preload("res://asset/loose.png")

const TURN_TIME_LIMIT := 30.0  # วินาทีต่อตา รวมกันทุกฝ่าย หมดแล้วเสียตาไปเลย (ดู Board.force_pass_turn)

var _shake_tween: Tween
var _settings_panel: Control
var _end_banner: TextureRect
var _end_score_row: HBoxContainer
var _end_score_value: Label
var _end_high_value: Label
var _end_score_p2_value: Label
var _p2_score_digits: HBoxContainer
var _end_high_row: HBoxContainer
var _end_record_label: Label
## HIGH SCORE ของโหมดนี้ตอนเริ่มเกม — จบเกมแล้วคะแนนที่สูงกว่านี้ = ทำลายสถิติ (ใช้โชว์ NEW RECORD!)
var _record_at_start: int = 0

@onready var board: Node = $Board
@onready var pause_menu: Control = $UI/PauseMenu
@onready var result_label: Label = $UI/PauseMenu/PausePanel/VBoxContainer/Label
@onready var resume_button: TextureButton = $UI/PauseMenu/PausePanel/VBoxContainer/Resume
@onready var background: Sprite2D = $Background
@onready var timer_label: Label = $UI/TimerPanel/Label
@onready var timer_title_label: Label = $UI/TimerPanel/Title
@onready var score_label: Label = $UI/ScorePanel/Label
@onready var high_score_label: Label = $UI/HighScorePanel/Label
@onready var our_team_label: Label = $UI/OurTeamPanel/Label
@onready var opponent_team_label: Label = $UI/OpponentTeamPanel/Label

## เกมจบแล้วหรือยัง — ใช้กันไม่ให้ปุ่ม Resume โผล่กลับมาตอนกด pause หลังเกมจบ
var _finished: bool = false
var _turn_time_remaining: float = TURN_TIME_LIMIT
var _score: int = 0  # Weighted capture points plus a one-time victory bonus (ผู้เล่น 1 = ฝ่ายขาว)
var _score_p2: int = 0  # ผู้เล่น 2 (ฝ่ายดำ) — นับเฉพาะโหมด PVP ส่วนโหมด PVC ฝ่ายดำคือ AI ไม่มีคะแนน

func _is_pvp() -> bool:
	return GameManager.game_mode == "PVP"

func _ready():
	AudioManager.play_music(GAMEPLAY_MUSIC)
	_start_background_sway()

	var pause_shortcut := Shortcut.new()
	pause_shortcut.events = InputMap.action_get_events("pause")
	$UI/PauseButton.shortcut = pause_shortcut
	ChessPiece.hide_bars = false  # static ค้างข้ามฉาก — กด Restart/กลับเมนูตอน pause ไม่งั้นหลอดเลือดหายถาวร
	$UI.move_child(pause_menu, -1)  # ลำดับ node ท้ายสุด = วาดทับแผงคะแนน/เวลา/จำนวนหมากทั้งหมด
	pause_menu.visible = false
	result_label.text = ""
	_record_at_start = StatsManager.high_score
	_build_end_screen()
	_setup_pvp_hud()
	$UI/PauseButton.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	$UI/PauseMenu/PausePanel/VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	$UI/PauseMenu/PausePanel/VBoxContainer/Settings.pressed.connect(_on_settings_pressed)
	$UI/PauseMenu/PausePanel/VBoxContainer/MainMenu.pressed.connect(_on_main_menu_pressed)

	board.game_ended.connect(_on_game_ended)
	board.piece_attacked.connect(_on_piece_attacked)
	board.check_alerted.connect(_on_check_alerted)
	board.skill_used.connect(_on_skill_used_stats)
	StatsManager.achievement_unlocked.connect(_on_achievement_unlocked)
	board.turn_changed.connect(_on_turn_changed_reset_timer)
	board.move_made.connect(_on_move_made_update_team_counts)
	board.pieces_ready.connect(_update_team_counts)
	_update_score_label()
	_update_timer_label()

## นับเวลาถอยหลังต่อตา — ไม่ต้องกัน paused เอง เพราะ Main ไม่ได้ตั้ง process_mode = Always
## (ค่าเริ่มต้น PROCESS_MODE_INHERIT) ตัว _process() นี้เลยหยุดขยับอัตโนมัติทันทีที่เกม paused
func _process(delta: float) -> void:
	if get_tree().paused or board.game_over or board.animating:
		return
	_turn_time_remaining -= delta
	if _turn_time_remaining <= 0.0:
		_turn_time_remaining = 0.0
		_update_timer_label()
		board.force_pass_turn()
		return
	_update_timer_label()

func _on_pause_pressed():
	if SceneTransition.is_transitioning:
		return
	if get_tree().paused and not _finished:
		_on_resume_pressed()
		return
	AudioManager.play_sfx(SFX_BUTTON)
	if _finished:
		return  # เกมจบแล้ว เมนูค้างอยู่ ไม่มีอะไรให้ pause
	AudioManager.stop_character_audio()
	result_label.text = ""
	_show_pause_menu()
	get_tree().paused = true

func _on_resume_pressed():
	if is_instance_valid(_settings_panel) or SceneTransition.is_transitioning:
		return
	AudioManager.play_sfx(SFX_BUTTON)
	_hide_pause_menu()
	get_tree().paused = false

func _on_settings_pressed() -> void:
	if is_instance_valid(_settings_panel) or SceneTransition.is_transitioning:
		return
	AudioManager.play_sfx(SFX_BUTTON)
	get_tree().paused = true
	SceneTransition.transition(_open_settings_panel)

func _open_settings_panel() -> void:
	pause_menu.hide()
	$UI/PauseButton.hide()
	_settings_panel = SETTINGS_SCENE.instantiate()
	_settings_panel.embedded = true
	_settings_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_settings_panel.back_requested.connect(_on_settings_closed)
	$UI.add_child(_settings_panel)

func _on_settings_closed() -> void:
	if SceneTransition.is_transitioning or not is_instance_valid(_settings_panel):
		return
	SceneTransition.transition(_close_settings_panel)

func _close_settings_panel() -> void:
	if is_instance_valid(_settings_panel):
		_settings_panel.queue_free()
	_settings_panel = null
	pause_menu.modulate.a = 1.0
	pause_menu.show()
	$UI/PauseButton.show()

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
	if _finished:
		return
	_finished = true
	AudioManager.stop_greeting()
	if result in ["checkmate", "timeout"]:
		if winner == ChessPiece.Team.WHITE:
			_award_score(VICTORY_BONUS, ChessPiece.Team.WHITE)
		elif _is_pvp():
			_award_score(VICTORY_BONUS, ChessPiece.Team.BLACK)
	if GameManager.game_mode == "PVC":
		if winner == ChessPiece.Team.WHITE:
			StatsManager.record_game_ended(true)
		elif winner == ChessPiece.Team.BLACK:
			StatsManager.record_game_ended(false)
		else:
			StatsManager.record_game_ended(null)
	else:
		StatsManager.record_game_ended(null, true)  # โหมด PVP ไม่มี "ผู้เล่น" ฝ่ายตายตัว นับเป็นเกม PVP ไม่นับแพ้/ชนะ/เสมอ
	var player_won := result in ["checkmate", "timeout"] and (GameManager.game_mode != "PVC" or winner == ChessPiece.Team.WHITE)
	result_label.text = _result_text(result, winner)
	_show_end_screen(player_won, result in ["checkmate", "timeout"])
	resume_button.visible = false  # เกมจบแล้ว เล่นต่อไม่ได้ เหลือแค่ Restart / Main Menu
	_show_pause_menu()
	get_tree().paused = true
	AudioManager.play_sfx(SFX_VICTORY if player_won else SFX_DEFEAT)

## สร้างส่วนหน้าจอจบเกม (ป้าย WIN/LOSE + แถวคะแนน) แทรกเหนือ/ใต้ข้อความผลเกมใน PausePanel
## ซ่อนไว้ตลอดจนกว่าเกมจะจบ — เมนู pause ปกติจึงไม่เปลี่ยน
func _build_end_screen() -> void:
	var box: VBoxContainer = $UI/PauseMenu/PausePanel/VBoxContainer
	_end_banner = TextureRect.new()
	_end_banner.custom_minimum_size = Vector2(0, 300)
	_end_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_end_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_end_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_banner.visible = false
	box.add_child(_end_banner)
	box.move_child(_end_banner, 0)

	var font: Font = load("res://asset/ui/components/fonts/runic_font.fnt")
	_end_score_row = HBoxContainer.new()
	_end_score_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_end_score_row.add_theme_constant_override("separation", 70)
	_end_score_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_score_row.visible = false
	var pvp := _is_pvp()
	_end_score_value = _add_score_column(_end_score_row, "P1 SCORE" if pvp else "SCORE", Color(0.65, 0.94, 1.0), font)
	if pvp:
		# PVP: แถวบน = คะแนนเกมนี้ของทั้ง 2 คน, แถวล่าง = HIGH SCORE ตัวเดียวที่ 2 คนใช้ร่วมกัน (ตัวเล็กกว่า)
		_end_score_p2_value = _add_score_column(_end_score_row, "P2 SCORE", Color(1.0, 0.7, 0.45), font)
		_end_high_row = HBoxContainer.new()
		_end_high_row.alignment = BoxContainer.ALIGNMENT_CENTER
		_end_high_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_end_high_row.visible = false
		_end_high_value = _add_score_column(_end_high_row, "HIGH SCORE", Color(1.0, 0.85, 0.46), font, 0.8)
		box.add_child(_end_high_row)
		box.move_child(_end_high_row, result_label.get_index() + 1)
	else:
		_end_high_value = _add_score_column(_end_score_row, "HIGH SCORE", Color(1.0, 0.85, 0.46), font)
	box.add_child(_end_score_row)
	box.move_child(_end_score_row, result_label.get_index() + 1)

	_end_record_label = Label.new()
	# ใช้ฟอนต์เริ่มต้นของเกม ไม่ใช่ฟอนต์รูน — ฟอนต์รูนไม่มีเครื่องหมาย "!" และย้อมสีทองไม่ได้ (สีฟ้าในตัวฟอนต์คูณทับ)
	_end_record_label.add_theme_font_size_override("font_size", 46)
	_end_record_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.46))
	_end_record_label.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.05))
	_end_record_label.add_theme_constant_override("outline_size", 6)
	_end_record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_end_record_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_record_label.visible = false
	box.add_child(_end_record_label)
	box.move_child(_end_record_label, _end_score_row.get_index())  # อยู่เหนือแถวคะแนน

	result_label.add_theme_font_size_override("font_size", 28)
	result_label.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.05))
	result_label.add_theme_constant_override("outline_size", 4)

func _add_score_column(row: HBoxContainer, title: String, color: Color, font: Font, scale: float = 1.0) -> Label:
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 0)
	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var value_label := Label.new()
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for label in [title_label, value_label]:
		label.add_theme_font_override("font", font)
		label.add_theme_color_override("font_color", color)
		label.add_theme_color_override("font_outline_color", Color(0.015, 0.025, 0.05))
		label.add_theme_constant_override("outline_size", 4)
	title_label.add_theme_font_size_override("font_size", int(26 * scale))
	value_label.add_theme_font_size_override("font_size", int(56 * scale))
	column.add_child(title_label)
	column.add_child(value_label)
	row.add_child(column)
	return value_label

func _show_end_screen(player_won: bool, decisive: bool) -> void:
	if decisive:
		_end_banner.texture = VICTORY_BANNER if player_won else DEFEAT_BANNER
		_end_banner.visible = true
	_end_score_value.text = str(_score)
	_end_high_value.text = str(StatsManager.high_score)
	_end_score_row.visible = true
	var half_height := 440.0
	if _is_pvp():
		_end_score_p2_value.text = str(_score_p2)
		_end_high_row.visible = true
		half_height = 490.0  # แถวสถิติสูงสุดเพิ่มอีกแถว
	# ป้าย + แถวคะแนนทำให้สูงกว่าเมนู pause ปกติ — ขยายแผงให้พอดีปุ่มทั้ง 3
	var record_text := _new_record_text()
	if record_text != "":
		_end_record_label.text = record_text
		_end_record_label.visible = true
		half_height += 30.0
		# กระพริบเบาๆ ให้เด่น — ต้องให้ tween ทำงานตอน paused ได้ (เมนูนี้อยู่ตอน tree.paused = true)
		var pulse := create_tween().set_loops()
		pulse.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		pulse.tween_property(_end_record_label, "modulate:a", 0.45, 0.6)
		pulse.tween_property(_end_record_label, "modulate:a", 1.0, 0.6)
	var panel: Panel = $UI/PauseMenu/PausePanel
	panel.custom_minimum_size = Vector2(600, half_height * 2.0)
	panel.offset_top = -half_height
	panel.offset_bottom = half_height

## ข้อความ NEW RECORD! ถ้าเกมนี้มีคะแนนที่สูงกว่าสถิติเดิมของโหมด (ว่างถ้าไม่ได้ทำลายสถิติ)
## โหมด PVP บอกด้วยว่าผู้เล่นคนไหนทำได้ — ถ้าทั้งสองคนทะลุสถิติเดิม นับคนที่คะแนนสูงกว่า
func _new_record_text() -> String:
	var best := maxi(_score, _score_p2) if _is_pvp() else _score
	if best <= 0 or best <= _record_at_start:
		return ""
	if not _is_pvp():
		return "NEW RECORD!"
	return "NEW RECORD! P%d" % (1 if _score >= _score_p2 else 2)

func _result_text(result: String, winner: int) -> String:
	match result:
		"checkmate":
			return "รุกฆาต! ฝ่าย%sชนะ" % ChessPiece.side_name(winner)
		"timeout":
			return "หมดเวลา! ฝ่าย%sชนะ" % ChessPiece.side_name(winner)
		"stalemate":
			return "อับ (Stalemate) — เสมอ"
		"insufficient_material":
			return "หมากไม่พอรุกฆาต — เสมอ"
		"fifty_move":
			return "ครบกฎ 50 ตา — เสมอ"
		"threefold_repetition":
			return "ซ้ำตำแหน่งเดิม 3 ครั้ง — เสมอ"
		_:
			return "จบเกม"

## สั่นหน้าจอตอนปะทะ — แรงสั่นตามดาเมจที่ตี (ฟังจาก signal Board.piece_attacked ที่มีอยู่แล้ว)
## สั่นเฉพาะ node "Main" (ตัวเอง) ซึ่งเป็น root ของฉากเกม — UI ไม่สั่นตามเพราะอยู่ใน CanvasLayer
## แยกต่างหาก ไม่ผูกกับ transform ของ Main
func _on_piece_attacked(attacker: ChessPiece, victim: ChessPiece, damage: float, killed: bool) -> void:
	if killed:
		if attacker.side == ChessPiece.Team.WHITE and victim.side == ChessPiece.Team.BLACK:
			StatsManager.record_kill()
			_award_score(CAPTURE_POINTS.get(victim.piece_kind, 0), ChessPiece.Team.WHITE)
		elif _is_pvp() and attacker.side == ChessPiece.Team.BLACK and victim.side == ChessPiece.Team.WHITE:
			_award_score(CAPTURE_POINTS.get(victim.piece_kind, 0), ChessPiece.Team.BLACK)
		_update_team_counts()
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
	_set_piece_bars_hidden(true)
	pause_menu.visible = true
	pause_menu.modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(pause_menu, "modulate:a", 1.0, PAUSE_FADE_DURATION)

## ซ่อน/แสดงหลอดเลือดบนตัวหมากทุกตัว — _process ของหมากหยุดตอน paused เลยต้องสั่งวาดใหม่เอง
func _set_piece_bars_hidden(hidden: bool) -> void:
	ChessPiece.hide_bars = hidden
	var pieces := board.get_node_or_null("Pieces")
	if pieces == null:
		return
	for piece in pieces.get_children():
		piece.queue_redraw()

## เฟดออกจากเมนู pause แล้วค่อยซ่อนจริงตอนจางหมด (ไม่ใช่ซ่อนทันที ไม่งั้นจะไม่เห็น fade เลย)
func _hide_pause_menu() -> void:
	_set_piece_bars_hidden(false)
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
	var turn_title := "YOUR TURN" if board.side_to_move == ChessPiece.Team.WHITE else "AI TURN"
	if GameManager.game_mode == "PVP":
		turn_title = "WHITE TURN" if board.side_to_move == ChessPiece.Team.WHITE else "BLACK TURN"
	timer_title_label.text = turn_title
	timer_label.text = "%02d:%02d" % [seconds / 60, seconds % 60]
	timer_label.modulate = Color(1.0, 0.35, 0.3) if seconds <= 5 else Color.WHITE

## ให้คะแนนฝ่ายที่กินหมาก — ฝ่ายขาว = ผู้เล่น 1 (และคะแนนเดียวของโหมด PVC), ฝ่ายดำ = ผู้เล่น 2 (เฉพาะ PVP)
func _award_score(points: int, side: int = ChessPiece.Team.WHITE) -> void:
	if points <= 0:
		return
	if side == ChessPiece.Team.BLACK:
		_score_p2 += points
		StatsManager.record_score(_score_p2)  # HIGH SCORE ใช้ร่วมกัน — คะแนนของใครสูงกว่าสถิติก็ทำลายสถิติเดียวกัน
	else:
		_score += points
		StatsManager.record_score(_score)
	_update_score_label()

func _update_score_label() -> void:
	score_label.text = "%02d" % _score
	_show_score_digits("%04d" % _score, $UI/ScorePanel/Frame2/Digits)  # At least four digits; larger scores fit the same row.
	high_score_label.text = "%02d" % StatsManager.high_score
	if _p2_score_digits != null:
		_show_score_digits("%04d" % _score_p2, _p2_score_digits)

## โหมด PVP: แสดงแผงคะแนนผู้เล่น 2 (node `UI/ScorePanelP2` ที่อยู่ใน main.tscn — ลากจัดตำแหน่งใน editor ได้)
## กับป้าย PLAYER 1 บนแผงของผู้เล่น 1 โหมดอื่นซ่อนทั้งคู่ HIGH SCORE ไม่แยก ใช้แผงเดียวร่วมกัน
func _setup_pvp_hud() -> void:
	var pvp := _is_pvp()
	$UI/ScorePanelP2.visible = pvp
	$UI/ScorePanel/Caption.visible = pvp
	if pvp:
		_p2_score_digits = $UI/ScorePanelP2/Frame2/Digits

## แสดงคะแนนด้วยรูปเลขรูนเรืองแสง (asset/digits) แทนตัวอักษร — score_label ยังเก็บข้อความไว้เป็นค่าจริง
func _show_score_digits(text: String, row: HBoxContainer) -> void:
	for child in row.get_children():
		row.remove_child(child)
		child.queue_free()
	for ch in text:
		var digit := TextureRect.new()
		digit.texture = load("res://asset/digits/%s.png" % ch)
		digit.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		digit.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		digit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		digit.size_flags_vertical = Control.SIZE_EXPAND_FILL
		digit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(digit)

## นับหมากที่เหลือจริงบนกระดานแยกฝั่งขาว/ดำ แล้วอัปเดตป้าย Our Team / Opponent Team
func _update_team_counts() -> void:
	var white_count := 0
	var black_count := 0
	for row in board.board_state:
		for piece in row:
			if not is_instance_valid(piece) or piece.hp <= 0.0:
				continue
			if piece.side == ChessPiece.Team.WHITE:
				white_count += 1
			else:
				black_count += 1
	our_team_label.text = "%02d" % white_count
	opponent_team_label.text = "%02d" % black_count
