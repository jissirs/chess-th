extends Node

## เก็บค่าที่ต้องรู้ข้ามฉาก: โหมดเกม และระดับความยาก AI (ตั้งจากหน้า Settings เซฟลงไฟล์)

const SETTINGS_PATH := "user://game_settings.cfg"

enum AIDifficulty { EASY, NORMAL, HARD }
const AI_DIFFICULTY_NAMES := ["EASY", "NORMAL", "HARD"]
## ความลึกการค้นหาของ AI (จำนวนครึ่งตาที่มองล่วงหน้า) ต่อระดับ — ยิ่งลึกยิ่งฉลาดแต่ยิ่งช้า
## EASY 1 = ดูแค่ตาตัวเอง, NORMAL 2 = ดูตอบโต้ของผู้เล่นด้วย (ค่าเดิมของเกม), HARD 3 = ดูต่ออีกชั้น
const AI_SEARCH_DEPTHS := [1, 2, 3]

var game_mode: String = "PVP"  # ค่าเริ่มต้น
var ai_difficulty: int = AIDifficulty.NORMAL

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		ai_difficulty = clampi(int(config.get_value("ai", "difficulty", AIDifficulty.NORMAL)), 0, AI_SEARCH_DEPTHS.size() - 1)

func set_ai_difficulty(level: int) -> void:
	ai_difficulty = clampi(level, 0, AI_SEARCH_DEPTHS.size() - 1)
	var config := ConfigFile.new()
	config.set_value("ai", "difficulty", ai_difficulty)
	config.save(SETTINGS_PATH)

func ai_search_depth() -> int:
	return AI_SEARCH_DEPTHS[ai_difficulty]
