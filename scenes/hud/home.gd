extends Node

var mode:int
var pointer:int = 0
var file_dirs:Array = [null, null, null, null]
var dicts:Array = [null, null, null, null]

func _ready():
	MusicPlayer._play("start.wav", false)
	file_dirs[0] = "user://save_one.json"
	file_dirs[1] = "user://save_two.json"
	file_dirs[2] = "user://save_three.json"
	file_dirs[3] = "user://save_four.json"
	dicts[0] = Save._load(file_dirs[0])
	dicts[1] = Save._load(file_dirs[1])
	dicts[2] = Save._load(file_dirs[2])
	dicts[3] = Save._load(file_dirs[3])
	print(dicts[0])
	$Buttons/SaveSelect/Save1/ChapterCount/Text.text = str(dicts[0]["chapters_complete"])
	$Buttons/SaveSelect/Save1/PamphletCount/Text.text = str(dicts[0]["pamphlet_count"])
	print(dicts[1])
	$Buttons/SaveSelect/Save2/ChapterCount/Text.text = str(dicts[1]["chapters_complete"])
	$Buttons/SaveSelect/Save2/PamphletCount/Text.text = str(dicts[1]["pamphlet_count"])
	print(dicts[2])
	$Buttons/SaveSelect/Save3/ChapterCount/Text.text = str(dicts[2]["chapters_complete"])
	$Buttons/SaveSelect/Save3/PamphletCount/Text.text = str(dicts[2]["pamphlet_count"])
	print(dicts[3])
	$Buttons/SaveSelect/Save4/ChapterCount/Text.text = str(dicts[3]["chapters_complete"])
	$Buttons/SaveSelect/Save4/PamphletCount/Text.text = str(dicts[3]["pamphlet_count"])
	print("---------")
	mode = HomeState.mode
	if mode == 2:
		for node in $Buttons/ChapterSelect.get_children():
			if node.get_name() != "Pointer":
				node.visible = false
		$Buttons/ChapterSelect/Chapter1.position = Vector2(960, 448)
		$Buttons/ChapterSelect/Chapter1.scale = Vector2(1, 1)
		$Buttons/ChapterSelect/Chapter1.visible = true
		$Buttons/ChapterSelect/Chapter2.position = Vector2(960, 512)
		$Buttons/ChapterSelect/Chapter2.scale = Vector2(0.5, 0.5)
		$Buttons/ChapterSelect/Chapter2.visible = true


func _process(_delta):
	if not $Timer.is_stopped():
		return;
	match mode:#modes
		0:
			$Buttons/StartScreen.visible = true
			$Buttons/SaveSelect.visible = false
			$Buttons/ChapterSelect.visible = false
			_start_screen()
		1:
			$Buttons/StartScreen.visible = false
			$Buttons/SaveSelect.visible = true
			$Buttons/ChapterSelect.visible = false
			_save_select()
		2:
			$Buttons/StartScreen.visible = false
			$Buttons/SaveSelect.visible = false
			$Buttons/ChapterSelect.visible = true
			_chapter_select()

func _start_screen():
	match pointer:#anim
		0:
			$Buttons/StartScreen/Pointer.position = Vector2(880, 448)
			$Buttons/StartScreen/Start.play("on")
			$Buttons/StartScreen/Exit.play("off")
		1:
			$Buttons/StartScreen/Pointer.position = Vector2(880, 512)
			$Buttons/StartScreen/Start.play("off")
			$Buttons/StartScreen/Exit.play("on")
	if Input.is_action_pressed("ui_down") && pointer == 0:#down and up
		pointer += 1
		$Switch.play()
	if Input.is_action_pressed("ui_up") && pointer == 1:
		pointer -= 1
		$Switch.play()
	if Input.is_action_just_released("ui_select"):#pressed
		if pointer == 0:#starts
			$Click.play()
			$Buttons/StartScreen/Start.play("click")
			$Timer.start()
			#mode = 1
			#pointer = 0
		else:#quits
			get_tree().quit(0);

