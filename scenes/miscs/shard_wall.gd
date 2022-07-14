extends Node2D

export var req:int = 0
var player :Node

func _ready():
	player = get_tree().current_scene._get_player()

func _physics_process(delta):
	#checks shards
	if player.shards >= req:
		$BarrierZone.set_collision_layer_bit(1, false)
