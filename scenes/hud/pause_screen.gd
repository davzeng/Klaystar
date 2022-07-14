extends Control

#nodes
var player:Node
var animation_player:Node
var spawns_manager:Node
#sprites pos
var positions:Array = [Vector2(768, 256),Vector2(768, 320),Vector2(768, 384),Vector2(768, 448)]
var pos:int = 0

func _ready():
	#sets nodes
	player = get_tree().current_scene._get_player()
	animation_player = get_tree().current_scene._get_animation_player()
	spawns_manager = get_tree().current_scene._get_spawns_manager()
	visible = false
	if not Save.debug: 
		if Save.dict.has("chapters_complete") and Save.dict["chapters_complete"] == 0:
			if get_tree().current_scene.name == "ChapterOne":#activates in prologue
				print("first chp")
				$ChapterSelect.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_pause"):#pause and unpauses
		get_tree().paused = !get_tree().paused
		pos = 1
		$Pointer.position = positions[pos]
	visible = get_tree().paused#sets visibility of buttons
	$SkipCutscene.visible = animation_player.skip_waiting
	
	if get_tree().paused:
		if not $Timer.is_stopped():
			return
		if pos == 0:
			$SkipCutscene.play("on")
			$Continue.play("off")
			$SaveAndQuit.play("off")
			$ChapterSelect.play("off")
		if pos == 1:
			$SkipCutscene.play("off")
			$Continue.play("on")
			$SaveAndQuit.play("off")
			$ChapterSelect.play("off")
		if pos == 2:
			$SkipCutscene.play("off")
			$Continue.play("off")
			$SaveAndQuit.play("on")
			$ChapterSelect.play("off")
		if pos == 3:
			$SkipCutscene.play("off")
			$Continue.play("off")
			$SaveAndQuit.play("off")
			$ChapterSelect.play("on")
		if Input.is_action_just_pressed("ui_down"):#down key
			if not $ChapterSelect.visible:
				if pos < 2:
					pos += 1
					$Switch.play()
			else:
				if pos < 3:
					pos += 1
					$Switch.play()
			$Pointer.position = positions[pos]
		if Input.is_action_just_pressed("ui_up"):#up key
			if animation_player.skip_waiting:
				if pos > 0:
					pos -= 1
					$Switch.play()
			else:
				if pos > 1:
					pos -= 1
					$Switch.play()
			$Pointer.position = positions[pos]
		if Input.is_action_just_released("ui_select"):#select
			$Click.play()
			if pos == 0:#skip
				$SkipCutscene.play("click")
			elif pos == 1:#resume
				$Continue.play("click")
			elif pos == 2:#save and quit
				$SaveAndQuit.play("click")
			else:#chapter select
				$ChapterSelect.play("click")
			$Timer.start()


func _on_Timer_timeout():
	if pos == 0:#skip
		animation_player._skip()
		get_tree().paused = false
		visible = false
	elif pos == 1:#resume
		get_tree().paused = false
		visible = false
	elif pos == 2:#save and quit
		get_tree().paused = false
		Save._save(Save.SAVE_AND_QUIT)
		HomeState.mode = 0
		get_tree().change_scene("res://scenes/hud/home.tscn")
	else:#chapter select
		get_tree().paused = false
		Save._save(Save.RETURN_TO_SELECT)
		HomeState.mode = 2
		get_tree().change_scene("res://scenes/hud/home.tscn")