func _save_select():
	match pointer:#anim
		0:
			$Buttons/SaveSelect/Pointer.position = Vector2(880, 384)
			$Buttons/SaveSelect/Save1.play("on")
			$Buttons/SaveSelect/Save2.play("off")
			$Buttons/SaveSelect/Save3.play("off")
			$Buttons/SaveSelect/Save4.play("off")
		1:
			$Buttons/SaveSelect/Pointer.position = Vector2(880, 448)
			$Buttons/SaveSelect/Save1.play("off")
			$Buttons/SaveSelect/Save2.play("on")
			$Buttons/SaveSelect/Save3.play("off")
			$Buttons/SaveSelect/Save4.play("off")
		2:
			$Buttons/SaveSelect/Pointer.position = Vector2(880, 512)
			$Buttons/SaveSelect/Save1.play("off")
			$Buttons/SaveSelect/Save2.play("off")
			$Buttons/SaveSelect/Save3.play("on")
			$Buttons/SaveSelect/Save4.play("off")
		3:
			$Buttons/SaveSelect/Pointer.position = Vector2(880, 576)
			$Buttons/SaveSelect/Save1.play("off")
			$Buttons/SaveSelect/Save2.play("off")
			$Buttons/SaveSelect/Save3.play("off")
			$Buttons/SaveSelect/Save4.play("on")
	if Input.is_action_just_pressed("ui_down") && pointer < 3:#down and up
		$Switch.play()
		pointer += 1
	if Input.is_action_just_pressed("ui_up") && pointer > 0:
		$Switch.play()
		pointer -= 1
	if Input.is_action_just_released("ui_select"):#select
		$Click.play()
		match pointer:
			0:
				$Buttons/SaveSelect/Save1.play("click")
			1:
				$Buttons/SaveSelect/Save2.play("click")
			2:
				$Buttons/SaveSelect/Save3.play("click")
			3:
				$Buttons/SaveSelect/Save4.play("click")
		$Timer.start()
		#Save._open(file_dirs[pointer], dicts[pointer])
		#if Save.dict.has("chapter") and not Save.dict["chapter"] == "" and not Save.dict["chapter"] == null:
		#	get_tree().change_scene(Save.dict["chapter"])
		#else:
		#	mode = 2
		#	for node in $Buttons/ChapterSelect.get_children():
		#		if node.get_name() != "Pointer":
		#			node.visible = false
		#	$Buttons/ChapterSelect/Chapter1.position = Vector2(960, 448)
		#	$Buttons/ChapterSelect/Chapter1.scale = Vector2(1, 1)
		#	$Buttons/ChapterSelect/Chapter1.visible = true
		#	$Buttons/ChapterSelect/Chapter2.position = Vector2(960, 512)
		#	$Buttons/ChapterSelect/Chapter2.scale = Vector2(0.5, 0.5)
		#	$Buttons/ChapterSelect/Chapter2.visible = true
		#	pointer = 0
	if Input.is_action_just_released("ui_back"):
		mode = 0
		pointer = 0
	
