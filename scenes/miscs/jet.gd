extends Area2D

export var direction:int

var player :Node
var force :Vector2
func _ready():
	match direction:#sets direction
		0:
			force = Vector2(0, -4500)
		1:
			force = Vector2(4500, 0)
		2:
			force = Vector2(0, 4500)
		3:
			force = Vector2(-4500, 0)
	player = get_tree().current_scene._get_player()
	$AnimatedSprite.play("default")


func _physics_process(delta):#pushes player
	if overlaps_body(player) and not player.velocity.y < -1200:
		player._push(force * delta)
