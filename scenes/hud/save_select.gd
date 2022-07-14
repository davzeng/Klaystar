extends Control

#current save
var select:int = 0
var reset:bool = false

func _ready():
	MusicPlayer._stop()

func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):#up and down
		if select < 3:
			get_child(select)._unselected()
			get_child(select+1)._selected()
			select += 1
			reset = false
	if Input.is_action_just_pressed("ui_up"):
		if select > 0:
			get_child(select)._unselected()
			get_child(select-1)._selected()
			select -= 1
			reset = false
	if Input.is_action_just_pressed("ui_right"):
		reset = true
	elif Input.is_action_just_pressed("ui_left"):
		reset = false
		
	if Input.is_action_just_released("ui_select"):#select
		if reset:
			get_child(select)._reset()
		else:
			get_child(select)._triggered()
	if Input.is_action_just_released("ui_back"):#return to start
		get_tree().change_scene("res://scenes/hud/start_screen.tscn")
