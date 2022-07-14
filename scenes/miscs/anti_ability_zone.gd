extends Node2D

export var area:Vector2 = Vector2(1,1)
#nodes
var player :Node
var malo:Node
var malo_area :Node

func _ready():
	#set children
	$Sprite.material.set_shader_param("sprite_scale", area)
	$Area.scale = area
	$Sprite.scale = area
	#set nodes
	player = get_tree().current_scene._get_player()
	malo = get_tree().current_scene._get_malo()
	malo_area = get_tree().current_scene._get_malo().get_node("Area")

func _physics_process(delta):
	if $Area.overlaps_body(player):
		if malo.burb and $Area.overlaps_area(malo_area):#looks for dead mode
			player.dead = true
		if player.ball:
			player.dead = true
