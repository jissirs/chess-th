extends Control

@onready var progress_bar = $ProgressBar
@onready var loading_label = $Loading  # ปรับชื่อ node ตามจริงถ้าไม่ตรง

var loading_duration = 3.0  # เวลาที่ progress bar วิ่งเต็ม (วินาที)
var elapsed_time = 0.0
var bar_started = false

func _ready():
	progress_bar.visible = false  # ซ่อนไว้ก่อน
	progress_bar.value = 0

	# รอ 3 วินาทีก่อน ค่อยแสดง progress bar แล้วเริ่มขยับ
	await get_tree().create_timer(3.0).timeout

	progress_bar.visible = true  # โชว์ตอนนี้
	bar_started = true

func _process(delta):
	if bar_started:
		elapsed_time += delta
		var progress = (elapsed_time / loading_duration) * 100.0
		progress_bar.value = min(progress, 100.0)

		if progress >= 100.0:
			_on_loading_complete()

func _on_loading_complete():
	set_process(false)  # หยุดไม่ให้ _process ทำงานซ้ำ
	# เปลี่ยนไปหน้า MainMenu
	SceneTransition.change_scene("res://Scene/main_menu.tscn")
