extends Node2D

var player :Node
var primed:bool

func _ready():#pause node and sets player
	player = get_tree().current_scene._get_player()

func _physics_process(_delta):#detects player
	if $Area.overlaps_body(player):
		if primed:
			var vec = (_center() - player._center()).normalized()
			var pos = _center() - (player._center()-player.position) + (vec*224)
			player._warp(pos, vec*700)
			#player.position = _center() - (player._center()-player.position) + (vec*224)
			#player.velocity = vec*700
			player.on_floor_window = 0
			player.jump_extend_window = 0
			$Timer.start()
			primed = false
	else:
		primed = true
	

func _center() -> Vector2:#returns center coordinates
	return position + Vector2(224, 224)
	
