extends Area2D

var player :Node

func _ready():#pause node and sets player
	player = get_tree().current_scene._get_player()

func _physics_process(_delta):
	if overlaps_body(player):
		if not player.warp:
			player.dead = true
