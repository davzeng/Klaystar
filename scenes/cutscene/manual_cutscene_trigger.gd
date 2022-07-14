extends Area2D
#anim
export var animation: String
export var prompt_position: Vector2
var player :Node
var animation_player :Node

func _ready():
	#sets nodes
	player = get_tree().current_scene._get_player()
	animation_player = get_tree().current_scene._get_animation_player()
	$Prompt.position = prompt_position

func _physics_process(_delta):#controls animation/activation
	if overlaps_body(player):
		if not player.ball:#stops player from being ball
			player.in_cs = true
		if Input.is_action_just_pressed("ui_select") and animation_player.current_animation == "":
			animation_player.play(animation)
		$Prompt.visible = true
	else:
		$Prompt.visible = false
