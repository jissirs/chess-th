# คู่มือสร้างเกมหมากรุก Chess TH ตั้งแต่ศูนย์

คู่มือนี้พาสร้างเกมตั้งแต่โปรเจกต์เปล่า **จับมือทำทีละขั้น พร้อมโค้ดเต็มทุกไฟล์**
เขียนแต่ละไฟล์ **ครั้งเดียวจบด้วยเวอร์ชันล่าสุดที่ใช้งานจริงในโปรเจกต์ ณ ตอนนี้** ไม่มีเวอร์ชันเก่า
ปนอยู่ ไม่ต้องแก้ย้อนไปย้อนมา — ทำตามลำดับ 0 → 12 ได้ผลลัพธ์ตรงกับโปรเจกต์ปัจจุบันเป๊ะๆ

> ⚠️ **นี่คือสแนปช็อตสถานะโปรเจกต์ ณ วันที่เขียน ไม่ใช่เกมที่เสร็จสมบูรณ์แล้ว**
> ทำครบ 12 ตอนแล้วจะได้หมากรุกที่**เล่นได้จริงครบกติกาสากล** พร้อม AI ที่รู้จักทั้งระบบเลือดและ
> passive skill, เพลง+เสียงเอฟเฟกต์ (เดิน/ตี/ตาย) ที่คุม volume แยก Music/SFX ได้จากหน้า Settings,
> ระบบเลือด (HP) แบบแฟนตาซีที่ตีหลายทีถึงตาย พร้อมเอฟเฟกต์ออร่าพลัง/ปะทะ/ตาย และ passive skill
> เฉพาะตัวของเรือ+ควีน+เบี้ย+ม้า — แต่ยังมีของที่ตั้งใจเว้นไว้ไม่ทำ (background ยังไม่ขยับสมจริง,
> passive ของบิชอป/คิงยังไม่มี, เสียงคลิก/UI/รุกฆาตยังไม่มี ฯลฯ) ดูรายการเต็มที่
> **"สิ่งที่คู่มือนี้ยังไม่ครอบคลุม"** ท้ายตอนที่ 12 — ถ้าโค้ดในโปรเจกต์จริงถูกแก้เพิ่มเติมทีหลัง
> คู่มือนี้อาจไม่ตรงกับล่าสุดอีกต่อไปจนกว่าจะอัปเดต

## ลำดับการทำ

