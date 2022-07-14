extends AnimatedSprite

var player :Node

func _ready():#pause node and sets playe
	player = get_tree().current_scene._get_player()
	play("idle")

func _physics_process(delta):#detects player
	if player.zero_g:
		visible = false
		return
	
	visible = true
	if $Area.overlaps_body(player):
		player.zero_g = true
		play("activate")

func _bound_changed():
	play("idle")
