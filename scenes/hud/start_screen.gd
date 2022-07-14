extends Control

var top:Vector2 = Vector2(672, 448)#positions
var bottom:Vector2 = Vector2(672, 544)

var start:bool = true

func _ready():#sets pos
	MusicPlayer._stop()
	$Sprite.position = top

func _process(_delta):
	if Input.is_action_pressed("ui_down"):#down and up
		start = false
		$Sprite.position = bottom
	if Input.is_action_pressed("ui_up"):
		start = true
		$Sprite.position = top
	
	if Input.is_action_just_released("ui_select"):#pressed
		if start:#starts
			get_tree().change_scene("res://scenes/hud/save_select.tscn")
		else:#quits
			get_tree().quit(0);