| ตอน | ทำอะไร | ทดสอบได้ตอนจบ |
|---|---|---|
| [0](#ตอนที่-0--เตรียมตัว) | ติดตั้ง Godot, สร้างโปรเจกต์, เตรียม asset, ตั้งค่า | — |
| [1](#ตอนที่-1--autoload-2-ตัว) | `GameManager` + `SceneTransition` | — |
| [2](#ตอนที่-2--หน้า-loading) | จอโหลดมี progress bar | จอโหลดวิ่งจนเต็ม |
| [3](#ตอนที่-3--เมนูหลัก) | เมนูหลัก + ปุ่ม | Loading → fade → Menu |
| [4](#ตอนที่-4--สมองของเกม-กติกาหมากรุก) | `chess_piece.gd` + `chess_rules.gd` | — (โค้ดล้วน ยังไม่เห็นภาพ) |
| [5](#ตอนที่-5--กระดานเปอร์สเปกทีฟ) | `board.tscn` + `Board.gd` + `main.tscn` | เส้นตารางทับกระดานพอดี |
| [6](#ตอนที่-6--วางตัวหมากลงกระดาน) | `piece_spawner.gd` | เห็นหมาก 32 ตัวเรียงครบ |
| [7](#ตอนที่-7--คลิกเดินหมาก) | `click_to_move.gd` | **เล่นหมากรุกได้จริง!** |
| [8](#ตอนที่-8--ui-ฉากเกม-pause--จบเกม) | Pause menu + `main.gd` | กด Pause / เห็นผลจบเกม |
| [9](#ตอนที่-9--ai-โหมด-singleplayer) | `chess_ai.gd` + `ai_player.gd` | เล่นกับคอมได้ |
| [10](#ตอนที่-10--ระบบเสียง-audio-bus--หน้า-settings) | `AudioManager` (Autoload) + Audio Bus + หน้า Settings สไตล์หินรูน | ลาก slider แล้วเสียงเพลง/เอฟเฟกต์เปลี่ยนจริงแบบ real-time |
| [11](#ตอนที่-11--ระบบเลือด-hp--เอฟเฟกต์การต่อสู้แฟนตาซี) | เลือด (HP) + เอฟเฟกต์ปะทะ/ตาย + SFX + Passive Skill (เรือ/ควีน/เบี้ย/ม้า) + **Active Skill กดใช้เอง (ทุกชนิด)** | กินหมากแล้วแค่เลือดลด ต้องตีซ้ำถึงตายจริง, กดปุ่มสกิลเหนือหัวหมากใช้ท่าพิเศษได้ |
| [12](#ตอนที่-12--ตรวจงานครั้งสุดท้าย) | เช็คลิสต์ + แก้ปัญหาที่พบบ่อย | — |

---

## ตอนที่ 0 — เตรียมตัว

### 0.1 ติดตั้ง Godot

ดาวน์โหลด **Godot 4.7.1** (หรือใหม่กว่า) จาก [godotengine.org](https://godotengine.org) — เลือกเวอร์ชัน
**Standard** (ไม่ใช่ .NET/C# เพราะคู่มือนี้ใช้ GDScript ล้วน) ไฟล์เป็น .exe เดี่ยว ไม่ต้องติดตั้ง เปิดใช้ได้เลย

### 0.2 สร้างโปรเจกต์

1. เปิด Godot → **Create New Project**
2. ตั้งชื่อ `chess-th` เลือกโฟลเดอร์ที่ต้องการ
3. **Renderer**: เลือก `Forward+`
4. กด **Create & Edit**

### 0.3 สร้างโฟลเดอร์

ที่แผง **FileSystem** (ล่างซ้าย) คลิกขวาที่ `res://` → **Create Folder** ทำ 3 อัน:

```
res://
├── Scene/          ← ไฟล์ .tscn ทั้งหมด
├── script/         ← ไฟล์ .gd ทั้งหมด
└── asset/
	├── pieces/     ← รูปตัวหมาก
	└── audio/      ← เพลง
```

### 0.4 เตรียม asset ให้ครบ

ลากไฟล์รูปจาก File Explorer มาวางในแผง FileSystem ของ Godot ได้เลย (Godot จะ import ให้อัตโนมัติ)

**รูปทั้งหมดต้องเป็น PNG พื้นหลังโปร่งใส** ยกเว้นภาพพื้นหลังฉากที่เป็น JPG ได้

#### หน้า Loading
| ไฟล์ | คืออะไร |
|---|---|
| `asset/loading.jpg` | ภาพพื้นหลังจอโหลด |
| `asset/progressbar_under.png` | พื้นหลอด progress bar |
| `asset/progressbar_fill.png` | ส่วนที่วิ่งเติมในหลอด |

#### หน้าเมนูหลัก
| ไฟล์ | คืออะไร |
|---|---|
| `asset/mainmenu_bg .jpg` | ภาพพื้นหลังเมนู |
| `asset/singleplayer.png` + `asset/singleplayerbutton.png` | ปุ่ม Singleplayer (ปกติ + hover) |
| `asset/multiplayer.png` + `asset/multiplayerbutton.png` | ปุ่ม Multiplayer (ปกติ + hover) |
| `asset/setting.png` + `asset/settingbutton.png` | ปุ่ม Setting (ปกติ + hover) |
| `asset/quit.png` + `asset/Quitbutton.png` | ปุ่ม Quit (ปกติ + hover) |

#### ฉากเกม
| ไฟล์ | คืออะไร |
|---|---|
| `asset/bg.png` | ภาพกระดานหมากรุก **มุมกล้องเอียง (เปอร์สเปกทีฟ)** ไม่ใช่ตารางตรงๆ จากด้านบน |
| `asset/pausebutton.png` + `asset/pausebutton_hover.png` | ปุ่ม Pause วงกลม |
| `asset/resume.png` + `asset/resumebutton.png` | ปุ่ม Resume |
| `asset/restart.png` + `asset/restartbutton.png` | ปุ่ม Restart |
| `asset/mainmenu.png` + `asset/mainmenubutton.png` | ปุ่ม Main Menu |
| `asset/audio/{ชื่อเพลง}.mp3` | เพลงประกอบ |

#### ตัวหมาก (18 ไฟล์ — สำคัญมาก ชื่อต้องตรงเป๊ะ)

โค้ดจะประกอบชื่อไฟล์เองเป็น `{ชื่อ}_{ฝั่ง}.png` โดย `back` = ฝ่ายผู้เล่น (แถวล่าง เห็นด้านหลัง),
`front` = ฝ่ายศัตรู (แถวบน เห็นด้านหน้า)

```
asset/pieces/
├── king_back.png     king_front.png
├── queen_back.png    queen_front.png
├── rook_back.png     rook_front.png
├── bishop_back.png   bishop_front.png
├── knight_back.png   knight_front.png
├── soldier_crimson_back.png    soldier_crimson_front.png
├── soldier_purple_back.png     soldier_purple_front.png
├── soldier_runic1_back.png     soldier_goldfire_front.png
└── soldier_runic2_back.png     soldier_sapphie_front.png
```

> **ทำไมเบี้ยมี 4 สี?** เพื่อให้เบี้ย 8 ตัวในแถวเดียวกันดูไม่ซ้ำจำเจ โค้ดจะสลับสีวนไปตามคอลัมน์
> ฝั่ง back กับ front ใช้คนละชุดสีก็ได้ (ตามตารางด้านบน 2 สีท้ายต่างกัน) ไม่มีปัญหา
>
> **หมากทุกตัวต้องหันหน้าทางเดียวกัน** เพราะโค้ดไม่มีการ flip ภาพ

### 0.5 ตั้งค่า Project Settings

เมนูบนสุด **Project → Project Settings**

| หมวด | ตั้งค่า |
|---|---|
| General → Display → Window → **Viewport Width** | `1920` |
| General → Display → Window → **Viewport Height** | `1200` |
| General → Display → Window → Stretch → **Mode** | `canvas_items` |

### 0.6 เพิ่ม Input Action สำหรับปุ่ม Pause

ยังอยู่ในหน้า Project Settings → แท็บ **Input Map**

1. ช่อง **Add New Action** พิมพ์ `pause` → กด **Add**
2. หา action `pause` ที่เพิ่งสร้าง → กดปุ่ม **+** ด้านขวา
3. กดปุ่ม **Esc** บนคีย์บอร์ด → **OK**

> ถ้าข้ามขั้นนี้ พอถึงตอนที่ 8 จะ error ว่าไม่รู้จัก action `"pause"`

---

## ตอนที่ 1 — Autoload 2 ตัว

**Autoload** คือ node ที่มีอยู่ตลอดเวลา ไม่หายไปตอนเปลี่ยนฉาก เรียกใช้จากที่ไหนก็ได้ด้วยชื่อของมัน
เราต้องใช้ 2 ตัว: เก็บค่าข้ามฉาก (`GameManager`) และเปลี่ยนฉากแบบ fade (`SceneTransition`)

### 1.1 สร้าง `script/game_manager.gd`

คลิกขวาที่โฟลเดอร์ `script` → **Create New → Script** → ตั้งชื่อ `game_manager.gd` → **Create**

```gdscript
extends Node

var game_mode: String = "PVP"  # ค่าเริ่มต้น
```

จบแค่นี้จริงๆ — มันคือกล่องเก็บค่าเดียว ว่าผู้เล่นเลือกโหมดไหนจากเมนู เพื่อให้ฉากเกมอ่านต่อได้

### 1.2 สร้างฉาก `Scene/SceneTransition.tscn`

1. เมนู **Scene → New Scene**
2. ในแผง Scene กด **Other Node** → ค้นหา `CanvasLayer` → **Create**
3. เปลี่ยนชื่อ node เป็น `SceneTransition` (ดับเบิลคลิกที่ชื่อ)
4. คลิกขวาที่ `SceneTransition` → **Add Child Node** → `ColorRect` → ตั้งชื่อ `FadeRect`
5. คลิก `FadeRect` → แถบเครื่องมือบนวิวพอร์ต กด **Anchors Preset** (ไอคอนสี่เหลี่ยม) → เลือก **Full Rect**
6. ที่ Inspector ขวามือ → **Color** → ตั้งเป็นสีดำทึบ (R=0, G=0, B=0, A=255)
7. **Ctrl+S** เซฟเป็น `res://Scene/SceneTransition.tscn`

> ใช้ `CanvasLayer` เพราะมันวาดทับทุกอย่างในฉากเสมอ ไม่ว่าของข้างล่างจะตั้ง z_index เท่าไหร่

### 1.3 สร้าง `script/SceneTransition.gd`

คลิก node `SceneTransition` → ที่ Inspector หาไอคอน **สคริปต์** (กระดาษม้วน) ด้านบน → **Attach Script**
→ Path: `res://script/SceneTransition.gd` → **Create**

```gdscript
extends CanvasLayer

@onready var fade_rect = $FadeRect

func _ready():
	fade_rect.modulate.a = 0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # อย่าให้บังคลิกตอนโปร่งใส

func change_scene(path: String):
	# Fade to black
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished

	# เปลี่ยน scene ตอนจอมืดสนิท
	get_tree().change_scene_to_file(path)

	# Fade กลับมาโปร่งใส
	var tween2 = create_tween()
	tween2.tween_property(fade_rect, "modulate:a", 0.0, 0.5)
```

### 1.4 ลงทะเบียน Autoload ทั้ง 2 ตัว

**Project → Project Settings → แท็บ Globals → Autoload**

| Path | Node Name |
|---|---|
| `res://script/game_manager.gd` | `GameManager` |
| `res://Scene/SceneTransition.tscn` | `SceneTransition` |

กดไอคอนโฟลเดอร์เลือกไฟล์ → ตรวจว่าช่อง Node Name ตรงตามตาราง → กด **Add** ทีละอัน

> ⚠️ **ชื่อต้องตรงเป๊ะ** เพราะโค้ดตอนหลังเรียกตรงๆ ว่า `GameManager.game_mode` และ
> `SceneTransition.change_scene(...)` ถ้าพิมพ์ผิดจะ error ว่า `Identifier not declared`

---

## ตอนที่ 2 — หน้า Loading

### 2.1 สร้างฉาก `Scene/loading_screen.tscn`

1. **Scene → New Scene** → **User Interface** (สร้าง `Control` ให้อัตโนมัติ)
2. เปลี่ยนชื่อ node เป็น `LoadingScreen`
3. เลือก `LoadingScreen` → Anchors Preset → **Full Rect**

เพิ่ม node ลูก 2 ตัว (คลิกขวาที่ `LoadingScreen` → Add Child Node):

| ชื่อ node | ชนิด | ตั้งค่า |
|---|---|---|
| `Loading` | `Sprite2D` | Inspector → **Texture** ← ลาก `loading.jpg` มาวาง แล้วจัดตำแหน่ง/ขนาดให้เต็มจอ |
| `ProgressBar` | `TextureProgressBar` | ดูตารางถัดไป |

ตั้งค่า `ProgressBar` ที่ Inspector:

| ช่อง | ค่า |
|---|---|
| **Texture Under** | ลาก `progressbar_under.png` มาวาง |
| **Texture Over** | ลาก `progressbar_under.png` มาวาง (ตัวเดียวกัน) |
| **Texture Progress** | ลาก `progressbar_fill.png` มาวาง |

จัดตำแหน่งหลอดให้อยู่ตรงที่ต้องการด้วยการลากในวิวพอร์ต

**Ctrl+S** เซฟเป็น `res://Scene/loading_screen.tscn`

### 2.2 สคริปต์ `script/loading.gd`

Attach Script ที่ node `LoadingScreen` → `res://script/loading.gd`

```gdscript
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
```

### 2.3 ตั้งเป็นฉากเริ่มต้น

**Project → Project Settings → General → Application → Run → Main Scene**
→ เลือก `res://Scene/loading_screen.tscn`

### ✅ ทดสอบ

กด **F5** (Play) → เห็นภาพจอโหลดนิ่ง 3 วินาที → หลอดโผล่มาวิ่งจนเต็มใน 3 วินาที → จอ fade เป็นสีดำ
แล้ว error ว่าหา `main_menu.tscn` ไม่เจอ **(ปกติ! เพราะยังไม่ได้สร้าง — ทำในตอนถัดไป)**

---

## ตอนที่ 3 — เมนูหลัก

### 3.1 สร้างฉาก `Scene/main_menu.tscn`

**Scene → New Scene → User Interface** → เปลี่ยนชื่อ root เป็น `MainMenu`

เพิ่ม node ลูก:

```
MainMenu (Control)
├── MainmenuBg (Sprite2D)              ← Texture = mainmenu_bg .jpg
├── Singleplayerbutton (TextureButton)
├── multiplayerbutton  (TextureButton)
├── settingbutton      (TextureButton)
└── quitbutton         (TextureButton)
```

> ⚠️ **ชื่อ node ต้องตรงตามนี้เป๊ะ (ตัวพิมพ์เล็ก-ใหญ่ด้วย)** เพราะสคริปต์อ้างอิงชื่อตรงๆ

ตั้งค่าปุ่มทั้ง 4 อันเหมือนกันหมด ที่ Inspector:

| ช่อง | ค่า |
|---|---|
| **Texture Normal** | รูปปุ่มตอนปกติ (เช่น `singleplayer.png`) |
| **Texture Hover** | รูปปุ่มตอนเอาเมาส์ชี้ (เช่น `singleplayerbutton.png`) |
| **Ignore Texture Size** | ✅ ติ๊ก |
| **Stretch Mode** | `Keep Aspect Centered` |

> ติ๊ก **Ignore Texture Size** เพื่อให้ปรับขนาดปุ่มได้อิสระโดยลากในวิวพอร์ต ไม่ถูกล็อกตามขนาดรูปจริง
> และ **Keep Aspect Centered** กันภาพยืดผิดสัดส่วน

จัดตำแหน่งปุ่มตามใจ แล้ว **Ctrl+S** เซฟเป็น `res://Scene/main_menu.tscn`

### 3.2 สคริปต์ `script/main_menu.gd`

Attach Script ที่ node `MainMenu` → `res://script/main_menu.gd`

```gdscript
extends Control

func _ready():
	$Singleplayerbutton.pressed.connect(_on_singleplayer_pressed)
	$multiplayerbutton.pressed.connect(_on_multiplayer_pressed)
	$quitbutton.pressed.connect(_on_quit_pressed)
	# หมายเหตุ: $settingbutton ตั้งใจไม่ผูก signal ไว้ก่อน เพราะยังไม่มีหน้าตั้งค่าให้ไปเปิด
	# กดแล้วจะไม่มีอะไรเกิดขึ้น (เป็นงานที่ยังไม่ได้ทำ ดูภาคผนวกท้ายคู่มือ)

func _on_singleplayer_pressed():
	GameManager.game_mode = "PVC"
	SceneTransition.change_scene("res://Scene/main.tscn")

func _on_multiplayer_pressed():
	GameManager.game_mode = "PVP"
	SceneTransition.change_scene("res://Scene/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
```

### ✅ ทดสอบ

กด **F5** → Loading → fade → **เห็นเมนูหลัก** → เอาเมาส์ชี้ปุ่ม ต้องเปลี่ยนเป็นรูป hover →
กด Singleplayer/Multiplayer จะ fade แล้ว error หา `main.tscn` ไม่เจอ (ปกติ ยังไม่ได้สร้าง)
→ กด Quit ต้องปิดเกมได้

---

## ตอนที่ 4 — สมองของเกม (กติกาหมากรุก)

ตอนนี้เขียนโค้ดล้วน **ไม่ต้องสร้าง node หรือฉากใดๆ เลย** และยังไม่เห็นอะไรบนจอ
แต่เป็นหัวใจของทั้งเกม — ทำก่อนเพราะไฟล์อื่นๆ ทั้งหมดต้องพึ่งพาสองไฟล์นี้

### 4.1 `script/chess_piece.gd` — ข้อมูลหมาก 1 ตัว

คลิกขวาโฟลเดอร์ `script` → Create New → Script → `chess_piece.gd`

```gdscript
extends Sprite2D
class_name ChessPiece

## หมากหนึ่งตัวบนกระดาน เก็บทั้งข้อมูลเชิงกติกา (ชนิด / ฝ่าย / เคยเดินหรือยัง)
## และข้อมูลการแสดงผล (ขนาดพักปกติ ใช้ตอนย่อ-ขยายเวลาเลือก)
##
## กติกาทั้งหมดอยู่ใน chess_rules.gd — ไฟล์นี้เป็นแค่ "ข้อมูลของหมากตัวเดียว"

enum Kind { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }

## WHITE = ฝ่ายผู้เล่น อยู่แถวล่าง (row 7) ใช้ภาพชุด *_back.png
## BLACK = ฝ่ายศัตรู อยู่แถวบน (row 0) ใช้ภาพชุด *_front.png
enum Team { WHITE, BLACK }

var piece_kind: Kind = Kind.PAWN
var side: Team = Team.WHITE

## ใช้ตัดสินสิทธิ์ castling (คิง/เรือต้องยังไม่เคยเดิน) และเบี้ยเดิน 2 ช่อง
var has_moved: bool = false

## ขนาดปกติของ sprite ตัวนี้ ก่อนถูกขยายตอนถูกเลือก
## เก็บไว้เพื่อคืนค่าได้เป๊ะๆ ไม่ต้องหารกลับ (กันค่าเพี้ยนสะสมจาก float)
var resting_scale: Vector2 = Vector2.ONE

## ชื่อไฟล์ภาพของหมากแต่ละชนิด (เบี้ยมีหลายสี จึงจัดการแยกใน piece_spawner.gd)
static func art_name(kind: int) -> String:
	match kind:
		Kind.KNIGHT: return "knight"
		Kind.BISHOP: return "bishop"
		Kind.ROOK: return "rook"
		Kind.QUEEN: return "queen"
		Kind.KING: return "king"
		_: return "soldier"

## ส่วนท้ายชื่อไฟล์ตามฝ่าย: ผู้เล่นเห็นหลังตัวหมาก ศัตรูเห็นหน้าตัวหมาก
static func suffix_for(p_side: int) -> String:
	return "back" if p_side == Team.WHITE else "front"

static func side_name(p_side: int) -> String:
	return "ขาว" if p_side == Team.WHITE else "ดำ"
```

> ⚠️ **ห้ามตั้งชื่อ enum ว่า `Color`** — ชนกับ `Color` ที่ Godot มีอยู่แล้ว คอมไพล์ไม่ผ่าน จึงใช้ `Team`
>
> `class_name ChessPiece` ทำให้เรียกใช้จากไฟล์ไหนก็ได้โดยไม่ต้อง preload

### 4.2 `script/chess_rules.gd` — กติกาหมากรุกสากล

สร้างไฟล์ `script/chess_rules.gd`

ไฟล์นี้ยาวที่สุดในโปรเจกต์ แต่เป็น **static function ล้วนๆ ไม่ผูกกับ node เลย** — คัดลอกทั้งก้อนได้เลย

```gdscript
extends RefCounted
class_name ChessRules

## กติกาหมากรุกสากลทั้งหมด เป็น static function ล้วนๆ ไม่ผูกกับ node ใดๆ
## ทำให้เทสต์/เรียกใช้ซ้ำได้ง่าย และ Board.gd แค่เรียกใช้เป็น "สมอง" ของเกม
##
## รูปแบบ state: Array 8 แถว แต่ละแถวเป็น Array 8 ช่อง เก็บ ChessPiece หรือ null
## อ้างอิงช่องด้วย Vector2i(col, row) — x = col, y = row
##
## รองรับ: เดินตามชนิดหมาก, กิน, รุก (check), ห้ามเดินให้ตัวเองถูกรุก,
##         castling, en passant, promotion, รุกฆาต, อับ (stalemate),
##         หมากไม่พอชนะ (insufficient material), กฎ 50 ตา
## ยังไม่รองรับ: เสมอจากการเดินซ้ำ 3 ครั้ง (threefold repetition)

const COLS := 8
const ROWS := 8

const NO_CELL := Vector2i(-1, -1)

const KNIGHT_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, -1), Vector2i(1, -2),
	Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, 2),
]
const KING_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
]
const ROOK_DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
]
const BISHOP_DIRS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]


# ---------------------------------------------------------------- ตัวช่วยพื้นฐาน

static func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < COLS and cell.y >= 0 and cell.y < ROWS


static func at(state: Array, cell: Vector2i) -> ChessPiece:
	if not in_bounds(cell):
		return null
	return state[cell.y][cell.x]


static func opponent(p_side: int) -> int:
	return ChessPiece.Team.BLACK if p_side == ChessPiece.Team.WHITE else ChessPiece.Team.WHITE


## ทิศที่เบี้ยเดินไปข้างหน้า: ขาวอยู่แถวล่าง (row 7) จึงเดินขึ้นไปทาง row 0
static func forward(p_side: int) -> int:
	return -1 if p_side == ChessPiece.Team.WHITE else 1


## แถวเริ่มต้นของเบี้ย (แถวที่ยังเดิน 2 ช่องได้)
static func pawn_start_row(p_side: int) -> int:
	return 6 if p_side == ChessPiece.Team.WHITE else 1


## แถวปลายทางที่เบี้ยจะ promote
static func promotion_row(p_side: int) -> int:
	return 0 if p_side == ChessPiece.Team.WHITE else 7


static func empty_state() -> Array:
	var state: Array = []
	for row in range(ROWS):
		var row_data: Array = []
		for col in range(COLS):
			row_data.append(null)
		state.append(row_data)
	return state


## ก็อป state แบบตื้น — ตัว ChessPiece ยังเป็นตัวเดิม (เราแค่ย้ายตำแหน่งใน array
## ระหว่างจำลองตาเดิน ไม่ได้แก้ค่าอะไรในตัวหมาก จึงปลอดภัย)
static func copy_state(state: Array) -> Array:
	var out: Array = []
	for row in state:
		out.append((row as Array).duplicate())
	return out


# ------------------------------------------------------- ตาเดินดิบ (ยังไม่กรองรุก)

## ตาเดินที่ "ถูกต้องตามการเคลื่อนที่ของหมากชนิดนั้น" แต่ยังไม่ได้เช็คว่า
## เดินแล้วคิงตัวเองจะถูกรุกหรือไม่ — ใช้ legal_moves() ถ้าต้องการตาเดินที่ใช้ได้จริง
static func pseudo_moves(state: Array, from: Vector2i, ep_target: Vector2i, allow_castling: bool = true) -> Array:
	var piece := at(state, from)
	if piece == null:
		return []

	var moves: Array = []
	match piece.piece_kind:
		ChessPiece.Kind.PAWN:
			_add_pawn_moves(state, from, piece, ep_target, moves)
		ChessPiece.Kind.KNIGHT:
			_add_steps(state, from, KNIGHT_OFFSETS, piece.side, moves)
		ChessPiece.Kind.BISHOP:
			_add_rays(state, from, BISHOP_DIRS, piece.side, moves)
		ChessPiece.Kind.ROOK:
			_add_rays(state, from, ROOK_DIRS, piece.side, moves)
		ChessPiece.Kind.QUEEN:
			_add_rays(state, from, ROOK_DIRS, piece.side, moves)
			_add_rays(state, from, BISHOP_DIRS, piece.side, moves)
		ChessPiece.Kind.KING:
			_add_steps(state, from, KING_OFFSETS, piece.side, moves)
			if allow_castling:
				_add_castling(state, from, piece, moves)
	return moves


static func _add_pawn_moves(state: Array, from: Vector2i, piece: ChessPiece, ep_target: Vector2i, moves: Array) -> void:
	var dir := forward(piece.side)

	# เดินหน้า 1 ช่อง (ต้องว่าง) และ 2 ช่องถ้ายังอยู่แถวเริ่มต้นและว่างทั้งคู่
	var one := from + Vector2i(0, dir)
	if in_bounds(one) and at(state, one) == null:
		moves.append(one)
		var two := from + Vector2i(0, dir * 2)
		if from.y == pawn_start_row(piece.side) and in_bounds(two) and at(state, two) == null:
			moves.append(two)

	# กินทแยง 2 ข้าง — ต้องมีหมากฝ่ายตรงข้ามอยู่ หรือเป็นช่อง en passant
	for dx in [-1, 1]:
		var cap := from + Vector2i(dx, dir)
		if not in_bounds(cap):
			continue
		var target := at(state, cap)
		if target != null:
			if target.side != piece.side:
				moves.append(cap)
		elif cap == ep_target:
			moves.append(cap)


## หมากที่เดินทีละก้าว (ม้า, คิง)
static func _add_steps(state: Array, from: Vector2i, offsets: Array[Vector2i], p_side: int, moves: Array) -> void:
	for offset in offsets:
		var cell := from + offset
		if not in_bounds(cell):
			continue
		var target := at(state, cell)
		if target == null or target.side != p_side:
			moves.append(cell)


## หมากที่เดินเป็นเส้นยาวจนติดตัวอื่น (เรือ, บิชอป, ควีน)
static func _add_rays(state: Array, from: Vector2i, dirs: Array[Vector2i], p_side: int, moves: Array) -> void:
	for dir in dirs:
		var cell := from + dir
		while in_bounds(cell):
			var target := at(state, cell)
			if target == null:
				moves.append(cell)
			else:
				if target.side != p_side:
					moves.append(cell)  # กินได้ แต่ไปต่อไม่ได้
				break
			cell += dir


## Castling — เงื่อนไขครบตามกติกาสากล:
## คิงและเรือต้องยังไม่เคยเดิน, ช่องระหว่างกลางต้องว่างหมด,
## และคิงต้องไม่กำลังถูกรุก / ไม่เดินผ่าน / ไม่ไปหยุดบนช่องที่ถูกโจมตี
static func _add_castling(state: Array, from: Vector2i, king: ChessPiece, moves: Array) -> void:
	if king.has_moved:
		return
	if is_in_check(state, king.side):
		return

	var enemy := opponent(king.side)
	for corner in [0, COLS - 1]:
		var rook_col: int = corner
		var rook := at(state, Vector2i(rook_col, from.y))
		if rook == null or rook.side != king.side or rook.piece_kind != ChessPiece.Kind.ROOK or rook.has_moved:
			continue

		var step: int = 1 if rook_col > from.x else -1

		# ช่องระหว่างคิงกับเรือต้องว่างทั้งหมด
		var blocked := false
		var col: int = from.x + step
		while col != rook_col:
			if state[from.y][col] != null:
				blocked = true
				break
			col += step
		if blocked:
			continue

		var pass_cell := Vector2i(from.x + step, from.y)
		var dest := Vector2i(from.x + step * 2, from.y)
		if is_square_attacked(state, pass_cell, enemy):
			continue
		if is_square_attacked(state, dest, enemy):
			continue
		moves.append(dest)


# ------------------------------------------------------------------ การรุก (check)

## ช่องที่หมากตัวนี้ "โจมตีถึง" — ต่างจากตาเดินตรงที่เบี้ยโจมตีเฉพาะแนวทแยง
## (เดินหน้าตรงๆ ไม่นับเป็นการโจมตี) และคิงไม่นับ castling ป้องกันการเรียกวนซ้ำ
static func attack_squares(state: Array, from: Vector2i) -> Array:
	var piece := at(state, from)
	if piece == null:
		return []
	if piece.piece_kind == ChessPiece.Kind.PAWN:
		var dir := forward(piece.side)
		var out: Array = []
		for dx in [-1, 1]:
			var cell := from + Vector2i(dx, dir)
			if in_bounds(cell):
				out.append(cell)
		return out
	return pseudo_moves(state, from, NO_CELL, false)


static func is_square_attacked(state: Array, cell: Vector2i, by_side: int) -> bool:
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.side != by_side:
				continue
			if cell in attack_squares(state, Vector2i(col, row)):
				return true
	return false


static func find_king(state: Array, p_side: int) -> Vector2i:
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece != null and piece.side == p_side and piece.piece_kind == ChessPiece.Kind.KING:
				return Vector2i(col, row)
	return NO_CELL


static func is_in_check(state: Array, p_side: int) -> bool:
	var king_cell := find_king(state, p_side)
	if king_cell == NO_CELL:
		return false  # ไม่มีคิงบนกระดาน (เช่นตอนตั้งกระดานทดสอบ) ถือว่าไม่ถูกรุก
	return is_square_attacked(state, king_cell, opponent(p_side))


# --------------------------------------------------------------- ตาเดินที่ใช้ได้จริง

## จำลองการเดินบน state ก๊อปใหม่ (รวมผลข้างเคียงของ en passant และ castling)
## ไม่แตะ state เดิมและไม่แก้ค่าในตัวหมาก — ใช้สำหรับทดสอบว่าเดินแล้วคิงปลอดภัยไหม
static func apply(state: Array, from: Vector2i, to: Vector2i, ep_target: Vector2i) -> Array:
	var new_state := copy_state(state)
	var piece := at(state, from)
	if piece == null:
		return new_state

	# en passant: เบี้ยที่ถูกกินไม่ได้อยู่ช่องปลายทาง แต่อยู่ช่องข้างๆ ในแถวเดิม
	if piece.piece_kind == ChessPiece.Kind.PAWN and to == ep_target and at(state, to) == null:
		new_state[from.y][to.x] = null

	# castling: คิงขยับ 2 ช่อง แปลว่าต้องลากเรือมาอยู่ฝั่งตรงข้ามคิงด้วย
	if piece.piece_kind == ChessPiece.Kind.KING and absi(to.x - from.x) == 2:
		var rook_col: int = COLS - 1 if to.x > from.x else 0
		var rook_dest: int = to.x - 1 if to.x > from.x else to.x + 1
		new_state[from.y][rook_dest] = new_state[from.y][rook_col]
		new_state[from.y][rook_col] = null

	new_state[to.y][to.x] = piece
	new_state[from.y][from.x] = null
	return new_state


## ตาเดินที่ใช้ได้จริง = ตาเดินดิบ ที่กรองเอาตาที่ทำให้คิงตัวเองถูกรุกออกแล้ว
static func legal_moves(state: Array, from: Vector2i, ep_target: Vector2i) -> Array:
	var piece := at(state, from)
	if piece == null:
		return []
	var out: Array = []
	for to in pseudo_moves(state, from, ep_target):
		if not is_in_check(apply(state, from, to, ep_target), piece.side):
			out.append(to)
	return out


## ตาเดินทั้งหมดของฝ่ายหนึ่ง คืนเป็น Array ของ {"from": Vector2i, "to": Vector2i}
static func all_legal_moves(state: Array, p_side: int, ep_target: Vector2i) -> Array:
	var out: Array = []
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.side != p_side:
				continue
			var from := Vector2i(col, row)
			for to in legal_moves(state, from, ep_target):
				out.append({"from": from, "to": to})
	return out


## เช็คแบบลัด — เจอตาแรกก็หยุด เร็วกว่า all_legal_moves มากเวลาใช้ตัดสินรุกฆาต/อับ
static func has_legal_move(state: Array, p_side: int, ep_target: Vector2i) -> bool:
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.side != p_side:
				continue
			if not legal_moves(state, Vector2i(col, row), ep_target).is_empty():
				return true
	return false


# ------------------------------------------------------------------- สถานะของเกม

## หมากเหลือน้อยจนไม่มีทางรุกฆาตได้เลย → เสมอทันที
## ครอบคลุม: คิงเปล่า vs คิงเปล่า, คิง+บิชอป vs คิง, คิง+ม้า vs คิง,
##           และคิง+บิชอป vs คิง+บิชอป ที่บิชอปทั้งคู่อยู่ช่องสีเดียวกัน
static func insufficient_material(state: Array) -> bool:
	var minors: Array = []  # หมากที่ไม่ใช่คิง
	for row in range(ROWS):
		for col in range(COLS):
			var piece: ChessPiece = state[row][col]
			if piece == null or piece.piece_kind == ChessPiece.Kind.KING:
				continue
			# เบี้ย เรือ ควีน เหลืออยู่แม้ตัวเดียวก็ยังรุกฆาตได้ → ไม่เสมอ
			if piece.piece_kind != ChessPiece.Kind.BISHOP and piece.piece_kind != ChessPiece.Kind.KNIGHT:
				return false
			minors.append({"piece": piece, "cell": Vector2i(col, row)})

	if minors.size() <= 1:
		return true
	if minors.size() == 2:
		var a: Dictionary = minors[0]
		var b: Dictionary = minors[1]
		var both_bishops: bool = (a.piece as ChessPiece).piece_kind == ChessPiece.Kind.BISHOP \
			and (b.piece as ChessPiece).piece_kind == ChessPiece.Kind.BISHOP
		if both_bishops and (a.piece as ChessPiece).side != (b.piece as ChessPiece).side:
			var color_a: int = ((a.cell as Vector2i).x + (a.cell as Vector2i).y) % 2
			var color_b: int = ((b.cell as Vector2i).x + (b.cell as Vector2i).y) % 2
			return color_a == color_b
	return false


## สรุปสถานะกระดานสำหรับฝ่ายที่ถึงตาเดิน
## คืน {"check": bool, "result": String} โดย result == "" แปลว่าเกมยังไม่จบ
## ค่าอื่นที่เป็นไปได้: "checkmate", "stalemate", "insufficient_material", "fifty_move"
static func status(state: Array, side_to_move: int, ep_target: Vector2i, halfmove_clock: int) -> Dictionary:
	var check := is_in_check(state, side_to_move)
	var result := ""
	if not has_legal_move(state, side_to_move, ep_target):
		result = "checkmate" if check else "stalemate"
	elif insufficient_material(state):
		result = "insufficient_material"
	elif halfmove_clock >= 100:  # 50 ตาของทั้งสองฝ่าย = 100 halfmove
		result = "fifty_move"
	return {"check": check, "result": result}
```

### แนวคิดสำคัญที่ต้องเข้าใจ

| แนวคิด | อธิบาย |
|---|---|
| `pseudo_moves` vs `legal_moves` | pseudo = ถูกตามรูปแบบการเดินของหมากชนิดนั้น / legal = pseudo ที่กรองแล้วว่าเดินไปคิงตัวเองไม่โดนรุก (นี่คือที่มาของกฎ "หมากถูกตรึง" โดยไม่ต้องเขียนโค้ดพิเศษเลย) |
| ทำไม `attack_squares` แยกจาก `pseudo_moves` | เบี้ยเดินตรงแต่**กินทแยง** → ช่องที่มันเดินไม่ใช่ช่องที่มัน "คุม" ถ้าใช้ตัวเดียวกันจะคำนวณการรุกผิด |
| `allow_castling = false` ตอนเช็คการโจมตี | ไม่งั้น `_add_castling` → `is_in_check` → `attack_squares` → `_add_castling` เรียกวนไม่รู้จบ |
| `apply()` ไม่แก้ตัวหมาก | ก๊อปแค่ array ตัว `ChessPiece` ยังเป็น object เดิม → จำลองอนาคตได้ปลอดภัย ไม่ต้อง undo |

---

## ตอนที่ 5 — กระดานเปอร์สเปกทีฟ

ภาพกระดานเป็นภาพวาดมุมกล้องเอียง ช่องแถวบน (ไกลกล้อง) เล็กกว่าแถวล่าง (ใกล้กล้อง) มาก
เราต้องแปลงพิกัดตาราง 8×8 ในหน่วยตรรกะ → พิกัดจริงบนจอ ด้วยเทคนิค **homography**

วิธี: วาง `Marker2D` ทับมุมกระดานทั้ง 4 ในภาพ แล้วให้โค้ดคำนวณเอง

### 5.1 สร้างฉาก `Scene/board.tscn`

1. **Scene → New Scene → Other Node** → `Node2D` → ตั้งชื่อ `Board`
2. เพิ่ม node ลูก 4 ตัว ชนิด `Marker2D` ชื่อ: `TopLeft`, `TopRight`, `BottomLeft`, `BottomRight`
3. **Ctrl+S** เซฟเป็น `res://Scene/board.tscn`

### 5.2 สคริปต์ `script/Board.gd`

Attach Script ที่ node `Board` → `res://script/Board.gd`

```gdscript
@tool
extends Node2D
class_name board

## แปลงตาราง 8x8 ให้เข้ากับภาพกระดานเปอร์สเปกทีฟใน asset/bg.png
## Marker2D 4 มุมด้านล่างกำหนดรูปสี่เหลี่ยมคางหมู — ลากในเอดิเตอร์ให้ตรงกับภาพได้

const COLS := 8
const ROWS := 8

@export var show_debug_grid: bool = true

@onready var top_left: Marker2D = $TopLeft
@onready var top_right: Marker2D = $TopRight
@onready var bottom_left: Marker2D = $BottomLeft
@onready var bottom_right: Marker2D = $BottomRight

# board_state[row][col] เก็บ ChessPiece ที่อยู่ช่องนั้น หรือ null ถ้าว่าง
var board_state: Array = []

## เดินสำเร็จหนึ่งตา (ส่ง piece หลัง promote แล้ว ถ้ามีการ promote)
signal move_made(from_cell: Vector2i, to_cell: Vector2i, piece: ChessPiece)
## เปลี่ยนตาเดินเป็นอีกฝ่าย
signal turn_changed(side: int)
## ฝ่ายที่ถึงตาเดินกำลังถูกรุกอยู่
signal check_alerted(side: int)
## เกมจบ — result ดูค่าที่เป็นไปได้ใน ChessRules.status(), winner = -1 คือเสมอ
signal game_ended(result: String, winner: int)

var side_to_move: int = ChessPiece.Team.WHITE
## ช่องที่เบี้ยฝ่ายตรงข้ามเพิ่งเดินผ่านเมื่อตาที่แล้ว (กินผ่านได้เฉพาะตาถัดไปเท่านั้น)
var en_passant_target: Vector2i = ChessRules.NO_CELL
## นับตาที่ไม่มีการกินและไม่มีการเดินเบี้ย ใช้ตัดสินกฎ 50 ตา
var halfmove_clock: int = 0
var fullmove_number: int = 1
var game_over: bool = false
## [from, to] ของตาล่าสุด ว่างถ้ายังไม่มีใครเดิน
var last_move: Array = []
## true ระหว่างที่หมากกำลังเลื่อนด้วย animation — กันไม่ให้คลิกเดินซ้อนจนสถานะสับสน
var animating: bool = false

func _ready() -> void:
	_init_board_state()
	_reset_game_state()

func _init_board_state() -> void:
	board_state.clear()
	for row in range(ROWS):
		var row_data: Array = []
		for col in range(COLS):
			row_data.append(null)
		board_state.append(row_data)

func _reset_game_state() -> void:
	side_to_move = ChessPiece.Team.WHITE
	en_passant_target = ChessRules.NO_CELL
	halfmove_clock = 0
	fullmove_number = 1
	game_over = false
	last_move = []
	animating = false

## พิกัดจริงบนจอ ของจุดกึ่งกลางช่อง (col, row) นับจาก 0 ที่มุมบนซ้าย
func cell_to_world(col: int, row: int) -> Vector2:
	return _project(col + 0.5, row + 0.5)

## พิกัดจริงของจุดตัดเส้นตาราง; u อยู่ในช่วง [0, COLS], v อยู่ในช่วง [0, ROWS]
## ใช้การแปลงแบบ projective (homography) จากสี่เหลี่ยมหน่วยไปหา Marker2D ทั้งสี่
## ซึ่งเป็นวิธีที่ถูกต้องสำหรับภาพมุมกล้อง — ถ้าใช้ bilinear ธรรมดาเส้นตารางจะบิดเบี้ยวไม่ตรงภาพ
func _project(u: float, v: float) -> Vector2:
	var c := _homography_coeffs()
	var fu := u / float(COLS)
	var fv := v / float(ROWS)
	var denom: float = c.a13 * fu + c.a23 * fv + 1.0
	var x: float = (c.a11 * fu + c.a21 * fv + c.a31) / denom
	var y: float = (c.a12 * fu + c.a22 * fv + c.a32) / denom
	return Vector2(x, y)

## สูตรแปลงสี่เหลี่ยมหน่วย → สี่เหลี่ยมด้านไม่เท่า (Heckbert)
## p0=TL ที่ (0,0), p1=TR ที่ (1,0), p2=BR ที่ (1,1), p3=BL ที่ (0,1)
func _homography_coeffs() -> Dictionary:
	var p0 := top_left.global_position
	var p1 := top_right.global_position
	var p2 := bottom_right.global_position
	var p3 := bottom_left.global_position

	var dx1 := p1.x - p2.x
	var dx2 := p3.x - p2.x
	var dx3 := p0.x - p1.x + p2.x - p3.x
	var dy1 := p1.y - p2.y
	var dy2 := p3.y - p2.y
	var dy3 := p0.y - p1.y + p2.y - p3.y

	var a13 := 0.0
	var a23 := 0.0
	var det := dx1 * dy2 - dx2 * dy1
	if absf(dx3) > 0.0001 or absf(dy3) > 0.0001:
		if absf(det) > 0.0001:
			a13 = (dx3 * dy2 - dx2 * dy3) / det
			a23 = (dx1 * dy3 - dx3 * dy1) / det

	var a11 := p1.x - p0.x + a13 * p1.x
	var a21 := p3.x - p0.x + a23 * p3.x
	var a31 := p0.x
	var a12 := p1.y - p0.y + a13 * p1.y
	var a22 := p3.y - p0.y + a23 * p3.y
	var a32 := p0.y

	return {
		"a11": a11, "a21": a21, "a31": a31, "a13": a13,
		"a12": a12, "a22": a22, "a32": a32, "a23": a23,
	}

## 4 มุมของช่อง (col, row) ตามเปอร์สเปกทีฟจริงของกระดาน (ไม่ใช่สี่เหลี่ยมจัตุรัสตรงๆ
## เพราะกระดานเป็นภาพมุมกล้อง) เรียงตามเข็มนาฬิกาเริ่มจากมุมบนซ้าย ใช้วาดกรอบไฮไลต์ช่อง
func cell_corners(col: int, row: int) -> PackedVector2Array:
	return PackedVector2Array([
		_project(col, row),
		_project(col + 1, row),
		_project(col + 1, row + 1),
		_project(col, row + 1),
	])

## ช่องที่ใกล้พิกัดที่ระบุที่สุด (เช่นตำแหน่งเมาส์) คืน (-1,-1) ถ้ายังไม่พร้อม
func world_to_cell(world_pos: Vector2) -> Vector2i:
	if not (top_left and top_right and bottom_left and bottom_right):
		return Vector2i(-1, -1)
	var best_cell := Vector2i(-1, -1)
	var best_dist := INF
	for row in range(ROWS):
		for col in range(COLS):
			var dist := cell_to_world(col, row).distance_squared_to(world_pos)
			if dist < best_dist:
				best_dist = dist
				best_cell = Vector2i(col, row)
	return best_cell

# ------------------------------------------------------------------- ตัวคุมเกม
# Board เป็นเจ้าของทั้ง "สภาพกระดาน" และ "สถานะเกม" ส่วนกติกาอยู่ใน ChessRules
# และการวางตำแหน่ง/ขนาด sprite อยู่ใน piece_spawner.gd (node ลูกชื่อ Pieces)

## ตาเดินที่คลิกได้จริงของหมากในช่องนี้ — คืน [] ถ้าเป็นช่องว่าง
## เป็นหมากฝ่ายตรงข้าม หรือหมากตัวนั้นขยับไม่ได้เลย (เช่นถูกตรึงอยู่หน้าคิง)
func legal_moves_for(cell: Vector2i) -> Array:
	if game_over:
		return []
	var piece := ChessRules.at(board_state, cell)
	if piece == null or piece.side != side_to_move:
		return []
	return ChessRules.legal_moves(board_state, cell, en_passant_target)

## พยายามเดินหมากจาก from ไป to คืน true ถ้าเดินได้จริง
## promote_to ใช้เฉพาะตอนเบี้ยถึงแถวสุดท้าย (ค่าเริ่มต้นคือควีน)
##
## ลำดับขั้นตอนในฟังก์ชันนี้ตายตัว ห้ามสลับที่ เพราะแต่ละขั้นอิงผลจากขั้นก่อนหน้า:
##   1. อัปเดต board_state (ตรรกะเกม) ให้เสร็จทันทีทั้งหมดก่อน — ตัวเดิน + เรือ (ถ้า castling)
##   2. เริ่ม animation เลื่อนหมาก แล้ว await ให้เลื่อนเสร็จก่อนค่อยไปขั้นต่อไป
##      (กันไม่ให้ popup รุกฆาต/เช็ครุก โผล่ทับตอนหมากยังเลื่อนค้างอยู่)
##   3. หลังเลื่อนเสร็จ: promote (ถ้าเบี้ยถึงแถวสุดท้าย), อัปเดต en passant / 50 ตา / เปลี่ยนตา
##   4. ส่ง signal ให้ UI ไปอัปเดตทีหลังสุด
func try_move(from_cell: Vector2i, to_cell: Vector2i, promote_to: int = ChessPiece.Kind.QUEEN) -> bool:
	if animating or not (to_cell in legal_moves_for(from_cell)):
		return false

	var piece: ChessPiece = board_state[from_cell.y][from_cell.x]
	var is_pawn := piece.piece_kind == ChessPiece.Kind.PAWN
	var captured: ChessPiece = board_state[to_cell.y][to_cell.x]

	# ---------- ขั้นที่ 1: อัปเดต board_state (ตรรกะเกม) ให้ครบก่อน ----------

	# กินผ่าน (en passant): เบี้ยที่โดนกินอยู่ข้างๆ ไม่ใช่ช่องปลายทาง
	if is_pawn and to_cell == en_passant_target and captured == null:
		captured = board_state[from_cell.y][to_cell.x]
		board_state[from_cell.y][to_cell.x] = null

	# หมายเหตุ: ไม่ queue_free() เหยื่อทันทีตรงนี้ — ปล่อยให้ _play_capture() ด้านล่าง
	# จัดการทั้ง animation สะบัด/ล้ม และลบทิ้งจริงตอนแอนิเมชันจบ (ดูตอนที่ 10)

	var move_tweens: Array = []

	# castling: คิงขยับ 2 ช่อง ต้องลากเรือข้ามมาอยู่อีกฝั่งของคิงด้วย (เลื่อนพร้อมกับคิง)
	if piece.piece_kind == ChessPiece.Kind.KING and absi(to_cell.x - from_cell.x) == 2:
		var rook_col: int = COLS - 1 if to_cell.x > from_cell.x else 0
		var rook_dest: int = to_cell.x - 1 if to_cell.x > from_cell.x else to_cell.x + 1
		var rook: ChessPiece = board_state[from_cell.y][rook_col]
		board_state[from_cell.y][rook_col] = null
		board_state[from_cell.y][rook_dest] = rook
		rook.has_moved = true
		move_tweens.append(_place_visual(rook, Vector2i(rook_dest, from_cell.y), true))

	board_state[from_cell.y][from_cell.x] = null
	board_state[to_cell.y][to_cell.x] = piece
	piece.has_moved = true

	# มีการกิน → เล่น animation พุ่งเข้าปะทะ+เหยื่อล้ม (ตอนที่ 10) แทนการเดินตรงไปเฉยๆ
	if captured != null:
		move_tweens.append(_play_capture(piece, captured, to_cell))
	else:
		move_tweens.append(_place_visual(piece, to_cell, true))

	# ---------- ขั้นที่ 2: รอ animation เลื่อนหมากให้จบก่อน ----------
	animating = true
	for t in move_tweens:
		if t != null:
			await (t as Tween).finished
	animating = false

	# ---------- ขั้นที่ 3: หลังเลื่อนเสร็จแล้วเท่านั้น ค่อยจัดการส่วนที่เหลือ ----------

	# 3a) promote ก่อน (ถ้าเข้าเงื่อนไข) เพราะขั้นถัดไปอ้างอิง piece.side ซึ่งไม่เปลี่ยนอยู่แล้ว
	#     แต่ต้องได้ node ตัวหมากที่ถูกต้อง (ตัวใหม่หลัง promote) ไปใช้ตอน emit signal ท้ายฟังก์ชัน
	if is_pawn and to_cell.y == ChessRules.promotion_row(piece.side):
		piece = _promote(piece, to_cell, promote_to)

	# 3b) ตั้งช่อง en passant ให้ตาถัดไป เฉพาะตอนเบี้ยเพิ่งเดินรวด 2 ช่อง
	if is_pawn and absi(to_cell.y - from_cell.y) == 2:
		en_passant_target = Vector2i(from_cell.x, (from_cell.y + to_cell.y) / 2)
	else:
		en_passant_target = ChessRules.NO_CELL

	# 3c) กฎ 50 ตา: นับใหม่ทุกครั้งที่เดินเบี้ยหรือมีการกิน
	if is_pawn or captured != null:
		halfmove_clock = 0
	else:
		halfmove_clock += 1
	if side_to_move == ChessPiece.Team.BLACK:
		fullmove_number += 1

	# 3d) สลับตาเดิน — ต้องทำหลังสุดของขั้นนี้ เพราะ 3a-3c ยังอ้างอิง side_to_move ของฝ่ายที่เพิ่งเดิน
	last_move = [from_cell, to_cell]
	side_to_move = ChessRules.opponent(side_to_move)

	# ---------- ขั้นที่ 4: ส่ง signal ให้ UI ไปอัปเดต (ต้องมาหลังสุด) ----------
	move_made.emit(from_cell, to_cell, piece)
	turn_changed.emit(side_to_move)
	_evaluate_status()  # เช็ค check / รุกฆาต / อับ ด้วย side_to_move ที่อัปเดตแล้ว
	return true

func _evaluate_status() -> void:
	var state: Dictionary = ChessRules.status(board_state, side_to_move, en_passant_target, halfmove_clock)
	var result: String = state.result
	if result != "":
		game_over = true
		# รุกฆาตเท่านั้นที่มีผู้ชนะ กรณีอื่น (อับ / หมากไม่พอ / 50 ตา) คือเสมอ
		var winner: int = ChessRules.opponent(side_to_move) if result == "checkmate" else -1
		game_ended.emit(result, winner)
	elif state.check:
		check_alerted.emit(side_to_move)

## เปลี่ยนเบี้ยเป็นหมากตัวใหม่ คืน node ตัวใหม่ (ตัวเก่าถูกลบทิ้ง)
func _promote(pawn: ChessPiece, cell: Vector2i, kind: int) -> ChessPiece:
	var pieces := get_node_or_null("Pieces")
	if pieces == null or not pieces.has_method("spawn_piece"):
		return pawn
	var promoted: ChessPiece = pieces.spawn_piece(ChessPiece.art_name(kind), pawn.side, cell, kind)
	if promoted == null:
		return pawn
	promoted.has_moved = true
	pawn.queue_free()
	return promoted

## ให้ node Pieces จัดตำแหน่ง/ขนาด sprite ใหม่ตามช่องปลายทาง
## (ขนาดเปลี่ยนตามแถวด้วย เพราะกระดานเป็นเปอร์สเปกทีฟ แถวไกลกล้องช่องเล็กกว่า)
## animate = true คืน Tween ที่กำลังเลื่อนอยู่ ให้ try_move() await ต่อได้
func _place_visual(piece: ChessPiece, cell: Vector2i, animate: bool = false) -> Tween:
	var pieces := get_node_or_null("Pieces")
	if pieces != null and pieces.has_method("place_piece"):
		return pieces.place_piece(piece, cell, animate)
	return null

## ให้ node Pieces เล่น animation พุ่งเข้าปะทะ + เหยื่อล้มหาย (ฟังก์ชัน play_capture() อยู่ใน
## piece_spawner.gd — เขียนตอนที่ 6) ถ้าหา Pieces ไม่เจอ (ไม่ควรเกิด) ให้ fallback ลบเหยื่อทันที
## แล้วเดินแบบปกติ กันเกมค้าง — เหมือนแพตเทิร์นของ _promote() ด้านบนที่เรียก pieces.spawn_piece()
func _play_capture(attacker: ChessPiece, victim: ChessPiece, cell: Vector2i) -> Tween:
	var pieces := get_node_or_null("Pieces")
	if pieces != null and pieces.has_method("play_capture"):
		return pieces.play_capture(attacker, victim, cell)
	victim.queue_free()
	return _place_visual(attacker, cell, true)

func _process(_delta: float) -> void:
	if show_debug_grid and Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	# เส้นตารางนี้มีไว้ช่วยลากมุม Marker2D ให้ตรงกับภาพตอน edit เท่านั้น
	# ห้ามให้หลุดไปโชว์ตอนเล่นเกมจริง ไม่งั้นจะทับกรอบเรืองแสงและรกตา
	if not show_debug_grid or not Engine.is_editor_hint():
		return
	if not (top_left and top_right and bottom_left and bottom_right):
		return
	var color := Color(1, 0.15, 0.15, 0.65)
	for i in range(COLS + 1):
		draw_line(to_local(_project(i, 0)), to_local(_project(i, ROWS)), color, 2.0)
	for j in range(ROWS + 1):
		draw_line(to_local(_project(0, j)), to_local(_project(COLS, j)), color, 2.0)
```

> **`@tool` คืออะไร?** ทำให้สคริปต์รันในเอดิเตอร์ด้วย ไม่ใช่แค่ตอนเล่นเกม —
> เราต้องใช้เพื่อให้เห็นเส้นตารางแดงตอนลาก Marker2D จัดตำแหน่ง
> ส่วน `Engine.is_editor_hint()` ใน `_draw()` กันไม่ให้เส้นแดงหลุดไปโชว์ตอนเล่นเกมจริง

### 5.3 สร้างฉากเกม `Scene/main.tscn`

1. **Scene → New Scene → Other Node** → `Node2D` → ตั้งชื่อ `Main`
2. เพิ่ม `Sprite2D` ชื่อ `Background` → Texture = `bg.png` → ปรับ scale/position ให้เต็มจอ
3. เพิ่มฉาก `board.tscn` เข้ามา: กดไอคอน **โซ่ (Instantiate Child Scene)** ในแผง Scene →
   เลือก `res://Scene/board.tscn`
4. **Ctrl+S** เซฟเป็น `res://Scene/main.tscn`

### ✅ ทดสอบ — จัดมุมกระดานให้ตรง

กด **F6** (Run Current Scene) เพื่อรัน `main.tscn` โดยตรง — หรือดูในเอดิเตอร์ก็ได้เพราะมี `@tool`

ในเอดิเตอร์จะเห็น**เส้นตารางสีแดง 8×8** ทับอยู่บนภาพกระดาน — ถ้ายังไม่ตรง:
1. คลิก node `Board` → คลิกที่ Marker2D แต่ละตัวในวิวพอร์ต
2. **ลากมุมทั้ง 4 ให้ตรงกับมุมกระดานในภาพ**
3. เส้นตารางจะอัปเดตตามทันที ปรับจนเส้นทับช่องในภาพพอดี

> นี่คือขั้นตอนที่ต้องใช้สายตาปรับเอง ไม่มีค่าตายตัว เพราะขึ้นกับภาพกระดานที่คุณใช้

---

## ตอนที่ 6 — วางตัวหมากลงกระดาน

### 6.1 เพิ่ม node `Pieces`

เปิด `Scene/board.tscn` → คลิกขวาที่ `Board` → Add Child Node → `Node2D` → ตั้งชื่อ **`Pieces`**

> ⚠️ ชื่อต้องเป็น `Pieces` เป๊ะ เพราะ `Board.gd` หามันด้วย `get_node_or_null("Pieces")`

### 6.2 สคริปต์ `script/piece_spawner.gd`

Attach Script ที่ node `Pieces` → `res://script/piece_spawner.gd`

> ⚠️ โค้ดด้านล่างอ้างถึง `SlashEffect` (ในฟังก์ชัน `_spawn_slash_effect`) ซึ่งเป็นไฟล์ใหม่ที่ยัง
> ไม่ได้สร้าง — ถ้าเซฟตอนนี้ Godot จะขึ้น error สีแดงชั่วคราวว่าไม่รู้จัก `SlashEffect` **ไม่ต้องตกใจ**
> พิมพ์โค้ดให้ครบก่อนแล้วค่อยไปสร้าง `script/slash_effect.gd` ต่อใน STEP 6.3 ข้างล่าง error จะหายเอง

```gdscript
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

	var piece := ChessPiece.new()
	piece.name = "%s_%d_%d" % [art_name, cell.x, cell.y]
	piece.texture = tex
	piece.piece_kind = kind
	piece.side = side

	add_child(piece)
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

	# 2) จังหวะปะทะ: สั่งเหยื่อเริ่มสะบัด/ล้ม + โชว์รอยฟัน (รันแยก ไม่บล็อกคิวหลัก) แล้วหยุดนิ่งสั้นๆ
	tween.tween_callback(_play_victim_death.bind(victim))
	tween.tween_callback(_spawn_slash_effect.bind(victim.position))
	tween.tween_interval(IMPACT_HOLD)

	# 3) ผู้โจมตีเดินต่อไปช่องปลายทางตามปกติ (ease-out เหมือน place_piece ทั่วไป)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(attacker, "position", final_pos, MOVE_DURATION)
	tween.parallel().tween_property(attacker, "scale", final_scale, MOVE_DURATION)

	return tween

## สร้างเอฟเฟกต์รอยฟัน (SlashEffect) ที่ตำแหน่งปะทะ — วาดด้วยโค้ดล้วนๆ ไม่ต้องมี asset รูป
## เป็น node ชั่วคราวที่ลบตัวเองทิ้งอัตโนมัติหลังเล่นจบ (ดู slash_effect.gd ใน STEP 6.3)
func _spawn_slash_effect(at_position: Vector2) -> void:
	var slash := SlashEffect.new()
	slash.position = at_position
	add_child(slash)

## เหยื่อสะบัดหมุนไปทางสุ่ม (ซ้าย/ขวา) พร้อมเลื่อนลงเหมือนล้ม แล้วจางหายไป ก่อนถูกลบทิ้งจริง
## เป็น tween แยกจาก play_capture() โดยตั้งใจ — จะได้ไม่ต้องรอเหยื่อล้มเสร็จก่อนผู้โจมตีเดินต่อ
func _play_victim_death(victim: ChessPiece) -> void:
	if victim == null or not is_instance_valid(victim):
		return
	var death_tween := create_tween().set_parallel(true)
	death_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var spin_dir := 1.0 if randf() < 0.5 else -1.0  # สุ่มทิศทางสะบัด กันดูซ้ำจำเจทุกครั้งที่กิน
	death_tween.tween_property(victim, "rotation", spin_dir * deg_to_rad(100), VICTIM_FALL_DURATION)
	death_tween.tween_property(victim, "position:y", victim.position.y + 40.0, VICTIM_FALL_DURATION)
	death_tween.tween_property(victim, "modulate:a", 0.0, VICTIM_FALL_DURATION)
	death_tween.chain().tween_callback(victim.queue_free)

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
```

### 6.3 สร้าง `script/slash_effect.gd` — เอฟเฟกต์รอยฟันตอนกิน

คลิกขวาโฟลเดอร์ `script` → Create New → Script → `slash_effect.gd`

ไม่ต้องมี asset รูปใดๆ เลย — วาดด้วย `_draw()` ล้วนๆ เหมือนกรอบเรืองแสงใน `click_to_move.gd`
(ตอนที่ 7) เป็น node ชั่วคราวที่สร้างตัวเอง เล่นแอนิเมชันจบ แล้ว `queue_free()` ตัวเองทิ้งอัตโนมัติ
ไม่ต้องผูกกับ node ไหนในฉากล่วงหน้า:

```gdscript
extends Node2D
class_name SlashEffect

## เอฟเฟกต์รอยฟันตอนกิน — เส้นสว่างพาดขวางแบบฟันดาบ ไม่ต้องมี asset รูปใดๆ เลย
## วาดด้วย _draw() ล้วนๆ (สองเส้นซ้อนกัน: เส้นแกนกลางสว่างจ้า + เส้นขอบฟุ้งจางรอบนอก)
## แล้วขยายออกทางแนวนอนพร้อมจางหายอย่างรวดเร็ว จากนั้นลบตัวเองทิ้งอัตโนมัติ
##
## เรียกใช้จาก piece_spawner.gd:play_capture() ตอนจังหวะปะทะ (ดูฟังก์ชัน _spawn_slash_effect)

const LENGTH := 70.0
const WIDTH := 6.0
const DURATION := 0.18

func _ready() -> void:
	rotation = randf_range(-0.5, 0.5)  # เอียงมุมสุ่มเล็กน้อย กันดูซ้ำจำเจทุกครั้งที่กิน
	z_index = 5  # อยู่เหนือตัวหมากเสมอ (Pieces z_index = 1) ให้เห็นรอยฟันชัดไม่โดนบัง

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.6, 1.0), DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, DURATION).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func _draw() -> void:
	var half := LENGTH * 0.5
	var from := Vector2(-half, 0)
	var to := Vector2(half, 0)
	# เส้นขอบฟุ้งจาง (หนา สีอ่อน โปร่งใสบางส่วน) วาดก่อน แล้วทับด้วยเส้นแกนกลางสว่างจ้า
	# ซ้อนกันแบบนี้ได้ความรู้สึก "แสงฟุ้งรอบรอยฟัน" แบบเดียวกับกรอบไฮไลต์ใน click_to_move.gd
	draw_line(from, to, Color(1.0, 0.95, 0.6, 0.35), WIDTH * 2.5)
	draw_line(from, to, Color(1.0, 1.0, 0.9, 1.0), WIDTH)
```

> เพราะมี `class_name SlashEffect` เรียกใช้ `SlashEffect.new()` จากไฟล์ไหนก็ได้เลยโดยไม่ต้อง
> `preload()` — เหมือนกับ `ChessPiece`/`ChessRules`/`ChessAI` ที่ทำมาแล้วก่อนหน้านี้ พอสร้างไฟล์นี้
> เสร็จ error สีแดงที่ `piece_spawner.gd` เตือนไว้ใน STEP 6.2 จะหายไปเอง

### 3 เทคนิคสำคัญในไฟล์นี้

| เทคนิค | แก้ปัญหาอะไร |
|---|---|
| `y_sort_enabled = true` | หมากตัวสูงบังกันเอง — ต้องให้ตัวใกล้กล้อง (y มาก) วาดทับตัวไกล ไม่งั้นตัวหลังโผล่มาทับตัวหน้า |
| `FEET_OFFSET_RATIO` | วางให้ **เท้า** อยู่กลางช่อง ไม่ใช่ **กึ่งกลางรูป** ไม่งั้นตัวหมากจะดูลอยเหนือช่อง |
| `perspective_strength` | หมากแถวบนต้องเล็กกว่าแถวล่างตามเปอร์สเปกทีฟ แต่ไม่สุดโต่งจนแถวบนเล็กเกินมองไม่เห็น |
| `play_capture()` / `_play_victim_death()` | ตอนกิน ผู้โจมตีพุ่งเข้าหา**ตำแหน่งจริงของเหยื่อ** (`victim.position`) ก่อน 1 จังหวะสั้นๆ แล้วเหยื่อสะบัดหมุน+ล้ม+จางหายเป็น tween แยกอิสระ ไม่บล็อกผู้โจมตีให้รอ — ใช้ตำแหน่งเหยื่อจริงแทนช่องปลายทาง เพราะกินผ่าน (en passant) เหยื่ออยู่คนละช่องกับที่ผู้โจมตีไปจอด |
| `SlashEffect` (`slash_effect.gd`) | เอฟเฟกต์รอยฟันวาดด้วย `_draw()` ล้วนๆ ไม่ต้องมี asset รูป เป็น node ชั่วคราวที่ `queue_free()` ตัวเองหลังเล่นจบ — เทคนิคเดียวกับกรอบเรืองแสงใน `click_to_move.gd` แค่เอามาทำเป็น node แยกที่มีอายุสั้นๆ แทนการวาดค้างทุกเฟรม |

### ✅ ทดสอบ

กด **F6** รัน `main.tscn` → **เห็นหมาก 32 ตัวเรียงครบทั้งกระดาน**
ขนาดไล่จากเล็ก (แถวบน) → ใหญ่ (แถวล่าง) และยืนบนช่องพอดีไม่ลอย

**ถ้าไม่เห็นหมากเลย** → เปิดแผง **Output** ด้านล่าง ดูว่ามี warning `หารูปหมากไม่เจอ:` ไหม
ถ้ามีแปลว่าชื่อไฟล์รูปไม่ตรงกับที่โค้ดคาดไว้ (กลับไปเช็คตอนที่ 0.4)

---

## ตอนที่ 7 — คลิกเดินหมาก

### 7.1 เพิ่ม node `ClickToMove`

เปิด `Scene/board.tscn` → คลิกขวาที่ `Board` → Add Child Node → `Node2D` → ตั้งชื่อ `ClickToMove`

**ต้องอยู่ต่อจาก `Pieces` ในลำดับ** (ลากสลับได้ถ้าผิดลำดับ)

```
Board
├── TopLeft / TopRight / BottomLeft / BottomRight
├── Pieces          ← z_index = 1 (ตั้งในโค้ด)
└── ClickToMove     ← z_index = 0 (ค่าปกติ)
```

### 7.2 สคริปต์ `script/click_to_move.gd`

Attach Script ที่ node `ClickToMove` → `res://script/click_to_move.gd`

```gdscript
extends Node2D

## ระบบคลิกเดินหมาก — รับ input แล้วส่งต่อให้ Board.try_move() ตัดสิน
## กติกาทั้งหมดอยู่ใน chess_rules.gd ไฟล์นี้ไม่ตัดสินอะไรเองเลย
##
## คลิกหมากฝ่ายตัวเอง = เลือก (ขึ้นกรอบไฮไลต์ช่องที่เดินได้)
## คลิกช่องที่ไฮไลต์ = เดิน, คลิกช่องเดิม = ยกเลิก, คลิกหมากตัวอื่นของตัวเอง = เปลี่ยนไปเลือกตัวนั้น

const SELECTED_SCALE_MULT := 1.15  # ขยายหมากที่เลือกไว้เล็กน้อย ให้เห็นชัดว่าเลือกอยู่
const SELECT_DURATION := 0.32  # ระยะเวลาเด้งตอนเลือก/ยกเลิกเลือก

## หมากที่เบี้ยจะกลายเป็นตอนถึงแถวสุดท้าย
## TODO: ทำ UI ให้ผู้เล่นเลือกเองตอน promote (ตอนนี้เป็นควีนอัตโนมัติ)
@export var auto_promote_to: ChessPiece.Kind = ChessPiece.Kind.QUEEN

var selected_cell: Vector2i = ChessRules.NO_CELL
var legal_targets: Array = []

@onready var board: Node = get_parent()

func _ready() -> void:
	# กรอบไฮไลต์ต้องอยู่ "เหนือพื้นหลัง แต่ใต้ตัวหมาก" — z_index เทียบกันทั้งฉาก
	# ไม่ใช่แค่ในกลุ่มพี่น้อง ถ้าลด z ตัวเองต่ำกว่า 0 จะโดนพื้นหลังบังไปด้วย
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
	if board.game_over or board.animating or not _board_ready():
		return
	if GameManager.game_mode == "PVC" and board.side_to_move == ChessPiece.Team.BLACK:
		return  # ตาของ AI (ฝ่ายดำ) ในโหมด PVC ผู้เล่นคุมฝ่ายดำเองไม่ได้ (ดู ai_player.gd)
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

## วาดกรอบสี่เหลี่ยมเรืองแสงรอบช่อง (col, row) — ใช้มุมจริงตามเปอร์สเปกทีฟของกระดาน
## ทำเอฟเฟกต์เรืองแสงโดยวาดเส้นซ้อนกันหลายชั้น ชั้นนอกหนา-จางลงเรื่อยๆ ไปจนถึงชั้นในสุดที่คมชัด
func _draw_glow_quad(cell: Vector2i, color: Color) -> void:
	var corners: PackedVector2Array = board.cell_corners(cell.x, cell.y)
	var local_corners := PackedVector2Array()
	for point in corners:
		local_corners.append(to_local(point))
	local_corners.append(local_corners[0])  # ปิดกรอบให้ครบวง

	var glow_layers := [
		{"width": 16.0, "alpha": 0.12},
		{"width": 10.0, "alpha": 0.22},
		{"width": 5.0, "alpha": 0.45},
		{"width": 2.5, "alpha": 0.95},
	]
	for layer in glow_layers:
		draw_polyline(local_corners, Color(color.r, color.g, color.b, layer.alpha), layer.width, true)

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
```

### เทคนิคที่น่าสนใจในไฟล์นี้

**กรอบเรืองแสงโดยไม่ใช้ shader:** วาด `draw_polyline` ทับกัน 4 ชั้น ชั้นนอกสุดหนา 16px แต่จางมาก
(alpha 0.12) → ชั้นในสุดบาง 2.5px แต่ทึบ (alpha 0.95) ซ้อนกันได้ความรู้สึกแสงฟุ้งจากขอบ

**คลิกให้แม่น:** `world_to_cell()` หาแค่ช่องที่ศูนย์กลางใกล้เมาส์สุด ซึ่งใช้ไม่ได้กับหมากตัวสูง
(คลิกลำตัวจะไปโดนช่องแถวบน) จึง hit-test กรอบสี่เหลี่ยมของ sprite จริงก่อน แล้วค่อย fallback

### ✅ ทดสอบ — เล่นได้แล้ว!

กด **F6** รัน `main.tscn` แล้วลองทั้งหมดนี้:

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| คลิกหมากฝ่ายขาว (แถวล่าง) | เด้งขยายขึ้น + ขึ้นกรอบทองรอบตัว + กรอบเขียว/แดงตามช่องที่เดินได้ |
| คลิกช่องเขียว | หมากเลื่อนลื่นไปช่องนั้น |
| คลิกหมากฝ่ายดำ | คลิกไม่ติด (ยังไม่ถึงตาเขา) |
| เดินเบี้ย 2 ช่องตาแรก | ทำได้ / ตาที่ 2 เดินได้แค่ช่องเดียว |
| เอาหมากไปตรงหน้าคิงแล้วลองเลือก | ถ้าถูกตรึงจะเลือกไม่ได้เลย |
| ทำให้คิงถูกรุก | ขึ้นวงแหวนแดงรอบคิง |
| ลอง Fool's mate (รุกฆาตเร็ว) | เดินต่อไม่ได้แล้ว (แต่ยังไม่มี popup — ทำในตอนถัดไป) |
| เดินหมากไปกินหมากฝ่ายตรงข้าม (เช่น e4 → d5 → exd5) | ผู้โจมตีพุ่งเข้าหาเหยื่อไวๆ ก่อน 1 จังหวะ พร้อมเห็นเส้นสว่างพาดขวาง (รอยฟัน) ตรงจุดปะทะ แล้วเหยื่อสะบัดหมุน+ล้ม+จางหาย จากนั้นผู้โจมตีเดินต่อจนถึงช่องปลายทาง |

---

## ตอนที่ 8 — UI ฉากเกม (Pause + จบเกม)

### 8.1 เพิ่ม UI ใน `main.tscn`

เปิด `Scene/main.tscn` → คลิกขวาที่ `Main` → Add Child Node → `CanvasLayer` → ตั้งชื่อ `UI`

สร้างโครงนี้ใต้ `UI`:

```
UI (CanvasLayer)
├── PauseButton (TextureButton)        ← Process Mode = Always
└── PauseMenu (Control)                ← Process Mode = Always
    ├── DimBackground (ColorRect)      ← Full Rect, สีดำโปร่ง ~72%
    └── PausePanel (Panel)             ← Anchors = Center
        └── VBoxContainer              ← Full Rect, Alignment = Center
            ├── Label
            ├── Resume   (TextureButton)
            ├── Restart  (TextureButton)
            └── MainMenu (TextureButton)
```

**ตั้งค่าสำคัญ:**

| Node | ช่อง | ค่า |
|---|---|---|
| `PauseButton` | Texture Normal / Hover | `pausebutton.png` / `pausebutton_hover.png` |
| `PauseButton` | Offset | ตั้งให้อยู่มุมซ้ายบน เช่น Left=20, Top=20, Right=140, Bottom=140 |
| `Resume` | Texture Normal / Hover | `resume.png` / `resumebutton.png` |
| `Restart` | Texture Normal / Hover | `restart.png` / `restartbutton.png` |
| `MainMenu` | Texture Normal / Hover | `mainmenu.png` / `mainmenubutton.png` |
| ปุ่มทั้ง 4 | Ignore Texture Size | ✅ ติ๊ก |
| ปุ่มทั้ง 4 | Stretch Mode | `Keep Aspect Centered` |
| ปุ่มใน VBox 3 อัน | Custom Minimum Size | `360 × 120` |
| ปุ่มใน VBox 3 อัน | Size Flags Horizontal | `Shrink Center` |
| `PauseMenu` | **Visible** | ❌ **เอาติ๊กออก** (ซ่อนตอนเริ่ม) |

> ⚠️ **`Process Mode = Always` สำคัญมาก** ตั้งที่ `PauseButton` และ `PauseMenu`
> (Inspector → หมวด Node → Process → Mode) ไม่งั้นพอสั่ง `get_tree().paused = true`
> **ปุ่มในเมนู pause จะกดไม่ได้เลย** เพราะโดนหยุดไปพร้อมกับเกม

### 8.2 สคริปต์ `script/main.gd`

Attach Script ที่ node `Main` → `res://script/main.gd`

```gdscript
extends Node2D

@onready var board: Node = $Board
@onready var pause_menu: Control = $UI/PauseMenu
@onready var result_label: Label = $UI/PauseMenu/PausePanel/VBoxContainer/Label
@onready var resume_button: TextureButton = $UI/PauseMenu/PausePanel/VBoxContainer/Resume

## เกมจบแล้วหรือยัง — ใช้กันไม่ให้ปุ่ม Resume โผล่กลับมาตอนกด pause หลังเกมจบ
var _finished: bool = false

func _ready():
	pause_menu.visible = false
	result_label.text = ""
	$UI/PauseButton.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	$UI/PauseMenu/PausePanel/VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	$UI/PauseMenu/PausePanel/VBoxContainer/MainMenu.pressed.connect(_on_main_menu_pressed)

	board.game_ended.connect(_on_game_ended)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		_on_pause_pressed()

func _on_pause_pressed():
	if _finished:
		return  # เกมจบแล้ว เมนูค้างอยู่ ไม่มีอะไรให้ pause
	result_label.text = ""
	pause_menu.visible = true
	get_tree().paused = true

func _on_resume_pressed():
	pause_menu.visible = false
	get_tree().paused = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false          # ต้องคืนค่าก่อน เปลี่ยนฉากตอน paused=true จะค้าง
	SceneTransition.change_scene("res://Scene/main_menu.tscn")

func _on_game_ended(result: String, winner: int) -> void:
	_finished = true
	result_label.text = _result_text(result, winner)
	resume_button.visible = false  # เกมจบแล้ว เล่นต่อไม่ได้ เหลือแค่ Restart / Main Menu
	pause_menu.visible = true
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
```

> **จุดที่พลาดง่าย:** ต้องสั่ง `get_tree().paused = false` **ก่อน** เรียก `change_scene()` เสมอ
> เพราะ `SceneTransition.change_scene()` มี `await tween.finished` อยู่ ถ้า tree ยัง paused
> tween จะไม่ขยับเลย → จอค้างไม่เปลี่ยนฉาก (เหตุผลเดียวกับที่ `_on_restart_pressed` ต้องคืนก่อน)
>
> **เคล็ดลับ:** เราใช้ `PausePanel` ตัวเดิมแสดงผลจบเกมด้วย ไม่ต้องสร้าง popup ใหม่ — แค่ซ่อนปุ่ม Resume

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| กดปุ่ม Pause มุมซ้ายบน (หรือ Esc) | เมนูโผล่ เกมหยุด ปุ่มกดได้ |
| กด Resume | เมนูหาย เล่นต่อได้ |
| กด Restart | กระดานเริ่มใหม่ |
| กด Main Menu | fade กลับไปหน้าเมนูหลัก |
| เล่นจนรุกฆาต | เมนูโผล่พร้อมข้อความ "รุกฆาต! ฝ่ายขาวชนะ" และไม่มีปุ่ม Resume |

---

## ตอนที่ 9 — AI (โหมด Singleplayer)

ตอนนี้กด Singleplayer จากเมนูก็ยังเล่นเหมือน PVP (คุมเองทั้ง 2 ฝ่าย) เพราะยังไม่มีใครอ่าน
`GameManager.game_mode` ไปใช้ — ตอนนี้เราจะเติมส่วนที่ขาด

แยกเป็น 2 ไฟล์ตามหลักการเดิม: **สมอง** (ตัดสินใจ ไม่ผูก node) แยกจาก **มือ** (สั่งงาน ผูก node)

### 9.1 `script/chess_ai.gd` — สมองของ AI (เวอร์ชัน HP-aware)

> ⚠️ **โค้ดนี้ต้องมีระบบเลือด (HP) ในหมากอยู่ก่อนแล้ว** (`piece.hp`, `piece.max_hp`,
> `piece.attack_power` ใน `chess_piece.gd` และ logic "ตีไม่ตายไม่ขยับเข้าไปแทนที่" ใน
> `Board.try_move()`) — ระบบนี้เป็นการต่อยอดหมากรุกให้กลายเป็นเกมต่อสู้ที่ต้องตีสะสมดาเมจ
> หลายครั้งกว่าจะกินตาย แทนที่จะกินตายทันทีทีเดียวแบบหมากรุกปกติ **ขั้นตอนสร้างระบบเลือดทั้งหมด**
> (หลอดเลือด, ตัวเลขดาเมจลอย, เอฟเฟกต์แตกกระจายตอนตาย ฯลฯ) **อยู่ใน [ตอนที่ 11](#ตอนที่-11--ระบบเลือด-hp--เอฟเฟกต์การต่อสู้แฟนตาซี)**
> ต่างหาก — ทำตอนที่ 11 ให้เสร็จก่อนถ้าจะไล่ทำคู่มือนี้ตามลำดับจริงๆ (ตอนที่ 9 นี้เขียนไว้ก่อน
> ตามลำดับเลข แต่โค้ด "สมอง AI" ในนี้พึ่งพาผลลัพธ์ของตอนที่ 11 — เป็นข้อจำกัดของการเรียงลำดับ
> คู่มือที่ยังไม่ได้แก้ ท่อนนี้แค่บันทึกไว้ว่า "สมอง AI" หน้าตาเป็นแบบนี้เมื่อรู้จักระบบเลือดแล้ว)

**ปัญหาที่ต้องระวังเป็นพิเศษ:** `ChessRules.copy_state()` ที่ใช้จำลองอนาคตก็อปแค่ตื้นๆ —
ตัว `ChessPiece` ข้างในยังเป็น object เดิมของเกมจริงทุกตัว **ห้ามแก้ `piece.hp` ตรงๆ ระหว่าง
ค้นหาเด็ดขาด** (จะไปแก้เลือดจริงของหมากในเกมโดยไม่ตั้งใจ) ต้องจำลองเลือดแยกด้วย `Dictionary`
ต่างหาก (คีย์เป็นตัว `ChessPiece` เอง แม็ปไปหา "เลือดจำลอง" ของกิ่งการค้นหานั้น)

```gdscript
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

	var remaining_hp: float = _effective_hp(captured, hp_overrides) - piece.attack_power
	var lethal := remaining_hp <= 0.0

	if lethal:
		# ตายจริง — เหมือนเดิมทุกอย่าง ใช้ ChessRules.apply() ได้เลย (ลบเหยื่อ + ย้ายผู้โจมตีให้แล้ว)
		new_overrides.erase(captured)  # ตายแล้วไม่ต้องมีสถานะเลือดค้างให้จำต่อในสายนี้อีก
		return {"state": ChessRules.apply(state, from, to, ep_target), "overrides": new_overrides}

	# ไม่ตาย — board_state ไม่เปลี่ยนเลย (เหมือน Board.try_move() ตอน piece_moved = false:
	# ผู้โจมตีไม่ขยับเข้าไปแทนที่ เหยื่อยังยืนอยู่ที่เดิม) มีแค่เลือดจำลองของเหยื่อที่ลดลง
	new_overrides[captured] = remaining_hp
	return {"state": ChessRules.copy_state(state), "overrides": new_overrides}

## หาตาเดินที่ดีที่สุดสำหรับฝ่าย side ที่ความลึก depth ชั้น
## คืน {} ถ้าไม่มีตาเดินให้เลือกเลย (ไม่ควรเกิด เพราะ Board._evaluate_status ควรจับจบเกมได้ก่อนแล้ว)
static func best_move(state: Array, side: int, ep_target: Vector2i, depth: int = 2) -> Dictionary:
	var moves: Array = ChessRules.all_legal_moves(state, side, ep_target)
	if moves.is_empty():
		return {}

	var maximizing := side == ChessPiece.Team.BLACK
	var best_score: float = -INF if maximizing else INF
	var best_moves: Array = []  # เก็บทุกตาที่คะแนนเท่ากับดีที่สุด แล้วค่อยสุ่มเลือก 1 อัน

	for move in moves:
		# เริ่มจาก overrides ว่างเปล่า (ตอนนี้ยังไม่มีการจำลองใดๆ มาก่อนหน้า) piece.hp จริงยังเชื่อถือได้
		var result := _apply_hp_aware(state, move.from, move.to, ep_target, {})
		var score := _minimax(result.state, depth - 1, ChessRules.opponent(side), -INF, INF, result.overrides)
		var better: bool = score > best_score if maximizing else score < best_score
		if better:
			best_score = score
			best_moves = [move]
		elif score == best_score:
			best_moves.append(move)

	# สุ่มในบรรดาตาที่ดีที่สุดเท่าๆ กัน กัน AI เดินซ้ำแบบเดิมทุกครั้งที่เจอสถานการณ์เดียวกัน
	return best_moves[randi() % best_moves.size()]

## minimax แบบมี alpha-beta pruning ตัดกิ่งที่รู้แล้วว่าอีกฝ่ายไม่มีทางเลือกมา
## side คือฝ่ายที่ "กำลังจะเดิน" ในชั้นนี้ (สลับไปมาทุกชั้นตามธรรมชาติของเกม)
## hp_overrides ไล่ตามการจำลองไปทุกชั้น เก็บเลือดจำลองสะสมของทุกตัวที่เคยโดนตีในสายนี้
static func _minimax(state: Array, depth: int, side: int, alpha: float, beta: float, hp_overrides: Dictionary) -> float:
	if depth <= 0:
		return material_score(state, hp_overrides)

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
```

> **alpha-beta pruning คืออะไร?** วิธีตัดกิ่งการค้นหาที่รู้แน่นอนแล้วว่าอีกฝ่ายไม่มีทางยอมให้เกิดขึ้น
> ผลลัพธ์สุดท้ายเหมือนไม่ตัดเป๊ะๆ (ไม่ใช่การประมาณ) แต่เร็วกว่ามาก
> depth 2 ยังไม่จำเป็นเท่าไหร่ แต่ใส่ไว้ก่อนเพื่อให้ขยับเป็น depth 3-4 ทีหลังได้โดยไม่ต้องรื้อ

**✅ ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):**
ตีหมากเลือดเต็มด้วยดาเมจไม่พอ 1 ครั้ง → กระดานไม่เปลี่ยน ผู้โจมตีไม่ขยับ, เลือดจำลองลดถูกต้อง
ตามสูตร (`เดิม - attack_power`) พอตีซ้ำจนดาเมจสะสมพอ → การกินเกิดขึ้นจริงตามปกติ และรัน
`ChessAI.best_move()` ต่อกัน 20 ครึ่งตาไม่มีตาเดินผิดกติกาหรือ crash แม้แต่ครั้งเดียว

### 9.2 `script/ai_player.gd` — มือของ AI

```gdscript
extends Node

## เดินให้ฝ่ายศัตรู (ดำ) อัตโนมัติเมื่อ GameManager.game_mode == "PVC"
## ผูกสคริปต์นี้กับ node ลูกของ Board (เช่นชื่อ "AIPlayer") เหมือน click_to_move.gd
## กติกาการเลือกตาเดินอยู่ใน chess_ai.gd ไฟล์นี้แค่ "ฟังจังหวะ" แล้วสั่ง Board.try_move()

const AI_SIDE := ChessPiece.Team.BLACK
## ความลึกการมองล่วงหน้า (จำนวนครึ่งตาที่ AI จำลองไปข้างหน้า) ยิ่งมากยิ่งฉลาดแต่ยิ่งช้า
## depth 2 = มองตาตัวเอง + ตาตอบโต้ของคู่แข่ง เพียงพอสำหรับ AI ระดับเล่นสนุกๆ ไม่หน่วงจนรู้สึกได้
const SEARCH_DEPTH := 2
## หน่วงเวลาก่อนเดิน ให้ความรู้สึกเหมือน "กำลังคิด" ไม่ใช่เดินทันทีจนดูเหมือนบั๊ก
const THINK_DELAY := 0.5

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

	var move: Dictionary = ChessAI.best_move(board.board_state, AI_SIDE, board.en_passant_target, SEARCH_DEPTH)
	if move.is_empty():
		return  # ไม่มีตาเดิน (ไม่ควรเกิด เพราะ Board._evaluate_status ควรจับจบเกมได้ก่อนหน้านี้แล้ว)
	board.try_move(move.from, move.to)
```

### 9.3 เพิ่ม node `AIPlayer`

เปิด `Scene/board.tscn` → คลิกขวาที่ `Board` → Add Child Node → **`Node`** (ไม่ใช่ Node2D
เพราะไม่ต้องวาดอะไร) → ตั้งชื่อ `AIPlayer` → Attach Script `res://script/ai_player.gd`

```
Board
├── TopLeft / TopRight / BottomLeft / BottomRight
├── Pieces
├── ClickToMove
└── AIPlayer        ← เพิ่มใหม่
```

> **ทำไม AI ต้องเป็นฝ่ายดำเสมอ?** ผู้เล่นสปอว์นที่แถวล่างเป็นฝ่ายขาว (ดูตอนที่ 6)
> และฝ่ายขาวเดินก่อนเสมอตามกติกาสากล จึงล็อกไว้ตรงๆ ไม่ต้องอ่านจาก config

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เมนูหลัก → **Singleplayer** → เดินฝ่ายขาว | รอ ~0.5 วิ แล้วฝ่ายดำเดินเองอัตโนมัติ พร้อม animation เลื่อนเหมือนที่เราเดิน |
| ลองคลิกหมากฝ่ายดำ | คลิกไม่ติดเลย |
| เมนูหลัก → **Multiplayer** | ต้องคุมได้ทั้ง 2 ฝ่ายเหมือนเดิม (AI ไม่ยุ่ง) |

---

## ตอนที่ 10 — ระบบเสียง (Audio Bus) + หน้า Settings

ต่างจากแค่วาง `AudioStreamPlayer` แล้วติ๊ก Autoplay เฉยๆ — ตอนนี้เราทำระบบที่**คุมระดับเสียงเพลง
(Music) กับเอฟเฟกต์ (SFX) แยกกันได้จริงผ่านหน้า Settings** และเพลงยัง**เล่นต่อเนื่องข้ามฉาก**ได้ด้วย
เพราะย้ายไปเป็น Autoload ตั้งแต่แรก

### ภาพรวม

```
AudioManager (Autoload, script/audio_manager.gd)
├── คุม Audio Bus "Music" และ "SFX" (แยกจาก Master)
├── play_music() / stop_music() — เล่น/หยุดเพลงพื้นหลัง
├── play_sfx() — เล่นเสียงเอฟเฟกต์สั้นๆ (สร้าง/ลบ AudioStreamPlayer ชั่วคราวอัตโนมัติ)
├── set_music_volume() / set_sfx_volume() — ปรับ volume ผ่าน AudioServer แบบ real-time
└── เซฟ/โหลดค่าเสียงลง user://audio_settings.cfg (จำค่าข้ามการเปิดเกมใหม่)

Scene/settings.tscn (script/settings.gd)
├── MusicSlider / SfxSlider (HSlider) → ต่อกับ AudioManager
└── BackButton (TextureButton) → กลับไป main_menu.tscn
```

### 10.1 สร้าง Audio Bus แยกเพลง/เอฟเฟกต์

1. เปิดแท็บ **Audio** (แถบด้านล่างของ Godot คู่กับ Output/Debugger)
2. กด **Add Bus** 2 ครั้ง สร้าง bus ชื่อ **Music** และ **SFX**
3. เช็คว่าทั้งคู่ส่งเสียงไปที่ **Master** (ค่า default)
4. Save จะได้ไฟล์ `default_bus_layout.tres` เก็บการตั้งค่านี้ไว้อัตโนมัติ

### 10.2 `script/audio_manager.gd` — ตัวกลางคุมเสียงทั้งเกม

คลิกขวาโฟลเดอร์ `script` → Create New → Script → `audio_manager.gd`

```gdscript
extends Node

## ตัวกลางคุมเสียงทั้งเกม — เพลงพื้นหลัง (Music) กับเสียงเอฟเฟกต์ (SFX)
## ต้องตั้งเป็น Autoload ชื่อ "AudioManager" และต้องมี Audio Bus "Music"/"SFX" ก่อน (ดู 10.1)

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const SAVE_PATH := "user://audio_settings.cfg"

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	_load_settings()

func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return  # เพลงเดิมกำลังเล่นอยู่แล้ว ไม่ต้องเริ่มใหม่
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()

## เล่นเสียงเอฟเฟกต์ (คลิกปุ่ม, เดินหมาก, กินหมาก ฯลฯ) — สร้าง AudioStreamPlayer ชั่วคราว
## แล้วลบตัวเองทิ้งหลังเล่นจบ เล่นซ้อนกันได้หลายเสียงพร้อมกัน
func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

## --- ควบคุมระดับเสียง (รับค่า 0.0-1.0 จาก slider แล้วแปลงเป็นเดซิเบล) ---

func set_music_volume(linear: float) -> void:
	_set_bus_volume(MUSIC_BUS, linear)
	_save_settings()

func set_sfx_volume(linear: float) -> void:
	_set_bus_volume(SFX_BUS, linear)
	_save_settings()

func get_music_volume() -> float:
	return _get_bus_volume(MUSIC_BUS)

func get_sfx_volume() -> float:
	return _get_bus_volume(SFX_BUS)

func _set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("ไม่พบ audio bus ชื่อ '%s' — เช็คว่าสร้างไว้ในแท็บ Audio แล้วหรือยัง" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(clampf(linear, 0.0, 1.0)))
	AudioServer.set_bus_mute(bus_idx, linear <= 0.0)

func _get_bus_volume(bus_name: String) -> float:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))

## --- เซฟ/โหลดค่าเสียงลงไฟล์ ให้จำค่าไว้ข้ามการเปิดเกมใหม่ ---

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", get_music_volume())
	config.set_value("audio", "sfx_volume", get_sfx_volume())
	config.save(SAVE_PATH)

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return  # ยังไม่เคยเซฟมาก่อน ใช้ค่า default ของ bus ต่อไป
	set_music_volume(config.get_value("audio", "music_volume", 1.0))
	set_sfx_volume(config.get_value("audio", "sfx_volume", 1.0))
```

> ⚠️ **ตรวจให้แน่ใจว่าโค้ดที่วางไปอยู่ในไฟล์จริง อย่าเชื่อแค่ว่า "วางแล้ว"** — เคยเจอเคสที่ปุ่ม
> "Create Script" สร้าง template เปล่า (`extends Node` + `_ready()` ว่างๆ) ค้างอยู่ทับโค้ดที่ตั้งใจวาง
> ทำให้ error `Nonexistent function 'get_music_volume'` ตอนเรียกใช้ทั้งที่ "ดูเหมือน" วางโค้ดไปแล้ว

### 10.3 ตั้งเป็น Autoload

**Project → Project Settings → Autoload** → Path เลือก `res://script/audio_manager.gd` →
Node Name ตั้งเป็น `AudioManager` (ตัวสะกดต้องตรงเป๊ะ) → **Add**

> เป็น Autoload (ไม่ใช่ node ในฉาก) ตั้งแต่แรก เพราะงั้น**เพลงเล่นต่อเนื่องข้ามฉากได้เองอัตโนมัติ**
> ไม่ต้องทำอะไรเพิ่ม — ต่างจากการวาง `AudioStreamPlayer` ไว้ใน `main.tscn` ตรงๆ ซึ่งจะหยุด/รีเซ็ตทุกครั้ง
> ที่เปลี่ยนฉาก

### 10.4 เชื่อมเพลง gameplay เข้ากับระบบ

1. เปิดไฟล์ `script/main.gd`
2. เพิ่มบรรทัดนี้ไว้บนสุดของไฟล์ (นอกฟังก์ชันใดๆ):
```gdscript
const GAMEPLAY_MUSIC := preload("res://asset/audio/{ชื่อไฟล์เพลง}.mp3")
```
3. หาฟังก์ชัน `_ready():` แล้วเพิ่มบรรทัดนี้ไว้ข้างใน (จะมีโค้ดอื่นอยู่แล้วก็ได้ ไม่ต้องลบ):
```gdscript
	AudioManager.play_music(GAMEPLAY_MUSIC)
```
4. หาฟังก์ชัน `_on_main_menu_pressed()` แล้วเพิ่มบรรทัดนี้เข้าไปข้างใน (ก่อนบรรทัด
   `SceneTransition.change_scene(...)`):
```gdscript
	AudioManager.stop_music()          # ไม่ควรเล่นต่อตอนกลับเมนูหลัก
```
5. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ห้ามวาง `AudioStreamPlayer` เล่นเพลงตรงๆ ในฉากอีกทางขนานกับ `AudioManager`**
> เคยเจอบั๊กที่มี node `AudioStreamPlayer` ชื่อ `BGM` ตั้ง `autoplay = true` เล่นเพลงเดียวกันตรงๆ ผ่าน
> bus **"Master"** (ไม่ใช่ "Music") ทำให้เพลงเล่นซ้อนกัน 2 ทาง — ทางหนึ่งคุม volume ได้ อีกทางคุมไม่ได้เลย
> อาการที่เจอคือ **"ลาก slider แล้วเสียงไม่เปลี่ยนเลย"** ทั้งที่โค้ดถูกทุกอย่าง — ต้องเล่นเพลงผ่าน
> `AudioManager.play_music()` ทางเดียวเท่านั้น

### 10.5 สร้างหน้า Settings scene

1. **Scene → New Scene → User Interface** (root เป็น `Control`) → เปลี่ยนชื่อเป็น `Settings` →
   save `res://Scene/settings.tscn`
2. เพิ่ม `Sprite2D` ชื่อ `Background` → Texture = `mainmenu_bg .jpg` (ภาพเดียวกับเมนูหลัก ให้ดูต่อเนื่อง) →
   จัด position/scale ให้เต็มจอ 1920×1200
3. เพิ่ม `HSlider` 2 ตัว: `MusicSlider`, `SfxSlider` → ตั้งค่าที่ Inspector หมวด **Range**:
   **Min Value 0 / Max Value 1 / Step 0.05 / Value 1**
   (ถ้าหาหมวด Range ไม่เจอ พิมพ์ "min" ในช่องค้นหา 🔍 ด้านบนของ Inspector)
4. เพิ่มปุ่ม `BackButton` (ดู 10.7 ว่าจะใช้ TextureButton สไตล์ไหน)

### 10.6 `script/settings.gd`

Attach Script ที่ node `Settings` → `res://script/settings.gd`

```gdscript
extends Control

@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SfxSlider
@onready var back_button: TextureButton = $BackButton

func _ready() -> void:
	# ตั้งค่า slider ให้ตรงกับค่าเสียงปัจจุบัน (กรณีเคยปรับ/เซฟไว้ก่อนหน้า)
	music_slider.value = AudioManager.get_music_volume()
	sfx_slider.value = AudioManager.get_sfx_volume()

	# ต่อสัญญาณ: ลาก slider แล้วเปลี่ยนเสียงทันที
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)

func _on_music_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_back_pressed() -> void:
	SceneTransition.change_scene("res://Scene/main_menu.tscn")
```

> ⚠️ **`$` path ในสคริปต์ต้องตรงกับตำแหน่งจริงใน scene tree เป๊ะ** — ถ้าย้าย node ออกจาก
> container หรือลบ container ทิ้งทีหลัง (ดู 10.8) ต้องกลับมาแก้ `$...` ให้ตรง ไม่งั้น error
> `Invalid access to property or key ... on a base object of type 'null instance'`
>
> และถ้าเปลี่ยนชนิด node (เช่น `Button` → `TextureButton` ใน 10.7) ต้องแก้ **type ของตัวแปร**
> (`@onready var back_button: TextureButton`) ให้ตรงด้วย ไม่งั้น error
> `Trying to assign value of type 'TextureButton' to a variable of type 'Button'`

ต่อปุ่ม Settings ในเมนูหลัก (`script/main_menu.gd`) ให้เปิดหน้านี้:
```gdscript
func _on_settings_pressed():
	SceneTransition.change_scene("res://Scene/settings.tscn")
```

### 10.7 ทำ UI สไลเดอร์สไตล์กราฟิกของเกม (ถ้ามีภาพกรอบ/แถบเลื่อนสำเร็จรูป)

ถ้ามีภาพกรอบสไตล์เกม (เช่นกรอบหินสลักรูน) ที่มีข้อความ "BGM VOLUME"/"SFX VOLUME" พร้อมเลขสเกล
และปุ่มเลื่อนวาดไว้ในตัวอยู่แล้ว ใช้เป็นพื้นหลัง + ปุ่มเลื่อนจริงได้ตามนี้:

**10.7.1 ลบปุ่มเลื่อนที่วาดตายตัวออกจากพื้นหลัง (image healing)**
ภาพต้นฉบับมักวาดปุ่มเลื่อนค้างไว้ตำแหน่งคงที่ ถ้าใช้ทั้งภาพเป็นพื้นหลังตรงๆ จะมีปุ่มปลอมค้างซ้อนกับ
ปุ่มเลื่อนจริงที่ขยับได้ — ใช้เทคนิค **clone-stamp แบบขอบนุ่ม (feather blend)**: โคลนชิ้นส่วนราง
ที่ "สะอาด" (ไม่มีปุ่ม) จากตำแหน่ง x เดียวกันบนอีกราง มาแปะทับตำแหน่งปุ่มเดิม โดยใช้ mask เบลอ
(Gaussian blur) ที่ขอบ กันไม่ให้เกิดรอยตะเข็บเป็นสี่เหลี่ยมนูน (ถ้าแปะแบบขอบคมตรงๆ จะเห็นรอยนูนชัดเจน)
→ บันทึกเป็น `asset/ui/settings_panel.png`

**10.7.2 ครอปปุ่มเลื่อน (grabber) แยกไว้ใช้เป็นไอคอนจริง**
ครอปเฉพาะปุ่มจากภาพต้นฉบับ ทำขอบมนจาง (rounded + blur บน alpha channel) แทนขอบสี่เหลี่ยมคมๆ
(ไม่งั้นดูเหมือนแปะสติกเกอร์ทับราง) แล้วย่อขนาดให้พอดีความหนาของราง
→ บันทึกเป็น `asset/ui/settings_grabber.png`

> ⚠️ **`HSlider` ของ Godot วาด grabber icon ตามขนาดพิกเซลจริงของไฟล์ภาพเป๊ะๆ — ไม่มีช่อง
> "Scale" ให้ปรับใน Inspector เหมือน Sprite2D** ถ้าอยากปรับขนาดปุ่มเลื่อนต้อง**แก้ไฟล์ PNG
> ต้นฉบับโดยตรง** (resize แล้ว save ทับไฟล์เดิม ชื่อเดิม Godot จะ reimport ให้เอง)

**10.7.3 วางภาพพื้นหลัง + จัดโครงสร้าง**
1. เพิ่ม `Sprite2D` ชื่อ `VolumePanel` → texture = `settings_panel.png` → อยู่เหนือพื้นหลังหลัก
   แต่ใต้ slider จริง
2. ถ้าข้อความ "BGM VOLUME"/"SFX VOLUME" ถูก baked ไว้ในภาพแล้ว ไม่ต้องสร้าง `Label` ซ้ำ

**10.7.4 สไตล์ HSlider ให้โปร่งใส ใช้ grabber จากภาพ**
ที่ Inspector ของ `MusicSlider`/`SfxSlider` → หมวด **Theme Overrides**:
- **Styles → Slider** = New **StyleBoxEmpty**
- **Styles → Grabber Area** = New **StyleBoxEmpty**
- **Icons → Grabber / Grabber Highlight / Grabber Disabled** = `settings_grabber.png`

**10.7.5 วางอิสระให้ตรงกับรางในภาพ**

> ⚠️ **ถ้า slider อยู่ใน `Container` (เช่น `VBoxContainer`) จะลากจัดตำแหน่งเองไม่ได้** ต้องย้ายออกมา
> เป็นลูกตรงของ `Settings` (root) ก่อน แต่การย้ายแบบนี้**ไม่รีเซ็ต anchor/layout mode ให้อัตโนมัติ**
> ทำให้บางครั้งลากในหน้าจอไม่ได้เลย — แก้โดยเลือก node แล้วกด **Anchor Preset (แถบเครื่องมือเหนือวิวพอร์ต)
> → Top Left** เพื่อสลับกลับไปโหมดตำแหน่งอิสระ (พิกเซล offset ตรงๆ) แล้วค่อยลาก/พิมพ์ `offset_left/top/right/bottom`
> ให้ตรงกับรางในภาพ (คำนวณจาก scale ของ `VolumePanel` เทียบกับตำแหน่งพิกเซลจริงในไฟล์ภาพต้นฉบับ)
>
> จุดที่พลาดง่าย: กะระยะจากสายตาแคบไป ทำให้ลาก slider ไม่ถึง 100% ของแถบ — ต้องวัดพิกัดหัวลูกศร
> ซ้าย/ขวาของรางในภาพต้นฉบับให้แม่น แล้วคำนึงด้วยว่า Godot จัดตำแหน่ง grabber center แบบเว้นครึ่ง
> ความกว้างไอคอนจากขอบซ้าย/ขวาเสมอ (ไม่ใช่แค่ยืดเต็มความกว้าง Control)

### 10.8 เปลี่ยนปุ่ม Back ให้เป็นสไตล์เดียวกับปุ่มอื่นในเกม

1. ใช้ `TextureButton` (ไม่ใช่ `Button` ธรรมดา) — ใส่ `texture_normal`/`texture_hover` จากชุดปุ่มที่มีอยู่แล้ว
   (เช่นปุ่ม "MAIN MENU" จากเมนู pause ในตอนที่ 8 — ความหมายตรงกันพอดีเพราะกดแล้วกลับไปเมนูหลักเหมือนกัน)
2. ติ๊ก **Ignore Texture Size** ✅, ตั้ง **Stretch Mode = Keep Aspect Centered**

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| กด F5 เข้าฉากเกม | ได้ยินเพลง gameplay ทันที |
| เข้าเมนูหลัก → Settings → ลาก **Music slider** | เสียงเพลงดัง-เบาเปลี่ยนตามทันที (ทดสอบให้ชัวร์: ลากสุดซ้าย = เงียบสนิท, สุดขวา = ดังสุด) |
| ลาก **SFX slider** แล้วปิด/เปิดเกมใหม่ | ค่าที่ปรับไว้ต้องจำได้ (อ่านจาก `user://audio_settings.cfg`) |
| กด Back | กลับไปเมนูหลักได้ |
| เอาเมาส์ชี้ปุ่ม Back | เรืองแสงแบบเดียวกับปุ่มอื่นในเกม |

---

## ตอนที่ 11 — ระบบเลือด (HP) + เอฟเฟกต์การต่อสู้แฟนตาซี

หมากรุกปกติกินตายทันทีทีเดียว — ตอนนี้เปลี่ยนให้เป็นสไตล์แฟนตาซี **ทุกตัวมีเลือด 100 เท่ากันหมด
แต่พลังโจมตีต่างกันตามชนิดหมาก ต้องตีหลายทีถึงจะตายจริง** พร้อมเอฟเฟกต์ออร่าพลังลอยรอบตัว,
เอฟเฟกต์ตอนปะทะ (ทั้งแบบตายและไม่ตาย), และเอฟเฟกต์ตอนตายจริง

> ⚠️ **หัวใจของดีไซน์นี้คือ `chess_rules.gd` (กติกาเดิน/รุก/รุกฆาต) ไม่ต้องแก้เลยสักบรรทัด**
> เพราะ HP มีผลแค่ตอน `Board.try_move()` ตัดสินว่า "กินครั้งนี้ตายจริงไหม" ไม่ใช่ตอนตัดสิน
> "เดินได้ไหม" — ถ้าโจมตีแล้วเหยื่อไม่ตาย `board_state` จะไม่เปลี่ยนเลย (ผู้โจมตีไม่ขยับเข้าไป
> แทนที่ เหยื่อยังยืนอยู่ที่เดิม) กติกา check/checkmate/castling ทั้งหมดยังทำงานถูกต้องเป๊ะ
> เพราะยังคำนวณจาก `board_state` แบบเดิมทุกอย่าง

### ค่าพื้นฐาน

| หมาก | เลือด (HP) | พลังโจมตี | จำนวนตีที่ต้องใช้ (ประมาณ) |
|---|---|---|---|
| เบี้ย | 100 | 20 | 5 ครั้ง |
| ม้า/บิชอป | 100 | 30 | 4 ครั้ง |
| เรือ | 100 | 40 | 3 ครั้ง |
| ควีน | 100 | 60 | 2 ครั้ง |
| คิง | 100 | 35 | (ไม่มีวันตายผ่านทางนี้ — เกมจบด้วยรุกฆาตก่อนเสมอ ไม่มีการ "กิน" คิงจริงในหมากรุก) |

### 11.1 `script/chess_piece.gd` — เพิ่มเลือด + พลังโจมตี + หลอดเลือด

1. เปิดไฟล์ `script/chess_piece.gd`
2. หาบรรทัด `var resting_scale: Vector2 = Vector2.ONE`
3. เพิ่มโค้ดนี้ต่อท้ายบรรทัดนั้น (ก่อนถึงฟังก์ชัน `art_name`):

```gdscript
## --- ระบบเลือด (HP) --- ตีหลายทีถึงตาย แทนที่จะกินตายทันทีทีเดียวแบบหมากรุกปกติ
## เลือดเท่ากันหมดทุกตัว (100) แต่พลังโจมตีต่างกันตามชนิดหมาก
## piece_spawner.gd ตั้งค่า hp/max_hp/attack_power ให้ตอนสร้างตัวหมาก
## กติกาการ "เดินไปกินได้ไหม" ยังคงเดิมทุกอย่าง (chess_rules.gd ไม่ต้องแก้เลย) — HP มีผลแค่ตอน
## Board.try_move() ตัดสินว่าการกินครั้งนี้ตายจริงไหม ถ้าไม่ตายผู้โจมตีจะไม่ได้ขยับเข้าไปแทนที่
const BASE_HP := 100.0

var max_hp: float = BASE_HP
var hp: float = BASE_HP
var attack_power: float = 1.0

## พลังโจมตีพื้นฐานตามชนิดหมาก — ดาเมจที่สร้างให้เหยื่อทุกครั้งที่กิน/โจมตีสำเร็จ
static func base_attack(kind: int) -> float:
	match kind:
		Kind.PAWN: return 20.0
		Kind.KNIGHT: return 30.0
		Kind.BISHOP: return 30.0
		Kind.ROOK: return 40.0
		Kind.QUEEN: return 60.0
		Kind.KING: return 35.0
		_: return 20.0

## โดนโจมตี amount หน่วย คืน true ถ้าเลือดหมด (ตาย)
func take_damage(amount: float) -> bool:
	hp = maxf(hp - amount, 0.0)
	queue_redraw()
	return hp <= 0.0

func _process(_delta: float) -> void:
	queue_redraw()  # เลือดขยับ/ขนาดหมากเปลี่ยนบ่อย วาดใหม่ทุกเฟรมง่ายกว่าคอย queue_redraw() ทุกจุดที่แก้ค่า

## วาดหลอดเลือดลอยเหนือหัวหมาก — หารด้วย scale ปัจจุบันทุกจุด กันไม่ให้หลอดยืด/หดเบี้ยว
## ตอนหมากถูกขยายเวลาเลือก หรือแถวไกล้-ไกลกล้องที่ขนาดหมากต่างกันมาก (ดู piece_spawner.gd)
func _draw() -> void:
	if texture == null or max_hp <= 0.0:
		return
	var sx: float = maxf(absf(scale.x), 0.0001)
	var sy: float = maxf(absf(scale.y), 0.0001)
	var bar_w := 70.0 / sx
	var bar_h := 9.0 / sy
	var gap := 14.0 / sy
	var top_y: float = -texture.get_height() * 0.5 - gap - bar_h
	var bg_rect := Rect2(Vector2(-bar_w * 0.5, top_y), Vector2(bar_w, bar_h))

	var pct: float = clampf(hp / max_hp, 0.0, 1.0)
	var fill_color: Color
	if pct > 0.5:
		fill_color = Color(0.25, 0.85, 0.3)
	elif pct > 0.25:
		fill_color = Color(0.95, 0.75, 0.15)
	else:
		fill_color = Color(0.9, 0.15, 0.15)

	draw_rect(bg_rect, Color(0.0, 0.0, 0.0, 0.55))
	if pct > 0.0:
		draw_rect(Rect2(bg_rect.position, Vector2(bar_w * pct, bar_h)), fill_color)
	draw_rect(bg_rect, Color(1.0, 1.0, 1.0, 0.4), false, 1.0 / sy)
```

> **ทำไมหารด้วย `scale` ทุกจุด?** `_draw()` วาดในพิกัดโลคัลของ node ซึ่งถูกคูณด้วย `scale` ของ
> node นั้นเสมอ (เหมือน `Board._draw()` วาดกรอบกริดในพิกัดโลคัลของตัวเอง) ถ้าไม่หารกลับ พอหมาก
> ถูกขยายตอนเลือก หรืออยู่แถวใกล้กล้องที่ scale ใหญ่กว่าแถวไกล — หลอดเลือดจะยืด/หดขนาดเบี้ยวตาม
> ไม่ใช่ขนาดคงที่บนจอแบบที่ควรจะเป็น

4. กด `Ctrl+S` เซฟไฟล์ `chess_piece.gd`

### 11.2 `script/piece_spawner.gd` — ตั้งค่าเลือดตอนสร้าง + ออร่าพลัง + animation โจมตีไม่ตาย

1. เปิดไฟล์ `script/piece_spawner.gd`
2. หาฟังก์ชัน `spawn_piece()` แล้วหาบรรทัด `piece.side = side`
3. เพิ่ม 3 บรรทัดต่อท้ายบรรทัดนั้น (ตั้งค่าเลือด/พลังโจมตี):

```gdscript
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
	place_piece(piece, cell)
	get_parent().board_state[cell.y][cell.x] = piece
	return piece
```

4. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันเหล่านี้ต่อท้าย:

```gdscript
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
```

> เอฟเฟกต์ตาย (สะบัด/ล้ม/จางหาย) กับเอฟเฟกต์ปะทะ (รอยฟัน `SlashEffect`) ที่มีอยู่แล้วจากตอนที่ 6
> ถูกใช้ซ้ำทั้งคู่ — `play_capture()` เดิม (โจมตีจนตาย) ไม่ต้องแก้อะไรเลย ใช้ `play_attack_bounce()`
> ใหม่นี้เฉพาะกรณีโจมตีไม่ตายเท่านั้น

5. กด `Ctrl+S` เซฟไฟล์ `piece_spawner.gd`

### 11.3 `script/Board.gd` — แยก "โจมตีตาย" กับ "โจมตีไม่ตาย" ใน `try_move()`

1. เปิดไฟล์ `script/Board.gd`
2. ลบฟังก์ชัน `try_move()` เดิมทั้งฟังก์ชันทิ้ง (ตั้งแต่บรรทัด `func try_move(...)` ถึงบรรทัด
   `return true` ที่อยู่ก่อน `func _evaluate_status()`)
3. วางโค้ดนี้แทนที่ตรงจุดที่ลบไป:

```gdscript
## เกมจบแล้วหรือยัง — winner = -1 คือเสมอ (ดู ChessRules.status())
## ส่งเพิ่มจากของเดิม: แจ้งตอนโจมตีสำเร็จ ไม่ว่าจะฆ่าตายหรือแค่ลดเลือด (เอาไว้ต่อเสียง/เอฟเฟกต์ทีหลัง)
signal piece_attacked(attacker: ChessPiece, victim: ChessPiece, damage: float, killed: bool)

## พยายามเดินหมากจาก from ไป to คืน true ถ้าเดินได้จริง
## promote_to ใช้เฉพาะตอนเบี้ยถึงแถวสุดท้าย (ค่าเริ่มต้นคือควีน)
##
## ลำดับขั้นตอนในฟังก์ชันนี้ตายตัว ห้ามสลับที่ เพราะแต่ละขั้นอิงผลจากขั้นก่อนหน้า:
##   1. ตัดสินก่อนว่าถ้ามีการโจมตี จะฆ่าเหยื่อตายจริงไหม (ระบบเลือด) แล้วค่อยอัปเดต board_state
##      ตามผลนั้น — ถ้าไม่ตาย ผู้โจมตี "ไม่ขยับ" เข้าไปแทนที่ (เหยื่อยังยืนอยู่ที่เดิม แค่เลือดลด)
##   2. เริ่ม animation แล้ว await ให้เล่นจบก่อนค่อยไปขั้นต่อไป
##   3. หลังเล่นจบ: promote / en passant / 50 ตา / เปลี่ยนตา (เฉพาะกรณีที่ตัวหมากขยับจริง)
##   4. ส่ง signal ให้ UI ไปอัปเดตทีหลังสุด
func try_move(from_cell: Vector2i, to_cell: Vector2i, promote_to: int = ChessPiece.Kind.QUEEN) -> bool:
	if animating or not (to_cell in legal_moves_for(from_cell)):
		return false

	var piece: ChessPiece = board_state[from_cell.y][from_cell.x]
	var is_pawn := piece.piece_kind == ChessPiece.Kind.PAWN
	var captured: ChessPiece = board_state[to_cell.y][to_cell.x]
	var is_en_passant := is_pawn and to_cell == en_passant_target and captured == null
	if is_en_passant:
		captured = board_state[from_cell.y][to_cell.x]

	# ---------- ขั้นที่ 1: ตัดสินผลการโจมตี (ถ้ามี) ก่อนแตะ board_state ----------

	var lethal := true  # ไม่มีการกินเลย ก็ถือว่า "ผ่าน" ได้ปกติเหมือนเดิม
	if captured != null:
		lethal = captured.take_damage(piece.attack_power)
		piece_attacked.emit(piece, captured, piece.attack_power, lethal)

	# piece_moved = ผู้โจมตีได้ขยับไปช่องปลายทางจริงไหมในตานี้ — false เฉพาะกรณี
	# "โจมตีแล้วเหยื่อไม่ตาย" เท่านั้น (เหยื่อยังกีดขวางอยู่ ขยับเข้าไปแทนที่ไม่ได้)
	var piece_moved: bool = captured == null or lethal

	var move_tweens: Array = []

	if piece_moved:
		# ---------- อัปเดต board_state (ตรรกะเกม) ให้ครบก่อน — เหมือนโค้ดเดิมทุกประการ ----------

		if is_en_passant:
			board_state[from_cell.y][to_cell.x] = null

		# castling: คิงขยับ 2 ช่อง ต้องลากเรือข้ามมาอยู่อีกฝั่งของคิงด้วย (เลื่อนพร้อมกับคิง)
		if piece.piece_kind == ChessPiece.Kind.KING and absi(to_cell.x - from_cell.x) == 2:
			var rook_col: int = COLS - 1 if to_cell.x > from_cell.x else 0
			var rook_dest: int = to_cell.x - 1 if to_cell.x > from_cell.x else to_cell.x + 1
			var rook: ChessPiece = board_state[from_cell.y][rook_col]
			board_state[from_cell.y][rook_col] = null
			board_state[from_cell.y][rook_dest] = rook
			rook.has_moved = true
			move_tweens.append(_place_visual(rook, Vector2i(rook_dest, from_cell.y), true))

		board_state[from_cell.y][from_cell.x] = null
		board_state[to_cell.y][to_cell.x] = piece
		piece.has_moved = true

		if captured != null:
			move_tweens.append(_play_capture(piece, captured, to_cell))
		else:
			move_tweens.append(_place_visual(piece, to_cell, true))
	else:
		# โจมตีไม่ตาย — board_state ไม่เปลี่ยนเลย (ทั้งผู้โจมตีและเหยื่อยังอยู่ที่เดิม)
		move_tweens.append(_play_attack_bounce(piece, captured))

	# ---------- ขั้นที่ 2: รอ animation เลื่อนหมากให้จบก่อน ----------
	animating = true
	for t in move_tweens:
		if t != null:
			await (t as Tween).finished
	animating = false

	# ---------- ขั้นที่ 3: หลังเลื่อนเสร็จแล้วเท่านั้น ค่อยจัดการส่วนที่เหลือ ----------

	# 3a) promote ก่อน (ถ้าเข้าเงื่อนไข) — เฉพาะกรณีขยับไปจริง เพราะโจมตีไม่ตายเบี้ยยังไม่ถึงแถวไหน
	if piece_moved and is_pawn and to_cell.y == ChessRules.promotion_row(piece.side):
		piece = _promote(piece, to_cell, promote_to)

	# 3b) ตั้งช่อง en passant ให้ตาถัดไป เฉพาะตอนเบี้ยเพิ่งเดินรวด 2 ช่องจริง
	if piece_moved and is_pawn and absi(to_cell.y - from_cell.y) == 2:
		en_passant_target = Vector2i(from_cell.x, (from_cell.y + to_cell.y) / 2)
	else:
		en_passant_target = ChessRules.NO_CELL

	# 3c) กฎ 50 ตา: นับใหม่เฉพาะตอนเดินเบี้ยจริงหรือมีการกิน (ตาย) จริง — โจมตีไม่ตายไม่นับรีเซ็ต
	if piece_moved and (is_pawn or captured != null):
		halfmove_clock = 0
	else:
		halfmove_clock += 1
	if side_to_move == ChessPiece.Team.BLACK:
		fullmove_number += 1

	# 3d) สลับตาเดิน — เสียตาเสมอไม่ว่าจะโจมตีตายหรือไม่ตาย (ตัดสินใจโจมตีก็ถือว่าเสียตานี้ไปแล้ว)
	last_move = [from_cell, to_cell]
	side_to_move = ChessRules.opponent(side_to_move)

	# ---------- ขั้นที่ 4: ส่ง signal ให้ UI ไปอัปเดต (ต้องมาหลังสุด) ----------
	move_made.emit(from_cell, to_cell, piece)
	turn_changed.emit(side_to_move)
	_evaluate_status()  # เช็ค check / รุกฆาต / อับ ด้วย side_to_move ที่อัปเดตแล้ว
	return true
```

4. หาฟังก์ชัน `_play_capture()` ที่มีอยู่แล้ว
5. เพิ่มฟังก์ชันใหม่นี้ต่อท้ายฟังก์ชันนั้น:

```gdscript
## ให้ node Pieces เล่น animation พุ่งเข้าปะทะแล้วถอยกลับ (โจมตีสำเร็จแต่เหยื่อไม่ตาย)
## ถ้าหา Pieces ไม่เจอ (ไม่ควรเกิด) ให้ fallback เฉยๆ ไม่ทำอะไร (board_state ไม่เปลี่ยนอยู่แล้ว)
func _play_attack_bounce(attacker: ChessPiece, victim: ChessPiece) -> Tween:
	var pieces := get_node_or_null("Pieces")
	if pieces != null and pieces.has_method("play_attack_bounce"):
		return pieces.play_attack_bounce(attacker, victim)
	return null
```

6. กด `Ctrl+S` เซฟไฟล์ `Board.gd`

### 11.4 อัปเกรดเอฟเฟกต์ตาย — จาก "จางหายเฉยๆ" เป็น "แตกกระจายเป็นเศษชิ้น" (shatter)

`_play_victim_death()` เวอร์ชันตอนที่ 6 (สะบัด/ล้ม/จางหาย) ใช้งานได้แต่ดูเรียบไป — เปลี่ยนให้สมจริงขึ้น
ด้วย 3 เอฟเฟกต์พร้อมกัน: **แตกเป็นเศษชิ้น** (ตัดภาพตัวหมากเองเป็นตาราง 3×3 แล้วให้กระเด็นคนละทิศ),
**ฝุ่นกระจาย**, และ **วงแหวนกระแทกพื้น** — ไม่ต้องใช้ asset รูปเพิ่มเลยสักไฟล์

**(a) สร้าง `script/impact_ring.gd` ใหม่** — วงแหวนแสงขยายออกแล้วจางหาย วาดด้วย `_draw()` ล้วนๆ
เทคนิคเดียวกับ `SlashEffect` (ตอนที่ 6):

1. คลิกขวาโฟลเดอร์ `script` ในแผง FileSystem → **Create New → Script...**
2. Inherits: `Node2D`, Path: `res://script/impact_ring.gd` → **Create**
3. ลบโค้ด template ที่ Godot ใส่มาให้ (`extends Node2D` + `_ready()`/`_process()` เปล่าๆ) ทิ้งทั้งหมด
   แล้ววางโค้ดนี้แทน — **ไม่ต้องผูก script นี้กับ node ไหนในฉากเลย** เพราะจะถูกสร้างขึ้นเองด้วยโค้ด
   ตอนรันเกม (`ImpactRing.new()`) เหมือน `SlashEffect` ทุกประการ

```gdscript
extends Node2D
class_name ImpactRing

## วงแหวนแสงกระแทกพื้น ขยายออกแล้วจางหาย ใช้ตอนหมากตาย (ดู piece_spawner.gd:_play_victim_death)
## วาดด้วย _draw() ล้วนๆ ไม่ต้องมี asset รูป เป็น node ชั่วคราวที่ลบตัวเองทิ้งอัตโนมัติหลังเล่นจบ
## เทคนิคเดียวกับ SlashEffect: ใช้ tween_method() ยิงค่าเข้าตัวแปรแล้ว queue_redraw() ทุกครั้งที่ค่าขยับ

const START_RADIUS := 10.0
const END_RADIUS := 65.0
const DURATION := 0.35
const RING_WIDTH := 5.0

var _radius := START_RADIUS
var _alpha := 0.9

func _ready() -> void:
	z_index = 4  # อยู่เหนือตัวหมาก (Pieces z_index = 1) แต่ใต้รอยฟัน (SlashEffect z_index = 5)

	var tween := create_tween()
	tween.tween_method(_set_radius, START_RADIUS, END_RADIUS, DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_method(_set_alpha, 0.9, 0.0, DURATION)
	tween.chain().tween_callback(queue_free)

func _set_radius(r: float) -> void:
	_radius = r
	queue_redraw()

func _set_alpha(a: float) -> void:
	_alpha = a
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 48, Color(0.85, 0.8, 0.7, _alpha), RING_WIDTH, true)
```

4. กด `Ctrl+S` เซฟไฟล์ `impact_ring.gd`

**(b) แก้ `script/piece_spawner.gd`**

1. เปิดไฟล์ `script/piece_spawner.gd`
2. หาบรรทัด `VICTIM_FALL_DURATION` เดิม แล้วเพิ่มค่าคงที่ 2 ตัวนี้ใกล้ๆ กัน:

```gdscript
const SHATTER_GRID := 3            # ตัดภาพตัวหมากเป็นตาราง 3x3 = 9 ชิ้นตอนแตก
const SHATTER_FLY_DURATION := 0.5  # เวลาที่เศษชิ้นบินกระเด็นก่อนจางหาย
```

3. หาฟังก์ชัน `_play_victim_death()` เวอร์ชันตอนที่ 6 (สะบัด/ล้ม/จางหาย) แล้ว**แทนที่ทั้งฟังก์ชัน**
   ด้วยอันนี้:

```gdscript
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
```

4. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันใหม่ 3 ตัวนี้ต่อท้าย:

```gdscript
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
```

5. กด `Ctrl+S` เซฟไฟล์ `piece_spawner.gd`

> เอฟเฟกต์รอยฟัน (`SlashEffect`, ตอนที่ 6) ยังใช้ซ้ำเหมือนเดิมทุกจุด — ของใหม่ในนี้เสริมแค่ตอน
> "ตายจริง" เท่านั้น ส่วน `play_attack_bounce()`/`_play_victim_hit()` ในตอนที่ 11.2 (โจมตีไม่ตาย)
> ไม่ต้องแก้อะไรเลย เพราะเรียกเฉพาะกรณีเหยื่อยังไม่ตาย

### 11.5 ตัวเลขดาเมจลอยขึ้นสไตล์ RPG (damage popup)

โผล่ทุกครั้งที่โจมตีสำเร็จ (ทั้งตายและไม่ตาย) โดยฟังจาก signal `piece_attacked` ที่มีอยู่แล้วจาก
ตอนที่ 11.3 — **ไม่ต้องแก้ `Board.gd` เลยสักบรรทัด**

**(a) สร้าง `script/damage_popup.gd` ใหม่:**

1. คลิกขวาโฟลเดอร์ `script` ในแผง FileSystem → **Create New → Script...**
2. Inherits: `Node2D`, Path: `res://script/damage_popup.gd` → **Create**
3. ลบโค้ด template ที่ Godot ใส่มาให้ทิ้งทั้งหมด แล้ววางโค้ดนี้แทน — เหมือน `impact_ring.gd` และ
   `SlashEffect` ตัวนี้**ไม่ต้องผูกกับ node ไหนในฉากเลย** จะถูกสร้างขึ้นเองด้วยโค้ดตอนรันเกม
   (`DamagePopup.new()`)

```gdscript
extends Node2D
class_name DamagePopup

## ตัวเลขดาเมจลอยขึ้นแล้วจางหาย สไตล์เกม RPG — ยิ่งดาเมจแรง ยิ่งตัวใหญ่ + เขย่าแรงตอนโผล่
## โผล่ตอนโจมตีสำเร็จ (ทั้งกรณีตายและไม่ตาย) — วาดด้วย draw_string() ล้วนๆ ไม่ต้องมี asset ฟอนต์เพิ่ม
##
## ต้องเรียก setup() ก่อน add_child() เสมอ (ดู piece_spawner.gd:_on_piece_attacked) เพราะ
## _ready() อ่านค่าที่ setup() ตั้งไว้ไปคำนวณความแรงของเอฟเฟกต์ทันทีที่ node เข้าฉาก

const FONT_SIZE := 34

## ดาเมจระดับนี้ขึ้นไป = เอฟเฟกต์ (ขนาด/แรงเขย่า) แรงเต็มที่ — ปรับเลขนี้เพื่อจูนความรู้สึกได้
const REFERENCE_DAMAGE := 60.0

const BASE_FONT_SCALE := 0.85
const MAX_FONT_SCALE := 1.8
const BASE_SHAKE := 3.0
const MAX_SHAKE := 16.0
const SHAKE_STEPS := 5
const SHAKE_STEP_DURATION := 0.03

const RISE_DISTANCE := 55.0
const RISE_DURATION := 0.7

var _text: String = ""
var _color: Color = Color.WHITE
var _alpha: float = 1.0
var _damage: float = 0.0
var _killed: bool = false
var _font: Font

## เรียกก่อน add_child() เสมอ — killed=true แสดงว่าตีครั้งนี้ฆ่าเหยื่อตายจริง (สีแดง) ไม่ตายก็แค่เลือดลด (สีทอง)
func setup(damage: float, killed: bool) -> void:
	_text = "-%d" % int(round(damage))
	_damage = damage
	_killed = killed
	_color = Color(1.0, 0.35, 0.25) if killed else Color(1.0, 0.85, 0.3)

func _ready() -> void:
	_font = ThemeDB.fallback_font
	z_index = 7  # เหนือทุกเอฟเฟกต์ รวมถึงเศษชิ้นแตก (z_index 6)

	# ความแรง 0.0-1.0 เทียบกับ REFERENCE_DAMAGE — ใช้คุมทั้งขนาดตัวอักษรและแรงเขย่า
	var strength: float = clampf(_damage / REFERENCE_DAMAGE, 0.0, 1.0)
	var font_scale: float = lerp(BASE_FONT_SCALE, MAX_FONT_SCALE, strength) * (1.2 if _killed else 1.0)
	var shake_mag: float = lerp(BASE_SHAKE, MAX_SHAKE, strength)
	var base_pos: Vector2 = position

	scale = Vector2(font_scale, font_scale) * 1.9  # โผล่มาใหญ่เว่อร์ก่อน ให้ความรู้สึก "กระแทก"

	var tween := create_tween()

	# 1) หดจากใหญ่เว่อร์ลงมาขนาดจริงแบบเด้ง (impact punch)
	tween.tween_property(self, "scale", Vector2(font_scale, font_scale), 0.14) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# 2) เขย่าอยู่กับที่สั้นๆ ตามแรงโจมตี ก่อนเริ่มลอยขึ้น — ยิ่งดาเมจสูง ยิ่งเขย่าแรง
	for i in range(SHAKE_STEPS):
		var falloff: float = 1.0 - float(i) / SHAKE_STEPS
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_mag * falloff
		tween.tween_property(self, "position", base_pos + offset, SHAKE_STEP_DURATION)
	tween.tween_property(self, "position", base_pos, SHAKE_STEP_DURATION)

	# 3) ลอยขึ้นพร้อมจางหายตามปกติ
	var rand_x_offset := randf_range(-15.0, 15.0)
	var target: Vector2 = base_pos + Vector2(rand_x_offset, -RISE_DISTANCE)
	tween.tween_property(self, "position", target, RISE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_method(_set_alpha, 1.0, 0.0, RISE_DURATION).set_delay(RISE_DURATION * 0.3)
	tween.chain().tween_callback(queue_free)

func _set_alpha(a: float) -> void:
	_alpha = a
	queue_redraw()

func _draw() -> void:
	if _font == null:
		return
	var col := Color(_color.r, _color.g, _color.b, _alpha)
	var outline := Color(0.0, 0.0, 0.0, _alpha * 0.85)
	for offset in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		draw_string(_font, Vector2(-18, 8) + offset, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, outline)
	draw_string(_font, Vector2(-18, 8), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, col)
```

4. กด `Ctrl+S` เซฟไฟล์ `damage_popup.gd`

> **ทำไมต้อง `scale` ก่อนแล้วค่อย tween ลดลง?** เทคนิค "โผล่มาใหญ่เว่อร์แล้วหดกลับแบบเด้ง"
> (`TRANS_BACK`) เป็นแพทเทิร์นมาตรฐานเกม RPG ให้ความรู้สึก "กระแทก" มีน้ำหนัก มากกว่าโผล่มาขนาด
> เดียวตรงๆ ทื่อๆ — ยิ่งดาเมจแรง (`font_scale` ยิ่งสูง) ยิ่งรู้สึกกระแทกแรงตามไปด้วยโดยอัตโนมัติ

**(b) แก้ `script/piece_spawner.gd`**

1. เปิดไฟล์ `script/piece_spawner.gd`
2. หาฟังก์ชัน `_ready()` แล้วเพิ่มบรรทัดนี้ต่อท้าย (ต่อสัญญาณ):

```gdscript
	board.piece_attacked.connect(_on_piece_attacked)
```

3. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันใหม่นี้ต่อท้าย:

```gdscript
## โผล่ตัวเลขดาเมจลอยขึ้นเหนือหัวเหยื่อทุกครั้งที่โจมตีสำเร็จ (ฟังจาก signal Board.piece_attacked
## ที่มีอยู่แล้วจากระบบเลือด — ไม่ต้องแก้ Board.gd เลย)
func _on_piece_attacked(_attacker: ChessPiece, victim: ChessPiece, damage: float, killed: bool) -> void:
	if victim == null or not is_instance_valid(victim) or victim.texture == null:
		return
	var popup := DamagePopup.new()
	popup.global_position = victim.global_position + Vector2(0, -victim.texture.get_height() * victim.scale.y * 0.55)
	popup.setup(damage, killed)
	add_child(popup)
```

4. กด `Ctrl+S` เซฟไฟล์ `piece_spawner.gd`

### 11.6 หน้าจอสั่นตามแรงตี (screen shake)

โปรเจกต์นี้ไม่มี `Camera2D` แต่จำลอง "กล้องสั่น" ได้ด้วยการสั่น `position` ของ node `Main` เอง
(root ของฉากเกม `main.tscn`) แทน — ได้ผลเหมือนกล้องสั่นทุกอย่าง **ยกเว้น UI** เพราะ `UI` เป็น
`CanvasLayer` ซึ่งไม่ขยับตาม transform ของ parent อยู่แล้ว ปุ่ม Pause จึงนิ่ง ไม่กระตุกตามไปด้วย

1. เปิดไฟล์ `script/main.gd`
2. หาบรรทัด `const GAMEPLAY_MUSIC` แล้วเพิ่มค่าคงที่นี้ต่อท้าย:

```gdscript
const SHAKE_REFERENCE_DAMAGE := 60.0  # ดาเมจระดับนี้ = สั่นเต็มแรง (สูงกว่านี้ก็สั่นแรงเท่าเดิม)
const SHAKE_MAX_OFFSET := 22.0        # พิกเซล ระยะสั่นสูงสุดตอนดาเมจเต็มแรง
const SHAKE_STEPS := 6
const SHAKE_STEP_DURATION := 0.035

var _shake_tween: Tween
```

3. หาฟังก์ชัน `_ready()` แล้วหาบรรทัด `board.game_ended.connect(_on_game_ended)` ข้างใน
4. เพิ่มบรรทัดนี้ต่อท้ายบรรทัดนั้น:

```gdscript
	board.piece_attacked.connect(_on_piece_attacked)
```

5. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันใหม่ 2 ตัวนี้ต่อท้าย:

```gdscript
## สั่นหน้าจอตอนปะทะ — แรงสั่นตามดาเมจที่ตี (ฟังจาก signal Board.piece_attacked ที่มีอยู่แล้ว)
## สั่นเฉพาะ node "Main" (ตัวเอง) ซึ่งเป็น root ของฉากเกม — UI ไม่สั่นตามเพราะอยู่ใน CanvasLayer
## แยกต่างหาก ไม่ผูกกับ transform ของ Main
func _on_piece_attacked(_attacker: ChessPiece, _victim: ChessPiece, damage: float, killed: bool) -> void:
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
```

6. กด `Ctrl+S` เซฟไฟล์ `main.gd`

> `base_pos = Vector2.ZERO` เพราะ `Main` เป็น root node ของฉาก ไม่เคยถูกตั้ง position เริ่มต้นเป็น
> อย่างอื่น — ถ้าสั่นแล้วจอเบี้ยวค้าง ให้เช็คว่า node `Main` ใน editor ตั้ง position ไว้ที่ (0,0) จริงไหม
>
> `_shake_tween.kill()` ก่อนสร้างตัวใหม่ทุกครั้งกันปัญหา tween สั่นซ้อนกันหลายชุดพร้อมกันตอนตีรัวๆ
> ติดกันเร็วๆ (เช่น AI เดินต่อทันทีหลังผู้เล่น) ซึ่งจะทำให้ตำแหน่งสั่นเพี้ยนสะสมไม่กลับที่เดิม

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| ทุกตัวมีหลอดเลือดลอยเหนือหัวเสมอ | สีเขียว (เลือดเต็ม) |
| ทุกตัวมีประกายฟุ้งลอยรอบตัวตลอดเวลา | สีทองฝั่งผู้เล่น / สีม่วงฝั่งศัตรู |
| เดินเบี้ยไปกินหมากที่เลือดยังเหลือเยอะ (เช่นควีนตีเรือครั้งแรก) | เรือเลือดลด (หลอดเปลี่ยนสีตามเปอร์เซ็นต์) แต่ **เรือยังยืนอยู่ที่เดิม** ผู้โจมตีเด้งกลับที่เดิม ไม่ได้ขยับเข้าไปแทนที่ — เห็นตัวเลขดาเมจ**สีทอง ตัวเล็ก** ลอยขึ้น พร้อมจอสั่นเบาๆ |
| ตีซ้ำจนเลือดหมด (โดยเฉพาะด้วยหมากแรงอย่างควีน) | เหยื่อ**แตกกระจายเป็นเศษชิ้น** พร้อมฝุ่นและวงแหวนกระแทกพื้น ผู้โจมตีขยับเข้าไปแทนที่จริง — เห็นตัวเลขดาเมจ**สีแดง ตัวใหญ่เด้งเขย่าแรง** พร้อม**จอสั่นแรงชัดเจน** |
| เทียบการตีเบา (เบี้ย) กับตีแรง (ควีน) ติดกัน | ขนาดตัวเลข/แรงเขย่าตัวเลข/แรงสั่นจอ ต้องต่างกันชัดเจนตามพลังโจมตี ไม่ใช่เท่ากันหมด |
| ลองเดินหมากธรรมดา (ไม่กิน) | ทำงานปกติทุกอย่าง ไม่มีอะไรเปลี่ยน ไม่มีจอสั่น |
| ลองทำให้คิงถูกรุก/รุกฆาต | ยังทำงานถูกต้องเหมือนเดิมทุกกรณี (ไม่กระทบเลย เพราะ `chess_rules.gd` ไม่ถูกแก้) |

### 11.7 ต่อสาย SFX เข้ากับเดิน/ตี/ตาย

ตอนที่ 10 สร้าง `AudioManager.play_sfx()` และ bus "SFX" ไว้พร้อมใช้แล้ว แต่ยังไม่มีจุดไหนในเกม
เรียกมันเลย — ตอนนี้ต่อสายเข้ากับ 3 จังหวะที่ทำไว้แล้วในตอนที่ 11: เดินเฉยๆ / ตีไม่ตาย (bounce) /
ตีตายจริง (capture)

1. **เตรียมไฟล์เสียง** วางไว้ที่ `asset/audio/` (โฟลเดอร์เดียวกับเพลง ไม่ต้องแยกโฟลเดอร์ย่อยก็ได้):
   เสียงเดิน (เช่น `footsteps.mp3`), เสียงตีไม่ตาย (เช่น `punchsound.mp3`), เสียงตีตาย/ปะทะหนักกว่า
   (เช่น `Film Punch.mp3`)
2. เปิดไฟล์ `script/Board.gd`
3. หาบรรทัด `const ROWS := 8` แล้วเพิ่มค่าคงที่นี้ต่อท้าย:

```gdscript
const SFX_MOVE := preload("res://asset/audio/footsteps.mp3")  # เสียงเดินหมากปกติ (ไม่มีการกิน)
```

4. ในฟังก์ชัน `try_move()` หาบล็อก `if captured != null: / else:` ที่ตัดสินใจเรียก `_play_capture()`
   หรือ `_place_visual()`
5. เติมเสียงเข้าไปที่ branch `else` (เดินเฉยๆ ไม่มีการกิน — เสียงกินอยู่ในจังหวะปะทะของ
   `play_capture()`/`play_attack_bounce()` แทน ไม่ต้องเล่นซ้ำตรงนี้) จนบล็อกทั้งหมดหน้าตาเป็นแบบนี้:

```gdscript
	if captured != null:
		move_tweens.append(_play_capture(piece, captured, to_cell))
	else:
		AudioManager.play_sfx(SFX_MOVE)
		move_tweens.append(_place_visual(piece, to_cell, true))
```

6. กด `Ctrl+S` เซฟไฟล์ `Board.gd`
7. เปิดไฟล์ `script/piece_spawner.gd`
8. หาบรรทัด `SHATTER_FLY_DURATION` แล้วเพิ่มค่าคงที่ 2 ตัวนี้ต่อท้าย:

```gdscript
const SFX_KILL := preload("res://asset/audio/Film Punch.mp3")  # ตีตายจริง (play_capture)
const SFX_HIT := preload("res://asset/audio/punchsound.mp3")   # ตีไม่ตาย (play_attack_bounce)
```

9. หาฟังก์ชัน `play_capture()` แล้วเติมเสียงเข้าไปในจังหวะปะทะ (ที่เดียวกับที่สั่งเหยื่อล้ม +
   โชว์รอยฟัน) จนตรงนั้นหน้าตาเป็นแบบนี้:

```gdscript
	# 2) จังหวะปะทะ: สั่งเหยื่อเริ่มสะบัด/ล้ม + โชว์รอยฟัน + เสียงตีตาย (รันแยก ไม่บล็อกคิวหลัก) แล้วหยุดนิ่งสั้นๆ
	tween.tween_callback(_play_victim_death.bind(victim))
	tween.tween_callback(_spawn_slash_effect.bind(victim.position))
	tween.tween_callback(AudioManager.play_sfx.bind(SFX_KILL))
	tween.tween_interval(IMPACT_HOLD)
```

10. หาฟังก์ชัน `play_attack_bounce()` แล้วทำแบบเดียวกันด้วยเสียงคนละอัน:

```gdscript
	tween.tween_callback(_play_victim_hit.bind(victim))
	tween.tween_callback(_spawn_slash_effect.bind(victim.position))
	tween.tween_callback(AudioManager.play_sfx.bind(SFX_HIT))
	tween.tween_interval(IMPACT_HOLD)
```

11. กด `Ctrl+S` เซฟไฟล์ `piece_spawner.gd`

> **`AudioManager.play_sfx.bind(SFX_KILL)` คืออะไร?** `.bind()` สร้าง `Callable` ที่ผูกอาร์กิวเมนต์
> ไว้ล่วงหน้า — เทียบเท่ากับเขียนฟังก์ชันแยกแล้วเรียก `AudioManager.play_sfx(SFX_KILL)` ข้างใน แต่สั้นกว่า
> ใช้แพตเทิร์นเดียวกับ `_play_victim_death.bind(victim)` ที่มีอยู่แล้วในโค้ดชุดนี้

**✅ ทดสอบแล้วด้วยสคริปต์แยก:** จำลอง `e4 → d5 → exd5` ผ่าน `Board.try_move()` จริง (ไม่ผ่าน UI)
ทั้ง 3 ตาเดินสำเร็จ (`true`) ไม่มี error/crash แม้รันแบบ headless (ไม่มีอุปกรณ์เสียงจริง) — ยืนยันว่า
เรียก `AudioManager.play_sfx()` ปลอดภัยแม้ไม่มีเสียงให้ได้ยินจริงในสภาพแวดล้อมทดสอบ

**ทดสอบในเกมจริงที่ต้องลองเอง:** คลิกเดินหมากธรรมดา → ได้ยินเสียงเดิน, ตีหมากที่เลือดยังเหลือ →
ได้ยินเสียงตีไม่ตาย, ตีจนตาย → ได้ยินเสียงตีตาย (คนละเสียงกับตีไม่ตาย), เข้า **Setting** ลาก slider
SFX ลงสุด → เสียงเอฟเฟกต์เงียบแต่เพลงพื้นหลังยังเล่นอยู่ (คนละ bus กัน)

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** เสียงคลิกเลือกหมาก, เสียงปุ่ม UI (เมนู/pause), เสียงรุกฆาต/จบเกม
> ยังไม่มีจุดไหนเรียก `play_sfx()` เลย — ใช้แพตเทิร์นเดียวกับด้านบน (`preload()` + `AudioManager.play_sfx()`)
> เพิ่มได้ที่ `click_to_move.gd` (`_try_select()`) และ `main.gd` (`_on_game_ended()`) ตามลำดับ

### 11.8 Passive Skill ต่อชนิดหมาก (เรือ + ควีน + เบี้ย + ม้า)

หมากแต่ละชนิดควรรู้สึกต่างกันตอนต่อสู้ ไม่ใช่แค่ตัวเลข `attack_power`/`hp` ต่างกันเฉยๆ — เพิ่ม
"passive skill" ที่ปรับดาเมจตามเงื่อนไขเฉพาะของหมากแต่ละชนิด แยกเป็นไฟล์ใหม่ต่างหากตามแพตเทิร์น
เดิมของโปรเจกต์ (สมองแยกจาก node เหมือน `chess_rules.gd`/`chess_ai.gd`) ทำ 4 ชนิดแรก
(**เรือ, ควีน, เบี้ย, ม้า**) วางโครงให้ขยายไปอีก 2 ชนิด (บิชอป/คิง) ทีหลังได้ง่าย

**ออกแบบไว้:**

| หมาก | Passive | กลไก | ต้องรู้อะไรเพิ่ม |
|---|---|---|---|
| **เรือ (Rook)** | ป้อมปราการ | ถ้ายังไม่เคยขยับเลย (`has_moved == false`) → ลดดาเมจที่ได้รับ 30% | แค่ตัวหมากเอง |
| **ควีน (Queen)** | โค่นล้ม | ถ้าเป้าหมายเหลือเลือด ≤25% → ดาเมจ x2 | แค่ตัวหมากทั้งคู่ |
| **เบี้ย (Pawn)** | แนวรบเหล็ก | มีเบี้ยฝ่ายเดียวกันอยู่ช่องข้างๆ (ซ้าย/ขวา แถวเดียวกัน) → ลดดาเมจที่ได้รับ 20% | **ตำแหน่งบนกระดาน** ของเหยื่อ |
| **ม้า (Knight)** | จู่โจมครั้งแรก | โจมตีครั้งแรกสุดในเกมของตัวเอง → ดาเมจ +25% | ตัวแปร**ความจำ**ว่าเคยโจมตีมาก่อนไหม |

**เบี้ยกับม้าต้องการข้อมูลคนละแบบจาก Rook/Queen เดิม:**
- เบี้ยต้องรู้**ตำแหน่งบนกระดาน**ของเหยื่อถึงจะเช็คช่องข้างๆ ได้ → `compute_damage()` ต้องขยาย
  signature เพิ่ม `state` (กระดาน) กับ `victim_cell` (ตำแหน่ง)
- ม้าต้องมี "ความจำ" ว่าเคยโจมตีมาก่อนหรือยัง → เพิ่มตัวแปรใหม่ `has_attacked` ใน `chess_piece.gd`

**จุดที่ต้องระวังเป็นพิเศษ (แบบเดียวกับตอนทำ Rook/Queen):** ตอนกินผ่าน (en passant) เหยื่อ
**ไม่ได้อยู่ที่ `to_cell`** แต่อยู่ข้างๆ — ต้องคำนวณตำแหน่งเหยื่อจริงแยกต่างหาก ไม่งั้น "แนวรบเหล็ก"
จะเช็คช่องผิดตำแหน่ง

**STEP 1 — เพิ่มตัวแปร `has_attacked` ใน `chess_piece.gd`**

1. เปิดไฟล์ `script/chess_piece.gd`
2. หาบรรทัด `var attack_power: float = 1.0`
3. เพิ่มบรรทัดใหม่ต่อท้าย:

```gdscript
var attack_power: float = 1.0
var has_attacked: bool = false  # เคยโจมตีสำเร็จมาก่อนไหม (ใช้ตัดสิน passive "จู่โจมครั้งแรก" ของม้า)
```

4. กด `Ctrl+S` เซฟไฟล์ `chess_piece.gd`

**STEP 2 — สร้าง/เขียนทับ `script/passive_skills.gd`**

1. คลิกขวาโฟลเดอร์ `script` ในแผง FileSystem → **Create New → Script...**
2. Inherits: `RefCounted`, Path: `res://script/passive_skills.gd` → **Create**
3. ลบโค้ด template ที่ Godot ใส่มาให้ทิ้งทั้งหมด แล้ววางโค้ดนี้แทน:

```gdscript
extends RefCounted
class_name PassiveSkills

## Passive skill ของหมากแต่ละชนิด — ปรับดาเมจตอนโจมตี ตามชนิดของ "ผู้โจมตี" และ "เหยื่อ"
## เรียกจาก Board.try_move() แทนการใช้ attacker.attack_power ตรงๆ
##
## แต่ละ passive คำนวณเป็น "ตัวคูณ" แยกอิสระจากกัน แล้วคูณรวมกันตอนจบใน compute_damage()
## เพิ่ม/ถอด passive ตัวใหม่ทีหลัง แค่เพิ่มเงื่อนไขใน _attacker_multiplier()/_victim_multiplier()
## โดยไม่กระทบ passive ตัวอื่นที่มีอยู่แล้วเลย — ยังไม่ทำ: บิชอป/คิง (เพิ่มทีหลังได้)
##
## ⚠️ ทำไมต้องรับ state + victim_cell เพิ่ม — passive ของเบี้ย ("แนวรบเหล็ก") ต้องเช็คว่ามีเบี้ย
## ฝ่ายเดียวกันอยู่ช่องข้างๆ ไหม ซึ่งต้องรู้ตำแหน่งบนกระดานของเหยื่อถึงจะเช็คได้ — Rook/Queen เดิม
## ไม่ต้องใช้ 2 ค่านี้เลย (ใส่ underscore หน้าพารามิเตอร์ที่ไม่ได้ใช้ในฟังก์ชันที่ไม่เกี่ยวกับตำแหน่ง)

const QUEEN_EXECUTE_HP_THRESHOLD := 0.25  # เหยื่อเลือดเหลือ ≤25% ควีนโค่นล้มดาเมจ x2
const QUEEN_EXECUTE_MULTIPLIER := 2.0

const ROOK_FORTIFY_REDUCTION := 0.30  # เรือที่ยังไม่เคยขยับเลย ลดดาเมจที่ได้รับ 30%

const PAWN_SHIELDWALL_REDUCTION := 0.20  # เบี้ยที่มีเบี้ยฝ่ายเดียวกันอยู่ช่องข้างๆ ลดดาเมจที่ได้รับ 20%

const KNIGHT_FIRST_STRIKE_MULTIPLIER := 1.25  # ม้าโจมตีครั้งแรกสุดในเกมของตัวเอง ดาเมจ +25%

## คำนวณดาเมจจริงที่เหยื่อจะได้รับ หลังคิด passive ของทั้งผู้โจมตีและเหยื่อแล้ว
## เรียกแทนการใช้ attacker.attack_power ตรงๆ ทุกที่ที่มีการคำนวณดาเมจ (ทั้งเกมจริงและ AI จำลอง)
## state + victim_cell คือกระดานปัจจุบันและตำแหน่งของเหยื่อ (ดูคำเตือนหัวไฟล์ว่าทำไมต้องมี)
static func compute_damage(attacker: ChessPiece, victim: ChessPiece, state: Array, victim_cell: Vector2i) -> float:
	var damage := attacker.attack_power
	damage *= _attacker_multiplier(attacker, victim)
	damage *= _victim_multiplier(attacker, victim, state, victim_cell)
	return damage

## ตัวคูณดาเมจจากฝั่ง "ผู้โจมตี" — ควีน: โค่นล้ม / ม้า: จู่โจมครั้งแรก
static func _attacker_multiplier(attacker: ChessPiece, victim: ChessPiece) -> float:
	var multiplier := 1.0
	if attacker.piece_kind == ChessPiece.Kind.QUEEN and victim.max_hp > 0.0:
		var hp_ratio: float = victim.hp / victim.max_hp
		if hp_ratio <= QUEEN_EXECUTE_HP_THRESHOLD:
			multiplier *= QUEEN_EXECUTE_MULTIPLIER
	if attacker.piece_kind == ChessPiece.Kind.KNIGHT and not attacker.has_attacked:
		multiplier *= KNIGHT_FIRST_STRIKE_MULTIPLIER
	return multiplier

## ตัวคูณดาเมจจากฝั่ง "เหยื่อ" — เรือ: ป้อมปราการ / เบี้ย: แนวรบเหล็ก
static func _victim_multiplier(_attacker: ChessPiece, victim: ChessPiece, state: Array, victim_cell: Vector2i) -> float:
	var multiplier := 1.0
	if victim.piece_kind == ChessPiece.Kind.ROOK and not victim.has_moved:
		multiplier *= (1.0 - ROOK_FORTIFY_REDUCTION)
	if victim.piece_kind == ChessPiece.Kind.PAWN and _has_allied_pawn_beside(state, victim_cell, victim.side):
		multiplier *= (1.0 - PAWN_SHIELDWALL_REDUCTION)
	return multiplier

## มีเบี้ยฝ่ายเดียวกันยืนอยู่ช่องซ้ายหรือขวา (แถวเดียวกัน) ของ cell ไหม
static func _has_allied_pawn_beside(state: Array, cell: Vector2i, side: int) -> bool:
	for dx in [-1, 1]:
		var check_col: int = cell.x + dx
		if check_col < 0 or check_col >= 8:
			continue
		var neighbor: ChessPiece = state[cell.y][check_col]
		if neighbor != null and neighbor.piece_kind == ChessPiece.Kind.PAWN and neighbor.side == side:
			return true
	return false
```

4. กด `Ctrl+S` เซฟไฟล์ `passive_skills.gd`

> ⚠️ **`var check_col: int = cell.x + dx` ต้องระบุ type ตรงๆ ห้ามใช้ `:=`** — เจอปัญหานี้มาแล้วจริง
> ตอนแรกเขียน `var check_col := cell.x + dx` แล้วได้ error
> `Cannot infer the type of "check_col" variable because the value doesn't have a set type`
> สาเหตุ: `dx` มาจาก `for dx in [-1, 1]` ซึ่งเป็น array literal ที่ Godot ไม่รู้ type ชัดเจนล่วงหน้า
> (เจอรูปแบบปัญหาเดียวกันนี้มาแล้วหลายรอบในโปรเจกต์ ดูตาราง "ปัญหาที่พบบ่อย" ท้ายตอนที่ 12)

> ⚠️ **ตั้งชื่อไฟล์ให้ถูกตั้งแต่ตอนสร้าง** — เจอปัญหานี้มาแล้วจริง: สร้างสคริปต์ใหม่ใน Godot แล้วลืม
> เปลี่ยนชื่อจาก `new_script.gd` (ชื่อ default) เป็น `passive_skills.gd` ก่อนพิมพ์โค้ด พอมีทั้ง
> `new_script.gd` และ `passive_skills.gd` ประกาศ `class_name PassiveSkills` ซ้ำกัน 2 ไฟล์ →
> `Parse Error: Class "PassiveSkills" hides a global script class` ทันทีที่เปิดโปรเจกต์
> วิธีแก้ถ้าเจอ: ลบไฟล์ที่ชื่อผิด (`new_script.gd`) ทิ้ง เหลือไว้แค่ไฟล์ที่ตั้งชื่อถูกไฟล์เดียว

> ทำไมแยก `_attacker_multiplier` กับ `_victim_multiplier` เป็น 2 ฟังก์ชัน — เพราะ passive บางตัวขึ้นกับ
> "ใครเป็นคนตี" (ควีน/ม้า) บางตัวขึ้นกับ "ใครโดนตี" (เรือ/เบี้ย) แยกกันชัดเจนจะได้ไม่ต้องงงว่า `if`
> แต่ละอันเช็คฝั่งไหน พอจะเพิ่มบิชอป/คิงทีหลัง แค่รู้ว่ามันเป็น passive ของ "ผู้โจมตี" หรือ "เหยื่อ"
> ก็ไปเติมในฟังก์ชันที่ถูกต้องได้เลย

**STEP 3 — ต่อเข้ากับ `Board.gd`**

1. เปิดไฟล์ `script/Board.gd`
2. หาฟังก์ชัน `try_move()` แล้วมองหาบล็อกนี้ (อยู่ใต้คอมเมนต์ "ขั้นที่ 1"):

```gdscript
	var lethal := true  # ไม่มีการกินเลย ก็ถือว่า "ผ่าน" ได้ปกติเหมือนเดิม
	if captured != null:
		lethal = captured.take_damage(piece.attack_power)
		piece_attacked.emit(piece, captured, piece.attack_power, lethal)
```

3. แก้บล็อกนั้นเป็นแบบนี้แทน (หาตำแหน่งเหยื่อจริงก่อน เผื่อกินผ่าน แล้วส่งเข้า `compute_damage()`
   พร้อมตั้ง `has_attacked`):

```gdscript
	var lethal := true  # ไม่มีการกินเลย ก็ถือว่า "ผ่าน" ได้ปกติเหมือนเดิม
	if captured != null:
		# ตำแหน่งจริงของเหยื่อ — กินผ่าน (en passant) เหยื่อไม่ได้อยู่ที่ to_cell แต่อยู่ข้างๆ
		var captured_cell: Vector2i = to_cell
		if is_en_passant:
			captured_cell = Vector2i(to_cell.x, from_cell.y)

		var damage := PassiveSkills.compute_damage(piece, captured, board_state, captured_cell)
		lethal = captured.take_damage(damage)
		piece_attacked.emit(piece, captured, damage, lethal)
		piece.has_attacked = true  # ใช้ตัดสิน passive "จู่โจมครั้งแรก" ของม้าตาถัดๆ ไป
```

4. กด `Ctrl+S` เซฟไฟล์ `Board.gd`

> ⚠️ `piece.has_attacked = true` ต้องอยู่**หลัง**บรรทัด `compute_damage()` เท่านั้น ไม่งั้นม้าจะไม่ได้
> โบนัสในการโจมตีครั้งแรกของมันเองเลย (เพราะ flag ถูกตั้งเป็น true ไปก่อนที่จะเช็ค)
>
> `piece_attacked` ที่ส่งค่า `damage` ออกไป เป็นตัวที่ `piece_spawner.gd` เอาไปโชว์เป็นตัวเลขลอย
> (`DamagePopup`) อยู่แล้ว เลยได้ตัวเลขที่ถูกต้องตาม passive ไปแสดงผลฟรีๆ ไม่ต้องแก้ `piece_spawner.gd` เลย

**STEP 4 — ต่อเข้ากับ AI (`chess_ai.gd`) กันประเมินผิด**

1. เปิดไฟล์ `script/chess_ai.gd`
2. หาฟังก์ชัน `_apply_hp_aware()` แล้วหาบล็อกนี้:

```gdscript
	var new_overrides: Dictionary = hp_overrides.duplicate()

	if captured == null:
		# ไม่มีการกิน — พฤติกรรมเหมือน ChessRules.apply() เดิมทุกอย่าง ไม่ต้องยุ่งกับเลือดเลย
		return {"state": ChessRules.apply(state, from, to, ep_target), "overrides": new_overrides}

	var remaining_hp: float = _effective_hp(captured, hp_overrides) - piece.attack_power
```

3. แก้บรรทัดสุดท้ายของบล็อกนั้นเป็นแบบนี้แทน (เพิ่มการหา `captured_cell` แบบเดียวกับ STEP 3):

```gdscript
	var new_overrides: Dictionary = hp_overrides.duplicate()

	if captured == null:
		# ไม่มีการกิน — พฤติกรรมเหมือน ChessRules.apply() เดิมทุกอย่าง ไม่ต้องยุ่งกับเลือดเลย
		return {"state": ChessRules.apply(state, from, to, ep_target), "overrides": new_overrides}

	# ตำแหน่งจริงของเหยื่อ — กินผ่าน (en passant) เหยื่อไม่ได้อยู่ที่ to แต่อยู่ข้างๆ
	var captured_cell: Vector2i = to
	if is_en_passant:
		captured_cell = Vector2i(to.x, from.y)

	var remaining_hp: float = _effective_hp(captured, hp_overrides) - PassiveSkills.compute_damage(piece, captured, state, captured_cell)
```

4. กด `Ctrl+S` เซฟไฟล์ `chess_ai.gd`

> ถ้าข้าม step นี้ AI จะยังคิดว่าทุกการโจมตีดาเมจเท่าเดิมตาม `attack_power` เฉยๆ ไม่รู้จัก passive
> เลยสักตัว — ตัดสินใจเดินหมากผิดจากความเป็นจริง (เจอปัญหาแบบนี้มาแล้วตอนทำ AI ให้รู้จักระบบเลือด
> ครั้งแรก ดูตอนที่ 9.1)
>
> **ข้อจำกัดที่ยอมรับได้:** AI จะยังไม่รู้เรื่อง "ม้าตัวนี้เคยโจมตีในกิ่งการค้นหานี้ไปแล้วหรือยัง"
> เพราะไม่ได้ทำ override เหมือน `hp` (อ่าน `attacker.has_attacked` ตัวจริงตรงๆ) — กระทบเฉพาะกรณี
> ค้นลึกมากๆ จนม้าตัวเดียวโจมตี 2 ครั้งในเส้นทางจำลองเดียวกัน ซึ่งแทบไม่เกิดที่ `SEARCH_DEPTH = 2`

**✅ ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`)** เรียก
`PassiveSkills.compute_damage()` ตรงๆ 9 กรณี (5 กรณีของ Rook/Queen จากก่อนหน้า + 4 กรณีใหม่)
บวกทดสอบ integration ผ่าน `Board.try_move()` จริงอีก 5 ตา (รวมกินผ่าน en passant) ผ่านหมดทุกกรณี:

| กรณี | คาดหวัง | ผลจริง |
|---|---|---|
| เบี้ย (atk 20) ตีเบี้ยที่มีเบี้ยฝ่ายเดียวกันอยู่ข้างๆ | 20 × 0.8 = 16 | 16.0 ✅ |
| เบี้ยตีเบี้ยที่ไม่มีเบี้ยข้างๆ | 20 (ปกติ) | 20.0 ✅ |
| ม้า (atk 30) โจมตีครั้งแรกในเกม | 30 × 1.25 = 37.5 | 37.5 ✅ |
| ม้าตัวเดิมโจมตีครั้งที่ 2 | 30 (ปกติ ไม่มีโบนัส) | 30.0 ✅ |
| กินผ่าน (en passant) ที่ต้องหาตำแหน่งเหยื่อจริงถึงจะเช็ค "แนวรบเหล็ก" ได้ | เดินผ่าน `Board.try_move()` ได้ไม่ error | `true` ทุกตา ✅ |

**ทดสอบในเกมจริงที่ต้องลองเอง:**

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| ตีเรือฝ่ายตรงข้ามที่ยังไม่เคยขยับเลย | ดาเมจลอยขึ้น**น้อยกว่าปกติ 30%** |
| ใช้ควีนตีเป้าหมายที่เลือดเหลือน้อย (≤25%) | ดาเมจลอยขึ้น**เป็น 2 เท่า** |
| ตีเบี้ยที่มีเบี้ยฝ่ายเดียวกันยืนติดข้างๆ | ดาเมจลอยขึ้น**น้อยกว่าปกติ 20%** |
| ตีเบี้ยตัวเดียวโดดๆ ไม่มีเบี้ยข้างๆ | ดาเมจปกติเต็ม |
| ใช้ม้าโจมตีเป็นครั้งแรกในเกม | ดาเมจ**มากกว่าปกติ 25%** |
| ใช้ม้าตัวเดิมโจมตีอีกครั้ง (ครั้งที่ 2 เป็นต้นไป) | ดาเมจกลับมาปกติ ไม่มีโบนัสอีก |
| ลองกินผ่าน (en passant) ที่เบี้ยฝ่ายตรงข้ามมีเบี้ยข้างๆ | ต้องเช็คช่องถูกตำแหน่ง (ตำแหน่งจริงของเหยื่อ ไม่ใช่ช่องว่างที่ผู้โจมตีไปจอด) — ดาเมจลดถูกต้อง |

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** passive ของบิชอป/คิง — เพิ่มเงื่อนไขใน
> `_attacker_multiplier()`/`_victim_multiplier()` ของ `passive_skills.gd` ได้เลยตามแพตเทิร์นเดิม
> ไม่ต้องแก้ `Board.gd`/`chess_ai.gd` อีก (2 ไฟล์นั้นเรียก `compute_damage()` ผ่านกลางอยู่แล้ว)
> ยังไม่มี UI/ไอคอนบอกผู้เล่นว่าหมากตัวไหนมี passive ทำงานอยู่ด้วย — รู้ได้แค่จากตัวเลขดาเมจที่เปลี่ยนไป

### 11.9 สกิลกดใช้เอง (active skills) — ปุ่มลอยเหนือหัวหมาก

ตอนที่ 11.8 ทำ **passive skill** (โบนัสอัตโนมัติตามเงื่อนไข ไม่ต้องกดอะไร) ไปแล้ว ตอนนี้เพิ่มอีก
ชั้นคือ **active skill** — หมากทุกชนิดมีท่าพิเศษของตัวเอง 1 ท่า **ใช้ได้ครั้งเดียวต่อเกม** กดปุ่มที่
ลอยขึ้นเหนือหัวหมากตอนเลือกไว้แทนการเดิน (เสียตาเหมือนเดิน แต่ตัวหมากไม่ขยับ) — คนละกลไกกับ
passive แต่**ทำงานร่วมกันได้** เพราะ passive ปรับ "ตัวคูณดาเมจตามเงื่อนไข" ส่วน active buff (ม้า/ควีน)
ปรับ "ตัวคูณดาเมจจากการกดใช้เอง" คูณต่อกันได้เลยไม่ชนกัน

**ออกแบบไว้ (ทุกชนิดใช้ได้ครั้งเดียวต่อเกมเหมือนกันหมด เพื่อความง่าย — อยากได้แบบ cooldown ใช้ซ้ำได้
ทุก N ตา ค่อยทำต่อยอดทีหลัง):**

| หมาก | สกิล |
|---|---|
| เบี้ย | ฮีลตัวเอง +40 |
| ม้า | โจมตีครั้งถัดไปแรงขึ้น ×1.5 (คูณต่อจาก passive จู่โจมครั้งแรกได้ด้วย) |
| บิชอป | ฮีลตัวเองเต็ม |
| เรือ | เสริมเกราะ (+30 เลือดสูงสุด ถาวร) |
| ควีน | โจมตีครั้งถัดไปแรงขึ้น ×2 (คูณต่อจาก passive โค่นล้มได้ด้วย) |
| คิง | ปลุกใจ — ฮีลหมากฝ่ายเดียวกัน**ทุกตัว** +20 |

**จุดที่ต้องคิดก่อนลงมือ — ปุ่มนี้ต้องรับคลิกได้ แต่ไม่ชนกับระบบคลิกเดินหมากที่มีอยู่แล้ว:**
ไม่ใช้ `Area2D`/`Button` จริง (เสี่ยงชนกับ physics picking ของระบบคลิกเดิม) แต่ทำเป็น node
วาดภาพเฉยๆ แล้วให้ `click_to_move.gd` (ตัวที่ฟัง input การคลิกทั้งหมดอยู่แล้ว) **เช็คระยะจากจุดคลิก
ไปยังตำแหน่งปุ่มเอง** ก่อนตีความเป็นคลิกเดินหมากปกติ — แพตเทิร์นเดียวกับ `_piece_cell_under()`
ที่มีอยู่แล้วซึ่งก็เช็คระยะแบบมือเหมือนกัน

ไฟล์ที่แก้ 4 ไฟล์ + ไฟล์ใหม่ 1 ไฟล์:

**STEP 1 — สร้าง `script/skill_button.gd`**

1. คลิกขวาโฟลเดอร์ `script` → **Create New → Script...**
2. Inherits: `Node2D`, Path: `res://script/skill_button.gd` → **Create**
3. ลบโค้ด template ทิ้ง วางนี้แทน — **ไม่ต้องผูกกับ node ไหนในฉาก** (ถูกสร้างเองด้วยโค้ดตอนรันเกม
   เหมือน `SlashEffect`/`ImpactRing`/`DamagePopup`)

```gdscript
extends Node2D
class_name SkillButton

## ไอคอนปุ่ม "ใช้สกิล" ลอยเหนือหัวหมากที่เลือกอยู่ — รูปร่าง/สีเปลี่ยนตามประเภทสกิลของหมากตัวนั้น
## วาดด้วยโค้ดล้วนๆ ไม่ต้องมี asset ตัวเองไม่รับคลิกจริง (ดู click_to_move.gd ที่เช็คระยะเอง)
##
## ต้องเรียก setup() ก่อน add_child() เสมอ (เหมือน DamagePopup.setup()) เพราะ _draw()
## ต้องรู้ก่อนว่าไอคอนควรเป็นแบบไหน

const HIT_RADIUS := 24.0

var _icon_kind: String = "heal"

## แบ่งกลุ่มไอคอนตามชนิดหมาก — ต้องตรงกับที่ Board._apply_skill() คืนค่า effect_kind จริงตอนใช้:
## เบี้ย/บิชอป/เรือ = "heal", ม้า/ควีน = "buff", คิง = "rally"
func setup(piece_kind: int) -> void:
	match piece_kind:
		ChessPiece.Kind.PAWN, ChessPiece.Kind.BISHOP, ChessPiece.Kind.ROOK:
			_icon_kind = "heal"
		ChessPiece.Kind.KNIGHT, ChessPiece.Kind.QUEEN:
			_icon_kind = "buff"
		ChessPiece.Kind.KING:
			_icon_kind = "rally"

func _ready() -> void:
	z_index = 8  # เหนือทุกเอฟเฟกต์ รวมถึงตัวเลขดาเมจ (z_index 7)

func _draw() -> void:
	var bg_color: Color
	match _icon_kind:
		"heal": bg_color = Color(0.25, 0.75, 0.35, 0.92)
		"buff": bg_color = Color(0.95, 0.55, 0.15, 0.92)
		"rally": bg_color = Color(0.35, 0.55, 0.95, 0.92)
		_: bg_color = Color(0.25, 0.55, 1.0, 0.9)

	draw_circle(Vector2.ZERO, HIT_RADIUS, bg_color)
	draw_arc(Vector2.ZERO, HIT_RADIUS, 0.0, TAU, 32, Color(1.0, 1.0, 1.0, 0.95), 3.0, true)

	match _icon_kind:
		"heal":
			_draw_cross()
		"buff":
			_draw_lightning()
		"rally":
			_draw_star()

## เครื่องหมายบวก (+) สำหรับสกิลฮีล/เสริมเกราะ
func _draw_cross() -> void:
	var w := 6.0
	var l := 16.0
	draw_rect(Rect2(Vector2(-w * 0.5, -l * 0.5), Vector2(w, l)), Color.WHITE)
	draw_rect(Rect2(Vector2(-l * 0.5, -w * 0.5), Vector2(l, w)), Color.WHITE)

## สายฟ้าสำหรับสกิลบัฟโจมตี
func _draw_lightning() -> void:
	var points := PackedVector2Array([
		Vector2(2, -14), Vector2(-8, 2), Vector2(-1, 2),
		Vector2(-2, 14), Vector2(8, -2), Vector2(1, -2),
	])
	draw_colored_polygon(points, Color.WHITE)

## ดาว 5 แฉกสำหรับสกิลปลุกใจทีม
func _draw_star() -> void:
	var points := PackedVector2Array()
	var outer := 13.0
	var inner := 5.5
	for i in range(10):
		var angle := deg_to_rad(-90 + i * 36)
		var r := outer if i % 2 == 0 else inner
		points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, Color.WHITE)
```

> **ทำไมแบ่งกลุ่มไอคอนตาม `piece_kind` แทนที่จะรอผลจริงจาก `Board._apply_skill()`?** เพราะปุ่มต้อง
> โผล่**ก่อน**กดใช้สกิล (ตอนเลือกหมาก) — ตอนนั้นยังไม่มีค่า `effect_kind` จริงให้ใช้ (มันเป็นค่าที่
> `Board._apply_skill()` คืนกลับมา**หลัง**กดใช้แล้วเท่านั้น) จึงต้องเดาล่วงหน้าจากชนิดหมากแทน —
> ถ้าเพิ่มสกิลใหม่ทีหลังแล้วเปลี่ยนผลลัพธ์ของหมากชนิดไหน ต้องแก้ `setup()` ในไฟล์นี้ให้ตรงกับของจริง
> ใน `Board._apply_skill()` ด้วยเสมอ (สองจุดนี้ไม่ได้ผูกกันอัตโนมัติ)

**STEP 2 — แก้ `script/chess_piece.gd`** — เพิ่มข้อมูลสกิล

1. เปิดไฟล์ `script/chess_piece.gd`
2. หาบรรทัด `var attack_power: float = 1.0` (หรือ `var has_attacked: bool = false` ถ้าทำตอนที่ 11.8
   มาแล้ว)
3. เพิ่มโค้ดนี้ต่อท้ายบรรทัดนั้น (ก่อนถึง `static func base_attack`):

```gdscript
## --- ระบบสกิล --- ทุกชนิดหมากมีสกิลของตัวเอง 1 อัน ใช้ได้ครั้งเดียวต่อเกม (แทนการเดินในตานั้น)
var skill_used: bool = false

## คูณดาเมจของ "ตาถัดไปที่โจมตีสำเร็จ" (สกิลม้า/ควีน) แล้วรีเซ็ตกลับเป็น 1.0 อัตโนมัติหลังใช้ครั้งเดียว
var attack_buff_multiplier: float = 1.0

## หมากทุกชนิดมีสกิล (ตอนนี้ทุกอัน — เผื่ออนาคตอยากตัดบางชนิดออกได้ง่ายๆ)
static func has_skill(_kind: int) -> bool:
	return true

## คำอธิบายสกิลสั้นๆ ตามชนิดหมาก (เอาไว้โชว์ UI ทีหลังได้ถ้าต้องการ)
static func skill_label(kind: int) -> String:
	match kind:
		Kind.PAWN: return "ฮีล +40"
		Kind.KNIGHT: return "โจมตีตาถัดไปแรงขึ้น x1.5"
		Kind.BISHOP: return "ฮีลเต็ม"
		Kind.ROOK: return "เสริมเกราะ +30 เลือดสูงสุด"
		Kind.QUEEN: return "โจมตีตาถัดไปแรงขึ้น x2"
		Kind.KING: return "ปลุกใจฝ่ายเดียวกันทั้งหมด +20 เลือด"
		_: return ""

## ใช้สกิลได้ไหมตอนนี้ — ต้องเป็นชนิดที่มีสกิล และยังไม่เคยใช้มาก่อนในเกมนี้
func can_use_skill() -> bool:
	return has_skill(piece_kind) and not skill_used
```

4. กด `Ctrl+S` เซฟไฟล์ `chess_piece.gd`

**STEP 3 — แก้ `script/Board.gd`**

1. เปิดไฟล์ `script/Board.gd`
2. หาบล็อกดาเมจในตอนที่ 11.8 (STEP 3) — บรรทัดที่มี
   `var damage := PassiveSkills.compute_damage(piece, captured, board_state, captured_cell)`
3. เพิ่ม 2 บรรทัดนี้แทรกเข้าไปกลางบล็อก (เอาตัวคูณบัฟจากสกิลม้า/ควีนมาคูณต่อ) จนบล็อกทั้งหมด
   หน้าตาเป็นแบบนี้:

```gdscript
		var damage := PassiveSkills.compute_damage(piece, captured, board_state, captured_cell)
		damage *= piece.attack_buff_multiplier  # บัฟจากสกิลม้า/ควีน (ถ้าเพิ่งใช้) ใช้แล้วรีเซ็ตทันที
		piece.attack_buff_multiplier = 1.0
		lethal = captured.take_damage(damage)
		piece_attacked.emit(piece, captured, damage, lethal)
		piece.has_attacked = true  # ใช้ตัดสิน passive "จู่โจมครั้งแรก" ของม้าตาถัดๆ ไป
```

4. เลื่อนลงไปหาบรรทัด `return true` ที่อยู่ก่อน `func _evaluate_status() -> void:`
5. เพิ่มฟังก์ชันใช้สกิลนี้ตรงกลาง (คั่นระหว่าง `return true` กับ `func _evaluate_status()`):

```gdscript
## ใช้สกิลของหมากที่ cell แทนการเดิน (เสียตาเหมือนเดิน แต่ตัวหมากไม่ขยับ)
## ตอนนี้รองรับสกิลครบทุกชนิดตาม ChessPiece.skill_label() — เพิ่ม/แก้ผลลัพธ์ได้ที่ _apply_skill()
signal skill_used(piece: ChessPiece, effect_kind: String)

func try_use_skill(cell: Vector2i) -> bool:
	if animating or game_over:
		return false
	var piece: ChessPiece = ChessRules.at(board_state, cell)
	if piece == null or piece.side != side_to_move or not piece.can_use_skill():
		return false

	var effect_kind := _apply_skill(piece)
	piece.skill_used = true
	skill_used.emit(piece, effect_kind)

	last_move = [cell, cell]
	side_to_move = ChessRules.opponent(side_to_move)
	turn_changed.emit(side_to_move)
	_evaluate_status()
	return true

## ใช้ผลของสกิลจริง คืนชื่อประเภทเอฟเฟกต์ ("heal"/"buff"/"rally") ให้ piece_spawner.gd เลือกภาพให้ตรง
func _apply_skill(piece: ChessPiece) -> String:
	match piece.piece_kind:
		ChessPiece.Kind.PAWN:
			piece.hp = minf(piece.hp + 40.0, piece.max_hp)
			return "heal"
		ChessPiece.Kind.BISHOP:
			piece.hp = piece.max_hp
			return "heal"
		ChessPiece.Kind.ROOK:
			piece.max_hp += 30.0
			piece.hp += 30.0
			return "heal"
		ChessPiece.Kind.KNIGHT:
			piece.attack_buff_multiplier = 1.5
			return "buff"
		ChessPiece.Kind.QUEEN:
			piece.attack_buff_multiplier = 2.0
			return "buff"
		ChessPiece.Kind.KING:
			for row in board_state:
				for p in row:
					if p != null and p.side == piece.side:
						p.hp = minf(p.hp + 20.0, p.max_hp)
			return "rally"
		_:
			return ""
```

6. กด `Ctrl+S` เซฟไฟล์ `Board.gd`

**STEP 4 — แก้ `script/click_to_move.gd`**

1. เปิดไฟล์ `script/click_to_move.gd`
2. หาบรรทัด `var legal_targets: Array = []`
3. เพิ่มบรรทัดนี้ต่อท้าย (ตัวแปรเก็บปุ่มสกิล):
```gdscript
var skill_button: SkillButton = null
```

4. หาฟังก์ชัน `_handle_click()` แล้วหาบรรทัด
   `if GameManager.game_mode == "PVC" and board.side_to_move == ChessPiece.Team.BLACK: return`
   ข้างใน
5. แทรกโค้ดนี้ต่อท้ายบรรทัดนั้น (ก่อนบรรทัด `var cell := _cell_at_mouse()`) — เช็คว่าคลิก
   โดนปุ่มสกิลไหมก่อนอย่างอื่นทั้งหมด:
```gdscript
	# เช็คว่าคลิกโดนปุ่มสกิลไหมก่อนอย่างอื่นทั้งหมด (ต้องมีหมากถูกเลือกอยู่ก่อน ปุ่มถึงจะโผล่)
	if skill_button != null and is_instance_valid(skill_button):
		var mouse := get_global_mouse_position()
		if mouse.distance_to(skill_button.global_position) <= SkillButton.HIT_RADIUS:
			board.try_use_skill(selected_cell)
			_deselect()
			return
```

6. หาฟังก์ชัน `_try_select()` แล้วหาบรรทัด
   `_animate_scale(piece, piece.resting_scale * SELECTED_SCALE_MULT, true)`
7. เพิ่มบรรทัดนี้ต่อท้าย (โผล่ปุ่มตอนเลือกหมาก):
```gdscript
	_update_skill_button(piece)
```

8. หาฟังก์ชัน `_clear_selection_state()` แล้วเพิ่มบรรทัด `_clear_skill_button()` ก่อนบรรทัด
   `queue_redraw()` (ซ่อนปุ่มตอนล้างสถานะเลือก)
9. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันจัดการปุ่ม 2 อันนี้ต่อท้าย:
```gdscript
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
```

10. กด `Ctrl+S` เซฟไฟล์ `click_to_move.gd`

**STEP 5 — แก้ `script/piece_spawner.gd`** — เอฟเฟกต์ตอนใช้สกิล

1. เปิดไฟล์ `script/piece_spawner.gd`
2. หาบรรทัด `board.piece_attacked.connect(_on_piece_attacked)`
3. เพิ่มบรรทัดนี้ต่อท้าย (ต่อสัญญาณ `skill_used`):
```gdscript
	board.skill_used.connect(_on_skill_used)
```

4. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันเอฟเฟกต์ 2 อันนี้ต่อท้าย:
```gdscript
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
```

5. กด `Ctrl+S` เซฟไฟล์ `piece_spawner.gd`

> ⚠️ **`try_use_skill()` ไม่ผ่าน `legal_moves_for()`/`ChessRules` เลย** — ตั้งใจ เพราะการใช้สกิล
> ไม่ใช่ "การเดิน" ตามความหมายของหมากรุก ไม่ต้องเช็คว่าเดินได้ตามกติกาไหม แค่เช็คสิทธิ์
> (`can_use_skill()`) แล้วเสียตาไปเลย — ตอนที่เขียนส่วนนี้ (ตอนที่ 11.9) `ChessAI.best_move()`
> ยังเดินผ่าน `ChessRules.all_legal_moves()` เท่านั้น ทำให้ AI ไม่มีวันสั่งใช้สกิลเองเลย — **ข้อจำกัด
> นี้ถูกแก้แล้วในตอนที่ 11.26** (`ChessAI` พิจารณาการใช้สกิลเป็นตัวเลือกคู่ขนานกับตาเดินปกติแล้ว)
>
> ปุ่มสกิลอยู่ที่ `global_position` ตรงๆ ไม่ใช่ลูกของตัวหมาก (`piece.add_child(...)`) เพราะถ้าเป็นลูก
> ของหมาก ตอน `_animate_scale()` ขยายหมากเวลาเลือก ปุ่มจะโดนขยายเบี้ยวตามไปด้วย — เพิ่มเป็นลูกของ
> `ClickToMove` เอง (`add_child(skill_button)` ใน `_update_skill_button()`) แล้วคำนวณตำแหน่งแบบ
> world position ตรงๆ แทน

### ✅ ทดสอบ

**ทดสอบแบบเจาะจงทีละสกิล** (เรียก `board.try_use_skill(cell)` ตรงๆ ผ่านสคริปต์ ไม่ต้องรอคลิกเมาส์):

| สกิล | ทดสอบ | ผลที่ควรได้ |
|---|---|---|
| บิชอปฮีล | ลดเลือดบิชอปเหลือ 10 แล้วใช้สกิล | เลือดกลับเป็น 100 เต็ม, `skill_used = true`, ใช้ซ้ำไม่ได้อีก, เสียตาจริง (สลับฝ่าย) |
| ม้าบัฟ | ใช้สกิลม้า แล้วเช็คค่า | `attack_buff_multiplier` เปลี่ยนจาก 1.0 → 1.5 |
| คิงปลุกใจ | ลดเลือดเบี้ยตัวหนึ่งเหลือ 50 แล้วให้คิงใช้สกิล | เบี้ยตัวนั้น (ไม่ใช่แค่คิง) เลือดเพิ่มเป็น 70 |

**ทดสอบในเกมจริง:**

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| คลิกเลือกหมากฝ่ายตัวเองที่ยังไม่เคยใช้สกิล | ไอคอนวงกลมโผล่ลอยเหนือหลอดเลือด — เครื่องหมายบวกสีเขียว (เบี้ย/บิชอป/เรือ), สายฟ้าสีส้ม (ม้า/ควีน), ดาวสีน้ำเงิน (คิง) |
| กดปุ่มนั้น | เกิดผลตามสกิล (ฮีล/บัฟ/ปลุกใจ) พร้อมประกายสี, หมากไม่ขยับ, เสียตาไปฝ่ายตรงข้าม, ปุ่มหายไป (ใช้ไปแล้ว) |
| เลือกหมากตัวเดิมอีกครั้งหลังใช้สกิลไปแล้ว | **ไม่มีปุ่มสกิลโผล่อีก** (ใช้ได้ครั้งเดียวต่อเกมจริง) |
| ใช้สกิลม้า/ควีนแล้วโจมตีตาถัดไป | ดาเมจสูงกว่าปกติตามตัวคูณ (ม้า x1.5, ควีน x2) — ถ้าม้าโจมตีครั้งแรกในเกมด้วย จะได้โบนัส passive x1.25 คูณทบเข้าไปอีก |
| คลิกตำแหน่งอื่นบนกระดานที่ไม่ใช่ปุ่มสกิล ตอนปุ่มกำลังโชว์อยู่ | ทำงานปกติ (เดิน/ยกเลิก/เปลี่ยนตัวเลือก) เหมือนไม่มีปุ่มอยู่เลย ไม่ชนกัน |

> **อัปเดต:** ทุกข้อจำกัดที่เคยเขียนไว้ตรงนี้ถูกแก้แล้วในตอนหลัง — cooldown ใช้ซ้ำได้ทุก N ตา
> (ตอนที่ 11.13), tooltip โชว์คำอธิบายสกิล (ตอนที่ 11.15), และ AI ใช้สกิลเองได้ (ตอนที่ 11.26)

### 11.10 เติม SFX จุดที่ยังไม่มีเสียง — เสียงตีต่อชนิดหมาก + คลิกเลือก + ปุ่ม UI + รุกฆาต/จบเกม

ตอนที่ 11.7 ต่อสาย SFX ไว้แค่ 3 จังหวะ (เดิน/ตีไม่ตาย/ตีตาย) และบันทึกไว้ใน "ยังไม่ได้ทำ" ว่ายังขาด
เสียงคลิกเลือกหมาก, เสียงปุ่ม UI, เสียงรุกฆาต/จบเกม — ตอนนี้เติมให้ครบ พร้อมเพิ่มของใหม่อีกอย่าง คือ
**เสียงตีแยกตามชนิดหมาก** (แทนที่จะใช้ `SFX_KILL`/`SFX_HIT` เสียงเดียวกันหมดทุกตัว)

**ไฟล์เสียงที่ต้องมี** (หาจาก [Pixabay](https://pixabay.com) — ฟรี ไม่ต้องเครดิต — วางไว้ที่
`asset/audio/`):

| ไฟล์ | ใช้กับ | ชื่อเสียงต้นฉบับ (Pixabay) |
|---|---|---|
| `pawn_hit.mp3` | เบี้ยตี (เบา) | Punch 03 — Universfield |
| `knight_hit.mp3` | ม้าตี (ฟันไว) | Clean fast Swoosh.aiff — freesound_community |
| `bishop_hit.mp3` | บิชอปตี (เวทมนตร์) | Epic Spell Impact — DRAGON-STUDIO |
| `rook_hit.mp3` | เรือตี (หนักแน่น) | Boulder Impact — DRAGON-STUDIO |
| `queen_hit.mp3` | ควีนตี (เวทแรง) | Magic Burst — humordome |
| `king_hit.mp3` | คิงตี (สง่า) | Cinematic Impact Boom 05 — Universfield |
| `select_click.mp3` | คลิกเลือกหมาก | UI Radio Select — SoundShellStudio |
| `ui_button.mp3` | ปุ่ม UI ทุกปุ่ม (เมนู/pause) | Click Button — Universfield |
| `victory_fanfare.mp3` | รุกฆาต | Success Fanfare Trumpets — freesound_community |
| `game_over.mp3` | จบเกมแบบอื่น (เสมอ/อับ) | Game Over Orchestral Stinger — Coghezi |

**STEP 1 — เสียงตีต่อชนิดหมาก (แก้ `script/piece_spawner.gd`)**

1. เปิดไฟล์ `script/piece_spawner.gd`
2. หาบรรทัด:
```gdscript
const SFX_KILL := preload("res://asset/audio/Film Punch.mp3")  # ตีตายจริง (play_capture)
const SFX_HIT := preload("res://asset/audio/punchsound.mp3")   # ตีไม่ตาย (play_attack_bounce)
```
3. แก้เป็น (ทำเป็น fallback + เพิ่มเสียงต่อชนิดหมาก 6 บรรทัด):
```gdscript
const SFX_KILL := preload("res://asset/audio/Film Punch.mp3")  # ตีตายจริง (play_capture) — fallback
const SFX_HIT := preload("res://asset/audio/punchsound.mp3")   # ตีไม่ตาย (play_attack_bounce) — fallback

const SFX_PAWN_HIT := preload("res://asset/audio/pawn_hit.mp3")
const SFX_KNIGHT_HIT := preload("res://asset/audio/knight_hit.mp3")
const SFX_BISHOP_HIT := preload("res://asset/audio/bishop_hit.mp3")
const SFX_ROOK_HIT := preload("res://asset/audio/rook_hit.mp3")
const SFX_QUEEN_HIT := preload("res://asset/audio/queen_hit.mp3")
const SFX_KING_HIT := preload("res://asset/audio/king_hit.mp3")
```
4. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันนี้ต่อท้าย (เลือกเสียงตามชนิดหมากที่ "ตี"):
```gdscript
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
```
5. หาฟังก์ชัน `play_capture()` แล้วหาบรรทัด `tween.tween_callback(AudioManager.play_sfx.bind(SFX_KILL))`
6. แก้เป็น:
```gdscript
	tween.tween_callback(AudioManager.play_sfx.bind(_attack_sfx_for(attacker.piece_kind)))
```
7. หาฟังก์ชัน `play_attack_bounce()` แล้วหาบรรทัด `tween.tween_callback(AudioManager.play_sfx.bind(SFX_HIT))`
8. แก้เป็น:
```gdscript
	tween.tween_callback(AudioManager.play_sfx.bind(_attack_sfx_for(attacker.piece_kind)))
```
9. กด `Ctrl+S` เซฟไฟล์

> `SFX_KILL`/`SFX_HIT` เดิมยังเก็บไว้เป็น fallback ในฟังก์ชัน `_attack_sfx_for()` เผื่อ `kind` ไม่ตรง
> กับ 6 ชนิดหมาก (ไม่ควรเกิดแต่กันไว้)

**STEP 2 — เสียงคลิกเลือกหมาก (แก้ `script/click_to_move.gd`)**

1. เปิดไฟล์ `script/click_to_move.gd`
2. หาบรรทัด `const SELECT_DURATION := 0.32` แล้วเพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
const SFX_SELECT := preload("res://asset/audio/select_click.mp3")
```
3. หาฟังก์ชัน `_try_select()` แล้วหาบรรทัด
   `_animate_scale(piece, piece.resting_scale * SELECTED_SCALE_MULT, true)`
4. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
	AudioManager.play_sfx(SFX_SELECT)
```
5. กด `Ctrl+S` เซฟไฟล์

**STEP 3 — เสียงปุ่ม UI ในฉากเกม (แก้ `script/main.gd`)**

1. เปิดไฟล์ `script/main.gd`
2. หาบรรทัด `const GAMEPLAY_MUSIC := preload("res://asset/audio/BRAZILIAN PHONK.mp3")` แล้วเพิ่ม
   3 บรรทัดนี้ต่อท้าย:
```gdscript
const SFX_BUTTON := preload("res://asset/audio/ui_button.mp3")
const SFX_VICTORY := preload("res://asset/audio/victory_fanfare.mp3")  # รุกฆาต
const SFX_DEFEAT := preload("res://asset/audio/game_over.mp3")         # เสมอ/จบเกมแบบอื่น
```
3. หาฟังก์ชัน `_on_pause_pressed()` แล้วเพิ่ม `AudioManager.play_sfx(SFX_BUTTON)` เป็นบรรทัดแรกในฟังก์ชัน:
```gdscript
func _on_pause_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	if _finished:
```
4. หาฟังก์ชัน `_on_resume_pressed()` แล้วเพิ่ม `AudioManager.play_sfx(SFX_BUTTON)` เป็นบรรทัดแรก:
```gdscript
func _on_resume_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	pause_menu.visible = false
```
5. หาฟังก์ชัน `_on_restart_pressed()` แล้วเพิ่ม `AudioManager.play_sfx(SFX_BUTTON)` เป็นบรรทัดแรก:
```gdscript
func _on_restart_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	get_tree().paused = false
```
6. หาฟังก์ชัน `_on_main_menu_pressed()` แล้วเพิ่ม `AudioManager.play_sfx(SFX_BUTTON)` เป็นบรรทัดแรก:
```gdscript
func _on_main_menu_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	get_tree().paused = false          # ต้องคืนค่าก่อน เปลี่ยนฉากตอน paused=true จะค้าง
```
7. กด `Ctrl+S` เซฟไฟล์ `main.gd`

**STEP 4 — เสียงรุกฆาต/จบเกม (ไฟล์เดียวกับ STEP 3 — `script/main.gd`)**

1. หาฟังก์ชัน `_on_game_ended(result: String, winner: int) -> void:` แล้วหาบรรทัด `_finished = true`
2. เพิ่มโค้ดนี้ต่อท้ายบรรทัดนั้น (เล่นเสียงต่างกันตามผลจบเกม — รุกฆาต = แฟนแฟร์, อย่างอื่น = game over):
```gdscript
	if result == "checkmate":
		AudioManager.play_sfx(SFX_VICTORY)
	else:
		AudioManager.play_sfx(SFX_DEFEAT)
```
3. กด `Ctrl+S` เซฟไฟล์

**STEP 5 (ต่อยอดไม่บังคับ) — เสียงปุ่มในเมนูหลัก (แก้ `script/main_menu.gd`)**

STEP 3 ทำแค่ปุ่มในฉากเกม (pause menu) — ถ้าอยากให้ปุ่มในหน้าเมนูหลักมีเสียงคลิกด้วย:

1. เปิดไฟล์ `script/main_menu.gd`
2. เพิ่มบรรทัดนี้ไว้บนสุดของไฟล์ (ใต้ `extends Control`):
```gdscript
const SFX_BUTTON := preload("res://asset/audio/ui_button.mp3")
```
3. เพิ่ม `AudioManager.play_sfx(SFX_BUTTON)` เป็นบรรทัดแรกในทุกฟังก์ชัน `_on_..._pressed()` ทั้ง 4 ตัว
   (`_on_singleplayer_pressed`, `_on_multiplayer_pressed`, `_on_settings_pressed`, `_on_quit_pressed`)
   จนไฟล์หน้าตาเป็นแบบนี้:
```gdscript
func _on_singleplayer_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	GameManager.game_mode = "PVC"
	SceneTransition.change_scene("res://Scene/main.tscn")

func _on_multiplayer_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	GameManager.game_mode = "PVP"
	SceneTransition.change_scene("res://Scene/main.tscn")

func _on_settings_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	SceneTransition.change_scene("res://Scene/settings.tscn")

func _on_quit_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	get_tree().quit()
```
4. กด `Ctrl+S` เซฟไฟล์

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** จำลอง
`e4 → d5 → exd5` ผ่าน `Board.try_move()` จริงทั้ง 3 ตา ผ่านหมด (`true`) ไม่มี error/parse error
แม้รันแบบ headless — ยืนยันว่า `_attack_sfx_for()` เรียกได้ปลอดภัยและไฟล์เสียงใหม่ทั้ง 10 ไฟล์ import
ผ่านแล้ว (ต้องเปิด Godot editor อย่างน้อย 1 ครั้งก่อน เพื่อให้มันสร้างไฟล์ `.import` ให้ไฟล์เสียงใหม่ —
ถ้ายังไม่เคยเปิด editor เลยหลังก็อปไฟล์เสียงมาวาง จะเจอ error
`Preload file "..." has no resource loaders (unrecognized file extension)`)

**ทดสอบในเกมจริงที่ต้องลองเอง:**

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| คลิกเลือกหมากแต่ละตัว | ได้ยินเสียงคลิกสั้นๆ (`select_click`) ทุกครั้ง |
| ตีด้วยเบี้ย/ม้า/บิชอป/เรือ/ควีน/คิง (ทั้งตายและไม่ตาย) | เสียงตี**ต่างกันตามชนิดหมากที่ตี** ไม่ใช่เสียงเดียวกันหมด |
| กดปุ่ม Pause / Resume / Restart / Main Menu | ได้ยินเสียงคลิกปุ่ม (`ui_button`) ทุกปุ่ม |
| (ถ้าทำ STEP 5) กดปุ่มในเมนูหลัก | ได้ยินเสียงคลิกปุ่มเช่นกัน |
| เล่นจนรุกฆาต | ได้ยินเสียงแฟนแฟร์ชัยชนะ (`victory_fanfare`) |
| เล่นจนอับ/เสมอแบบอื่น | ได้ยินเสียง game over (`game_over`) แทน |
| ลาก slider SFX ใน Settings ลงสุด | เสียงใหม่ทั้งหมดเงียบไปด้วย (อยู่ bus "SFX" เดียวกับเสียงเดิม) |

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** เสียงตีของบิชอป/คิงยังไม่แยก passive/active skill (ใช้เสียงตี
> ปกติเหมือนโจมตีทั่วไป), ยังไม่มีเสียงตอน `check_alerted` (ฝ่ายถูกรุกแต่ยังไม่จบเกม)

### 11.11 Passive Skill ของบิชอปและคิง (เติมให้ครบ 6 ชนิด)

ตอนที่ 11.8 ทำ passive ไว้แค่ 4 ชนิดแรก (เรือ/ควีน/เบี้ย/ม้า) แล้ววางโครงไว้ให้ขยายบิชอป/คิงทีหลัง
ได้ง่าย — ตอนนี้เติมให้ครบทั้ง 6 ชนิด

**ออกแบบเพิ่ม:**

| หมาก | Passive | กลไก | ต้องรู้อะไรเพิ่ม |
|---|---|---|---|
| **บิชอป (Bishop)** | แสงชำระ | ตีเป้าหมายที่เลือดเต็ม (ยังไม่เคยโดนตี) → ดาเมจ +15% | แค่ตัวหมากทั้งคู่ |
| **คิง (King)** | ราชันคุ้มกัน | หมากฝ่ายเดียวกัน (รวมคิงเอง) ที่อยู่ในระยะประชิดคิง (8 ช่องรอบ + ตัวคิงเอง) → ลดดาเมจที่ได้รับ 15% | ตำแหน่งคิงฝ่ายเดียวกันบนกระดาน |

**STEP 1 — แก้ `script/passive_skills.gd`**

1. เปิดไฟล์ `script/passive_skills.gd`
2. หาบรรทัด `const KNIGHT_FIRST_STRIKE_MULTIPLIER := 1.25  # ม้าโจมตีครั้งแรกสุดในเกมของตัวเอง ดาเมจ +25%`
3. เพิ่ม 2 บรรทัดนี้ต่อท้าย:
```gdscript
const BISHOP_PURIFY_MULTIPLIER := 1.15  # บิชอปตีเป้าหมายที่เลือดเต็ม (ยังไม่เคยโดนตี) ดาเมจ +15%
const KING_ROYAL_GUARD_REDUCTION := 0.15  # หมากในระยะประชิดคิงฝ่ายเดียวกัน (รวมคิงเอง) ลดดาเมจที่ได้รับ 15%
```
4. หาฟังก์ชัน `_attacker_multiplier()` แล้วหาบรรทัด:
```gdscript
	if attacker.piece_kind == ChessPiece.Kind.KNIGHT and not attacker.has_attacked:
		multiplier *= KNIGHT_FIRST_STRIKE_MULTIPLIER
```
5. เพิ่มโค้ดนี้ต่อท้ายบรรทัดนั้น (ก่อน `return multiplier`):
```gdscript
	if attacker.piece_kind == ChessPiece.Kind.BISHOP and victim.max_hp > 0.0 and victim.hp >= victim.max_hp:
		multiplier *= BISHOP_PURIFY_MULTIPLIER
```
6. หาฟังก์ชัน `_victim_multiplier()` แล้วหาบรรทัด:
```gdscript
	if victim.piece_kind == ChessPiece.Kind.PAWN and _has_allied_pawn_beside(state, victim_cell, victim.side):
		multiplier *= (1.0 - PAWN_SHIELDWALL_REDUCTION)
```
7. เพิ่มโค้ดนี้ต่อท้ายบรรทัดนั้น (ก่อน `return multiplier`):
```gdscript
	if _is_near_allied_king(state, victim_cell, victim.side):
		multiplier *= (1.0 - KING_ROYAL_GUARD_REDUCTION)
```
8. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชัน helper 2 ตัวนี้ต่อท้าย:
```gdscript
## หา cell ของคิงฝ่าย side บนกระดาน คืน Vector2i(-1,-1) ถ้าหาไม่เจอ (ไม่ควรเกิดในเกมจริง — คิงตายไม่ได้)
static func _find_king_cell(state: Array, side: int) -> Vector2i:
	for row in range(state.size()):
		for col in range(state[row].size()):
			var p: ChessPiece = state[row][col]
			if p != null and p.piece_kind == ChessPiece.Kind.KING and p.side == side:
				return Vector2i(col, row)
	return Vector2i(-1, -1)

## cell อยู่ในระยะประชิดคิงฝ่าย side ไหม (รวมช่องที่คิงยืนอยู่เองด้วย) — ใช้ Chebyshev distance <= 1
static func _is_near_allied_king(state: Array, cell: Vector2i, side: int) -> bool:
	var king_cell := _find_king_cell(state, side)
	if king_cell == Vector2i(-1, -1):
		return false
	return maxi(absi(cell.x - king_cell.x), absi(cell.y - king_cell.y)) <= 1
```
9. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **`_is_near_allied_king` ใช้ `victim_cell` ไม่ใช่ตำแหน่ง `victim.position` จริง** — เหมือน
> `_has_allied_pawn_beside` เดิม เพราะ `state`/`victim_cell` คือกระดานตรรกะ (array) ไม่ใช่พิกัดหน้าจอ
> ปลอดภัยกับกรณีกินผ่าน (en passant) เหมือนเดิม เพราะ `Board.gd` คำนวณ `captured_cell` ที่ถูกต้องมาให้
> แล้วตั้งแต่ตอนที่ 11.8
>
> ไม่ต้องแก้ `Board.gd`/`chess_ai.gd` เลยสักบรรทัด — ทั้งคู่เรียก `PassiveSkills.compute_damage()`
> ผ่านกลางอยู่แล้วตั้งแต่ตอนที่ 11.8

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** เรียก
`PassiveSkills.compute_damage()` ตรงๆ จากตำแหน่งเริ่มเกมจริง ยืนยันตัวเลขตรงตามที่คาด — บิชอปตีควีน
ดำ (เลือดเต็ม, ยืนติดคิงดำพอดี) ได้ 30×1.15×0.85 = 29.325 (ทั้งโบนัสบิชอปและ Royal Guard ทำงานพร้อม
กัน), ตีเบี้ยขาวที่ยืนติดคิงขาวด้วยควีนดำ ได้ 60×0.85(Royal Guard)×0.80(shieldwall เดิม) = 40.8, ตี
คิงขาวเองได้ 60×0.85 = 51.0, ตีเบี้ยไกลคิงได้ 60×0.80(shieldwall) = 48.0 (ไม่มี Royal Guard) — ตัวคูณ
ทั้งหมดคูณรวมกันถูกต้องตามสูตรใน `compute_damage()`

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| ใช้บิชอปตีเป้าหมายที่เลือดยังเต็ม 100% | ดาเมจ +15% |
| ใช้บิชอปตีเป้าหมายที่เลือดลดไปแล้ว | ดาเมจปกติ ไม่มีโบนัส |
| ตีหมากที่ยืนติดคิงฝ่ายเดียวกัน (1 ช่องรอบคิง) | ดาเมจลด 15% |
| ตีคิงเอง (ถ้าทำได้ตามกติกาการจำลอง) | ดาเมจลด 15% เช่นกัน (คิงป้องกันตัวเองในระยะประชิด) |
| ตีหมากที่อยู่ไกลคิง (2 ช่องขึ้นไป) | ดาเมจปกติ |

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** ยังไม่มี UI/ไอคอนบอกผู้เล่นว่าหมากตัวไหนมี passive ทำงานอยู่
> (รู้ได้แค่จากตัวเลขดาเมจที่เปลี่ยนไป — เหมือนเดิมตั้งแต่ตอนที่ 11.8)

### 11.12 Promotion ให้ผู้เล่นเลือกเอง (แทนควีนอัตโนมัติ)

ตอนที่ 7 (`click_to_move.gd`) ตั้ง `auto_promote_to = ChessPiece.Kind.QUEEN` fix ไว้ตายตัว ทำให้เบี้ย
ถึงแถวสุดท้ายกลายเป็นควีนเสมอ — ตอนนี้เพิ่มป๊อปอัพ 4 ตัวเลือก (Q/R/B/N) ให้ผู้เล่นคลิกเลือกเอง
โผล่เหนือช่องปลายทางตอนเบี้ยเดินถึงแถวโปรโมท (เทคนิคเดียวกับ `skill_button.gd` ตอนที่ 11.9 —
วาดเอง ไม่ใช้ node คลิกได้จริง เช็คระยะคลิกเองใน `click_to_move.gd`)

**STEP 1 — สร้าง `script/promotion_picker.gd`**

1. คลิกขวาโฟลเดอร์ `script` ในแผง FileSystem → **Create New → Script...**
2. Inherits: `Node2D`, Path: `res://script/promotion_picker.gd` → **Create**
3. ลบโค้ด template ที่ Godot ใส่มาให้ทิ้งทั้งหมด แล้ววางโค้ดนี้แทน — **ไม่ต้องผูก script นี้กับ node
   ไหนในฉากเลย** เหมือน `skill_button.gd`:

```gdscript
extends Node2D
class_name PromotionPicker

## ป๊อปอัพให้ผู้เล่นเลือกว่าจะให้เบี้ยที่ถึงแถวสุดท้ายกลายเป็นหมากอะไร (ควีน/เรือ/บิชอป/ม้า)
## แทนที่จะกลายเป็นควีนอัตโนมัติเสมอ — โผล่เหนือช่องปลายทางตอนเบี้ยเดินถึงแถวโปรโมท
## click_to_move.gd เช็คระยะคลิกเอง (ไม่รับคลิกจริง) เทคนิคเดียวกับ skill_button.gd

const HIT_RADIUS := 26.0
const OPTION_SPACING := 60.0
const OPTIONS: Array = [
	ChessPiece.Kind.QUEEN, ChessPiece.Kind.ROOK, ChessPiece.Kind.BISHOP, ChessPiece.Kind.KNIGHT,
]
const OPTION_LABELS := ["Q", "R", "B", "N"]

func _ready() -> void:
	z_index = 9  # เหนือทุกอย่าง รวมถึงปุ่มสกิล (z_index 8)

## ตำแหน่งโลก (global) ของตัวเลือกลำดับที่ i (0-3) — ใช้เช็คระยะคลิกจาก click_to_move.gd
func option_global_position(i: int) -> Vector2:
	var offset_x: float = (i - 1.5) * OPTION_SPACING
	return global_position + Vector2(offset_x, 0)

func _draw() -> void:
	var font := ThemeDB.fallback_font
	for i in range(OPTIONS.size()):
		var offset_x: float = (i - 1.5) * OPTION_SPACING
		var center := Vector2(offset_x, 0)
		draw_circle(center, HIT_RADIUS, Color(0.15, 0.15, 0.2, 0.92))
		draw_arc(center, HIT_RADIUS, 0.0, TAU, 32, Color(1.0, 0.85, 0.3, 0.95), 3.0, true)
		var label: String = OPTION_LABELS[i]
		var text_size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 28)
		draw_string(font, center - text_size * 0.5 + Vector2(0, text_size.y * 0.35), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
```

**STEP 2 — แก้ `script/click_to_move.gd`**

1. เปิดไฟล์ `script/click_to_move.gd`
2. หาบรรทัด `var skill_button: SkillButton = null`
3. เพิ่ม 2 บรรทัดนี้ต่อท้าย:
```gdscript
var promotion_picker: PromotionPicker = null
var _pending_promotion: Dictionary = {}
```
4. หาฟังก์ชัน `_handle_click()` แล้วหาบรรทัดแรกสุดในฟังก์ชัน
   (`if board.game_over or board.animating or not _board_ready():`)
5. แทรกโค้ดนี้ไว้**บนสุด**ของฟังก์ชัน (ก่อนบรรทัดนั้นเลย — ต้องเช็คก่อนอย่างอื่นทั้งหมด รวมถึงปุ่ม
   สกิล เพราะระหว่างเลือกโปรโมทห้ามให้คลิกอื่นแทรก):
```gdscript
	if promotion_picker != null and is_instance_valid(promotion_picker):
		_handle_promotion_click()
		return
```
6. หาบรรทัด `board.try_move(from, cell, auto_promote_to)`
7. แก้เป็น (เช็คก่อนว่าตานี้เป็นการโปรโมทไหม):
```gdscript
			var moving_piece := ChessRules.at(board.board_state, from)
			if moving_piece != null and moving_piece.piece_kind == ChessPiece.Kind.PAWN \
					and cell.y == ChessRules.promotion_row(moving_piece.side):
				_show_promotion_picker(from, cell)
			else:
				board.try_move(from, cell, auto_promote_to)
```
8. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันเหล่านี้ต่อท้าย:
```gdscript
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
```
9. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ระหว่างป๊อปอัพโปรโมทค้างอยู่ ผู้เล่นยกเลิกไม่ได้** — ตั้งใจ เพราะเบี้ยเดินถึงแถวสุดท้ายแล้ว
> ตามกติกาหมากรุก**ต้อง**โปรโมทเสมอ ไม่มีทาง "ไม่โปรโมท" ได้ ผู้เล่นแค่ต้องเลือกว่าจะเป็นตัวไหน
>
> AI (`ai_player.gd`) ไม่ผ่านโค้ดนี้เลย — มันเรียก `board.try_move()` ตรงๆ ผ่าน `ChessAI.best_move()`
> ซึ่ง fallback เป็นควีนอัตโนมัติเหมือนเดิม (ค่า default ของพารามิเตอร์ `promote_to`) ป๊อปอัพนี้มีผล
> เฉพาะตอนผู้เล่นคลิกเดินเองเท่านั้น

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** สร้าง
`PromotionPicker` ตรงๆ ยืนยัน `option_global_position()` คำนวณตำแหน่งถูก (offset ตาม
`OPTION_SPACING` จริง), `OPTIONS` เรียงตรงกับ `ChessPiece.Kind` enum (`[4,3,2,1]` = Queen/Rook/
Bishop/Knight), `promotion_picker` ใน `click_to_move.gd` เริ่มต้นเป็น `null` ถูกต้อง, และการเดินปกติ
(`e4`) ยังทำงานได้ไม่กระทบ — **หมายเหตุ: ไฟล์ `.gd` ใหม่ที่มี `class_name` ต้องเปิด Godot editor
อย่างน้อย 1 ครั้งก่อน (หรือรัน `godot --headless --editor --quit`) เพื่อให้มันลงทะเบียน global class
ก่อน ไม่งั้นสคริปต์อื่นเรียกใช้ชื่อคลาสนั้นตรงๆ จะเจอ `Identifier "X" not declared in the current
scope`**

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เดินเบี้ยขาวจนถึงแถวบนสุด (row 0) | ป๊อปอัพ 4 วงกลม (Q/R/B/N) โผล่เหนือช่องนั้น หมากยังไม่ขยับ |
| คลิกตัวเลือก "N" (ม้า) | เบี้ยกลายเป็นม้า ป๊อปอัพหาย เสียตาไปฝ่ายตรงข้ามตามปกติ |
| คลิกที่อื่นบนกระดานตอนป๊อปอัพค้างอยู่ | ไม่มีอะไรเกิดขึ้น (ไม่นับเป็นการยกเลิก) จนกว่าจะคลิกโดนตัวเลือกจริง |
| ให้ AI (ฝ่ายดำ โหมด PVC) เดินเบี้ยถึงแถวสุดท้าย | กลายเป็นควีนอัตโนมัติเหมือนเดิม ไม่มีป๊อปอัพ (AI ไม่ใช้ picker) |
| เลือก "Q" (ควีน) | พฤติกรรมเหมือนของเดิมทุกอย่าง (auto-promote เป็นควีนแบบเดิม) |

### 11.13 Cooldown สกิล (แทนใช้ได้ครั้งเดียวต่อเกม)

ตอนที่ 11.9 ทำสกิลไว้ให้ใช้ได้แค่ครั้งเดียวตลอดเกม (`skill_used: bool`) — ตอนนี้เปลี่ยนเป็นตัวนับ
cooldown ที่ลดลงทุกครั้งที่เสียตา (ไม่ว่าจะเดินปกติหรือใช้สกิล) พอถึง 0 ใช้ได้อีกครั้ง

**STEP 1 — แก้ `script/chess_piece.gd`**

1. เปิดไฟล์ `script/chess_piece.gd`
2. หาบรรทัด `var skill_used: bool = false`
3. แก้เป็น:
```gdscript
const SKILL_COOLDOWN_TURNS := 6  # จำนวนตา (ครึ่งตา) ที่ต้องรอก่อนใช้สกิลตัวเดิมได้อีกครั้ง
var skill_cooldown_remaining: int = 0
```
4. หาฟังก์ชัน `can_use_skill()`:
```gdscript
func can_use_skill() -> bool:
	return has_skill(piece_kind) and not skill_used
```
5. แก้เป็น:
```gdscript
func can_use_skill() -> bool:
	return has_skill(piece_kind) and skill_cooldown_remaining <= 0
```
6. กด `Ctrl+S` เซฟไฟล์

**STEP 2 — แก้ `script/Board.gd`**

1. เปิดไฟล์ `script/Board.gd`
2. หาฟังก์ชัน `try_use_skill()` แล้วหาบรรทัด:
```gdscript
	var effect_kind := _apply_skill(piece)
	piece.skill_used = true
	skill_used.emit(piece, effect_kind)

	last_move = [cell, cell]
	side_to_move = ChessRules.opponent(side_to_move)
```
3. แก้เป็น (ลด cooldown ของทุกตัวก่อน แล้วค่อยตั้ง cooldown เต็มให้ตัวที่เพิ่งใช้สกิล):
```gdscript
	var effect_kind := _apply_skill(piece)
	skill_used.emit(piece, effect_kind)

	last_move = [cell, cell]
	_tick_skill_cooldowns()
	piece.skill_cooldown_remaining = ChessPiece.SKILL_COOLDOWN_TURNS
	side_to_move = ChessRules.opponent(side_to_move)
```
4. หาฟังก์ชัน `try_move()` แล้วหาคอมเมนต์ `# 3d) สลับตาเดิน` กับบรรทัดที่ตามมา:
```gdscript
	# 3d) สลับตาเดิน — เสียตาเสมอไม่ว่าจะโจมตีตายหรือไม่ตาย (ตัดสินใจโจมตีก็ถือว่าเสียตานี้ไปแล้ว)
	last_move = [from_cell, to_cell]
	side_to_move = ChessRules.opponent(side_to_move)
```
5. แก้เป็น (เติม `_tick_skill_cooldowns()` เข้าไปก่อนสลับตา):
```gdscript
	# 3d) สลับตาเดิน — เสียตาเสมอไม่ว่าจะโจมตีตายหรือไม่ตาย (ตัดสินใจโจมตีก็ถือว่าเสียตานี้ไปแล้ว)
	last_move = [from_cell, to_cell]
	_tick_skill_cooldowns()
	side_to_move = ChessRules.opponent(side_to_move)
```
6. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันนี้ต่อท้าย:
```gdscript
## ลดตัวนับ cooldown สกิลของหมากทุกตัวบนกระดานลง 1 ตา (ไม่ต่ำกว่า 0) — เรียกทุกครั้งที่เสียตา
## ไม่ว่าจะเป็นการเดินปกติหรือการใช้สกิล เพื่อให้สกิลใช้ซ้ำได้ทุก N ตาแทนที่จะหมดสิทธิ์ตลอดเกม
func _tick_skill_cooldowns() -> void:
	for row in board_state:
		for p in row:
			if p != null and p.skill_cooldown_remaining > 0:
				p.skill_cooldown_remaining -= 1
```
7. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ทำไมต้องลด cooldown ของ "ทุกตัวบนกระดาน" ไม่ใช่แค่ตัวที่เดิน** — เพราะ cooldown นับเป็น
> "จำนวนตาที่ผ่านไปในเกม" ไม่ใช่ "จำนวนครั้งที่ตัวนั้นได้เดิน" — ถ้านับแบบหลังหมากที่ไม่ได้ขยับเลย
> จะไม่มีวัน cooldown หมดเลย ซึ่งไม่ตรงกับสิ่งที่ผู้เล่นคาดหวัง (เห็นตาเดินผ่านไป N ตาแล้วก็ควรใช้ได้)
>
> `_tick_skill_cooldowns()` เรียกก่อน `side_to_move = ChessRules.opponent(...)` เสมอทั้ง 2 จุด —
> ให้แน่ใจว่านับครบ 1 ครั้งต่อการเสียตาจริงๆ ไม่ว่าจะเป็นการเดินหรือใช้สกิล

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** ใช้สกิลม้า
ขาวตรงๆ ผ่าน `board.try_use_skill()` แล้วไล่จำลอง 6 ตาถัดไปด้วย `board.try_move()` จริง — ผลตรงตาม
คาดทุกจุด: cooldown = 6 ทันทีหลังใช้, ลดเหลือ 5 หลังผ่านไป 1 ตา, เหลือ 1 หลังผ่านไป 5 ตา, และเหลือ 0
พอดีหลังผ่านไปครบ 6 ตา ซึ่งตอนนั้น `can_use_skill()` กลับมาเป็น `true` ให้ใช้ซ้ำได้ทันที

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| ใช้สกิลม้าตัวหนึ่ง แล้วเช็คค่า `skill_cooldown_remaining` | เท่ากับ 6 ทันที |
| เดินหมากอื่นไปเรื่อยๆ 5 ตา (ทั้ง 2 ฝ่ายรวมกัน) | `skill_cooldown_remaining` ของม้าตัวนั้นลดลงเหลือ 1 |
| เดินตาที่ 6 | `skill_cooldown_remaining` เหลือ 0, `can_use_skill()` คืน `true`, ปุ่มสกิลโผล่กลับมาให้กดได้อีก |
| ใช้สกิลซ้ำก่อนครบ 6 ตา | `try_use_skill()` คืน `false` (ปุ่มไม่โผล่ตั้งแต่แรกเพราะ `can_use_skill()` เป็น false) |
| ใช้สกิลตัวอื่นระหว่าง cooldown ของตัวแรกยังไม่หมด | ใช้ได้ปกติ (cooldown แยกตามตัวหมากแต่ละชิ้น ไม่ใช่ร่วมกันทั้งฝ่าย) |

### 11.14 เสียงตอนถูกรุก (check)

`Board.gd` มี signal `check_alerted(side: int)` อยู่แล้วตั้งแต่ตอนที่ 5 แต่ยังไม่เคยมีใครฟังเลย —
เพิ่มไฟล์เสียงใหม่ `check_alert.mp3` (จาก [Pixabay](https://pixabay.com) — ฟรี ไม่ต้องเครดิต —
"dramatic sting") วางไว้ที่ `asset/audio/` แล้วต่อสัญญาณเข้ากับ `main.gd` (ไฟล์เดียวกับ SFX อื่นๆ
จากตอนที่ 11.10)

**STEP — แก้ `script/main.gd`**

1. เปิดไฟล์ `script/main.gd`
2. หาบรรทัด
   `const SFX_DEFEAT := preload("res://asset/audio/game_over.mp3")         # เสมอ/จบเกมแบบอื่น`
   แล้วเพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
const SFX_CHECK := preload("res://asset/audio/check_alert.mp3")
```
3. หาฟังก์ชัน `_ready():` แล้วหาบรรทัด `board.piece_attacked.connect(_on_piece_attacked)`
4. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
	board.check_alerted.connect(_on_check_alerted)
```
5. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันนี้ต่อท้าย:
```gdscript
## เล่นเสียงเตือนตอนฝ่ายใดฝ่ายหนึ่งถูกรุก (ฟังจาก signal Board.check_alerted ที่มีอยู่แล้วตั้งแต่
## ตอนที่ 5 แต่ยังไม่เคยมีใครฟังมาก่อน) — ไม่สนใจว่าฝ่ายไหนถูกรุก เล่นเสียงเดียวกันหมด
func _on_check_alerted(_side: int) -> void:
	AudioManager.play_sfx(SFX_CHECK)
```
6. กด `Ctrl+S` เซฟไฟล์

> `check_alerted` ยิงเฉพาะตอนเกม**ยังไม่จบ**แต่ฝ่ายที่ถึงตาเดินกำลังถูกรุกอยู่ (ดู `_evaluate_status()`
> ใน `Board.gd`: `elif state.check:` — ถ้าเป็นรุกฆาตจะยิง `game_ended` แทน ไม่ใช่ `check_alerted`)
> ดังนั้นเสียงนี้จะไม่ซ้อนกับเสียงรุกฆาต/จบเกมที่ทำในตอนที่ 11.10

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** ยืนยันว่า
`check_alerted` ยิงจริงและ `main.gd` ต่อสัญญาณสำเร็จ

> ⚠️ **จุดที่พลาดได้ง่ายตอนเขียนสคริปต์ทดสอบ (ไม่เกี่ยวกับโค้ดจริง แค่เกี่ยวกับวิธีทดสอบ):** ลองเดิน
> ตาเปิดเกมแบบ `1.e4 e5 2.Qh5 Nc6 3.Qxf7+` เหมือนหมากรุกปกติก่อน แต่ไม่เกิดเช็คเลย — เพราะเกมนี้มี
> ระบบเลือด (HP)! การ "กิน" ที่ดาเมจไม่พอฆ่า ผู้โจมตี**ไม่ขยับเข้าไปแทนที่** (ดูตอนที่ 11.3) ควีนเลย
> ไม่ได้ไปยืนที่ f7 จริงๆ ไม่มีทางเช็คได้ — วิธีทดสอบที่ใช้ได้จริงคือ**ตั้งตำแหน่งหมากบน
> `board.board_state` ตรงๆ** (คิงขาว + คิงดำ + เรือดำล่อคิงขาวตรงคอลัมน์เดียวกันไม่มีตัวขวาง) แล้วเรียก
> `board._evaluate_status()` ตรงๆ แทนการจำลองเดินเป็นตาๆ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เดินหมากให้คิงฝ่ายตรงข้ามถูกรุก (แต่ยังไม่รุกฆาต) | ได้ยินเสียง `check_alert` ทันที พร้อมกรอบแดงเตือนรอบคิงที่มีอยู่แล้ว (ตอนที่ 7) |
| เดินหมากธรรมดาที่ไม่ทำให้เกิดการรุก | ไม่มีเสียงนี้ |
| เดินจนรุกฆาตเลย (checkmate ทันที) | ได้ยินแค่เสียง `victory_fanfare` (ตอนที่ 11.10) ไม่มีเสียง `check_alert` ซ้อน |
| ลาก slider SFX ลงสุด | เสียงนี้เงียบไปด้วย (อยู่ bus "SFX" เดียวกัน) |

### 11.15 Tooltip สกิล (โชว์คำอธิบายตอน hover ปุ่มสกิล)

`ChessPiece.skill_label(kind)` มีข้อความอธิบายสกิลแต่ละชนิดเตรียมไว้แล้วตั้งแต่ตอนที่ 11.9 แต่ยังไม่มี
UI ไปโชว์ — เพิ่มกล่องข้อความลอยขึ้นตอนเมาส์ชี้ค้างที่ปุ่มสกิล (วาดเองด้วย `_draw()` เหมือนกรอบไฮไลต์/
กรอบเช็คที่มีอยู่แล้วใน `click_to_move.gd`)

**STEP — แก้ `script/click_to_move.gd`**

1. เปิดไฟล์ `script/click_to_move.gd`
2. หาบรรทัด `var _pending_promotion: Dictionary = {}`
3. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
var _skill_tooltip_visible: bool = false
```
4. หาฟังก์ชัน `_draw()` แล้วหาบรรทัดสุดท้ายในฟังก์ชันนั้น (ก่อนจะจบฟังก์ชัน — ปกติจะเป็นลูป
   `for target in legal_targets:` ที่วาดกรอบไฮไลต์ช่องเดินได้ — ไม่ใช่ `_draw_check_warning()`
   เพราะอันนั้นถูกเรียกไว้บนสุดของฟังก์ชันต่างหาก)
5. เพิ่มโค้ดนี้ต่อท้ายลูปนั้น (ยังอยู่ในฟังก์ชัน `_draw()`):
```gdscript
	if _skill_tooltip_visible and skill_button != null and is_instance_valid(skill_button):
		_draw_skill_tooltip()
```
6. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันเหล่านี้ต่อท้าย:
```gdscript
## เช็คทุกเฟรมว่าเมาส์ชี้ค้างที่ปุ่มสกิลอยู่ไหม — เปลี่ยนสถานะแล้วค่อย queue_redraw() (ไม่ redraw
## รัวทุกเฟรมโดยไม่จำเป็น) เพราะปุ่มสกิลไม่ใช่ Control node จริง จะใช้ mouse_entered/exited ไม่ได้
func _process(_delta: float) -> void:
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
```
7. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ทำไมต้องมี `_process()` แยก แทนจะเช็คใน `_draw()` เลย** — `_draw()` ใน Godot รันเฉพาะตอนถูก
> เรียก `queue_redraw()` เท่านั้น (คำเตือนซ้ำหลายรอบในโปรเจกต์นี้) การขยับเมาส์เฉยๆ (ไม่คลิก) ไม่ทำให้
> `_draw()` รันเอง จึงต้องมี `_process()` คอยเช็คระยะทุกเฟรมแล้วค่อยสั่ง `queue_redraw()` เฉพาะตอน
> สถานะ hover เปลี่ยนจริงๆ (เข้า/ออก) กันวาดซ้ำโดยไม่จำเป็น
>
> ปุ่มสกิล (`skill_button.gd`) เป็น `Node2D` ธรรมดา ไม่ใช่ `Control`/`Area2D` จึงไม่มี signal
> `mouse_entered`/`mouse_exited` ให้ใช้ — ต้องเช็คระยะทางเองแบบเดียวกับที่คลิกปุ่มสกิลใช้ `HIT_RADIUS`
> อยู่แล้ว (`_handle_click()`)

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** เรียก
`click_to_move._try_select()` ตรงๆ ยืนยันปุ่มสกิลโผล่จริง, เรียก `_draw_skill_tooltip()` ผ่าน
`queue_redraw()` ไม่มี error, และ `ChessPiece.skill_label(ChessPiece.Kind.KNIGHT)` คืนข้อความถูกต้อง
("โจมตีตาถัดไปแรงขึ้น x1.5")

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เลือกหมากที่มีสกิล (เช่นม้า) แล้วเอาเมาส์ไปวางค้างที่ปุ่มสกิล | กล่องข้อความ "โจมตีตาถัดไปแรงขึ้น x1.5" โผล่เหนือปุ่ม |
| ขยับเมาส์ออกจากปุ่ม | กล่องข้อความหายไป |
| เลือกหมากตัวอื่นที่มีสกิลต่างกัน (เช่นคิง) แล้ว hover ปุ่ม | ข้อความเปลี่ยนเป็น "ปลุกใจฝ่ายเดียวกันทั้งหมด +20 เลือด" ตรงกับชนิดหมากที่เลือกอยู่ |
| หมากที่ติด cooldown (ตอนที่ 11.13) ไม่มีปุ่มสกิลโผล่ | ไม่มี tooltip เพราะไม่มีปุ่มให้ hover ตั้งแต่แรก |
| ยกเลิกการเลือกหมาก (ปุ่มหายไป) | tooltip หายไปด้วยทันที ไม่ค้าง |

### 11.16 ไอคอนบอกว่าหมากตัวไหนมี Passive ทำงานอยู่

ไอคอนวงกลมทองเล็กๆ ข้างหลอดเลือด โผล่บนหมากที่ passive แบบ "ป้องกันตัวเอง" (ไม่ต้องพึ่งข้อมูล
เป้าหมาย) กำลังทำงานอยู่จริง:

| Passive ที่โชว์ได้ | เงื่อนไข |
|---|---|
| เรือ (ป้อมปราการ) | ยังไม่เคยขยับ |
| เบี้ย (แนวรบเหล็ก) | มีเบี้ยฝ่ายเดียวกันยืนติดข้างๆ |
| ม้า (จู่โจมครั้งแรก) | ยังไม่เคยโจมตีในเกมนี้ |
| หมากใดๆ ใกล้คิงฝ่ายเดียวกัน (ราชันคุ้มกัน) | อยู่ในระยะประชิดคิง (รวมคิงเอง) |

> ⚠️ **ควีน (โค่นล้ม) กับบิชอป (แสงชำระ) โชว์ไม่ได้แบบนี้** — เพราะ 2 passive นี้ขึ้นอยู่กับ**เป้าหมาย
> ที่ยังไม่รู้ล่วงหน้า** (เลือดของศัตรูที่จะโดนตี) ไม่ใช่สถานะของตัวเองเฉยๆ ไม่มีทางโชว์เป็นไอคอนค้าง
> บนตัวหมากได้อย่างมีความหมาย — ต้องรู้ว่าจะตีตัวไหนก่อนถึงจะบอกได้ (ยังไม่ทำ ต่อยอดได้ทีหลัง)

**STEP 1 — แก้ `script/passive_skills.gd`**

1. เปิดไฟล์ `script/passive_skills.gd`
2. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันนี้ต่อท้าย:
```gdscript
## หมากตัวนี้กำลังได้ประโยชน์จาก passive ของตัวเอง "ตอนนี้เลย" (ไม่ต้องรู้ว่าจะไปตีใคร) ไหม —
## ใช้แค่โชว์ไอคอนบอกสถานะเฉยๆ ไม่เกี่ยวกับ compute_damage() เลย ไม่ครอบคลุมควีน/บิชอปเพราะ
## passive ของ 2 ชนิดนั้นขึ้นกับเป้าหมายที่ยังไม่รู้ล่วงหน้า
static func is_passive_active(piece: ChessPiece, state: Array, cell: Vector2i) -> bool:
	if piece.piece_kind == ChessPiece.Kind.ROOK and not piece.has_moved:
		return true
	if piece.piece_kind == ChessPiece.Kind.PAWN and _has_allied_pawn_beside(state, cell, piece.side):
		return true
	if piece.piece_kind == ChessPiece.Kind.KNIGHT and not piece.has_attacked:
		return true
	if _is_near_allied_king(state, cell, piece.side):
		return true
	return false
```
3. กด `Ctrl+S` เซฟไฟล์

**STEP 2 — แก้ `script/chess_piece.gd`**

1. เปิดไฟล์ `script/chess_piece.gd`
2. หาบรรทัด
   `var has_attacked: bool = false  # เคยโจมตีสำเร็จมาก่อนไหม (ใช้ตัดสิน passive "จู่โจมครั้งแรก" ของม้า)`
3. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
var passive_indicator: bool = false  # true ถ้า passive ของตัวเองกำลังทำงานอยู่ตอนนี้ (ดู PassiveSkills.is_passive_active)
```
4. หาฟังก์ชัน `_draw()` แล้วหาบรรทัดสุดท้าย (`draw_rect(bg_rect, Color(1.0, 1.0, 1.0, 0.4), false, 1.0 / sy)`)
5. เพิ่มโค้ดนี้ต่อท้าย (ยังอยู่ในฟังก์ชัน `_draw()`):
```gdscript
	if passive_indicator:
		var badge_r: float = 9.0 / sy
		var badge_pos := Vector2(bar_w * 0.5 + badge_r + 4.0 / sx, top_y + bar_h * 0.5)
		draw_circle(badge_pos, badge_r, Color(1.0, 0.85, 0.25, 0.95))
		draw_arc(badge_pos, badge_r, 0.0, TAU, 16, Color(1.0, 1.0, 1.0, 0.9), 1.5 / sy, true)
```
6. กด `Ctrl+S` เซฟไฟล์

**STEP 3 — แก้ `script/piece_spawner.gd`**

1. เปิดไฟล์ `script/piece_spawner.gd`
2. หาบรรทัด `board.skill_used.connect(_on_skill_used)` (บรรทัดสุดท้ายใน `_ready()`)
3. เพิ่ม 3 บรรทัดนี้ต่อท้าย:
```gdscript
	board.move_made.connect(_on_move_made_update_passives)
	board.skill_used.connect(_on_skill_used_update_passives)
	_update_passive_indicators()
```
4. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันเหล่านี้ต่อท้าย:
```gdscript
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
```
5. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ทำไมต้องมีฟังก์ชัน wrapper (`_on_move_made_update_passives`/`_on_skill_used_update_passives`)
> แทนที่จะต่อ `_update_passive_indicators` ตรงๆ** — `_update_passive_indicators()` ไม่รับ
> พารามิเตอร์เลย แต่ signal `move_made`/`skill_used` ส่งค่ามาให้ 3/2 ตัวตามลำดับ — ต้องมีฟังก์ชันคั่น
> กลางที่รับพารามิเตอร์ตามจริง (ใส่ underscore หน้าตัวที่ไม่ได้ใช้) แล้วค่อยเรียกฟังก์ชันจริงไม่มี
> พารามิเตอร์ข้างใน ให้แน่ใจว่า signature ตรงกันแบบชัดเจน ไม่พึ่งพฤติกรรม auto-truncate ของ Godot

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** ยืนยันจาก
ตำแหน่งเริ่มเกมจริง — เรือ (a1), ม้า (b1), คิง (e1) มี `passive_indicator = true` ทันที และ**ควีน
(d1) ก็เป็น `true` ด้วยเช่นกัน** เพราะยืนติดกับคิงพอดี (ระยะประชิด 1 ช่อง) ตาม "ราชันคุ้มกัน" ที่
ครอบคลุมหมากทุกชนิดที่อยู่ใกล้คิง ไม่ใช่แค่ passive เฉพาะชนิดของตัวเอง — ไม่ใช่บั๊ก แค่ 2 เงื่อนไข
ทับซ้อนกันได้ (ควีนไม่มี "แสงชำระ"/"โค่นล้ม" เป็นไอคอนของตัวเอง แต่ได้ไอคอน "ราชันคุ้มกัน" จากการยืน
ใกล้คิงแทน) — เดินม้าเฉยๆ (ไม่ตี) ก็ยังคง `passive_indicator = true` อยู่ ยืนยันว่าเช็คเฉพาะ
`has_attacked` ไม่ใช่ `has_moved`

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เริ่มเกมใหม่ | เรือทั้ง 4 ตัว, เบี้ยแถวเริ่มต้นทุกตัว, ม้าทั้ง 4 ตัว, คิงและหมากข้างๆ คิงทั้ง 2 ฝ่าย (รวมควีนที่ยืนติดคิง) มีไอคอนวงกลมทองขึ้นครบ |
| ขยับเรือตัวหนึ่ง | ไอคอนของเรือตัวนั้นหายไปทันที (มีโบนัสไม่ได้แล้วเพราะขยับแล้ว) |
| ม้าโจมตีสำเร็จครั้งแรก | ไอคอนของม้าตัวนั้นหายไป (`has_attacked` เป็น true แล้ว) — แต่แค่**เดิน**เฉยๆ ไม่ตี ไอคอนยังอยู่ |
| เดินเบี้ยออกจากแนวเบี้ยข้างๆ | ไอคอนของเบี้ยที่เหลืออยู่ข้างๆ หายไปด้วย (ไม่มีเพื่อนติดกันแล้ว) |
| คิงขยับออกจากตำแหน่งเดิม | ไอคอนของหมากที่เคยอยู่ใกล้คิงเดิม (แต่ไม่ใกล้คิงตำแหน่งใหม่) หายไป ส่วนหมากที่อยู่ใกล้ตำแหน่งใหม่ของคิงจะได้ไอคอนแทน |
| ควีน/บิชอปที่อยู่ไกลคิง | ไม่มีไอคอนนี้เลย (ตามข้อจำกัดที่ตั้งใจ — มีไอคอนได้เฉพาะตอนบังเอิญยืนใกล้คิงเท่านั้น) |

> **เอาออกแล้ว:** เดิมตอนที่ 11.17 ในนี้เคยเป็น Move History Log (panel มุมขวาบนโชว์ประวัติการเดิน
> ผ่าน `Board.move_log`/`move_logged`) — ฟีเจอร์นี้ถูกถอดออกจากโปรเจกต์แล้วทั้งหมด (ลบ `MoveLogPanel`
> ออกจาก `main.tscn`, ลบ `move_log`/`move_logged`/`PIECE_LETTERS`/`_cell_to_algebraic()`/`_log_move()`/
> `_log_skill()` ออกจาก `Board.gd`, ลบ `move_log_label`/`_on_move_logged()` ออกจาก `main.gd`)

### 11.18 Achievements / สถิติสะสม

สร้าง Autoload ใหม่ `StatsManager` เก็บสถิติสะสม**ข้ามเกม/ข้ามเซสชัน** เซฟลงไฟล์ `ConfigFile` แบบเดียวกับ
ที่ `audio_manager.gd` ทำกับค่าเสียง (ตอนที่ 10.2) — พอปลดล็อก achievement ใหม่จะมี toast ข้อความลอยขึ้น
แจ้งเตือนสั้นๆ

**สถิติที่เก็บ:** จำนวนศัตรูที่ฆ่าสะสม, จำนวนครั้งที่ใช้ Active Skill สะสม, จำนวนเกมที่เล่น/ชนะ/
แพ้/เสมอ
**Achievement เริ่มต้น 5 อัน:** First Blood, Slayer (ฆ่า 50), Skilled (ใช้สกิลครั้งแรก),
Tactician (ใช้สกิล 20 ครั้ง), Champion (ชนะ AI 10 เกม)

**STEP 1 — สร้าง `script/stats_manager.gd`**

1. คลิกขวาโฟลเดอร์ `script` ในแผง FileSystem → **Create New → Script...**
2. Inherits: `Node`, Path: `res://script/stats_manager.gd` → **Create**
3. ลบโค้ด template ที่ Godot ใส่มาให้ทิ้งทั้งหมด แล้ววางโค้ดนี้แทน:

```gdscript
extends Node

## เก็บสถิติสะสมตลอดการเล่น (ข้ามเกม/ข้ามเซสชัน)
## เซฟลงไฟล์ ConfigFile เหมือนที่ audio_manager.gd ทำกับค่าเสียง (ตอนที่ 10.2)

const SAVE_PATH := "user://stats.cfg"

var total_kills: int = 0
var total_skills_used: int = 0
var games_played: int = 0
var games_won: int = 0
var games_lost: int = 0
var games_drawn: int = 0

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

func record_kill() -> void:
	total_kills += 1
	_check_achievements()
	_save()

func record_skill_used() -> void:
	total_skills_used += 1
	_check_achievements()
	_save()

## บันทึกผลจบเกม — win_for_player: true=ผู้เล่นชนะ, false=แพ้, null=เสมอ/ไม่เกี่ยว (เช่นโหมด PVP)
func record_game_ended(win_for_player) -> void:
	games_played += 1
	if win_for_player == true:
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
	total_kills = config.get_value("stats", "total_kills", 0)
	total_skills_used = config.get_value("stats", "total_skills_used", 0)
	games_played = config.get_value("stats", "games_played", 0)
	games_won = config.get_value("stats", "games_won", 0)
	games_lost = config.get_value("stats", "games_lost", 0)
	games_drawn = config.get_value("stats", "games_drawn", 0)
	unlocked_achievements = config.get_value("stats", "unlocked_achievements", [])
```
4. กด `Ctrl+S` เซฟไฟล์

**STEP 2 — ลงทะเบียนเป็น Autoload**

1. **Project → Project Settings → Autoload**
2. Path เลือก `res://script/stats_manager.gd`
3. Node Name ตั้งเป็น `StatsManager` (ตัวสะกดต้องตรงเป๊ะ)
4. คลิก **Add**

**STEP 3 — แก้ `script/main.gd`**

1. เปิดไฟล์ `script/main.gd`
2. หาฟังก์ชัน `_on_piece_attacked()` แล้วหาบรรทัด
   `func _on_piece_attacked(_attacker: ChessPiece, _victim: ChessPiece, damage: float, killed: bool) -> void:`
3. เพิ่มบรรทัดนี้ไว้เป็นบรรทัดแรกในฟังก์ชัน (ก่อนบรรทัด `var strength: float = ...`):
```gdscript
	if killed:
		StatsManager.record_kill()
```
4. หาฟังก์ชัน `_ready():` แล้วหาบรรทัด `board.check_alerted.connect(_on_check_alerted)`
5. เพิ่ม 2 บรรทัดนี้ต่อท้าย:
```gdscript
	board.skill_used.connect(_on_skill_used_stats)
	StatsManager.achievement_unlocked.connect(_on_achievement_unlocked)
```
6. หาฟังก์ชัน `_on_game_ended(result: String, winner: int) -> void:` แล้วหาบรรทัด `_finished = true`
7. เพิ่มโค้ดนี้ต่อท้ายบรรทัดนั้น:
```gdscript
	if GameManager.game_mode == "PVC":
		if winner == ChessPiece.Team.WHITE:
			StatsManager.record_game_ended(true)
		elif winner == ChessPiece.Team.BLACK:
			StatsManager.record_game_ended(false)
		else:
			StatsManager.record_game_ended(null)
	else:
		StatsManager.record_game_ended(null)  # โหมด PVP ไม่มี "ผู้เล่น" ฝ่ายตายตัว ไม่นับแพ้/ชนะ
```
8. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันเหล่านี้ต่อท้าย:
```gdscript
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
```
9. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **`ACHIEVEMENTS` ต้องเป็น `var` ไม่ใช่ `const`** — เจอ error แบบนี้มาก่อนถ้าลองใช้ `const`:
> `Cannot use a non-constant value in a constant expression` เพราะ `func(s): return ...` (lambda)
> เป็น `Callable` ที่สร้างขึ้นตอนรันจริง ไม่ใช่ค่าคงที่ที่รู้ล่วงหน้าตอน compile — เหมือนปัญหา
> `var check_col := cell.x + dx` ที่เจอมาแล้วในตอนที่ 11.8 (ต้องระบุ type ชัดเจน ห้าม infer จาก
> ค่าที่ compile-time ไม่รู้)
>
> Toast แจ้งเตือนเพิ่มเป็นลูกของ `$UI` (CanvasLayer) ตรงๆ ไม่ใช่ลูกของ `Main` — เพราะอยากให้อยู่
> ตำแหน่งคงที่บนจอเสมอ ไม่สั่นตามจอตอนปะทะ (ตอนที่ 11.6) เหมือนปุ่ม Pause ที่ตั้งใจไม่สั่นตามเช่นกัน

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** เรียก
`record_kill()`/`record_skill_used()` ตรงๆ บน `StatsManager` autoload — ปลดล็อก "First Blood" ทันที
หลังฆ่าครั้งแรก และ "Skilled" หลังใช้สกิลครั้งแรก ไม่มีซ้ำ, โหลด `main.tscn` ทั้งฉากจริงยืนยันการต่อ
signal ทั้งหมดใน `_ready()` ไม่ error และการเดินหมากปกติยังทำงานถูกต้องหลังเพิ่มโค้ดสถิติเข้าไป
(ไม่กระทบของเดิม) — **หมายเหตุเดียวกับตอนที่ 11.12/11.15: autoload ใหม่ที่แก้ `project.godot` ตรงๆ
(ไม่ผ่านหน้าต่าง Project Settings) ต้องรัน `godot --headless --editor --quit` อย่างน้อย 1 ครั้งก่อน
เพื่อให้ Godot สร้างไฟล์ `.uid` ให้สคริปต์และลงทะเบียน autoload จริง ไม่งั้นจะหา `StatsManager`
ไม่เจอ**

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| ฆ่าศัตรูตัวแรกในเกม | toast "🏆 First Blood — ฆ่าศัตรูตัวแรก" ลอยขึ้นกลางจอบนสุดแล้วจางหาย |
| ใช้ Active Skill ครั้งแรก | toast "🏆 Skilled — ใช้ Active Skill ครั้งแรก" โผล่ |
| ปิดเกมแล้วเปิดใหม่ | สถิติ (`total_kills` ฯลฯ) ยังอยู่ครบ ไม่รีเซ็ตกลับ 0 (โหลดจาก `user://stats.cfg`) |
| ปลดล็อก achievement เดิมซ้ำ (เช่นฆ่าศัตรูตัวที่ 2 หลัง First Blood ปลดแล้ว) | ไม่มี toast ซ้ำ (เช็คด้วย `unlocked_achievements`) |
| เล่นโหมด PVC จนชนะ AI | `games_won` เพิ่มขึ้น 1, ถ้าครบ 10 ครั้งจะได้ achievement "Champion" |
| เล่นโหมด PVP จนจบเกม | `games_played` เพิ่มขึ้นแต่ `games_won`/`games_lost` ไม่ขยับ (ไม่มีฝ่าย "ผู้เล่น" ตายตัว) |

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** ยังไม่มีหน้าจอ "ดูสถิติทั้งหมด" (แค่มี toast ตอนปลดล็อกใหม่
> เท่านั้น) — เพิ่มได้โดยสร้างฉากใหม่คล้าย Settings (ตอนที่ 10.5) แสดงค่าจาก `StatsManager` ตรงๆ,
> ยังไม่เก็บ "สกิลที่ใช้บ่อยสุด" แยกตามชนิดหมาก (มีแค่ยอดรวม `total_skills_used`)

> **เอาออกแล้ว:** เดิมตอนที่ 11.19 ในนี้เคยเป็น AI Difficulty slider ในหน้า Settings (ย้าย
> `SEARCH_DEPTH` ไปเก็บที่ `GameManager.ai_difficulty` แบบปรับได้/persist ลงไฟล์) — ฟีเจอร์นี้ถูก
> ถอดออกจากโปรเจกต์แล้วทั้งหมด กลับไปใช้ `const SEARCH_DEPTH := 2` แบบตายตัวใน `ai_player.gd`
> เหมือนเดิม (ลบ `ai_difficulty`/`set_ai_difficulty()`/`_load_difficulty()` ออกจาก `game_manager.gd`,
> ลบ `difficulty_slider`/`difficulty_label` ออกจาก `settings.gd`)

### 11.20 AI ประเมินเชิงตำแหน่ง (Positional Evaluation)

ตอนนี้ `ChessAI` ประเมินตาเดินจากแค่ `material_score()` (มูลค่าหมาก × สัดส่วนเลือด) ไม่สนใจตำแหน่ง
บนกระดานเลย — เพิ่ม `positional_score()` แยกต่างหาก ให้คะแนนเสริมเบาๆ ตาม 2 หลักการพื้นฐาน: **(1)**
ม้า/บิชอป/ควีนอยู่ใกล้กลางกระดานมีค่ากว่าอยู่ริม (ควบคุมพื้นที่ได้กว้างกว่า) **(2)** เบี้ยที่รุกคืบ
ใกล้แถวโปรโมทมีค่ากว่าเบี้ยที่ยังไม่ขยับ — คูณด้วยน้ำหนักเล็กๆ ไม่ให้แซงหน้าคะแนนมูลค่าหมากจริง

> ⚠️ **พบภายหลังว่าตอนนี้เคยเขียนไว้ในคู่มือแต่ไม่เคยถูกใส่ในโค้ดโปรเจกต์จริง** (ตรวจเจอตอนไล่เช็ค
> `chess_ai.gd` ทีหลัง) — ถ้าเคยทำตอนที่ 11.26 (AI ใช้ Active Skill) มาก่อนแล้ว ไฟล์จะมี
> `SKILL_TIEBREAK_PENALTY` อยู่ก่อน `POSITIONAL_WEIGHT` แล้ว ให้ยึดตาม STEP ด้านล่างนี้ (อ้างอิงอันหลัง
> เป็นจุดแทรก) ไม่ใช่ตามลำดับเลขตอนในเล่ม

**STEP — แก้ `script/chess_ai.gd`**

1. เปิดไฟล์ `script/chess_ai.gd`
2. หาบรรทัด `const SKILL_TIEBREAK_PENALTY := 0.001` (ถ้ายังไม่ได้ทำตอนที่ 11.26 มาก่อน ให้หา
   `const CHECKMATE_SCORE := 9999.0` แทน)
3. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript

## น้ำหนักของคะแนนเชิงตำแหน่งเทียบกับคะแนนมูลค่าหมาก (material_score) — 0.05 = มีผลเสริมเบาๆ
## ไม่ทำให้ AI ยอมเสียหมากฟรีๆ แค่เพื่อได้ตำแหน่งดีขึ้นนิดหน่อย
const POSITIONAL_WEIGHT := 0.05
```
4. หาฟังก์ชัน `material_score()` ทั้งฟังก์ชัน แล้วหาบรรทัดสุดท้าย (`return score`)
5. เพิ่มฟังก์ชันใหม่ 3 ตัวนี้ต่อท้ายฟังก์ชัน `material_score()`:
```gdscript
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
```
6. หาฟังก์ชัน `_minimax()` แล้วหาบรรทัด:
```gdscript
	if depth <= 0:
		return material_score(state, hp_overrides)
```
7. แก้เป็น (รวมคะแนนเชิงตำแหน่งเข้าไปด้วย):
```gdscript
	if depth <= 0:
		return material_score(state, hp_overrides) + positional_score(state) * POSITIONAL_WEIGHT
```
8. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **`POSITIONAL_WEIGHT` ต้องเล็กมากๆ (0.05)** — เพราะ `material_score()` ให้หน่วยเป็น "มูลค่าหมาก
> เทียบเบี้ย 1 ตัว" (เบี้ย=1.0, ควีน=9.0) ถ้า `positional_score()` มีน้ำหนักเยอะเกินไป AI อาจยอม
> เสียหมากจริงๆ แค่เพื่อขยับไปอยู่ตำแหน่งกลางกระดานที่ "ดูดี" กว่า ซึ่งเป็นการตัดสินใจที่แย่มาก
>
> คะแนนเชิงตำแหน่งนี้มีผล**เฉพาะตอนค้นถึงใบสุดท้ายของต้นไม้การค้นหา** (`depth <= 0`) เท่านั้น —
> เหมือนกับที่ `material_score()` ทำงานอยู่แล้ว ไม่ต้องแก้จุดอื่นใน `_minimax()` เลย

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เปรียบเทียบ AI เดินม้าออกจากมุมกระดาน (Na3/Nh3) กับม้าไปกลางกระดาน (Nc3/Nf3) เมื่อค่าอื่นเท่ากัน | AI เลือกเดินม้าไปกลางกระดานมากกว่า (คะแนนตำแหน่งสูงกว่า) |
| เปรียบเทียบ AI เดินเบี้ยรุกไปข้างหน้า vs อยู่นิ่งเฉยๆ เมื่อทั้งคู่ปลอดภัยเท่ากัน | AI เลือกรุกเบี้ยไปข้างหน้ามากกว่า |
| AI ไม่ยอมเสียหมากฟรีๆ เพื่อไปอยู่ตำแหน่งกลางกระดาน | ยังคงหลีกเลี่ยงการเดินที่ทำให้เสียหมากเปล่าๆ เหมือนเดิม (`POSITIONAL_WEIGHT` เล็กพอที่จะไม่ครอบงำมูลค่าหมากจริง) |

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** ยังไม่มีคะแนนความปลอดภัยของคิง (king safety — เช่นเช็คว่าคิง
> ถูกล้อมด้วยหมากป้องกันไหม), ยังไม่มี piece-square table แบบเต็มมาตรฐาน (ตอนนี้ใช้แค่ heuristic
> ง่ายๆ 2 อย่าง ไม่ใช่ตารางคะแนนต่อช่องแบบละเอียดของหมากรุกจริง)

### 11.21 แสงพวยพุ่งตอน Promote

เบี้ยที่ promote สำเร็จ (ตอนที่ 11.12) ตอนนี้แค่กลายร่างเฉยๆ ไม่มีเอฟเฟกต์อะไรเลย — เพิ่มเสาแสงทอง
พวยพุ่งขึ้น + วงแหวนกระแทกพื้น + ประกายทองฟุ้งรอบตัว ให้ความรู้สึกพิเศษสมกับเป็นการอัปเกรดหมาก

**STEP 1 — สร้าง `script/promote_glow.gd`**

1. คลิกขวาโฟลเดอร์ `script` → **Create New → Script...**
2. Inherits: `Node2D`, Path: `res://script/promote_glow.gd` → **Create**
3. ลบโค้ด template ทิ้ง วางนี้แทน — **ไม่ต้องผูกกับ node ไหนในฉาก** (สร้างเองด้วยโค้ดตอนรันเกม
   เหมือน `SlashEffect`/`ImpactRing`)

```gdscript
extends Node2D
class_name PromoteGlow

## แสงพวยพุ่งขึ้นฟ้าตอนเบี้ย promote — เสาแสงสามเหลี่ยมยืดขึ้นแล้วจางหาย + จุดแสงตรงฐาน
## วาดด้วย _draw() ล้วนๆ ไม่ต้องมี asset รูป เป็น node ชั่วคราวที่ลบตัวเองทิ้งอัตโนมัติหลังเล่นจบ

const DURATION := 0.6
const BEAM_HEIGHT := 220.0
const BEAM_WIDTH := 40.0

var _progress := 0.0  # 0 → 1 ตลอดช่วงอายุของเอฟเฟกต์

func _ready() -> void:
	z_index = 4  # อยู่เหนือตัวหมาก (Pieces z_index = 1) เหมือน ImpactRing
	var tween := create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, DURATION) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)

func _set_progress(p: float) -> void:
	_progress = p
	queue_redraw()

func _draw() -> void:
	var alpha := 1.0 - _progress
	var height := BEAM_HEIGHT * (0.3 + _progress * 0.7)
	var half_w := BEAM_WIDTH * 0.5 * (1.0 - _progress * 0.5)
	var points := PackedVector2Array([
		Vector2(-half_w, 0), Vector2(half_w, 0),
		Vector2(half_w * 0.3, -height), Vector2(-half_w * 0.3, -height),
	])
	draw_colored_polygon(points, Color(1.0, 0.95, 0.6, alpha * 0.85))
	draw_circle(Vector2.ZERO, 8.0 + _progress * 6.0, Color(1.0, 1.0, 0.85, alpha))
```

**STEP 2 — แก้ `script/piece_spawner.gd`** — เพิ่มฟังก์ชันเล่นเอฟเฟกต์

1. เปิดไฟล์ `script/piece_spawner.gd`
2. เลื่อนไปท้ายไฟล์ แล้วเพิ่มโค้ดนี้ต่อท้าย:
```gdscript
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
```
3. กด `Ctrl+S` เซฟไฟล์

**STEP 3 — แก้ `script/Board.gd`** — เรียกเอฟเฟกต์ตอน promote จริง

1. เปิดไฟล์ `script/Board.gd`
2. หาฟังก์ชัน `_promote()`:
```gdscript
func _promote(pawn: ChessPiece, cell: Vector2i, kind: int) -> ChessPiece:
	var pieces := get_node_or_null("Pieces")
	if pieces == null or not pieces.has_method("spawn_piece"):
		return pawn
	var promoted: ChessPiece = pieces.spawn_piece(ChessPiece.art_name(kind), pawn.side, cell, kind)
	if promoted == null:
		return pawn
	promoted.has_moved = true
	pawn.queue_free()
	return promoted
```
3. แก้เป็น (แทรก 2 บรรทัดก่อน `pawn.queue_free()`):
```gdscript
func _promote(pawn: ChessPiece, cell: Vector2i, kind: int) -> ChessPiece:
	var pieces := get_node_or_null("Pieces")
	if pieces == null or not pieces.has_method("spawn_piece"):
		return pawn
	var promoted: ChessPiece = pieces.spawn_piece(ChessPiece.art_name(kind), pawn.side, cell, kind)
	if promoted == null:
		return pawn
	promoted.has_moved = true
	if pieces.has_method("play_promote_effect"):
		pieces.play_promote_effect(promoted, cell)
	pawn.queue_free()
	return promoted
```
4. กด `Ctrl+S` เซฟไฟล์

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เดินเบี้ยไปถึงแถวสุดท้ายแล้วเลือกโปรโมท (Q/R/B/N ตัวไหนก็ได้) | เสาแสงทองพวยพุ่งขึ้น + วงแหวนกระแทกพื้น + ประกายทองฟุ้งรอบตัวหมากตัวใหม่ ก่อนจางหายไปเอง |
| AI (ฝ่ายดำ โหมด PVC) เดินเบี้ยถึงแถวสุดท้าย | เอฟเฟกต์เล่นเหมือนกันทุกประการ (ไม่ผ่าน UI picker แต่ยังเรียก `_promote()` เส้นเดียวกัน) |

### 11.22 กรอบเรืองแสงเต้นจังหวะ (Pulsing Highlight Glow)

กรอบไฮไลต์รอบช่องที่เลือก/ช่องที่เดินได้ (ตอนที่ 7.2) ตอนนี้สว่างนิ่งตลอดเวลา — เพิ่มจังหวะเต้น
สว่าง-หรี่ต่อเนื่อง (sine wave) ให้ดูมีชีวิตชีวาขึ้น

**STEP — แก้ `script/click_to_move.gd`**

1. เปิดไฟล์ `script/click_to_move.gd`
2. หาบรรทัด `const SFX_SELECT := preload("res://asset/audio/select_click.mp3")`
3. เพิ่มโค้ดนี้ต่อท้าย:
```gdscript
const PULSE_SPEED := 3.2   # เรเดียนต่อวินาที ยิ่งมากยิ่งเต้นถี่
const PULSE_MIN := 0.55    # ความเข้มแสงต่ำสุดตอนจังหวะจาง (0-1)
const PULSE_MAX := 1.0     # ความเข้มแสงสูงสุดตอนจังหวะสว่าง
```
4. หาบรรทัด `var _skill_tooltip_visible: bool = false`
5. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
var _pulse_time: float = 0.0
```
6. หาฟังก์ชัน `_process(_delta: float) -> void:` (ตัวที่มีอยู่แล้วสำหรับเช็ค hover ปุ่มสกิลจากตอนที่
   11.15) แล้วแก้จาก:
```gdscript
func _process(_delta: float) -> void:
	if skill_button == null or not is_instance_valid(skill_button):
```
เป็น (เปลี่ยนชื่อพารามิเตอร์จาก `_delta` เป็น `delta` แล้วเพิ่มตัวจับเวลาการเต้นก่อนโค้ดเดิม):
```gdscript
func _process(delta: float) -> void:
	if selected_cell != ChessRules.NO_CELL:
		_pulse_time += delta
		queue_redraw()
	if skill_button == null or not is_instance_valid(skill_button):
```
7. หาฟังก์ชัน `_draw_glow_quad()`:
```gdscript
func _draw_glow_quad(cell: Vector2i, color: Color) -> void:
	var corners: PackedVector2Array = board.cell_corners(cell.x, cell.y)
	var local_corners := PackedVector2Array()
	for point in corners:
		local_corners.append(to_local(point))
	local_corners.append(local_corners[0])  # ปิดกรอบให้ครบวง

	var glow_layers := [
		{"width": 16.0, "alpha": 0.12},
		{"width": 10.0, "alpha": 0.22},
		{"width": 5.0, "alpha": 0.45},
		{"width": 2.5, "alpha": 0.95},
	]
	for layer in glow_layers:
		draw_polyline(local_corners, Color(color.r, color.g, color.b, layer.alpha), layer.width, true)
```
8. แก้เป็น (เพิ่มตัวคูณ `pulse` เข้าไปคูณกับ alpha ของทุกชั้น):
```gdscript
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
```
9. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ทำไม `queue_redraw()` เฉพาะตอน `selected_cell != NO_CELL`** — ไม่ใช่ทุกเฟรมตลอดเวลา
> เพื่อไม่ให้เปลืองแรงวาดเปล่าๆ ตอนไม่มีอะไรถูกเลือกอยู่บนกระดานเลย (ไม่มีกรอบให้เต้นอยู่แล้ว)

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| คลิกเลือกหมากตัวไหนก็ได้ | กรอบทองรอบตัวที่เลือก และกรอบเขียว/แดงรอบช่องที่เดินได้ สว่าง-หรี่เป็นจังหวะต่อเนื่อง ไม่ใช่แสงนิ่งเหมือนเดิม |
| ยกเลิกการเลือก (ไม่มีช่องไหนไฮไลต์) | ไม่มีอะไรให้เต้น (ไม่มีการ `queue_redraw()` เปล่าๆ ทุกเฟรมด้วย) |

### 11.23 พื้นหลังขยับเบาๆ (Background Sway)

พื้นหลังกระดาน (`asset/bg.png`) นิ่งสนิทมาตลอด — เพิ่มการขยับวนไปมาเบาๆ (idle sway) ให้ฉากดูมีชีวิต
โดยไม่กระทบตำแหน่งกระดาน/ตัวหมากเลย เพราะ `Background` เป็นคนละ node กับ `Board`

**STEP — แก้ `script/main.gd`**

1. เปิดไฟล์ `script/main.gd`
2. หาบรรทัด `@onready var resume_button: TextureButton = $UI/PauseMenu/PausePanel/VBoxContainer/Resume`
3. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
@onready var background: Sprite2D = $Background
```
4. หาบรรทัด `const SHAKE_STEP_DURATION := 0.035`
5. เพิ่มโค้ดนี้ต่อท้าย:
```gdscript
const BG_SWAY_OFFSET := 6.0     # พิกเซล ระยะขยับของพื้นหลัง
const BG_SWAY_DURATION := 4.0   # วินาทีต่อช่วงการขยับ 1 รอบ (ยิ่งมากยิ่งขยับช้า นุ่มนวล)
```
6. หาฟังก์ชัน `_ready():` แล้วหาบรรทัดแรกสุด `AudioManager.play_music(GAMEPLAY_MUSIC)`
7. เพิ่มบรรทัดนี้ต่อท้าย:
```gdscript
	_start_background_sway()
```
8. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันนี้ต่อท้าย:
```gdscript
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
```
9. กด `Ctrl+S` เซฟไฟล์

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เปิดฉากเกม (`main.tscn`) ทิ้งไว้เฉยๆ ไม่ต้องคลิกอะไร | พื้นหลังกระดานเลื่อนซ้าย-ขวา-บน-ล่างเบาๆ วนต่อเนื่องช้าๆ ไม่หยุดนิ่งสนิทเหมือนเดิม |
| เดินหมาก/คลิกเลือก ระหว่างพื้นหลังกำลังขยับ | ตำแหน่งกระดาน/ตัวหมากไม่กระทบเลย (คนละ node กับ Background) |

### 11.24 หมากขยับมีชีวิต (Idle Sway แทน Sprite Sheet)

หมากทุกตัวยังเป็นรูปนิ่งใบเดียว (`Sprite2D`) ทำท่าทางจริง (เดิน/โจมตี) ต้องมี sprite sheet หรือ
`Skeleton2D` rig ซึ่งเป็นงานอาร์ตที่โปรเจกต์นี้ยังไม่มี asset รองรับ — ทำเวอร์ชันเบาๆ ด้วยโค้ดล้วนๆ
แทน: ให้หมากทุกตัวแกว่งตัวเอียงซ้าย-ขวาเบาๆ วนตลอดเวลา (idle sway) ต่างจังหวะกันทั้งกระดาน

**STEP — แก้ `script/piece_spawner.gd`**

1. เปิดไฟล์ `script/piece_spawner.gd`
2. หาบรรทัด `const VICTIM_FALL_DURATION := 0.3  # เวลาที่หมากซึ่งโดนกินสะบัด/ล้ม/จางหายก่อนถูกลบทิ้งจริง`
3. เพิ่มโค้ดนี้ต่อท้าย:
```gdscript
const IDLE_SWAY_ANGLE_DEG := 1.5   # องศา มุมเอียงสูงสุดตอนแกว่ง (เบามาก ไม่ให้ดูรก)
const IDLE_SWAY_MIN_DURATION := 1.6
const IDLE_SWAY_MAX_DURATION := 2.4
```
4. หาฟังก์ชัน `spawn_piece()` แล้วหาบรรทัด:
```gdscript
	add_child(piece)
	_spawn_power_aura(piece)
	place_piece(piece, cell)
```
5. แก้เป็น (แทรก `_start_idle_sway(piece)` เข้าไป):
```gdscript
	add_child(piece)
	_spawn_power_aura(piece)
	_start_idle_sway(piece)
	place_piece(piece, cell)
```
6. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันนี้ต่อท้าย:
```gdscript
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
```
7. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ทำไมใช้ `rotation` ไม่ใช่ `scale`/`position`** — สอง property นั้นถูกใช้งานเต็มไปหมดแล้วโดย
> ระบบอื่น (เลือกหมาก, เดิน, ปะทะ) ถ้าไปแกว่งซ้อนจะชนกันจนหมากกระตุก/ขนาดเพี้ยน — `rotation`
> เกือบไม่มีใครแตะเลย (ยกเว้นตอนแตกกระจายตอนตายซึ่งเกิด**หลัง**หมากถูกซ่อนไปแล้ว ไม่ชนกัน) จึงปลอดภัย
> สุดที่จะใช้เป็นช่องทางแยกสำหรับ animation แบบต่อเนื่องนี้
>
> `bind_node(piece)` สำคัญมาก — ถ้าลืมใส่ tween จะพยายามขยับ `rotation` ของหมากที่ถูกลบไปแล้ว
> (โดนกินตาย) ซึ่งจะไม่ error ร้ายแรงแต่เปลืองทรัพยากรเปล่าๆ เพราะ tween วนไม่รู้จบไม่เคยถูกฆ่าทิ้ง

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เริ่มเกมใหม่ | หมากทุกตัวบนกระดานแกว่งเอียงซ้าย-ขวาเบาๆ ไม่พร้อมกัน (แต่ละตัวจังหวะไม่ตรงกัน) |
| กินหมากตัวหนึ่ง | ตัวที่ตายไม่มี error ใดๆ ขึ้นใน Output (tween ถูก `bind_node()` ฆ่าทิ้งอัตโนมัติ) |
| เบี้ย promote เป็นหมากตัวใหม่ | หมากตัวใหม่ก็แกว่งได้ตามปกติ (เรียก `spawn_piece()` ซ้ำ ผ่าน `_start_idle_sway()` เหมือนกัน) |

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** นี่เป็นแค่เวอร์ชันเบาๆ ทดแทน sprite sheet/rig จริง — ถ้าอยากได้
> ท่าทางเดิน/โจมตี/ตายที่สมจริงกว่านี้ (ขยับขา/แขนจริง) ยังต้องมี sprite sheet หรือ `Skeleton2D` rig
> เป็น asset เพิ่มอยู่ดี โค้ดส่วนนี้แก้ให้ทีหลังได้แต่ต้องมีรูปมาก่อน

### 11.25 สรุประบบ Passive Skill และ Active Skill (อ้างอิงรวม)

หมากทั้ง 6 ชนิดมีทั้ง Passive Skill (ทำงานอัตโนมัติตามเงื่อนไข ไม่ต้องกดอะไร — ตอนที่ 11.8/11.11)
และ Active Skill (กดใช้เองแทนการเดิน มี cooldown — ตอนที่ 11.9/11.13) คนละระบบ ทำงานคู่ขนานกันได้
โดยไม่ชนกัน — สรุปรวมไว้ที่นี่ให้เห็นภาพทั้งหมดในที่เดียว

**Passive Skill** — เช็คจาก `piece_kind` ล้วนๆ ใน `passive_skills.gd` จึงครอบคลุม**หมากทุกตัวบน
กระดานทั้ง 32 ตัวโดยอัตโนมัติ** ทันทีที่ spawn (ไม่ต้องตั้งค่าเพิ่มรายตัว):

| หมาก | จำนวน/ฝ่าย | ชื่อ Passive | เงื่อนไข | ผล |
|---|---|---|---|---|
| เบี้ย (Pawn) | 8 | แนวรบเหล็ก | มีเบี้ยฝ่ายเดียวกันยืนติดข้างๆ (ซ้ายหรือขวา) | ลดดาเมจที่ได้รับ 20% |
| เรือ (Rook) | 2 | ป้อมปราการ | ยังไม่เคยขยับเลย (`has_moved == false`) | ลดดาเมจที่ได้รับ 30% |
| ม้า (Knight) | 2 | จู่โจมครั้งแรก | ยังไม่เคยโจมตีสำเร็จในเกมนี้ (`has_attacked == false`) | ดาเมจที่ทำ +25% |
| บิชอป (Bishop) | 2 | แสงชำระ | เป้าหมายเลือดเต็ม 100% (ยังไม่เคยโดนตี) | ดาเมจที่ทำ +15% |
| ควีน (Queen) | 1 | โค่นล้ม | เป้าหมายเลือดเหลือ ≤25% | ดาเมจที่ทำ ×2 |
| คิง (King) | 1 | ราชันคุ้มกัน | หมากฝ่ายเดียวกันใดๆ (รวมคิงเอง) อยู่ในระยะประชิด 1 ช่องรอบคิง | ลดดาเมจที่ได้รับ 15% |

ตัวคูณทั้งหมดคำนวณผ่าน `PassiveSkills.compute_damage()` จุดเดียว (`_attacker_multiplier()` +
`_victim_multiplier()` คูณกัน) ทั้งเกมจริง (`Board.try_move()`) และ AI จำลอง (`chess_ai.gd`) เรียก
จุดนี้เหมือนกันหมด — แก้ค่าที่เดียวมีผลทั้งสองทาง

**Active Skill** — เก็บสถานะเป็น instance field ในตัวหมากแต่ละชิ้นจริง (`skill_cooldown_remaining`,
`attack_buff_multiplier` ใน `chess_piece.gd`) จึงครอบคลุม**หมากทุกตัวทั้ง 32 ตัวเช่นกัน** โดยแต่ละตัว
มี cooldown แยกอิสระจากกัน (เบี้ย 8 ตัวใช้สกิลได้คนละจังหวะ ไม่ผูกรวมกัน):

| หมาก | จำนวน/ฝ่าย | สกิล | ผล | effect_kind |
|---|---|---|---|---|
| เบี้ย (Pawn) | 8 | ฮีลตัวเอง | +40 เลือด (ไม่เกิน max_hp) | `"heal"` |
| ม้า (Knight) | 2 | โจมตีตาถัดไปแรงขึ้น | `attack_buff_multiplier = 1.5` (คูณต่อกับ passive จู่โจมครั้งแรกได้) | `"buff"` |
| บิชอป (Bishop) | 2 | ฮีลเต็ม | `hp = max_hp` | `"heal"` |
| เรือ (Rook) | 2 | เสริมเกราะถาวร | `max_hp += 30`, `hp += 30` | `"heal"` |
| ควีน (Queen) | 1 | โจมตีตาถัดไปแรงขึ้น | `attack_buff_multiplier = 2.0` (คูณต่อกับ passive โค่นล้มได้) | `"buff"` |
| คิง (King) | 1 | ปลุกใจทีม | หมากฝ่ายเดียวกัน**ทุกตัว** +20 เลือด | `"rally"` |

กติกาการใช้ (ทุกชนิดเหมือนกันหมด): `can_use_skill()` คืน `true` เมื่อ `skill_cooldown_remaining <= 0`
เท่านั้น — ใช้แล้ว cooldown รีเซ็ตเป็น `SKILL_COOLDOWN_TURNS` (6 ตา) และเสียตาเหมือนเดินปกติ (ตัวหมาก
ไม่ขยับ) ลดลงทุกครั้งที่เสียตา ไม่ว่าจะเดินหรือใช้สกิล (`Board._tick_skill_cooldowns()`)

> ⚠️ **อัปเดต:** ข้อจำกัด "AI ไม่มีวันใช้ Active Skill เอง" ที่เคยเขียนไว้ตรงนี้ถูกแก้แล้วในตอนที่
> 11.26 ถัดไป — `ChessAI.best_move()` พิจารณาการใช้สกิลเป็นตัวเลือกคู่ขนานกับตาเดินปกติแล้ว

### 11.26 AI ใช้ Active Skill เองได้

ก่อนหน้านี้ `ChessAI.best_move()` เดินผ่าน `ChessRules.all_legal_moves()` เท่านั้น ไม่รู้จัก
`try_use_skill()` เลย ทำให้ AI (ฝ่ายดำ โหมด PVC) ไม่มีวันกดใช้สกิลตลอดเกม — ตอนนี้ให้ AI พิจารณา
"การใช้สกิล" เป็นตัวเลือกคู่ขนานกับ "การเดิน" ปกติ โดยจำลองผลของสกิล (ฮีล HP) ผ่านกลไก `hp_overrides`
เดียวกับที่ใช้จำลองดาเมจอยู่แล้ว แล้วเทียบคะแนนกับตาเดินทั้งหมดตรงๆ เลือกตัวที่ดีที่สุด

**ข้อจำกัดที่ยอมรับตั้งแต่ต้น:**
- สกิลบัฟโจมตี (ม้า/ควีน) ไม่มีผลต่อคะแนนในตานั้นเลย เพราะ `material_score()` ไม่รู้จัก "ดาเมจใน
  อนาคต" — AI แทบไม่เลือกใช้ 2 สกิลนี้เอง (ยกเว้นไม่มีตาเดินอื่นดีกว่าเลย)
- สกิลเสริมเกราะเรือดูไม่มีประโยชน์ในสายตา AI ถ้าเรือเลือดเต็มอยู่แล้ว เพราะ `max_hp` ที่เพิ่มขึ้นจริง
  ไม่ถูกนับใน simulation แบบง่ายนี้ (คะแนนคำนวณจาก `piece.max_hp` จริงเป็นตัวหาร ไม่ใช่ค่าจำลอง)
- การพิจารณาสกิลเกิดแค่ที่ **ตาแรกสุดของ AI เท่านั้น (root)** ไม่ได้คิดลึกลงไปว่าอนาคตควรใช้สกิลไหน
  ก่อน — เพียงพอสำหรับ `SEARCH_DEPTH = 2` ที่ใช้อยู่

**STEP 1 — แก้ `script/chess_ai.gd`**

1. เปิดไฟล์ `script/chess_ai.gd`
2. หาฟังก์ชัน `_apply_hp_aware()` แล้วหาบรรทัดสุดท้าย
   (`return {"state": ChessRules.copy_state(state), "overrides": new_overrides}`) ก่อนคอมเมนต์
   `## หาตาเดินที่ดีที่สุดสำหรับฝ่าย side ที่ความลึก depth ชั้น`
3. แทรกฟังก์ชันใหม่ 2 อันนี้เข้าไประหว่าง `_apply_hp_aware()` กับ `best_move()`:
```gdscript
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
## จึงเป็นข้อจำกัดที่ยอมรับ: AI แทบไม่เลือกใช้ 2 สกิลนี้เอง (ดูหมายเหตุด้านบน)
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
```
4. หาฟังก์ชัน `best_move()` ทั้งฟังก์ชัน:
```gdscript
static func best_move(state: Array, side: int, ep_target: Vector2i, depth: int = 2) -> Dictionary:
	var moves: Array = ChessRules.all_legal_moves(state, side, ep_target)
	if moves.is_empty():
		return {}

	var maximizing := side == ChessPiece.Team.BLACK
	var best_score: float = -INF if maximizing else INF
	var best_moves: Array = []  # เก็บทุกตาที่คะแนนเท่ากับดีที่สุด แล้วค่อยสุ่มเลือก 1 อัน

	for move in moves:
		# เริ่มจาก overrides ว่างเปล่า (ตอนนี้ยังไม่มีการจำลองใดๆ มาก่อนหน้า) piece.hp จริงยังเชื่อถือได้
		var result := _apply_hp_aware(state, move.from, move.to, ep_target, {})
		var score := _minimax(result.state, depth - 1, ChessRules.opponent(side), -INF, INF, result.overrides)
		var better: bool = score > best_score if maximizing else score < best_score
		if better:
			best_score = score
			best_moves = [move]
		elif score == best_score:
			best_moves.append(move)

	# สุ่มในบรรดาตาที่ดีที่สุดเท่าๆ กัน กัน AI เดินซ้ำแบบเดิมทุกครั้งที่เจอสถานการณ์เดียวกัน
	return best_moves[randi() % best_moves.size()]
```
5. แก้เป็น (เพิ่มการพิจารณาสกิลเป็นตัวเลือกคู่ขนาน):
```gdscript
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
		var better: bool = score > best_score if maximizing else score < best_score
		var action := {"type": "skill", "cell": cell}
		if better:
			best_score = score
			best_actions = [action]
		elif score == best_score:
			best_actions.append(action)

	# สุ่มในบรรดาตัวเลือกที่ดีที่สุดเท่าๆ กัน กัน AI เดินซ้ำแบบเดิมทุกครั้งที่เจอสถานการณ์เดียวกัน
	return best_actions[randi() % best_actions.size()]
```
6. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ทำไมตาเดินปกติไม่มี key `"type"` แต่ตาสกิลมี** — `ai_player.gd` (STEP 2) จะเช็ค
> `action.get("type", "") == "skill"` เพื่อแยกว่าต้องสั่ง `try_use_skill()` หรือ `try_move()` — ตาเดิน
> ปกติที่มาจาก `ChessRules.all_legal_moves()` ไม่มี key นี้อยู่แล้ว ใช้ `.get()` พร้อมค่า default กันพัง

**STEP 2 — แก้ `script/ai_player.gd`**

1. เปิดไฟล์ `script/ai_player.gd`
2. หาโค้ดนี้ท้ายฟังก์ชัน `_maybe_take_turn()`:
```gdscript
	var move: Dictionary = ChessAI.best_move(board.board_state, AI_SIDE, board.en_passant_target, SEARCH_DEPTH)
	if move.is_empty():
		return  # ไม่มีตาเดิน (ไม่ควรเกิด เพราะ Board._evaluate_status ควรจับจบเกมได้ก่อนหน้านี้แล้ว)
	board.try_move(move.from, move.to)
```
3. แก้เป็น (แยกกรณีสกิล/เดินปกติ):
```gdscript
	var action: Dictionary = ChessAI.best_move(board.board_state, AI_SIDE, board.en_passant_target, SEARCH_DEPTH)
	if action.is_empty():
		return  # ไม่มีตาเดิน/สกิลให้เลือกเลย (ไม่ควรเกิด เพราะ Board._evaluate_status ควรจับจบเกมได้ก่อนหน้านี้แล้ว)
	if action.get("type", "") == "skill":
		board.try_use_skill(action.cell)
	else:
		board.try_move(action.from, action.to)
```
4. กด `Ctrl+S` เซฟไฟล์

**STEP 3 — กันสกิลที่ไม่มีผลจริงไม่ให้ชนะเสมอกับเดินเฉยๆ (แก้ `script/chess_ai.gd`)**

ทดสอบจริงพบว่า "ใช้สกิลแต่ไม่มีผล" (เช่นฮีลตอนเลือดเต็มอยู่แล้ว) กับ "เดินเฉยๆ" ให้คะแนนเท่ากันเป๊ะ
(ทั้งคู่ = 0) ทำให้ `randi() % best_actions.size()` มีโอกาสสุ่มติดสกิลได้ทั้งที่ไม่มีประโยชน์อะไรเลย
— แก้ด้วยการหักคะแนนของสกิลลงนิดเดียว (เล็กจนไม่กระทบตอนสกิลมีประโยชน์จริง) ให้ตาเดินชนะเสมอเวลา
เสมอกันเป๊ะๆ

1. เปิดไฟล์ `script/chess_ai.gd`
2. หาบรรทัด `const CHECKMATE_SCORE := 9999.0`
3. เพิ่มโค้ดนี้ต่อท้าย:
```gdscript
## ค่าติดลบเล็กมาก หักออกจากคะแนนของ "การใช้สกิล" เสมอ — กันไม่ให้ AI เลือกใช้สกิลที่ให้ผลเท่ากับ
## เดินเฉยๆ (เช่นฮีลตอนเลือดเต็มอยู่แล้ว) เพราะคะแนนเท่ากันเป๊ะจะถูกสุ่มเลือกได้ 50/50 — ต้องเล็กกว่า
## ผลจริงของสกิลมากๆ (เบี้ยฮีล +40 มีผลต่อคะแนนหลักสิบ) ไม่งั้นจะไปกลบประโยชน์จริงของสกิลจนไม่ถูกเลือกเลย
const SKILL_TIEBREAK_PENALTY := 0.001
```
4. หาฟังก์ชัน `best_move()` แล้วหาบล็อกนี้ (ส่วนที่วนลูป `skill_cells`):
```gdscript
	# พิจารณาสกิลเป็นตัวเลือกคู่ขนานกับตาเดิน — เทียบคะแนนกันตรงๆ ในบันไดเดียวกัน
	for cell in skill_cells:
		var result := _apply_skill_aware(state, cell, {})
		var score := _minimax(result.state, depth - 1, ChessRules.opponent(side), -INF, INF, result.overrides)
		var better: bool = score > best_score if maximizing else score < best_score
		var action := {"type": "skill", "cell": cell}
		if better:
			best_score = score
			best_actions = [action]
		elif score == best_score:
			best_actions.append(action)
```
5. แก้เป็น (เพิ่ม 2 บรรทัดหักคะแนนก่อนเทียบ):
```gdscript
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
```
6. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ทำไม `-SKILL_TIEBREAK_PENALTY if maximizing else SKILL_TIEBREAK_PENALTY`** — `maximizing` เป็น
> `true` ตอน AI (ฝ่ายดำ) กำลังตัดสินใจที่ root (คะแนนบวก = ดีกับฝ่ายดำ) จึงต้อง**ลบ**เพื่อทำให้สกิลดู
> แย่ลงเล็กน้อยในมุมมองของฝ่ายดำ — ถ้าวันหลังมีคนเรียกฟังก์ชันนี้ให้ฝ่ายขาวตัดสินใจเอง (`maximizing`
> เป็น `false`) ต้อง**บวก**แทน เพราะคะแนนสูง = แย่สำหรับฝ่ายขาว (มุมมองกลับด้าน)

### ✅ ทดสอบ

**ทดสอบแล้วด้วยสคริปต์แยก (`SceneTree` script รันผ่าน `godot --headless --script`):** จำลอง 2
สถานการณ์ตรงๆ ผ่าน `ChessAI.best_move()` — (1) เบี้ยฝ่ายดำเลือดเหลือ 15/100 บนกระดานที่มีแค่คิง 2
ฝ่าย: AI เลือก `{"type": "skill", "cell": (3, 3)}` ตรงตามที่คาด (2) เบี้ยฝ่ายดำเลือดเต็ม 100/100
สถานการณ์เดียวกัน: หลังเพิ่ม `SKILL_TIEBREAK_PENALTY` แล้ว AI ไม่เลือกสกิลอีกต่อไป (ก่อนแก้เคย
สุ่มติดสกิลทั้งที่ไม่มีประโยชน์)

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เล่นโหมด PVC จงใจปล่อยให้หมากฝ่ายดำโดนตีจนเลือดเหลือน้อย (เช่น < 40%) | ตาถัดไปของ AI มีโอกาสสั่งใช้สกิลฮีล (ปุ่มไม่ขยับ ขึ้น sparkle สีเขียว) แทนการเดินปกติ |
| ไม่มีหมากฝ่าย AI ตัวไหนเลือดต่ำพอจะได้ประโยชน์จากการฮีล | AI เดินปกติเหมือนเดิมทุกอย่าง ไม่สุ่มติดสกิลที่ไม่มีผลอีกต่อไป |
| ม้า/ควีนฝ่าย AI มีสกิลใช้ได้ | แทบไม่เห็น AI กดใช้เอง (ตามข้อจำกัดที่ยอมรับไว้ — บัฟไม่มีผลต่อคะแนนในตานั้น) |
| เรือฝ่าย AI เลือดเต็มอยู่แล้วมีสกิลใช้ได้ | แทบไม่เห็น AI กดใช้ (เพราะดูไม่มีประโยชน์ในสายตา simulation แบบง่ายนี้) |
| คิงฝ่าย AI มีสกิลใช้ได้ และมีพวกพ้องเลือดต่ำหลายตัว | มีโอกาสสูงที่ AI จะกดใช้ปลุกใจทีม (ฮีลได้หลายตัวพร้อมกัน คะแนนรวมสูง) |

> **ยังไม่ได้ทำ (ต่อยอดได้ทีหลัง):** บัฟโจมตี (ม้า/ควีน) และเสริมเกราะเรือยังไม่ถูกให้คุณค่าจริงในสายตา
> AI (ตามข้อจำกัดที่อธิบายไว้ด้านบน) — ถ้าอยากให้ฉลาดขึ้นต้องขยาย `material_score()`/`positional_score()`
> ให้รู้จักตัวคูณ `attack_buff_multiplier` และ `max_hp` ที่เพิ่มขึ้นจริงด้วย ซึ่งซับซ้อนกว่านี้พอสมควร

### 11.27 ปรับสมดุลค่า HP/พลังโจมตี (Balance)

ค่าเดิม (`BASE_HP = 100`, พลังโจมตี Pawn=20, Knight/Bishop=30, Rook=40, Queen=60, King=35) ทำให้เบี้ย
ต้องตี **5 ครั้ง** กว่าจะฆ่าอะไรก็ได้ ซึ่งช้ามากโดยเฉพาะช่วงต้นเกมที่ปะทะกันด้วยเบี้ยบ่อยสุด — ยกพลัง
โจมตีขึ้นทั้งกระดาน ให้จำนวนครั้งที่ต้องตีกระชับขึ้น แต่ยังคงลำดับความแรงเดิมของแต่ละชนิดไว้:

| หมาก | เดิม | ใหม่ | ครั้งที่ต้องตี (เดิม → ใหม่) |
|---|---|---|---|
| เบี้ย | 20 | 30 | 5 → 3.3 |
| ม้า/บิชอป | 30 | 35 | 3.3 → 2.9 |
| เรือ | 40 | 50 | 2.5 → 2.0 |
| ควีน | 60 | 75 | 1.7 → 1.3 |
| คิง | 35 | 40 | 2.9 → 2.5 |

**STEP — แก้ `script/chess_piece.gd`**

1. เปิดไฟล์ `script/chess_piece.gd`
2. หาฟังก์ชัน `base_attack()`:
```gdscript
static func base_attack(kind: int) -> float:
	match kind:
		Kind.PAWN: return 20.0
		Kind.KNIGHT: return 30.0
		Kind.BISHOP: return 30.0
		Kind.ROOK: return 40.0
		Kind.QUEEN: return 60.0
		Kind.KING: return 35.0
		_: return 20.0
```
3. แก้ตัวเลขเป็น:
```gdscript
static func base_attack(kind: int) -> float:
	match kind:
		Kind.PAWN: return 30.0
		Kind.KNIGHT: return 35.0
		Kind.BISHOP: return 35.0
		Kind.ROOK: return 50.0
		Kind.QUEEN: return 75.0
		Kind.KING: return 40.0
		_: return 30.0
```
4. กด `Ctrl+S` เซฟไฟล์

> ⚠️ **ค่านี้เป็นแค่จุดเริ่มต้นที่สมเหตุสมผล ไม่ใช่ตัวเลขศักดิ์สิทธิ์** — ปรับต่อได้ตามความรู้สึกตอน
> เล่นจริง ถ้ายังรู้สึกยาวไปอีก ลองเพิ่มทุกค่าอีก 20-30% พร้อมกัน (คงสัดส่วนเดิมไว้) หรือถ้าเร็วไป
> ลดกลับลงมาได้ — ค่าฮีลของสกิล (Pawn +40, Rook +30, King rally +20) ไม่ได้ปรับตาม เพราะ 100 HP ยัง
> เป็นฐานเท่าเดิม แค่ตายเร็วขึ้นเฉยๆ (ยังฮีลกลับมาได้สัดส่วนเท่าเดิม)

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| เบี้ยตีเบี้ยฝ่ายตรงข้าม (ไม่มี passive ลดดาเมจ) | ตายภายใน 4 ครั้ง (ปัดขึ้นจาก 3.3) แทนที่จะเป็น 5 ครั้งเหมือนเดิม |
| ควีนตีอะไรก็ตามที่เลือดเต็ม (ไม่มี passive) | มักตายภายใน 2 ครั้ง |
| เล่นทั้งเกมจนจบ | รู้สึกกระชับขึ้นกว่าเดิมชัดเจน ไม่ต้องแลกหมัดกันนานเกินไปเหมือนก่อนปรับ |

### 11.28 Pause Menu Fade

ตอนนี้กด Pause/Resume เมนูโผล่/หายทันที (`pause_menu.visible = true/false` ตรงๆ) — เพิ่ม fade เข้า/
ออกนุ่มนวลขึ้น ใช้ทั้งตอนกด Pause และตอนเกมจบ (หน้าจอผลก็ใช้ `pause_menu` เดียวกัน)

**STEP — แก้ `script/main.gd`**

1. เปิดไฟล์ `script/main.gd`
2. หาบรรทัด `const BG_SWAY_DURATION := 4.0   # วินาทีต่อช่วงการขยับ 1 รอบ (ยิ่งมากยิ่งขยับช้า นุ่มนวล)`
3. เพิ่มโค้ดนี้ต่อท้าย:
```gdscript
const PAUSE_FADE_DURATION := 0.25
```
4. หาฟังก์ชัน `_on_pause_pressed()`:
```gdscript
func _on_pause_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	if _finished:
		return  # เกมจบแล้ว เมนูค้างอยู่ ไม่มีอะไรให้ pause
	result_label.text = ""
	pause_menu.visible = true
	get_tree().paused = true
```
5. แก้เป็น (แทนบรรทัด `pause_menu.visible = true` ด้วยฟังก์ชันใหม่):
```gdscript
func _on_pause_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	if _finished:
		return  # เกมจบแล้ว เมนูค้างอยู่ ไม่มีอะไรให้ pause
	result_label.text = ""
	_show_pause_menu()
	get_tree().paused = true
```
6. หาฟังก์ชัน `_on_resume_pressed()`:
```gdscript
func _on_resume_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	pause_menu.visible = false
	get_tree().paused = false
```
7. แก้เป็น:
```gdscript
func _on_resume_pressed():
	AudioManager.play_sfx(SFX_BUTTON)
	_hide_pause_menu()
	get_tree().paused = false
```
8. หาฟังก์ชัน `_on_game_ended()` แล้วหาบรรทัดท้ายฟังก์ชัน:
```gdscript
	result_label.text = _result_text(result, winner)
	resume_button.visible = false  # เกมจบแล้ว เล่นต่อไม่ได้ เหลือแค่ Restart / Main Menu
	pause_menu.visible = true
	get_tree().paused = true
```
9. แก้เป็น:
```gdscript
	result_label.text = _result_text(result, winner)
	resume_button.visible = false  # เกมจบแล้ว เล่นต่อไม่ได้ เหลือแค่ Restart / Main Menu
	_show_pause_menu()
	get_tree().paused = true
```
10. เลื่อนไปท้ายไฟล์ แล้วเพิ่มฟังก์ชันเหล่านี้ต่อท้าย:
```gdscript
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
```
11. กด `Ctrl+S` เซฟไฟล์

### ✅ ทดสอบ

| ทดสอบ | ผลที่ควรได้ |
|---|---|
| กด Pause ระหว่างเล่น | เมนูค่อยๆ จางเข้ามาแทนที่จะโผล่ทันที |
| กด Resume | เมนูค่อยๆ จางหายออกไป (ไม่ใช่หายวับทันที) |
| สังเกตระหว่าง fade ทั้งสองทาง | เกมยัง `paused = true` ตลอดช่วง fade แต่แอนิเมชันยังขยับต่อได้ปกติ ไม่ค้าง |
| เล่นจนจบเกม (ชนะ/แพ้/อับ) | หน้าจอผลเฟดเข้าเหมือนกับตอนกด Pause |

---

## ตอนที่ 12 — ตรวจงานครั้งสุดท้าย

### เช็คลิสต์ไฟล์ทั้งหมด

```
chess-th/
├── Scene/
│   ├── loading_screen.tscn      ตอนที่ 2
│   ├── main_menu.tscn           ตอนที่ 3
│   ├── SceneTransition.tscn     ตอนที่ 1
│   ├── board.tscn               ตอนที่ 5, 6, 7, 9
│   └── main.tscn                ตอนที่ 5, 8, 10
├── script/
│   ├── game_manager.gd          ตอนที่ 1   [Autoload]
│   ├── SceneTransition.gd       ตอนที่ 1   [Autoload]
│   ├── loading.gd               ตอนที่ 2
│   ├── main_menu.gd             ตอนที่ 3
│   ├── chess_piece.gd           ตอนที่ 4   ข้อมูลหมาก 1 ตัว
│   ├── chess_rules.gd           ตอนที่ 4   กติกาล้วน (ไม่ผูก node)
│   ├── chess_ai.gd              ตอนที่ 9   AI ล้วน (ไม่ผูก node)
│   ├── Board.gd                 ตอนที่ 5   พิกัด + สถานะเกม + ตัวคุมเกม
│   ├── piece_spawner.gd         ตอนที่ 6   สร้าง/จัดวาง/animate sprite + สั่งเล่น animation การกิน
│   ├── slash_effect.gd          ตอนที่ 6   เอฟเฟกต์รอยฟันตอนกิน (วาดเอง ไม่ใช้ asset)
│   ├── impact_ring.gd           ตอนที่ 11  วงแหวนกระแทกพื้นตอนหมากตาย (วาดเอง ไม่ใช้ asset)
│   ├── damage_popup.gd          ตอนที่ 11  ตัวเลขดาเมจลอยขึ้นสไตล์ RPG (วาดเอง ไม่ใช้ asset)
│   ├── passive_skills.gd        ตอนที่ 11  Passive skill ต่อชนิดหมาก (ไม่ผูก node) — เรือ+ควีน+เบี้ย+ม้า
│   ├── skill_button.gd          ตอนที่ 11  ปุ่ม Active skill ลอยเหนือหัวหมาก (วาดเอง ไม่ใช้ asset)
│   ├── promotion_picker.gd      ตอนที่ 11  ป๊อปอัพเลือกโปรโมทเบี้ย Q/R/B/N (วาดเอง ไม่ใช้ asset)
│   ├── promote_glow.gd          ตอนที่ 11  แสงพวยพุ่งตอนเบี้ย promote (วาดเอง ไม่ใช้ asset)
│   ├── click_to_move.gd         ตอนที่ 7, 11   รับ input จากคน + วาดไฮไลต์เต้นจังหวะ + เช็คคลิกปุ่มสกิล/โปรโมท
│   ├── ai_player.gd             ตอนที่ 9   สั่งเดินแทน AI
│   ├── main.gd                  ตอนที่ 8, 11   Pause menu + ผลจบเกม + หน้าจอสั่นตามแรงตี + พื้นหลังขยับ
│   ├── audio_manager.gd         ตอนที่ 10  [Autoload] คุมเพลง/SFX ทั้งเกม
│   ├── settings.gd              ตอนที่ 10  ต่อ slider/ปุ่มกับ AudioManager
│   └── stats_manager.gd         ตอนที่ 11  [Autoload] สถิติสะสม + achievement (ไม่ผูก scene node)
└── asset/  (ตอนที่ 0)
	├── audio/{ชื่อเพลง}.mp3     ตอนที่ 10
	└── ui/settings_panel.png, settings_grabber.png   ตอนที่ 10 (ถ้าใช้ภาพกรอบสำเร็จรูป)
```

> `chess_piece.gd` (ตอนที่ 4), `piece_spawner.gd` (ตอนที่ 6), `Board.gd` (ตอนที่ 5),
> `click_to_move.gd` (ตอนที่ 7), `main.gd` (ตอนที่ 8) และ `chess_ai.gd` (ตอนที่ 9) ไม่ใช่ไฟล์ใหม่
> แต่ถูกแก้เพิ่มเติมหลายรอบในตอนที่ 11 (ระบบเลือด/เอฟเฟกต์/passive/active skill/animation เสริม) —
> ดูเนื้อหาตอนที่ 11 ทั้งหมด (11.1–11.24) สำหรับโค้ดเวอร์ชันล่าสุด

ไฟล์ scene เพิ่มเติมจากตอนที่ 10: `Scene/settings.tscn`

### ทิศทางการพึ่งพา

```
chess_piece.gd  ←  chess_rules.gd  ←  chess_ai.gd
	   ↑                 ↑                 ↑
	   ↑          passive_skills.gd ────────┤ (Board.gd และ chess_ai.gd เรียก
	   ↑                 ↑                 ↑  compute_damage() ทั้งคู่)
	   └──────────── Board.gd ─────────────┘
			  ↑           ↑           ↑
   piece_spawner   click_to_move   ai_player
		↑
  slash_effect
						↑
					 main.gd
```

`chess_rules.gd` และ `chess_ai.gd` ไม่รู้จัก node ใดเลย → ยกไปใช้โปรเจกต์อื่นหรือเขียนเทสต์ได้ทันที

### ปัญหาที่พบบ่อย + วิธีแก้

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| `Identifier "SceneTransition" not declared` | ลืมตั้ง Autoload หรือพิมพ์ชื่อผิด | ตรวจ Project Settings → Globals → Autoload ชื่อต้องตรงเป๊ะ |
| `enum Color` คอมไพล์ไม่ผ่าน | ชนกับ `Color` ของ Godot | เปลี่ยนชื่อ enum เป็นอย่างอื่น เช่น `Team` |
| `Cannot infer the type of "x"` | Godot เดา type จาก ternary, จาก `Node`, หรือจากการวน `for x in [a, b]` (array literal) ไม่ได้ | ระบุ type ตรงๆ ทุกครั้งที่ใช้ `:=` กับค่าที่มาจากที่มาไม่ชัดเจน: `var x: int = a if c else b` หรือ `var x: int = cell.x + dx` ตอนวน `for dx in [-1, 1]` |
| ไม่เห็นตัวหมากเลย | ชื่อไฟล์รูปไม่ตรง | ดูแผง Output หา warning `หารูปหมากไม่เจอ:` แล้วแก้ชื่อไฟล์ |
| อ่าน `board_state` แล้ว index หลุด/error | `_ready()` ของ **node ลูก** (`ClickToMove`/`Pieces`) รันก่อน **node แม่** (`Board`) เสมอ | เพิ่ม guard เช็ค `board.board_state.size() == 8` ก่อนอ่านค่า (ดู `_board_ready()` ใน `click_to_move.gd`) |
| เส้นตารางแดงโผล่ตอนเล่นเกม | ลืม `Engine.is_editor_hint()` ใน `_draw()` | ดูโค้ด `Board.gd` ตอนที่ 5.2 ให้ครบ |
| กดไฮไลต์/วาดกรอบแล้วไม่อัปเดตตามสถานะใหม่ | `_draw()` ใน Godot รันเฉพาะตอนถูกเรียก `queue_redraw()` เท่านั้น ไม่ได้รันทุกเฟรมอัตโนมัติ | เรียก `queue_redraw()` ทุกครั้งที่ state ที่ใช้วาดเปลี่ยน (ดู `_on_board_changed()` ใน `click_to_move.gd`) |
| กรอบไฮไลต์ทับตัวหมาก | `Pieces` ไม่ได้ตั้ง `z_index = 1` | ดู `piece_spawner.gd` `_ready()` |
| กรอบไฮไลต์หายไปหมด | ตั้ง `ClickToMove.z_index = -1` ทำให้ไปอยู่ต่ำกว่า Background (z_index เทียบกันทั้งฉาก) | อย่ากดตัวเองลง ให้ยก `Pieces` ขึ้นแทน |
| คลิกลำตัวหมากตัวสูงแล้วไปโดนช่องแถวบนแทน | `world_to_cell()` หาแค่ "ช่องที่ศูนย์กลางใกล้เมาส์สุด" แต่หมากตัวสูงยืนล้ำขึ้นไปทับแถวข้างบน | hit-test กรอบสี่เหลี่ยมของ sprite จริงก่อน แล้วค่อย fallback ไปใช้ระยะทางถึงศูนย์กลางช่อง (ดู `_piece_cell_under()` ใน `click_to_move.gd`) |
| หมากขนาดเพี้ยนสะสมหลังเลือก/ยกเลิกหลายรอบ | คูณ/หารด้วย `SELECTED_SCALE_MULT` ตรงๆ ทำให้ float คลาดเคลื่อนสะสม | เก็บ `resting_scale` ไว้เป็นค่าอ้างอิง แล้วเซ็ตค่ากลับตรงๆ แทนการหารคืน (ดู `ChessPiece.resting_scale`) |
| ปุ่มใน pause menu กดไม่ได้ | ลืมตั้ง `Process Mode = Always` | ตั้งที่ `PauseButton` และ `PauseMenu` |
| กด Main Menu แล้วจอค้าง | ลืม `get_tree().paused = false` ก่อน `change_scene()` | ดู `main.gd` `_on_main_menu_pressed()` |
| หมากกระตุกตอนเดิน | เรียก `_deselect()` แทน `_clear_selection_state()` ก่อนสั่งเดิน → 2 tween แย่งกันแก้ scale | ดู `_handle_click()` ตอนที่ 7.2 |
| popup รุกฆาตเด้งกลางทางที่หมากยังเลื่อน | `_evaluate_status()` รันก่อน animation จบ | ต้อง `await tween.finished` ก่อน แล้วค่อย emit signal |
| `TextureButton` error ตอนโหลดฉาก | ประกาศ type เป็น `Button` แต่ node จริงเป็น `TextureButton` (คนละแขนงกัน) | แก้ type annotation ให้ตรงกับ node จริง |
| โหมด PVC ผู้เล่นยังคลิกเดินฝ่ายดำ (ฝั่ง AI) เองได้ | `click_to_move.gd` เช็คแค่ `piece.side == side_to_move` ไม่ได้แยกโหมดเกม | เพิ่ม guard `GameManager.game_mode == "PVC" and side_to_move == BLACK → return` ใน `_handle_click()` (ดูตอนที่ 9.3) |
| ลาก volume slider แล้วเสียงไม่เปลี่ยนเลย | มี `AudioStreamPlayer` เล่นเพลงตรงๆ ในฉากขนานกับ `AudioManager` ผ่าน bus "Master" ที่ slider คุมไม่ถึง | ลบ node ที่เล่นเพลงตรงๆ ทิ้ง ให้เหลือทางเดียวผ่าน `AudioManager.play_music()` (ดูตอนที่ 10.4) |
| ปรับขนาดปุ่มเลื่อน (grabber) ของ HSlider ไม่ได้จาก Inspector | `Slider` วาด icon ตามขนาดพิกเซลจริงของไฟล์เสมอ ไม่มีช่อง Scale ให้ปรับ | resize ไฟล์ PNG ต้นฉบับโดยตรงแล้ว reimport (ดูตอนที่ 10.7.2) |
| ย้าย Control ออกจาก Container แล้วลาก/จัดตำแหน่งในวิวพอร์ตไม่ได้ | anchor/layout mode ยังเป็นค่าที่ container เคยตั้งไว้ ไม่ได้รีเซ็ตอัตโนมัติ | ตั้ง Anchor Preset → Top Left ใหม่ (ดูตอนที่ 10.7.5) |
| แก้ .tscn/.gd จากภายนอก (เช่นด้วยสคริปต์/เครื่องมืออื่น) แล้วค่าหายกลับไปเป็นของเดิม | Godot editor ที่เปิดค้างอยู่ save ทับตอนสลับกลับไปที่ editor | ปิด editor ก่อนแก้ไฟล์จากภายนอก หรือ reload scene ใน editor หลังแก้เสร็จเสมอ |
| หมากรุกดูรก/สับสน หลังกินหมากยังยืนอยู่ 2 ตัวซ้อนกันในช่องเดียว | ลืมแยกกรณี "โจมตีไม่ตาย" (`piece_moved = false`) ออกจาก "โจมตีตาย" ใน `try_move()` — ถ้าอัปเดต `board_state` แม้ตอนไม่ตาย จะมี 2 ตัวชนกันในช่องเดียว | ต้อง guard ทุกจุดที่แก้ `board_state`/`has_moved`/promotion/en-passant-target ด้วย `if piece_moved:` (ดูตอนที่ 11.3) |
| หลอดเลือด (HP bar) ยืด/บิดเบี้ยวตอนหมากขยายเวลาเลือกหรืออยู่คนละแถว | วาดใน `_draw()` โดยไม่ได้หารด้วย `scale` ปัจจุบันของ node | หารความกว้าง/สูง/ระยะห่างของหลอดด้วย `scale.x`/`scale.y` ทุกจุด (ดู `chess_piece.gd` ตอนที่ 11.1) |
| `Parse Error: Class "X" hides a global script class` | สร้างสคริปต์ใหม่ใน Godot แล้วลืมเปลี่ยนชื่อไฟล์จาก `new_script.gd` (ชื่อ default) ก่อนพิมพ์ `class_name` ลงไป ทำให้มี 2 ไฟล์ประกาศคลาสเดียวกันซ้ำ | หาไฟล์ `new_script.gd` (หรือชื่อ default อื่นๆ) ที่หลงเหลืออยู่ แล้วลบทิ้ง เหลือไว้แค่ไฟล์ที่ตั้งชื่อถูกไฟล์เดียว (ดูตอนที่ 11.8) |

### สิ่งที่คู่มือนี้ยังไม่ครอบคลุม (ต่อยอดเองได้)

| หัวข้อ | หมายเหตุ |
|---|---|
| **AI ยังไม่มีคะแนน king safety / piece-square table เต็มมาตรฐาน** | มีแค่ `positional_score()` แบบ heuristic ง่ายๆ 2 อย่าง (ตอนที่ 11.20) — ยังไม่เช็คว่าคิงถูกล้อมด้วยหมากป้องกันไหม |
| **ระดับความยาก AI ปรับจาก Settings ไม่ได้** | เคยทำ (ตอนที่ 11.19 เดิม) แล้วถอดออกเพราะสร้าง node ไม่ครบจนเกม error — กลับไปใช้ `const SEARCH_DEPTH := 2` ตายตัวใน `ai_player.gd` เหมือนเดิม ทำใหม่ได้ทีหลังถ้าอยากได้ (ดูหมายเหตุท้ายตอนที่ 11.20) |
| **Threefold repetition** | **ตั้งใจไม่ทำ** — ผู้เล่นตัดสินใจว่าเกมนี้ไม่ต้องการกลไกเสมอเพิ่ม เอาแค่ชนะ/แพ้พอ (อับ/หมากไม่พอ/50 ตาที่มีอยู่แล้วยังคงเดิม ไม่ได้ถอดออก แค่ไม่เพิ่มเงื่อนไขเสมอใหม่) |
| **King ไม่มีหลอดเลือดที่มีความหมายจริง** | ตั้ง `base_attack(KING)` ไว้เฉยๆ แต่คิงไม่เคยถูก `take_damage()` เรียกจริงในเกม เพราะกติกาหมากรุกไม่ยอมให้เดินไปกินคิงได้ตรงๆ (เกมจบด้วยรุกฆาตก่อนเสมอ) — เป็นพฤติกรรมที่ตั้งใจ ไม่ใช่บั๊ก |
| **ไม่มีหน้าจอ "ดูสถิติทั้งหมด"** | `StatsManager` (ตอนที่ 11.18) เก็บสถิติสะสมไว้แล้ว แต่มีแค่ toast ตอนปลดล็อก achievement ใหม่ ยังไม่มีฉากแยกไว้ดูค่าทั้งหมดย้อนหลัง |
| **ตัวหมากขยับไม่แข็ง (สมจริง)** | ตั้งใจไม่ทำต่อ — ตอนที่ 11.24 เพิ่ม idle sway (แกว่งตัวเอียงเบาๆ) แบบโค้ดล้วนๆ ไว้แล้ว ถือว่าเพียงพอ ถ้าจะเอาท่าทางเดิน/โจมตีจริงต้องมี sprite sheet หรือ `Skeleton2D` rig เป็นงานอาร์ตเพิ่ม |
