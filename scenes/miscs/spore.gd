extends Node2D

var player :Node

func _ready():#pause node and sets player
	player = get_tree().current_scene._get_player()
	$Sprite.play("idle")

func _physics_process(_delta):#detects player
	if $Area.overlaps_body(player) and $Sprite.animation == "idle":
		$Sprite.play("warn")

func _center() -> Vector2:#returns center coordinates
	return position + $Center.position
	
func _blast():#throws player
	if $Area.overlaps_body(player):
		player._push((player._center() - _center()).normalized()*900)
	for node in get_tree().get_nodes_in_group("BoundBased"):
		if node.has_method("_fall"):
			node._fall()

func _on_Sprite_animation_finished():#mananges animation ques
	if $Sprite.animation == "warn":
		$Sprite.play("explode")
		$Pop.play()
	elif $Sprite.animation == "explode":
		$Sprite.play("regen")
		$Res.play()
	elif $Sprite.animation == "regen":
		$Sprite.play("idle")


func _on_Sprite_frame_changed():#blasts when on the right frame
	if $Sprite.animation == "explode" and $Sprite.frame == 6:
		_blast()