func _chapter_select():
	var chapter = 1;#limits vis
	for node in $Buttons/ChapterSelect.get_children():
		if node.get_name() != "Pointer":
			if chapter == pointer+1:
				node.play("on")
			else:
				node.play("off")
			chapter += 1
	
	if Input.is_action_just_pressed("ui_down") && pointer < 7 && (pointer+1 <= Save.dict.chapters_complete || Save.debug):#down and up
		$Switch.play()
		pointer += 1
		$Tween.stop_all()
		chapter = 1;#limits vis
		for node in $Buttons/ChapterSelect.get_children():
			if node.get_name() != "Pointer":
				if chapter == pointer - 1:
					$Tween.interpolate_property(node, "position", Vector2(960, 384),
						Vector2(960, 320), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(0.5, 0.5),
						Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				elif chapter == pointer:
					$Tween.interpolate_property(node, "position", Vector2(960, 448),
						Vector2(960, 384), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(1, 1),
						Vector2(0.5, 0.5), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				elif chapter == pointer + 1:
					$Tween.interpolate_property(node, "position", Vector2(960, 512),
						Vector2(960, 448), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(0.5, 0.5),
						Vector2(1, 1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				elif chapter == pointer + 2:
					$Tween.interpolate_property(node, "position", Vector2(960, 576),
						Vector2(960, 512), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(0, 0),
						Vector2(0.5, 0.5), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				chapter += 1
		$Tween.start()
	if Input.is_action_just_pressed("ui_up") && pointer > 0:
		$Switch.play()
		pointer -= 1
		$Tween.stop_all()
		chapter = 1;#limits vis
		for node in $Buttons/ChapterSelect.get_children():
			if node.get_name() != "Pointer":
				if chapter == pointer:
					$Tween.interpolate_property(node, "position", Vector2(960, 360),
						Vector2(960, 384), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(0, 0),
						Vector2(0.5, 0.5), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				elif chapter == pointer + 1:
					$Tween.interpolate_property(node, "position", Vector2(960, 384),
						Vector2(960, 448), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(0.5, 0.5),
						Vector2(1, 1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				elif chapter == pointer + 2:
					$Tween.interpolate_property(node, "position", Vector2(960, 448),
						Vector2(960, 512), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(1, 1),
						Vector2(0.5, 0.5), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				elif chapter == pointer + 3:
					$Tween.interpolate_property(node, "position", Vector2(960, 512),
						Vector2(960, 576), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(node, "scale", Vector2(0.5, 0.5),
						Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					node.visible = true
				chapter += 1
		$Tween.start()
	if Input.is_action_just_released("ui_select"):
		$Click.play()
		match pointer:
			0:
				$Buttons/ChapterSelect/Chapter1.play("click")
			1:
				$Buttons/ChapterSelect/Chapter2.play("click")
			2:
				$Buttons/ChapterSelect/Chapter3.play("click")
			3:
				$Buttons/ChapterSelect/Chapter4.play("click")
			4:
				$Buttons/ChapterSelect/Chapter5.play("click")
			5:
				$Buttons/ChapterSelect/Chapter6.play("click")
			6:
				$Buttons/ChapterSelect/Chapter7.play("click")
			7:
				$Buttons/ChapterSelect/Chapter8.play("click")
		$Timer.start()
		#match pointer:
		#	0:
		#		get_tree().change_scene("res://scenes/chapters/chapter_one.tscn")
		#	1:
		#		get_tree().change_scene("res://scenes/chapters/chapter_two.tscn")
		#	2:
		#		get_tree().change_scene("res://scenes/chapters/chapter_three.tscn")
		#	3:
		#		get_tree().change_scene("res://scenes/chapters/chapter_four.tscn")
		#	4:
		#		get_tree().change_scene("res://scenes/chapters/chapter_five.tscn")
		#	5:
		#		get_tree().change_scene("res://scenes/chapters/chapter_six.tscn")
		#	6:
		#		get_tree().change_scene("res://scenes/chapters/chapter_seven.tscn")
		#	7:
		#		get_tree().change_scene("res://scenes/chapters/chapter_eight.tscn")
	if Input.is_action_just_released("ui_back"):
		mode = 1
		pointer = 0


func _on_Timer_timeout():
	if mode == 0:
		pointer = 0
		mode = 1
	elif mode == 1:
		Save._open(file_dirs[pointer], dicts[pointer])
		if Save.dict.has("chapter") and not Save.dict["chapter"] == "" and not Save.dict["chapter"] == null:
			get_tree().change_scene(Save.dict["chapter"])
		else:
			mode = 2
			for node in $Buttons/ChapterSelect.get_children():
				if node.get_name() != "Pointer":
					node.visible = false
			$Buttons/ChapterSelect/Chapter1.position = Vector2(960, 448)
			$Buttons/ChapterSelect/Chapter1.scale = Vector2(1, 1)
			$Buttons/ChapterSelect/Chapter1.visible = true
			$Buttons/ChapterSelect/Chapter2.position = Vector2(960, 512)
			$Buttons/ChapterSelect/Chapter2.scale = Vector2(0.5, 0.5)
			$Buttons/ChapterSelect/Chapter2.visible = true
			pointer = 0
	elif mode == 2:
		match pointer:
			0:
				get_tree().change_scene("res://scenes/chapters/chapter_one.tscn")
			1:
				get_tree().change_scene("res://scenes/chapters/chapter_two.tscn")
			2:
				get_tree().change_scene("res://scenes/chapters/chapter_three.tscn")
			3:
				get_tree().change_scene("res://scenes/chapters/chapter_four.tscn")
			4:
				get_tree().change_scene("res://scenes/chapters/chapter_five.tscn")
			5:
				get_tree().change_scene("res://scenes/chapters/chapter_six.tscn")
			6:
				get_tree().change_scene("res://scenes/chapters/chapter_seven.tscn")
			7:
				get_tree().change_scene("res://scenes/chapters/chapter_eight.tscn")
