extends Node

## เก็บสถิติสะสมตลอดการเล่น (ข้ามเกม/ข้ามเซสชัน)
## เซฟลงไฟล์ ConfigFile เหมือนที่ audio_manager.gd ทำกับค่าเสียง (ตอนที่ 10.2)

const SAVE_PATH := "user://stats.cfg"

## สถิติสูงสุดแยกตามโหมด: "PVC" = เล่นกับ AI, "PVP" = 2 ผู้เล่น (ใน PVP ผู้เล่นทั้งสองใช้ค่าเดียวกัน)
var high_scores: Dictionary = {"PVC": 0, "PVP": 0}
## high_score = สถิติของโหมดที่กำลังเล่น (GameManager.game_mode) — โค้ดเดิมที่อ่าน/เขียน high_score
## ตรงๆ (แผงคะแนน, เทสต์) จึงใช้ได้ต่อโดยไม่ต้องแก้ แต่ได้ค่าของโหมดที่ถูกต้องเสมอ
var high_score: int:
	get:
		return int(high_scores.get(GameManager.game_mode, 0))
	set(value):
		high_scores[GameManager.game_mode] = value
var total_kills: int = 0
var total_skills_used: int = 0
var games_played: int = 0
var games_won: int = 0
var games_lost: int = 0
var games_drawn: int = 0
## จำนวนเกม PVP ที่เล่นจบ — แยกจาก won/lost/drawn เพราะ PVP ไม่มี "ผู้เล่น" ฝ่ายตายตัว นับชนะ/แพ้ไม่ได้
var games_pvp: int = 0

## รายชื่อ achievement ที่ปลดล็อกแล้ว (เก็บเป็น key string) — ใช้กันไม่ให้แจ้งเตือนซ้ำ
var unlocked_achievements: Array = []

## ยิงตอนปลดล็อก achievement ใหม่ (ครั้งแรกเท่านั้น) — UI (main.gd) ฟังไว้โชว์ toast แจ้งเตือน
signal achievement_unlocked(title: String)

## เกณฑ์ achievement ทั้งหมด — เพิ่มตัวใหม่แค่เพิ่ม entry ในนี้ ไม่ต้องแก้โค้ดส่วนอื่นเลย
## ⚠️ ใช้ var ไม่ใช่ const เพราะ Callable (func(s): ...) ไม่ใช่ constant expression ใน GDScript
var ACHIEVEMENTS := [
	{"key": "first_blood", "title": "First Blood — ฆ่าศัตรูตัวแรก", "check": func(s): return s.total_kills >= 1},
	{"key": "slayer", "title": "Slayer — ฆ่าศัตรูสะสม 50 ตัว", "check": func(s): return s.total_kills >= 50},
	{"key": "skilled", "title": "Skilled — ใช้ Active Skill ครั้งแรก", "check": func(s): return s.total_skills_used >= 1},
	{"key": "tactician", "title": "Tactician — ใช้ Active Skill สะสม 20 ครั้ง", "check": func(s): return s.total_skills_used >= 20},
	{"key": "champion", "title": "Champion — ชนะ AI สะสม 10 เกม", "check": func(s): return s.games_won >= 10},
]

func _ready() -> void:
	_load()

func record_score(score: int) -> void:
	if score > high_score:
		high_score = score
		_save()

func record_kill() -> void:
	total_kills += 1
	_check_achievements()
	_save()

func record_skill_used() -> void:
	total_skills_used += 1
	_check_achievements()
	_save()

## บันทึกผลจบเกม — win_for_player: true=ผู้เล่นชนะ, false=แพ้, null=เสมอ
## pvp = true: เกม 2 ผู้เล่น นับแค่ games_played/games_pvp ไม่นับชนะ/แพ้/เสมอ
func record_game_ended(win_for_player, pvp: bool = false) -> void:
	games_played += 1
	if pvp:
		games_pvp += 1
	elif win_for_player == true:
		games_won += 1
	elif win_for_player == false:
		games_lost += 1
	else:
		games_drawn += 1
	_check_achievements()
	_save()

func _check_achievements() -> void:
	for entry in ACHIEVEMENTS:
		if entry.key in unlocked_achievements:
			continue
		if entry.check.call(self):
			unlocked_achievements.append(entry.key)
			achievement_unlocked.emit(entry.title)

func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("stats", "high_score_pvc", high_scores["PVC"])
	config.set_value("stats", "high_score_pvp", high_scores["PVP"])
	config.set_value("stats", "games_pvp", games_pvp)
	config.set_value("stats", "total_kills", total_kills)
	config.set_value("stats", "total_skills_used", total_skills_used)
	config.set_value("stats", "games_played", games_played)
	config.set_value("stats", "games_won", games_won)
	config.set_value("stats", "games_lost", games_lost)
	config.set_value("stats", "games_drawn", games_drawn)
	config.set_value("stats", "unlocked_achievements", unlocked_achievements)
	config.save(SAVE_PATH)

func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	# ไฟล์เซฟเก่ามีแค่ "high_score" ค่าเดียว (ตอนนั้นยังไม่แยกโหมด) — ย้ายไปเป็นสถิติของโหมด PVC
	var legacy: int = maxi(0, int(config.get_value("stats", "high_score", 0)))
	high_scores["PVC"] = maxi(0, int(config.get_value("stats", "high_score_pvc", legacy)))
	high_scores["PVP"] = maxi(0, int(config.get_value("stats", "high_score_pvp", 0)))
	games_pvp = config.get_value("stats", "games_pvp", 0)
	total_kills = config.get_value("stats", "total_kills", 0)
	total_skills_used = config.get_value("stats", "total_skills_used", 0)
	games_played = config.get_value("stats", "games_played", 0)
	games_won = config.get_value("stats", "games_won", 0)
	games_lost = config.get_value("stats", "games_lost", 0)
	games_drawn = config.get_value("stats", "games_drawn", 0)
	unlocked_achievements = config.get_value("stats", "unlocked_achievements", [])
