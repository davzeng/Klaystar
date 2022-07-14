extends Node2D#might be deleated


var player :Node

func _ready():
	player = get_tree().current_scene._get_player()

func _teleport():
	player._teleport(position)
